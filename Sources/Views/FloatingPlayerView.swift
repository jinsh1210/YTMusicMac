import AppKit
import SwiftUI

struct FloatingPlayerView: View {
    @ObservedObject var manager: MusicPlayerManager
    var onOpenMain: () -> Void = {}

    @State private var isDraggingSeek = false
    @State private var dragSeekValue: Double = 0
    @State private var isPlayButtonHovered = false

    private let artSize: CGFloat = 90

    var body: some View {
        HStack(spacing: 10) {
            albumArtSquare
                .frame(width: artSize, height: artSize)
                .padding(.leading, 10)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    trackInfo
                        .padding(.top, 13)

                    Spacer()

                    openMainButton
                        .padding(.top, 6)
                        .padding(.trailing, 12)
                }

                Spacer()

                controls
                    .padding(.horizontal, 4)

                seekBar
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: 320, height: 110)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
    }

    // MARK: - 앨범아트

    private var albumArtSquare: some View {
        Group {
            if let img = manager.albumArtImage {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                artPlaceholder
            }
        }
        .frame(width: artSize, height: artSize)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }

    private var artPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(white: 0.18))
            .overlay(
                Image(systemName: "music.note")
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 24))
            )
    }

    // MARK: - 메인창 열기 버튼

    private var openMainButton: some View {
        Button(
            action: onOpenMain,
            label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
        )
        .buttonStyle(.plain)
        .help("메인 창 열기")
    }

    // MARK: - 트랙 정보

    private var trackInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(manager.currentTrack?.title ?? "재생 중인 곡 없음")
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .foregroundStyle(manager.currentTrack != nil ? .primary : .secondary)

            Text(manager.currentTrack?.artist ?? "")
                .font(.system(size: 11))
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - 컨트롤

    private var controls: some View {
        HStack(spacing: 0) {
            Spacer()

            Button(
                action: { manager.toggleShuffle() },
                label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 13))
                        .foregroundStyle(manager.isShuffled ? Color.accentColor : Color.primary.opacity(0.6))
                }
            )
            .buttonStyle(.plain)

            Spacer()

            Button(
                action: { manager.previousTrack() },
                label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                }
            )
            .buttonStyle(.plain)

            Spacer()

            Button(
                action: { manager.togglePlay() },
                label: {
                    ZStack {
                        Circle()
                            .fill(Color.primary.opacity(isPlayButtonHovered ? 0.1 : 0))
                            .frame(width: 38, height: 38)
                        Image(systemName: manager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.primary)
                            .offset(x: manager.isPlaying ? 0 : 1)
                    }
                }
            )
            .buttonStyle(.plain)
            .onHover { isPlayButtonHovered = $0 }

            Spacer()

            Button(
                action: { manager.nextTrack() },
                label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                }
            )
            .buttonStyle(.plain)

            Spacer()

            Button(
                action: { manager.cycleRepeat() },
                label: {
                    Image(systemName: manager.repeatMode == .one ? "repeat.1" : "repeat")
                        .font(.system(size: 13))
                        .foregroundStyle(manager.repeatMode == .off ? Color.primary.opacity(0.6) : Color.accentColor)
                }
            )
            .buttonStyle(.plain)

            Spacer()
        }
    }

    // MARK: - 시크바

    private var seekBar: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.12))
                        .frame(height: 3)

                    Capsule()
                        .fill(Color.primary.opacity(0.65))
                        .frame(width: max(0, geo.size.width * progress), height: 3)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDraggingSeek = true
                            dragSeekValue = max(0, min(1, value.location.x / geo.size.width))
                        }
                        .onEnded { value in
                            let ratio = max(0, min(1, value.location.x / geo.size.width))
                            manager.seek(to: ratio * manager.duration)
                            isDraggingSeek = false
                        }
                )
            }
            .frame(height: 3)

            HStack {
                Text(formatTime(isDraggingSeek ? dragSeekValue * manager.duration : manager.currentTime))
                    .font(.system(size: 9, weight: .medium).monospacedDigit())
                    .foregroundStyle(.secondary)

                Spacer()

                Text("-\(formatTime(manager.duration - manager.currentTime))")
                    .font(.system(size: 9, weight: .medium).monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - 헬퍼

    private var progress: CGFloat {
        guard manager.duration > 0 else { return 0 }
        if isDraggingSeek { return CGFloat(dragSeekValue) }
        return CGFloat(manager.currentTime / manager.duration)
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let totalSeconds = Int(seconds)
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
