# ADR-0004 — Security Coverage Backfill

Status: Accepted (bootstrap challenge resolution) · Date: 2026-09-23
Challenge source: Stage-3 security review findings F5, F6.

## Context
Challenge found: (a) inline protocol constants in agent files had already drifted stale; (b) no NIP-07 treatment (the dominant web key-theft surface); (c) no NIP-47 security card; (d) NIP-46 doc missed auth_url phishing / decryption-oracle / revocation; (e) thin NIP-05 operational guidance; (f) no org-level supply-chain policy; (g) no heightened review bar for AI-generated code.

## Decision
1. Agent files hold NO inline protocol constants — pointers to KB only (F5 post-mortem applied to agents/cryptography.md).
2. protocols/nip-07.md created: web-client key-safety standard (CSP baseline, signer display requirements, XSS hardening, no raw nsec).
3. protocols/nip-47.md created: wallet-connect secret hygiene, budget enforcement, metadata notes.
4. protocols/nip-46.md extended: auth_url phishing, decryption-oracle scoping, session revocation/rate-limit guidance.
5. NIP-05 section extended: DNS-poisoning mechanics, domain-expiry hijack, endpoint monitoring.
6. knowledge/security/SUPPLY-CHAIN.md created: SBOM, release signing/checksums, dependency-advisory response procedure, lockfile rules.
7. code-review agent applies heightened bar to machine-generated diffs (vector/differential tests before human review of generated crypto; provenance labeling).

## Consequences
Backfill artifacts are first-generation and marked as such; they deepen as the swarm does real work.
