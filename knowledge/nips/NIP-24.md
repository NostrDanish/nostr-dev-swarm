# NIP-24 — Extra metadata fields and tags

Source: https://github.com/nostr-protocol/nips/blob/master/24.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
A catch-all registry of de-facto-standard extra fields/tags not defined elsewhere: extra kind-0 profile metadata fields, deprecated kind-3 content fields, and the default meanings of common tags (`r`, `i`, `title`, `t`) across event kinds.

## Event kinds
| kind | class | role |
|------|-------|------|
| 0 | replaceable | User metadata — extra optional JSON fields defined here |
| 3 | replaceable | Follow list — deprecated content format documented here |

## Tags defined/used (default meanings when no more specific NIP overrides)
- `r`: a web URL the event refers to.
- `i`: an external id the event refers to — see NIP-73.
- `title`: name of NIP-51 sets, NIP-52 calendar events, NIP-53 live events, NIP-99 listings.
- `t`: hashtag — value MUST be a lowercase string.

## Content format
kind 0 `.content` (stringified JSON) extra fields:
- `display_name`: richer alternative name; `name` should ALWAYS be set regardless.
- `website`: related web URL.
- `banner`: URL to a wide (~1024x768) background picture for profile screens.
- `bot`: boolean — content is entirely/partially automated.
- `birthday`: object `{"year": number, "month": number, "day": number}` — each field MAY be omitted.

Deprecated kind-0 fields (ignore/remove): `displayName` (use `display_name`), `username` (use `name`).
Deprecated kind-3 content: `{<relay-url>: {"read": bool, "write": bool}}` — use NIP-65 instead.

## Semantics & rules
- These fields are optional; clients must tolerate their absence/presence.
- `t` hashtag values MUST be lowercase (non-obvious normalization rule).
- Field deprecation: clients encountering `displayName`/`username` should migrate/ignore.

## Security & privacy notes
- `birthday` and `website` leak personal data; profile metadata is public and replicated.
- `bot` flag is self-declared and unenforceable; malicious bots simply won't set it.
- `banner`/image URLs cause remote fetches → IP-leak/tracking risk when rendering profiles.

## Interoperability notes
- These fields are the de-facto profile standard across virtually all clients (Damus, Amethyst, Primal, Iris, Snort...). NIP-24's tag meanings act as fallback defaults overridden by specific NIPs (e.g. NIP-22's `i` semantics, NIP-23's `title`).

## Example
```json
{
  "kind": 0,
  "content": "{\"name\":\"alice\",\"display_name\":\"Alice ⚡\",\"website\":\"https://alice.example\",\"banner\":\"https://alice.example/banner.jpg\",\"bot\":false,\"birthday\":{\"year\":1990,\"month\":6}}"
}
```
(constructed example per spec field definitions)

## Open questions / uncertainties
- No canonical max lengths or formats for `website`/`banner` beyond "URL".
- `birthday` partial-date semantics (e.g. day without year) are left to clients.
