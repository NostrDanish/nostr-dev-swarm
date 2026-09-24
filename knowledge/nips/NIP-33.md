# NIP-33 — Parameterized Replaceable Events

Source: https://github.com/nostr-protocol/nips/blob/master/33.md
Retrieved: 2026-09-23
Status: unlisted/withdrawn — stub file: 'Renamed to "Addressable events" and moved to [NIP-01](01.md).' Marked `final` `mandatory`. Not in README. Merged into NIP-01 via PR #703 (2023-08-13); stub text updated 2024-08-20 (PR #1418) for the "addressable event" rename.
Confidence: HIGH (spec-read)

## Purpose
Originally defined parameterized replaceable events — events identified by `pubkey + kind + d-tag` (the `a`-tag coordinate `<kind>:<pubkey>:<d-tag>`), where a newer event replaces older ones with the same coordinate. Renamed "addressable events"; normative text now in NIP-01.

## Event kinds
Historically defined the addressable range 30000≤n<40000; current normative ranges in NIP-01.

## Tags defined/used
`d` tag (address identifier) and `a` tag (coordinate references) — defined in NIP-01.

## Content format
Stub: header + rename/move notice only.

## Semantics & rules
See NIP-01: for addressable events, relays store only the latest per (pubkey, kind, d); `a` tags reference them.

## Security & privacy notes
n/a — pointer stub.

## Interoperability notes
NIP-33 is the most-cited of the merged stubs: countless NIPs say "NIP-33 addressable event" — all such references resolve to NIP-01's addressable-events text.

## Example
n/a — no content in stub.

## Open questions / uncertainties
None — hollowed intentionally; retained for link stability.
