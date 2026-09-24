# NIP-61 — Nutzaps

Source: https://github.com/nostr-protocol/nips/blob/master/61.md
Retrieved: 2026-09-23
Status: `draft` `optional` (not unrecommended)
Confidence: HIGH (spec-read)

## Purpose
P2PK-locked Cashu ecash zaps where **the payment itself is the receipt** — no LNURL server, no separate receipt verification step like NIP-57.

## Event kinds
- `10019` — addressable (parameterized replaceable): **nutzap informational event** — recipient's mint list, relays, and P2PK pubkey.
- `9321` — regular: **nutzap event** — the payment, published by sender, p-tagging recipient.
- `7376` — regular: NIP-60 spending history used to record redemption (`redeemed` marker).

## Tags defined/used
- 10019: `relay` (where recipient reads nutzaps — senders write here), `mint` (mint URL + optional unit markers e.g. `usd`, `sat`; recipient's accepted mints), `pubkey` (P2PK receiving pubkey — MUST NOT be the user's main Nostr pubkey).
- 9321: `proof` (one or more P2PK-locked proofs as stringified JSON, including DLEQ proof), `u` (mint URL EXACTLY as in recipient's 10019), `unit` (default `sat`), `p` (recipient identity pubkey), `e` (nutzapped event, optional, with relay hint), `k` (nutzapped kind).
- 7376 redemption: plaintext `e` tag with `redeemed` marker pointing at the 9321; `p` tag = nutzap sender.

## Content format
- 9321 `.content`: optional human-readable comment (plaintext).
- `proof` tag value: stringified Cashu proof whose `secret` is a NUT-11 P2PK condition: `["P2PK",{"nonce":"...","data":"02<33-byte-pubkey>"}]`.
- 7376 redemption content: NIP-44-encrypted array (direction/amount/unit/created-token e-tag).

## Semantics & rules
- **Send flow**: fetch recipient's 10019 → mint or swap ecash on one of recipient's listed mints → P2PK-lock proofs to recipient's 10019 `pubkey` (MUST prefix pubkey with `"02"` for nostr↔cashu compatibility) → publish 9321 to the relays listed in 10019.
- **Receive flow**: REQ `{ "kinds":[9321], "#p":["my-pubkey"], "#u":["<my-mints>"], "since": <created_at of latest 7376> }` — `#u` filtering prevents interacting with non-signaled mints; `since` uses last redemption as a watermark. Then swap tokens into own wallet (NIP-60 or otherwise).
- After claiming, client SHOULD publish 7376 e-tagging the 9321 with `redeemed`, published to the **sender's** NIP-65 read relays (signals redemption; prevents double-claiming).
- **Observer verification (offline)**: clients counting zaps SHOULD check (1) recipient published 10019 tagging that mint, (2) token is P2PK-locked to the pubkey in 10019, (3) `u` tag mint ∈ recipient's listed mints, (4) locally verify DLEQ proofs (NUT-12). All offline given the mint keyset + 10019.
- Clients SHOULD normalize/dedupe mint URLs (NIP-65 style).
- A 9321 MUST use a mint from recipient's 10019 and be published to recipient's NIP-65 relays — "failure to do so may result in the recipient donating the tokens to the mint since the recipient might never see the event."

## Security & privacy notes
- **Funds at risk**:
  - Sending to a mint not in 10019 = money likely burned (recipient won't watch that mint; proofs are bearer instruments anyone holding them can attempt to spend).
  - P2PK locking is the *only* thing preventing theft-in-transit: an unlocked (or wrongly-locked) proof in a public 9321 can be claimed by **anyone** who sees it first. Spec urges NUT-11 (P2PK) + NUT-12 (DLEQ) capable mints "to avoid receiving nutzaps anyone can spend."
  - **Race on redemption**: multiple devices/observers see the same 9321; whoever swaps first at the mint wins. The 7376 `redeemed` marker is advisory — the mint's spent-proof DB is the real arbiter. A compromised receiving key = silent theft of all future nutzaps.
  - **Mint trust**: mint custodies the BTC; a malicious mint can refuse swaps or rug. DLEQ proofs let observers verify token validity w.r.t. the mint's keys, not the mint's solvency.
  - Sender-receipt ambiguity: unlike NIP-57 there's no LNURL-issued receipt; the "receipt" is the P2PK proof itself — forgery-resistant only if observer does all four checks above (skipping mint-membership or lock checks lets anyone fabricate apparent zaps).
- Privacy: 9321 is public (sender, recipient, amount via proof `amount`, mint, comment). Sender privacy relies on ecash payer anonymity at the mint, not on Nostr.

## Interoperability notes
- Depends on NIP-60 (wallet state, receiving `privkey`), NIP-65 (relay lists), Cashu NUT-11 (P2PK) / NUT-12 (DLEQ).
- Alternative to NIP-57 Lightning zaps — no LNURL server needed for receiving.

## Example
Real spec 9321 proof tag (abbreviated):
```yaml
[ "proof", "{\"amount\":1,\"C\":\"02277c66...\",\"id\":\"000a93d6f8a1d2c4\",\"secret\":\"[\\\"P2PK\\\",{\\\"nonce\\\":\\\"b00bdd...\\\",\\\"data\\\":\\\"02eaee89...\\\"}]\"}" ]
```

## Open questions / uncertainties
- `since`-watermark-based fetching can skip nutzaps if history events are lost/deleted; spec admits clients "might choose other markers."
- No mechanism to refund/recover nutzaps sent to wrong mints or never claimed (sender could self-redeem only if they kept a spend path — unspecified).
- Unit/multi-currency handling is marker-convention only.
