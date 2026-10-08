# DrawWithMe collaboration rules

These rules apply to every human or AI contributor in this repository.

## Product boundary

- The current product is a native Apple-platform drawing party game.
- Current implementation focuses on local Free Draw on iPad. iPhone and Mac product work is deferred.
- Game Center, networking, and room code are deferred and have been removed from the current implementation.
- The v1 feature boundary lives in `ARCHITECTURE.md`. Deferred concepts belong in `docs/IDEAS.md` until the project manager promotes them.

## Workflow

Tickets and status live on the Trello board "Draw With Me": https://trello.com/b/9taMj4X8/draw-with-me
Before starting, read two cards on it: "READ FIRST: how this board works" and "Workflow: tickets, PRs, reviews". The process is defined there, not here, so the two cannot drift apart. The rules that matter most:

- Work only from the Ready list, top eligible card first, one ticket at a time.
- No card, no PR. If Matt asks for something directly, make the card first.
- Branch from the base branch named on the card "Repo, branches, and PR stack". One ticket, one branch, one PR, opened ready for review and not as a draft. No stacked PRs. Start the PR description with "Trello: " and the card's short link.
- Handoffs and reviews are comments on the pull request, not on the Trello card. Start each one with who sent it and its type, for example "Z: HANDOFF ...". Questions for Matt go on the card.
- Never merge or close a PR. Claude merges a ticket PR into the base branch after an Approved review and a passing "Build and test" check. Matt lands the base branch on main.
- After a review that requests changes, fix them, push, and post a new HANDOFF. Do not push after a HANDOFF while you wait for the review.
- Documentation is Claude's job, not yours. Write clear names and working, tested code. You do not need to add `///` comments or update `ARCHITECTURE.md` and `docs/decisions/`; Claude does that during review, in commits titled "review: ...". In your HANDOFF, mention any new boundary, state transition, or invariant so Claude knows what to document.
- Claude may push commits to your PR branch: documentation, and small fixes that let the PR merge without another round. Before you push to a branch that is in review or that Claude has touched, pull it first. Never rewrite or force-push over Claude's commits.
- Ask before changing architecture, adding a dependency, or touching signing or entitlements.
- Never touch Matt's local changes to project.pbxproj, the shared scheme, or .DS_Store files.

## Architecture is part of the code

Claude keeps the architecture documents current. The rules below say what they must cover.

- Update `ARCHITECTURE.md` in the same change whenever a component boundary, state transition, network message, persistence rule, or platform assumption changes.
- Record durable architectural decisions in `docs/decisions/`.
- Prefer deterministic, testable domain logic over view-owned business rules.
- Do not couple game rules directly to GameKit, PencilKit, or SwiftUI.

## Literate Swift

Claude writes and maintains the documentation comments, following these rules. The coding agent may add comments but is not required to.

- Use Xcode markup documentation comments (`///`) for every type and for non-obvious methods, state transitions, and invariants.
- Explain *why* a rule exists and which invariant it protects. Do not narrate syntax.
- Use headings, lists, `Important`, `Note`, `Parameters`, `Returns`, and `Throws` where they improve generated Quick Help.
- Use `Important` for invariants until the Invariant callout is confirmed in Quick Help.
- Follow Apple's Xcode markup reference:
  https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/

## Engineering discipline

- Keep source files focused on one concept.
- Add tests for every state-machine transition and bug fix.
- Treat network messages and peer-provided text as untrusted input.
- Never make room survival depend on one participant remaining connected.
- Preserve accessibility labels and Dynamic Type behavior when changing UI.
- Do not add a third-party dependency without documenting the reason and alternatives in an architecture decision record.

