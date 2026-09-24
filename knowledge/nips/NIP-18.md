# NIP-18 — Reposts

Source: https://github.com/nostr-protocol/nips/blob/master/18.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines reposts (`kind 6`) to signal to followers that a kind-1 note is worth reading, generic reposts (`kind 16`) for any other kind, and quote reposts via `q` tags for NIP-21 mentions.

## Event kinds
| kind | class | role |
|------|-------|------|
| 6 | regular | Repost — reserved for kind-1 contents |
| 16 | regular | Generic repost — any kind other than kind 1 |

## Tags defined/used
- `e` (required): id of the reposted note; MUST include a relay URL as third entry indicating where the note can be fetched.
- `p` (recommended): pubkey of the reposted event's author.
- `q` (quote reposts): `["q", "<event-id> or <event-address>", "<relay-url>", "<pubkey-if-regular-event>"]`.
- `k` (kind 16, SHOULD): stringified kind number of the reposted event.
- `a` (kind 16, SHOULD when reposting a replaceable event): coordinate `kind:pubkey:d-tag` of the reposted event.

## Content format
- kind 6: `.content` is the STRINGIFIED JSON of the reposted note. MAY be empty but that's not recommended.
- Reposts of NIP-70-protected events SHOULD ALWAYS have empty `content`.
- kind 16 without `a` tag (specific version of a replaceable event): `content` MUST contain the full JSON string of the reposted event.

## Semantics & rules
- kind 6 is strictly for kind 1; any other kind ⇒ use kind 16.
- Quote reposts: mentions of NIP-21 entities (`nevent`, `note`, `naddr`) in ANY event's content MUST be converted into `q` tags. Rationale: `q` tags ensure quote reposts are not pulled into reply threads as replies, and allow easily pulling/counting all quotes of a post.
- If a kind-16 repost of a replaceable event has no `a` tag, it is interpreted as reposting a SPECIFIC VERSION, and then the full JSON must be embedded in `content`.

## Security & privacy notes
- Embedding full reposted JSON lets followers verify content without fetching; empty content saves bandwidth but requires trusted fetch.
- NIP-70 (protected events) interplay: reposting protected events with embedded content would defeat relay auth — hence mandatory empty content.
- Reposts amplify content; there is no consent mechanism — authors can't prevent republication.

## Interoperability notes
- Widely implemented (Damus, Amethyst, Snort, Primal, etc.). `q` tags are shared with NIP-10/NIP-22. NIP-25 reactions use a similar `e`/`p`/`k` tag pattern.

## Example
```json
{
  "kind": 6,
  "content": "{\"id\":\"<note-id>\",\"pubkey\":\"<author>\",\"kind\":1,...}",
  "tags": [
    ["e", "<note-id>", "wss://relay.where-note-found"],
    ["p", "<author-pubkey>"]
  ]
}
```
(from spec rules; constructed concrete values)

## Open questions / uncertainties
- No guidance on reposting addressable events in kind 6 (out of scope — only kind 16 covers them).
- Counting quotes via `q` tags depends on relays indexing `q` tags — filter/index support is implementation-dependent.
