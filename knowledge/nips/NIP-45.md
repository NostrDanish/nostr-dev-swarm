# NIP-45 — Event Counts

Source: https://github.com/nostr-protocol/nips/blob/master/45.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay` (README titles it "Counting results"); not unrecommended
Confidence: HIGH (spec-read)

## Purpose
Adds a `COUNT` verb so clients can get event counts (followers, reactions, replies...) without downloading thousands of events — avoiding second-layer indexers that erode decentralization. Includes a HyperLogLog (HLL) extension so counts from multiple relays can be **merged** without double counting.

## Event kinds
No new kinds. Defines a new client→relay and relay→client message type (registered in the README message tables).

## Tags defined/used
No tags. Filter-based; the HLL `offset` derivation keys off the filter's **first tag attribute** (single `#<tag>` entry with a single item).

## Content format
Protocol messages:
```
["COUNT", <query_id>, <filters JSON>...]          // request, NIP-01 REQ-style filters, multiple filters OR'd into ONE aggregated count
["COUNT", <query_id>, {"count": <integer>}]       // response
["COUNT", <query_id>, {"count": <n>, "approximate": true}]
["COUNT", <subscription_id>, {"count": <n>, "hll": "<hex>"}]
["CLOSED", <query_id>, "auth-required: ..."]      // refusal — relay MUST use CLOSED when refusing
```
`hll` = 256 uint8 registers concatenated, hex-encoded → always a 512-character hex string.

## Semantics & rules
- Multiple filters are OR'd and aggregated into a single count.
- Relays MAY return probabilistic counts; if so they MAY include `"approximate": true|false`.
- Refusal MUST be a `CLOSED` message (e.g. counting other people's DMs returns `auth-required: cannot count other people's DMs`).
- **HLL algorithm (relay side, the only part needed for interop)**:
  1. If filter eligible, compute deterministic `offset`;
  2. 256 registers init 0;
  3. For each counted event: register index `ri` = byte at position `offset` of the event's **pubkey**; count leading zero bits starting at position `offset+1`, +1; store if bigger than current register.
- **`offset` computation**: take the filter's first `#`-tag attribute → its first item → get a 64-hex string (event id / pubkey hex as-is; address `<kind>:<pubkey>:<d>` → use the pubkey part; anything else → sha256 hex) → take the hex character at position 32 → parse as base-16 → **add 8**.
- Merging client-side = per-register max across relays; estimate from merged registers (implementation-specific estimator).
- Determinism rationale: lets relays **cache/precompute** HLLs per target id/pubkey without recounting the DB.
- **Canonical "common filters"** relays may precompute: reactions `{#e:[id], kinds:[7]}`, reposts `{#e:[id], kinds:[6]}`, quotes `{#q:[id], kinds:[1,1111]}`, replies `{#e:[id], kinds:[1]}`, comments `{#E:[id], kinds:[1111]}`, followers `{#p:[pk], kinds:[3]}` — always exactly one tag attribute with one item.
- Clients can merge relay HLLs with locally computed HLLs from raw events; recommended to persist local HLL + last-read date.

## Security & privacy notes
- Spec documents a grinding attack: mine pubkeys with many leading zero bits at the HLL sampling position to inflate one's own count (one key per target). Mitigation is the same as for fake followers: only count from relays with admission filtering, not open-write relays.
- Counts can leak existence/volume info (hence relays may refuse e.g. DM counts via CLOSED/auth-required).

## Interoperability notes
- Filters are NIP-01 format; refusal uses NIP-01 `CLOSED` with NIP-42-style prefixes.
- Supported by strfry and nostream; nostr-rs-relay README does **not** list 45.

## Example
From spec — follower count with HLL:
```
["COUNT", <subscription_id>, {"kinds": [3], "#p": [<pubkey>]}]
["COUNT", <subscription_id>, {"count": 16578, "hll": "06070705..."}]  // 512 hex chars
```

## Open questions / uncertainties
- Behavior for filters without a single tag attribute is explicitly undefined ("no use case justifies HLL there yet").
- Estimator formula deliberately left out of the spec ("check some implementation source code") — estimates may differ across implementations.
- `approximate` and `hll` interplay (exact count + HLL estimate) is under-specified.
