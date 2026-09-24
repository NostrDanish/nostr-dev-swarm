# NIP-27 — Text Note References

Source: https://github.com/nostr-protocol/nips/blob/master/27.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally; README marks NIP-08 unrecommended "deprecated in favor of NIP-27")
Confidence: HIGH (spec-read)

## Purpose
Standardizes how clients embed and render inline references to other events and profiles inside the `.content` of any text-bearing event (e.g. kinds 1 and 30023) using NIP-21 `nostr:...` codes.

## Event kinds
Applies to any event kind with readable text content (spec names kinds 1 and 30023).

## Tags defined/used
- `p` (optional): may be added for mentioned profiles when the author wants them NOTIFIED.
- `q` (optional, per NIP-18): quote tags `["q", "<event-id or address>", "<relay-url>", "<pubkey>"]` when the author wants the referenced event to treat the mention as a quote/reply-recognition.
- (Implicitly) `e` tags may be omitted deliberately if the mention should NOT appear among replies.

## Content format
Mentions are inline `nostr:` + NIP-19 bech32 codes (`nprofile`, `npub`, `nevent`, `note`, `naddr`) embedded directly in the text.

## Semantics & rules
- Writing clients SHOULD insert mentions as NIP-21 codes inside `.content` (e.g. autocomplete `@name` → `nostr:nprofile1...`).
- Including NIP-18 `q` tags for references is OPTIONAL — do it when the mentioned profile should be notified or the reference should register as a quote.
- Reading clients MAY do any context augmentation: replace the bech32 URL with `@name`, link internally, link to a web client, or show a preview box of the referenced event.
- Clients may let users mention WITHOUT notifying (omit `p` tag) or reference WITHOUT appearing in replies (omit `e` tag) — deliberate non-notification is an intended feature.
- Kind-1-only clients seeing e.g. a kind-30023 `naddr` reference may link out to a hardcoded webapp that can display it.

## Security & privacy notes
- Mention notifications (`p` tags) can be used for spam/harassment; clients need mention filtering.
- Decoding arbitrary relay hints from `nprofile`/`nevent` codes can leak reader IP to attacker-controlled relays when auto-fetching previews.

## Interoperability notes
- Supersedes deprecated NIP-08. Universal in modern clients for `@`-mentions. Ties together NIP-19 (encodings), NIP-21 (URI scheme), NIP-18 (`q` tags).

## Example
```json
{
  "content": "hello nostr:nprofile1qqszclxx9f5haga8sfjjrulaxncvkfekj097t6f3pu65f86rvg49ehqj6f9dh",
  "created_at": 1679790774,
  "id": "f39e9b451a73d62abc5016cffdd294b1a904e2f34536a208874fe5e22bbd47cf",
  "kind": 1,
  "pubkey": "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
  "sig": "f8c8bab1b90c...43f4d",
  "tags": [["p", "2c7cc62a697ea3a7826521f3fd34f0cb273693cbe5e9310f35449f43622a5cdc"]]
}
```
(from spec; sig truncated)

## Open questions / uncertainties
- No canonical rule for whether `npub` vs `nprofile` is preferred for mentions (spec allows both).
- Notification behavior without `p` tags depends on relays indexing content — not guaranteed.
