import XCTest
@testable import DrawWithMe

/// Executable specifications for the replicated room invariants.
final class RoomSnapshotTests: XCTestCase {
    func testFirstConnectedParticipantBecomesHost() throws {
        var room = RoomSnapshot(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

        try room.apply(.participantJoined(alex))

        XCTAssertEqual(room.hostID, alex.id)
        XCTAssertEqual(room.hostTerm, 1)
        XCTAssertEqual(room.revision, 1)
    }

    func testDisconnectedHostMigratesToOldestConnectedParticipant() throws {
        var room = try roomWithThreeParticipants()
        let previousTerm = room.hostTerm

        try room.apply(.connectionChanged(alex.id, .disconnected))

        XCTAssertEqual(room.hostID, blair.id)
        XCTAssertEqual(room.hostTerm, previousTerm + 1)
        XCTAssertEqual(room.connectedParticipants.map(\.id), [blair.id, casey.id])
    }

    func testReturningFormerHostDoesNotReclaimAuthority() throws {
        var room = try roomWithThreeParticipants()
        try room.apply(.connectionChanged(alex.id, .disconnected))
        let migratedTerm = room.hostTerm

        try room.apply(.connectionChanged(alex.id, .connected))

        XCTAssertEqual(room.hostID, blair.id)
        XCTAssertEqual(room.hostTerm, migratedTerm)
    }

    func testRemovingHostMigratesWithoutEndingPlayingRoom() throws {
        var room = try roomWithThreeParticipants()
        try room.apply(.gameStarted)

        try room.apply(.participantRemoved(alex.id))

        XCTAssertEqual(room.phase, .playing)
        XCTAssertEqual(room.hostID, blair.id)
    }

    func testStartingRequiresTwoConnectedParticipants() throws {
        var room = RoomSnapshot()
        try room.apply(.participantJoined(alex))

        XCTAssertThrowsError(try room.apply(.gameStarted)) { error in
            XCTAssertEqual(error as? RoomRuleError, .insufficientConnectedParticipants)
        }
        XCTAssertEqual(room.phase, .lobby)
        XCTAssertEqual(room.revision, 1, "Rejected events must not increment the revision.")
    }

    func testRoomRejectsEighthParticipant() throws {
        var room = RoomSnapshot()
        for ordinal in 0..<RoomConfiguration.maximumParticipantCount {
            try room.apply(.participantJoined(participant(ordinal: UInt64(ordinal))))
        }

        XCTAssertThrowsError(
            try room.apply(.participantJoined(participant(ordinal: 99)))
        ) { error in
            XCTAssertEqual(error as? RoomRuleError, .roomFull)
        }
    }

    func testEnvelopeRoundTripsThroughJSON() throws {
        var room = try roomWithThreeParticipants()
        try room.apply(.connectionChanged(alex.id, .disconnected))
        let envelope = RoomEnvelope(
            roomID: room.id,
            senderID: blair.id,
            hostTerm: room.hostTerm,
            roomRevision: room.revision,
            payload: .snapshot(room)
        )

        let data = try JSONEncoder().encode(envelope)
        let decoded = try JSONDecoder().decode(RoomEnvelope.self, from: data)

        XCTAssertEqual(decoded, envelope)
    }

    private let alex = Participant(
        id: "alex",
        displayName: "Alex",
        joinOrdinal: 1,
        connectionState: .connected
    )

    private let blair = Participant(
        id: "blair",
        displayName: "Blair",
        joinOrdinal: 2,
        connectionState: .connected
    )

    private let casey = Participant(
        id: "casey",
        displayName: "Casey",
        joinOrdinal: 3,
        connectionState: .connected
    )

    private func roomWithThreeParticipants() throws -> RoomSnapshot {
        var room = RoomSnapshot()
        try room.apply(.participantJoined(alex))
        try room.apply(.participantJoined(blair))
        try room.apply(.participantJoined(casey))
        return room
    }

    private func participant(ordinal: UInt64) -> Participant {
        Participant(
            id: "player-\(ordinal)",
            displayName: "Player \(ordinal)",
            joinOrdinal: ordinal,
            connectionState: .connected
        )
    }
}

