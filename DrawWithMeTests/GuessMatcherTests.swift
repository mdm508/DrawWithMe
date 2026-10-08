import XCTest
@testable import DrawWithMe

/// The guessing rules, written as examples.
///
/// Each row of the table below is one rule you can read without opening
/// `GuessMatcher`: exact matches win, guesses one edit away are close,
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
            ("box", "boxes", .wrong),      // an "es" plural needs two edits
            ("cat", "cats", .close),       // a one-letter "s" plural is within the limit
            ("mouse", "mouses", .close),
            ("cat", "bat", .close),
            ("cat", "at", .close),
            ("cat", "cart", .close),
            ("cat", "cow", .wrong),        // two substitutions exceed the limit, even for short words
            ("cat", "cows", .wrong),       // a different plural is not a match
            ("draw", "drew", .close),
            ("house", "horse", .close),
            ("flower", "flow", .wrong),   // deleting "er" takes two edits
            ("pencil", "pensil", .close),
            ("table", "tablet", .close),
            ("sun", "son", .close),
            ("paint", "point", .close),
            ("brush", "blush", .close),
            ("apple", "apricot", .wrong),
            ("cat", "dog", .wrong),        // three substitutions exceed the limit
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
