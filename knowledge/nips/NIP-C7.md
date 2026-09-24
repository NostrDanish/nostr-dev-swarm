# NIP-C7 — Chats

Source: https://github.com/nostr-protocol/nips/blob/master/C7.md
Retrieved: 2026-09-23
Status: `draft` `optional` (no unrecommended mark)
Confidence: HIGH (spec-read)

## Purpose
Minimal public chat message format: kind `9` events forming an ordered stream ("chat view"), with replies via quoting rather than threading.

## Event kinds
- `9` — chat message (regular kind).

## Tags defined/used
- `q` (NIP-18 quote tag): `["q", <event-id>, <relay-url>, <pubkey>]` — a reply to a kind 9 is another kind 9 quoting the parent.
- Other content kinds MAY be quoted inside kind 9 following NIP-18.

## Content format
`.content` = plain message text; quoted references may appear inline as `nostr:nevent1...`.

## Semantics & rules
- Clients rendering a chat view MUST fetch **only** kind-9 events "in order to prevent missing context across implementations" — a strict interop rule keeping the stream uniform.
- No rooms/channels are defined by this NIP itself; the stream is just ordered kind 9.

## Security & privacy notes
- Fully public and signed; no privacy expectations. Quoting-based replies mean reply structure is soft (quote can be omitted/forged context), unlike strict threading.

## Interoperability notes
- Reuses NIP-18 quoting; kind 9 is also the recommended inner event kind for NIP-EE MLS group application messages, giving it a second life inside encrypted groups.
- Distinct from NIP-28 (kind 40-44 channel chat) and NIP-C7's simplicity is its selling point.

## Example
Real spec example:
```json
{ "kind": 9, "content": "GM", "tags": [] }
```
Reply:
```json
{ "kind": 9, "content": "nostr:nevent1...\nyes",
  "tags": [["q", "<event-id>", "<relay-url>", "<pubkey>"]] }
```

## Open questions / uncertainties
- Without a scope tag (room/relay/geohash), what defines "a chat" beyond relay choice is unspecified here.
- Fetch-only-kind-9 rule conflicts with quoting other kinds (clients still need those quoted events from somewhere).
