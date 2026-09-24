# Nostr NIP Inventory — Tier-1 Research Report

Retrieved: 2026-09-23
Source: https://github.com/nostr-protocol/nips (branch `master`), README.md (SHA `1185974a48f42e018c12cb346536b331cd7bfff9`) and individual NIP files, retrieved via the GitHub API.
Researcher: nostr-protocol-researcher (explore subagent)

Scope note: The repo states: "NIPs listed here are not a protocol checklist… Other standards and NIPs may exist outside this repository." See also the machine-readable registry at https://github.com/nostr-protocol/registry-of-kinds.

## A. NIP TABLE

Statuses in quotes are the literal markers from individual NIP file headers; "unrecommended" marks are struck-through entries in the README itself. Everything else: **status: not formally marked**.

| NIP | Title | Status | Summary |
|---|---|---|---|
| 01 | Basic protocol flow description | `draft` `mandatory` | Core event format, signatures, filters, relay/client websocket protocol. |
| 02 | Follow List | not formally marked | Kind-3 contact lists with petnames and relay hints. |
| 03 | OpenTimestamps Attestations | unrecommended ("vulnerable to one specific attack, needs update") | Anchoring event hashes in Bitcoin (kind 1040). |
| 04 | Encrypted Direct Message | unrecommended (deprecated in favor of NIP-17) | Legacy ECDH+AES-256-CBC DMs (kind 4). |
| 05 | DNS-based identifiers | `final` `optional` | DNS `/.well-known/nostr.json` name→pubkey lookup. |
| 06 | Key derivation from mnemonic | unrecommended ("prefer a single nsec") | BIP39/BIP32-style seed derivation. |
| 07 | `window.nostr` browser capability | not formally marked | Browser-extension signer interface. |
| 08 | Handling Mentions | unrecommended (deprecated in favor of NIP-27) | Old mention convention. |
| 09 | Event Deletion Request | `draft` `optional` | Kind-5 deletion requests via `e`/`a` tags. |
| 10 | Text Notes and Threads | not formally marked | Kind-1 notes and threading. |
| 11 | Relay Information Document | `draft` `optional` | HTTP JSON metadata for relays. |
| 13 | Proof of Work | not formally marked | `nonce` tag PoW commitment. |
| 14 | Subject tag | not formally marked | `subject` tag in text events. |
| 15 | Nostr Marketplace | unrecommended ("too complicated, try 99") | Stalls/products (kinds 30017–30020). |
| 17 | Private Direct Messages | `draft` `optional` | NIP-44/NIP-59 gift-wrapped chat (14, 15, 10050). |
| 18 | Reposts | not formally marked | Kind-6/16 reposts. |
| 19 | bech32 entities | `draft` `optional` | npub/nsec/note/nprofile/nevent/naddr. |
| 21 | `nostr:` URI scheme | not formally marked | URI prefix for bech32 entities. |
| 22 | Comment | not formally marked | Kind-1111 comments with scope tags. |
| 23 | Long-form Content | `draft` `optional` | Kind-30023 Markdown articles. |
| 24 | Extra metadata fields | not formally marked | Extra kind-0 profile fields. |
| 25 | Reactions | `draft` `optional` | Kind-7 reactions; kind-17 external reactions. |
| 26 | Delegated Event Signing | unrecommended; `draft` `unrecommended` `optional` | `delegation` tag signing. |
| 27 | Text Note References | not formally marked | `nostr:` references in content. |
| 28 | Public Chat | unrecommended ("try NIP-29") | Chat channels (kinds 40–44). |
| 29 | Relay-based Groups | not formally marked | Relay-administered groups (9000–9030, 39000-9). |
| 30 | Custom Emoji | not formally marked | `emoji` shortcode tags. |
| 31 | Dealing with Unknown Events | unrecommended ("unnecessarily bloated") | `alt` fallback descriptions. |
| 32 | Labeling | not formally marked | Kind-1985 labels. |
| 34 | `git` stuff | not formally marked | Repos, patches, PRs, issues (1617–1633, 30617, 30618). |
| 35 | Torrents | not formally marked | Kinds 2003/2004. |
| 36 | Sensitive Content | not formally marked | `content-warning` tag. |
| 37 | Draft Events | not formally marked | Encrypted drafts (31234, 1234). |
| 38 | User Statuses | not formally marked | Kind-30315 live status. |
| 39 | External Platform Identities | not formally marked | Kind-10011 identity claims. |
| 40 | Expiration Timestamp | not formally marked | `expiration` tag. |
| 42 | Client authentication to relays | `draft` `optional` | AUTH challenge/response, kind 22242. |
| 43 | Relay Access Metadata | not formally marked | Membership for restricted relays (8000/8001, 13534, 28934-6). |
| 44 | Encrypted Payloads (Versioned) | `optional` | v2 = ECDH+HKDF+ChaCha20+HMAC, padded. |
| 45 | Counting results | not formally marked | `COUNT` message. |
| 46 | Nostr Remote Signing | not formally marked (no status header in file) | Bunker protocol, kind 24133. |
| 47 | Nostr Wallet Connect | not formally marked | Wallet API over Nostr (13194, 23194, 23195). |
| 48 | Bridged Events | not formally marked | `proxy` tag. |
| 49 | Private Key Encryption | not formally marked | `ncryptsec` scrypt/secretbox format. |
| 50 | Search Capability | `draft` `optional` | `search` filter field. |
| 51 | Lists | `draft` `optional` | Standard lists/sets, encrypted private items. |
| 52 | Calendar Events | not formally marked | Kinds 31922–31925. |
| 53 | Live Streaming and Spaces | not formally marked | 1311, 10312, 30311–30313. |
| 54 | Wiki | not formally marked | 30818, 30819, 818. |
| 55 | Android Signer Application | not formally marked | Android signer API. |
| 56 | Reporting | not formally marked | Kind-1984 reports. |
| 57 | Lightning Zaps | `draft` `optional` | Zap requests 9734 / receipts 9735. |
| 58 | Badges | not formally marked | 30009, 8, 30008/10008. |
| 59 | Gift Wrap | `optional` | rumor→seal(13)→gift wrap(1059/21059). |
| 5A | Static Websites (nsites) | not formally marked | 5128, 15128, 35128. |
| 60 | Cashu Wallet | not formally marked | 17375, 7374–7376. |
| 61 | Nutzaps | not formally marked | 9321, 10019. |
| 62 | Request to Vanish | not formally marked | Kind-62 global deletion. |
| 64 | Chess (PGN) | not formally marked | Kind 64. |
| 65 | Relay List Metadata | `draft` `optional` | Kind-10002 outbox model. |
| 66 | Relay Discovery and Liveness | not formally marked | 30166, 10166. |
| 67 | EOSE Completeness Hint | not formally marked | Machine-readable EOSE hint. |
| 68 | Picture-first feeds | not formally marked | Kind-20 pictures. |
| 69 | Peer-to-peer Order events | not formally marked | Kind-38383 orders. |
| 70 | Protected Events | not formally marked | `-` tag, auth-required writes. |
| 71 | Video Events | not formally marked | 21/22, 34235/34236. |
| 72 | Moderated Communities | unrecommended ("try NIP-29") | 34550, 4550. |
| 73 | External Content IDs | not formally marked | `i`/`k` tags. |
| 75 | Zap Goals | not formally marked | Kind-9041 goals. |
| 77 | Negentropy Syncing | `draft` `optional` | `NEG-*` set reconciliation. |
| 78 | Application-specific data | `draft` `optional` | Kinds 78, 30078. |
| 7D | Forum Threads | not formally marked | Kind-11 threads. |
| 84 | Highlights | not formally marked | Kind-9802. |
| 85 | Trusted Assertions | not formally marked | 30382–30384. |
| 86 | Relay Management API | `draft` `optional` | JSON-RPC admin API with NIP-98 auth. |
| 87 | Cashu/Fedimint Discoverability | not formally marked | 38172/38173. |
| 88 | Polls | not formally marked | 1068, 1018. |
| 89 | Recommended Application Handlers | `draft` `optional` | 31989, 31990. |
| 90 | Data Vending Machines | unrecommended ("got totally out of control") | 5000–7000 job kinds. |
| 92 | Media Attachments (`imeta`) | not formally marked | `imeta` tag. |
| 94 | File Metadata | `draft` `optional` | Kind-1063. |
| 96 | HTTP File Storage | unrecommended ("replaced by Blossom") | REST file storage. |
| 98 | HTTP Auth | `draft` `optional` | Kind-27235 Authorization header. |
| 99 | Classified Listings | `draft` `optional` | 30402/30403. |
| A0 | Voice Messages | not formally marked | 1222, 1244. |
| A3 | payto: Payment Targets | not formally marked | 10133. |
| A4 | Public Messages | not formally marked | Kind-24. |
| B0 | Web Bookmarks | not formally marked | 39701. |
| B7 | Blossom | not formally marked | Blob storage via Nostr auth (10063, 24242). |
| BE | Nostr BLE | unrecommended ("only implemented once… requires review") | Nostr over BLE. |
| C0 | Code Snippets | not formally marked | Kind-1337. |
| C7 | Chats | not formally marked | Kind-9. |
| CC | Geocaching | not formally marked | 7516, 7517, 37516, 37517. |
| EE | E2EE via MLS | unrecommended ("superseded by the Marmot Protocol") | MLS group encryption. |
| F4 | Podcasts | not formally marked | 54, 10154. |

