import SwiftUI
import WebKit

struct MusicWebView: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context _: Context) -> WKWebView {
        webView.wantsLayer = true
        webView.layer?.backgroundColor = CGColor.clear
        // WKWebView 내부의 WKScrollView 배경도 투명하게 처리
        webView.subviews.compactMap { $0 as? NSScrollView }.forEach {
            $0.drawsBackground = false
            $0.backgroundColor = .clear
        }
        return webView
    }

    func updateNSView(_: WKWebView, context _: Context) {}
}
