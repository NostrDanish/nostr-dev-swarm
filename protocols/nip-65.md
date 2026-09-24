# NIP-65 — Relay List Metadata (Outbox Model)

Source: https://github.com/nostr-protocol/nips/blob/master/65.md
Retrieved: 2026-09-23
Status: `draft` `optional`
Confidence: HIGH.

## Spec
- Replaceable kind **10002** with `r` tags: `["r", "<relay url>", "<read|write?>"]` (no marker = both).
- Outbox model routing:
  - Fetch a user's events from their **write** relays.
  - Fetch mentions of a user from their **read** relays.
  - Publish to: author's write relays + tagged users' read relays + propagate the author's kind-10002.
- Keep lists small (2–4 relays per category); spread widely to public indexers.

## Why it matters
This is what makes Nostr identity/data portable in practice: clients discover where a user actually reads/writes instead of relying on a hardcoded relay set. The basis of scalable relay topology.

## Swarm guidance
- Any client we build MUST publish and honor kind-10002.
- Relay selection UX: surface write vs read semantics; warn when a user's relays are unreachable or tiny/overlapping sets (centralization risk).
- Watch relay list freshness — stale 10002 = undeliverable DMs/mentions.
