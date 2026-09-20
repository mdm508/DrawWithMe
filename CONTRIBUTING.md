# Contributing

The project manager owns product priority. Contributors own implementation quality and must surface architectural tradeoffs early.

## Working agreement

1. Select or create a GitHub issue before implementation.
2. Keep one architectural purpose per pull request.
3. Update `ARCHITECTURE.md` with boundary or invariant changes.
4. Move non-v1 ideas to `docs/IDEAS.md`; do not quietly expand scope.
5. Add or update tests before considering a transition complete.

## Literate programming

Documentation comments are part of the design. Use Xcode markup so important reasoning appears in Quick Help and generated documentation.

```swift
/// Applies one committed room event.
///
/// The reducer is deterministic: equal snapshots and equal events must produce
/// equal results on every peer.
///
/// - Important: Only a committed event may increment `revision`.
/// - Parameter event: The ordered event accepted for this room.
/// - Throws: ``RoomRuleError`` when the event violates an invariant.
mutating func apply(_ event: RoomEvent) throws
```

Use comments to document invariants, failure behavior, ownership, concurrency, and surprising framework constraints. Avoid comments that merely repeat a symbol's name.

Reference: https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/

