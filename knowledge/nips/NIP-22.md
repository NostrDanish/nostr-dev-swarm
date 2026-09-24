# NIP-22 — Comment

Source: https://github.com/nostr-protocol/nips/blob/master/22.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines `kind:1111` comments: threading notes always scoped to a root — either a Nostr event (id or address) or an external `I`-tag identifier per NIP-73 (URL, podcast GUID, hashtag, geohash, etc.). This is the replacement for kind-1 replies to non-kind-1 events.

## Event kinds
| kind | class | role |
|------|-------|------|
| 1111 | regular | Comment scoped to a root event or external identifier |

## Tags defined/used
Uppercase = ROOT scope; lowercase = PARENT item (same as root for top-level comments):
- `A`/`E`/`I` (required, one of): root scope — address, event id, or I-tag value; `["<A,E,I>", "<address|id|I-value>", "<relay or web hint>", "<root pubkey if E tag>"]`.
- `K` (required): stringified kind of the root item (or external type like `web`, `podcast:item:guid`).
- `P` (required when available): pubkey of root scope author + relay hint.
- `a`/`e`/`i` (required): parent item reference — same syntax as uppercase.
- `k` (required): kind of the parent item.
- `p` (required when available): pubkey of parent author + relay hint.
- `q` (optional): quote citations of NIP-21 references in content.
- `p` tags also SHOULD be used for pubkey mentions via NIP-21 in content.

## Content format
Plaintext only — no HTML, Markdown, or other formatting.

## Semantics & rules
- Comments MUST point to the root scope with UPPERCASE tags and to the parent with lowercase tags. `K` and `k` MUST always be present.
- For top-level comments, root tags and parent tags have identical values.
- When the parent is replaceable/addressable, include BOTH the `a` (address) AND an `e` tag with the specific event id.
- Comments MUST tag authors when available: `P` for root author, `p` for parent author.
- External scopes use `I`/`i` tags with NIP-73 values (`web` URLs, `podcast:item:guid`, hashtags, geohashes, ISBNs...).
- Replies to `kind 30023` articles MUST use kind 1111 (per NIP-23).

## Security & privacy notes
- Comments on external identifiers (URLs, podcast GUIDs) are fully public and unauthenticated w.r.t. the external platform — anyone can comment "on" any URL.
- Thread integrity relies on clients correctly distinguishing root vs parent tags; mixing cases silently breaks threading.
- Relay hints leak where content was found; web hints may leak browsing-adjacent metadata.

## Interoperability notes
- Adopted by long-form clients (comments under articles), podcast apps (Fountain-style GUID comments), and replacing kind-1 replies to articles/files. Depends on NIP-73 for external ID vocabularies and NIP-10/NIP-18 for `q`-tag quoting.

## Example
```yaml
{
  "kind": 1111,
  "content": "Great file!",
  "tags": [
    ["E", "768ac8720cdeb59227cf95e98b66560ef03d8bc9a90d721779e76e68fb42f5e6", "wss://example.relay", "3721e07b079525289877c366ccab47112bdff3d1b44758ca333feb2dbbbbe5bb"],
    ["K", "1063"],
    ["P", "3721e07b079525289877c366ccab47112bdff3d1b44758ca333feb2dbbbbe5bb"],
    ["e", "768ac8720cdeb59227cf95e98b66560ef03d8bc9a90d721779e76e68fb42f5e6", "wss://example.relay", "3721e07b079525289877c366ccab47112bdff3d1b44758ca333feb2dbbbbe5bb"],
    ["k", "1063"],
    ["p", "3721e07b079525289877c366ccab47112bdff3d1b44758ca333feb2dbbbbe5bb"]
  ]
}
```
(comment on a NIP-94 file, from spec)

## Open questions / uncertainties
- Moderation of comment threads on external scopes is unspecified.
- No normative behavior when `K`/`k` disagree with the actual referenced event's kind.
