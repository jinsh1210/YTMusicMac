import Combine
import WebKit

@MainActor
final class MusicPlayerManager: NSObject, ObservableObject {
    @Published var currentTrack: Track?
    @Published var isPlaying = false
    @Published var isLoading = true

    let webView: WKWebView
    private var isAuthenticating = false

    override init() {
        let prefs = WKWebpagePreferences()
        prefs.preferredContentMode = .desktop
        prefs.allowsContentJavaScript = true

        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        config.userContentController = controller
        config.websiteDataStore = .default()
        config.allowsAirPlayForMediaPlayback = true
        config.upgradeKnownHostsToHTTPS = true
        config.defaultWebpagePreferences = prefs
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: .zero, configuration: config)
        super.init()

        setupWebView()
        setupMessageHandlers()
        Task {
            await setupContentRules()
            loadInitialURL()
            // DMG 이젝션 로직을 백그라운드 우선순위로 실행
            Task(priority: .background) {
                checkAndEjectDMG()
            }
        }
    }

    deinit {
        MainActor.assumeIsolated {
            let ucc = webView.configuration.userContentController
            ucc.removeScriptMessageHandler(forName: "trackChanged")
            ucc.removeScriptMessageHandler(forName: "playbackChanged")
            webView.navigationDelegate = nil
            webView.uiDelegate = nil
        }
    }

    private func setupWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
    }

    private func loadInitialURL() {
        webView.load(URLRequest(url: URL(string: "https://music.youtube.com")!))
    }

    private func setupMessageHandlers() {
        let handler = WeakMessageHandler(self)
        webView.configuration.userContentController.add(handler, name: "trackChanged")
        webView.configuration.userContentController.add(handler, name: "playbackChanged")

        let scriptSource = """
        if (window.location.hostname !== 'music.youtube.com') return;
        function observePlayer() {
            const playerBar = document.querySelector('ytmusic-player-bar');
            if (!playerBar) {
                setTimeout(observePlayer, 1000); // 1초 간격으로 확인
                return;
            }
            function updateStatus() {
                try {
                    const title = document.querySelector('.title.style-scope.ytmusic-player-bar')?.innerText || "";
                    const artist = document.querySelector('.byline.style-scope.ytmusic-player-bar')?.innerText || "";
                    const art = document.querySelector('#layout > ytmusic-player-bar > div.middle-controls.style-scope.ytmusic-player-bar > img')?.src || "";
                    const playBtnLabel = document.querySelector('#play-pause-button')?.getAttribute('aria-label') ?? '';
                    const isPlaying = playBtnLabel === '일시중지' || playBtnLabel === 'Pause';
                    window.webkit.messageHandlers.trackChanged.postMessage({title, artist, art});
                    window.webkit.messageHandlers.playbackChanged.postMessage(isPlaying);
                } catch(e) {}
            }
            let _t;
            const observer = new MutationObserver(() => { clearTimeout(_t); _t = setTimeout(updateStatus, 100); });
            observer.observe(playerBar, { childList: true, subtree: true, attributes: true, attributeFilter: ['aria-label', 'src'] });
            window.addEventListener('pagehide', () => { observer.disconnect(); clearTimeout(_t); }, { once: true });
            updateStatus();
        }
        observePlayer();
        """
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
    }

    private func setupContentRules() async {
        guard let store = WKContentRuleListStore.default() else { return }
        let identifier = "YTMusicBlock"

        // 캐시된 규칙 우선 조회 — 매 실행마다 재컴파일하지 않아 URL 로드 지연을 방지
        let cached = await withCheckedContinuation { (cont: CheckedContinuation<WKContentRuleList?, Never>) in
            store.lookUpContentRuleList(forIdentifier: identifier) { list, _ in
                cont.resume(returning: list)
            }
        }
        if let cached {
            webView.configuration.userContentController.add(cached)
            return
        }

        // 최초 실행 시에만 컴파일 후 디스크에 저장
        let rules = #"""
        [
            {"trigger":{"url-filter":".*\\.doubleclick\\.net"},"action":{"type":"block"}},
            {"trigger":{"url-filter":".*googlesyndication\\.com"},"action":{"type":"block"}},
            {"trigger":{"url-filter":".*google-analytics\\.com"},"action":{"type":"block"}},
            {"trigger":{"url-filter":".*googletagmanager\\.com"},"action":{"type":"block"}},
            {"trigger":{"url-filter":".*googleadservices\\.com"},"action":{"type":"block"}}
        ]
        """#
        await withCheckedContinuation { continuation in
            store.compileContentRuleList(forIdentifier: identifier, encodedContentRuleList: rules) { [weak self] ruleList, _ in
                if let self, let ruleList {
                    self.webView.configuration.userContentController.add(ruleList)
                }
                continuation.resume()
            }
        }
    }

    func handleMessage(_ message: WKScriptMessage) {
        if message.name == "trackChanged", let dict = message.body as? [String: String] {
            let newTrack = Track(title: dict["title"] ?? "", artist: dict["artist"] ?? "", albumArt: URL(string: dict["art"] ?? ""))
            if currentTrack != newTrack { currentTrack = newTrack }
        } else if message.name == "playbackChanged", let playing = message.body as? Bool {
            isPlaying = playing
        }
    }

    func togglePlay() { executeJavaScript("document.querySelector('#play-pause-button').click()") }
    func nextTrack() { executeJavaScript("document.querySelector('.next-button').click()") }
    func previousTrack() { executeJavaScript("document.querySelector('.previous-button').click()") }

    private func executeJavaScript(_ script: String) {
        Task { try? await webView.evaluateJavaScript(script) }
    }

    private func checkAndEjectDMG() {
        let bundlePath = Bundle.main.bundlePath
        if bundlePath.hasPrefix("/Applications"), FileManager.default.fileExists(atPath: "/Volumes/YTMusicMac") {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
            process.arguments = ["detach", "/Volumes/YTMusicMac", "-quiet"]
            try? process.run()
        }
    }
}

private class WeakMessageHandler: NSObject, WKScriptMessageHandler {
    weak var manager: MusicPlayerManager?
    init(_ manager: MusicPlayerManager) { self.manager = manager }
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        Task { @MainActor [weak self] in self?.manager?.handleMessage(message) }
    }
}

extension MusicPlayerManager: WKNavigationDelegate {
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        isLoading = true
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        isLoading = false
    }

    // WKWebpagePreferences를 포함하는 최신 델리게이트 메서드로 교체하여 데스크탑 모드 강제
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow, preferences)
            return
        }

        // 매 이동마다 데스크탑 모드 강제 적용
        preferences.preferredContentMode = .desktop

        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            decisionHandler(.allow, preferences)
            return
        }

        let host = url.host ?? ""
        if host.hasSuffix(".google.com") || host == "google.com" || host == "accounts.youtube.com" {
            isAuthenticating = true
            decisionHandler(.allow, preferences)
            return
        }

        if host == "music.youtube.com" {
            isAuthenticating = false
            decisionHandler(.allow, preferences)
            return
        }

        let youtubeHosts = ["www.youtube.com", "youtube.com", "m.youtube.com"]
        if youtubeHosts.contains(host) {
            if isAuthenticating || url.path == "/" || url.path == "" {
                isAuthenticating = false
                isLoading = true
                decisionHandler(.cancel, preferences)
                webView.load(URLRequest(url: URL(string: "https://music.youtube.com")!))
                return
            }
        }

        decisionHandler(.allow, preferences)
    }
}

extension MusicPlayerManager: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil { webView.load(navigationAction.request) }
        return nil
    }
}

struct Track: Equatable {
    let title: String
    let artist: String
    let albumArt: URL?
}
