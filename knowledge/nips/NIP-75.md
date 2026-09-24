# NIP-75 — Zap Goals

Source: https://github.com/nostr-protocol/nips/blob/master/75.md
Retrieved: 2026-09-23
Status: `draft` `optional` (not unrecommended)
Confidence: HIGH (spec-read)

## Purpose
Fundraising goals: an event declaring a target amount; contributions arrive as NIP-57 Lightning zaps against the goal event and are tallied from receipts.

## Event kinds
- `9041` — regular: zap goal event.
- Linked from addressable events via a `goal` tag (`["goal", "<event id>", "<relay url optional>"]`).
- Zap receipts are standard NIP-57 `kind:9735`.

## Tags defined/used
Required on 9041:
- `amount` — target in **millisats**.
- `relays` — list of relays where zaps to this goal are sent and from which they are tallied.
Optional:
- `closed_at` — unix ts; zap receipts published after it SHOULD NOT count toward progress.
- `image`, `summary`.
- `r` / `a` — link goal to URL or addressable event.
- multiple `zap` tags (NIP-57 Appendix G) — multiple beneficiary pubkeys.

## Content format
`.content` = human-readable description of the goal (plaintext).

## Semantics & rules
- When zapping a goal event, clients MUST include the goal's `relays` list in the zap request's `relays` tag — tallying depends on receipts landing on those relays.
- When zapping an addressable event that carries a `goal` tag, clients SHOULD include the goal event id in the zap request's `e` tag (so the receipt attributes to the goal).
- Tally = sum of valid NIP-57 zap receipts (kind 9735) on the listed relays tagging the goal, filtered by `closed_at`.
- Clients MAY display goals on profiles.

## Security & privacy notes
- **Funds at risk (tally integrity)**: progress is computed from NIP-57 receipts, so all NIP-57 receipt-verification rules are load-bearing — verify receipt signature against the recipient's LNURL provider's `nostrPubkey`, check bolt11 matches, etc. A malicious/compromised LNURL server can forge receipts inflating apparent progress (funds never moved). NIP-75 adds no checks of its own.
- Receipt set is relay-dependent: a relay withholding/deleting 9735s skews the tally downward; goal creator chooses the relay set (centralization of truth).
- `closed_at` filtering is SHOULD-level: late zaps may or may not count → disputes about whether the goal "met" its target at close.
- Multiple `zap` beneficiaries split payouts per NIP-57 Appendix G weighting — donors must trust clients to honor splits.
- No refunds if goal fails; zaps are unconditional donations.

## Interoperability notes
- Pure extension of NIP-57 zaps/LNURL; usable from long-form posts, badges, live streams via `goal` tag.

## Example
Real spec goal event:
```yaml
{
  "kind": 9041,
  "tags": [
    ["relays", "wss://alicerelay.example.com", "wss://bobrelay.example.com"],
    ["amount", "210000"],
    ["closed_at", "<unix timestamp in seconds>"]
  ],
  "content": "Nostrasia travel expenses"
}
```

## Open questions / uncertainties
- No canonical rule for which receipts count when receipts appear on non-listed relays (clients may diverge).
- No defined "goal met" event or payout condition; purely a display/tally convention.
