import XCTest
@testable import MusicPop

final class MusicPopTests: XCTestCase {
    func testInitialState() {
        let manager = MusicPlayerManager()
        XCTAssertTrue(manager.isLoading)
        XCTAssertNil(manager.currentTrack)
        XCTAssertFalse(manager.isPlaying)
    }
}
