# Research Log — Wave 5: IDENTITY, KEYS & MISC cluster

Researcher: NOSTR PROTOCOL DEEP-RESEARCHER (subagent)
Date: 2026-09-23
Method: all 18 files fetched from `https://raw.githubusercontent.com/nostr-protocol/nips/master/<XX>.md` (raw fetch). README.md also fetched to verify listing status. GitHub commits API used for 12/16/20/33 history. All cards written from fetched sources — nothing from memory.

Cards live in `knowledge/nips/NIP-XX.md`.

---

## NIP-06 — Basic key derivation from mnemonic seed phrase
Source: https://github.com/nostr-protocol/nips/blob/master/06.md

- Header: `draft` `unrecommended` `optional`; top warning "unrecommended: prefer a single nsec"; README shows it struck-through as unrecommended.
- BIP39 mnemonic → binary seed; BIP32 path `m/44'/1237'/<account>'/0/0` (coin type 1237 per SLIP44); account 0 for basic clients.
- Fully offline convention; no event kinds, tags, or relay semantics.
- Two full test vectors (mnemonic → hex privkey, nsec, hex pubkey, npub) pin interoperability.
- Risk: mnemonic compromise = all derived accounts; unrecommended because seed handling broadens attack surface vs single nsec.
- Confidence: HIGH.

## NIP-26 — Delegated Event Signing
Source: https://github.com/nostr-protocol/nips/blob/master/26.md

- Header: `draft` `unrecommended` `optional` `relay`; warning "adds unnecessary burden for little gain"; README struck-through.
- `delegation` tag: `[delegator pubkey, conditions query string, 64-byte Schnorr token over sha256("nostr:delegation:<delegatee>:<conditions>")]`.
- Conditions: `kind=<n>`, `created_at<<ts>`, `created_at><ts>`, combined with `&`; advisories to always bound both sides of `created_at`.
- Relays should dual-index `authors` queries over pubkey + delegation tag and allow delegator deletion of delegatee events.
- Unrecommended because relay validation/indexing burden outweighs gain; NIP-46 remote signing covers the cold-key use case.
- Full worked example with real keys/token in spec. Confidence: HIGH.

## NIP-37 — Draft Wraps
Source: https://github.com/nostr-protocol/nips/blob/master/37.md

- `draft` `optional`. Kind 31234 = encrypted draft wrap (NIP-44-to-self of JSON-stringified unsigned draft); blank content = deleted.
- Kind 1234 = checkpoint/revision referencing parent via `a` tag `31234:<pubkey>:<d>`.
- Kind 10013 = private-content relay list; relay URLs in NIP-44-encrypted private tags; MUST publish 10013 to NIP-65 write relays; drafts SHOULD go to 10013 relays; those relays SHOULD be NIP-42-authed.
- `k` tag (required) names the draft's kind; NIP-40 `expiration` recommended.
- Note: spec's `"expiration", "now + 90 days"` is a placeholder, not a real timestamp. Confidence: HIGH.

## NIP-48 — Bridged events
Source: https://github.com/nostr-protocol/nips/blob/master/48.md

- `draft` `optional`. `["proxy", <id>, <protocol>]` tag marks event as bridged from another protocol; any kind.
- Protocol table: activitypub (URL), atproto (AT URI), rss (URL + guid fragment), web (URL); extensible.
- Use: dedupe bridged duplicates, link to source. Trust is reputational — tag is self-asserted, no cryptographic proof of mirroring.
- References FEP-fffd Proxy Objects and the Mostr bridge. Confidence: HIGH.

## NIP-49 — Private Key Encryption (`ncryptsec`)
Source: https://github.com/nostr-protocol/nips/blob/master/49.md

- `draft` `optional`. Password → NFKC normalization → scrypt(password, salt=16 random bytes, log_n (1 byte), r=8, p=1) → 32-byte key → XChaCha20-Poly1305 encrypt 32 raw privkey bytes with key-security byte as associated data.
- Payload = concat(version 0x02, LOG_N, SALT, NONCE(24B), ASSOCIATED_DATA, CIPHERTEXT) = 91 bytes → bech32 hrp `ncryptsec`.
- LOG_N cost table: 16→64MiB/~100ms, 18→256MiB, 20→1GiB/~2s, 21→2GiB, 22→4GiB.
- Key-security byte: 0x00 known-insecure handling, 0x01 not-known-insecure, 0x02 untracked.
- Scrypt justified as maximally memory-hard (preferred over argon2); XChaCha20-Poly1305 over AES. Never publish ncryptsec to Nostr; zero memory of keys/passwords.
- NFKC test vector (U+212B U+2126 U+1E9B U+0323 → U+00C5 U+03A9 U+1E69) + decryption vector (password 'nostr', log_n=16 → hex key `3501...8683`). Confidence: HIGH.

## NIP-55 — Android Signer Application
Source: https://github.com/nostr-protocol/nips/blob/master/55.md

