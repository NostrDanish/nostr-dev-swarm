# NIP-10 — Text Notes and Threads

Source: https://github.com/nostr-protocol/nips/blob/master/10.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines `kind:1` as a simple plaintext note and specifies how threads are constructed with marked `e` tags (root/reply markers), how mentions/quotes work via `q` tags, and how `p` tags record thread participants. Also documents (deprecated) positional `e` tags for backward compatibility.

## Event kinds
| kind | class | role |
|------|-------|------|
| 1 | regular | Short text note / thread reply |

## Tags defined/used
- `e` (optional, repeated, marked PREFERRED): `["e", <event-id>, <relay-url>, <marker>, <pubkey>]` where marker ∈ {`"reply"`, `"root"`}; relay-url SHOULD be valid but may be `""`; pubkey SHOULD be the author of the referenced event (used by the outbox model to fetch from author's write relays).
- `q` (optional): `["q", "<event-id> or <event-address>", "<relay-url>", "<pubkey-if-regular-event>"]` — for quoting events cited via NIP-21 `nostr:` URLs; keeps quotes out of reply threads.
- `p` (optional, repeated): pubkeys involved in the thread — notifications.

## Content format
Human-readable plaintext. Markup languages such as Markdown and HTML SHOULD NOT be used.

## Semantics & rules
- Kind-1 replies MUST NOT reply to other kinds — use NIP-22 (kind 1111) instead. (Non-obvious: cross-kind replies are forbidden here.)
- Marked `e` tags: `"reply"` = direct parent; `"root"` = thread root. A direct reply to the root uses ONLY a `"root"` marker (single `e` tag).
- `e` tags SHOULD be sorted by reply stack from root to direct parent.
- Authors of `e` and `q` tagged events SHOULD be added as `p` tags to notify them.
- `p` tag inheritance: replying to event E with `p` tags [p1,p2,p3] by author a1 ⇒ reply's `p` tags should be [a1, p1, p2, p3] (any order).
- DEPRECATED positional scheme (keep for reading old events): no marker; positions carry meaning — 0 `e` tags = standalone; 1 = reply target; 2 = [root, reply]; many = [root, ...mentions..., reply]. Deprecated because mentions are ambiguous with replies.

## Security & privacy notes
- Positional-tag ambiguity lets mentions be misread as replies — reason for deprecation; clients must handle both schemes when reading.
- Missing/incorrect relay hints can make referenced events unfetchable; pubkey hints aid outbox-model resolution.
- No access control: any note can reference/reply to any other; spam replies are a moderation problem (cf. NIP-13 PoW, NIP-36 content warnings).

## Interoperability notes
- Universal: kind 1 is the core social note (all clients/relays/SDKs).
- NIP-22 supersedes kind-1 replies for non-kind-1 targets. NIP-18 defines quote-repost `q` tags used here. NIP-27 governs inline `nostr:` mentions. Deprecated NIP-08 (mentions) replaced by NIP-27.

## Example
```json
{
  "kind": 1,
  "content": "Agreed, great point nostr:note1xyz...",
  "tags": [
    ["e", "<root-id>", "wss://relay.example", "root", "<root-author-pubkey>"],
    ["e", "<parent-id>", "wss://relay.example", "reply", "<parent-author-pubkey>"],
    ["p", "<root-author-pubkey>"],
    ["p", "<parent-author-pubkey>"]
  ]
}
```
(constructed example adapted from spec rules)

## Open questions / uncertainties
- How clients should reconcile old positional events encountered in the wild is left to implementers.
- No explicit rule on how many `p` tags may accumulate in deep threads (unbounded growth in practice).
