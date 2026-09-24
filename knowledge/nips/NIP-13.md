# NIP-13 — Proof of Work

Source: https://github.com/nostr-protocol/nips/blob/master/13.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines a way to generate and interpret Proof of Work (PoW) on nostr notes as spam deterrence. PoW is a bearer proof any relay/client can validate cheaply: difficulty = number of leading zero bits in the NIP-01 event id.

## Event kinds
Any kind can carry PoW; mining is expressed via a tag, not a kind.

## Tags defined/used
- `nonce` (required for mining): `["nonce", <nonce-number>, <target-difficulty>]` — the second entry is iterated while mining; the third SHOULD contain the committed target difficulty.

## Content format
Unchanged — arbitrary event content; PoW attaches to the whole serialized event via its id.

## Semantics & rules
- Difficulty = count of leading zero BITS (not hex digits) of the 32-byte id. Example: id `000000000e9d97a1...` = 36 bits; `002f...` = 10 leading zeroes — remember hex digits ≤ 7 contribute leading zeroes.
- Mining loop: bump the nonce tag's second entry, recompute the id (per NIP-01), repeat until enough leading zero bits. Recommended to also update `created_at` during mining.
- The committed target difficulty (3rd nonce entry) defends against lucky bulk spammers: if a thread requires 40 bits but the note committed to 30, clients can safely reject even if it happens to have 40. Clients MAY reject notes missing a difficulty commitment.
- Validation reference code provided in C and JS (`count_leading_zero_bits` over the 32-byte hash; JS version uses `Math.clz32(nibble) - 28` on first nonzero hex nibble).
- Delegated PoW: since the NIP-01 id does NOT commit to the signature, PoW can be outsourced to providers (useful for mobile/energy-constrained devices).

## Security & privacy notes
- Bearer proof: not tied to identity — a mined event by a spammer's key is still "valid PoW"; it only raises cost, doesn't authenticate.
- Delegation means the pubkey owner did no work; trust in PoW-as-effort-by-author is weakened by design (acknowledged).
- Relays may advertise minimum difficulty (via NIP-11 `limitation` in practice); clients targeting PoW-restricted relays must mine accordingly.
- Replay: an already-mined id is fixed; no malleability beyond normal event semantics.

## Interoperability notes
- Relay-facing (`relay` marker): PoW-gated relays exist; clients like more-speech and various mining tools implement it. NIP-11 relay documents may advertise `min_pow_difficulty`.

## Example
```json
{
  "id": "000006d8c378af1779d2feebc7603a125d99eca0ccf1085959b307f64e5dd358",
  "pubkey": "a48380f4cfcc1ad5378294fcac36439770f9c878dd880ffa94bb74ea54a6f243",
  "created_at": 1651794653,
  "kind": 1,
  "tags": [["nonce", "776797", "20"]],
  "content": "It's just me mining my own business",
  "sig": "284622fc0a...aba977"
}
```
(from spec — mined note with 24 leading zero bits against target 20)

## Open questions / uncertainties
- No standard difficulty scale or UX guidance; what counts as "enough" PoW is relay/policy specific.
- Interaction between delegated PoW and NIP-26 delegation (unrecommended) is unaddressed.
