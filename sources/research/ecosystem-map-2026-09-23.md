# Nostr Implementation Ecosystem Map — Research Report

Retrieved: 2026-09-23
Sources: official GitHub repos (verified via GitHub API / repo opens), crates.io, npm, pub.dev, Maven Central, RustSec, maintainer docs.
Researcher: nostr-ecosystem-researcher (explore subagent)

## A. RELAY IMPLEMENTATIONS

Field-wide context: a 379-relay probe (Aug 2025, https://github.com/chr15m/nostr-relay-research) found strfry (129), nostr-rs-relay (84), nostream (33), haven (27), wot-relay (10), khatru (10) dominant. Declared NIP support: NIP-11 ×324, NIP-42 ×97, NIP-77 ×66, NIP-86 ×57, NIP-50 ×9.

### strfry
- C++ · https://github.com/hoytech/strfry (723★, updated 2026-09-22 — active)
- LMDB storage, no external DB; zero-downtime restarts; hot config reload
- NIPs: 1, 2, 4, 9, 11, 22, 28, 40, 42 (auth), 45, 70, 77 (negentropy — flagship)
- Abuse controls: write-policy plugin system; connection/subscription limits
- Most-deployed relay; default on Umbrel

### nostr-rs-relay
- Rust · https://github.com/scsibug/nostr-rs-relay (GitHub mirror; master at https://git.sr.ht/~gheartsfield/nostr-rs-relay) — active; crate v0.8.12
- SQLite (experimental PostgreSQL)
- NIPs per README: 01, 02, 05, 09, 11, 12, 15, 16, 20, 22, 26 (disabled), 28, 33, 40, 42, 91. No NIP-77 yet (open issue #234). NIP-50/86 not listed.
- Rate limiting/quotas via config.toml

### khatru
- Go · https://github.com/fiatjaf/khatru — ARCHIVED on GitHub; development moved to `fiatjaf.com/nostr` monorepo (https://pkg.go.dev/fiatjaf.com/nostr/khatru)
- Framework for custom relays (hook-based: RejectConnection/RejectEvent/RejectFilter; policies.PreventLargeTags, NoComplexFilters)
- NIPs: 11, 42, 77 (Negentropy flag), 86 (HandleNIP86), 70 protected events
- Rate limiting via RejectConnection hooks; used by Pyramid, relay29 ecosystem

### nostream
- TypeScript · https://github.com/Cameri/nostream (829★, updated 2026-09-20 — active; MIT)
- PostgreSQL 14 + Redis + Node 18; Docker; Tor/I2P options
- NIPs per README: 01, 02, 04, 09, 11 (+11a), 12, 13 (PoW), 15, 16, 20, 22, 26 (removed), 28, 33, 40. NIP-42/50/77/86 not in README's list.
- Positioned for paid relays

### rnostr
- Rust · https://github.com/rnostr/rnostr (120★, updated 2026-09-12 — active; crates.io v0.4.8)
- NIP-42 auth with whitelist/blacklist, event-author filtering, per-connection rate limiting; benchmark tool rnostr/nostr-bench

### relayer (+ "Relayer Basic")
- Go · https://github.com/fiatjaf/relayer (framework; legacy/maintenance). "Relayer Basic" = its `basic/` reference implementation. Superseded in practice by khatru/fiatjaf.com.

### Other notable active relays
- haven — https://github.com/bitvora/haven (Go, personal/whitelist)
- wot-relay — https://github.com/bitvora/wot-relay (WoT-filtered)
- chorus — https://github.com/mikedilger/chorus (Rust, personal)
- pyramid — https://github.com/fiatjaf/pyramid (invite-hierarchy, khatru)
- frith — https://github.com/coracle-social/frith (invite codes)
- Citrine — Android on-device relay by greenart7c3 (NIP-77 since v3.0.0)
- netstr — https://github.com/bezysoftware/netstr (C#/Postgres)
- nost-py — https://github.com/UTXOnly/nost-py (Python)
- relay.nostr.band — proprietary closed-source large indexer relay

## B. CLIENTS

| Client | Platform | Repo | Status | Notable |
|---|---|---|---|---|
| Damus | iOS/macOS (Swift) | https://github.com/damus-io/damus | Active (2026-09-21) | Zaps, nostrdb search, NIP-46 signer for QR login, Notedeck spin-off |
| Amethyst | Android, desktop early (Kotlin) | https://github.com/vitorpamplona/amethyst | Active (2026-09-22) | Broadest NIP coverage; Quartz lib; Amber signer; GPG-verifiable APKs + SECURITY.md |
| Primal | Web (SolidJS), Android, iOS | https://github.com/PrimalHQ/primal-web-app (+ -android-app, -ios-app) | All active | Hosted caching service; Julia backend https://github.com/PrimalHQ/primal-server (old caching-service archived) |
| Snort | Web (React/TS) | https://github.com/v0l/snort | Activity uncertain | worker-relay package reused by others |
| Coracle | Web (Svelte) | https://github.com/coracle-social/coracle | Active (2026-09-22) | Multi-relay power features, WoT moderation, NIP-42 |
| Iris | Web | https://github.com/irislib/iris-client (old mmalmi/iris removed) | Active | nostr-social-graph WoT, nostr-double-ratchet chat |
| noStrudel | Web/PWA (React/TS) | https://github.com/hzrd149/nostrudel | Active (v1.1.0) | NIPs 07, 17, 42, 44, 49, 51, 57, 65, 66, 90; Blossom; Docker/Umbrel/Start9 |
| Nosotros | Web | repo NOT verified on GitHub | — | NIP-42 compat, offline mode |
| Nostur | iOS/macOS | https://github.com/nostur-com/nostur-ios-public | Active | Multi-account, NIP-42 |
| Gossip | Desktop (Rust) | https://github.com/mikedilger/gossip | Active | NIP-46 bunker mode, relay whitelisting, SpamSafe |
| Flotilla | Web (relay groups) | https://github.com/coracle-social/flotilla | Active (v1.3.1) | Relays-as-groups model |
| Jumble | Web/PWA | https://github.com/codytseng/jumble | Active | Relay-feed browsing |

## C. SDKs / LIBRARIES

### nostr-tools (JS/TS)
- https://github.com/nbd-wtf/nostr-tools (854★, active; public domain)
- Keys, sign/verify, SimplePool/Relay, NIP-19, NIP-05, NIP-27, NIP-42, NIP-45; full BunkerSigner (bunker:// and nostrconnect://); nip44 module shipped. Companion: @nostr/gadgets (https://github.com/nbd-wtf/nostr-gadgets)

### NDK — Nostr Dev Kit (TS)
- https://github.com/nostr-dev-kit/ndk (423★, active; MIT; npm @nostr-dev-kit/ndk v3.0.3)
- Outbox model (NIP-65), caching adapters (Dexie/SQLite/Redis/memory/relay), sessions, WoT, Svelte/React/RN bindings, mock-relay test utils
- NIPs: 01, 04, 07, 17, 22, 23, 29, 42, 44, 46 (nsecBunker, permission tokens, OAuth flow), 47, 57, 59, 60, 61, 65, 77 (@nostr-dev-kit/sync), 89, 90

### nostr-sdk (Rust + bindings)
- https://github.com/nostrdevkit/nostr (org renamed from rust-nostr; 674★, active; MIT). Crate nostr-sdk v0.45.3. Book: rust-nostr.org
- Workspace: nostr core, nostr-relay-pool, nostr-sdk, nostr-connect (NIP-46), nwc (NIP-47), DB backends (LMDB/SQLite/IndexedDB/nostrdb), Blossom client, relay-builder (nostrd: https://github.com/nostrdevkit/nostrd). NIP-44 v2 in core.
- Bindings: https://github.com/nostrdevkit/nostr-sdk-ffi — Python (pypi nostr-sdk), Kotlin/KMP (Maven), Swift, C#. Older binding repos archived.

### go-nostr (Go) — superseded
- https://github.com/nbd-wtf/go-nostr — ARCHIVED. Successor: `fiatjaf.com/nostr` monorepo (nip44/nip46 packages, khatru, eventstore, nip77).

### Python
- https://github.com/jeffthibault/python-nostr — likely stale (~2023–24 last substantive releases; uncertain). Maintained alternative: official nostr-sdk Python bindings. Others: pynostr, nostrkey (NIP-44 + NIP-46 bunker client).

### Dart / Flutter
- Dart NDK: https://github.com/relaystr/ndk (pub.dev ndk 0.10.0-dev.3, active, OpenSats-funded; used by yana, camelus, zap.stream, zapstore)
- dart-nostr: https://github.com/anasfik/nostr (active)
- https://github.com/realmeylisdev/dart_nostr — claims 75+ NIPs (single-author; verify before production)

### Kotlin / JVM
- nostr-sdk Kotlin bindings via nostr-sdk-ffi (Maven Central org.rust-nostr)
- nostr4j: https://github.com/NostrGameEngine/nostr4j (NIPs 01/04/05/07/09/24/39/40/44/46/47/49/50/57, NWC, Blossom)
- cashapp/nostrino (older), nostr-spring-boot-starter (https://github.com/theborakompanioni/nostr-spring-boot-starter)

## D. INFRASTRUCTURE & TOOLING

### Blossom (blob/media)
- Spec: https://github.com/hzrd149/blossom (319★, active) — blobs addressed by SHA-256; uploads authorized by signed kind-24242 events (BUD-01…BUD-12)
- Impls: blossom-server (Deno ref), blossom-client-sdk, blossom-audit CLI, PrimalHQ/primal-blossom-server (Rust), Morganite (Android cache)

### Negentropy / NIP-77 sync
- Spec: NIP-77. Reference impl: https://github.com/hoytech/negentropy (C++, active); Rust: https://github.com/nostrdevkit/negentropy; TS: @nostr-dev-kit/sync + nostr-tools
- Relay support: strfry (native), khatru flag, Citrine, nogringo/nostr-relay, nostria-app/nostria-relay

### Indexers / crawlers / search
- nostr.band: large proprietary indexer (closed-source core); org https://github.com/nostrband (nostr-embed, noauth, nostrsite)
- nostr.watch: https://github.com/sandwichfarm/nostr-watch (NIP-66 monitoring)
- Coracle Compass: Ansible playbook for strfry kind-10002 indexer
- NIP-50 search rare relay-side (9/379 probed); handled by dedicated relays or client-side

### Signing tools (NIP-46 / NIP-55 / NIP-07)
- Amber — https://github.com/greenart7c3/Amber (Android signer; NIP-46 over relays incl. Tor + NIP-55; per-app permissions; GPG-signed releases; OpenSats-funded)
- nsecbunkerd — https://github.com/kind-0/nsecbunkerd: DEFUNCT — repo emptied 2026-06-02; do not deploy. Successor candidates: Signet (https://github.com/Letdown2491/signet, self-described rewrite), dsbaars/bunker46, workouse/bilo-bunker
- nsec.app / nostrband noauth; nos2x (https://github.com/fiatjaf/nos2x, NIP-07); Aegis (https://github.com/ZharlieW/Aegis); Peridot (desktop bunker); `nak bunker` (https://github.com/fiatjaf/nak)

### NIP-05 services
- nostrcheck-server — https://github.com/quentintaranpino/nostrcheck-server (relay + NIP-05 + NIP-96/Blossom + NWC + WoT)
- NIP-05 can advertise NIP-46 endpoints (`nip46` object in nostr.json)

### DVM (NIP-90) ecosystem
- NIP-90 unrecommended but supported: NDK, noStrudel; libs: forgesworn/toll-booth-dvm, spcpza/nostr-dvm (Python), sebdeveloper6952/adk-nostr (Google ADK over NIP-90), godvm (Go)

## E. SECURITY-RELEVANT RESOURCES

- RustSec advisory batch (2026-08-01/02) against rust-nostr crates (https://rustsec.org/advisories/):
  - RUSTSEC-2026-0224 (HIGH): verification-cache poisoning → forged events bypass signature validation (nostr-relay-pool)
  - RUSTSEC-2026-0231 (HIGH): unbounded NIP-42 AUTH challenge queue → memory-exhaustion DoS by malicious relay; fixed ≥0.44.3
  - RUSTSEC-2026-0232 (HIGH): processing of unverified relay events
  - RUSTSEC-2026-0243 (INFO): nostr-relay-pool unmaintained
  - nostr crate: 0225 (debug output exposes NIP-46/NIP-60 credentials), 0226 (wallet event parsers accept unauthenticated events), 0227 (NIP-44 v2 decryption resource exhaustion), 0228 (NIP-04 malformed-ciphertext memory amplification), 0229 (NIP-98 parsing resource exhaustion), 0230 (empty NIP-50 filter panic)
- Key compromise is terminal: no key rotation/revocation in the protocol (no NIP-41); custody software quality critical
- nsecbunkerd deletion incident (2026-06): supply-chain trap for tooling that reads pushed_at as "maintained"
- Spam/flooding mitigations: strfry write-policy plugins, nostream NIP-13 PoW, khatru RejectConnection hooks, rnostr whitelist/blacklist, wot-relay WoT filtering
- Client key-handling: noStrudel warns against raw nsec (recommends NIP-07 signers / NIP-49 ncryptsec); Amethyst publishes APK fingerprint + SECURITY.md; Amber GPG-signs releases
- No public third-party security audits of strfry/nostr-rs-relay/nostream found — marked unverifiable, not absent

## F. UNCERTAINTIES

- Nosotros: no GitHub repo verified (may be on Nostr-native git/GRASP)
- Snort: updated_at may reflect metadata, not commits
- python-nostr (jeffthibault): treat as stale, not confirmed archived
- Iris: old repo 404; current source at irislib/iris-client (not independently opened)
- Damus NIP matrix not enumerated in README
- nostream: README NIP list may lag code
- "Relayer Basic": the basic/ example inside fiatjaf/relayer; no separate repo
- nostr.band internals closed-source
- khatru/go-nostr archived on GitHub; active development at fiatjaf.com/nostr — GitHub timestamps frozen
