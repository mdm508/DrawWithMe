import GameKit

/// Converts Game Center player records into framework-independent room members.
enum GameCenterParticipantMapper {
    private static let maximumDisplayNameLength = 40

    /// Converts a GameKit player into the room's stable participant value.
    ///
    /// - Parameters:
    ///   - player: The authenticated or matched Game Center player.
    ///   - joinOrdinal: The room-assigned ordering value used for host election.
    /// - Returns: A connected participant containing no GameKit types.
    static func participant(for player: GKPlayer, joinOrdinal: UInt64) -> Participant {
        participant(
            identifier: player.gamePlayerID,
            displayName: player.displayName,
            joinOrdinal: joinOrdinal
        )
    }

    /// Pure mapping seam used by tests without requiring a live Game Center account.
    ///
    /// Display names are bounded before they enter replicated room state. Game
    /// Center identifiers remain unchanged because they are stable identity keys.
    static func participant(
        identifier: String,
        displayName: String,
        joinOrdinal: UInt64
    ) -> Participant {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeName = trimmedName.isEmpty
            ? "Player"
            : String(trimmedName.prefix(maximumDisplayNameLength))

        return Participant(
            id: identifier,
            displayName: safeName,
            joinOrdinal: joinOrdinal,
            connectionState: .connected
        )
    }
}
