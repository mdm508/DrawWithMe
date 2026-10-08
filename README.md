# DrawWithMe

DrawWithMe currently opens directly into local Free Draw on iPad, using Apple’s
movable PencilKit tool picker. No account or network connection is required.
Game Center, networking, and room code have been removed; online play is deferred.

## Development

Open `DrawWithMe.xcodeproj` in Xcode 26.5 or newer. The deployment target is
iOS/iPadOS 18 or newer. Existing Mac Catalyst support is retained for validation.

The current boundaries and drawing behavior are documented in
[ARCHITECTURE.md](ARCHITECTURE.md). Future ideas live in [docs/IDEAS.md](docs/IDEAS.md).
Source documentation uses Apple’s Xcode markup (`///`).

## Continuous integration

- Every pull request and push to `codex/m1-same-tablet` runs an iOS Debug build and Mac Catalyst tests on GitHub Actions.
- A green check means the committed project builds and available tests pass; it does not replace iPad mini playtesting.
