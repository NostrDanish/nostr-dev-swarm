# Verifier v1 — acceptance criteria for NOSTR DEV SWARM deliverable

Checks (all must pass):

1. STRUCTURE
   - Top-level dirs exist: agents/, knowledge/, protocols/, architecture/, decisions/,
     threat-models/, test-plans/, sources/
   - knowledge/ has subdirs: nips/, event-kinds/, tags/, relays/, clients/, sdk/,
     security/, cryptography/, networking/
   - 15 agent files in agents/: chief-architect, nostr-protocol, security-redteam,
     cryptography, networking, backend, frontend, rust-systems, devops-sre,
     qa-testing, performance, privacy, research, code-review, product-ux (.md)
   - README.md and OPERATING_MANUAL.md exist at root.

2. KNOWLEDGE BASE CONTENT
   - knowledge/nips/INDEX.md exists and lists >= 30 NIPs with status + source URL.
   - knowledge/event-kinds/ registry exists and lists >= 20 kinds.
   - Every .md file in knowledge/nips/ and protocols/ contains the marker
     "Source:" and "Retrieved:" (versioned-knowledge rule).
   - protocols/ contains at least: nostr.md, nip-01.md, nip-44.md, nip-46.md,
     nip-50.md, nip-77.md, blossom.md.

3. CHALLENGE LOG
   - threat-models/ contains >= 1 threat model file.
   - decisions/ contains >= 1 ADR file.
   - sources/ contains >= 1 source-registry file.
   - A challenge record exists (decisions/ or threat-models/ file mentioning
     findings from protocol + security challengers).

4. NO PLACEHOLDERS
   - No file contains "TODO: fill" or "lorem ipsum".

Implementation: check.sh (bash) returns exit 0 on pass, prints FAIL lines otherwise.
