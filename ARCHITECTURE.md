# DrawWithMe architecture

## Current scope

The app opens directly into local Free Draw on iPad. Game Center, networking,
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

The existing project still supports iPhone and Mac Catalyst and contains legacy
Game Center capability/signing configuration. These settings are preserved while
Matt's local project and shared scheme edits are present. They do not initiate
Game Center at runtime. iPhone and Mac product work remains deferred.
