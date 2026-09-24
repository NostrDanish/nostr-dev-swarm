# Threat Model — The Swarm Organization Itself

Created: 2026-09-23
Source: Stage-3 security/red-team challenge of the bootstrap scaffold (independent reviewer subagent)
Retrieved: 2026-09-23
Status: Baseline org threat model; revisit whenever ground rules or KB pipeline change.

This file records the security challenge of the swarm's own design. Findings F1–F7 with the standard schema; weak rules W1–W8; resolutions tracked in decisions/ADR-0001..0005.

## F1 — AI signing boundary is policy text with no enforcement mechanism — HIGH
- Threat: agent or prompt-injected orchestrator drifts across the signing boundary (generates key-touching code, self-signs to production relays, instructs a signer directly).
- Impact: Terminal — Nostr has no key rotation/revocation.
- Likelihood: Medium-high in autonomous operation. The word "silently" in the ground rule was a literal loophole (fixed — see ADR-0002).
- Attack surface: the Policy Engine in `AI → Unsigned Intent → Policy Engine → Approval → Signer → Network` was unspecified (no capability model, audit trail, forbidden-ops list, sandboxing); no rule forbidding secrets in agent contexts.
- Mitigation: ADR-0002 (Policy Engine as specified component; "silently" deleted; no-secrets-in-prompts rule).
- Residual risk: approval fatigue; compromise of the signer component itself (nsecbunkerd precedent).

## F2 — KB poisoning path; verifier cannot detect a lie — HIGH
- Threat: malicious/erroneous entry enters sources/research/ and is distilled into knowledge/; or quiet post-hoc edit. Downstream agents consume it as verified truth.
- Impact: corrupts the oracle every role consults; fabricated constants/advisories flow into future builds stamped "Confidence: HIGH".
- Likelihood: Medium. Enablers found: verifier only grepped for marker strings; no integrity manifest/hashes; "append-only" was convention not mechanism; no corroboration rule; Tier-1 includes mutable GitHub master HEADs (nsecbunkerd repo-wipe precedent).
- Mitigation: ADR-0001 (content-hash manifest, two-agent corroboration for security-critical entries, SHA pinning, drift = review event, 90-day TTL).
- Residual risk: colluding verifier agent; legitimate-but-wrong upstream edits.

## F3 — Indirect prompt injection via the source/KB pipeline — HIGH
- Threat: external content carries adversarial instructions aimed at agents reading it. Scaffold treated external text as untrusted facts but not as untrusted instructions.
- Impact: full org compromise via the read path — the KB every agent is mandated to read.
- Likelihood: Medium and rising; the design maximizes exposure by design ("KB, not prompts, holds facts").
- Mitigation: ADR-0003 (content-is-data rule, ingestion quarantine, prompt-injection personas added to red-team mode).
- Residual risk: model-level susceptibility; injection smuggled in legitimate spec text.

## F4 — False provenance risk: claims ahead of artifacts — HIGH (was live at bootstrap)
- Threat: README claimed "challenged by independent reviewers" while decisions/ and threat-models/ were empty and the verifier was failing.
- Impact: inverted trust signal at the layer the org sells ("Verifiable > Trusted").
- Status at writing: RESOLVED for bootstrap — this file + ADRs now exist; verifier v2 asserts claim↔artifact consistency (ADR-0005).
- Mitigation: ADR-0005; gate handoff on PASS; FAIL runs are blockers, not footnotes.

## F5 — Live drift defect: stale crypto constant in agent file — MEDIUM severity / HIGH diagnostic value
- agents/cryptography.md embedded a superseded NIP-44 padding limit ("65536 cap") contradicting knowledge/cryptography/PRIMITIVES.md and protocols/nip-44.md (6-byte extended prefix, max 2^32−1). External spot-check confirmed KB correct, agent file stale.
- Impact: interop failure now; demonstrates the duplicated-constant drift class.
- Mitigation: constant stripped from the agent file → pointer to KB (fixed 2026-09-23); verifier v2 scans agents/ for embedded protocol constants (ADR-0004/0005).
- Residual risk: semantic (wording) drift still slips pattern checks.

## F6 — Coverage gaps — MEDIUM
1. NIP-07 key-theft surface undocumented → protocols/nip-07.md created (ADR-0004).
2. NIP-47 (wallet connect) funds-at-risk untreated → protocols/nip-47.md created.
3. NIP-46 doc missed auth_url phishing, decryption-oracle scoping, revocation/rate-limits → added to protocols/nip-46.md.
4. NIP-05 operational guidance thin (DNS poisoning, domain-expiry hijack, endpoint monitoring) → added to protocols/nip-05-09-11-19-51-57.md.
5. No org-level supply-chain policy → knowledge/security/SUPPLY-CHAIN.md created (SBOM, release signing, advisory-response).
6. Relay log retention had principle but no operational standard → SUPPLY-CHAIN.md + nip-07 standards include retention defaults.
7. AI-generated code needed a heightened review bar → added to code-review operating rules (ADR-0004).

## F7 — Gift-wrap metadata under-modeled — LOW
- Global passive adversary / relay collusion can correlate 1059 p-tags across relays → social graph reconstruction despite wrapping; kind-10050 DM relay lists are public metadata; NIP-42 AUTH pubkey↔connection binding lacks mitigation guidance.
- Mitigation: documented in protocols/nip-17.md / nip-42.md; privacy agent must name the adversary each mitigation does NOT defeat.
- Residual risk: HIGH against state-level correlators — users must be told.

## Weak rules (W1–W8) → resolutions
| # | Defect | Resolution |
|---|---|---|
| W1 | "aging" undefined | ADR-0001: 90-day TTL for security-critical entries |
| W2 | "critical" undefined, self-attested re-checks | ADR-0001: re-verification recorded as artifact |
| W3 | "silently" loophole | ADR-0002: word removed; boundary = component |
| W4 | append-only log unenforced | ADR-0005: git-tracked + CI-run verification |
| W5 | sign-off without gate mechanics | ADR-0002: enumerated gated operations |
| W6 | marker checks covered only nips/+protocols/ | verifier v2: all of knowledge/ checked |
| W7 | verifier inside its own trust domain | ADR-0005: external/CI run path |
| W8 | reviewer "independence" undefined | ADR-0005: separate-context requirement for challengers |
