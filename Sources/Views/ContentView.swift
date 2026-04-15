import SwiftUI

struct ContentView: View {
    @EnvironmentObject var playerManager: MusicPlayerManager

    var body: some View {
        ZStack {
            MusicWebView(webView: playerManager.webView)
                .edgesIgnoringSafeArea(.all)

            if playerManager.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}
