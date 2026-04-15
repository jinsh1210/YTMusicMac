import SwiftUI

@main
struct YTMusicMacApp: App {
    @StateObject private var playerManager = MusicPlayerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerManager)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
