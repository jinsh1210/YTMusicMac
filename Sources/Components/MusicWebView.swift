import SwiftUI
import WebKit

struct MusicWebView: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context _: Context) -> WKWebView {
        webView.wantsLayer = true
        return webView
    }

    func updateNSView(_: WKWebView, context _: Context) {}
}
