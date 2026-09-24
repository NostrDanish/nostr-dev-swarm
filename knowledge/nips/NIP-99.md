# NIP-99 — Classified Listings

Source: https://github.com/nostr-protocol/nips/blob/master/99.md
Retrieved: 2026-09-23
Status: `draft` `optional` (not unrecommended — positioned as the simpler successor to unrecommended NIP-15)
Confidence: HIGH (spec-read)

## Purpose
Lightweight classified listings for arbitrary products/services/rentals/jobs/personals. Deliberately minimal: NIP-23-style long-form structure + a few standardized metadata tags. E-commerce extension: github.com/GammaMarkets/market-spec.

## Event kinds
- `30402` — addressable: active classified listing.
- `30403` — addressable: draft/inactive listing (same structure).

## Tags defined/used
Standardized (SHOULD include): `d` (identifier), `title`, `summary`, `published_at` (unix ts string of first publication), `location`, `price` (`["price","<number>","<currency>","<frequency?>"]` — ISO 4217 or ISO-like codes e.g. `btc`, `eth`; frequency noun: hour/day/week/month/year), `status` (`active`|`sold`).
Common: `t` (categories/keywords), `image` (NIP-58 format with optional dimensions), `g` (geohash).
May reference other events via `e`/`a` tags.

## Content format
`.content` = Markdown description of what is offered and by whom. `.pubkey` = the listing party.

## Semantics & rules
- Addressable: seller updates listing (price, status → `sold`) by republishing same `d`.
- No checkout, payment, escrow, or messaging flow is defined — contact/payment arrangements are out-of-band or left to client conventions/extensions (e.g., GammaMarkets market-spec).
- Structure intentionally mirrors NIP-23 so long-form tooling renders listings.

## Security & privacy notes
- **Funds at risk**: the NIP defines advertising only — there is no protocol-level guarantee of anything. Buyer/seller safety depends entirely on out-of-band arrangements:
  - No payment proof, receipt, or delivery attestation; nothing prevents fake listings, price bait-and-switch via republish, or impersonation beyond the author's npub reputation.
  - `price` currency accepts "ISO 4217-like" codes (btc/eth) — unit confusion (BTC vs sats) is a real client-display hazard; spec gives no sats convention.
  - `location`/`g` + personals use cases carry physical-safety and doxxing risk.
  - `published_at` is self-reported (used for sorting; can be backdated).
- Markdown content: client rendering must sanitize embedded images/links (tracking, phishing).

## Interoperability notes
- Recommended replacement for NIP-15's listing side (per NIP-15 README pointer). Payments typically bolted on via NIP-57 zaps/LNURL or external checkout; GammaMarkets spec standardizes e-commerce on top.

## Example
Real spec event (abridged; the spec's own sample text replaced with neutral placeholders):
```yaml
{
  "kind": 30402,
  "created_at": 1675642635,
  "content": "Vintage synthesizer, fully serviced ... (Markdown)",
  "tags": [
    ["d", "vintage-synth-sale"],
    ["title", "Vintage Synthesizer"],
    ["published_at", "1296962229"],
    ["t", "electronics"],
    ["image", "https://url.to.img", "256x256"],
    ["image", "https://url.to.img2", "256x256"],
    ["summary", "Fully serviced, original box, NYC pickup"],
    ["location", "NYC"],
    ["price", "100", "USD"]
  ]
}
```

## Open questions / uncertainties
- No standard checkout/ordering flow — interop gap left to extensions.
- Currency precision/sat-denomination conventions unspecified.
- `status` vocabulary minimal (`active`/`sold`); no reserved/expired states.
