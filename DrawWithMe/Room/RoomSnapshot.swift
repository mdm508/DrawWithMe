import Foundation

/// The durable phases of a room's game loop.
enum RoomPhase: String, Codable, Sendable {
    case lobby
    case playing
    case results
}

/// A complete deterministic view of room state.
///
/// Every peer retains this state so the room can survive the coordinating host
/// disconnecting. Framework-specific objects such as `GKPlayer` never appear in
/// the snapshot.
struct RoomSnapshot: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    private(set) var revision: UInt64
    private(set) var hostTerm: UInt64
    private(set) var hostID: Participant.ID?
    private(set) var participants: [Participant]
    private(set) var configuration: RoomConfiguration
    private(set) var phase: RoomPhase

    /// Creates an empty room before its first participant joins.
    init(
        id: UUID = UUID(),
        configuration: RoomConfiguration = RoomConfiguration()
    ) {
        self.id = id
        revision = 0
        hostTerm = 0
        hostID = nil
        participants = []
        self.configuration = configuration
        phase = .lobby
    }

    /// Connected participants in the shared deterministic order.
    var connectedParticipants: [Participant] {
        participants
            .filter(\.isConnected)
            .sorted(by: Participant.hostElectionOrder)
    }

    /// The current host when the replicated membership state is valid.
    var host: Participant? {
        guard let hostID else { return nil }
        return participants.first { $0.id == hostID }
    }

    /// Applies one committed event to this snapshot.
    ///
    /// - Important: Equal snapshots and equal events must produce equal results
    ///   on every peer. No clock, randomness, or framework state is consulted.
    /// - Parameter event: The event accepted into the room's ordered log.
    /// - Throws: ``RoomRuleError`` when the event violates a room invariant.
    mutating func apply(_ event: RoomEvent) throws {
        switch event {
        case let .participantJoined(participant):
            try join(participant)

        case let .connectionChanged(participantID, connectionState):
            try updateConnection(for: participantID, to: connectionState)

        case let .participantRemoved(participantID):
            try removeParticipant(participantID)

        case let .configurationChanged(configuration):
            guard phase == .lobby else {
                throw RoomRuleError.configurationLocked
            }
            self.configuration = configuration

        case .gameStarted:
            guard phase == .lobby else {
                throw RoomRuleError.invalidPhase(expected: .lobby, actual: phase)
            }
            guard connectedParticipants.count >= 2 else {
                throw RoomRuleError.insufficientConnectedParticipants
            }
            phase = .playing

        case .gameFinished:
            guard phase == .playing else {
                throw RoomRuleError.invalidPhase(expected: .playing, actual: phase)
            }
            phase = .results

        case .returnedToLobby:
            guard phase == .results else {
                throw RoomRuleError.invalidPhase(expected: .results, actual: phase)
            }
            phase = .lobby
        }

        revision += 1
        try validateInvariants()
    }

    private mutating func join(_ participant: Participant) throws {
        guard participants.count < RoomConfiguration.maximumParticipantCount else {
            throw RoomRuleError.roomFull
        }
        guard !participants.contains(where: { $0.id == participant.id }) else {
            throw RoomRuleError.duplicateParticipant(participant.id)
        }
        guard !participants.contains(where: { $0.joinOrdinal == participant.joinOrdinal }) else {
            throw RoomRuleError.duplicateJoinOrdinal(participant.joinOrdinal)
        }

        participants.append(participant)
        participants.sort(by: Participant.hostElectionOrder)
        electHostIfNecessary()
    }

    private mutating func updateConnection(
        for participantID: Participant.ID,
        to connectionState: Participant.ConnectionState
    ) throws {
        guard let index = participants.firstIndex(where: { $0.id == participantID }) else {
            throw RoomRuleError.unknownParticipant(participantID)
        }

        participants[index].connectionState = connectionState
        electHostIfNecessary()
    }

    private mutating func removeParticipant(_ participantID: Participant.ID) throws {
        guard let index = participants.firstIndex(where: { $0.id == participantID }) else {
            throw RoomRuleError.unknownParticipant(participantID)
        }

        participants.remove(at: index)
        electHostIfNecessary()
    }

    /// Elects a host only when the current authority is no longer eligible.
    ///
    /// A reconnected former host therefore does not reclaim authority from a
    /// healthy successor, preventing unnecessary term churn.
    private mutating func electHostIfNecessary() {
        if let hostID,
           participants.contains(where: { $0.id == hostID && $0.isConnected }) {
            return
        }

        let successorID = connectedParticipants.first?.id
        guard successorID != hostID else { return }

        hostID = successorID
        hostTerm += 1
    }

    /// Verifies the invariants that all peers rely upon for migration.
    private func validateInvariants() throws {
        guard participants.count <= RoomConfiguration.maximumParticipantCount else {
            throw RoomRuleError.roomFull
        }

        let participantIDs = Set(participants.map(\.id))
        guard participantIDs.count == participants.count else {
            throw RoomRuleError.corruptSnapshot("Participant identifiers must be unique.")
        }

        let ordinals = Set(participants.map(\.joinOrdinal))
        guard ordinals.count == participants.count else {
            throw RoomRuleError.corruptSnapshot("Join ordinals must be unique.")
        }

        if connectedParticipants.isEmpty {
            guard hostID == nil else {
                throw RoomRuleError.corruptSnapshot("An empty connected roster cannot have a host.")
            }
        } else {
            guard let host, host.isConnected else {
                throw RoomRuleError.corruptSnapshot("The host must be connected.")
            }
        }
    }
}

private extension Participant {
    /// Total ordering used independently by every peer during host election.
    static func hostElectionOrder(_ lhs: Participant, _ rhs: Participant) -> Bool {
        if lhs.joinOrdinal == rhs.joinOrdinal {
            return lhs.id < rhs.id
        }
        return lhs.joinOrdinal < rhs.joinOrdinal
    }
}

