# NIP-B0 — Web Bookmarking

Source: https://github.com/nostr-protocol/nips/blob/master/B0.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README. README lists it as "Web Bookmarks".
Confidence: HIGH (spec-read)

## Purpose
Editable web bookmarks as addressable events — one event per URI, queryable by `d` tag.

## Event kinds
- `39701` — **Web bookmark** (addressable).

## Tags defined/used
- `d` (required) — the bookmarked URI itself. Convention: if the scheme is `https`, omit everything before the hostname (e.g. `alice.blog/post` not `https://alice.blog/post`). This makes bookmarks queryable by `d`.
- `t` — hashtags/topics.
- `published_at` — unix seconds (string) of first bookmark publication.
- `title` — bookmark title; usable as attribute for the HTML link element.

## Content format
`.content` = detailed description of the bookmark; may be empty.

## Semantics & rules
- Addressability: since `d` = URI, each user has at most one bookmark per URI; editing = republishing the same address.
- Replies/comments to kind 39701 MUST use kind `1111` events per NIP-22.

## Security & privacy notes
- Bookmarks are public by default — reading/collection habits exposed.
- URI normalization (stripped scheme) means `http` vs `https` variants produce different `d` values only for non-https (https prefix always dropped).

## Interoperability notes
- NIP-22 comments (kind 1111); complements NIP-51 kind 10003 bookmark lists / 30003 bookmark sets (which reference events/addresses rather than arbitrary URIs — B0 covers plain web URIs).

## Example
Real spec example:
```yaml
{
  "kind": 39701,
  "pubkey": "2729620da105979b22acfdfe9585274a78c282869b493abfa4120d3af2061298",
  "created_at": 1738869705,
  "tags": [
    ["d", "alice.blog/post"],
    ["published_at", "1738863000"],
    ["title", "Blog insights by Alice"],
    ["t", "post"],
    ["t", "insight"]
  ],
  "content": "A marvelous insight by Alice about the nature of blogs and posts."
}
```

## Open questions / uncertainties
- Behavior for non-https schemes beyond "omit chars before hostname only if https" is minimally specified (e.g. should `http://` be kept? spec implies yes).
- No guidance on trailing-slash/fragment normalization, so near-duplicate bookmarks possible.
