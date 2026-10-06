# ADR 0002: Deterministic host migration

- Status: Historical; deferred from the current Free Draw implementation
- Date: 2026-09-19

## Context

A party must not end because its original host backgrounds the app, loses connectivity, or leaves. Making one device the sole owner of room state would also make recovery and testing fragile.

## Decision

Replicate committed room state to every peer. The current host coordinates commands, while every peer applies the same ordered events. When the host disconnects, all peers choose the connected participant with the smallest `(joinOrdinal, participantID)` ordering key. Host authority is versioned by a monotonically increasing term.

## Consequences

- Host migration requires no central room owner.
- Determinism is unit-testable without GameKit.
- Reliable game events and periodic snapshots are required.
- In-flight commands may need retry after a term change.
- A reconnected former host remains a normal participant unless elected during a later migration.

