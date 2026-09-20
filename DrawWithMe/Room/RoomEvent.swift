import Foundation

/// A committed fact that changes the replicated room snapshot.
///
/// Commands and user intent will be validated by the active host before becoming
/// events. Peers only reduce committed events.
enum RoomEvent: Codable, Equatable, Sendable {
    case participantJoined(Participant)
    case connectionChanged(Participant.ID, Participant.ConnectionState)
    case participantRemoved(Participant.ID)
    case configurationChanged(RoomConfiguration)
    case gameStarted
    case gameFinished
    case returnedToLobby
}

/// A domain-level rejection that leaves the room snapshot unchanged.
enum RoomRuleError: Error, Equatable, LocalizedError {
    case roomFull
    case duplicateParticipant(Participant.ID)
    case duplicateJoinOrdinal(UInt64)
    case unknownParticipant(Participant.ID)
    case insufficientConnectedParticipants
    case configurationLocked
    case invalidPhase(expected: RoomPhase, actual: RoomPhase)
    case corruptSnapshot(String)

    var errorDescription: String? {
        switch self {
        case .roomFull:
            "The room already has the maximum number of participants."
        case let .duplicateParticipant(id):
            "Participant \(id) is already in the room."
        case let .duplicateJoinOrdinal(ordinal):
            "Join ordinal \(ordinal) is already in use."
        case let .unknownParticipant(id):
            "Participant \(id) is not in the room."
        case .insufficientConnectedParticipants:
            "At least two connected participants are required."
        case .configurationLocked:
            "Room settings cannot change after the game starts."
        case let .invalidPhase(expected, actual):
            "Expected room phase \(expected.rawValue), found \(actual.rawValue)."
        case let .corruptSnapshot(reason):
            "The room snapshot is invalid: \(reason)"
        }
    }
}

