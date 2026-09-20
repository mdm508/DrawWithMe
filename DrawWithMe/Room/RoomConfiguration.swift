import Foundation

/// Host-controlled rules shared by every mode in the first release.
struct RoomConfiguration: Codable, Equatable, Sendable {
    /// The number of complete passes through the participant roster.
    enum RoundCount: Int, CaseIterable, Codable, Identifiable, Sendable {
        case one = 1
        case three = 3
        case five = 5

        var id: Int { rawValue }
    }

    /// The drawing time available to one participant.
    enum TurnDuration: Int, CaseIterable, Codable, Identifiable, Sendable {
        case thirty = 30
        case sixty = 60
        case ninety = 90
        case oneHundredTwenty = 120

        var id: Int { rawValue }
    }

    /// Maximum room population promised by the product design.
    static let maximumParticipantCount = 7

    var roundCount: RoundCount = .three
    var turnDuration: TurnDuration = .sixty
    var showsWordLengthHint = true
}

