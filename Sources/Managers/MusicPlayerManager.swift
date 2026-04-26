import Combine
import WebKit

@MainActor
final class MusicPlayerManager: NSObject, ObservableObject {
    @Published var currentTrack: Track?
    @Published var isPlaying = false
    @Published var isLoading = true
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var albumArtImage: NSImage?
    @Published var isShuffled = false
    @Published var repeatMode: RepeatMode = .off

    let webView: WKWebView
    private var isAuthenticating = false

    override init() {
        let prefs = WKWebpagePreferences()
        prefs.preferredContentMode = .desktop

        let config = WKWebViewConfiguration()
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
            ucc.removeScriptMessageHandler(forName: "progressChanged")
            ucc.removeScriptMessageHandler(forName: "shuffleChanged")
            ucc.removeScriptMessageHandler(forName: "repeatChanged")
            webView.navigationDelegate = nil
            webView.uiDelegate = nil
        }
    }

    private func setupWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"

        // AppKit 레벨에서 다크 모드 강제 적용 — WKScrollView 배경이 시스템 라이트 모드일 때
        // 흰색으로 그려지는 문제의 근본 원인을 차단
        webView.appearance = NSAppearance(named: .darkAqua)
        webView.setValue(false, forKey: "drawsBackground")
        if #available(macOS 12.0, *) {
            webView.underPageBackgroundColor = .clear
        }
    }

    private func loadInitialURL() {
        webView.load(URLRequest(url: URL(string: "https://music.youtube.com")!))
    }

    private func setupMessageHandlers() {
        let handler = WeakMessageHandler(self)
        webView.configuration.userContentController.add(handler, name: "trackChanged")
        webView.configuration.userContentController.add(handler, name: "playbackChanged")
        webView.configuration.userContentController.add(handler, name: "progressChanged")
        webView.configuration.userContentController.add(handler, name: "shuffleChanged")
        webView.configuration.userContentController.add(handler, name: "repeatChanged")

        let ucc = webView.configuration.userContentController
        ucc.addUserScript(WKUserScript(source: PlayerScripts.scrollbarStyle, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        ucc.addUserScript(WKUserScript(source: PlayerScripts.playerObserver, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
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
        switch message.name {
        case "trackChanged": handleTrackChanged(message.body)
        case "playbackChanged": handlePlaybackChanged(message.body)
        case "progressChanged": handleProgressChanged(message.body)
        case "shuffleChanged": handleShuffleChanged(message.body)
        case "repeatChanged": handleRepeatChanged(message.body)
        default: break
        }
    }

    private func handleTrackChanged(_ body: Any) {
        guard let dict = body as? [String: String] else { return }
        let newTrack = Track(title: dict["title"] ?? "", artist: dict["artist"] ?? "", albumArt: URL(string: dict["art"] ?? ""))
        if currentTrack != newTrack {
            currentTrack = newTrack
            loadAlbumArt(url: newTrack.albumArt)
        }
    }

    private func handlePlaybackChanged(_ body: Any) {
        guard let playing = body as? Bool else { return }
        isPlaying = playing
    }

    private func handleProgressChanged(_ body: Any) {
        guard let dict = body as? [String: Any] else { return }
        if let time = dict["currentTime"] as? Double { currentTime = time }
        if let dur = dict["duration"] as? Double { duration = dur }
    }

    private func handleShuffleChanged(_ body: Any) {
        guard let active = body as? Bool else { return }
        isShuffled = active
    }

    private func handleRepeatChanged(_ body: Any) {
        guard let raw = body as? String else { return }
        switch raw {
        case "one": repeatMode = .one
        case "all": repeatMode = .all
        default: repeatMode = .off
        }
    }

    private func loadAlbumArt(url: URL?) {
        guard let url else { albumArtImage = nil; return }
        Task.detached(priority: .userInitiated) {
            var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
            // lh3.googleusercontent.com CDN — User-Agent 없으면 403
            request.setValue(
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
                forHTTPHeaderField: "User-Agent"
            )
            request.setValue("https://music.youtube.com", forHTTPHeaderField: "Referer")
            guard let (data, _) = try? await URLSession.shared.data(for: request),
                  let image = NSImage(data: data) else { return }
            await MainActor.run { self.albumArtImage = image }
        }
    }

    func seek(to time: Double) {
        executeJavaScript("document.querySelector('video').currentTime = \(time)")
    }

    func togglePlay() {
        executeJavaScript("document.querySelector('#play-pause-button').click()")
    }

    func nextTrack() {
        executeJavaScript("document.querySelector('.next-button').click()")
    }

    func previousTrack() {
        executeJavaScript("document.querySelector('.previous-button').click()")
    }

    func toggleShuffle() {
        executeJavaScript("""
        (function() {
            const bar = document.querySelector('ytmusic-player-bar');
            if (!bar) return;
            const btn = Array.from(bar.querySelectorAll('button')).find(b =>
                (b.getAttribute('aria-label') || '').includes('셔플') ||
                (b.getAttribute('aria-label') || '').toLowerCase().includes('shuffle')
            );
            if (btn) btn.click();
        })();
        """)
    }

    func cycleRepeat() {
        executeJavaScript("""
        (function() {
            const bar = document.querySelector('ytmusic-player-bar');
            if (!bar) return;
            const btn = Array.from(bar.querySelectorAll('button')).find(b =>
                (b.getAttribute('aria-label') || '').includes('반복') ||
                (b.getAttribute('aria-label') || '').toLowerCase().includes('repeat')
            );
            if (btn) btn.click();
        })();
        """)
    }

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
    init(_ manager: MusicPlayerManager) {
        self.manager = manager
    }

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

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        preferences.preferredContentMode = .desktop
        guard let url = navigationAction.request.url,
              let targetFrame = navigationAction.targetFrame,
              targetFrame.isMainFrame
        else {
            decisionHandler(.allow, preferences)
            return
        }
        let policy = navigationPolicy(for: url, webView: webView)
        decisionHandler(policy, preferences)
    }

    private func navigationPolicy(for url: URL, webView: WKWebView) -> WKNavigationActionPolicy {
        let host = url.host ?? ""
        if host.hasSuffix(".google.com") || host == "google.com" || host == "accounts.youtube.com" {
            isAuthenticating = true
            return .allow
        }
        if host == "music.youtube.com" {
            isAuthenticating = false
            return .allow
        }
        let youtubeHosts = ["www.youtube.com", "youtube.com", "m.youtube.com"]
        if youtubeHosts.contains(host), isAuthenticating || url.path == "/" || url.path == "" {
            isAuthenticating = false
            isLoading = true
            webView.load(URLRequest(url: URL(string: "https://music.youtube.com")!))
            return .cancel
        }
        return .allow
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

enum RepeatMode {
    case off, all, one
}
