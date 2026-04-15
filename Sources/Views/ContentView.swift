import SwiftUI
import WebKit

struct ContentView: View {
    let webView: WKWebView

    var body: some View {
        MusicWebView(webView: webView)
    }
}