Files `12.md`, `16.md`, `20.md`, `33.md` exist in the repo but are NOT listed in the README (withdrawn-by-merge stubs; content verified in wave-5 investigation — see their NIP cards).

## B. EVENT KIND REGISTRY

Sources: README Event Kinds table + 01.md.

### Kind ranges (NIP-01)

| Range | Classification | Meaning |
|---|---|---|
| 1000≤n<10000, 4≤n<45, n==1, n==2 | Regular | Expected to be stored by relays. |
| 10000≤n<20000, n==0, n==3 | Replaceable | Per (pubkey, kind) only latest MUST be stored. |
| 20000≤n<30000 | Ephemeral | Not expected to be stored. |
| 30000≤n<40000 | Addressable | Per (kind, pubkey, `d`) only latest MUST be stored. |

Equal-timestamp replaceable conflicts → lowest id retained. `kind` is 0–65535. NIP-90 reserves 5000–5999 (requests), 6000–6999 (results), 7000 (feedback).

### Named kinds

README states the table "is not exhaustive"; defers to registry-of-kinds. Entries citing NKBIP-01/02/03, nostrocket, joinstr, Marmot are EXTERNAL (non-nips-repo). The full named-kind table is maintained in `knowledge/event-kinds/REGISTRY.md` (with collision flags and external-source markers).

