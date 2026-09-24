# Test Plan — Swarm Bootstrap Validation

Retrieved/created: 2026-09-23

## Scope
Validating the swarm scaffold itself (this repo), not a software product.

## Checks (automated — verifier/v1/check.sh)
1. Directory structure complete (agents/, knowledge/*, protocols/, decisions/, threat-models/, test-plans/, sources/, architecture/).
2. 15 agent role files present and non-trivial.
3. knowledge/nips/INDEX.md lists ≥30 NIPs with status.
4. knowledge/event-kinds/REGISTRY.md lists ≥20 named kinds.
5. All nips+protocols files carry Source:/Retrieved: markers (versioned knowledge).
6. Required protocol docs present: nostr, nip-01, nip-44, nip-46, nip-50, nip-77, blossom.
7. Challenge artifacts: ≥1 threat model, ≥1 ADR, ≥1 source registry, challenge record.
8. No placeholder text.

## Checks (human/agent — Stage 3 challenge)
1. Protocol challenger: spot-verify KB claims against https://github.com/nostr-protocol/nips; flag inventions/staleness.
2. Security challenger: red-team the scaffold (what does this org design get wrong about security/privacy?).
3. Findings recorded in decisions/ + threat-models/; KB corrections applied.

## Regression rule
Any future KB update must re-run verifier checks and keep markers/citations intact. Later verifier versions (v2 integrity, v3 coverage) extend this gate.
