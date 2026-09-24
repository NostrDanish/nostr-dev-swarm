# NIP-20 — Command Results

Source: https://github.com/nostr-protocol/nips/blob/master/20.md
Retrieved: 2026-09-23
Status: unlisted/withdrawn — stub file: "Moved to [NIP-01](01.md)." Marked `final` `mandatory`. Not in README. Merged into NIP-01 via PR #703 (2023-08-13).
Confidence: HIGH (spec-read)

## Purpose
Originally defined `OK` command results — relay-to-client messages indicating whether an `EVENT` was accepted (`["OK", <event-id>, <true|false>, <message>]`). Now normative in NIP-01.

## Event kinds
none defined

## Tags defined/used
none

## Content format
Stub: header + "Moved to NIP-01" only.

## Semantics & rules
See NIP-01: relays send `OK` messages with machine-readable prefixes (`duplicate:`, `pow:`, `blocked:`, `rate-limited:`, `invalid:`, `error:`) in the message field.

## Security & privacy notes
n/a — pointer stub.

## Interoperability notes
Old references to NIP-20 = NIP-01 `OK` semantics.

## Example
n/a — no content in stub.

## Open questions / uncertainties
None — hollowed intentionally; retained for link stability.
