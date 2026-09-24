# NIP-67 — EOSE Completeness Hint

Source: https://github.com/nostr-protocol/nips/blob/master/67.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README
Confidence: HIGH (spec-read)

## Purpose
Fixes the ambiguity of NIP-01 `EOSE`: it marks the stored/live boundary but not whether the relay **withheld** stored events due to its own internal cap. Legacy client heuristics (compare received count to requested `limit`) fail two ways: (1) relay cap < client limit ⇒ client wrongly concludes completeness and silently misses data; (2) match count == cap ⇒ client must issue a wasted extra `REQ` to see zero results. NIP-67 appends an optional third element to `EOSE` carrying completeness hints.

## Event kinds
None — extends the relay→client `EOSE` message.

## Tags defined/used
None.

## Content format
```
["EOSE", <subscription_id>, [<hint>, ...]]
```
Defined hints (array may carry several, may be empty):
- `"finish"` — relay has sent **every** stored event matching the filters; client SHOULD NOT paginate further.
- `"more"` — relay holds more matching stored events than sent; client SHOULD paginate. Sending it is optional (detecting "more exists" isn't cheap on every backend).
- `"auth"` — more events may be available after NIP-42 `AUTH`. Relay MUST send the `AUTH` challenge message **before** the `EOSE` containing `"auth"`.

## Semantics & rules
- **Asymmetry principle**: presence of a hint is definitive; absence is not. No third element, or neither `finish` nor `more` ⇒ client SHOULD paginate with `until = oldest received event's created_at` as before.
- Clients MUST ignore unknown hint values without error (forward-compat); relays not implementing the NIP keep sending 2-element EOSE.
- Hints apply only to **stored** events; real-time streaming continues per NIP-01 until `CLOSE`/`CLOSED`.
- **created_at ties**: when not sending `"finish"`, relays SHOULD advance the cursor so all events sharing the boundary `created_at` are included in one response (avoids clients missing tie-events when paginating by `until`); emit `"finish"` only when no older events remain.
- Advertisement: relays SHOULD list `67` in NIP-11 `supported_nips`.
- Backward compatible because EOSE is indexed positionally and trailing array elements are ignored by existing parsers.

## Security & privacy notes
- A malicious relay can lie with `"finish"` to censor silently — but this is equivalent to the pre-existing trust model (relays could always withhold events); the hint adds no new trust requirement.
- `"auth"` hint reveals that gated content exists for the queried filter — minor metadata leak, inherent to the feature.

## Interoperability notes
- Extends NIP-01 EOSE; composes with NIP-42 AUTH (ordering requirement: AUTH challenge precedes `"auth"`-hinted EOSE).
- Very recent NIP; no implementation claims found in strfry/nostr-rs-relay/nostream/khatru READMEs at retrieval time.

## Examples
From spec:
```
["REQ", "sub2", {"ids": ["abcd..."]}]
["EVENT", "sub2", {...}]
["EOSE", "sub2", ["finish"]]
```
```
["EOSE", "sub2b", ["more"]]            // after 300 capped events
["AUTH", "challenge..."]
["EOSE", "sub4", ["auth", "finish"]]   // hints may combine
```

## Open questions / uncertainties
- `"more"` is advisory-optional, so clients can never fully rely on its absence — pagination heuristics remain necessary as fallback.
- No guidance on interaction with `limit` in filters (does `"finish"` mean "everything matching filter" or "everything up to client's limit"? The examples imply the relay's cap, client `limit` interplay is implicit).
- Adoption unknown at retrieval time.
