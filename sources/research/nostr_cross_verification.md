# Nostr Deep Research — Cross-Verification Summary

Retrieved: 2026-09-23
Scope: Round-1 bootstrap KB + Round-2 deep-research expansion (6 waves, 71 new per-NIP cards + adjacent-protocol files).

## Verification tiers

### HIGH CONFIDENCE (independently verified against live specs)
- Round-1: 8/8 mandated claim sets verified by protocol challenger against nostr-protocol/nips @ SHA 1185974a (kind ranges, NIP-44 v2 construction + extended padding, NIP-46 methods, NIP-59 layers, NIP-77 messages + 0x61, NIP-98, NIP-65, unrecommended set). RustSec advisory batch + nsecbunkerd incident confirmed via independent sources.
- Round-2: 12-card adversarial sample (NIP-02, 22, 29, 45, 47, 49, 54, 60, 66, 71, 86, EE) + EXTERNAL-REGISTRIES.md + marmot.md — ALL VERIFIED against live specs; zero factual errors in kinds/tags/constants/statuses.
- Suspicious-claim resolutions: NIP-43 dual kinds 33534/13534 TRUE; Marmot KeyPackage 443→30443 + 10051 dropped TRUE (nips README kind table is stale on this); NIP-02 `final` header TRUE.

### MEDIUM CONFIDENCE
- NKBIP tag-level details (wikistr JS-rendered; verified via GitHub mirrors; marked MEDIUM in card).
- Ecosystem activity statuses (GitHub metadata; commit-level freshness not always confirmed).

### LOW / UNRESOLVED
- Relay census numbers (Aug 2025 probe) — attributed, not re-verified.
- NIP-03's referenced attack: undocumented in spec; unknown.
- NIP-A3 kind 10133: appears only in the spec's example, not prose.

## Conflict zones discovered (documented, not averaged away)
1. Kind 10011 collision: README → NIP-39 External Identities; 51.md → "Favorite follow sets". Flagged in REGISTRY.md.
2. NIP-66 `timeout` tag: spec prose vs example contradict on argument order. Flagged in card.
3. NIP-F4: prose says 10164, example/README say 10064. Flagged in card.
4. `i`-tag semantic overload across NIPs 22/24/25/39/73 (different meanings per context).
5. NIP-71 references `service nip96` while README marks NIP-96 unrecommended (replaced by Blossom).
6. Marmot kind churn: adopted spec (30443, no 10051) vs nips README table (443/444/445/10051). Spec wins; registry stale.
7. i-tag/payment ambiguities: NIP-90 designed-in payment ambiguity; NIP-99 currency unit-confusion hazard.

## Corrections applied from challenges
- Round-1: q-tag attribution (NIP-18), NIP-98 SHOULD-vs-MUST, NIP-77 fingerprint endianness/varint, REGISTRY completeness + collision flags, advisory version floors.
- Round-2: NIP-29 card — three should-level rules inflated to MUST, corrected with inline notes; NIP-99/NIP-23 spec example placeholder text neutralized.
- Security challenge (round 1): ADR-0001..0005; org threat model; NIP-07/47 cards; NIP-46 attack scenarios; supply-chain policy.

## Residual risk
Unsampled cards (~59) verified only by their authors' spec-reads; sampling covered the highest-risk clusters (money, crypto, relay admin). Recommend periodic re-verification per ADR-0001 TTL rule.
