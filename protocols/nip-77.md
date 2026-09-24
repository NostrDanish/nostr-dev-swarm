# NIP-77 — Negentropy Syncing

Source: https://github.com/nostr-protocol/nips/blob/master/77.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay`
Confidence: HIGH.

## Purpose
Efficient client↔relay and relay↔relay set reconciliation using Negentropy v1: instead of exchanging full ID lists, peers exchange ~KB-sized range fingerprints and converge on have/need ID sets.

## Messages (hex-encoded binary over the same WS)
`NEG-OPEN` (subscription id + NIP-01 filter + initial message), bidirectional `NEG-MSG`, `NEG-ERR` (`blocked:`/`closed:`), `NEG-CLOSE`.
- NEG subscription IDs are a SEPARATE namespace from REQ IDs.
- Reconciliation yields ID sets only; actual event transfer uses ordinary `EVENT`/`REQ` on the same connection.

## Wire format (appendix)
Varints, 32-byte IDs, ranges with modes Skip(0)/Fingerprint(1)/IdList(2); fingerprint = SHA-256 over (sum of IDs — each ID interpreted as a 32-byte LITTLE-ENDIAN integer — mod 2^256, followed by the item count encoded as a Varint), truncated to [0:16]; protocol version byte 0x61 (v1). Implementers: do not code from this summary alone — follow 77.md's appendix byte-for-byte.

## Implementations
- Reference: https://github.com/hoytech/negentropy (C++)
- Rust: https://github.com/nostrdevkit/negentropy
- TS client: @nostr-dev-kit/sync, nostr-tools client-side
- Relay support: strfry (native sync — flagship), khatru (`Negentropy` flag), Citrine (≥v3.0.0), nogringo/nostr-relay, nostria-app/nostria-relay. nostr-rs-relay: NOT yet (open issue #234).
- Deployment: 66/379 probed relays (Aug 2025).

## Swarm guidance
- Prefer NIP-77 over "fetch everything since X" for sync-heavy features (local-first clients, relay mirroring, backup).
- Do not implement negentropy from scratch without property-based tests against the reference implementation.
