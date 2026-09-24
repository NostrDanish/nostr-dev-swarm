# NIP-69 — Peer-to-peer Order events

Source: https://github.com/nostr-protocol/nips/blob/master/69.md
Retrieved: 2026-09-23
Status: `draft` `optional` (not unrecommended)
Confidence: HIGH (spec-read)

## Purpose
Shared, platform-neutral order book for P2P Bitcoin↔fiat exchanges: one big liquidity pool across platforms (Mostro, lnp2pBot, Robosats, Peach) to fight liquidity fragmentation.

## Event kinds
- `38383` — addressable (parameterized replaceable): P2P order. Content empty; everything in tags.

## Tags defined/used
Mandatory: `d` (order UUID), `k` (`sell`|`buy`), `f` (ISO 4217 fiat currency), `s` (status: `pending`|`canceled`|`in-progress`|`success`|`expired`), `amt` (sats; `0` = amount resolved from public price API after taker accepts), `fa` (fiat amount; two values = range order min/max), `pm` (payment method(s), comma-separated), `premium` (%), `network` (`mainnet`/`testnet`/`signet`...), `layer` (`onchain`/`lightning`/`liquid`...), `expires_at` (pending-status expiry → SHOULD become `expired`), `expiration` (NIP-40 relay deletion time), `y` (platform id), `z` (document type, `order`).
Optional: `source` (URL to order), `rating` (JSON maker rating — calculation platform-defined), `name` (maker name), `g` (geohash for face-to-face), `bond` (security deposit amount both parties pay).

## Content format
`.content` is empty string in the reference event; all data in tags. `rating` tag value is stringified JSON `{total_reviews, total_rating, last_rating, max_rate, min_rate}`.

## Semantics & rules
- Addressable: maker updates status by republishing same `d` (e.g., pending → in-progress → success/canceled/expired).
- After `expires_at`, status SHOULD change to `expired`; after `expiration`, relay SHOULD delete (NIP-40).
- `amt = 0` signals market-price orders: fiat amount fixed, sats computed from a public API at trade time.
- The NIP defines **announcement only** — the actual trade protocol (escrow, bonds, dispute) is platform-specific (see Mostro protocol spec); counterparties coordinate via the platform in `y`/`source`.

## Security & privacy notes
- **Funds at risk**: the NIP itself moves no money, but it is an adversarial bulletin board:
  - **Oracle risk**: `amt: 0` orders depend on an unspecified "public API" for the exchange rate — manipulated or divergent price sources create dispute/exploitation surface; rate source and timestamp are not pinned in the event.
  - **Forged orders/impersonation**: any npub can publish any order; `name`, `rating` are self-asserted and trivially fakeable — trust must come from the platform (bond, reputation, escrow), not the event.
  - **Bond** (`bond` tag) is just an announced number; enforcement is platform-side (Mostro hold invoices etc.).
  - Fake `source` URLs = phishing vector; clients must not auto-follow.
  - Privacy: `g` geohash + face-to-face payment method leaks maker location; order history links trading activity to an npub.
- Status transitions rely on maker honesty; relays may retain stale versions of the addressable event.

## Interoperability notes
- Implemented by Mostro, @lnp2pBot, Robosats, Peach Bitcoin. Trade execution typically settles over Lightning (`layer` tag) with fiat rails in `pm`. References Mostro protocol spec and the abandoned n3xb proposal.

## Example
Real spec event (abridged):
```json
{
  "kind": 38383,
  "tags": [
    ["d", "ede61c96-4c13-4519-bf3a-dcf7f1e9d842"],
    ["k", "sell"], ["f", "VES"], ["s", "pending"],
    ["amt", "0"], ["fa", "100"],
    ["pm", "face to face", "bank transfer"],
    ["premium", "1"], ["network", "mainnet"], ["layer", "lightning"],
    ["bond", "0"], ["expires_at", "1719391096"], ["expiration", "1719995896"],
    ["y", "lnp2pbot"], ["z", "order"]
  ],
  "content": ""
}
```

## Open questions / uncertainties
- No standardized rate-oracle for `amt: 0` orders.
- `rating` schema is specified but its computation is platform-defined — not portable trust.
- No in-protocol dispute/escrow semantics; cross-platform trade completion is undefined behavior.
