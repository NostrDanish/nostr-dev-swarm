# Relay Implementations — Knowledge Entry

Source: https://github.com/chr15m/nostr-relay-research (379-relay probe, Aug 2025) + individual repos
Retrieved: 2026-09-23
Confidence: HIGH for repo facts; MEDIUM for deployment census (Aug 2025 snapshot).

## Deployment reality (probe, Aug 2025)
strfry 129, nostr-rs-relay 84, nostream 33, haven 27, wot-relay 10, khatru 10.
Declared NIP support: NIP-11 ×324, NIP-42 ×97, NIP-77 ×66, NIP-86 ×57, NIP-50 ×9 (search is rare relay-side).

## Major implementations

### strfry — C++ — https://github.com/hoytech/strfry (active)
- LMDB storage, zero-downtime restarts, hot config reload
- NIPs: 1, 2, 4, 9, 11, 22, 28, 40, 42, 45, 70, 77 (negentropy flagship)
- Write-policy plugin system; connection/subscription limits
- Most-deployed relay; Umbrel default

### nostr-rs-relay — Rust — https://github.com/scsibug/nostr-rs-relay (mirror; master on sourcehut, active)
- SQLite (experimental PostgreSQL)
- NIPs: 01, 02, 05, 09, 11, 12, 15, 16, 20, 22, 26 (disabled), 28, 33, 40, 42, 91. No NIP-77 (open issue #234).
- config.toml rate limiting/quotas

### khatru — Go — https://github.com/fiatjaf/khatru (ARCHIVED; dev moved to fiatjaf.com/nostr monorepo)
- Framework: RejectConnection/RejectEvent/RejectFilter hooks; policies.PreventLargeTags, NoComplexFilters
- NIPs: 11, 42, 77 (flag), 86 (HandleNIP86), 70
- Rate limiting via RejectConnection hooks; powers Pyramid, relay29 ecosystem

### nostream — TypeScript — https://github.com/Cameri/nostream (active, MIT)
- PostgreSQL 14 + Redis + Node 18; Docker; Tor/I2P
- NIPs per README: 01, 02, 04, 09, 11, 12, 13 (PoW), 15, 16, 20, 22, 26 (removed), 28, 33, 40. 42/50/77/86 unlisted (README may lag).
- Paid-relay positioning

### rnostr — Rust — https://github.com/rnostr/rnostr (active)
- NIP-42 auth w/ whitelist/blacklist, author filtering, per-connection rate limiting; nostr-bench benchmark tool

### Others
- haven (Go, personal/whitelist) https://github.com/bitvora/haven
- wot-relay (WoT-filtered) https://github.com/bitvora/wot-relay
- chorus (Rust, personal) https://github.com/mikedilger/chorus
- pyramid (invite hierarchy, khatru) https://github.com/fiatjaf/pyramid
- frith (invite codes) https://github.com/coracle-social/frith
- Citrine (Android on-device; NIP-77 since v3.0.0) — greenart7c3
- netstr (C#/Postgres) https://github.com/bezysoftware/netstr
- nost-py (Python) https://github.com/UTXOnly/nost-py
- relay.nostr.band — proprietary closed-source large indexer
- relayer/"Relayer Basic" (Go) https://github.com/fiatjaf/relayer — legacy; superseded by khatru

## Swarm guidance
- Default self-host recommendation: strfry (performance+negentropy) or nostr-rs-relay (simplicity).
- Custom policy relays: khatru framework (fiatjaf.com/nostr).
- Always read the relay's NIP-11 document before integration; honor `limitation` fields.
- Interop testing must cover ≥3 relay implementations (strfry + nostr-rs-relay + nostream minimum).
