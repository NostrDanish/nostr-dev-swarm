# Verifier index (append-only)

## v1 — created 2026-09-23
- Measures: directory structure completeness, 15 agent role files, NIP index breadth
  (>=30 NIPs), event-kind registry breadth (>=20 kinds), versioned-knowledge markers
  (Source:/Retrieved:) on all nips+protocols files, required protocol docs,
  challenge artifacts (threat model, ADR, source registry), placeholder absence.
- First version; no prior baseline.

## v2 — created 2026-09-23
- Extends v1: provenance-marker coverage across ALL of knowledge/; README claim↔artifact
  consistency (threat model + ADR-0001..0005 must exist); drift guard banning embedded
  NIP-44 padding constants in agents/ (post-mortem F5); regression check that the
  "silently" loophole stays removed (ADR-0002).
- Differs from v1: v1 measured structure/breadth; v2 measures integrity properties the
  Stage-3 security challenge exposed.

## v3 — created 2026-09-23 (goal round 2: deep-research expansion)
- Adds: per-NIP card coverage (>=60 cards in knowledge/nips/), card marker/section
  completeness, adjacent-protocol files (marmot, blossom-buds, NEGENTROPY, HISTORY,
  EXTERNAL-REGISTRIES), and >=6 research wave artifacts in /mnt/agents/output/research/.
- Differs from v2: v2 measured integrity; v3 measures depth/coverage of the expanded KB.
