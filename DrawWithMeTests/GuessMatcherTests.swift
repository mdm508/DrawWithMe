import XCTest
@testable import DrawWithMe

final class GuessMatcherTests: XCTestCase {
    func testGuessExamples() {
        let examples: [(secret: String, guess: String, expected: GuessMatch)] = [
            ("apple", "apple", .correct),
            ("cat", "cat", .correct),
            ("pencil", "pencil", .correct),
            ("apple", "appl", .close),
            ("apple", "apples", .close),
            ("box", "boxes", .close),
            ("mouse", "mouses", .close),
            ("cat", "bat", .close),
            ("cat", "at", .close),
            ("cat", "cart", .close),
            ("cat", "cow", .close),
            ("draw", "drew", .close),
            ("house", "horse", .close),
            ("flower", "flow", .close),
            ("pencil", "pensil", .close),
            ("table", "tablet", .close),
            ("sun", "son", .close),
            ("paint", "point", .close),
            ("brush", "blush", .close),
            ("apple", "apricot", .wrong),
            ("cat", "dog", .wrong),
            ("house", "hockey", .wrong),
            ("pencil", "elephant", .wrong),
            ("cat", "CAT", .wrong)
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
