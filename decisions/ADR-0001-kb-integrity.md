# ADR-0001 — Knowledge-Base Integrity & Re-Verification Gate

Status: Accepted (bootstrap challenge resolution) · Date: 2026-09-23
Challenge source: Stage-3 security review findings F2, F5, W1, W2.

## Context
The KB is the oracle every agent consults. At bootstrap it had no integrity mechanism: the verifier only checked marker strings, "append-only" was a convention, Tier-1 sources were mutable HEADs, and a single agent's research became KB without corroboration. Finding F5 proved drift was already live.

## Decision
1. Every KB/protocol entry continues to carry Source / Retrieved / Status / Confidence.
2. **Staleness TTL:** entries older than 90 days must be re-verified against their source before security-critical use; the re-verification is recorded (new Retrieved date + note).
3. **Corroboration:** security-critical claims (crypto constants, advisories, auth semantics) require two independent retrievals or one retrieval + one Tier-1 cross-check before Confidence: HIGH.
4. **Pinning:** Tier-1 GitHub sources are cited with commit SHA where feasible (nips README pinned at 1185974a...); upstream drift on a pinned source is a reviewable event, not silent change.
5. A content-hash manifest over knowledge/, protocols/, sources/ SHOULD be produced at release packaging time.

## Consequences
Slower KB updates; higher trust. Verifier v2 checks marker coverage across all of knowledge/.

## Alternatives rejected
- "Trust the research agents" — rejected: F2/F5 demonstrate single-agent error channels.
- Full signed-git-notary infrastructure — deferred as over-engineering for a markdown KB (revisit if the KB gains downstream automated consumers).
