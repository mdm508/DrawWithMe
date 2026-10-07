import Foundation
import XCTest
@testable import DrawWithMe

/// Verifies player-name persistence without reading or changing the app's defaults.
final class PlayerNamesStoreTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "PlayerNamesStoreTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    /// New installs start with visible labels for both sides of the table.
    func testLoadUsesPlayerDefaultsWhenNamesHaveNotBeenSaved() {
        XCTAssertEqual(
            PlayerNamesStore(userDefaults: userDefaults).load(),
            PlayerNames(playerOne: "Player 1", playerTwo: "Player 2")
        )
    }

    /// A fresh store sees the trimmed values written by the previous one.
    func testSaveTrimsSpacesAndPersistsBothNames() {
        let store = PlayerNamesStore(userDefaults: userDefaults)
        store.save(PlayerNames(playerOne: "  Alex  ", playerTwo: "\nSam\t"))

        XCTAssertEqual(
            PlayerNamesStore(userDefaults: userDefaults).load(),
            PlayerNames(playerOne: "Alex", playerTwo: "Sam")
        )
    }

    /// Whitespace-only entries must not replace the usable default labels.
    func testSaveUsesDefaultsForEmptyNames() {
        let store = PlayerNamesStore(userDefaults: userDefaults)
        store.save(PlayerNames(playerOne: " \n ", playerTwo: "Sam"))

        XCTAssertEqual(
            store.load(),
            PlayerNames(playerOne: "Player 1", playerTwo: "Sam")
        )
    }

    /// Long names stop at the ticket's initial twelve-character fit budget.
    func testSaveLimitsNamesToTwelveCharacters() {
        let store = PlayerNamesStore(userDefaults: userDefaults)
        store.save(PlayerNames(playerOne: "abcdefghijklmnop", playerTwo: "Christopher Robin"))

        XCTAssertEqual(
            store.load(),
            PlayerNames(playerOne: "abcdefghijkl", playerTwo: "Christopher")
        )
    }

    /// Loading legacy or interrupted values still enforces defaults and length.
    func testLoadNormalizesValuesStoredOutsideTheStore() {
        userDefaults.set(" \n ", forKey: "playerNames.playerOne")
        userDefaults.set("123456789012345", forKey: "playerNames.playerTwo")

        XCTAssertEqual(
            PlayerNamesStore(userDefaults: userDefaults).load(),
            PlayerNames(playerOne: "Player 1", playerTwo: "123456789012")
        )
    }
}
