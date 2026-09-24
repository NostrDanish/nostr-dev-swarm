# NIP-28 — Public Chat

Source: https://github.com/nostr-protocol/nips/blob/master/28.md
Retrieved: 2026-09-23
Status: `draft` `unrecommended` `optional` — README marks it **unrecommended**: "try NIP-29 instead"; in-file warning banner says the same.
Confidence: HIGH (spec-read)

## Purpose
Defines public chat channels (Telegram-style) with client-side moderation: channel creation, metadata updates, channel messages, hide-message, and mute-user. It imposes **no additional requirements on relays** — moderation is purely client-centric; clients decide what to display.

## Event kinds
| kind | class | role |
|---|---|---|
| 40 | regular | channel create |
| 41 | regular (de facto replaceable) | channel metadata update |
| 42 | regular | channel message |
| 43 | regular | hide message |
| 44 | regular | mute user |

Kinds 40–44 reserved. Kind 41 is formally in the "regular" range but the spec says only the most recent kind 41 per `e` tag value MAY be available — i.e. treated like a replaceable update keyed to the kind-40 event id.

## Tags defined/used
- `e` tags per **NIP-10** with markers `"root"` / `"reply"` and a relay URL recommendation (kinds 41, 42; kind 43 uses a plain `e` tag to the hidden kind-42 id).
- `p` tags per NIP-10 in replies (kind 42); plain `p` tag of the muted pubkey in kind 44.
- `t` tags on kind 41 to set searchable/filterable channel **category names** (up to client; spec example shows 3).

## Content format
- Kind 40: JSON object in content SHOULD include channel metadata: `name`, `about`, `picture`, `relays` (array of relay URLs to download from / broadcast to).
- Kind 41: same JSON metadata object (`name`/`about`/`picture`/`relays`); clients MAY add extra fields.
- Kind 42: plain string message.
- Kinds 43/44: optional JSON with `reason` (e.g. `{"reason": "Dick pic"}`).

## Semantics & rules
- Clients SHOULD ignore kind 41 metadata updates from pubkeys other than the kind 40 author's pubkey.
- Clients SHOULD hide kind-42 events matching a kind-43 (by event id) or kind-44 (by author pubkey) **issued by the viewing user**; clients MAY extend hiding to other users.
- Relay recommendations: clients SHOULD use relay URLs from channel metadata events, but MAY use any relay.
- No relay-side behavior is defined at all — no replaceability enforcement, no deletion; moderation state is just events clients interpret.

## Security & privacy notes
- Everything is public; moderation is advisory. A client that ignores kinds 43/44 sees everything.
- Trust model relies on clients honoring the kind-40 author as the sole metadata setter; a malicious relay could serve stale or attacker-authored kind 41s to naive clients.
- Deprecated status: NIP-29 relay-based groups supersede this with relay-enforced access control.

## Interoperability notes
- Uses NIP-10 marked `e`/`p` tags for threading and relay hints.
- NIP-51 kind `10005` (public chats list) exists for storing a user's channel list.
- Superseded by NIP-29 (README + in-file banner both point to 29). Implemented by strfry and nostr-rs-relay (both list NIP-28 as supported); nostream also lists it.

## Example
Kind 41 metadata update (from spec):
```yaml
{
  "content": "{\"name\": \"Updated Demo Channel\", \"about\": \"Updating a test channel.\", \"picture\": \"https://placekitten.com/201/201\", \"relays\": [\"wss://nos.lol\", \"wss://nostr.mom\"]}",
  "tags": [
    ["e", "<channel_create_event_id>", "<relay-url>", "root"],
    ["t", "<category_name-1>"]
  ]
}
```

## Open questions / uncertainties
- Spec never formally classifies kinds 40–44 as replaceable; kind 41's "only the most recent MAY be available" is a SHOULD-free relay suggestion that most generic relays do not enforce, so clients must pick latest by `created_at`.
- `relays` metadata array semantics (download vs broadcast) left vague.
