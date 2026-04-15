import SwiftUI

@main
struct YTMusicMacApp: App {
    @StateObject private var playerManager = MusicPlayerManager()

    var body: some Scene {
        WindowGroup {
            ContentView(manager: playerManager)
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}
