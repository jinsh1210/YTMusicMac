import Combine
import WebKit

@MainActor
final class MusicPlayerManager: NSObject, ObservableObject {
    @Published var currentTrack: Track?
    @Published var isPlaying = false
    @Published var isLoading = true

    let webView: WKWebView
    /// 로그인 흐름 추적: accounts.google.com 을 경유했는지 여부
    private var isComingFromLogin = false

    override init() {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        config.userContentController = controller
        config.websiteDataStore = .default()
        config.allowsAirPlayForMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: config)
        super.init()

        setupWebView()
        setupMessageHandlers()
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
        // macOS 15 Safari 18 최신 UserAgent - YouTube Music 데스크톱 모드 안정성 확보
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"

        let url = URL(string: "https://music.youtube.com")!
        webView.load(URLRequest(url: url))
    }

    private func setupMessageHandlers() {
        // WeakMessageHandler 프록시를 사용해 순환 참조(retain cycle) 방지
        let handler = WeakMessageHandler(self)
        webView.configuration.userContentController.add(handler, name: "trackChanged")
        webView.configuration.userContentController.add(handler, name: "playbackChanged")

        // setInterval 대신 MutationObserver를 사용해 플레이어 상태 변화를 이벤트 기반으로 감지
        let scriptSource = """
        // music.youtube.com 에서만 실행 — 로그인 페이지 등 다른 도메인에서 DOM 감시로 인한 간섭 방지
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
                    const isPlaying = document.querySelector('#play-pause-button')?.getAttribute('aria-label') === '일시중지' ||
                                       document.querySelector('#play-pause-button')?.getAttribute('aria-label') === 'Pause';

                    window.webkit.messageHandlers.trackChanged.postMessage({title, artist, art});
                    window.webkit.messageHandlers.playbackChanged.postMessage(isPlaying);
                } catch(e) {}
            }

            const observer = new MutationObserver(updateStatus);
            observer.observe(playerBar, { childList: true, subtree: true, attributes: true, attributeFilter: ['aria-label', 'src'] });
            window.addEventListener('pagehide', () => observer.disconnect(), { once: true });
            updateStatus();
        }
        observePlayer();
        """
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
    }

    func handleMessage(_ message: WKScriptMessage) {
        if message.name == "trackChanged", let dict = message.body as? [String: String] {
            let newTrack = Track(title: dict["title"] ?? "", artist: dict["artist"] ?? "", albumArt: URL(string: dict["art"] ?? ""))
            if currentTrack != newTrack { currentTrack = newTrack }
        } else if message.name == "playbackChanged", let playing = message.body as? Bool {
            isPlaying = playing
        }
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

    private func executeJavaScript(_ script: String) {
        Task {
            try? await webView.evaluateJavaScript(script)
        }
    }
}

/// WKScriptMessageHandler 순환 참조 방지를 위한 약한 참조 프록시
private class WeakMessageHandler: NSObject, WKScriptMessageHandler {
    weak var manager: MusicPlayerManager?

    init(_ manager: MusicPlayerManager) {
        self.manager = manager
    }

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        Task { @MainActor [weak self] in
            self?.manager?.handleMessage(message)
        }
    }
}

extension MusicPlayerManager: WKNavigationDelegate {
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        isLoading = true
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        if let url = webView.url?.absoluteString, url.contains("logout") {
            isLoading = true
        } else {
            isLoading = false
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // 서브 프레임(iframe) 내비게이션은 인터셉트 없이 허용
        if let targetFrame = navigationAction.targetFrame, !targetFrame.isMainFrame {
            decisionHandler(.allow)
            return
        }
        // targetFrame == nil 은 새 창(window.open) — 아래 로직으로 계속 처리

        let host = url.host ?? ""

        // Google 계열 도메인 진입 시 로그인 흐름 표시
        // accounts.youtube.com 도 포함
        if host.hasSuffix(".google.com") || host == "google.com" || host == "accounts.youtube.com" {
            isComingFromLogin = true
            decisionHandler(.allow)
            return
        }

        // YouTube Music — 로그인 흐름 초기화 후 허용
        if host == "music.youtube.com" {
            isComingFromLogin = false
            decisionHandler(.allow)
            return
        }

        // 일반 YouTube — 로그인 후 리다이렉트이거나 루트 경로이면 YouTube Music으로 전환
        let youtubeHosts = ["www.youtube.com", "youtube.com", "m.youtube.com"]
        if youtubeHosts.contains(host) {
            if isComingFromLogin || url.path == "/" || url.path == "" {
                isComingFromLogin = false
                isLoading = true
                decisionHandler(.cancel)
                DispatchQueue.main.async {
                    webView.load(URLRequest(url: URL(string: "https://music.youtube.com")!))
                }
                return
            }
        }

        decisionHandler(.allow)
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
