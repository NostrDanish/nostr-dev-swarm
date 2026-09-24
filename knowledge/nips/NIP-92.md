# NIP-92 — Media Attachments Metadata (`imeta`)

Source: https://github.com/nostr-protocol/nips/blob/master/92.md
Retrieved: 2026-09-23
Status: header shows only title; the file carries **no `draft`/`optional` marker line** (not formally marked). Listed in README.
Confidence: HIGH (spec-read)

## Purpose
Attach structured metadata to media URLs (images, videos, other files) embedded in event content, enabling rich previews and accessibility without a separate file-metadata event.

## Event kinds
none defined — `imeta` may accompany any kind containing media URLs (commonly kind 1).

## Tags defined/used
- `imeta` ("inline metadata"): variadic tag; each entry after the tag name is a **space-delimited key/value pair**.
- Rules: each `imeta` tag SHOULD match a URL in the event content; MUST contain `url` plus **at least one other field**; there SHOULD be only one `imeta` per URL.
- MAY include **any field specified by NIP-94** (`m` MIME type, `x` sha256, `ox`, `size`, `dim`, `blurhash`, `thumb`, `image`, `summary`, `alt`, `fallback`, …). Multiple `fallback` entries allowed.

## Content format
Media URL appears inline in `.content`; the `imeta` tag provides its metadata. Clients MAY replace imeta URLs with rich previews.

## Semantics & rules
- Recommended client behavior: when uploading files for a new post, MAY include metadata after upload; when the user pastes a URL, the client MAY download the file and compute metadata (hash, dim, blurhash) before sending; clients MAY ignore `imeta` tags whose `url` doesn't match a content URL.

## Security & privacy notes
- `x` sha256 lets clients verify downloaded media against the author-committed hash — integrity against swapped content at the URL (but the author could lie; hash binds only to what author saw).
- Prefetching pasted URLs to compute metadata makes the client fetch arbitrary third-party URLs (IP leakage / tracking via URL beacons).
- `alt` text improves accessibility; spoofed metadata can drive misleading previews.

## Interoperability notes
- Field vocabulary is NIP-94's — one shared schema across kind-1063 file events and inline imeta; kind-1063 events and `imeta` are convertible.
- `blurhash` gives progressive-loading placeholders cross-client.

## Example
Real spec example:
```json
[
  "imeta",
  "url https://nostr.build/i/my-image.jpg",
  "m image/jpeg",
  "blurhash eVF$^OI:${M{o#*0-nNFxakD-?xVM}WEWB%iNKxvR-oetmo#R-aen$",
  "dim 3024x4032",
  "alt A scenic photo overlooking the coast of Costa Rica",
  "x <sha256 hash as specified in NIP 94>",
  "fallback https://nostrcheck.me/alt1.jpg",
  "fallback https://void.cat/alt1.jpg"
]
```

## Open questions / uncertainties
- Space-delimited pairs break on values containing spaces (e.g. `alt` text) — parsing convention ("first space splits key from rest") is implicit, not stated.
- No guidance on conflicting `imeta` vs kind-94 facts for the same URL.
