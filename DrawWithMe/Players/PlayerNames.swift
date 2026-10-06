import Foundation

/// The two names shown during a game on one tablet.
struct PlayerNames: Equatable {
    /// The name for the player assigned to the first side of the table.
    let playerOne: String

    /// The name for the player assigned to the second side of the table.
    let playerTwo: String
}

/// Persists both player names without coupling the game flow to global defaults.
struct PlayerNamesStore {
    /// The injected domain keeps name persistence isolated from process-wide state.
    private let userDefaults: UserDefaults

    /// Creates a store with the chosen defaults domain, so tests can be isolated.
    ///
    /// - Parameter userDefaults: The persistence domain that owns both names.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Loads names and applies the same fallback rules used when saving them.
    ///
    /// Missing or invalid stored values still produce usable names, protecting
    /// the setup screen from empty labels after an interrupted or older save.
    func load() -> PlayerNames {
        PlayerNames(
            playerOne: normalized(
                userDefaults.string(forKey: Keys.playerOne) ?? Self.defaultPlayerOneName,
                fallback: Self.defaultPlayerOneName
            ),
            playerTwo: normalized(
                userDefaults.string(forKey: Keys.playerTwo) ?? Self.defaultPlayerTwoName,
                fallback: Self.defaultPlayerTwoName
            )
        )
    }

    /// Saves both names after trimming, applying empty-name defaults, and limiting length.
    ///
    /// - Parameter names: The proposed names for both players.
    func save(_ names: PlayerNames) {
        userDefaults.set(
            normalized(names.playerOne, fallback: Self.defaultPlayerOneName),
            forKey: Keys.playerOne
        )
        userDefaults.set(
            normalized(names.playerTwo, fallback: Self.defaultPlayerTwoName),
            forKey: Keys.playerTwo
        )
    }
}

private extension PlayerNamesStore {
    /// Player labels need a visible fallback and a fixed initial fit budget.
    static let defaultPlayerOneName = "Player 1"
    static let defaultPlayerTwoName = "Player 2"

    /// Twelve characters is the starting limit from dwm18; later layout work can tune it.
    static let maximumNameLength = 12

    /// Stable keys keep the two persisted values independent across app launches.
    enum Keys {
        /// The persisted name for the first side of the table.
        static let playerOne = "playerNames.playerOne"

        /// The persisted name for the second side of the table.
        static let playerTwo = "playerNames.playerTwo"
    }

    /// Returns a trimmed, nonempty name within the screen's initial length budget.
    func normalized(_ name: String, fallback: String) -> String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return fallback }
        return String(trimmedName.prefix(Self.maximumNameLength))
    }
}
