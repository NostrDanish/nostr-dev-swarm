# Verifier v2 — acceptance criteria

Extends v1 (v1 checks still run). New checks per ADR-0005:

1. Marker coverage extended: ALL .md files under knowledge/ (not just nips/) must
   contain "Source:" and "Retrieved:" (or an explicit "swarm policy" marker for
   org-authored standards).
2. README provenance honesty: README's challenge claims require the artifacts to
   exist — threat-models/ORG-THREAT-MODEL.md and decisions/ADR-0001..0005.
3. Drift guard: agents/*.md must NOT embed the NIP-44 padding constants
   (post-mortem F5) — grep for "65536" / "extended prefix" in agents/ must fail.
4. Weak-rule regressions: README/OPERATING_MANUAL must not reintroduce the
   "silently" loophole next to the signing boundary rule.

check.sh exits 0 only if v1 AND v2 checks pass.
