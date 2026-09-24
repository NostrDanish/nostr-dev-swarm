# Nostr Wave-6 Research — Adjacent Protocols & External Registries

Retrieved: 2026-09-23
Scope: everything around the core NIP list that lives in external registries, adjacent protocol repos, and the surrounding design literature.
Source tiering: Tier 1 = spec repos (GitHub, wikistr mirrors of signed content), Tier 2 = project docs / reference implementations / academic papers, Tier 3 = blogs/news (labeled where used).

---

## 1. registry-of-kinds (nostr-protocol/registry-of-kinds)

Repo: https://github.com/nostr-protocol/registry-of-kinds (Tier 1)

- **Purpose**: machine-readable registry of Nostr event kind definitions, intended to supersede the human-curated "Event Kinds" table in the nips README. The nips README itself says: "This table is not exhaustive. For a machine-readable registry of all known event kinds prefer https://github.com/nostr-protocol/registry-of-kinds (or alternative registries following the same YAML schema)."
- **Origin**: kind definitions are "based on" a Nostr long-form event (naddr viewable at njump.me).
- **Structure**: the entire registry is a **single YAML file**, `schema.yaml` (~78 KB, ~4,590 lines as of 2026-09-23), plus a `browser/` directory containing a small Vite/JS web viewer.
  - Top of file: YAML anchors defining reusable *tag shapes* (`_profile`, `_event`, `_addr`, `_kind`, `_rtag`, `_imetatag`, `_emojitag`, `_ptag`, `_etag`, `_qtag`, `_ktag`, `_gtag`, `_servertag`, etc.).
  - A `generic_tags:` section defines globally applicable tags: `t` (lowercase), `L`/`l` (NIP-32 labels), `expiration` (NIP-40 timestamp), `h` (group id).
  - A `kinds:` map keyed by kind number. Each entry has `description`, `in_use` (bool), `content` type (`json` / `free`), `multiple` (tags allowed to repeat), and `tags:` — a list of tag-shape descriptors. Tag shapes are typed chains: e.g. an `e` tag is `type: id` → optional `relay` → optional `pubkey`; constrained markers (e.g. `either: [reply, root]`) model NIP-10 positional markers.
- **Registration policy**: "Any reasonable event definition can be added here. Implementation and how-to-use guides must exist elsewhere." i.e., it is a permissive schema registry, not a governance gate. Contributions via GitHub PRs to `schema.yaml`.
- **Consumption**: usable "to automatically validate events (by relays at the time of event ingestion, for example)". fiatjaf's `nak` CLI implements this: `nak validate` validates events against the registry.
- **Relationship to nips README table**: complementary. The README table maps kind → NIP document (prose spec); registry-of-kinds gives a machine-checkable event schema with no semantics/prose. Alternative registries "following the same YAML schema" are explicitly blessed.

## 2. NKBIPs — Nostr Knowledge Base Interoperability Proposals (wikistr.com ecosystem)

Canonical texts are published as Nostr wiki articles on wikistr.com under author pubkey `fd208ee8c8f283780a9552896e4823cc9dc6bfd442063889577106940fd927c1` ("liminal"): the nips README links `[NKBIP-01/02/03]` there (Tier 1). wikistr.com itself is JS-rendered; full texts verified via the AsciiDoc/Markdown mirrors in https://github.com/decent-newsroom/newsroom/tree/master/documentation/NKBIP (Tier 2 mirror) and the earlier draft at https://github.com/limina1/NKBIPs (Tier 1 repo, Nov 2023).

**NKBIP-01 — Curated Publications** (`draft`/`mandatory`, author: liminal):
- Kind `30040` **Publication Index** (addressable): table of contents. `content` MUST be empty; MUST have `title` tag; identified by `d`+`pubkey`+`kind` (d normalized like NIP-54); MUST list `a` tags in display order (`["a","<kind:pubkey:dtag>","<relay hint>","<event id>"]` — the optional event-id 4th element pins a version); MUST have `auto-update` tag (`yes|ask|no`); derivative works MUST carry `p` (original author) + `E` (original event). MAY have `source`, `i` (ISBN etc.), `version`, `type` (`book|illustrated|magazine|documentation|academic|blog`).
- Kind `30041` **Publication Content** (sections/chapters/"zettels"): MUST have `d` and `title`; `content` is display text, MAY be AsciiDoc, MAY contain wikilinks `[[...]]`.
- The earlier Nov-2023 draft used stringified-JSON content and `e` tags in the index; the current spec moved to empty content + `a` tags.
- Wikistr also defines a `bookstr` macro `[[type:book chapter:verse | version]]` (e.g. `[[bible: John 3:16 | KJV]]`) for section references.

