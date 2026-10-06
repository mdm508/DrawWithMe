import XCTest
@testable import DrawWithMe

/// The guessing rules, written as examples.
///
/// Each row of the table below is one rule you can read without opening
/// `GuessMatcher`: exact matches win, anything within two edits is close,
/// anything further is wrong, and nothing is normalized.
final class GuessMatcherTests: XCTestCase {
    /// Checks every example in one pass. The message names the failing row.
    func testGuessExamples() {
        let examples: [(secret: String, guess: String, expected: GuessMatch)] = [
            ("apple", "apple", .correct),
            ("cat", "cat", .correct),
            ("pencil", "pencil", .correct),
            ("apple", "appl", .close),
            ("apple", "apples", .close),
            ("box", "boxes", .close),      // a plural is two insertions, so it counts as close
            ("mouse", "mouses", .close),
            ("cat", "bat", .close),
            ("cat", "at", .close),
            ("cat", "cart", .close),
            ("cat", "cow", .close),        // two substitutions: the limit of 2 applies to short words too
            ("draw", "drew", .close),
            ("house", "horse", .close),
            ("flower", "flow", .close),
            ("pencil", "pensil", .close),
            ("table", "tablet", .close),
            ("sun", "son", .close),
            ("paint", "point", .close),
            ("brush", "blush", .close),
            ("apple", "apricot", .wrong),
            ("cat", "dog", .wrong),        // three substitutions: one past the limit
            ("house", "hockey", .wrong),
            ("pencil", "elephant", .wrong),
            ("cat", "CAT", .wrong)         // no normalization: the keyboard is lowercase only
        ]

        for example in examples {
            XCTAssertEqual(
                GuessMatcher.classify(secret: example.secret, guess: example.guess),
                example.expected,
                "Expected \(example.guess) against \(example.secret) to be \(example.expected)"
            )
        }
    }
}
