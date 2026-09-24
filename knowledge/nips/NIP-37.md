# NIP-37 — Draft Wraps

Source: https://github.com/nostr-protocol/nips/blob/master/37.md
Retrieved: 2026-09-23
Status: `draft` `optional` (no unrecommended mark)
Confidence: HIGH (spec-read)

## Purpose
Encrypted, private storage of unsigned draft events (any kind) on relays, plus revision checkpoints and a relay list for private content.

## Event kinds
- `31234` — draft wrap (addressable, `d` tag); encrypted storage for an unsigned draft event.
- `1234` — checkpoint; revision history belonging to a parent kind-31234 draft.
- `10013` — relay list for private content (replaceable list of relays preferred for storing private events).

## Tags defined/used
- kind 31234: `d` (identifier), `k` (kind of the draft event — required), `expiration` (NIP-40, recommended).
- kind 1234: `a` = `31234:<pubkey>:<identifier>` pointing at the parent draft.
- kind 10013: public tags empty; `relay` URLs carried in encrypted private tags.

## Content format
- kind 31234/1234 `.content` = `nip44Encrypt(JSON.stringify(draft_event))` — the draft is JSON-stringified and NIP-44-encrypted to the signer's own public key.
- kind 10013 `.content` = `nip44Encrypt(JSON.stringify([["relay","wss://myrelay.mydomain.com"]]))` — private tags encrypted to the signer's keys.
- A blanked `.content` on kind 31234 signals the draft has been deleted.

## Semantics & rules
- Clients SHOULD publish kind 31234 to the relays listed in the author's kind 10013.
- Clients MUST publish kind 10013 to the author's NIP-65 `write` relays.
- Private-storage relays SHOULD be NIP-42-authed and only allow downloads of events signed by the authed user.
- NIP-40 `expiration` recommended on drafts (e.g. `"expiration", "now + 90 days"`).

## Security & privacy notes
- Drafts are encrypted to self with NIP-44, so relay operators only see ciphertext + outer metadata (kind, d-tag identifier, timestamps) — the `d` identifier and `k` tag leak what kind of content is being drafted and its stable ID.
- Checkpoints (kind 1234) accumulate encrypted revision history; each checkpoint is a ciphertext blob that persists until deleted.
- The whole scheme depends on relays honoring auth-gated private storage; a non-authed relay holding 31234 events exposes ciphertext to anyone.

## Interoperability notes
- Depends on NIP-44 (encryption), NIP-40 (expiration), NIP-42 (auth), NIP-65 (relay lists), NIP-33 addressing (`a` tags).
- Draft events are unsigned until actually published as their real kind.

## Example
Real spec example (kind 31234):
```js
{
  "kind": 31234,
  "tags": [
    ["d", "<identifier>"],
    ["k", "<kind of the draft event>"],
    ["expiration", "now + 90 days"]
  ],
  "content": nip44Encrypt(JSON.stringify(draft_event))
}
```

## Open questions / uncertainties
- `expiration` value `"now + 90 days"` is a human-readable placeholder, not a numeric timestamp — implementers must substitute a real NIP-40 unix timestamp.
- No conflict-resolution rule for concurrent edits to the same `d` identifier from multiple devices.