**NKBIP-02 — Vector Embeddings** (`draft`/`optional`):
- Kind `1987`: embedding labels for an event. Required tags: `e` (embedded event id, +relay hint), `model` (name+version+optional download link), `type` (text/image/audio/video), `vector` (comma-separated floats). Optional: `dims`, `norm` (normalized [0,1]), `hash`/`hash_type` (model verification), `source` (original text inline). Motivation: compute embeddings once, reuse for semantic search, recommendation, clustering, multimodal AI.
- nips README maps kind `1987` → "AI Embeddings / Vector lists | NKBIP-02".

**NKBIP-03 — Citations**:
- Four reference kinds: `30` internal Nostr reference (`c` tag = `<kind>:<pubkey>:<hex id>`), `31` external web reference (`u` URL tag, `accessed_on`), `32` hardcopy reference (`page_range`, `doi`, `published_in`, etc.), `33` prompt reference (`llm` tag naming the model — citation of AI-generated content). `content` = cited text.
- Markup scheme for embedding citations in content: `[[citation::end|foot|foot-end|inline|quote::nevent1...]]` and AI variants `[[citation::prompt-end|prompt-inline::...]]`.
- nips README maps kinds 30–33 → "internal/external web/hardcopy/prompt reference | NKBIP-03".

**Wider NKBIP family** (per nostr.blue's implementation docs, Tier 2): NKBIP-04 Directory System (kinds 30042–30045: drives/directories/tracebacks/symlinks), NKBIP-06 Nostr MIME types (`M` tag), NKBIP-08 Book wikilinks (`book::` macro). Implementations: Alexandria, nostr.blue, wikistr.

## 3. Marmot Protocol (MLS-based E2EE group messaging)

### Status history
- **NIP-EE** ("E2EE Messaging with MLS") was merged into nostr-protocol/nips on 2025-08-27 (PR #1427), defining kinds 443 (KeyPackage), 444 (Welcome), 445 (Group Event), 10051 (KeyPackage Relays List). NIP-EE is now flagged "unrecommended — superseded by Marmot Protocol".
- The spec then lived as **MIPs 00–05** (Marmot Improvement Proposals): MIP-00 Credentials & KeyPackages, MIP-01 Group Construction & `marmot_group_data` extension, MIP-02 Welcome events, MIP-03 Group messages, MIP-04 Encrypted media, MIP-05 Push notifications (draft), MIP-06 Multi-device (branch draft).
- **As of 2026-09-23 the MIPs are deprecated**: the repo now holds a reorganized "Status: adopted" spec split by surface — `foundation/` (identity, encodings, registries, errors), `protocol-core/` (group flows), `app-components/` (versioned MLS `app_data_dictionary` payloads), `transports/` (Nostr, QUIC), `features/` (encrypted media, push notifications, multi-device).

### Wire format (current adopted Nostr transport — marmot/blob/master/transports/nostr.md)
- **Kind `445`** group message: exactly one `h` tag = lowercase hex `nostr_group_id`; only other allowed tag is NIP-40 `expiration` (and only for application messages, never commits/proposals). Signed by a **fresh ephemeral keypair per event** (never the account identity, never reused). `content = base64(nonce(12) || ciphertext)` where ciphertext = `ChaCha20-Poly1305.encrypt(group_event_key, nonce, mls_message_bytes, aad="")` and `group_event_key = MLS-Exporter("marmot", "group-event", 32)` — per-epoch key, so receivers trial-decrypt against retained candidate epochs.
- **Welcomes**: NIP-59 gift wrap — outer kind `1059` → kind `13` seal → **unsigned kind `444` rumor** whose content is base64 `MLSMessage` (`mls_welcome` wire format), with `e` tag = KeyPackage event id consumed and `relays` tag = where to fetch group messages. Published to the recipient's **kind `10050`** (NIP-17 inbox relay list).
- **KeyPackages: now kind `30443`** (addressable — this replaced the NIP-EE/MIP-era kind 443): content = base64 `MLSMessage` (`mls_key_package`); tags `d` (random 32-byte slot id), `mls_protocol_version: 1.0`, `i` (KeyPackageRef hex), id-list tags `mls_ciphersuite` / `mls_extensions` / `mls_proposals` / `app_components` (`0x`-prefixed 16-bit hex ids). **Relay discovery now uses the account's NIP-65 kind `10002` write-relays — the old dedicated kind `10051` KeyPackage relay list is gone** ("There is no dedicated KeyPackage relay list"). The MIP-era group-data extension id was `0xF2EE`; the adopted spec splits it into app components (`marmot.group.profile.v1`, `marmot.transport.nostr.routing.v1`, `marmot.group.blossom.image.v1`, etc.) and requires `app_components` value `0x8009` (account-identity-proof v2).
- Kind `446` is used for optional push-notification rumors (also inside NIP-59 wraps).

### Trust model
- Identity: Nostr pubkey = account identity (MLS `BasicCredential`); **MLS signing keys are separate from Nostr identity keys** — compromise of a Nostr key does not decrypt MLS group messages; each device is a separate MLS leaf (multi-device support).
- Security properties come from MLS (RFC 9420): forward secrecy + post-compromise security; this is the motivation vs NIP-17 gift-wrap DMs (compromised nsec reveals all past+future messages, O(N) fan-out).
- Sender privacy: kind 445 envelopes are signed with throwaway keys, so relays see only the random group id, an ephemeral pubkey, and timing; the kind 444 rumor is sealed so relays can't even see welcome contents.
- Verification rules: receivers MUST verify NIP-01 id+signature before trusting any envelope field; sender identity is established *inside* MLS after decryption, not by the transport signature. Strict tag cardinality rules; transport evidence (event ids, relay timestamps, arrival order) MUST NOT choose canonical group state.
- Clients: WhiteNoise (reference), OpenChat/Scramble, Nymchat. Maturity caveat (May 2026 assessment): "experimental, breaking changes possible, cross-client compat untested", large groups (~150+) deferred pending MLS "light welcomes", KeyPackage deletion best-effort.

## 4. Blossom BUDs deep dive (hzrd149/blossom)

Repo: https://github.com/hzrd149/blossom (Tier 1). Blossom = HTTP endpoints for storing binary **blobs addressed by SHA-256 hash**, using Nostr keys for identity; BUDs = "Blossom Upgrade Documents" (RFC-2119 language per BUD-00). Event kinds used: `24242` auth tokens (BUD-11), `10063` user server list (BUD-03). Full per-BUD findings:

| BUD | Title | Status | What it specifies |
|---|---|---|---|
| 00 | Blossom Upgrade Documents | draft, mandatory | Common language; blobs = raw binary addressed by sha256; a BUD may define server requirements or pure client-side conventions |
| 01 | Server requirements & blob retrieval | draft, mandatory | All endpoints at domain root; CORS (`Access-Control-Allow-Origin: *`); `GET /<sha256>[.ext]` and `HEAD /<sha256>`; `X-Reason` error header; optional 3xx redirect to URL containing the same hash; Range-request support; optional `Sunset` header for retention signalling |
| 02 | Blob upload | draft, optional | `PUT /upload` (binary body; server MUST NOT modify bytes and MUST hash exact bytes received; `X-SHA-256` pre-declaration; 201 vs 200 if existing). **Blob Descriptor** JSON: `url` (must include file extension), `sha256`, `size`, `type`, `uploaded`; servers MAY add `magnet`/`infohash`/`ipfs` fields |
| 03 | User Server List | draft, optional | Replaceable kind `10063` with ordered `server` tags (most trusted first); clients MUST upload to at least the first server; retrieval fallback: extract hash from *last* 64-char hex in URL, then walk the author's server list, then well-known servers |
| 04 | Mirroring blobs | draft, optional | `PUT /mirror` with `{"url": ...}` body; server fetches from origin, verifies hash (against auth token's `x` tag), returns descriptor; enables multi-server redundancy without re-uploading |
| 05 | Media optimization | draft, optional | `PUT /media` = trusted "optimize/transcode for distribution" endpoint (server decides processing; returns descriptor of the *new* blob); optional `HEAD /media` preflight; recommended flow: upload original to trusted server → `/mirror` result elsewhere |
| 06 | Upload requirements | draft, optional | `HEAD /upload` preflight using `X-SHA-256`, `X-Content-Type`, `X-Content-Length`; advisory only, not a guarantee |
| 07 | Payment required | draft, optional | `402 Payment Required` + `X-Cashu` (NUT-24) or `X-Lightning` (BOLT-11) headers; client retries the same request with payment proof in the same header (cashuB token / preimage); HEAD endpoints MUST NOT be retried with proofs; extensible to new `X-{payment_method}` headers |
| 08 | Nostr File Metadata Tags | draft, optional | Servers MAY return a `nip94` field (NIP-94 tag array: `url`,`m`,`x`,`size`,`magnet`,`i`…) in the blob descriptor from `/upload` and `/mirror` |
| 09 | Blob Report | draft, optional | `PUT /report` with a signed NIP-56 kind `1984` report event containing `x` tags of blob hashes; servers MAY use trusted-moderator lists, MAY block deleted hashes from re-upload, SHOULD advertise ToS |
| 10 | Blossom URI Schema | draft, optional | `blossom:<sha256>.<ext>[?params]` magnet-style URIs; params `xs` (server hint, repeatable), `as` (author pubkey → BUD-03 list lookup), `sz` (byte size); resolution order: xs hints → author server lists → well-known fallback; unknown ext = `.bin` |
| 11 | Nostr Authorization | draft, optional | Auth token = signed kind `24242` event: human-readable `content`, NIP-40 `expiration` tag (required), `t` verb tag (`get\|upload\|list\|delete\|media`), optional `server` and `x` scoping tags; sent as `Authorization: Nostr <base64url(event)>`; per-endpoint verb/x-tag requirements table; warns unscoped `delete` tokens are replayable across servers |
| 12 | Blob management | draft, optional | `GET /list/<pubkey>` (unrecommended; cursor+limit pagination, `since`/`until` deprecated) and `DELETE /<sha256>` (servers MUST accept); multiple `x` tags ≠ multi-delete |

Cross-checks: BUD-03 corresponds to what NIP-B7 calls the Blossom server list; kind 24242 auth pattern mirrors NIP-98 HTTP-auth style. Implementations: blossom-server (Deno), blossom-client-sdk, Primal's Rust server.

## 5. GRASP / Nostr-native git beyond NIP-34

**NIP-34 recap**: kinds `30617` repository announcement, `30618` repository state, `1617` patch, `1618` PR, `1619` PR update, `1621` issue, `1630`–`1633` status, `10317` User GRASP list. Repo identity anchored by the `euc` tag = earliest unique commit id (fork-resistant identity). `nostr://<npub>/<identifier>` clone URLs via the `git-remote-nostr` helper.

**GRASP = "Git Relays Authorized via Signed-Nostr Proofs"** — the hosting layer NIP-34 delegates to: "GRASP defines how a combined Nostr relay and Git server can accept those events, authorise pushes, advertise capabilities, and serve the corresponding objects." Detection rule: a host is a GRASP server for a repo if the same hostname appears in the announcement's `clone` tag (https git URL) *and* `relays` tag (wss URL).

Architecture: one HTTP(S) endpoint serves both (a) Smart-HTTP git at `/<npub>/<identifier>.git` with **no user auth — pushes validated against the latest signed Nostr state event** (kind 30618), CORS `*`; and (b) a Nostr relay that auto-provisions blank repos on announcement events listing the instance and accepts events related to hosted repos. Nostr events are the authority; git servers are "dumb data relays" used redundantly. NIP-11 documents advertise `supported_grasps` (e.g. GRASP-01/02/03/06).

Known GRASP sub-specs: **GRASP-01** core service requirements (relay + git HTTP + push validation + `refs/nostr/<event-id>` for PRs + `allow-tip-sha1-in-want` etc.), **GRASP-02** proactive relay-to-relay sync (uses NIP-77 negentropy with REQ+EOSE fallback), **GRASP-03**, **GRASP-06** (PR fallback hosting from a user's grasp list — referenced by NIP-34 PR text).

Implementations:
- **ngit-grasp** (DanConwayDev → maintained fork by Pleb5): pure-Rust single binary (Hyper + nostr-relay-builder + LMDB), "Production Ready — full GRASP-01 and GRASP-02", includes `grasp-audit` compliance tester.
- **ngit-relay** (original reference): Docker stack of nginx + git-http-backend + pre/post-receive hooks + Khatru relay; now archived/superseded by ngit-grasp.
- **pyramid** (fiatjaf) multi-purpose relay with GRASP-01 support; **n34-relay** (awiteb, WIP).
- **blossom-nip34** crate: mountable axum router adding a NIP-34 relay + GRASP git server to blossom-server.
- Public instances: relay.ngit.dev, gitnostr.com.
- Clients/UIs: `ngit` CLI + `git-remote-nostr`, `nak git` (fiatjaf), gitworkshop.dev (web forge, in-browser PR merge), NostrHub (browser repo creation), gittr.
- Funding/context: OpenSats 13th wave grant to Dan Conway for Grasp. Historical note: NIP-34 merged 2024-03-05 after 44 days/130+ comments (PR #997); fiatjaf: "not for each version control system, just for git. No one uses the others."

## 6. Negentropy internals (hoytech/negentropy)

Sources: https://github.com/hoytech/negentropy (Tier 1), wire spec docs/negentropy-protocol-v1.md (Tier 1), theory article https://logperiodic.com/rbsr.html (Tier 1, author Doug Hoyte), based on Aljoscha Meyer's Range-Based Set Reconciliation (SRDS 2023, arXiv:2212.13567).

**Model**: set reconciliation for anti-entropy repair; finds symmetric difference of two record sets efficiently. Records map to `(timestamp: u64, id: 32 bytes)`; max u64 timestamp reserved as "infinity"; updates are modeled as delete+insert. Actual record transfer after diffing is **external to the protocol** — "storage/transport split": negentropy only computes *which* IDs each side is missing (`have`/`need` sets); fetching the events happens via ordinary Nostr `REQ`/`EVENT` afterwards.

**Algorithm** (range reconciliation): both sides sort records by (timestamp, id). A *range* = contiguous slice, referred to by bounds (timestamp + shortest disambiguating ID prefix; lower inclusive/upper exclusive). Client (initiator) sends a message = version byte + ordered ranges, each with mode:
- `Skip` (0): nothing more to do here;
- `Fingerprint` (1): 16-byte digest of all IDs in the range — if both sides' fingerprints match, the range is provably identical and closed; if they differ, the receiver **splits** its own range (equal-count buckets or custom strategies, e.g. recent items as IdList) and recurses;
- `IdList` (2): full ID list — base case, fully reconciles the range locally.
Termination: client ends when its response is a full-universe Skip (empty message). No "empty fingerprints" (unlike Meyer's design) — an empty range is sent as IdList of length 0 because it's smaller. Efficiency: ~`log16(N)/2` round trips for mostly-in-sync sets (≈3 round-trips for 1M records, 4 for 1B). Optional **frame size limit**: excess ranges are deferred by replying with a coalesced Fingerprint range (more round-trips; `have`/`need` may contain duplicates).

**Fingerprint construction** (Protocol V1, exact): (1) sum the element IDs mod 2^256 (each ID interpreted as a 32-byte **little-endian** unsigned integer); (2) concatenate the element count as a varint; (3) SHA-256; (4) take the first 16 bytes. This additive-homomorphic ("incremental") hash lets implementations maintain cached fingerprints that update in O(1) on insert/delete instead of re-hashing whole ranges.

**Wire format**: version byte `0x61` (v1; `0x62` reserved for v2, servers reply with max supported version for downgrade); varints are base-128 MSB-first; bounds delta-encode timestamps (`1+offset`, infinity = 0) with 0–32-byte ID prefixes. Debuggable with `fq` (fiatjaf contributed a negentropy decoder).

**Storage layer** is pluggable per implementation: C++ reference ships Vector / BTreeMem / BTreeLMDB / SubRange backends; Elvio Amparore's "Anti-Entropy LMDB" fork caches aggregate fingerprints in LMDB branch pages for a measured 4–10x speedup. Stable implementations exist in C++, JS, Rust (Kishimoto), Go (Illuzen; fiatjaf's Nostr-specific Go), C#, Kotlin (Pamplona), Perl (Hubbard). A cross-language conformance fuzz suite lives in `test/`.

**Nostr transport binding = NIP-77** (`NEG-OPEN` / `NEG-MSG` / `NEG-CLOSE` over the existing relay WebSocket, hex-encoded frames); used for client↔relay catch-up and relay↔relay sync. Users: strfry (`strfry sync <relay> [--dir both]`, pre-configured per-filter BTrees), nostria-relay, NDK `@nostr-dev-kit/sync`, ngit-grasp GRASP-02 sync, Citrine aggregator; also explored for Waku Sync. Academic status: arXiv:2603.19820 treats Negentropy as the practical RBSR reference and improves its storage layer with in-tree aggregates.

## 7. Nostr history & design philosophy

### Original rationale (Tier 1)
- Original essay: https://fiatjaf.com/nostr.html ("The simplest open protocol that is able to create a censorship-resistant global 'social' network once and for all"), linked from the original repo README https://github.com/nostr-protocol/nostr.
- Core slogan triad: "It doesn't rely on any trusted central server, hence it is resilient; it is based on cryptographic keys and signatures, so it is tamperproof; it does not rely on P2P techniques, and therefore it works."
- **Why relays, not servers**: "A relay is very simple and dumb. It does nothing besides accepting posts from some people and forwarding to others. Relays don't have to be trusted. Signatures are verified on the client side." A relay "doesn't talk to another relay, only directly to users" — deliberately no server-to-server federation. Relays "can be hosted by anyone and have any rule or internal policy they want"; banning is harmless because the pubkey identity and follower graph survive a relay ban.
- Stated problems with alternatives (fiatjaf's essay): Twitter (ads, addiction, censorship, spam); Mastodon/ActivityPub (identity attached to domains controlled by third parties; server-owner despotism "often worse than that of a big company"; migration "doesn't work in an adversarial environment (all followers are lost)"; server-to-server fan-out cost scales badly with many servers; abandoned amateur servers ≈ banning everyone); SSB (over-complicated, rigid per-user chain requirement, P2P-first); self-hosted-server models (require everyone to run a server; domains censorable). FAQ answer to "why hasn't anyone done it before": companies want money and P2P activists want no servers at all — "they both fail to see the specific mix of both worlds that Nostr uses."
- Scaling philosophy: the network "can work just fine with just a handful" of relays because new ones spawn easily; storage burden stays low because relays don't replicate to each other. Anti-spam = relay-level payment/auth (fees "outside of the protocol"), hashcash, captchas; spammy relays get unlisted by clients.
- Hardest acknowledged problem: discovering *which relay* hosts a given pubkey ("The hardest part is how to find in which relay you will find notes of each person you follow") — solved later by NIP-65 outbox model.

### Sourced comparisons vs ActivityPub / AT Protocol (label tiers)
- Academic (Tier 2): arXiv:2402.05709 "Exploring the Nostr Ecosystem" — relays "do not communicate with other relays; they interact solely with users… thereby decoupling the fixed association between a user and a server," unlike Fediverse instances. arXiv:2505.22962: Nostr/Farcaster users generate and manage their own keys (max user agency, higher knowledge barrier) vs ATProto/ActivityPub's familiar server-issued accounts.
- ActivityPub (Mastodon): migration moves followers but "Your posts will not be moved, due to technical limitations" (Mastodon docs); content unsigned and server-custodial; W3C spec has no DIDs (FEP-ef61 portable objects unshipped). Strengths: largest mature network, no key management, human-readable handles.
- AT Protocol (Bluesky): first-class account migration (CAR export/import, constant DID+handle), `did:plc` rotation keys with 72h recovery window — fixes Nostr's un-rotatable-key weakness; honest cons: single-operator `did:plc` directory (Bluesky-run today) and DNS-based handles; dominant relay/AppView can defederate. Nostr's honest con in return: "the key is un-rotatable… a lost or stolen nsec is permanent — no reset, no revocation" (key-rotation PR #1452 unmerged). ATProto relays/firehoses are expensive to run; Nostr has "just dumb relays and clients" but key loss = start over.
- Measurement caveat (Tier 3): punkscience.ca tech brief — Nostr "solves account portability and censorship-resistance at the identity layer" but "Adoption peaked early and has since plateaued — Nostr never crossed 100,000 weekly active users in any week of 2025."

## 8. Nostr for agents / AI

**NIP-90 Data Vending Machines as the agent substrate**:
- Kind ranges: `5000–5999` job requests (customer), `6000–6999` results (= request kind + 1000), `7000` feedback (`payment-required`, `processing`, `partial`, `error`, `success`). Inputs via `i` tags (text/url/event/**job** → chaining pipelines), `param`, `output`, `bid` (msat ceiling). Payment: Lightning bolt11 in `amount` tag / feedback, or zaps. Privacy: inputs can be encrypted to a specific provider (`encrypted` tag + provider `p` tag) — private from relays, not from the provider. Discovery via NIP-89 kind `31990` handler announcements. Concrete job kinds live in a separate registry repo `nostr-protocol/data-vending-machines`.
- Caveat (2026): NIP-90 flagged "unrecommended" upstream — "got totally out of control" — pointing toward use-case-specific micro-standards; live DVM traffic continues on kinds 5000–7000.

**Agent-communication experiments / frameworks (all sourced)**:
- `spcpza/nostr-dvm` — Python lib turning any function into a paid DVM ("Bitcoin is the billing layer. Nostr is the coordination layer"), with discovery + reputation helpers; frames NIP-90 as infrastructure for an agent-to-agent hiring economy.
- `sebdeveloper6952/adk-nostr` — Google ADK-Go "Nostr SubLauncher": agents listen for kind `5050` job requests on relays and publish kind `6050` results, NIP-89 handler announcements.
- OpenAgents issue #992 — agent-to-agent communication via NIP-28 channels + NIP-90 marketplace, coalition formation, NIP-OA spec work.
- Emerging NIPs (as of Feb 2026, per Nostr Compass #11, Tier 3): **NIP-AE Agents** (kind 4199 agent definitions, 4201 "nudge" prompting), **NIP-XX AI Agent Messages** (ephemeral kinds 25800–25806 for status/streaming/tool calls/errors; kind 31340 "AI Info"), **NIP-AC DVM Agent Coordination** (heartbeats, job reviews, data escrow, workflow chains, swarm bidding; reference impl at 2020117.xyz), **NIP-AD MCP Server Announcements** (MCP servers/skills announced on Nostr; in use on TENEX).
- `dyegolara/nostr-auth-agents` — "Sign in with Nostr" for LLM coding agents (Claude Code, OpenCode, Cursor…): NIP-07-style challenge signing with per-service HMAC-derived keys, MCP server packaging.
- Field reports (Tier 3, honest-failure evidence): "I ran a NIP-90 DVM for 8 hours" — zero organic jobs; conclusion "DVMs only make real sense when AI agents are the buyers" (stacker.news/items/1463738). "AI Hustler" 23-day autonomous agent experiment: DVM processed ~95 jobs but 97% came from a single bot pubkey; $0 revenue (marcindudek.dev/projects/ai-hustler/). MCP×Nostr community proposals: NIP-89 MCP advertisements, zap-based QoS, federated reputation (stacker.news/items/887732).
- Adjacent: Marmot is being used as agent messaging transport (NanoClaw × WhiteNoise bidirectional E2EE integration, Tier 3); NKBIP-02 kind 1987 embeddings provide semantic-search infrastructure for AI over Nostr content; NKBIP-03 kind 33 standardizes citing AI prompts.

---

## Unverifiable / caveats
- wikistr.com NKBIP pages are JS-rendered; texts verified via mirrors (decent-newsroom/newsroom, limina1/NKBIPs) rather than the canonical URL directly. The canonical URL is confirmed as the link target in the NIPs README.
- GRASP spec documents beyond GRASP-01/02/03/06 numbering (existence of 04/05) not confirmed; spec repo location referenced but not enumerated.
- Marmot spec churn is high: kind 443→30443 and kind 10051→(removed, use 10002) happened between the NIP-EE/MIP era and the adopted spec (2026). The NIPs README kind table still lists 443/444/445 → Marmot. Treat all Marmot kinds as "check transports/nostr.md at your commit" before implementing.
- NIP-90 marked unrecommended upstream; NIP-AE/AC/AD/XX are unmerged proposals (Feb 2026 status).
