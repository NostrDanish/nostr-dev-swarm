# NIP-88 — Polls

Source: https://github.com/nostr-protocol/nips/blob/master/88.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
Poll scheme on Nostr: poll definition, votes, counting rules, and result curation.

## Event kinds
- `1068` — **Poll** (regular). `content` = poll label/question.
- `1018` — **Poll response** (regular). Votes.

## Tags defined/used
Poll (1068):
- `option` — `["option", "<OptionId: alphanumeric>", "<label>"]`, repeated.
- `relay` — one or more relays where respondents are expected to respond.
- `polltype` — `singlechoice` (DEFAULT if absent) or `multiplechoice`.
- `endsAt` — unix timestamp when poll ends.

Response (1018):
- `e` — poll event id.
- `response` — `["response", "<optionId>"]`, one or more.
- Responses are meant to be published to the relays named in the poll event.

## Content format
Poll: label text. Response: empty in example.

## Semantics & rules
- **Poll type handling**: singlechoice → only the FIRST `response` tag counts; multiplechoice → the first response tag pointing to EACH option id counts (order-insensitive).
- **Counting**: fetch kind 1018 from poll-specified relays (`#e` filter, `until` = poll expiration); enforce one vote per pubkey — for multiple events by the same pubkey, only the one with the largest `created_at` within poll limits counts.
- **Relay advice**: poll authors should use relays that reject backdated events and do NOT honor kind-5 deletion requests for vote events, preserving result integrity after poll close.
- **Curation**: clients may tally only votes from a kind 30000 follow set, or apply PoW / Web-of-Trust scores for result filtering.

## Security & privacy notes
- Votes are public and pseudonymous; no anonymity.
- Integrity relies on relay behavior (no backdating, no deletes) — inherently soft; tallying rules are client-side conventions.
- Late/latest-vote-wins rule allows vote changing until `endsAt`.

## Interoperability notes
- NIP-09/kind 5 deletion semantics (relays advised to ignore for votes), NIP-51 kind 30000 follow sets for curated tallies, NIP-13 PoW and WoT for filtering.

## Example
Real spec poll:
```json
{
  "content": "Pineapple on pizza",
  "kind": 1068,
  "tags": [
    ["option", "qj518h583", "Yay"],
    ["option", "gga6cdnqj", "Nay"],
    ["relay", "<relay url1>"],
    ["polltype", "singlechoice"],
    ["endsAt", "<unix timestamp>"]
  ]
}
```
Response:
```json
{"kind": 1018, "tags": [["e", "<poll-id>"], ["response", "gga6cdnqj"], ["response", "m3agjsdq1"]]}
```

## Open questions / uncertainties
- No enforcement mechanism for relay behavior — results are advisory.
- Tie-breaking between identical timestamps not specified.
