import Combine
import WebKit

@MainActor
final class MusicPlayerManager: NSObject, ObservableObject {
    @Published var currentTrack: Track?
    @Published var isPlaying = false
    @Published var isLoading = true

    let webView: WKWebView

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

    private func setupWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
        // macOS 15 + Safari 18 — YouTube Music이 지원 브라우저로 인식하며, 패스키(macOS 13+ 필요)도 동작
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 15_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"

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
                setTimeout(observePlayer, 500);
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
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        isLoading = false
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let host = url.host ?? ""

        // www.youtube.com 은 music.youtube.com 으로 리다이렉트
        // (로그인 후 Google OAuth 콜백이 www.youtube.com 으로 오는 경우 포함)
        if host == "www.youtube.com" {
            let musicUrl = url.absoluteString.replacingOccurrences(of: "www.youtube.com", with: "music.youtube.com")
            if let newUrl = URL(string: musicUrl) {
                webView.load(URLRequest(url: newUrl))
                decisionHandler(.cancel)
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
