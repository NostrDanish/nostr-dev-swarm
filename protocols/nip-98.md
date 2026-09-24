# NIP-98 — HTTP Auth

Source: https://github.com/nostr-protocol/nips/blob/master/98.md
Retrieved: 2026-09-23
Status: `draft` `optional`
Confidence: HIGH.

## Spec
- Ephemeral kind **27235** event; content SHOULD be empty; required tags: `u` (absolute URL including query) and `method`; optional `payload` = hex SHA-256 of request body (POST/PUT/PATCH).
- Transport: `Authorization: Nostr <base64(event)>`.
- Server MUST check: kind == 27235, ~60-second timestamp window, exact URL match, method match; failures SHOULD → 401.

## Usage
- NIP-86 Relay Management API requires NIP-98 with `payload` tag REQUIRED and `u` = relay URL.
- Blossom-style HTTP services and NIP-96 (legacy) use NIP-98.
- General pattern for Nostr-authenticated REST APIs (alternative to API keys).

## Security notes (swarm-enforced)
- Strict URL canonicalization — query included; mismatches must fail closed.
- 60s window limits replay; servers should additionally dedupe event ids.
- SDK precedent: RUSTSEC-2026-0229 — NIP-98 parsing resource exhaustion. Bound header/event sizes.
- Never log full Authorization headers; the event is signed identity material.
