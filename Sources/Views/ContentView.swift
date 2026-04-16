import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject var manager: MusicPlayerManager

    var body: some View {
        ZStack {
            MusicWebView(webView: manager.webView)
                .blur(radius: manager.isLoggingIn ? 20 : 0)

            if manager.isLoading {
                ZStack {
                    Color(NSColor.windowBackgroundColor)
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                }
                .transition(.opacity)
            }

            if manager.isLoggingIn {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Google Login Required")
                        .font(.headline)
                    
                    Text("Please complete sign-in to access YouTube Music.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ProgressView()
                        .progressViewStyle(.linear)
                        .frame(width: 200)

                    Button("Cancel") {
                        manager.isLoggingIn = false
                        manager.webView.load(URLRequest(url: URL(string: "https://music.youtube.com")!))
                    }
                    .buttonStyle(.bordered)
                }
                .padding(40)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.default, value: manager.isLoading)
        .animation(.spring(), value: manager.isLoggingIn)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
