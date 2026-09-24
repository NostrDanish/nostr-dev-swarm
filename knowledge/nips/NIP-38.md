# NIP-38 — User Statuses

Source: https://github.com/nostr-protocol/nips/blob/master/38.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines `kind:30315` "User Status" — an optionally-expiring addressable event for sharing live statuses: what music you're listening to, current activity ("working", "hiking", "out of office"), etc.

## Event kinds
| kind | class | role |
|------|-------|------|
| 30315 | addressable (parameterized replaceable) | User status; `d` tag = status type |

## Tags defined/used
- `d` (required): status type. Two common types defined: `general` (general activity) and `music` (now-playing). Other types allowed but not defined here.
- `r` (MAY): link to a URL (e.g. `spotify:search:...` or event page).
- `p`, `e`, `a` (MAY): link the status to a profile, note, or addressable event.
- `expiration` (optional, per NIP-40): expiry timestamp — for `music`, should be when the track stops playing.

## Content format
Human-readable status text; MAY include emoji or NIP-30 custom emoji. Empty-string `content` means the client should CLEAR the status.

## Semantics & rules
- Addressable per (pubkey, d): one current status per type per user; new status of same type replaces the old.
- `music` status expiry should match track end (use NIP-40 `expiration` tag).
- Clients MAY display status next to the username on posts or profiles.
- Use cases listed: calendar apps setting "in a meeting", Nostr Nests linking to the nest, music/podcast apps updating now-playing, system media player integration.

## Security & privacy notes
- Live statuses are a real-time presence/activity leak — reveals habits, location-ish context, listening history; the addressable replaceability means only the latest is "current" but relays may retain old ones.
- `r` links can be tracking URLs; fetching them leaks reader IP.
- Nothing verifies a status (self-reported).

## Interoperability notes
- Implemented by status-capable clients (e.g. Amethyst, Nostr Nests ecosystem, some music clients). Composes with NIP-30 (custom emoji in status) and NIP-40 (expiration).

## Example
```json
{
  "kind": 30315,
  "content": "Intergalatic - Beastie Boys",
  "tags": [
    ["d", "music"],
    ["r", "spotify:search:Intergalatic%20-%20Beastie%20Boys"],
    ["expiration", "1692845589"]
  ]
}
```
(from spec)

## Open questions / uncertainties
- Only `general` and `music` are standardized; no registry for other status types.
- Behavior when `expiration` is absent vs. empty content for clearing is a client-convention gap (empty content clears; absent expiration means persistent until replaced).
