# Research Log — Wave 3: Money & Markets cluster

Researcher: NOSTR PROTOCOL DEEP-RESEARCHER (Money & Markets)
Date: 2026-09-23
Scope: NIP-03, 15, 47, 60, 61, 69, 75, 87, 90, 99, A3
Method: all 11 specs fetched live from `nostr-protocol/nips` master via GitHub MCP `get_file_contents` (SHA-verified). All cards written spec-first; nothing from memory.

## NIP-03 — OpenTimestamps Attestations (kind 1040)
Source: https://github.com/nostr-protocol/nips/blob/master/03.md (SHA 8e4e776f)
- Single event kind 1040; content = base64 `.ots` file; `e`+`k` tags point at the target event.
- Load-bearing rule: the OTS proof MUST commit the **event id** as its digest — so the proof covers the whole signed event (id = sha256 of serialized event).
- SHOULD be a single Bitcoin attestation, no pending-attestation refs.
- README marks it `unrecommended: vulnerable to one specific attack, needs update` — the spec text does not describe the attack; flagged in the card as an open question.
- Money relevance: timestamping of market events (orders, receipts) is a plausible use, but the unrecommended status makes it unusable as an authoritative dispute-resolution oracle without understanding the attack.
- Verification flow in spec is real: `nak req … | jq -r .content | ots verify` validated at block 810391.

## NIP-15 — Nostr Marketplace (30017/30018/30019/30020, 1021/1022, kind 4 checkout)
Source: https://github.com/nostr-protocol/nips/blob/master/15.md (SHA b1174891)
- Full merchant stack: stalls (30017), products (30018), UI config (30019), auctions (30020) — all addressable with `d` tag MUST equal content `id`.
- Checkout = 3-message JSON protocol over NIP-04 DMs: type 0 order → type 1 payment request → type 2 paid/shipped confirmation.
- **LNURL/Lightning interaction**: payment_options types are `url` (Stripe/PayPal/BTCPay), `btc` (on-chain), `ln` (bolt11 invoice), `lnurl` (LNURL-pay). Payment verification is entirely merchant-side; the customer receives no protocol-level receipt — dispute recourse is nil.
- Auctions: bids (1021) reference the auction **event id**, so editing after the first bid orphans bids — an elegant implicit "no edits after bidding opens" rule. Merchant confirmations (1022) must be pubkey-checked by clients.
- **Why unrecommended**: README says "too complicated, try NIP-99 instead". Concretely: heavy structured JSON-in-content per entity, checkout trapped in deprecated NIP-04 DMs (PII exposure: address/phone/email), no payment-proof standard, overselling possible (no inventory reservation). NIP-99 + external checkout covers the 90% case with far less machinery.

## NIP-47 — Nostr Wallet Connect (13194 / 23194 / 23195)
Source: https://github.com/nostr-protocol/nips/blob/master/47.md (SHA a00445f5)
- Client↔wallet-service JSON-RPC over relays; info event (replaceable 13194), request/response (ephemeral 23194/23195).
- Connection URI `nostr+walletconnect://<wallet-pubkey>?relay=…&secret=<32-byte>` — the `secret` is the **client's** signing/encryption key; it's a full spending credential bounded only by wallet-side budgets (`QUOTA_EXCEEDED`, `RESTRICTED`). Treat like a password.
- Encryption: NIP-44 (`nip44_v2`) preferred; `encryption` tag negotiates; **absence of tag ⇒ legacy NIP-04 assumed** (deprecated, weak — silent downgrade risk for old connections).
- Core commands: `pay_invoice`, `make_invoice`, `lookup_invoice`, `get_balance`, `get_info`; extensions (notifications, granular auth) moved to github.com/nostr-wallet-connect/nwc (02.md+).
- Privacy by design: user identity key never used; unique wallet-service pubkey per connection prevents payment-activity linkage. Relay still sees kinds/tags/timing — dedicated authenticated relay recommended for custodians.
- **Lightning interaction**: this IS the Lightning rail for much of the ecosystem (zap payments from clients). Result returns `preimage` = cryptographic payment proof inside the encrypted payload.
- Ephemeral-event delivery is best-effort; relays that drop idle connections can strand requests/responses.

## NIP-60 — Cashu Wallets (17375 / 7375 / 7376 / 7374)
Source: https://github.com/nostr-protocol/nips/blob/master/60.md (SHA 8c836ac0)
- Wallet state in relays: 17375 (replaceable wallet: mint list + encrypted P2PK `privkey`), 7375 (token events = unspent proofs, NIP-44-encrypted **to self**), 7376 (history, optional), 7374 (mint quote state, NIP-40-expiring).
- **Ecash model**: proofs are bearer IOUs from a custodial mint; Nostr relays store the encrypted bearer instruments, the mint is the double-spend arbiter. Security of stored funds = secrecy of the user's Nostr key (key compromise = drain).
- **Load-bearing state-transition rule**: spending requires (a) new 7375 rolling over unspent proofs + change, (b) old event id in `del`, (c) NIP-09 delete of the old event with mandatory `["k","7375"]` tag. This is anti-double-spend state hygiene, not consensus — the mint's spent-proof DB is the real guard; races between devices produce failed payments, not theft.
- Wallet `privkey` MUST be a separate key from the Nostr identity key; it only unlocks P2PK ecash received via NIP-61 nutzaps.
- Optional proof validation against mint (Appendix 1); stale-state handling deliberately left to implementations — a known soft spot.
- Metadata leakage: relays see encrypted blob sizes/timing (balance/activity inference); 7374 leaks mint URL in plaintext.

