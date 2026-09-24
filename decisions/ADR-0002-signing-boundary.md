# ADR-0002 — Signing Boundary as an Enforced Component

Status: Accepted (bootstrap challenge resolution) · Date: 2026-09-23
Challenge source: Stage-3 security review findings F1, W3, W5.

## Context
The rule "AI never silently holds authority over keys/signing" was policy text: the qualifier "silently" was a loophole, the Policy Engine was unspecified, and nothing forbade secrets entering agent contexts. Nostr has no key rotation — one violation is terminal.

## Decision
1. The word "silently" is deleted from the ground rule. AI **never** holds authority over: private keys, signing, financial transactions, security-critical authorization, production credentials, destructive infrastructure operations.
2. **No secrets in prompts, ever.** No nsec, ncryptsec passphrase, API token, or production credential may enter an agent context. Agents handle unsigned intents and public data only.
3. The pipeline `AI → Unsigned Intent → Policy Engine → Human/Trusted Approval → Signer → Network` is a REQUIRED component for any swarm-built system touching signing. The Policy Engine minimum spec: capability-scoped permissions (method[:kind] style, cf. NIP-46), append-only action log, enumerated forbidden operations, human-approval UX designed against fatigue (batching forbidden, per-action context display).
4. Gated operations (require security-redteam review before merge/deploy): authentication flows, key handling, crypto code paths, signer configuration, production credential handling, destructive infra.

## Consequences
Some architectures become impossible (AI-as-signer); that is the point. Approval UX becomes a first-class design problem (product-ux agent).

## Alternatives rejected
- Policy-text-only boundary — demonstrably unenforceable (F1).
- AI signing "for low-value keys" — rejected: value changes; keys don't rotate.
