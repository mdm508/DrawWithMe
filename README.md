# DrawWithMe

DrawWithMe is the working title for a native drawing party game designed around Apple Pencil on iPad, finger drawing on iPhone, and pointer input on Mac.

The first release concentrates on three things:

1. A drawing surface that feels immediate and obvious.
2. Private rooms that are easy to create and join through Game Center.
3. A room model that survives the host disconnecting.

The product scope and technical invariants are maintained in [ARCHITECTURE.md](ARCHITECTURE.md). Ideas that are intentionally outside v1 live in [docs/IDEAS.md](docs/IDEAS.md).

## Development

Requirements:

- Xcode 26.5 or newer
- iOS/iPadOS 18 or newer
- macOS through Mac Catalyst 18 or newer

Open `DrawWithMe.xcodeproj` in Xcode. The app launches directly into Free Draw, backed by Apple's movable PencilKit
tool picker. Game Center sign-in, invitations, and matchmaking are deferred; the
existing adapter is retained for future online play.

## Documentation standard

Source documentation uses [Apple's Xcode markup syntax](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/). Architecture changes must update the architecture document in the same commit.
