# SDKs & Libraries — Knowledge Entry

Source: individual repos/package registries (verified 2026-09-23); full citations in sources/research/ecosystem-map-2026-09-23.md
Retrieved: 2026-09-23
Confidence: HIGH.

## By language

### TypeScript / JavaScript
- **nostr-tools** — https://github.com/nbd-wtf/nostr-tools (active, public domain). Low-level: keys, sign/verify, SimplePool, NIP-19, NIP-05, NIP-42, NIP-45, nip44 module, full BunkerSigner (NIP-46 both flows). Companion: @nostr/gadgets.
- **NDK** — https://github.com/nostr-dev-kit/ndk (active, MIT, v3.0.3). High-level: outbox model (NIP-65), cache adapters, sessions, WoT, framework bindings, mock-relay test utils. NIPs incl. 44, 46, 57, 59, 60/61, 65, 77 (@nostr-dev-kit/sync), 89, 90.

### Rust (+ bindings)
- **nostr-sdk** — https://github.com/nostrdevkit/nostr (org renamed from rust-nostr; active, MIT; crate v0.45.3). Full workspace: core, relay-pool, nostr-connect (NIP-46), nwc (NIP-47), DB backends (LMDB/SQLite/IndexedDB/nostrdb), Blossom client, relay-builder. NIP-44 v2 in core.
- Bindings: nostr-sdk-ffi → Python (pypi nostr-sdk), Kotlin/KMP (Maven), Swift, C#.
- ⚠ SECURITY: RustSec advisory batch 2026-08 (RUSTSEC-2026-0224/0225/0226/0227/0228/0229/0230/0231/0232, 0243 unmaintained notice for nostr-relay-pool) — check knowledge/security/ADVISORIES.md before pinning versions; use the advisory-stated patched floors (e.g. ≥0.44.2 for 0224) and verify per advisory.

### Go
- go-nostr (nbd-wtf) ARCHIVED → successor: `fiatjaf.com/nostr` monorepo (nip44, nip46, eventstore, nip77, khatru).

### Python
- jeffthibault/python-nostr — likely stale. Prefer official nostr-sdk Python bindings. Others: pynostr, nostrkey (NIP-44 + NIP-46 bunker client).

### Dart / Flutter
- Dart NDK — https://github.com/relaystr/ndk (active, OpenSats-funded; used by yana, camelus, zap.stream, zapstore)
- dart-nostr — https://github.com/anasfik/nostr (active)

### Kotlin / JVM
- nostr-sdk Kotlin bindings (Maven org.rust-nostr); nostr4j (https://github.com/NostrGameEngine/nostr4j); cashapp/nostrino (older); nostr-spring-boot-starter.

## Selection guidance
- New TS client: NDK (high-level) or nostr-tools (low-level control).
- New service/relay-side Rust: nostr-sdk — but pin against advisory-fixed versions and monitor RustSec.
- Go relay/policy work: fiatjaf.com/nostr + khatru hooks.
- Verify NIP-44 support explicitly before choosing a library for encrypted features.
