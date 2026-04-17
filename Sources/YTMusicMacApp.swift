import Sparkle
import SwiftUI

@main
struct YTMusicMacApp: App {
    @StateObject private var playerManager: MusicPlayerManager
    private let updater: SPUUpdater

    init() {
        let manager = MusicPlayerManager()
        _playerManager = StateObject(wrappedValue: manager)

        let hostBundle = Bundle.main
        let applicationBundle = hostBundle
        let userDriver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: nil)
        updater = SPUUpdater(hostBundle: hostBundle, applicationBundle: applicationBundle, userDriver: userDriver, delegate: nil)

        try? updater.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(manager: playerManager)
                .frame(minWidth: 1050, minHeight: 750)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    updater.checkForUpdates()
                }
            }
        }
    }
}
