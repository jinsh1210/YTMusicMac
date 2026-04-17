import WebKit
import XCTest
@testable import YTMusicMac

final class YTMusicMacTests: XCTestCase {
    @MainActor
    func testInitialState() {
        let manager = MusicPlayerManager()
        XCTAssertTrue(manager.isLoading)
        XCTAssertNil(manager.currentTrack)
        XCTAssertFalse(manager.isPlaying)
    }

    @MainActor
    func testPlayerManagerConfiguration() {
        let manager = MusicPlayerManager()
        XCTAssertNotNil(manager.webView)
        XCTAssertEqual(manager.webView.customUserAgent?.contains("Safari"), true)
        XCTAssertTrue(manager.webView.configuration.allowsAirPlayForMediaPlayback)
    }

    /// release 빌드에서 모바일 스크롤바 방지를 위한 데스크탑 콘텐츠 모드 강제 설정 검증
    @MainActor
    func testDesktopContentModeIsEnforced() {
        let manager = MusicPlayerManager()
        XCTAssertEqual(
            manager.webView.configuration.defaultWebpagePreferences.preferredContentMode,
            .desktop,
            "WKWebView must always use desktop content mode to prevent mobile scrollbar in release builds"
        )
    }

    /// 데스크탑 User Agent 검증 (모바일 UA 방지)
    @MainActor
    func testUserAgentIsDesktopSafari() {
        let manager = MusicPlayerManager()
        let ua = manager.webView.customUserAgent ?? ""
        XCTAssertTrue(ua.contains("Macintosh"), "UA must identify as Mac desktop")
        XCTAssertFalse(ua.contains("Mobile"), "UA must not contain Mobile identifier")
        XCTAssertFalse(ua.contains("iPhone") || ua.contains("iPad"), "UA must not identify as iOS device")
    }

    /// HTTPS 업그레이드 보안 설정 검증
    @MainActor
    func testHTTPSUpgradeIsEnabled() {
        let manager = MusicPlayerManager()
        XCTAssertTrue(manager.webView.configuration.upgradeKnownHostsToHTTPS)
    }
}
