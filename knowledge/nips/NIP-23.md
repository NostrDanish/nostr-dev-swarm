# NIP-23 — Long-form Content

Source: https://github.com/nostr-protocol/nips/blob/master/23.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines `kind:30023` (addressable) for long-form Markdown articles/blog posts, with standardized metadata tags and editability via `d` tags. Also records the deprecation of kind 30024 drafts in favor of NIP-37.

## Event kinds
| kind | class | role |
|------|-------|------|
| 30023 | addressable | Long-form article (Markdown) |
| 30024 | addressable | DEPRECATED draft long-form (was self-encrypted NIP-04); use NIP-37 instead |

## Tags defined/used
- `d` (required in practice): article identifier for addressability/editability.
- `t` (optional, repeated): hashtags/topics.
- `title`, `image`, `summary`, `published_at` (optional, standardized): title; header image URL; summary; first-publication unix timestamp (stringified).
- `e`, `a` (optional): references to cited notes/articles with relay hints (paired with `nostr:` links per NIP-27).

## Content format
Markdown text. Two hard constraints for creators: MUST NOT hard line-break paragraphs (no arbitrary 80-column breaks); MUST NOT support adding HTML to Markdown.

## Semantics & rules
- `.created_at` = date of last update; `published_at` tag = first publication.
- Editability: articles are meant to be edited; clients should publish/read from relays implementing addressable-replacement semantics and MUST hide older versions of the same article (same `d`) they receive.
- Linking: use NIP-19 `naddr` codes plus an `a` tag.
- References to other notes/articles/profiles inside content MUST follow NIP-27 (`nostr:...` links, optional paired tags).
- Replies/comments to kind 30023 MUST use NIP-22 kind 1111 comments (NOT kind-1 replies).
- "Social" kind-1 clients should NOT be expected to implement this NIP.

## Security & privacy notes
- Markdown rendering without HTML mitigates injection/XSS — clients must still sanitize rendering.
- Editable addressable events: old versions persist on relays that ignore replacement; readers may see stale articles.
- `published_at` is self-reported and forgeable.

## Interoperability notes
- Implemented by long-form clients (Habla.news, Yakihonne, Highlighter, etc.); NIP-22 comments are the mandated reply mechanism; NIP-18 kind-16 generic reposts handle reposting articles.

## Example
(spec example, sample text replaced with neutral placeholders)
```json
{
  "kind": 30023,
  "created_at": 1675642635,
  "content": "A long-form article with an inline [reference][nostr:nevent1qqst8cujky046negxgwwm5ynqwn53t8aqjr6afd8g59nfqwxpdhylpcpzamhxue69uhhyetvv9ujuetcv9khqmr99e3k7mg8arnc9] to another note...",
  "tags": [
    ["d", "my-first-article"],
    ["title", "My First Article"],
    ["published_at", "1296962229"],
    ["t", "placeholder"],
    ["e", "b3e392b11f5d4f28321cedd09303a748acfd0487aea5a7450b3481c60b6e4f87", "wss://relay.example.com"],
    ["a", "30023:a695f6b60119d9521934a691347d9f78e8770b56da16bb255ee286ddf9fda919:ipsum", "wss://relay.nostr.org"]
  ]
}
```
(from spec, truncated)

## Open questions / uncertainties
- Markdown flavor is unspecified (CommonMark? GFM?) — rendering varies across clients.
- No canonical rule for `d`-tag collisions across clients editing the same article.
