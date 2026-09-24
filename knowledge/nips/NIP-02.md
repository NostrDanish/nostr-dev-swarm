# NIP-02 — Follow List

Source: https://github.com/nostr-protocol/nips/blob/master/02.md
Retrieved: 2026-09-23
Status: `final` `optional` (literal header markers; README lists it normally, not unrecommended)
Confidence: HIGH (spec-read)

## Purpose
Defines kind `3`, the "follow list": a replaceable event carrying a list of `p` tags, one per followed/known profile. It doubles as a backup mechanism, a profile-discovery signal, a relay-hint sharing channel, and the basis for a petname (local naming) scheme.

## Event kinds
| kind | class | role |
|------|-------|------|
| 3 | replaceable (kind 3 is explicitly replaceable per NIP-01) | Follow list; one per pubkey, newest overwrites older |

## Tags defined/used
- `p` (required, repeated): `["p", <32-byte hex pubkey>, <main relay URL>, <petname>]` — relay URL may be empty string; petname may be empty or omitted.

## Content format
`.content` is not used (should be `""`). NIP-24 notes a **deprecated** content format: a JSON object `{<relay-url>: {"read": bool, "write": bool}}` — NIP-65 replaces this.

## Semantics & rules
- Every new follow list **overwrites** previous ones, so it MUST contain ALL entries (not just deltas).
- Relays and clients SHOULD delete past follow lists as soon as a new one arrives.
- When adding new follows, clients SHOULD append them to the END of the list to keep chronological order of follows.
- Petname resolution: a petname (4th element of a `p` tag) is a local name. Names can be chained: `~/erin/charlie` resolves one component at a time through successive follow lists. Absolute roots allowed: `~npub1.../erin/charlie`, `~carol@names.com/erin/charlie`.
- Petnames must contain only ASCII letters, numbers, or `_` to qualify for resolution.

## Security & privacy notes
- Follow list is public metadata: reveals a user's social graph; using it for backup leaks contacts to anyone reading the relay.
- Relay URLs embedded in `p` tags leak infrastructure preferences; malicious relay hints could steer clients toward hostile relays.
- Petnames are purely local/trust-based; no global uniqueness guarantees — spoofing risk if clients display petnames from untrusted follow lists.

## Interoperability notes
- Universally implemented (kind 3 is one of the oldest kinds; all major clients and SDKs support it).
- Supersedes the old kind-3 content-based relay list: use NIP-65 (kind 10002) for relay metadata instead.
- NIP-51 "Follow sets" (kind 30000) coexist for multiple/named lists; kind 3 remains THE contact list.

## Example
```json
{
  "kind": 3,
  "tags": [
    ["p", "91cf9..4e5ca", "wss://alicerelay.com/", "alice"],
    ["p", "14aeb..8dad4", "wss://bobrelay.com/nostr", "bob"],
    ["p", "612ae..e610f", "ws://carolrelay.com/ws", "carol"]
  ],
  "content": ""
}
```
(from spec; id/pubkey/sig/created_at omitted)

## Open questions / uncertainties
- Spec says relays SHOULD delete old follow lists but relays technically can't "delete" — behavior relies on replaceable-event semantics of NIP-01.
- Petname chain resolution across untrusted lists has no spam/abuse guidance.
