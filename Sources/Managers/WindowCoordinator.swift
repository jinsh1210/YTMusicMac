import AppKit
import SwiftUI

@MainActor
final class WindowCoordinator: NSObject, ObservableObject {
    private weak var manager: MusicPlayerManager?
    private var floatingWindow: NSWindow?
    private var mainWindow: NSWindow?

    @AppStorage("floatingWidgetEnabled") private var floatingWidgetEnabled = true
    @AppStorage("floatingWidgetOnMinimize") private var floatingWidgetOnMinimize = true
    @AppStorage("floatingWidgetOnClose") private var floatingWidgetOnClose = true

    init(manager: MusicPlayerManager) {
        self.manager = manager
        super.init()
        observeMainWindow()
    }

    func setMainWindow(_ window: NSWindow) {
        guard mainWindow == nil else { return }
        mainWindow = window
        // 상태 복원 비활성화 — 이전 세션에서 숨겨진 상태가 복원되어 앱이 최소화 상태로 시작되는 문제 방지
        window.isRestorable = false
        window.makeKeyAndOrderFront(nil)
        DispatchQueue.main.async { [weak self, weak window] in
            guard let self, let window else { return }
            window.delegate = self
        }
    }

    func bringMainWindowToFront() {
        guard let window = mainWindow else { return }
        if window.isMiniaturized { window.deminiaturize(nil) }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        hideFloatingPlayer()
    }

    // MARK: - Floating Window

    func showFloatingPlayer() {
        guard floatingWidgetEnabled else { return }

        // 창이 이미 있으면 재사용 — 새로 만들면 @ObservedObject 연결이 끊어짐
        if let existing = floatingWindow {
            if !existing.isVisible {
                existing.orderFront(nil)
            }
            return
        }

        guard let manager else { return }
        let content = FloatingPlayerView(manager: manager, onOpenMain: { [weak self] in
            self?.bringMainWindowToFront()
        })

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 110),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true

        let hostingView = NSHostingView(rootView: content)
        hostingView.frame = NSRect(x: 0, y: 0, width: 320, height: 110)
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        hostingView.layer?.isOpaque = false
        window.contentView = hostingView
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isRestorable = false

        if let screen = NSScreen.main {
            let originX = screen.visibleFrame.maxX - 320 - 16
            let originY = screen.visibleFrame.minY + 16
            window.setFrameOrigin(NSPoint(x: originX, y: originY))
        }

        window.orderFront(nil)
        floatingWindow = window
    }

    func hideFloatingPlayer() {
        floatingWindow?.orderOut(nil)
    }

    // MARK: - Main Window Observer

    private func observeMainWindow() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidFinishLaunching),
            name: NSApplication.didFinishLaunchingNotification,
            object: nil
        )
    }

    @objc private func applicationDidFinishLaunching() {
        if let window = NSApp.windows.first(where: { !($0 is NSPanel) }) {
            setMainWindow(window)
        }
    }
}

// MARK: - NSWindowDelegate

extension WindowCoordinator: NSWindowDelegate {
    func windowDidMiniaturize(_: Notification) {
        guard floatingWidgetEnabled, floatingWidgetOnMinimize else { return }
        DispatchQueue.main.async { self.showFloatingPlayer() }
    }

    func windowDidDeminiaturize(_: Notification) {
        hideFloatingPlayer()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard floatingWidgetEnabled, floatingWidgetOnClose else { return true }
        sender.orderOut(nil)
        DispatchQueue.main.async { self.showFloatingPlayer() }
        return false
    }
}
