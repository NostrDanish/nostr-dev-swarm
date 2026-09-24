# NIP-62 — Request to Vanish

Source: https://github.com/nostr-protocol/nips/blob/master/62.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay`; not marked unrecommended in README
Confidence: HIGH (spec-read)

## Purpose
A Nostr-native way for a user to request a **complete reset of a key's fingerprint** — deletion of everything from a pubkey. The spec states this procedure is "legally binding in some jurisdictions," so relays supporting it should truly delete events from their database. Stronger than NIP-09 deletion requests.

## Event kinds
| kind | class | role |
|---|---|---|
| 62 | regular | Request to Vanish — from the pubkey being vanished, scoped by `relay` tags |

## Tags defined/used
- `relay` — REQUIRED, at least one. Value = relay service URL, or the uppercase literal `ALL_RELAYS` for a global request.
- No other tags defined. A NIP-09 kind-5 deletion against a kind-62 event explicitly has **no effect** (no "unrequest vanish").

## Content format
`content` MAY contain a human-readable reason or a legal notice to the relay operator.

## Semantics & rules
Targeted request:
- Relays MUST fully delete all events from `.pubkey` with `created_at` ≤ the request's `created_at`, if their own service URL is tagged. Deletion scope includes NIP-09 deletion events themselves.
- Relays SHOULD also delete all NIP-59 **gift wraps** (kind 1059) that p-tag the pubkey — wiping DMs *sent to* the user.
- Relays MUST ensure deleted events **cannot be re-broadcast** back into the relay (persistent tombstone/blocklist semantics).
- Relays MAY keep the signed kind-62 request itself for bookkeeping.
- **Paid or write-restricted relays MUST honor the request regardless of the user's membership/payment status.**
- Clients SHOULD send the event only to the tagged target relays.

Global request:
- `["relay", "ALL_RELAYS"]` (uppercase) asks every relay to delete everything; clients SHOULD broadcast it as widely as possible.

## Security & privacy notes
- This is the strongest erasure primitive in the NIPs repo: unlike NIP-09 (requests, keepable) and NIP-40 (advisory expiry), NIP-62 uses MUST-language and claims legal force (GDPR-style right to erasure is the obvious motivation).
- Still fundamentally voluntary: nothing forces non-supporting relays or archival third parties to comply; already-copied data persists off-relay.
- Gift-wrap deletion (SHOULD) erases DMs addressed to the user authored by *others* — a notable third-party-data implication.
- Anti-rebroadcast requirement means relays need durable per-pubkey suppression, not one-time deletes.

## Interoperability notes
- Interacts with NIP-09 (kind 5 cannot cancel a vanish), NIP-59 (gift wraps in scope), NIP-40 (different, weaker mechanism).
- nostream README lists NIP-62 as implemented. strfry and nostr-rs-relay READMEs do not list it (strfry ops docs describe manual `strfry delete --filter` by author, an operator-side equivalent).

## Example
From spec:
```yaml
{
  "kind": 62,
  "pubkey": "<32-byte hex pubkey of the event creator>",
  "tags": [["relay", "<relay url>"]],
  "content": "<reason or note>"
}
```
Global:
```yaml
{"kind": 62, "tags": [["relay", "ALL_RELAYS"]], "content": "<reason>"}
```

## Open questions / uncertainties
- "Legally binding" is asserted, not substantiated — actual jurisdictional effect is out of protocol scope.
- How relays MUST prevent re-broadcast (tombstones of deleted ids vs pubkey ban) is unspecified.
- Behavior for events with `created_at` *after* the request is undefined (future posts by the same key presumably allowed unless blocked).
- No mechanism to verify a relay complied.
