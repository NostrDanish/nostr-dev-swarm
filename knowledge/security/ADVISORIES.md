# Security Knowledge Base — Known Advisories & Attack Surface

Source: https://rustsec.org/advisories/ + sources/research/ecosystem-map-2026-09-23.md §E
Retrieved: 2026-09-23
Confidence: HIGH for RustSec entries; MEDIUM otherwise.

## RustSec batch 2026-08-01/02 — rust-nostr crates

| ID | Severity | Crate | Issue |
|---|---|---|---|
| RUSTSEC-2026-0224 | HIGH | nostr-relay-pool | Verification-cache poisoning: forged events bypass signature validation (CVSS 7.5; patched ≥0.44.2) |
| RUSTSEC-2026-0231 | HIGH | nostr-relay-pool | Unbounded NIP-42 AUTH challenge queue → memory DoS by malicious relay (fix in 0.44.x line; verify exact floor in the advisory before pinning) |
| RUSTSEC-2026-0232 | HIGH | nostr-relay-pool | Processing of unverified relay events |
| RUSTSEC-2026-0243 | INFO | nostr-relay-pool | Declared unmaintained |
| RUSTSEC-2026-0225 | — | nostr | Debug output exposes NIP-46/NIP-60 credentials |
| RUSTSEC-2026-0226 | — | nostr | Wallet event parsers accept unauthenticated events |
| RUSTSEC-2026-0227 | — | nostr | NIP-44 v2 decryption resource exhaustion |
| RUSTSEC-2026-0228 | — | nostr | NIP-04 malformed-ciphertext memory amplification |
| RUSTSEC-2026-0229 | — | nostr | NIP-98 parsing resource exhaustion |
| RUSTSEC-2026-0230 | — | nostr | Empty NIP-50 filter panic |

Lesson for the swarm: even the flagship SDK had verification-bypass and resource-exhaustion bugs. Signature verification MUST happen before any caching/processing; untrusted input sizes MUST be bounded at every layer.

## Protocol-level security facts
- No key rotation/revocation exists in Nostr (no NIP-41) — key compromise is terminal. Custody quality is critical.
- NIP-44 v2 limitations (per spec): no deniability, no forward secrecy, no post-compromise or post-quantum security, IP/date/partial-size leakage.
- Zap receipts (9735) are NOT proof of payment — clients MUST validate receipt pubkey == LNURL nostrPubkey + amount match (NIP-57).
- NIP-05 is identification, NOT verification; endpoint MUST NOT redirect; fetchers MUST ignore redirects.
- NIP-46 bunker `secret` MUST be validated to prevent connection spoofing.
- NIP-17 clients MUST verify seal pubkey == rumor pubkey (anti-impersonation).
- nsecbunkerd deletion incident (2026-06): repo emptied upstream — supply-chain trap; never treat pushed_at as "maintained".

## Relay-side abuse mitigations observed in the wild
strfry write-policy plugins · nostream NIP-13 PoW · khatru RejectConnection hooks · rnostr whitelist/blacklist · wot-relay WoT filtering · NIP-70 protected events · NIP-42 auth-gated writes (NIP-78/30078, NIP-17 gift wraps).

## Audit status
No public third-party security audits of strfry / nostr-rs-relay / nostream were found (unverifiable ≠ absent). NIP-44 v2 was audited by Cure53 (Dec 2023).