- `draft` `optional`. Three transports: **Intents** (UI approval; result extras `result`/`id`/`event`/`package`/`rejected`; non-OK resultCode = signer crash, RESULT_OK+rejected=true = user rejection; batch via singleTop flag + `results` array), **Content Resolver** (background `content://<pkg>.<TYPE>` queries, selectionArgs `[payload, pubkey, current_user]`, only for remembered permissions; `rejected` column means don't fall back to Intent), **Web** (`nostrsigner:` URL with `type`/`pubkey`/`callbackUrl`/`returnType`/`compressionType` query params; gzip results prefixed `"Signer1"`; clipboard fallback; NIP-46 recommended instead).
- Methods: get_public_key, sign_event, nip04/nip44 encrypt+decrypt, decrypt_zap_event; `permissions` objects `{type, kind?}` pre-authorize background calls.
- Setup: client declares `nostrsigner` scheme in manifest queries; MUST address requests to stored signer package name (anti-interception).
- Threat notes: scheme spoofing, over-broad remembered permissions, clipboard exfiltration. Confidence: HIGH.

## NIP-73 — External Content IDs
Source: https://github.com/nostr-protocol/nips/blob/master/73.md

- `draft` `optional`. `i` tag = external ID value; `k` tag = ID type for filtering. Optional 3rd-element URL hint.
- 12 ID types: web URL (normalized, no fragment), isbn (no hyphens), geo (lowercase geohash), iso3166 (uppercase), isan (no version part), doi (lowercase), `#` hashtag, podcast:guid / podcast:item:guid / podcast:publisher:guid, blockchain tx/address (`<chain>:[<chainId>:]tx|address:<id>`).
- Normalization rules are the interop core (ISBN hyphenless, ISO uppercase, geohash lowercase, etc.).
- Privacy: geohash/address references are easily correlated. Confidence: HIGH.

## NIP-92 — Media Attachments Metadata (`imeta`)
Source: https://github.com/nostr-protocol/nips/blob/master/92.md

- No status marker line in the file at all (title only) — "not formally marked".
- Variadic `imeta` tag, space-delimited key/value pairs; MUST have `url` + ≥1 other field; SHOULD match a URL in content; one imeta per URL; MAY include any NIP-94 field.
- Client behaviors: add metadata after upload; MAY prefetch pasted URLs to compute metadata; MAY ignore non-matching imeta.
- Space-delimited parsing vs multi-word values (e.g. alt text) is an implicit convention — noted as open question. Confidence: HIGH.

## NIP-94 — File Metadata
Source: https://github.com/nostr-protocol/nips/blob/master/94.md

- `draft` `optional`. Kind 1063, content = caption. Tags: url, m (lowercase MIME), **x = sha256 of file as served**, **ox = sha256 of original pre-server-transformation**, plus size, dim, magnet, i (infohash), blurhash, thumb, image, summary, alt, fallback (repeatable), service (e.g. NIP-96).
- x/ox pair distinguishes current bytes from original bytes — integrity + provenance.
- Not expected in social/longform clients; aimed at file-indexing relays and file-sharing clients.
- Schema reused inline by NIP-92 imeta. Confidence: HIGH.

## NIP-A4 — Public Messages
Source: https://github.com/nostr-protocol/nips/blob/master/A4.md

- `draft` `optional`. Kind 24 plaintext public message to ≥1 receivers via `p` tags; no `e` tags, no threads/chatrooms; notification-screen UX.
- Routing: MUST send to each receiver's NIP-65 inbox relays + sender's outbox relay.
- Integrations: NIP-40 expiration recommended; NIP-18 `q`; reactions/zaps MUST set `k=24`; nevent1 links MUST include kind 24; NIP-92 imeta SHOULD for media.
- Explicit warning: zero privacy, signed/public; must not be confused with NIP-17 kind-14 DM rumors. Confidence: HIGH.

## NIP-BE — Nostr BLE Communications Protocol
Source: https://github.com/nostr-protocol/nips/blob/master/BE.md

- `draft` `unrecommended` `optional`; warning: "only implemented once and unclear whether it works, requires review".
- BLE emulation of WS relay: service UUID `0000180f-…`, Nordic UART GATT with write char `87654321-…` and read/notify char `12345678-…`; role = highest device UUID becomes server; fixed-role UUIDs all-F (server)/all-0 (client).
- Framing: DEFLATE-compress NIP-01 message, split into `[2-byte index][chunk][1-byte last-flag]` batches; one message at a time; MTU negotiated; 64KB max.
- Sync: NIP-77 negentropy adapted to half-duplex write-success/read-message rounds ending in EOSE; event spread rules for both peer roles.
- Open issues: reference Kotlin chunker uses 1-byte index vs spec's 2-byte header; no BLE-layer pairing/encryption requirement. Confidence: HIGH.

## NIP-C7 — Chats
Source: https://github.com/nostr-protocol/nips/blob/master/C7.md

- `draft` `optional`. Chat message = kind 9; reply = kind 9 quoting parent with `q` tag (NIP-18).
- Chat views MUST fetch only kind 9 to keep context consistent across clients; other kinds MAY be quoted.
- Kind 9 doubles as the recommended inner message kind inside NIP-EE MLS groups. Confidence: HIGH.

## NIP-CC — Geocaching Events
Source: https://github.com/nostr-protocol/nips/blob/master/CC.md

- `draft` `optional`. Kinds: 37516 listing (addressable), 7516 found log, 1111 comment log (NIP-22; `t` = dnf|note|maintenance|archived), 7517 verification (signed by cache's verification key), 37517 curation list.
- Listing tags: d, name, g (multi-precision geohash), D/T 1–5, S size, t type, n modifiers, hint, mission ("Key Quest"), image, r, verification, F (winner lock-in).
- Verified finds: QR at cache exposes verification privkey → finder signs kind 7517 → embeds in kind 7516; validation checks sig + finder pubkey + naddr.
- `n` modifiers categorized (claim semantics: `first-to-find` with F-tag lock-in against forged `created_at`; prize nature: `art`); ≤1 per category; unknown ignored.
- Client guidance: ROT13 hints, DNF-pattern health detection, ≥8-char geohash (≥9 micro). Confidence: HIGH.

## NIP-EE — E2EE Messaging using MLS
Source: https://github.com/nostr-protocol/nips/blob/master/EE.md

- `final` `unrecommended` `optional`; warning: "superseded by the Marmot Protocol" (github.com/marmot-protocol/marmot).
- Goals: private + confidential DMs/groups, forward secrecy + post-compromise security, large-group scaling (linear→log vs Signal), multi-device.
- Kinds: 443 KeyPackage (tags mls_protocol_version/ciphersuite/extensions/client/relays/`-`), 444 Welcome (NIP-59 gift-wrapped, MUST never be signed), 445 Group event (fresh ephemeral keypair per event; `h` = nostr group id), 10051 KeyPackage relay list.
- kind-445 content: TLS-serialized MLSMessage NIP-44-encrypted using a keypair derived from the MLS `exporter_secret` (32 bytes, label `nostr`, rotated per epoch) as private key.
- Credentials: BasicCredential with identity = Nostr pubkey (immutable); MLS signing key MUST differ from identity key, MUST rotate regularly; required extensions required_capabilities, ratchet_tree, nostr_group_data (+last_resort recommended).
- nostr_group_data extension: nostr_group_id, name, description, admin_pubkeys (client-enforced admin model), relays.
- Commit race resolution: relay ack before self-apply; conflicts → lowest created_at, tie → lowest id; keep prior state briefly.
- Identity-key compromise doesn't decrypt MLS messages; large-group (>150) welcomes exceed event size — unresolved; superseded by Marmot. Confidence: HIGH.

---

## Special investigation: what are 12.md / 16.md / 20.md / 33.md?

**Finding: all four are withdrawn-by-merge stubs, not abandoned drafts.** Each still carries `final` `mandatory` markers but its body was replaced with a pointer to NIP-01. They are deliberately unlisted in README (verified: README.md contains no reference to 12.md/16.md/20.md/33.md or NIP-12/16/20/33).

Evidence:

- **12.md** (103 bytes): "NIP-12 — Generic Tag Queries. `final` `mandatory`. Moved to NIP-01." Original content = `#<tag>` filter queries.
- **16.md** (95 bytes): "NIP-16 — Event Treatment. `final` `mandatory`. Moved to NIP-01." Original = regular/replaceable/ephemeral event classes.
- **20.md** (95 bytes): "NIP-20 — Command Results. `final` `mandatory`. Moved to NIP-01." Original = `OK` relay messages.
- **33.md** (165 bytes): "NIP-33 — Parameterized Replaceable Events. `final` `mandatory`. Renamed to 'Addressable events' and moved to NIP-01." Original = d-tag/addressable events.
- Git history (GitHub commits API): commit **"merge nips 12, 16, 20 and 33 into nip 01 (#703)"**, authored 2023-08-13 (committer Viktor Vsk), hollowed out all four; 33.md received a later touch on 2024-08-20 via **PR #1418 "rename 'parameterized replaceable event' to 'addressable event'"** to update the stub wording.
- Interpretation: the files persist so historical links/citations (many NIPs reference "NIP-33 addressable events") resolve, but they are not standalone specs. Cards written with **Status: unlisted/withdrawn**.

Sources:
- https://github.com/nostr-protocol/nips/blob/master/12.md , /16.md , /20.md , /33.md
- https://github.com/nostr-protocol/nips/blob/master/README.md (listing absence)
- https://api.github.com/repos/nostr-protocol/nips/commits?path=12.md and ?path=33.md (merge commit evidence)
