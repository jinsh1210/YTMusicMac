import WebKit
import Combine

final class MusicPlayerManager: NSObject, ObservableObject {
    @Published var currentTrack: Track?
    @Published var isPlaying = false
    @Published var isLoading = true

    let webView: WKWebView

    override init() {
        let config = WKWebViewConfiguration()
        config.userContentController = WKUserContentController()

        // Persistent storage for cookies
        config.websiteDataStore = .default()

        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init()

        setupWebView()
    }

    private func setupWebView() {
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"

        let url = URL(string: "https://music.youtube.com")!
        webView.load(URLRequest(url: url))
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
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
}

extension MusicPlayerManager: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
    }
}

struct Track: Equatable {
    let title: String
    let artist: String
    let albumArt: URL?
}
