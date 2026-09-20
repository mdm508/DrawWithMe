import XCTest
@testable import DrawWithMe

/// Adapter-boundary tests that do not require a signed-in Game Center account.
final class GameCenterParticipantMapperTests: XCTestCase {
    func testMappingPreservesIdentityAndRoomOrdering() {
        let participant = GameCenterParticipantMapper.participant(
            identifier: "game-player-42",
            displayName: "  Alex  ",
            joinOrdinal: 7
        )

        XCTAssertEqual(participant.id, "game-player-42")
        XCTAssertEqual(participant.displayName, "Alex")
        XCTAssertEqual(participant.joinOrdinal, 7)
        XCTAssertEqual(participant.connectionState, .connected)
    }

    func testMappingBoundsUntrustedDisplayNames() {
        let participant = GameCenterParticipantMapper.participant(
            identifier: "game-player-42",
            displayName: String(repeating: "a", count: 100),
            joinOrdinal: 7
        )

        XCTAssertEqual(participant.displayName.count, 40)
    }

    func testMappingReplacesAnEmptyDisplayName() {
        let participant = GameCenterParticipantMapper.participant(
            identifier: "game-player-42",
            displayName: " \n ",
            joinOrdinal: 7
        )

        XCTAssertEqual(participant.displayName, "Player")
    }
}
