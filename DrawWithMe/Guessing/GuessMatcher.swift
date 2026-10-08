/// Decides whether a typed guess is right, nearly right, or wrong.
///
/// The guesser sees only three outcomes, never *which* letters matched. That is
/// the rule this type protects: a close guess must not leak the secret word one
/// letter at a time (see `GuessMatch/close`).
///
/// `GuessMatcher` is pure domain logic. It has no state and imports no UI or
/// drawing framework, so every rule below can be tested with plain strings.
///
/// - Precondition: Both `secret` and `guess` are already lowercase. The on screen
///   keyboard only types lowercase letters, and the word bank (dwm12, dwm13)
///   must store lowercase secrets, so this type does no normalization. A guess
///   of `"CAT"` against `"cat"` is `.wrong`, and the tests say so.
enum GuessMatcher {
    /// The greatest Levenshtein distance that still counts as a close guess.
    ///
    /// Matt's rule is a limit of 1 for every word length.
    /// - Attention: A one-edit limit still makes `"at"` close to `"cat"`, but
    ///   `"cow"` is no longer close to `"cat"`. The playtest (dwm28) can show
    ///   whether this is the right balance for short words.
    /// - Note: A plural with one added letter, such as `"cats"` against
    ///   `"cat"`, is close under this rule. An `"es"` plural such as `"boxes"`
    ///   against `"box"` needs two edits and is wrong; no separate plural rule
    ///   is applied.
    static let maximumCloseGuessEditDistance = 1

    /// Classifies one guess against the secret word.
    ///
    /// Only an exact match is `.correct`. A near miss is `.close` so the guesser
    /// is nudged without being told the answer.
    ///
    /// - Parameters:
    ///   - secret: The word being drawn, lowercase.
    ///   - guess: What the guesser typed, lowercase.
    /// - Returns: `.correct` for an exact match, `.close` when the words are
    ///   within the `maximumCloseGuessEditDistance` edit limit, otherwise `.wrong`.
    ///
    /// - Example: `"house"` against `"horse"` and `"cat"` against `"cats"`
    ///   are `.close`; `"box"` against `"boxes"` and `"cat"` against `"dog"`
    ///   are `.wrong`.
    static func classify(secret: String, guess: String) -> GuessMatch {
        guard secret != guess else { return .correct }
        guard levenshteinDistance(secret, guess) <= maximumCloseGuessEditDistance else {
            return .wrong
        }
        return .close
    }

    /// Counts the fewest single-character insertions, deletions, and
    /// substitutions that turn `lhs` into `rhs`.
    ///
    /// - Note: This is not always the true distance. When the lengths differ by
    ///   more than `maximumCloseGuessEditDistance` the answer is already
    ///   `.wrong`, so the method returns the limit plus one straight away instead
    ///   of filling the table. Callers must only compare the result against the
    ///   limit.
    /// - Complexity: O(*n* × *m*) time and O(*m*) space for words of length *n*
    ///   and *m*. Only two rows of the table are alive at once.
    private static func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
        let source = Array(lhs)
        let target = Array(rhs)

        guard abs(source.count - target.count) <= maximumCloseGuessEditDistance else {
            return maximumCloseGuessEditDistance + 1
        }

        // Row 0 is the cost of building each prefix of `target` from nothing.
        var previousRow = Array(0...target.count)

        for (sourceIndex, sourceCharacter) in source.enumerated() {
            var currentRow = Array(repeating: 0, count: target.count + 1)
            // Turning this prefix of `source` into nothing costs one deletion per letter.
            currentRow[0] = sourceIndex + 1

            for (targetIndex, targetCharacter) in target.enumerated() {
                let substitutionCost = sourceCharacter == targetCharacter ? 0 : 1
                currentRow[targetIndex + 1] = min(
                    previousRow[targetIndex + 1] + 1,  // delete a letter from `source`
                    currentRow[targetIndex] + 1,       // insert a letter into `source`
                    previousRow[targetIndex] + substitutionCost  // keep or substitute
                )
            }

            previousRow = currentRow
        }

        return previousRow[target.count]
    }
}

/// The outcome of one guess, and everything the guesser is allowed to learn.
///
/// - Important: There is deliberately one `.close` case and no "letters in the
///   right place" detail. Revealing partial matches would let a guesser solve
///   the word by trial and error instead of by reading the drawing.
enum GuessMatch: Equatable {
    /// The guess is exactly the secret word. The turn is won.
    case correct
    /// The guess is within the edit limit of the secret word but not equal to it.
    case close
    /// The guess is too far from the secret word to be worth a hint.
    case wrong
}
