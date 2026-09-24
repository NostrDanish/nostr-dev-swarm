# Source Registry — Authoritative References

Retrieved: 2026-09-23 (bootstrap); update per-entry on re-verification.

## Tier 1 — specifications / official repos / standards
| Source | URL | What it authoritatively answers |
|---|---|---|
| NIPs repo | https://github.com/nostr-protocol/nips | NIP texts, README master list, kind table, message types |
| NIPs README | https://github.com/nostr-protocol/nips/blob/master/README.md | NIP list + unrecommended marks + kind registry |
| registry-of-kinds | https://github.com/nostr-protocol/registry-of-kinds | Machine-readable kind registry (supplements README) |
| BIP-340 | https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki | Schnorr signatures over secp256k1 |
| NIP-44 test vectors | https://github.com/paulmillr/nip44 | Encryption conformance vectors |
| Blossom spec | https://github.com/hzrd149/blossom | BUD-01..12 blob storage specs |
| Negentropy reference | https://github.com/hoytech/negentropy | Set reconciliation reference impl |
| RustSec | https://rustsec.org/advisories/ | Rust crate security advisories |
| Marmot spec | https://github.com/marmot-protocol/marmot | MLS group messaging over Nostr |
| fiatjaf essay | https://fiatjaf.com/nostr.html | Original design rationale |

## Tier 2 — reference/respected implementations
| Source | URL | Notes |
|---|---|---|
| strfry | https://github.com/hoytech/strfry | Most-deployed relay (C++/LMDB, NIP-77) |
| nostr-rs-relay | https://github.com/scsibug/nostr-rs-relay (mirror; sourcehut master) | Rust/SQLite relay |
| khatru | https://github.com/fiatjaf/khatru (archived) → https://pkg.go.dev/fiatjaf.com/nostr/khatru | Go relay framework |
| nostream | https://github.com/Cameri/nostream | TS relay (PG+Redis) |
| nostr-tools | https://github.com/nbd-wtf/nostr-tools | JS toolkit |
| NDK | https://github.com/nostr-dev-kit/ndk | TS framework |
| nostr-sdk | https://github.com/nostrdevkit/nostr | Rust workspace + bindings |
| fiatjaf.com/nostr | https://pkg.go.dev/fiatjaf.com/nostr | Go monorepo (go-nostr successor) |
| Amber | https://github.com/greenart7c3/Amber | Android signer (NIP-46/55) |
| nostr.watch | https://github.com/sandwichfarm/nostr-watch | NIP-66 relay monitoring |
| Relay census | https://github.com/chr15m/nostr-relay-research | Aug 2025 deployment probe |

## Tier 3 — technical articles / community docs
- d-central.tech guides (key management, relay ops, DVMs)
- awesome-nostr: https://github.com/aljazceru/awesome-nostr
- logperiodic.com/rbsr.html (negentropy theory, by its author — Tier 1.5)

## Tier 4 — social/forums (lead generation only, never authority)
- Nostr itself, HN threads, etc.

## Rules
1. Cite the tier with every claim.
2. When sources disagree: identify the disagreement → check obsolescence → check implementation reality → distinguish spec vs convention → never silently invent behavior.
3. Raw bootstrap research reports: `sources/research/nip-inventory-2026-09-23.md`, `sources/research/ecosystem-map-2026-09-23.md`.
