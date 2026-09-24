# NIP-60 — Cashu Wallets

Source: https://github.com/nostr-protocol/nips/blob/master/60.md
Retrieved: 2026-09-23
Status: `draft` `optional` (not unrecommended)
Confidence: HIGH (spec-read)

## Purpose
Stores a Cashu ecash wallet's state in Nostr relays so the wallet follows the user across apps. Scope is **state keeping only** — receiving money from others is NIP-61's job.

## Event kinds
- `17375` — replaceable: **wallet event**. One per user (per wallet).
- `7375` — regular: **token event**; unspent proofs (encrypted). Multiple per mint allowed; multiple proofs per event.
- `7376` — regular: **spending history event** (optional, informational).
- `7374` — regular: **quote state event** (optional; mint quote id with NIP-40 `expiration` ≈ 2 weeks).
- `5` — NIP-09 delete used to destroy superseded token events; the delete event MUST carry `["k", "7375"]` so clients can filter state transitions.

## Tags defined/used
- Wallet (17375, all inside encrypted content): `mint` (≥1 REQUIRED), `privkey` (P2PK key for NIP-61 nutzaps — **distinct from the user's Nostr key**; MUST be stored encrypted in content).
- Token (7375): content fields `mint`, `proofs[]` (unencoded Cashu proofs), `unit` (default `sat`), `del` (ids of token events destroyed by this rollover).
- History (7376): inner tags `direction` (`in`|`out`), `amount`, `unit`; `e` tags with markers `created` / `destroyed` / `redeemed`.
- Quote (7374): `expiration`, `mint` tags (plaintext).

## Content format
All sensitive payloads are **NIP-44 encrypted to self** (`nip44_encrypt` with the user's own key):
- 17375 content: encrypted array of `[ "privkey", hex ]`, `[ "mint", url ]` pairs.
- 7375 content: encrypted JSON `{mint, unit, proofs:[{id, amount, secret, C}...], del:[...]}`.
- 7376 content: encrypted array of direction/amount/unit/`e` tuples. All tags in 7376 can be encrypted; `e` tags with the `redeemed` marker SHOULD be left unencrypted (public redemption signaling).

## Semantics & rules
- Discovery flow: fetch user's `kind:10019` (NIP-61) to find wallet relays; fallback to NIP-65 relay list; then REQ `{"kinds": [17375, 7375], "authors": ["<my-pubkey>"]}`.
- **Spend rollover (load-bearing)**: when spending proofs from a 7375 token, the client MUST (a) create a new 7375 rolling over all unspent proofs plus change outputs, (b) include the old event id in the new event's `del` array, (c) NIP-09 delete the old token event with `["k","7375"]` on the delete. Failure to delete = double-spend attempt surface (mint will reject already-spent proofs; race between two devices reading stale state).
- Clients SHOULD publish 7376 history events when balance changes, e-tagging created/destroyed tokens.
- Quote events SHOULD be avoided when local state suffices (publish only when app context demands cross-device quote tracking).
- Appendix: clients MAY validate proofs against the mint (check spent status); spent proofs ⇒ delete token and roll over the rest. Validation timing is implementation-defined.

## Security & privacy notes
- **Funds at risk**: anyone who decrypts 7375 contents can spend the proofs — security reduces to NIP-44-to-self secrecy of the user's Nostr key. Nostr key compromise = total wallet drain (except P2PK-locked proofs).
- The embedded `privkey` (P2PK receiving key) is encrypted at rest but any app with Nostr-key access can extract it — it MUST be a separate key so a leak only exposes ecash receiving, not identity.
- **Mint trust**: Cashu is custodial — the mint can rug all underlying BTC; proofs are bearer IOUs. Nothing in the NIP mitigates mint insolvency; multi-mint support (`mint` tags) is the only hedge.
- **Double-spend/state-race**: two clients with stale state can both spend the same proofs; mint rejects the second. The `del` field + deletes are best-effort state sync, not consensus. Relays withholding deletes or serving old 7375s cause user-visible loss attempts (not theft, but failed payments).
- Metadata leakage: relays see event counts, timing, and sizes of encrypted tokens — balance and activity patterns partially inferable. 7374 quote events leak mint URL + timing in plaintext tags.
- Deleting a token event without rollover (or a relay honoring delete while another keeps the old event) can **strand funds** if the delete propagates but the replacement event doesn't.

## Interoperability notes
- Pairs with NIP-61 (nutzaps): the 17375 `privkey` corresponds to the `pubkey` in 10019 for P2PK-locked receiving; 7376 `redeemed` markers signal nutzap redemption.
- Cashu protocol (NUTs) defines proof format, mint/swap/quote APIs — out of scope here.

## Example
Real spec wallet event:
```javascript
{
    "kind": 17375,
    "content": nip44_encrypt([
        [ "privkey", "hexkey" ],
        [ "mint", "https://mint1" ],
        [ "mint", "https://mint2" ]
    ]),
    "tags": []
}
```

## Open questions / uncertainties
- No standard reconciliation when multiple 17375 wallet events or divergent 7375 sets exist across relays ("left up to implementations").
- Proof validation cadence unspecified — stale-state losses possible between validations.
- No recovery story if the wallet event's mint list and actual token mints diverge.
