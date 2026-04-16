import SwiftUI
import Sparkle

@main
struct YTMusicMacApp: App {
    @StateObject private var playerManager = MusicPlayerManager()
    private let updaterController: SPUUpdaterController

    init() {
        let manager = MusicPlayerManager()
        _playerManager = StateObject(wrappedValue: manager)
        updaterController = SPUUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(manager: playerManager)
                .frame(minWidth: 940, minHeight: 600)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    updaterController.updater.checkForUpdates()
                }
            }
        }
    }
}
