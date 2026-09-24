# NIP-54 — Wiki

Source: https://github.com/nostr-protocol/nips/blob/master/54.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
Encyclopedia/wiki entries where MULTIPLE authors are expected to write articles about the exact same subject (small variations or fully independent content). Clients must therefore prioritize among competing versions.

## Event kinds
- `30818` — **Wiki article** (addressable). Identified by lowercase, normalized `d` tags.
- `818` — **Merge request** (regular). Request to merge a forked article into the source.
- `30819` — **Wiki redirect** (addressable). `d` tag = alias name; `a` tag points to target article. Enables auto-redirects and crowdsourced disambiguation pages.

## Tags defined/used
- `d` — normalized article identifier (rules below).
- `title` — display title when different from `d`.
- `summary` — for list displays.
- `a` and `e` — reference the original event an article was forked from.
- Marker semantics on `a`/`e`: `fork` (this event derived from another version; both `a` and `e` SHOULD carry it to pin exact version), `defer` (author considers someone else's entry the better version — stronger than a `+` reaction; effectively a "deletion" of own version, moving WoT weight to the original).
- Merge request (818) tags: `a` = target article; `e` (optional) = base version the modification was made against; `e` with `source` marker = the event id to be merged (MUST be kind 30818); `p` = destination pubkey.

## Content format
Content is **Djot** (not Markdown) with two special features:
1. Links may use NIP-21 `nostr:` URIs, e.g. `[Bob](nostr:npub1...)`.
2. Wikilink behavior: reference-style links with no defined reference resolve to the wiki article with that (normalized) name. `[cryptocurrency][]` → article `cryptocurrency`; `[lightning network][Lightning Network]` → `lightning-network`, display "lightning network".
Not recommended to link to specific article versions via `nostr:` — prefer wikilinks; readers/clients choose versions.

**`d` tag normalization rules** (MUST/SHOULD):
- Uppercase→lowercase (all cased letters); whitespace→`-`; punctuation/symbols SHOULD be removed; consecutive `-` collapsed; leading/trailing `-` stripped; non-ASCII letters (Japanese, Chinese, Arabic, Cyrillic) MUST be preserved as UTF-8; numbers preserved.
- Examples: `"Wiki Article"`→`wiki-article`, `"What's Up?"`→`whats-up`, `"Ñoño"`→`ñoño`, `"日本語 Article"`→`日本語-article`.

## Semantics & rules
- **Merge mechanics**: fork edits article → publishes new 30818 → sends kind 818 to destination pubkey referencing target (`a`), base version (`e`), and merge candidate (`e ... source`). Destination accepts/rejects by NIP-25 reaction `+`/`-` tagging the 818.
- **Version choice**: client-side prioritization via: NIP-25 `+` reactions (2–3 levels of recommendation chains), NIP-51 kind 10102 relay lists (where to query + ranking), NIP-02 contact lists (starting recommendation graph), wiki-specific NIP-51 trusted-author/curator lists.
- **Why Djot**: well-defined standalone spec (vs Markdown dialects/Asciidoc), native implementations in JS/Lua/Rust/Go, rich features (superscript, footnotes, tables, math), Markdown-familiar, linear-time parsing.

## Security & privacy notes
- Competing articles require WoT-based filtering; naive like-counting is explicitly called unproductive.
- Redirects are anyone-can-publish; clients must weigh redirect trust like articles.

## Interoperability notes
- NIP-21 (nostr: URIs), NIP-25 (reactions as accept/reject and recommendations), NIP-51 (lists), NIP-02 (contacts).
- Wiki articles can reference/be referenced by other content kinds.

## Example
Real spec merge request:
```json
{
  "content": "I added information about the block size limit",
  "kind": 818,
  "tags": [
    ["a", "30818:<destination-pubkey>:bitcoin", "<relay-url>"],
    ["e", "<base-version-id>", "<relay-url>"],
    ["p", "<destination-pubkey>"],
    ["e", "<version-to-be-merged>", "<relay-url>", "source"]
  ]
}
```
Redirect:
```json
{"kind": 30819, "tags": [["d", "btc"], ["a", "30818:<pubkey>:bitcoin", "<relay-url>"]], "content": ""}
```

## Open questions / uncertainties
- No canonical algorithm for article selection — deliberately client-defined.
- Merge acceptance is a social signal (reaction), not an automatic content merge.
