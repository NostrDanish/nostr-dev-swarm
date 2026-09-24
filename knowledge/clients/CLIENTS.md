# Nostr Clients — Knowledge Entry

Source: individual repos (verified 2026-09-23); full citations in sources/research/ecosystem-map-2026-09-23.md
Retrieved: 2026-09-23
Confidence: HIGH for repo facts; activity status as noted.

| Client | Platform | Repo | Status | Notable |
|---|---|---|---|---|
| Damus | iOS/macOS | https://github.com/damus-io/damus | Active | Zaps, nostrdb search, NIP-46 QR signer, Notedeck |
| Amethyst | Android/desktop | https://github.com/vitorpamplona/amethyst | Active | Broadest NIP coverage, Quartz lib, Amber signer, GPG-verified APKs |
| Primal | Web/Android/iOS | https://github.com/PrimalHQ/primal-web-app | Active | Hosted caching, Julia backend primal-server |
| Snort | Web | https://github.com/v0l/snort | Uncertain | worker-relay package reused elsewhere |
| Coracle | Web (Svelte) | https://github.com/coracle-social/coracle | Active | Multi-relay power features, WoT moderation |
| Iris | Web | https://github.com/irislib/iris-client | Active | nostr-social-graph, double-ratchet chat |
| noStrudel | Web/PWA | https://github.com/hzrd149/nostrudel | Active | NIPs 07,17,42,44,49,51,57,65,66,90; Blossom; self-hostable |
| Nosotros | Web | repo NOT verified | — | NIP-42, offline mode |
| Nostur | iOS/macOS | https://github.com/nostur-com/nostur-ios-public | Active | Multi-account, NIP-42 |
| Gossip | Desktop (Rust) | https://github.com/mikedilger/gossip | Active | NIP-46 bunker mode, relay whitelisting, SpamSafe |
| Flotilla | Web | https://github.com/coracle-social/flotilla | Active | Relays-as-groups (NIP-29-style) |
| Jumble | Web/PWA | https://github.com/codytseng/jumble | Active | Relay-feed browsing |

## Swarm guidance
- For interop testing of client features, prioritize: Amethyst (broadest NIP surface), noStrudel (power-user, Blossom), Coracle (WoT/relay features), Damus (iOS zaps), Gossip (desktop/bunker).
- Never paste raw nsec into web clients; use NIP-07 extensions, NIP-46 bunkers, or NIP-55 (Android).
