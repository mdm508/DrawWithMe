# DrawWithMe architecture

## Current scope

V1 is iPad only. The app opens directly into local Free Draw on iPad. Game Center, networking,
room membership, host migration, and their tests have been removed from the
current implementation. Online play is deferred; its earlier design is retained
in the historical ADRs and Git history.

## Component map

```text
SwiftUI app shell
├── Drawing feature
│   ├── DrawingWorkspaceView
│   ├── DrawingCanvasView (PencilKit adapter)
│   └── DrawingSessionHUD
├── Player names
│   └── PlayerNamesStore (UserDefaults adapter)
└── Guessing rules
    ├── GuessMatcher (pure domain logic)
    └── GuessMatch
```

`AppRootView` presents the workspace inside a navigation stack. No account,
authentication, or network connection is required.

Guessing uses the framework-independent `GuessMatcher`. It compares lowercase
words: exact matches are correct, guesses within one insertion, deletion, or
substitution are close, and all others are wrong. A one-letter plural such as
`cats` for `cat` is close; plurals requiring two edits, such as `boxes` for
`box`, are wrong. A close result never reveals matching letters.

## Planned for M1: same tablet game

Milestone M1 adds a two player game on one iPad mini in portrait. The players
sit across a table; the drawer uses one half of the screen and the guesser uses
the other half, rotated 180 degrees to face them. The decisions behind this are
in [ADR 0003](docs/decisions/0003-same-tablet-game.md). None of the components
below exist yet; tickets dwm12 to dwm26 build them.

```text
SwiftUI app shell
├── Same tablet table (two halves, one rotated)
│   ├── Drawer half: PencilKit canvas, word pick, guesses fading in beside the canvas
│   └── Guesser half: mirrored drawing, hint dashes, guess keyboard, guess log
├── Game rules (pure, Foundation only)
│   ├── Game state machine: setup, word pick, drawing, turn end, results
│   ├── Shared game settings: draw time 45/60/90 s, rounds 1/3/5, hints
│   ├── Scoring
│   └── GuessMatcher (exists today)
└── WordBank (local Swift package, SwiftData inside, value types outside)
```

- The state machine has no timers; time arrives as events from the view layer.
- The drawer has 10 seconds to pick one of three words. Drawing starts as soon
  as a word is picked. A correct guess ends the turn at once.
- Words have one preferred lowercase spelling. Game events carry the word's
  text, not a word bank ID.

## Drawing

`DrawingCanvasView` owns the PencilKit canvas through its coordinator. PencilKit
handles input, rendering, and the movable system tool picker. Picker preferences
use the local autosave name `DrawWithMe.DrawingTools`.

The workspace holds the drawing in memory. Clear Drawing requires confirmation;
cancelling preserves the drawing. Canvas contents are not saved across launches.
Compact overlays provide local drawing context and the clear action.

## Validation

Build the generic iOS Debug target and compile/run the Mac Catalyst test target.
The removed online features have no remaining unit tests. Drawing feel and tool
picker behavior require physical iPad mini checks: fast strokes, palm resting,
tool/color switching, and clear confirmation.

## Project configuration

V1 ships on iPad only. iPhone and Mac will be separate apps later, sharing the
game rules and the word bank through packages. The existing project still
supports iPhone and Mac Catalyst and contains legacy
Game Center capability/signing configuration. These settings are preserved while
Matt's local project and shared scheme edits are present. They do not initiate
Game Center at runtime. Mac Catalyst stays because CI runs the tests there.
