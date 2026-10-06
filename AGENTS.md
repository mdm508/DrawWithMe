# DrawWithMe collaboration rules

These rules apply to every human or AI contributor in this repository.

## Product boundary

- The current product is a native Apple-platform drawing party game.
- Current implementation focuses on local Free Draw on iPad. iPhone and Mac product work is deferred.
- Game Center, networking, and room code are deferred and have been removed from the current implementation.
- The v1 feature boundary lives in `ARCHITECTURE.md`. Deferred concepts belong in `docs/IDEAS.md` until the project manager promotes them.

## Architecture is part of the code

- Update `ARCHITECTURE.md` in the same change whenever a component boundary, state transition, network message, persistence rule, or platform assumption changes.
- Record durable architectural decisions in `docs/decisions/`.
- Prefer deterministic, testable domain logic over view-owned business rules.
- Do not couple game rules directly to GameKit, PencilKit, or SwiftUI.

## Literate Swift

- Use Xcode markup documentation comments (`///`) for every type and for non-obvious methods, state transitions, and invariants.
- Explain *why* a rule exists and which invariant it protects. Do not narrate syntax.
- Use headings, lists, `Important`, `Invariant`, `Note`, `Parameters`, `Returns`, and `Throws` where they improve generated Quick Help.
- Follow Apple's Xcode markup reference:
  https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/

## Engineering discipline

- Keep source files focused on one concept.
- Add tests for every state-machine transition and bug fix.
- Treat network messages and peer-provided text as untrusted input.
- Never make room survival depend on one participant remaining connected.
- Preserve accessibility labels and Dynamic Type behavior when changing UI.
- Do not add a third-party dependency without documenting the reason and alternatives in an architecture decision record.

