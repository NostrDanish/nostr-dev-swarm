# NIP-50 — Search Capability

Source: https://github.com/nostr-protocol/nips/blob/master/50.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay`
Confidence: HIGH for spec; deployment reality: rare (9/379 probed relays, Aug 2025 census).

## Spec
- Adds a `search` string field to NIP-01 filters.
- Relays SHOULD match against `content`, return results ordered by search quality (NOT created_at), apply `limit` after scoring.
- Query extensions as `key:value`: `include:spam`, `domain:`, `language:`, `sentiment:`, `nsfw:`; unsupported extensions SHOULD be ignored.
- Clients SHOULD check `supported_nips` (NIP-11), query multiple relays, may locally re-verify precision; relays SHOULD filter spam by default.

## Implementation reality
- Search is mostly provided by dedicated indexer relays (relay.nostr.band — closed-source) or client-side, not by general relays.
- Empty/malformed search filters have crashed SDK code (RUSTSEC-2026-0230: empty NIP-50 filter panic) — validate inputs.

## Swarm guidance
- Never assume a relay supports search; feature-detect via NIP-11.
- Treat search results as untrusted like any relay data: verify signatures, expect spam/poisoning.
- For search-heavy products, plan a dedicated indexer (e.g. strfry instance + Compass-style playbook) rather than relying on public relays.
