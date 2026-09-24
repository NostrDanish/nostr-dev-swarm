# Networking & Distributed Systems Knowledge Base

Source: NIP-01/11/42/45/50/65/66/77 + relay implementation docs (see knowledge/relays/IMPLEMENTATIONS.md)
Retrieved: 2026-09-23
Confidence: HIGH for protocol mechanics; MEDIUM for deployment guidance.

## Nostr wire protocol
- WebSocket (typically WSS) between client and relay; JSON arrays.
- Client→relay: `EVENT`, `REQ`, `CLOSE` (NIP-01), `AUTH` (NIP-42), `COUNT` (NIP-45).
- Relay→client: `EOSE`, `EVENT`, `NOTICE`, `OK`, `CLOSED` (NIP-01), `AUTH` (NIP-42), `COUNT` (NIP-45).
- NIP-77 adds `NEG-OPEN` / `NEG-MSG` / `NEG-ERR` / `NEG-CLOSE` (binary hex-encoded; separate subscription-id namespace from REQ).
- `OK`/`CLOSED` machine-readable prefixes: duplicate, pow, blocked, rate-limited, invalid, restricted, mute, error, auth-required.

## Efficiency
- NIP-77 negentropy: range-based set reconciliation (~KB fingerprints vs full ID lists); yields ID sets only — actual transfer via ordinary EVENT/REQ on the same connection. Protocol version byte 0x61 (v1). See NEGENTROPY.md for algorithm internals.
- `limit: 0` opens a live subscription without initial stored-event dump.
- NIP-45 COUNT avoids transferring events for counts; HLL extension merges counts across relays.

## Routing model (NIP-65 outbox)
- Fetch author's events from their WRITE relays; mentions from their READ relays.
- Publish to: author's write relays + tagged users' read relays + propagate kind-10002.
- Keep lists small (2–4 relays/category), spread to public indexers.

## Relay discovery & liveness
- NIP-66: kind-30166 relay discovery events, kind-10166 monitor announcements; nostr.watch (https://github.com/sandwichfarm/nostr-watch).
- NIP-11: HTTP `Accept: application/nostr+json` at relay URI; honor `limitation` (max_message_length, max_subscriptions, max_limit, min_pow_difficulty, auth_required, payment_required, created_at limits...); CORS required; unknown fields MUST be ignored.

## Distributed-systems checklist for any relay topology design
Failure (relay disappears) · partition (split relay sets) · duplication (same event, many relays) · ordering (created_at is author-claimed, not trustworthy) · replay (old events re-broadcast) · stale data (replaceable/addressable latest-wins, lowest-id tiebreak) · convergence (negentropy sync) · recovery (re-fetch from outbox relays).

## Privacy-relevant network facts
- Relays see client IPs; Tor/I2P supported by some relay stacks (nostream documents options).
- NIP-17/59 randomize seal/wrap created_at up to 2 days past to resist timing correlation.
- NIP-42 AUTH binds a pubkey to a connection — necessary for private kinds, but enables relay-side correlation; treat as tradeoff, not free win.
