import SwiftUI

@main
struct YTMusicMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var playerManager: MusicPlayerManager
    @StateObject private var windowCoordinator: WindowCoordinator
    private let updateChecker = UpdateChecker()

    init() {
        let manager = MusicPlayerManager()
        _playerManager = StateObject(wrappedValue: manager)
        _windowCoordinator = StateObject(wrappedValue: WindowCoordinator(manager: manager))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(manager: playerManager)
                .frame(minWidth: 1050, minHeight: 750)
                .environmentObject(windowCoordinator)
                .onAppear {
                    appDelegate.windowCoordinator = windowCoordinator
                }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("업데이트 확인...") {
                    updateChecker.checkForUpdates()
                }
            }
        }

        Settings {
            SettingsView()
        }
    }
}
