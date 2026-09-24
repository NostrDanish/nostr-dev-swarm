# NIP-CC — Geocaching Events

Source: https://github.com/nostr-protocol/nips/blob/master/CC.md
Retrieved: 2026-09-23
Status: `draft` `optional` (no unrecommended mark)
Confidence: HIGH (spec-read)

## Purpose
Event kinds for decentralized geocaching: create/share geocache listings, log finds (with cryptographic proof-of-presence), file DNF/maintenance reports, and curate lists/trails of caches.

## Event kinds
- `37516` — geocache listing (addressable).
- `7516` — found log (regular).
- `1111` — comment log (NIP-22 comment; log types via `t`).
- `7517` — geocache verification (proof of physical presence, signed by the cache's verification key).
- `37517` — geocache curation list (addressable; adventures/trails/treasure hunts).

## Tags defined/used
**Listing (37516)**: `d` (req), `name` (req), `g` geohash (req; multiple precisions 3–9 chars for proximity search), `D` difficulty 1–5 (req, indexed), `T` terrain 1–5 (req, indexed), `S` size `micro|small|regular|large|other` (req, indexed), `t` cache type (opt; `traditional` default; common: `multi`, `mystery`), `n` type modifiers (opt, ≤1 per category), `hint` (opt plaintext), `mission` (opt "Key Quest" payload; ≤1), `image`, `r` preferred log relays, `verification` (hex pubkey for verifying finds), `F` (opt; locks in first-to-find winner, `["F","<winner-pubkey-hex>"]`).
**Found log (7516)**: `a` = `37516:<pubkey>:<d-tag>` (req), `image` (opt), `verification` (opt, embedded kind-7517 JSON).
**Comment log (1111)**: NIP-22 root+parent tags `A`/`K`/`P` and `a`/`k`/`p` (identical for top-level: the listing, kind 37516, owner pubkey); `t` = `dnf|note|maintenance|archived` (default `note`; `archived` = owner officially retires the cache).
**Verification (7517)**: `a` = `<finder-pubkey-hex>:<geocache-naddr>`; content fixed string `"Geocaching verification for <finder-npub>"` (spec writes "Geocache verification for <finder-npub>").
**Curation list (37517)**: `d`, `title` (req), `a` → 37516/37515 refs (req, 1+, order meaningful), `description`, `image`, `g`, `theme` (`adventure|mojave`), `map` (`original|dark|satellite|adventure`).

## Content format
- 37516: cache description; 7516/1111: log message; 7517: fixed-format string; 37517: full list description.

## Semantics & rules
- **Verified finds**: finder obtains the cache's verification *private key* physically (typically QR at the location), signs a kind-7517 with it, and embeds it in their kind-7516 (and/or publishes standalone). Validation: check 7517 signature against the listing's `verification` pubkey, that the 7517 `a`-tag finder pubkey matches the log author, and the naddr matches the cache.
- **Type modifiers (`n`)**, categorized; ≤1 per category, unknown values ignored (forward compat):
  - *Claim semantics*: `first-to-find` — first verified found log is the exclusive claim; clients render listing as archived once one exists; winner = earliest `created_at` (ties → lowest event id). Because `created_at` is forgeable, the owner SHOULD lock the winner by republishing the listing with `["t","archived"]` **and** an `F` tag; when `F` is present, clients MUST attribute the claim to it regardless of apparent earlier logs.
  - *Prize nature*: `art` — the cache itself is a physical artwork.
- **Clients should**: ROT13 hints to avoid spoilers; infer cache health from recent DNF/maintenance patterns; publish logs to `r`-tag relays; require geohash precision ≥8 chars (≥9 for micro).

## Security & privacy notes
- Proof-of-presence rests entirely on secrecy of the verification private key at the physical site — anyone who photographs the QR can mint "finds" from anywhere; it's presence-*evidence*, not unforgeable proof.
- The `F`-tag lock-in exists precisely because `created_at` is author-supplied and forgeable — anti-backdating for claims.
- Geohash precision requirements limit location leakage in listings; finders posting logs with images may leak EXIF/location.
- Public logs + precise locations create physical-safety considerations for cache owners and finders.

## Interoperability notes
- Built on NIP-22 comments, NIP-33-style addressable coordinates; references NIP-GD Good Deed events for recording mission completions.
- Geohash `g` tags match the wider Nostr location-tagging ecosystem.

## Example
Real spec example (first-to-find art cache):
```json
{
  "kind": 37516,
  "content": "Hand-pulled linocut, edition of 1, signed on the back next to the QR. Whoever finds it keeps it.",
  "tags": [
    ["d", "linocut-aftermath-1748619568671"],
    ["name", "Aftermath (Linocut #1)"],
    ["g", "u4xsu6ry"], ["D", "2"], ["T", "2"], ["S", "small"],
    ["t", "traditional"], ["n", "first-to-find"], ["n", "art"],
    ["verification", "6805d4e5c0df48b4f76e2fdcb67a2acb1d97567b01c6fe17a236dc32f34f1c07"]
  ]
}
```

## Open questions / uncertainties
- Verification-key compromise/removal flow (cache muggled, QR copied) is unspecified.
- `t` is overloaded between cache types (37516) and log types (1111) — context-dependent.
- Exact required string for 7517 content is inconsistently written ("Geocache verification for…").
