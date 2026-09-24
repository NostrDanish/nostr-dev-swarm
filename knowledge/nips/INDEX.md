# NIP Index — Living Registry

Per-NIP deep cards live alongside this index as `NIP-NN.md` files (71 cards, spec-read 2026-09-23, cross-checked by an independent verifier — see `sources/research/` and the cross-verification summary). External registries (registry-of-kinds, NKBIPs, Marmot kinds): `EXTERNAL-REGISTRIES.md`.

Source: https://github.com/nostr-protocol/nips (master), README SHA 1185974a48f42e018c12cb346536b331cd7bfff9
Retrieved: 2026-09-23
Confidence: HIGH for listing/status; per-NIP detail files in this folder inherit the confidence of their sources.

Status legend: `final` / `draft` / `mandatory` / `optional` / `relay` = literal markers from the NIP file header; **unrecommended** = struck through in the README; *unmarked* = no formal status in README or file. The README assigns no final/draft labels itself.

| NIP-01 | Basic protocol flow | draft, mandatory | Core event format, signatures, filters, WS protocol |
| NIP-02 | Follow List | final, optional | Kind-3 contact lists |
| NIP-03 | OpenTimestamps Attestations | UNRECOMMENDED | Vulnerable to one specific attack, needs update |
| NIP-04 | Encrypted DM (legacy) | UNRECOMMENDED | Deprecated in favor of NIP-17 |
| NIP-05 | DNS-based identifiers | final, optional | /.well-known/nostr.json name→pubkey |
| NIP-06 | Mnemonic key derivation | UNRECOMMENDED | Prefer a single nsec |
| NIP-07 | window.nostr | unmarked | Browser extension signer interface |
| NIP-08 | Handling Mentions | UNRECOMMENDED | Deprecated in favor of NIP-27 |
| NIP-09 | Event Deletion Request | draft, optional | Kind-5 deletion via e/a tags |
| NIP-10 | Text Notes and Threads | unmarked | Kind-1 threading |
| NIP-11 | Relay Information Document | draft, optional | Relay metadata + limitation advertisement |
| NIP-13 | Proof of Work | unmarked | nonce tag PoW |
| NIP-14 | Subject tag | unmarked | subject tag |
| NIP-15 | Marketplace | UNRECOMMENDED | Too complicated; use NIP-99 |
| NIP-17 | Private Direct Messages | draft, optional | NIP-44+NIP-59 gift-wrapped DMs |
| NIP-18 | Reposts | unmarked | Kinds 6/16 |
| NIP-19 | bech32 entities | draft, optional | npub/nsec/note/nprofile/nevent/naddr |
| NIP-21 | nostr: URI scheme | unmarked | URI prefix |
| NIP-22 | Comment | unmarked | Kind-1111 scoped comments |
| NIP-23 | Long-form Content | draft, optional | Kind-30023 Markdown articles |
| NIP-24 | Extra metadata fields | unmarked | Extra kind-0 fields |
| NIP-25 | Reactions | draft, optional | Kind 7 / kind 17 external |
| NIP-26 | Delegated Event Signing | UNRECOMMENDED | delegation tag |
| NIP-27 | Text Note References | unmarked | nostr: references |
| NIP-28 | Public Chat | UNRECOMMENDED | Use NIP-29 instead |
| NIP-29 | Relay-based Groups | unmarked | Kinds 9000–9030, 39000-9 |
| NIP-30 | Custom Emoji | unmarked | emoji shortcode tags |
| NIP-31 | Unknown Events alt | UNRECOMMENDED | Unnecessarily bloated |
| NIP-32 | Labeling | unmarked | Kind-1985 labels |
| NIP-34 | git stuff | unmarked | Repos/patches/PRs/issues |
| NIP-35 | Torrents | unmarked | Kinds 2003/2004 |
| NIP-36 | Sensitive Content | unmarked | content-warning tag |
| NIP-37 | Draft Events | unmarked | Encrypted drafts 31234/1234 |
| NIP-38 | User Statuses | unmarked | Kind-30315 |
| NIP-39 | External Identities | unmarked | Kind-10011 |
| NIP-40 | Expiration Timestamp | unmarked | expiration tag |
| NIP-42 | Client Auth to Relays | draft, optional | AUTH, kind 22242 |
| NIP-43 | Relay Access Metadata | unmarked | Restricted-relay membership |
| NIP-44 | Encrypted Payloads v2 | optional | ECDH+HKDF+ChaCha20+HMAC, padded |
| NIP-45 | Counting | unmarked | COUNT message |
| NIP-46 | Remote Signing | unmarked (no header) | Bunker protocol, kind 24133 |
| NIP-47 | Nostr Wallet Connect | unmarked | 13194/23194/23195 |
| NIP-48 | Bridged Events | unmarked | proxy tag |
| NIP-49 | Private Key Encryption | unmarked | ncryptsec |
| NIP-50 | Search Capability | draft, optional | search filter field |
| NIP-51 | Lists | draft, optional | Standard lists/sets, encrypted items |
| NIP-52 | Calendar Events | unmarked | 31922–31925 |
| NIP-53 | Live Streaming/Spaces | unmarked | 1311, 10312, 30311–30313 |
| NIP-54 | Wiki | unmarked | 30818/30819/818 |
| NIP-55 | Android Signer App | unmarked | Intent/ContentResolver signer API |
| NIP-56 | Reporting | unmarked | Kind-1984 |
| NIP-57 | Lightning Zaps | draft, optional | 9734/9735 via LNURL |
| NIP-58 | Badges | unmarked | 30009/8/30008/10008 |
| NIP-59 | Gift Wrap | optional | rumor→seal(13)→wrap(1059/21059) |
| NIP-60 | Cashu Wallet | unmarked | 17375, 7374–7376 |
| NIP-61 | Nutzaps | unmarked | 9321, 10019 |
| NIP-62 | Request to Vanish | unmarked | Kind-62 global deletion |
| NIP-64 | Chess (PGN) | unmarked | Kind 64 |
| NIP-65 | Relay List Metadata | draft, optional | Kind-10002 outbox model |
| NIP-66 | Relay Discovery/Liveness | unmarked | 30166/10166 |
| NIP-67 | EOSE Completeness Hint | unmarked | EOSE hint |
| NIP-68 | Picture-first feeds | unmarked | Kind-20 |
| NIP-69 | P2P Order events | unmarked | Kind-38383 |
| NIP-70 | Protected Events | unmarked | `-` tag, authed-author-only writes |
| NIP-71 | Video Events | unmarked | 21/22, 34235/34236 |
| NIP-72 | Moderated Communities | UNRECOMMENDED | Use NIP-29 instead |
| NIP-73 | External Content IDs | unmarked | i/k tags |
| NIP-75 | Zap Goals | unmarked | Kind-9041 |
| NIP-77 | Negentropy Syncing | draft, optional | NEG-* set reconciliation |
| NIP-78 | Application-specific data | draft, optional | Kinds 78/30078 |
| NIP-84 | Highlights | unmarked | Kind-9802 |
| NIP-85 | Trusted Assertions | unmarked | 30382–30384 |
| NIP-86 | Relay Management API | draft, optional | JSON-RPC admin + NIP-98 auth |
| NIP-87 | Mint Discoverability | unmarked | 38172/38173 |
| NIP-88 | Polls | unmarked | 1068/1018 |
| NIP-89 | App Handlers | draft, optional | 31989/31990 |
| NIP-90 | Data Vending Machines | UNRECOMMENDED | 5000–7000; prefer microstandards |
| NIP-92 | Media Attachments (imeta) | unmarked | imeta tag |
| NIP-94 | File Metadata | draft, optional | Kind-1063 |
| NIP-96 | HTTP File Storage | UNRECOMMENDED | Replaced by Blossom |
| NIP-98 | HTTP Auth | draft, optional | Kind-27235 Authorization header |
| NIP-99 | Classified Listings | draft, optional | 30402/30403 |

Hex-lettered NIPs (not matched by numeric tooling): NIP-5A (nsites), NIP-7D (forum threads), NIP-A0 (voice), NIP-A3 (payto: targets), NIP-A4 (public messages), NIP-B0 (bookmarks), NIP-B7 (Blossom), NIP-BE (BLE, unrecommended), NIP-C0 (code snippets), NIP-C7 (chats), NIP-CC (geocaching), NIP-EE (MLS E2EE, unrecommended — superseded by Marmot), NIP-F4 (podcasts).

## Maintenance rules
1. Re-verify against https://github.com/nostr-protocol/nips before relying on any entry; record new Retrieved: date on change.
2. Repo files 12.md, 16.md, 20.md, 33.md exist but are NOT README-listed — they are withdrawn stubs merged into NIP-01 (PR #703, 2023-08-13); see their cards.
3. The README is not exhaustive; machine-readable registry: https://github.com/nostr-protocol/registry-of-kinds.
4. Specification vs convention vs implementation reality must be distinguished in every entry.
