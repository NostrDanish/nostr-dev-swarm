# Supply-Chain & Release Policy

Source: swarm policy (ADR-0004), informed by the nsecbunkerd repo-wipe incident (2026-06) and the RUSTSEC-2026-08 advisory batch (see ADVISORIES.md)
Retrieved: 2026-09-23
Confidence: swarm standard v1.

## Dependency rules
1. Lockfiles are mandatory and reviewed in PRs (unexpected transitive changes = review event).
2. SBOM generated for every release artifact.
3. Version pinning with hash verification where the ecosystem supports it.
4. Dependency-advisory response procedure: monitor RustSec / GitHub Advisories per stack; on advisory → assess exposure → patch floor from the advisory (never guess) → regression test → release note.
5. "Maintained" is never inferred from `pushed_at` (nsecbunkerd was wiped upstream while looking active). Check for substantive commits, release signing, and maintainer announcements.

## Release rules
1. Releases are signed (GPG/cosign-class) with published checksums; verify-before-run instructions in every release note.
2. Reproducible builds where the toolchain allows.
3. No bare archives without checksums (post-mortem: bootstrap packaging originally planned a bare tar.gz).

## CI/CD rules
1. CI runs the verifier/test suite from OUTSIDE the artifact's write path (ADR-0005).
2. Secrets never enter agent contexts or CI logs (ADR-0002); OIDC/short-lived credentials preferred over static tokens.
3. Build provenance attestations (SLSA-style) for security-critical artifacts.

## Relay-side operational standard (retention)
1. Default log-retention table per deployment: access logs minimal fields, no event-content logging, no Authorization headers (NIP-98 events are signed identity material), IP retention minimized, deletion enforced not promised.
2. Debug-logging toggles must not silently re-enable sensitive fields — reviewed as a security change.
