# NIP-25 — Reactions

Source: https://github.com/nostr-protocol/nips/blob/master/25.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines reaction events: `kind 7` for reactions to Nostr events (likes, dislikes, emoji) and `kind 17` for reactions to EXTERNAL (non-Nostr) content referenced via NIP-73 tags. Also defines custom-emoji reactions via NIP-30.

## Event kinds
| kind | class | role |
|------|-------|------|
| 7 | regular | Reaction to a Nostr event |
| 17 | regular | Reaction to external content (website, podcast, etc.) |

## Tags defined/used
kind 7:
- `e` (required): id of the event reacted to; SHOULD include relay hint; if multiple `e` tags (not recommended), the TARGET id must be LAST.
- `p` (SHOULD): pubkey of the event reacted to; if multiple `p` tags (not recommended), target pubkey must be LAST.
- `a` (SHOULD, when target is addressable): coordinates `kind:pubkey:d-tag`, included together with the `e` tag.
- `k` (MAY): stringified kind number of the reacted event.
- `e`/`a` SHOULD include relay and pubkey hints; `p` SHOULD include relay hints.
kind 17 (external):
- `k` (required): NIP-73 external content kind (`web`, `podcast:guid`, `podcast:item:guid`, ...).
- `i` (required): NIP-73 external identifier, optionally with hint URL.
- `emoji` (custom emoji reactions): `["emoji", <shortcode>, <image-url>]` per NIP-30.

## Content format
`content` MUST include user-generated content indicating reaction value:
- `+` or empty string ⇒ MUST be interpreted as "like"/"upvote".
- `-` ⇒ MUST be interpreted as "dislike"/"downvote".
- An emoji or NIP-30 `:shortcode:` ⇒ SHOULD NOT be interpreted as like/dislike; clients MAY display the emoji on the post.
- Custom emoji reaction: content is exactly ONE `:shortcode:` and there should be exactly ONE `emoji` tag.

## Semantics & rules
- kind 17 MUST be used (not kind 7) when the reaction target is not a native Nostr event, and MUST include NIP-73 `k`+`i` tags.
- Podcast example shows multiple `k`/`i` pairs for show + episode scoping.
- Reference Swift code in spec builds a like: tags `[["e", id, hint, pubkey], ["p", pubkey, hint], ["k", kind]]`, content `"+"`.

## Security & privacy notes
- Reactions are public, attributable, and non-repudiable — a like is a permanent public endorsement (deletion requests are best-effort per NIP-09).
- Reaction counts are trivially gameable (sockpuppet keys); clients shouldn't treat raw counts as quality signals.
- Empty-string content = like is a common interop trap (clients must not render it as blank).

## Interoperability notes
- Universally implemented for kind 7. Custom emoji reactions come from NIP-30; zap interactions (NIP-57) often accompany reactions. Kind 17 depends on NIP-73 vocabularies.

## Example
```yaml
{
  "kind": 17,
  "content": "⭐",
  "tags": [
    ["k", "web"],
    ["i", "https://example.com"]
  ]
}
```
(external website reaction, from spec)

```yaml
{
  "kind": 7,
  "content": ":soapbox:",
  "tags": [
    ["emoji", "soapbox", "https://gleasonator.com/emoji/Gleasonator/soapbox.png"]
  ]
}
```
(custom emoji reaction, from spec)

## Open questions / uncertainties
- No standardized negative-reaction display norms; `-` handling varies by client.
- Kind 17 adoption is much lower than kind 7 in practice.