## NIP-61 — Nutzaps (10019 / 9321 + 7376 redeemed markers)
Source: https://github.com/nostr-protocol/nips/blob/master/61.md (SHA bd2d8e6e)
- "The payment itself is the receipt": a 9321 carries P2PK-locked (NUT-11) proofs with DLEQ proofs (NUT-12); no LNURL server needed to receive — the key architectural difference from NIP-57 Lightning zaps.
- 10019 = receive policy: trusted mints (with unit markers), read relays, and the P2PK pubkey (MUST NOT be identity key; corresponds to NIP-60 wallet's encrypted `privkey`).
- Sender MUST lock with `"02"`-prefixed pubkey; MUST use a mint listed in recipient's 10019 and publish to their relays — else "recipient donates tokens to the mint" (spec's words): sending to unlisted mints = probable burn.
- Observer verification is offline and four-part: 10019 lists the mint; proof locked to 10019 pubkey; `u` tag matches listed mint exactly; DLEQ proof verifies locally. Skipping any check enables fake-zap display.
- **Double-spend/mint-trust**: unlocked proofs in public 9321s are stealable by anyone (first swap wins); redemption races resolved by mint, with 7376 `redeemed` markers as advisory signaling to the sender (published to sender's NIP-65 read relays). Mint custodies the BTC — DLEQ proves token authenticity, not mint solvency.
- Receiving filter pattern: `{"kinds":[9321], "#p":[me], "#u":[my mints], "since":<last 7376 created_at>}` — watermark can skip events if history is lost (spec acknowledges).

## NIP-69 — P2P Order events (38383)
Source: https://github.com/nostr-protocol/nips/blob/master/69.md (SHA 997cac67)
- Addressable order book shared across Mostro, lnp2pBot, Robosats, Peach — announcement layer only; trade execution/escrow is platform-specific.
- Rich mandatory tag set: `k`(buy/sell), `f`(ISO 4217), `s`(pending/canceled/in-progress/success/expired), `amt`(sats; **0 = market-price order resolved from a public API at accept time**), `fa`(fiat, range allowed), `pm`, `premium`, `network`, `layer`, expiry pair (`expires_at` status rule + NIP-40 `expiration`), `y` platform, `z=order`.
- **Oracle risk** (called out in card): `amt:0` depends on an unspecified external price API — rate source/timestamp not pinned in the event; manipulation or divergence = dispute surface.
- `rating`/`name` are self-asserted and fakeable; `bond` is an announced number enforced platform-side (e.g., Mostro hold invoices). Trust comes from the platform, never the event.
- Settlement typically Lightning (`layer` tag); fiat rails free-form in `pm`.

## NIP-75 — Zap Goals (9041)
Source: https://github.com/nostr-protocol/nips/blob/master/75.md (SHA b335afb8)
- Fundraising target event: REQUIRED `amount` (msats) + `relays` (tally set); optional `closed_at`, `image`, `summary`, multiple NIP-57 Appendix-G `zap` beneficiaries; linkable from addressable events via `goal` tag.
- Contributions are plain NIP-57 zaps; clients MUST put the goal's relay list in the zap request `relays` tag and SHOULD e-tag the goal when zapping a linked event.
- Tally integrity reduces entirely to NIP-57 receipt verification (covered elsewhere in the swarm): forged receipts from a malicious LNURL server inflate apparent progress without funds moving; relay withholding deflates it. `closed_at` enforcement is SHOULD-level → boundary disputes.
- No refunds, no "goal met" event; donation semantics only.

## NIP-87 — Cashu/Fedimint Discoverability (38172 / 38173 / 38000)
Source: https://github.com/nostr-protocol/nips/blob/master/87.md (SHA d9e172ae)
- Three actors: mint announces (38172 cashu: `d`=mint pubkey from `/v1/info`, `nuts` list, `n` network; 38173 fedimint: `d`=federation id, `u` invite codes, `modules`), user recommends (38000, addressable/editable), seeker queries recommenders' 38000s filtered by `#k`.
- This is the mint-trust layer for the whole ecash cluster: NIP-61's 10019 mint lists have to come from somewhere, and 87 is the WoT mechanism.
- Anti-sybil guidance is explicit: direct 38172/38173 queries SHOULD use spam prevention / restricted relays; recommendations only meaningful from the user's actual social graph.
- Asymmetry noted in card: cashu announcements bind to the mint pubkey (verifiable via `/v1/info`); fedimint announcements have no cryptographic binding between npub and federation — impersonation risk mitigated only by `a`-tag disambiguation + recommender trust.
- Privacy cost: recommending a mint publicly links you to your custodian.

## NIP-90 — Data Vending Machines (5000–5999 / 6000–6999 / 7000)
Source: https://github.com/nostr-protocol/nips/blob/master/90.md (SHA a6ea3bcd)
- Kind range reserved 5000–7000; result kind = request + 1000; feedback 7000 with status `payment-required|processing|error|success|partial`.
- Payment plumbing: `bid` (msat ceiling) on request; `amount`+optional bolt11 on results/feedback; customer pays invoice **or zaps the result** — SPs must watch both. `payment-required` is the only canonical pay-first gate (MUST be used if SP halts until paid).
- **Payment ambiguity is designed in** ("deliberately ambiguous"): no binding between payment and delivery, no escrow, no receipt. Concrete attack: any npub can squat a request with a junk 6xxx result + own bolt11 — customers must check result pubkey; spec doesn't mandate it. Double-pay risk across bolt11/zap dual paths.
- Encrypted params use deprecated NIP-04 (weak); relay sees bids/kinds/timing regardless. `i` type `url` is an SSRF vector against SPs.
- **Why unrecommended**: README — "this got totally out of control, prefer use-case-specific microstandards." The anything-for-anything framework plus undefined payment semantics produced fragmentation (job kinds pushed to an external repo); the ecosystem kept single-purpose DVM kinds instead.
- Job chaining has a documented zap-delay race (Appendix 1), left to SPs to mitigate.

## NIP-99 — Classified Listings (30402 / 30403)
Source: https://github.com/nostr-protocol/nips/blob/master/99.md (SHA 08b04cd0)
- NIP-23-shaped listings: Markdown content + standardized tags (`title`, `summary`, `published_at`, `location`, `price` with `[amount, currency, frequency?]`, `status` active/sold); 30403 = drafts.
- Advertisement only: zero checkout/payment/escrow semantics — funds-safety is entirely out-of-band (extensions like GammaMarkets market-spec standardize e-commerce on top).
- Currency accepts "ISO 4217-like" codes (btc, eth) with no sats convention — unit-confusion display hazard flagged in card.
- The designated successor to NIP-15's listing side (NIP-15 README points here).

## NIP-A3 — payto: Payment Targets (kind 10133 per example)
Source: https://github.com/nostr-protocol/nips/blob/master/A3.md (SHA 861bdaad)
- One tag format: `["payto", "<type>", "<address>"]` covering bitcoin, lightning (address), bip352 silent payments, bip353 DNS, monero, paypal, cashme, venmo, etc.; render via native URI or RFC-8905 `payto://<type>/<address>`.
- Threat model = address substitution: tags are self-asserted with no proof-of-control; key compromise or stale-relay replay of an addressable 10133 changes where donors send funds irreversibly.
- Kind 10133 appears only in the example, not in spec prose — flagged as convention-pending-clarification.
- Broader successor to profile `lud16`; inherits LNURL server trust for the `lightning` type.

## Cross-cutting themes (money cluster)
- **Two payment philosophies coexist**: NIP-57/75/90 ride Lightning+LNURL (server-issued receipts, preimage proofs, but LNURL trust and receipt-forgery surface); NIP-60/61 ride Cashu ecash (bearer instruments, offline-verifiable DLEQ proofs, but mint custody and first-swap-wins races). NIP-47 is the remote-control plumbing that lets clients actually pay Lightning invoices.
- **Encryption debt**: NIP-15 checkout and NIP-90 encrypted params still specify deprecated NIP-04; NIP-47 defaults legacy connections to NIP-04 by tag-absence; only NIP-60/61 are NIP-44-clean. Any PII- or funds-bearing NIP-04 channel is a liability.
- **Receipt/forgery asymmetry**: NIP-57 receipts are forged by malicious LNURL servers (affects NIP-75 tallies); nutzaps resist forgery only if observers perform all four offline checks (mint membership, P2PK lock, `u` exact-match, DLEQ); NIP-90 has no receipts at all; NIP-15/A3 payment targets are pure self-assertion.
- **Replaceability hazards**: addressable money-adjacent events (A3 targets, 69 orders, 87 announcements, 10019 policies) all share the stale-version/replay risk — clients must verify `created_at` freshness from authoritative relays.
- **Unrecommended triad**: NIP-03 (specific undisclosed attack), NIP-15 (complexity → NIP-99), NIP-90 (scope explosion → microstandards). All three remain draft+optional but should not be greenfield dependencies.

## Failures / gaps
- `web_open_url` to raw.githubusercontent.com was audit-rejected in this environment; GitHub MCP used for all fetches — no spec went unfetched. Confidence HIGH on all 11 cards.
- NIP-03's "one specific attack" is referenced by README but not documented in the spec; unresolved.
- NIP-A3's kind 10133 is example-only in the fetched text; unresolved whether prose elsewhere formally reserves it.