### Message types

Client→relay: `EVENT`, `REQ`, `CLOSE` (NIP-01), `AUTH` (NIP-42), `COUNT` (NIP-45).
Relay→client: `EOSE`, `EVENT`, `NOTICE`, `OK`, `CLOSED` (NIP-01), `AUTH` (NIP-42), `COUNT` (NIP-45).
NIP-77 adds `NEG-OPEN`/`NEG-MSG`/`NEG-ERR`/`NEG-CLOSE`.

## C. STANDARDIZED TAGS

IMPORTANT FINDING: The current README (2026-09-23) NO LONGER contains a standardized-tags table. Only NIP-01 defines base-layer tags:

| tag | meaning | NIP |
|---|---|---|
| e | Event reference: `["e", <id>, <relay?>, <pubkey?>]` | 01 |
| p | Pubkey reference: `["p", <pubkey>, <relay?>]` | 01 |
| a | Addressable reference: `["a", "<kind>:<pubkey>:<d>", <relay?>]` | 01 |

Convention: single-letter tags (a–z, A–Z) are indexed by relays and filterable as `#<letter>`; only first value indexed. Supplementary per-NIP tags tracked in `knowledge/tags/CONVENTIONS.md`.

## D. NOTABLE DETAILS (per-NIP technical notes)

Each cites https://github.com/nostr-protocol/nips/blob/master/<file>. Detailed per-NIP cards now live in `knowledge/nips/NIP-*.md`; this section preserves the original research summary for the highest-importance NIPs.

**NIP-01** (01.md; `draft` `mandatory` `relay`)
- Event: `{id, pubkey, created_at, kind (0–65535), tags, content, sig}`; id = lowercase-hex SHA-256 of UTF-8 JSON `[0, pubkey, created_at, kind, tags, content]` with strict escape list, no whitespace.
- Schnorr/secp256k1 per BIP-340; sig is 64-byte hex over the id.
- Filters: `ids`, `authors`, `kinds`, `#<letter>`, `since`, `until`, `limit`; list values OR-ed, attributes AND-ed, filters OR-ed; 64-char lowercase hex only for ids/authors/#e/#p.
- `limit: 0` → no stored events but EOSE still sent, subscription stays live.
- `OK`/`CLOSED` prefixes: `duplicate`, `pow`, `blocked`, `rate-limited`, `invalid`, `restricted`, `mute`, `error`.

**NIP-05** (05.md; `final` `optional`)
- Kind-0 `nip05` key; GET `https://<domain>/.well-known/nostr.json?name=<local-part>`; `names` map + optional `relays` map.
- "Identification, not verification"; follow pubkeys, never NIP-05 addresses. `_@domain` = root identifier.
- Endpoint MUST NOT return redirects; fetchers MUST ignore redirects; keys lowercase hex.

