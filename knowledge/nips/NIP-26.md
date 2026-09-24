# NIP-26 — Delegated Event Signing

Source: https://github.com/nostr-protocol/nips/blob/master/26.md
Retrieved: 2026-09-23
Status: `draft` `unrecommended` `optional` `relay`; top-of-file warning: "unrecommended: adds unnecessary burden for little gain". README also marks it unrecommended.
Confidence: HIGH (spec-read)

## Purpose
Allow events to be signed by a delegatee keypair on behalf of a delegator's ("root") pubkey — e.g. keep the root key in cold storage while authorizing per-client hot keys to publish for it.

## Event kinds
none defined (the `delegation` tag can appear on any event; conditions restrict by `kind`)

## Tags defined/used
- `["delegation", <delegator pubkey>, <conditions query string>, <delegation token>]`

## Content format
- **Delegation token**: 64-byte Schnorr signature by the delegator over the sha256 hash of the string `nostr:delegation:<delegatee pubkey>:<conditions query string>`.
- **Conditions query string** — fields and operators:
  - `kind` — `=${KIND_NUMBER}`: delegatee may only sign events of this kind.
  - `created_at` — `<${TIMESTAMP}` (only events created *before*) and `>${TIMESTAMP}` (only events created *after*).
  - Multiple conditions, including repeated fields, combined with `&`. Valid examples: `kind=1&created_at<1675721813`, `kind=0&kind=1&created_at>1675721813`, `kind=1&created_at>1674777689&created_at<1675721813`.
- The event's `pubkey` is the delegatee's; clients display the event as if published by the delegator.

## Semantics & rules
- Event is a valid delegation iff the event satisfies all conditions AND the token verifies against the exact conditions string embedded in the tag (tamper-evident binding).
- Advisory best practices: always include a `created_at>` "after" condition ≈ now (prevents backdating historic notes) and a bounded `created_at<` (unbounded delegations ≈ handing over the root key).
- Relays SHOULD answer `["REQ","",{"authors":["A"]}]` by querying both `pubkey` and the `delegation` tag value; relays SHOULD let the delegator delete delegatee-published events.

## Security & privacy notes
- Delegation tokens are bearer instruments: anyone holding a token + delegatee key can publish within conditions; there is no revocation mechanism other than time-bounding and relay-level deletion cooperation.
- `created_at` is author-chosen, so condition windows only limit, not prevent, misuse; a leaked delegatee key + token is forge-proof within its window.
- Why `unrecommended`: per the header warning it "adds unnecessary burden for little gain" — extra relay validation logic (token verification, dual author indexing, special delete rules) and client display complexity, while remote signing (NIP-46) achieves cold-storage-style key isolation without relay changes.

## Interoperability notes
- Requires relay support for dual `authors` indexing and delegator deletion; client support for displaying delegatee events under the delegator identity.
- NIP-46 remote signing is the modern replacement for the cold-root-key use case.

## Example
Real spec example: delegator pubkey `8e0d3d3e…25dd`, delegatee `477318cf…1396`, delegation string `nostr:delegation:477318cf…:kind=1&created_at>1674834236&created_at<1677426236`, token `6f44d7fe…5f524`; the delegatee then publishes a kind-1 "Hello, world!" event carrying the full `delegation` tag.

## Open questions / uncertainties
- No standard for token distribution to the delegatee (out-of-band assumption).
- Interaction between delegation and NIP-09 deletion across relays that don't index the tag is underspecified.
