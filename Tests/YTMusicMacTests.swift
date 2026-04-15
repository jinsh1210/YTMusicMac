import XCTest
@testable import YTMusicMac

final class YTMusicMacTests: XCTestCase {
    func testInitialState() {
        let manager = MusicPlayerManager()
        XCTAssertTrue(manager.isLoading)
        XCTAssertNil(manager.currentTrack)
        XCTAssertFalse(manager.isPlaying)
    }
}
