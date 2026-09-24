# NIP-F4 — Podcasts

Source: https://github.com/nostr-protocol/nips/blob/master/F4.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
Nostr-native podcast feeds: replace monolithic RSS feed URLs with per-episode Nostr events, fitting existing podcast players. Solves RSS pain points: URL/service-provider dependence (walled gardens, censorship, migration lock-in), no pagination/filtering (slow sync, schemes like Podping), no per-episode addressability (can't share one episode), no interaction (likes/comments/listens).

## Event kinds
- `10154` — **Podcast metadata** (replaceable). Show-level info; podcast clients should read this directly and ignore kind 0.
- `54` — **Podcast episode** (regular). Authored directly by the podcast's own pubkey.
- `10064` — **Authored podcasts list** (see discrepancy note below) — a user's counter-claim listing podcast pubkeys they author. README registers `10054` (favorite podcasts, NIP-51) and `10064` (authored podcasts, NIP-51).

## Tags defined/used
- 10154: `title`, `image` (cover URL), `description`, `website` (optional, multiple), `p` (optional, multiple: `<podcast-author-pubkey>`, role `host`/`cohost`/`editor`).
- 54 (episode): `title`, `image` (optional), `description`, `audio` (`["audio", "<audio-url>", "<optional media type>"]`, repeatable for alternate enclosures). `content` = markdown show notes.

## Content format
10154/10064: empty content (tag-driven). 54: markdown content.

## Semantics & rules
- **Each podcast is its own Nostr keypair** — enables combining podcast presence with normal kind-0/kind-1 microblogging; shared ownership via MuSig2 or social agreements; ownership can change over time (key handoff).
- **Authorship verification is two-way**: the `p` tag in 10154 MUST NOT be blindly trusted (any podcast can falsely claim authors); clients must check it against the claimed author's own authored-podcasts list event before displaying.
- Clients can use authored-podcasts lists to discover all podcasts by a user.
- Favorite podcasts: NIP-51 kind 10054 list — soft public recommendations.

## Security & privacy notes
- Bidirectional authorship claim check is the core anti-spoofing rule.
- Podcast key compromise = feed takeover; key rotation/handoff is purely social.

## Interoperability notes
- Designed to slot into existing podcast players (episode-per-event ≈ RSS item).
- NIP-51 lists (10054 favorites, authored lists), kind-0/1 profile interop optional.

## Example
Real spec episode:
```yaml
{
  "pubkey": "<podcast-pubkey>",
  "kind": 54,
  "tags": [
    ["title", "<episode title>"],
    ["image", "<optional episode image>"],
    ["description", "<a brief description>"],
    ["audio", "<audio-url>", "<optional_media_type>"]
  ],
  "content": "<markdown content>"
}
```

## Open questions / uncertainties
- **Kind-number inconsistency in spec**: prose says "This is the `kind:10164` event" but the example uses `kind: 10064`, and README registers `10064` as "Authored podcasts list" under NIP-51. Treat 10064 as canonical; 10164 is likely a typo.
- Spec explicitly defers: "...other important fields to be specified here later after further discovery" (episode metadata incomplete — no explicit GUID, duration, chapters, transcript tags yet).
- No value4value/payment tagging defined here.
