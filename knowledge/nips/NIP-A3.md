# NIP-A3 — payto: Payment Targets

Source: https://github.com/nostr-protocol/nips/blob/master/A3.md
Retrieved: 2026-09-23
Status: `draft` `optional` (not unrecommended)
Confidence: HIGH (spec-read)

## Purpose
Standardizes declaring payment addresses/accounts across any network or platform (Bitcoin, Lightning, Monero, PayPal, Cash App...) via a single `payto` tag format, renderable as buttons/URIs.

## Event kinds
- The spec's example uses `kind:10133` (a parameterized-replaceable kind in the 10000–19999 range per NIP-01 conventions, i.e., addressable) hosting `payto` tags. The fetched spec text does not explicitly define/announce the kind in prose — only the example demonstrates it.

## Tags defined/used
- `payto` — `["payto", "<type>", "<address>"]`: literal `"payto"`, lowercase payment `type`, then the address/username. Multiple tags per event. Clients may apply network-specific validation for recognized types.
- Common types listed: `bip352` (silent payments), `bip353` (DNS payment instructions), `bitcoin`, `bitcoincash`, `cashme` (Cash App $cashtag), `ethereum`, `lightning` (lightning address), `litecoin`, `monero`, `nano`, `paypal`, `revolut`, `solana`, `tron`, `venmo`, `zcash`.

## Content format
Empty/irrelevant; all data in tags.

## Semantics & rules
- Rendering: use native URI scheme when available (`bitcoin:<address>`, `ethereum:<address>`); otherwise fall back to RFC-8905 `payto://<type>/<address>`.
- Unknown types are allowed; in case of ambiguity a specific URI scheme may be used (e.g. `bitcoincash:` prefix disambiguates `bitcoincash` type).
- Extensible list: "new widely deployed formats can be added later."

## Security & privacy notes
- **Funds at risk — address substitution is the entire threat model**: whoever controls the npub controls where money goes.
  - `payto` tags are self-asserted; a compromised key (or compromised signer/extension) silently swaps the receiving address — irreversible for on-chain types.
  - Clients performing "additional validation" only check format, not ownership. No proof-of-control mechanism is defined.
  - Addressable kind (10133) means the latest replaceable event wins — a relay serving a stale (previous-attacker) version or withholding an update changes displayed payment targets; clients must fetch from authoritative relays and compare `created_at`.
  - Privacy: publishing all payment accounts under one npub links a user's cross-chain/cross-platform financial identities (chain-analysis and platform-correlation exposure).
  - `lightning` type is a lightning *address* (LNURL-pay) — inherits LNURL server trust (server can swap invoices).

## Interoperability notes
- Complements NIP-57 `lud16` profiles (broader: any network, not just Lightning); RFC-8905 `payto://` URI alignment; BIP-352 silent payments and BIP-353 DNS payment instructions first-class.

## Example
Real spec event:
```json
{
  "kind": 10133,
  "content": "",
  "tags": [
    ["payto", "bitcoin", "bc1qxq66e0t8d7ugdecwnmv58e90tpry23nc84pg9k"],
    ["payto", "nano", "nano_1dctqbmqxfppo9pswbm6kg9d4s4mbraqn8i4m7ob9gnzz91aurmuho48jx3c"],
    ["payto", "unknowntype", "l7tbta5b9xze6ckkfc99uohzxd009b0r"]
  ]
}
```
Rendered URIs: `bitcoin:bc1q...`, `payto://nano/nano_1dct...`.

## Open questions / uncertainties
- Kind 10133 appears only in the example; not formally specified in the fetched text (no explicit kind reservation prose) — treat as convention pending clarification.
- No ownership proof, signing of addresses, or revocation story.
- No precedence rules when multiple `payto` tags share a type.
