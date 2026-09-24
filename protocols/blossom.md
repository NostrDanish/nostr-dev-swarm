# Blossom — Blobs Stored Simply on Media Servers (NIP-B7)

Source: https://github.com/hzrd149/blossom (spec repo) + NIP-B7 in https://github.com/nostr-protocol/nips
Retrieved: 2026-09-23
Status: NIP-B7 not formally marked; ecosystem active.
Confidence: HIGH.

## Model
HTTP servers store binary blobs addressed by their SHA-256 hash. Uploads and management are authorized by signed Nostr events (kind **24242** auth events). Specs are split into BUD documents (BUD-01 … BUD-12) in the spec repo. Users advertise their servers in kind **10063** (server list).

## Key properties
- Content addressing by SHA-256 → integrity by construction, dedup across users, portable across servers.
- Auth = signed event, not accounts — consistent with Nostr identity model.
- Replaces NIP-96 HTTP File Storage (96.md marked unrecommended: "replaced by Blossom"; kind 10096 deprecated).

## Implementations / tooling
- blossom-server (Deno reference) — https://github.com/hzrd149/blossom-server
- blossom-client-sdk — https://github.com/hzrd149/blossom-client-sdk
- blossom-audit (server audit CLI) — https://github.com/hzrd149/blossom-audit
- primal-blossom-server (Rust) — https://github.com/PrimalHQ/primal-blossom-server
- Morganite (Android Blossom cache) — greenart7c3
- Client support: noStrudel, nostr-sdk (Blossom client), nostr4j, nostrcheck-server

## Swarm guidance
- For new media/file features: Blossom first, not NIP-96.
- Always verify blob hash after download; treat server responses as untrusted.
- Threat-model upload authorization: replay of kind-24242 auth events, storage-quota abuse, illegal-content takedown semantics per server policy.
- Multi-server mirroring for availability; hash addressing makes this cheap.

## See also
protocols/blossom-buds.md for the BUD-by-BUD breakdown.
