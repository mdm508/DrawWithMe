/// Classifies a lowercase guess without exposing partial letter matches.
enum GuessMatcher {
    /// The greatest Levenshtein distance that still counts as a close guess.
    static let maximumCloseGuessEditDistance = 2

    /// Returns `.correct` only for an exact match; close guesses remain distinct.
    static func classify(secret: String, guess: String) -> GuessMatch {
        guard secret != guess else { return .correct }
        guard levenshteinDistance(secret, guess) <= maximumCloseGuessEditDistance else {
            return .wrong
        }
        return .close
    }

    /// Computes insertion, deletion, and substitution distance over lowercase characters.
    private static func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
        let source = Array(lhs)
        let target = Array(rhs)

        guard abs(source.count - target.count) <= maximumCloseGuessEditDistance else {
            return maximumCloseGuessEditDistance + 1
        }

        var previousRow = Array(0...target.count)

        for (sourceIndex, sourceCharacter) in source.enumerated() {
            var currentRow = Array(repeating: 0, count: target.count + 1)
            currentRow[0] = sourceIndex + 1

            for (targetIndex, targetCharacter) in target.enumerated() {
                let substitutionCost = sourceCharacter == targetCharacter ? 0 : 1
                currentRow[targetIndex + 1] = min(
                    previousRow[targetIndex + 1] + 1,
                    currentRow[targetIndex] + 1,
                    previousRow[targetIndex] + substitutionCost
                )
            }

            previousRow = currentRow
        }

        return previousRow[target.count]
    }
}

/// The public outcome for evaluating a single guess.
enum GuessMatch: Equatable {
    case correct
    case close
    case wrong
}
