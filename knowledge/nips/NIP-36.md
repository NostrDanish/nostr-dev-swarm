# NIP-36 — Sensitive Content / Content Warning

Source: https://github.com/nostr-protocol/nips/blob/master/36.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines the `content-warning` tag so authors can mark an event's content as requiring reader approval before display; clients hide the content until the user acts. Optionally integrates with NIP-32 labels for qualified, queryable warning taxonomies.

## Event kinds
Applies to any content-bearing kind (spec example uses kind 1).

## Tags defined/used
- `content-warning` (optional): `["content-warning", <optional reason>]` — presence alone marks content as sensitive; reason string is optional.
- `L`/`l` (optional, per NIP-32): label namespace/value pairs — e.g. `["L", "content-warning"]` + `["l", "<reason>", "content-warning"]`, or external ontologies like `["L", "social.nos.ontology"]` + `["l", "NS-nud", "social.nos.ontology"]` for further qualification and querying.

## Content format
Unchanged; the content is what gets hidden behind the warning.

## Semantics & rules
- Clients can hide content until the user explicitly acts (click-to-reveal).
- The reason is a free-form optional string in the `content-warning` tag's second position.
- NIP-32 `L`/`l` tags MAY accompany the warning for structured labeling/querying (namespace `content-warning` or other ontologies).

## Security & privacy notes
- Self-declared: nothing forces bad actors to tag sensitive content; clients still need reporting (NIP-56) and moderation.
- The reason string itself is visible metadata — it can leak hints about the hidden content.
- Readers' reveal actions are client-local and not recorded on relays (no privacy leak from revealing).

## Interoperability notes
- Widely implemented in mainstream clients (Damus, Amethyst, Primal...). Composes with NIP-32 labeling and NIP-56 reporting for moderation stacks.

## Example
```json
{
  "pubkey": "<pub-key>",
  "created_at": 1000000000,
  "kind": 1,
  "tags": [
    ["t", "hastag"],
    ["L", "content-warning"],
    ["l", "reason", "content-warning"],
    ["L", "social.nos.ontology"],
    ["l", "NS-nud", "social.nos.ontology"],
    ["content-warning", "<optional reason>"]
  ],
  "content": "sensitive content with #hastag\n",
  "id": "<event-id>"
}
```
(from spec)

## Open questions / uncertainties
- No standardized vocabulary of reason strings (free-form); the `social.nos.ontology` values are illustrative, not enumerated here.
- Behavior for media-only events (no text content) is unspecified.
