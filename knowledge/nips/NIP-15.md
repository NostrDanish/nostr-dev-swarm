# NIP-15 — Nostr Marketplace

Source: https://github.com/nostr-protocol/nips/blob/master/15.md
Retrieved: 2026-09-23
Status: `draft` `unrecommended` `optional` — README warning: "unrecommended: too complicated, try NIP-99 instead"
Confidence: HIGH (spec-read)

## Purpose
Full structured marketplace protocol: merchants publish stalls/products as addressable events; checkout happens over encrypted DMs; includes auctions and customizable marketplace UIs. Based on Diagon-Alley; implemented in NostrMarket and Plebeian Market.

## Event kinds
- `0` — set_meta: merchant profile.
- `30017` — addressable: create/update stall. `d` tag required, MUST equal stall `id`.
- `30018` — addressable: create/update product. `d` tag MUST equal product `id`.
- `30019` — addressable: marketplace UI/UX config (name, theme, merchants list).
- `30020` — addressable: product sold as auction.
- `4` — regular: NIP-04 DM carrying checkout JSON messages.
- `5` — delete: remove product/stall.
- `1021` — regular: auction bid (`content` = bid amount in sats; `e` tag = auction event id).
- `1022` — regular: bid confirmation by merchant.

## Tags defined/used
- `d` (stall/product/auction/marketplace id), `t` (product category, multiple allowed), `e` (bid→auction; confirmation→bid and auction).
- NIP-19 `naddr` used for sharing stalls/products/marketplaces.

## Content format
- Stall (30017): JSON `{id, name, description?, currency, shipping:[{id, name?, cost, regions[]}]}`.
- Product (30018): JSON `{id, stall_id, name, description?, images?, currency, price, quantity(int|null), specs:[[k,v]], shipping:[{id, cost}]}`.
- Auction (30020): `{id, stall_id, name, starting_bid, start_date?, duration, specs, shipping}`.
- Checkout messages (NIP-04 encrypted JSON, MUST have `type` field):
  - type 0 (customer→merchant): new order `{id, type:0, name?, address?, message?, contact:{nostr, phone?, email?}, items:[{product_id, quantity}], shipping_id}`.
  - type 1 (merchant→customer): payment request `{id, type:1, message?, payment_options:[{type, link}]}` where type ∈ `url` | `btc` | `ln` | `lnurl`.
  - type 2 (merchant→customer): status `{id, type:2, message?, paid:bool, shipped:bool}`.
- Bid confirmation (1022): `{status: "accepted"|"rejected"|"pending"|"winner", message?, duration_extended?}`.

## Semantics & rules
- Customer MUST choose exactly one shipping zone from the stall; total shipping = stall base cost + (per-product extra cost × units).
- `quantity: null` = unlimited availability (digital goods/services).
- Payment flow: order (type 0) → merchant payment request (type 1, options incl. Lightning invoice `ln` or `lnurl` LNURL-pay, on-chain `btc`, or fiat `url`) → merchant confirmation (type 2) after payment received. Payment verification is entirely merchant-side.
- Auctions: bids reference the auction **event id** (not the `d` id), so editing an auction after the first bid orphans existing bids — this enforces "no edits after first bid" implicitly. Clients MUST verify bid confirmations are signed by the merchant's pubkey. Auction end = `start_date + duration + Σ(duration_extended across confirmations)`.
- `pending` bids may later be approved; `rejected` bids cannot.
- Sequential ids (0,1,2...) discouraged for stalls/products.

## Security & privacy notes
- Checkout runs over **NIP-04 DMs** (deprecated, weak encryption). Shipping addresses, phone, email are sent in these DMs: high PII exposure if NIP-04 is ever broken.
- No payment-proof standard: customer has no protocol-level receipt; `paid`/`shipped` are unilateral merchant claims. Dispute resolution is out-of-band; buyer has no escrow or recourse.
- Merchant can silently swap `payment_options` (e.g., malicious ln invoice) — the DM channel integrity is the only protection.
- Auction integrity depends on clients checking merchant signatures on kind 1022 confirmations; a merchant can still reject/pending bids arbitrarily.
- Denial-of-inventory: `quantity` is advisory; no atomic reservation — overselling possible between order and payment request.

## Interoperability notes
- Superseded in practice by NIP-99 (classified listings) per README; LNURL/Lightning via `ln`/`lnurl` payment option types; BTCPay/Stripe via `url` type.
- Data models: https://raw.githubusercontent.com/lnbits/nostrmarket/main/models.py

## Example
Real spec payment-request message (type 1):
```json
{
  "id": "<order id>",
  "type": 1,
  "message": "Please pay to complete your order",
  "payment_options": [
    {"type": "ln", "link": "lnbc..."},
    {"type": "lnurl", "link": "lnurlp..."}
  ]
}
```

## Open questions / uncertainties
- Spec itself flags open issues: is `contact.nostr` required? Should `specs` move to tags?
- No standard for shipping zones per-product `id` mismatch handling ("should match" only).
- Unrecommended: new implementations should evaluate NIP-99 + separate checkout conventions instead.
