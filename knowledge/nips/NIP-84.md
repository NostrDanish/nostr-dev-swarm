# NIP-84 — Highlights

Source: https://github.com/nostr-protocol/nips/blob/master/84.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
`kind:9802` "highlight" events signal content a user finds valuable — the Nostr analogue of ebook/article highlights.

## Event kinds
- `9802` — **Highlight** (regular).

## Tags defined/used
- **References** (SHOULD tag the source, nostr-native or not): `a` and/or `e` for nostr events; `i` for structured sources per NIP-73 (ISBNs, DOIs, podcast GUIDs...); `r` for anything else (URL or text).
- **Attribution**: one or more `p` tags MAY tag original authors (with optional role as last value: `author`, `editor`). Useful for non-nostr content where a pubkey is discoverable (e.g. `<link rel="me" href="nostr:nprofile1...">` on the document, or user prompt).
- `context` — MAY be included; surrounding text when the highlight is a subset of a paragraph (anchor/context semantics).
- `comment` — MAY be added to create a **quote highlight**; SHOULD render like a quote repost with the highlight as the quoted note. Prevents creating two successive notes (highlight + kind 1) which looks bad in microblogging clients.
- Marker discipline for quote highlights: `p`-tag mentions MUST carry a `mention` attribute to distinguish them from authors/editors; `r`-tag URLs from the comment MUST have a `mention` attribute; the highlighted source URL `r` tag MUST have the `source` attribute.

## Content format
`.content` = the highlighted portion of the text. MAY be empty for non-text media (e.g. NIP-94 audio/video highlights).

## Semantics & rules
- Anchor semantics: the highlight anchors to its source purely via reference tags (`e`/`a`/`i`/`r`) plus optional `context`; there is no character-offset anchoring — `content` + `context` are the locators.
- Quote highlight merges commentary into the same event instead of a separate kind-1.

## Security & privacy notes
- Highlights publicly reveal what a user reads/finds valuable (reading-history exposure).
- Attribution `p` tags are claims by the highlighter; not verified authorship.

## Interoperability notes
- NIP-73 external content IDs (`i`), NIP-94 (non-text media targets), NIP-21/nprofile discovery for author attribution, NIP-18-style quote rendering convention.

## Example
Constructed example (spec provides tag-level snippets only):
```json
{
  "kind": 9802,
  "content": "the highlighted sentence",
  "tags": [
    ["r", "https://example.com/article", "source"],
    ["context", "surrounding paragraph text..."],
    ["p", "<author-pubkey>", "<relay-url>", "author"],
    ["comment", "Great point!"],
    ["p", "<mentioned-pubkey>", "", "mention"]
  ]
}
```
Spec attribution example:
```yaml
{"tags": [
  ["p", "<pubkey-hex>", "<relay-url>", "author"],
  ["p", "<pubkey-hex>", "<relay-url>", "editor"]
]}
```

## Open questions / uncertainties
- No positional anchoring (offsets/selectors) — fuzzy matching via `context` only.
- Role vocabulary beyond author/editor is not enumerated.
