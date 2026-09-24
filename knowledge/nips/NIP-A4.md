# NIP-A4 — Public Messages

Source: https://github.com/nostr-protocol/nips/blob/master/A4.md
Retrieved: 2026-09-23
Status: `draft` `optional` (no unrecommended mark)
Confidence: HIGH (spec-read)

## Purpose
Kind `24`: a simple plaintext message addressed to one or more Nostr users, designed to be shown and replied to from notification screens — chat-like UX without any chat-history machinery.

## Event kinds
- `24` — public message (regular kind; signed).

## Tags defined/used
- `p` (one or more receivers, with optional relay URL).
- `e` tags **MUST NOT** be used — no threads, roots, or chatrooms exist.
- Optional integrations: `q` (NIP-18 quote repost), `expiration` (NIP-40, recommended), `imeta` (NIP-92, SHOULD for image/video links).

## Content format
`.content` = the message in plain text.

## Semantics & rules
- Messages MUST be sent to the NIP-65 **inbox relays of each receiver** and the **outbox relay of the sender**.
- Designed for notification screens; clients can support it without tracking chat history. Messages "can start and continue without any syntactic connection to each other."
- Not designed for feed display, but fully public — anyone can see and even reply to messages not meant for them.
- NIP-25 reactions to kind 24 MUST add `k` = `24`; NIP-57 zaps MUST include `k` = `24`; NIP-21 `nevent1` links to kind 24 MUST include `kind: 24` (other kinds not expected to render natively).

## Security & privacy notes
- **Zero privacy**: spec warns "There MUST be no expectation of privacy in this kind. It is just a public reply, but without a root note." Signed and meant for public consumption.
- Explicitly distinguished from kind-14 rumors in NIP-17 gift-wrapped DMs — confusing the two would leak private messages publicly.
- Ephemerality via NIP-40 expiration recommended since context-free messages age poorly.

## Interoperability notes
- Plays with NIP-18 (q), NIP-21/19 (nevent kind hint), NIP-25, NIP-40, NIP-57, NIP-65 (inbox/outbox routing), NIP-92 (imeta).
- Complements rather than replaces NIP-17 private DMs.

## Example
Real spec example:
```yaml
{
  "pubkey": "<sender-pubkey>",
  "kind": 24,
  "tags": [["p", "<receiver>", "<relay-url>"]],
  "content": "<message-in-plain-text>"
}
```

## Open questions / uncertainties
- Multiple receivers with differing inbox relay sets may cause partial delivery; no delivery confirmation.
- Without threading, client-side grouping heuristics (sender/receiver/time) are implementation-defined.
