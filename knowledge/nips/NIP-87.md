# NIP-87 — Cashu and Fedimint Discoverability

Source: https://github.com/nostr-protocol/nips/blob/master/87.md
Retrieved: 2026-09-23
Status: `draft` `optional` (not unrecommended)
Confidence: HIGH (spec-read)

## Purpose
Web-of-trust style discovery for ecash mints: mints announce themselves and capabilities; users publish recommendations; seekers query recommenders they trust before depositing funds with a mint.

## Event kinds
- `38172` — addressable: **Cashu mint announcement** (operator-published).
- `38173` — addressable: **Fedimint announcement**.
- `38000` — addressable (parameterized replaceable): **recommendation event** (user → mint). Replaceable so users can edit recommendations in place.

## Tags defined/used
- On 38000: `k` (kind being recommended: `38173` fedimint / `38172` cashu), `d` (the mint announcement's d-identifier; computable even if no announcement exists), `u` (mint URL or fedimint invite code; multiple allowed), `a` (`38173:<pubkey>:<d>` or `38172:<pubkey>:<d>` + relay hint — disambiguates duplicate announcements).
- On 38172: `d` SHOULD = mint pubkey (from `/v1/info`), `u` = mint URL, `nuts` (comma list of supported NUTs, e.g. `1,2,3,4,5,6,7`), `n` (network: mainnet/testnet/signet/regtest).
- On 38173: `d` SHOULD = federation id, `u` = invite codes (multiple), `modules` (e.g. `lightning,wallet,mint`), `n` (network).
- Content of 38172/38173: optional NIP-01 kind-0-style metadata JSON; if empty, fall back to author's kind:0.

## Content format
- 38000 `.content`: free-text review ("I trust this mint with my life").
- 38172/38173 `.content`: optional stringified metadata JSON.

## Semantics & rules
- Discovery flow: user B REQs `{"kinds":[38000], "authors":[<self/contact-list>], "#k":["38173"|"38172"]}` to get recommendations from people they follow, then fetches the referenced mint announcements.
- Direct query of 38172/38173 (bypassing recommendations) is allowed but clients SHOULD apply spam prevention / restricted high-quality relays to avoid directing users to malicious mints.
- `a` tag relay hints resolve duplicates claiming to be the same mint.

## Security & privacy notes
- **Funds at risk — this is the mint-trust layer**: choosing a mint via this NIP decides who custodies user funds.
  - A malicious mint operator can publish a polished 38172/38173; without the 38000 WoT layer there is no defense.
  - **Sybil recommendations**: 38000s are cheap to forge at scale; clients must restrict to the user's actual social graph (contact list), not global results.
  - **Duplicate/impersonation announcements**: same mint URL or pubkey claimed by multiple npubs — `d` = mint pubkey (cashu, from `/v1/info`) mitigates because the mint proves key control via its API, but fedimint `d` (federation id) and invite codes have no Nostr-side proof; an attacker can republish a legit federation's invite with malicious wrapper metadata. Verify the `a` pointer and recommender set.
  - Review content is subjective; no slashing/stake behind recommendations.
  - Privacy: recommendations publicly link a user to the mints custoding their funds (financial surveillance metadata).
- NIP-61 explicitly warns about sending to non-signaled mints; NIP-87 is the natural discovery source for populating `kind:10019` mint lists.

## Interoperability notes
- Feeds NIP-60/61 (which mints to hold/receive on), NIP-61's 10019 mint lists; cashu `/v1/info` (NUT-06) provides the mint pubkey used as `d`.

## Example
Real spec recommendation:
```json
{
  "kind": 38000,
  "tags": [
    ["k", "38173"],
    ["d", "<d-identifier>"],
    ["u", "<recommended-fedimint-invite-code>"],
    ["a", "38173:fedimint-pubkey:<d-identifier>", "wss://relay1"]
  ],
  "content": "I trust this mint with my life"
}
```

## Open questions / uncertainties
- No versioning/expiry for recommendations — stale endorsements of since-rugged mints persist.
- No standard scoring/aggregation of multiple recommendations.
- Fedimint announcements lack a cryptographic binding between the announcing npub and the federation.
