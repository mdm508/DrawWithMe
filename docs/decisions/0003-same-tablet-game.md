# ADR 0003: Same tablet game, reusable settings, and a word bank package

- Status: Accepted
- Date: 2026-10-08
- Ticket: dwm10 (Trello: https://trello.com/c/UfrKFzEc)

## Context

Milestone M1 is a two player game on one iPad mini. The players sit across a
table with the iPad in portrait. The drawer draws on their half, and the guesser
types guesses on the other half, which is rotated 180 degrees to face them.

Three things are decided before any game code is written, because every later
M1 ticket builds on them:

- V1 is iPad only. iPhone and Mac come later as separate apps, each designed for
  its device, sharing code through packages rather than one adaptive layout.
- Many future modes will share settings such as draw time, so a setting must be
  defined once and reused by every mode.
- The word bank must be reusable by other apps later.

Online play was removed from the current implementation (ADR 0001 and ADR 0002
are historical). A networked room may come back in a later milestone and should
be able to reuse the game rules instead of rewriting them.

## Decision

### 1. The game session is a pure state machine

The rules of one game live in a deterministic state machine in the domain layer.

- It imports Foundation only. It never imports SwiftUI, PencilKit, SwiftData, or
  GameKit, so it runs in unit tests without any UI or device.
- It has no timers. Time arrives from outside as events (for example "the word
  pick timed out" or "time expired"), so tests run instantly and a later network
  host can drive the same machine from its own clock.
- The same events in the same order always produce the same state. A later
  networked room can replay committed events on every device.
- Phases for M1: setup, word pick, drawing, turn end, results. There is no
  5 to 1 countdown: drawing starts as soon as the drawer picks a word.
- A correct guess ends the turn at once. Scoring is a separate pure function
  (dwm17) that the state machine calls at turn end.

The earlier networked room reducer was deleted with the online code, so the
state machine is new code and does not wrap it.

### 2. Settings are defined once and shared by every mode

- Shared settings: draw time (45, 60, or 90 seconds), rounds (1, 3, or 5), and
  hints. Each is defined in one place, with its allowed values and default.
- A mode owns a value of the shared settings plus only the settings unique to
  it. A new mode never redefines draw time or rounds.
- Settings are plain value types, so the state machine reads them without
  knowing how they were chosen or stored.

### 3. The word bank is a separate local Swift package

- A local Swift package named `WordBank`, with no dependency on app code.
- It stores words with SwiftData. Each word has a stable ID, its text, a
  category (abstract or concrete), a language, and an enabled flag.
- Every word has one preferred spelling, stored in lowercase (for example
  "ice cream", not "icecream"). The game is deliberately strict about spelling,
  and the guess matcher assumes lowercase input and does no normalization.
- Only plain value types leave the package. No SwiftData model object escapes.
- The game defines a small protocol for asking for candidate words, the package
  implements it, and the app injects it. Tests and SwiftUI previews use an
  in memory implementation.
- The starter list is a reviewable JSON file in the repo. On first launch the
  package imports it into its store. A prebuilt store in the bundle was the
  alternative; importing from JSON keeps the list diffable in pull requests and
  needs no build step.
- Game events carry the chosen word's text, not its ID, so a game in progress
  never depends on the word bank still containing that word.

## Consequences

- Every rule in M1 is testable without a device. The device only has to check
  layout, drawing feel, and timing.
- Views own no game rules. They render the state machine's state and send it
  events.
- Adding the package to the app changes `project.pbxproj`, which also holds
  Matt's local signing settings. That edit is made with Matt's agreement, in the
  word bank ticket (dwm12), not here.
- iPhone and Mac apps can later reuse the state machine, the settings, and the
  word bank, and supply their own layouts.
