# ADR 0001: Use Game Center identity for v1

- Status: Accepted
- Date: 2026-09-19

## Context

The product initially targets iPhone, iPad, and Mac. A custom email/password system would require server-side authentication, account recovery, abuse controls, and identity reconciliation before it adds value to the core game.

CloudKit's public database is not an arbitrary authentication provider; writing requires an authenticated iCloud account.

## Decision

Use Game Center as the v1 player identity and invitation system. Store a game-specific display preference locally when appropriate, while treating the stable Game Center player identifier as the network identity.

## Consequences

- The first release remains Apple-platform only.
- Invitations, friends, and matchmaking use system experiences.
- No password or account-recovery surface is required.
- A custom identity service remains possible behind an adapter if cross-platform support becomes a validated requirement.

