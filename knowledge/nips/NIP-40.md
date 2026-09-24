# NIP-40 — Expiration Timestamp

Source: https://github.com/nostr-protocol/nips/blob/master/40.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay`; not marked unrecommended in README
Confidence: HIGH (spec-read)

## Purpose
Lets an author declare a unix timestamp at which an event should be considered expired (by relays and clients) and deleted by relays. Use cases: temporary announcements, limited-time offers.

## Event kinds
No new kinds. The `expiration` tag applies to any kind. Explicitly noted: an expiration timestamp **does not affect storage of ephemeral events** (20000–29999), which relays must not store anyway.

## Tags defined/used
```
tag: expiration
values:
 - [UNIX timestamp in seconds]: required
```
Timestamp is in the same seconds format as `created_at`.

## Content format
Unchanged — any normal event content; expiration is purely a tag-level annotation.

## Semantics & rules
Client behavior:
- Clients SHOULD consult `supported_nips` in NIP-11 and SHOULD NOT send expiration-tagged events to relays that do not advertise this NIP.
- Clients SHOULD ignore (not display) events that have expired.

Relay behavior (note the asymmetry — all soft):
- Relays MAY NOT delete expired messages immediately and MAY persist them indefinitely.
- Relays SHOULD NOT serve expired events to clients, even if still stored.
- Relays SHOULD drop newly published events that are already expired.
- No requirement to reject future-dated expiration or to garbage-collect on a schedule.

## Security & privacy notes
- Spec carries an explicit **Warning**: events are publicly accessible the whole time they exist; third parties may download and archive them. Expiration is **not a security/privacy feature** — don't use it to protect conversations.
- Contrast with NIP-62 (Request to Vanish), which mandates hard deletion with (claimed) legal force; NIP-40 is advisory garbage collection.

## Interoperability notes
- Discovery via NIP-11 `supported_nips`.
- Widely implemented: strfry, nostr-rs-relay, and nostream all list NIP-40 as supported.

## Example
From spec:
```json
{
  "pubkey": "<pub-key>",
  "created_at": 1000000000,
  "kind": 1,
  "tags": [["expiration", "1600000000"]],
  "content": "This message will expire at the specified timestamp and be deleted by relays.\n",
  "id": "<event-id>"
}
```

## Open questions / uncertainties
- No defined behavior when `expiration` < `created_at` or unreasonably near/far — relay policy.
- Interaction with NIP-09 deletion is unspecified (both can independently target an event).
- Because deletion timing is unspecified, clients cannot assume an expired event is gone; they must filter locally.
