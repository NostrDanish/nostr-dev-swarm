# NIP-30 — Custom Emoji

Source: https://github.com/nostr-protocol/nips/blob/master/30.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines the `emoji` tag so custom emoji (shortcode → image URL) can be attached to events and rendered inline wherever `:shortcode:` appears in text fields.

## Event kinds
Emoji tags may be added to: **kind 0** (profile metadata), **kind 1** (notes), **kind 1111** (NIP-22 comments), **kind 7** (NIP-25 reactions), **kind 30315** (NIP-38 user statuses).

## Tags defined/used
- `emoji` (optional, repeated): `["emoji", <shortcode>, <image-url>, <emoji-set-address>]`
  - `<shortcode>`: MUST be only alphanumeric characters, hyphens, and underscores.
  - `<image-url>`: URL of the emoji image file.
  - `<emoji-set-address>`: OPTIONAL address pointer (`kind:pubkey:d-tag`) to a kind 30030 emoji set (NIP-51) the emoji belongs to.

## Content format
Unchanged text containing `:shortcode:` tokens; clients "emojify" by replacing tokens with the image. In kind 0, the `name` and `about` JSON fields should be emojified (not the whole content).

## Semantics & rules
- For each emoji tag, clients should parse and replace `:shortcode:` occurrences with the image.
- In NIP-25 reactions (kind 7), a custom emoji reaction has content set to exactly one `:shortcode:` and should have exactly one emoji tag (per NIP-25).
- Shortcode charset restriction (alphanumeric + `-` + `_`) prevents injection and parsing ambiguity.

## Security & privacy notes
- Image URLs are remote fetches: loading custom emoji leaks reader IP to the image host; malicious hosts can track reads.
- Emoji images are arbitrary remote content — clients should consider proxying/caching and image-type validation.
- Shortcode collisions across sets are possible; the optional set address disambiguates.

## Interoperability notes
- Popularized by Mastodon-compatible clients (e.g. Soapbox/Gleasonator heritage in examples); emoji sets live in NIP-51 kind 30030 lists. Used together with NIP-25 (emoji reactions) and NIP-38 (statuses).

## Example
```json
{
  "kind": 1,
  "content": "Hello :gleasonator: 😂 :ablobcatrainbow: :disputed: yolo",
  "tags": [
    ["emoji", "ablobcatrainbow", "https://gleasonator.com/emoji/blobcat/ablobcatrainbow.png", "30030:79c2cae114ea28a981e7559b4fe7854a473521a8d22a66bbab9fa248eb820ff6:blobcats"],
    ["emoji", "disputed", "https://gleasonator.com/emoji/Fun/disputed.png"],
    ["emoji", "gleasonator", "https://gleasonator.com/emoji/Gleasonator/gleasonator.png"]
  ]
}
```
(from spec)

## Open questions / uncertainties
- No guidance on image size/format constraints or animated emoji handling.
- Behavior when content contains a `:shortcode:` with no matching emoji tag is unspecified (render as text).
