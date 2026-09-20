import Foundation

/// A versioned boundary for all room network messages.
///
/// The envelope carries enough authority metadata to reject stale-host traffic
/// after migration and enough identity to de-duplicate retransmission.
struct RoomEnvelope: Codable, Equatable, Identifiable, Sendable {
    /// The first protocol implemented by the app.
    static let currentProtocolVersion: UInt16 = 1

    let protocolVersion: UInt16
    let id: UUID
    let roomID: UUID
    let senderID: Participant.ID
    let hostTerm: UInt64
    let roomRevision: UInt64
    let payload: Payload

    init(
        id: UUID = UUID(),
        roomID: UUID,
        senderID: Participant.ID,
        hostTerm: UInt64,
        roomRevision: UInt64,
        payload: Payload
    ) {
        protocolVersion = Self.currentProtocolVersion
        self.id = id
        self.roomID = roomID
        self.senderID = senderID
        self.hostTerm = hostTerm
        self.roomRevision = roomRevision
        self.payload = payload
    }

    /// Messages supported by protocol version one.
    enum Payload: Codable, Equatable, Sendable {
        case committedEvent(RoomEvent)
        case snapshot(RoomSnapshot)
        case heartbeat
    }
}

/// The delivery guarantee requested from a room transport.
enum RoomDelivery: Sendable {
    case latencyPreferred
    case reliableOrdered
}

/// Framework-independent transport used by the room session.
///
/// GameKit will conform through an adapter. Tests may use an in-memory transport
/// without importing GameKit.
protocol RoomTransport: Sendable {
    /// Sends one encoded room message to all connected peers.
    ///
    /// - Parameters:
    ///   - envelope: The validated protocol message to transmit.
    ///   - delivery: The delivery guarantee appropriate for the payload.
    func send(_ envelope: RoomEnvelope, delivery: RoomDelivery) async throws

    /// Produces validated, decoded messages as they arrive.
    func incomingEnvelopes() async -> AsyncStream<RoomEnvelope>
}

