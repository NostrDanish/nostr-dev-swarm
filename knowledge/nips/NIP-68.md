# NIP-68 — Picture-first feeds

Source: https://github.com/nostr-protocol/nips/blob/master/68.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
Kind `20` picture events for Instagram/Flickr/Snapchat/9GAG-like clients where the picture is the centerpiece. Images are hosted externally and referenced with `imeta` tags; events must be self-contained.

## Event kinds
- `20` — **Picture event** (regular). May contain multiple images as a single post.

## Tags defined/used
- `title` — short title of post.
- `imeta` (per NIP-92, repeated per image) with fields: `url`, `m` (MIME), `thumbhash`, `blurhash`, `dim` (`3024x4032`), `alt`, `x` (sha256 per NIP-94), `fallback` (repeated mirror URLs), and `annotate-user <pubkey-hex>:<posX>:<posY>` to tag users at specific positions in the image.
- `content-warning` — NSFW reason.
- `p` — tagged users (with optional relay).
- `m` — media type for filter support (clients filter by supported kinds/types).
- `x` — sha256 of each image, making images queryable by hash.
- `t` hashtags; `location` (city/state/country); `g` geohash.
- `L`/`l` (NIP-32) with ISO-639-1 when text is written in the image.

## Content format
`.content` = description of post; images only via `imeta`.

## Semantics & rules
- **Only these media types accepted**: `image/apng`, `image/avif`, `image/gif`, `image/jpeg`, `image/png`, `image/webp`.
- Multiple `imeta` tags = multi-image post displayed as one unit.
- `fallback` URLs provide mirror redundancy.
- Picture events may be mixed with NIP-71 kind `22` short vertical videos in the same feed.

## Security & privacy notes
- `annotate-user` publicly links pubkeys to face/positions in images — privacy-sensitive.
- External hosting means link rot; mitigated by `x` hash + `fallback` mirrors.

## Interoperability notes
- NIP-92 (`imeta`), NIP-94 (`x` file hash), NIP-32 (labels), NIP-71 kind 22 (mixed feeds).
- Fits media-set lists like kind 30006 picture sets / 39092 media starter packs (NIP-51).

## Example
Real spec example (abridged):
```yaml
{
  "kind": 20,
  "content": "<description of post>",
  "tags": [
    ["title", "<short title of post>"],
    ["imeta",
      "url https://nostr.build/i/my-image.jpg",
      "m image/jpeg",
      "blurhash eVF$^OI:${M{o#*0-nNFxakD-?xVM}WEWB%iNKxvR-oetmo#R-aen$",
      "dim 3024x4032",
      "alt A scenic photo overlooking the coast of Costa Rica",
      "x <sha256>",
      "fallback https://nostrcheck.me/alt1.jpg"],
    ["imeta", "...", "annotate-user <pubkey>:<posX>:<posY>"],
    ["content-warning", "<reason>"],
    ["m", "image/jpeg"],
    ["x", "<sha256>"],
    ["t", "<tag>"],
    ["location", "<location>"], ["g", "<geohash>"],
    ["L", "ISO-639-1"], ["l", "en", "ISO-639-1"]
  ]
}
```

## Open questions / uncertainties
- `annotate-user` coordinate system (units/origin) is not specified beyond `<posX>:<posY>`.
- Carousels/album ordering of multiple `imeta` tags is implicitly tag order (not stated).
