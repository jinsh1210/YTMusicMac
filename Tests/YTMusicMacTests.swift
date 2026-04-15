import WebKit
import XCTest
@testable import YTMusicMac

final class YTMusicMacTests: XCTestCase {
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
}
