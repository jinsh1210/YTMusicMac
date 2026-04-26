import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var windowCoordinator: WindowCoordinator?

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            windowCoordinator?.bringMainWindowToFront()
        }
        return true
    }
}
