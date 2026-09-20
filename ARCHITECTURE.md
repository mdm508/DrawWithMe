# DrawWithMe architecture

Last updated: 2026-09-19

## Product intent

DrawWithMe is a native Apple-platform party game. iPad and Apple Pencil lead the interaction design, while the same core canvas adapts to finger input on iPhone and pointer input on Mac Catalyst. The first release validates whether groups repeatedly enjoy the classic draw-and-guess loop.

## V1 boundary

V1 includes:

- Game Center identity, invitations, and private rooms.
- Two to seven participants, subject to the runtime GameKit match limit.
- One, three, or five rounds.
- Thirty, sixty, ninety, or one-hundred-twenty-second turns.
- Optional word-length hints.
- A curated English word bank with three difficulty bands.
- Pen, eraser, clear canvas, a compact color palette, and thin/medium/thick widths.
- Text guesses, deterministic scoring, a podium, rematch, report, block, and room kick.
- Recovery from any participant disconnect, including the current host.

Everything else belongs in `docs/IDEAS.md` until promoted by the project manager.

## Architectural principles

1. **The room is replicated, not owned by a device.** The host coordinates commands but is never the sole holder of authoritative game state.
2. **Rules are deterministic and transport-independent.** Given the same ordered event stream, every peer computes the same room snapshot.
3. **Drawing traffic and game events have different reliability needs.** Live stroke samples favor latency; completed strokes, guesses, turns, scores, and membership changes require ordered delivery.
4. **Platform frameworks terminate at adapters.** SwiftUI, PencilKit, GameKit, and CloudKit do not leak into the domain model.
5. **Private-by-default.** Drawings and chat are ephemeral unless the user explicitly saves them.
6. **Documentation changes with design.** A behavior is incomplete until its invariant and boundary are documented.

## Component map

```text
SwiftUI app shell
├── Drawing feature
│   ├── Adaptive drawing workspace
│   ├── PencilKit canvas adapter
│   └── Local tool preferences
├── Room feature
│   ├── RoomSession actor
│   ├── Deterministic RoomReducer
│   └── Classic-mode state machine
├── Networking
│   ├── RoomTransport protocol
│   ├── GameKit transport adapter (next milestone)
│   └── Codable protocol envelopes
└── Services
    ├── Game Center identity (next milestone)
    ├── Curated word repository
    └── Moderation/reporting (before public testing)
```

Dependency direction is always inward: adapters may depend on domain types; domain types never import UI or networking frameworks.

The target deliberately does not use project-wide Main Actor isolation. SwiftUI
views remain UI-isolated through their framework conformances, while room and
protocol value types remain nonisolated and can be reduced or encoded away from
the main thread.

## Room state machine

```text
Lobby ──start──> Playing ──all turns complete──> Results
  ▲                 │                              │
  └────return───────┴──────────rematch─────────────┘
```

The initial reducer implements lobby membership, configuration, start, results, return, and disconnect behavior. Classic turn sequencing will be layered onto the same reducer rather than kept in views.

### Membership invariants

- `joinOrdinal` is assigned once and never reused within a room.
- Participant ordering is `joinOrdinal`, then stable participant identifier.
- There is at most one host.
- If connected participants exist, the host must be connected.
- A returning former host does not automatically reclaim host authority.
- Removing or disconnecting the host increments `hostTerm` and elects the connected participant with the lowest ordering key.
- Every accepted event increments the room revision exactly once.

## Host migration

GameKit real-time matches are peer-to-peer. Each peer retains the last committed room snapshot and applies reliable room events in order. When GameKit reports that the host disconnected, every peer deterministically elects the same successor from the replicated membership list.

The host term prevents messages from a stale host being accepted after migration. Commands in flight during a migration may be rejected and retried against the new term; committed events are never rolled back.

See `docs/decisions/0002-deterministic-host-migration.md`.

## Networking protocol

`RoomEnvelope` is the versioned wire boundary. Every envelope carries:

- Protocol version
- Room identifier
- Sender identifier
- Host term
- Room revision
- Message identifier
- Payload

Delivery classes:

| Payload | Delivery | Reason |
|---|---|---|
| Live stroke samples | Unreliable | Newer samples supersede delayed samples |
| Completed stroke | Reliable | Peers must converge on the final drawing |
| Guess/chat | Reliable | Ordering and attribution matter |
| Room/game event | Reliable | All reducers must receive the same event order |
| Snapshot/recovery | Reliable | Repairs a peer after packet loss or reconnection |

The initial implementation uses JSON `Codable` messages for inspectability. A compact binary encoding is permitted later only after profiling demonstrates a need.

## Drawing architecture

`DrawingCanvasView` is the only PencilKit bridge. The SwiftUI feature owns the selected tool and local preferences; PencilKit owns touch/Pencil recognition and rendering.

The toolbar adapts by available width:

- Regular width: tools remain adjacent to the canvas.
- Compact width: tools form a bottom strip that preserves the maximum drawing area.
- Apple Pencil, finger, pointer, hardware keyboard, and accessibility input remain supported.

Network synchronization will transmit normalized vector samples, not screenshots or full-canvas images. A completed stroke is the durable unit. Clear-canvas is a versioned operation so an old stroke packet cannot resurrect erased content.

## Persistence

- `AppStorage`: local tool/color preferences.
- App bundle / signed remote update: curated word bank.
- CloudKit: durable public metadata and moderation records only when introduced.
- Game Center: v1 player identity, friends, invitations, and matchmaking.
- Live room state: replicated in memory; no single device is its sole owner.

Email/password authentication is intentionally excluded. CloudKit public-database writes require an iCloud-authenticated user and are not a substitute for arbitrary account authentication.

## Safety and moderation

Before public rooms are enabled, the product must include objectionable-content handling, reporting, blocking, published support contact information, and a review process. Room kicks are immediate room-level protection; they are not sufficient evidence for an account ban by themselves.

## Testing strategy

- Unit tests: reducer transitions, host election, stale-term rejection, scoring, word selection, and turn sequencing.
- Protocol tests: encode/decode compatibility and malformed/untrusted message rejection.
- Adapter tests: mocked transports and GameKit integration seams.
- UI tests: create room, join, draw, guess, host disconnect, finish, and rematch.
- Device matrix: iPad with Pencil, iPhone with finger, and Mac Catalyst with pointer/keyboard.

## Current implementation status

- [x] Repository collaboration and literate-documentation rules
- [x] V1 architecture and idea boundary
- [x] Adaptive local PencilKit/finger drawing surface
- [x] Pure room reducer with deterministic host migration
- [ ] Game Center authentication and invitation adapter
- [ ] Real-time GameKit transport
- [ ] Networked stroke replication
- [ ] Classic game loop and curated word bank
- [ ] Guessing, scoring, results, and rematch
- [ ] Moderation required for external testing
