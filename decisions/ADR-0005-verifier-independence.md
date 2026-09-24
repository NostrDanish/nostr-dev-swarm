# ADR-0005 — Verifier Independence & Honest Provenance

Status: Accepted (bootstrap challenge resolution) · Date: 2026-09-23
Challenge source: Stage-3 security review findings F4, W4, W6, W7, W8.

## Context
At challenge time the README claimed completed independent review while decisions/ and threat-models/ were empty and the verifier failed. The verifier lived inside the artifact it checked, covered only nips/+protocols/ for markers, and "independence" of challengers was undefined.

## Decision
1. verifier/v2 created (append-only versioning): marker checks extended to ALL of knowledge/; new check that README provenance claims map to real artifacts; new check scanning agents/ for embedded protocol constants.
2. Handoff gate: FAIL runs are blockers. Runs are logged in verifier/runs/ including unpublished ones (trajectory preserved).
3. Verifier SHOULD also run from outside the artifact's trust domain (CI) when this repo is git-hosted; in-sandbox runs are recorded but treated as self-attested.
4. Challenger independence: challengers must run in separate agent contexts from the authors of what they review; a single orchestrator must not author Position A, Position B, and the verdict.
5. Bootstrap status honestly recorded: protocol challenge = PASS (3 minor errors, fixed); security challenge = PASS-WITH-CHANGES (F1–F7; F4/F5 resolved by landing artifacts, rest via ADR-0001..0004).

## Consequences
Verifier claims are checkable; provenance statements are artifacts, not prose.
