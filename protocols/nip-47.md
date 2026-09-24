# NIP-47 — Nostr Wallet Connect (Security Card)

Source: https://github.com/nostr-protocol/nips/blob/master/47.md + swarm security policy (ADR-0004)
Retrieved: 2026-09-23
Status: not formally marked. Security rules below are SWARM POLICY.
Confidence: HIGH for kinds/mechanics; policy = swarm standard v1.

## Mechanics
Wallet service API over Nostr: kind **13194** (wallet info), kinds **23194**/**23195** (encrypted request/response). Connection strings embed a secret.

## Security rules (swarm policy — funds at risk)
1. Connection strings embed secrets in plaintext — treat like passwords: never log, never paste into web pages, never include in screenshots/support bundles, redact in telemetry.
2. Budget enforcement MUST be server-side (wallet-service side), not client courtesy: per-payment limits, daily budgets, allowed-method lists.
3. Standing capability risk: a connected client holds spend capability until revoked — provide revocation UX and audit log of payments.
4. Relay-transport metadata: requests traverse relays; content is encrypted but timing/counterparty metadata is visible — document this to users.
5. Precedent: RUSTSEC-2026-0226 — wallet event parsers accepting unauthenticated events. Verify signatures + expected counterparty pubkey on every wallet event; bound parse inputs.
6. AI boundary (ADR-0002): AI may prepare unsigned payment intents; approval + signing happen in the trusted component.