**NIP-44** (44.md; `optional`)
- Version byte; 0x00 reserved, 0x01 deprecated, 0x02 = ECDH → HKDF-extract (salt "nip44-v2") → per-message HKDF-expand (info = random 32-byte nonce, L=76) → ChaCha20 + HMAC-SHA256; base64.
- Custom powers-of-two padding; 2-byte u16 length prefix (<65536) or 6-byte extended (2 zero + u32); min 1 byte (padded to 32), max 2^32−1.
- Limitations: no deniability, no forward secrecy, no post-compromise/PQ security, metadata leakage; NOT a NIP-04 drop-in; defines no kinds.
- v2 audited by Cure53 (Dec 2023); test vectors at github.com/paulmillr/nip44.

**NIP-46** (46.md; no status header)
- JSON-RPC-like over kind 24133 NIP-44-encrypted events, p-tagging counterparty.
- Bootstrap: `bunker://<signer-pubkey>?relay=&secret=` or `nostrconnect://<client-pubkey>?relay=&secret=&perms=`; secret MUST be validated.
- Methods: connect, sign_event, ping, get_public_key, nip04_encrypt/decrypt, nip44_encrypt/decrypt, switch_relays, logout; perms as `method[:kind]`.
- Three keypairs: client (ephemeral), remote-signer, user. `auth_url` response for out-of-band auth; NIP-05/NIP-89 signer discovery.

**NIP-57** (57.md; `draft` `optional`)
- Kind 9734 zap request NOT published; sent via LNURL callback as `nostr` param. LNURL server must advertise allowsNostr + nostrPubkey; description hash commits to zap request.
- Kind 9735 receipt: p, P, e/a, bolt11, description (zap request JSON), optional preimage. NOT proof of payment — clients MUST validate receipt pubkey == nostrPubkey and amount match.
- `zap` tags for weighted splits.

**NIP-59** (59.md; `optional` `relay`)
- rumor (unsigned, deniable) → seal (kind 13, signed by real author, empty tags) → gift wrap (1059, random one-time key, p-tag recipient). 21059 = ephemeral variant.
- All NIP-44; randomized past timestamps; relays should require AUTH for gift wraps, serve 1059 only to p-tagged recipient.

**NIP-65** (65.md; `draft` `optional`)
- Kind 10002, `r` tags with read/write markers. Outbox model: read from author's write relays, mentions from read relays; publish to author write + tagged users' read + propagate 10002. Keep 2–4 relays per category.

**NIP-77** (77.md; `draft` `optional` `relay`)
- Negentropy v1 range-based set reconciliation; binary hex-encoded. NEG-OPEN/NEG-MSG/NEG-ERR/NEG-CLOSE; separate sub-id namespace.
- Reconciliation yields ID sets only; transfer via normal EVENT/REQ. Version byte 0x61 for v1.

**NIP-98** (98.md; `draft` `optional`)
- Kind 27235 ephemeral; content SHOULD be empty; required `u` (absolute URL) and `method` tags; optional `payload` = SHA-256 of body. `Authorization: Nostr <base64(event)>`; server checks kind, ~60s window, URL match, method match; failures SHOULD → 401.

## E. DISAGREEMENTS / UNCERTAINTIES

1. No standardized-tags table in current README (verified 2026-09-23); older revisions had one. Any "complete tag registry" requires non-Tier-1 reconstruction.
2. Status granularity inconsistent: README marks only unrecommended NIPs (03, 04, 06, 08, 15, 26, 28, 31, 72, 90, 96, BE, EE); file headers carry draft/optional/mandatory/final/relay. NIP-05 is the only `final`. NIP-46 has NO status header. (Wave-1 later found NIP-02's file header also carries `final`.)
3. README list vs repo files mismatch: 12.md/16.md/20.md/33.md exist but unlisted — RESOLVED by wave-5: withdrawn-by-merge stubs (PR #703, 2023-08-13), retained for link stability.
4. Kind registry includes external sources (NKBIP-*, nostrocket, joinstr, Marmot); kind 32267 listed with empty NIP column.
5. NIP-44 padding spec evolved: current 44.md has 6-byte extended length prefix for ≥65536-byte plaintext; older copies only document 2-byte u16.
6. Deprecated-but-listed entries retain kinds in registry (4, 40–44, 34550, 5000–7000, 10096).
7. Direct raw.githubusercontent.com access failed in research environment; content retrieved via GitHub API with file SHAs recorded.
