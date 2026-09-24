# NIP-42 — Authentication of Clients to Relays

Source: https://github.com/nostr-protocol/nips/blob/master/42.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay`
Confidence: HIGH.

## Flow
- Relay sends `["AUTH", <challenge>]`; client answers `["AUTH", <signed event>]`.
- Auth event: ephemeral kind **22242** with `relay` and `challenge` tags; relays MUST NOT broadcast kind 22242; `created_at` within ~10 minutes.
- Multiple pubkeys per connection via sequential AUTH; client AUTH MUST be answered with `OK`.
- New prefixes: `auth-required:` (no auth performed), `restricted:` (authed but not permitted). NIP-67 EOSE may carry an `auth` hint.

## Where auth is load-bearing
- NIP-17: relays serve kind 1059 gift wraps only to authenticated p-tagged recipient.
- NIP-78: kinds 78/30078 SHOULD require auth, served only to author.
- NIP-59: relays should require AUTH for gift wraps (spam mitigation).
- NIP-70: protected events restricted to relay-authenticated author writes.
- Deployment: 97/379 probed relays (Aug 2025).

## Security notes
- SDK precedent: unbounded AUTH challenge queue → memory DoS (RUSTSEC-2026-0231; fix in the 0.44.x line — verify exact patched floor at https://rustsec.org/advisories/RUSTSEC-2026-0231.html before pinning). Bound challenge state.
- AUTH binds pubkey↔connection: enables relay-side correlation — privacy tradeoff, document it.
