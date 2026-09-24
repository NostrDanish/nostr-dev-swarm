# NIP-90 — Data Vending Machine

Source: https://github.com/nostr-protocol/nips/blob/master/90.md
Retrieved: 2026-09-23
Status: `draft` `unrecommended` `optional` — README warning: "unrecommended: this got totally out of control, prefer use-case-specific microstandards"
Confidence: HIGH (spec-read)

## Purpose
Marketplace for on-demand computation: customers publish job requests (speech-to-text, summarization, translation...) with willingness to pay; competing service providers (DVMs) fulfill them. "Money in, data out." Not a 1:1 marketplace — an open competitive-offer flow.

## Event kinds
Range `5000–7000` reserved:
- `5000–5999` — job requests (customer). Regular events.
- `6000–6999` — job results (service provider). Result kind = request kind + 1000.
- `7000` — job feedback.
- `5` — kind-5 delete cancels a job request.
- `31990` — NIP-89 handler announcement used for DVM discoverability (`k` tag = supported job kinds).
Concrete job types are defined in a separate repo: github.com/nostr-protocol/data-vending-machines/kinds.

## Tags defined/used
Request (5xxx): `i` (`<data>`, `<input-type: url|event|job|text>`, `<relay?>`, `<marker?>`), `output` (mime type), `param` (key/value), `bid` (max msats willing to pay), `relays` (where SPs SHOULD publish responses), `p` (preferred SPs; others MIGHT still answer), `encrypted` (marks NIP-04-encrypted `i`/`param` in content).
Result (6xxx): `request` (stringified original request JSON), `e` (request id + relay hint), `i` (echo of inputs), `p` (customer), `amount` (msats requested + optional bolt11 invoice), `encrypted`.
Feedback (7000): `status` (`payment-required`|`processing`|`error`|`success`|`partial` + extra info), `amount`, `e`, `p`; `.content` empty or partial-result sample.

## Content format
- Request: usually empty; if params are private, `i`+`param` tags are NIP-04-encrypted to the SP's pubkey and placed in `content` (requires `p` tag + `encrypted` tag).
- Result: `.content` = output payload (plaintext, or NIP-04-encrypted if request was encrypted — then omit cleartext `i`).
- Feedback: `.content` empty or partial results.

## Semantics & rules
- Flow: customer publishes 5xxx → SPs MAY emit 7000 feedback (`payment-required`, `processing`...) → SP publishes 6xxx result with `amount`/bolt11 → customer pays the bolt11 **or zaps the result event**; SPs should monitor for both.
- `payment-required` feedback is the ONLY canonical "pay first" signal: SPs MUST use it if no further work happens until payment.
- **Payment flow is deliberately ambiguous** (spec says so): pay-before, pay-after, partial-sample-then-pay, or reputation-based free-first are all legal; SPs model their own risk.
- Job chaining: `i` type `job` references a previous job's output; downstream SPs may start on sight of upstream result but "will likely wait for a zap to be published first" — spec notes a race where upstream SP delays publishing the zap for advantage; mitigation left to SPs.
- Cancellation: kind-5 delete tagging the request.

## Security & privacy notes
- **Funds at risk**:
  - **Payment ambiguity is the core hazard**: nothing binds a result to a specific invoice or proves payment ↔ delivery. Customer may pay a bolt11 from a 7000/6xxx and receive nothing further (no escrow, no receipt binding); SP may deliver and never be paid. Bid (`bid` tag) is a ceiling, not a commitment.
  - **Result/invoice forgery**: any npub can publish a 6xxx tagging the customer's `p` with an `amount`+bolt11 — a squatter can watch for requests and race the real SP with a garbage result and their own invoice. Customers MUST check the result pubkey (against their `p`-tagged preferred SP or reputation) before paying; the spec does not mandate this.
  - Zap-vs-invoice double path ("pay bolt11 or zap") risks double payment unless client tracks state.
  - Encrypted params use **deprecated NIP-04** — sensitive inputs (texts to translate/summarize) are weakly protected; relay sees timing/kinds/bid metadata regardless.
  - `i` type `url` makes SPs fetch arbitrary URLs (SSRF/abuse vector on SP side).
  - Job chaining zap-delay race documented in Appendix 1.
- No SLA, no quality oracle: "not up to this NIP to define how vending machines run their business."

## Interoperability notes
- Payment rails: NIP-57 zaps or raw bolt11. Discovery via NIP-89 (kind 31990 with `k` = job kinds). Unrecommended per README — "prefer use-case-specific microstandards" (e.g., kind 5050-style single-purpose DVM specs still in use).

## Example
Real spec job request skeleton:
```yaml
{
  "kind": 5xxx,
  "content": "",
  "tags": [
    [ "i", "<data>", "<input-type>", "<relay>", "<marker>" ],
    [ "output", "<mime-type>" ],
    [ "relays", "wss://..." ],
    [ "bid", "<msat-amount>" ]
  ]
}
```

## Open questions / uncertainties
- No standard linking a specific payment to a specific result (invoice reuse across feedback events undefined).
- Which of multiple competing SP results the customer should pay is out of scope.
- NIP-04 for encrypted params is a known-weak holdover; no NIP-44 variant specified.
- Whole NIP flagged as out-of-control; fragmentation across the kinds repo.
