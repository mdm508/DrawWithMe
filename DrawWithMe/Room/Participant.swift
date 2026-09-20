import Foundation

/// A person who belongs to one room roster.
///
/// Participant identity is intentionally independent of GameKit. The GameKit
/// adapter supplies the stable identifier, while the room domain only reasons
/// about ordering and connection state.
struct Participant: Codable, Hashable, Identifiable, Sendable {
    /// Whether a participant can currently exchange room messages.
    enum ConnectionState: String, Codable, Sendable {
        case connected
        case disconnected
    }

    /// The stable identity supplied by the active identity adapter.
    let id: String

    /// The player-facing name captured when the participant joins.
    var displayName: String

    /// A monotonic ordering value assigned once by the room.
    ///
    /// - Important: This value is never reused within a room. It is the primary
    ///   key for deterministic host election.
    let joinOrdinal: UInt64

    /// The participant's last committed connection state.
    var connectionState: ConnectionState

    /// Whether the participant is eligible to coordinate the room.
    var isConnected: Bool {
        connectionState == .connected
    }
}

