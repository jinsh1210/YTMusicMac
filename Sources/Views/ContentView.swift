import AppKit
import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject var manager: MusicPlayerManager
    @EnvironmentObject var windowCoordinator: WindowCoordinator

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
        .background(MainWindowAccessor(coordinator: windowCoordinator))
    }
}

/// NSWindow 참조를 WindowCoordinator에 전달
private struct MainWindowAccessor: NSViewRepresentable {
    let coordinator: WindowCoordinator

    func makeNSView(context _: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                coordinator.setMainWindow(window)
            }
        }
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}
}
