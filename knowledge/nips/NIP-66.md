# NIP-66 — Relay Liveness Monitoring

Source: https://github.com/nostr-protocol/nips/blob/master/66.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay` (README title: "Relay Discovery and Liveness Monitoring"); not unrecommended
Confidence: HIGH (spec-read)

## Purpose
Standardizes **relay discovery** and **relay monitor announcements**: monitor operators probe relays (NIP-11 docs, websocket round trips, DNS/geo/SSL checks) and publish signed, queryable events describing each relay's characteristics and liveness, so clients can discover and select relays without hardcoded lists.

## Event kinds
| kind | class | role |
|---|---|---|
| 30166 | addressable | Relay Discovery event — one per relay per monitor; `d` = relay's normalized URL |
| 10166 | replaceable | Relay Monitor Announcement — declares a monitor's intent/frequency/checks |

## Tags defined/used
On 30166 (only `d` is required):
- `d` — relay URL, normalized per RFC 3986 §6; for relays not URL-accessible, a hex pubkey MAY be used instead.
- `rtt-open` / `rtt-read` / `rtt-write` — round-trip times in ms for connect, read, write probes.
- `n` — network type, SHOULD be one of `clearnet`, `tor`, `i2p`, `loki`.
- `T` — relay type, PascalCase (e.g. `PrivateInbox`); enumeration tracked in nips issue #1282.
- `N` — supported NIP number (repeat per NIP).
- `R` — requirement flags per NIP-11 `limitations`: `auth`, `writes`, `pow`, `payment`; false values prefixed `!` (e.g. `["R", "!payment"]`).
- `t` — topic. `k` — accepted/unaccepted kinds (`!` prefix for unaccepted). `g` — NIP-52 geohash. `l` — language with ISO-639-1 label (per example).
- Multi-valued attributes MUST be repeated as separate tags (`[["t","cats"],["t","dogs"]]`, not one tag with many values).

On 10166 (all optional metadata):
- `frequency` — seconds between the monitor's publications.
- `timeout` — index 1: test name (`open`, `read`, `write`, `nip11`...), index 2: timeout ms; if test name omitted, applies to all tests. (NOTE: spec text says "Index 1 is the monitor's timeout... Index 2 describes what test", but the example shows `["timeout", "open", "5000"]` — i.e. name first, ms second. See Open questions.)
- `c` — checks performed, lowercase strings: `open`, `read`, `write`, `auth`, `nip11`, `dns`, `geo` (example also uses `ws`, `ssl`).
- `g` — geohash of the monitor.

## Content format
- 30166 `content` MAY carry the stringified JSON of the relay's NIP-11 document (snapshot as observed by the monitor).
- 10166 `content` empty in the example.

## Semantics & rules
- Monitors derive data from the relay's NIP-11 doc and/or active probing; **observed values MAY deliberately contradict advertised NIP-11 values** if the relay implements a different policy than it advertises — that's the point.
- Monitors SHOULD also publish kind 0 (profile) and kind 10002 (NIP-65 relay list) so they're discoverable/trustable entities.
- 10166 is optional — only for monitors publishing at "regular and predictable frequency."
- Risk mitigation (load-bearing client rules):
  - Clients MUST NOT require 30166 data to function; its absence MUST NOT block relay connections.
  - Monitors can be wrong or malicious; clients SHOULD NOT trust a single source — use web-of-trust filtering, multiple monitors, and discard filter results that would eliminate an "unreasonable proportion" of relays.

## Security & privacy notes
- Trust problem is explicit: a malicious monitor can publish erroneous 30166s to steer users away from (or toward) relays. Hence multi-source corroboration requirements.
- Content-embedded NIP-11 docs can go stale; check `created_at`.
- Monitor pubkey reputation is the only authenticity anchor — no proof-of-measurement.

## Interoperability notes
- Builds on NIP-11 (source data + `limitations` keys for `R`), NIP-52 (geohash `g`), NIP-65 kind 10002 (monitor's own relay list), NIP-19-style addressing of 30166 by `d`=URL.
- This is monitor-side infrastructure; no relay-software support required. Deployed ecosystem: relay monitor/crawler projects (e.g. nostr.watch lineage) produce 30166/10166 events.

## Example
From spec (30166):
```json
{
  "kind": 30166,
  "pubkey": "<monitor's pubkey>",
  "content": "<optional nip 11 document>",
  "tags": [
    ["d", "wss://some.relay/"],
    ["n", "clearnet"],
    ["N", "40"], ["N", "33"],
    ["R", "!payment"], ["R", "auth"],
    ["g", "ww8p1r4t8"],
    ["l", "en", "ISO-639-1"],
    ["t", "nsfw"],
    ["rtt-open", "234"]
  ]
}
```

## Open questions / uncertainties
- `timeout` tag argument order contradicts itself: prose says index 1 = ms, index 2 = test name; example uses `["timeout", "open", "5000"]` (name then ms). Implementations must pick; the example form appears dominant in the wild.
- Relay-type vocabulary (`T`) deferred to a GitHub issue, not codified.
- No defined freshness/attestation scheme for measurements.
