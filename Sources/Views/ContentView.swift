import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject var manager: MusicPlayerManager

    var body: some View {
        ZStack {
            MusicWebView(webView: manager.webView)

            if manager.isLoading {
                ZStack {
                    Color(NSColor.windowBackgroundColor)
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.15), value: manager.isLoading)
    }
}
