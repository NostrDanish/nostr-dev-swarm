# NIP-39 — Linking Profiles to Other Platforms

Source: https://github.com/nostr-protocol/nips/blob/master/39.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Lets users declare control over identities on other platforms (GitHub, Twitter/X, Mastodon, Telegram) via `i` tags in a `kind:10011` "External Identities" event, each with a verifiable proof pointing back to the user's npub.

## Event kinds
| kind | class | role |
|------|-------|------|
| 10011 | replaceable | External identities claim list |

## Tags defined/used
- `i` (repeated): `["i", "<platform>:<identity>", "<proof>"]` — MUST have exactly two parameters:
  1. `platform:identity` — platform name + identity joined with `:`.
  2. `proof` — string or object pointing to proof of ownership.
- Platform names SHOULD contain only `a-z`, `0-9`, `._-/` and MUST NOT contain `:`.
- Identity names SHOULD be normalized to lowercase; primary alias preferred.

## Content format
Not used; claims live entirely in tags.

## Semantics & rules
- Clients SHOULD process `i` tags with MORE than 2 values for future extensibility (don't choke on extra entries).
- Claim types and proof formats:
  - `github`: identity = GitHub username; proof = Gist ID. Gist by `<identity>` with a single file containing `Verifying that I control the following Nostr public key: <npub>`. Verify at `https://gist.github.com/<identity>/<proof>`.
  - `twitter`: identity = Twitter username; proof = Tweet ID containing `Verifying my account on nostr My Public Key: "<npub>"`. Verify at `https://twitter.com/<identity>/status/<proof>`.
  - `mastodon`: identity = `<instance>/@<username>`; proof = post ID containing `Verifying that I control the following Nostr public key: "<npub>"`. Verify at `https://<identity>/<proof>`.
  - `telegram`: identity = Telegram numeric user ID; proof = `<ref>/<id>` pointing to a message in public channel/group `<ref>` with message ID `<id>`, containing the verification text. Verify at `https://t.me/<proof>`.

## Security & privacy notes
- Verification requires fetching third-party platforms: proofs can be deleted or platforms can be down/API-gated (Twitter proofs are effectively unverifiable post-API-lockdown — widely known operational caveat).
- Claims are self-published; clients MUST verify the external proof before trusting — an unverified `i` tag proves nothing.
- Linking identities publicly correlates the nostr key with real-world/platform accounts — privacy cost by design.
- Proof text binds npub→platform but verification of the reverse direction (platform→this specific nostr event) relies on the claim event's signature.

## Interoperability notes
- Kind 10011 registered in README kind table. NIP-73 later generalized `i` tags for external content IDs (different purpose). In practice many clients rely more on NIP-05 for identity; NIP-39 verification UIs are rare.

## Example
```yaml
{
  "kind": 10011,
  "tags": [
    ["i", "github:semisol", "9721ce4ee4fceb91c9711ca2a6c9a5ab"],
    ["i", "twitter:semisol_public", "1619358434134196225"],
    ["i", "mastodon:bitcoinhackers.org/@semisol", "109775066355589974"],
    ["i", "telegram:1087295469", "nostrdirectory/770"]
  ]
}
```
(from spec)

## Open questions / uncertainties
- Only 4 platforms defined; no registry process for new ones (extensibility via extra tag values is hinted).
- Twitter claim type predates X API restrictions; current verifiability is doubtful (not addressed in spec).
