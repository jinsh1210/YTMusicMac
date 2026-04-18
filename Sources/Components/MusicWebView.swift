import SwiftUI
import WebKit

struct MusicWebView: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context _: Context) -> WKWebView {
        webView.wantsLayer = true
        webView.layer?.backgroundColor = NSColor.black.cgColor
        webView.subviews.compactMap { $0 as? NSScrollView }.forEach {
            $0.drawsBackground = false
            $0.backgroundColor = .black
        }
        return webView
    }

    func updateNSView(_: WKWebView, context _: Context) {}
}
