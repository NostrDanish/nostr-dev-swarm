# Research Log — Wave 4: Content & Media cluster

Date: 2026-09-23. Method: all 15 spec files fetched from `nostr-protocol/nips@master` via GitHub MCP `get_file_contents` (SHAs recorded per file); README.md also fetched to check unrecommended marks and the kind registry. Knowledge cards written to `knowledge/nips/NIP-XX.md`.

## NIP-5A — Static Websites (nsites) — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/5A.md (SHA 690d67a5)
- Static-site model: manifest events map URL paths → sha256 blob hashes served from Blossom; host HTTP servers resolve manifests and stream blobs. Kinds: 15128 root site (replaceable, no `d`), 35128 named site (addressable, `d` = site id matching `^[a-z0-9-]{1,13}$`), 5128 manifest snapshot (regular, immutable version).
- Non-obvious: deterministic **aggregate hash** (sort `"<hash> <path>\n"` lines lexicographically, sha256) identifies site versions independent of author — enables copy-detection across pubkeys; `app` tags explicitly excluded from the hash.
- Canonical host addressing is a single DNS label: `<npub>.host`, `v<snapshotIdB36>.host`, `<pubkeyB36><dTag>.host` (pubkeyB36 = 50-char lowercase base36 of raw pubkey; dTag appended with no separator) — designed to dodge wildcard TLS limits.
- Copy lineage: lowercase `a` = immediate parent, uppercase `A` = lineage origin; copies may change kind/identifier; `a`/`A` are the stable indexable references.
- Retrieval chain: manifest `server` hints → BUD-03 kind 10063 server list (MUST try) → 404 if neither. Blob hash mismatch → treat as not found. `/404.html` fallback path mandated; `index.html` fallback for directory paths.
- README registry: kind 34128 = "Legacy nsite manifest (deprecated)".

## NIP-32 — Labeling — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/32.md (SHA 84670c97)
- Kind 1985 label events; `L` = namespace, `l` = label (mark matching `L` REQUIRED when `L` present; implied `ugc` otherwise).
- `#`-prefixed namespaces (e.g. `#t`) attach standard nostr tags to targets — bridge mechanism.
- Deliberately regular (not addressable) events: standard `d`-tag design judged too complex; bulk re-label via NIP-09 delete + republish.
- Design heuristic: reusable labels only; unique values are "values, not labels". Self-reporting allowed by putting `l`/`L` on any kind.

## NIP-34 — git stuff — HIGH (GRASP verified)
- Source: https://github.com/nostr-protocol/nips/blob/master/34.md (SHA c70c3555)
- Nostr-native git: **30617 repo announcement** (addressable; only `d` required; author asserts maintainership unless `u` fork tag present) vs **30618 repo state** (addressable; optional source of truth for `refs/heads/*`/`refs/tags/*` → commit-id plus `HEAD` ref).
- Collaboration kinds: 1617 patch (`content` = git format-patch output, <60kb rule vs PRs), 1618 PR, 1619 PR update (NIP-22 `E`/`P` tags), 1621 issue, 1630–1633 status (Open / Applied-Merged-Resolved / Closed / Draft; latest status from author-or-maintainer wins; revision-closed rule tied to 1631 tagging). Kind 1622 (git replies) deprecated per README; NIP-22 comments used instead.
- Repo identity across forks: `r` tag with `"euc"` marker = earliest unique commit (root commit, or first commit after a permanent fork).
- `nostr://` clone URLs (`nostr://<npub|nip05>/[<relay-hint>/]<identifier>`, percent-encoded) work with plain `git clone` via a git-remote-nostr helper.
- **GRASP**: spec defines kind 10317 "user grasp list" — replaceable list of `g` tags with grasp server websocket URLs, explicitly "similar in function to NIP-65 relay list and NIP-B7 blossom list"; grasp servers referenced via njump naddr link in spec. GRASP = git server + relay + remote-helper stack (the ngit ecosystem); the in-spec reference is an naddr, not a standalone spec doc.
- Optional stable-commit-id tags (`commit`, `parent-commit`, `commit-pgp-sig`, `committer`) preserve the proposer's commit id when merged.

## NIP-35 — Torrents — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/35.md (SHA 3891f6f4)
- Kind 2003 torrent index (no .torrent files on nostr); `x` = V1 btih info hash for magnet construction (BEP 53); `file` entries with sizes; `tracker` optional.
- Rich `i`-tag taxonomy: `tcat:` category paths (best-effort newznab match), `newznab:`, `tmdb:movie:`, `ttvdb:`, `imdb:`, `mal:anime|manga:`, `anilist:`. Kind 2004 = torrent comment (kind-1-like, NIP-10).

## NIP-52 — Calendar Events — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/52.md (SHA 060b38f2)
- Kinds 31922 date-based (ISO dates, exclusive `end`), 31923 time-based (unix ts + IANA `start_tzid`/`end_tzid` + REQUIRED day-bucket `D` tag `floor(ts/86400)` for day queries), 31924 calendar list, 31925 RSVP (`status` accepted/declined/tentative; `fb` free/busy MUST be omitted when declined).
- Collaborative requests: calendar event `a`-tags a 31924 calendar → owner approves by adding the event's `a` to the calendar.
- Recurring events **intentionally unsupported** — clients duplicate metadata. RSVP authorization semantics deliberately undefined.

## NIP-54 — Wiki — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/54.md (SHA ead362d2)
- Kind 30818 articles (addressable; lowercase normalized `d`: lowercase, whitespace→`-`, strip punctuation, collapse `-`, preserve non-ASCII UTF-8 & numbers). Content = **Djot** with wikilink fallback (undefined reference-style links resolve to normalized article names) and NIP-21 `nostr:` links.
- **Merge mechanics**: kind 818 merge request carries `a` (target article), optional base-version `e`, and `e`+`source` marker (the 30818 event to merge); acceptance = NIP-25 `+`/`-` reaction from destination pubkey — social signal, not automatic merge.
- `fork` and `defer` markers on `a`/`e` tags: defer = "their version is better" (stronger than `+`, effectively deletes own version). Kind 30819 redirects enable crowdsourced disambiguation. Article selection is client-defined WoT (reactions, kind 10102 relay lists, contact lists, wiki-curator lists).

## NIP-64 — Chess (PGN) — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/64.md (SHA ecbc8385)
- Kind 64, content = PGN database. Publish strict (export format), parse lax (import format); clients SHOULD validate moves; relays MAY reject invalid PGN. `alt` tag for non-supporting clients.

## NIP-68 — Picture-first feeds — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/68.md (SHA 60fc99eb)
- Kind 20 multi-image posts; imeta-driven; restricted MIME whitelist (apng/avif/gif/jpeg/png/webp); `annotate-user <pubkey>:<x>:<y>` in-image user tags; per-image top-level `x` hashes make images queryable. Designed to mix with NIP-71 kind 22 shorts in one feed.

## NIP-71 — Video Events — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/71.md (SHA e55e470d)
- Four kinds: 21 normal / 22 short (regular), 34235 / 34236 addressable variants (`d` required) for metadata fixes, legacy-ID preservation, URL migration.
- **Variants**: one imeta per rendition distinguished by `dim` + `m` (mp4 vs HLS `application/x-mpegURL`); separate audio-track imetas with `l en ISO-639-1 ov` (`ov` = original language); clients should prefer separate audio for gapless resolution switching. New imeta props: `duration` (float s), `bitrate`, `waveform`. `fallback` URLs weighted equally with `url`.
- `origin` tag tracks imported content (`platform, external-id, original-url, metadata`). `segment` tags = chapters with thumbnails. Minor spec inconsistency: `duration` also shown as top-level tag; `text-track` format differs between prose and example.

## NIP-84 — Highlights — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/84.md (SHA 51de3edd)
- Kind 9802; content = highlighted text (empty allowed for non-text media). Anchor semantics: source via `e`/`a`/`i` (NIP-73)/`r` tags + optional `context` tag (surrounding paragraph) — no character offsets.
- Quote highlights: `comment` tag merges commentary (renders like quote repost; avoids highlight+kind1 double-post). Marker discipline: mention `p`/`r` tags MUST carry `mention`; source URL `r` MUST carry `source`; author `p` tags may carry roles (author/editor).

## NIP-88 — Polls — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/88.md (SHA 9971623f)
- Poll 1068 (`option` id+label, `relay` endpoints, `polltype` default singlechoice, `endsAt`), response 1018 (`response <optionId>`).
- Counting: one vote per pubkey, latest within poll window wins; singlechoice counts only FIRST response tag; multiplechoice counts first-per-option-id. Integrity is advisory: authors advised to use relays that reject backdating and ignore kind-5 deletes; curation via kind 30000 follow sets / PoW / WoT.

## NIP-A0 — Voice Messages — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/A0.md (SHA 884bf2aa)
- Kinds 1222 root / 1244 reply (NIP-22); content = direct audio URL, ≤60 s, `audio/mp4` (AAC/Opus) recommended; optional imeta `waveform` + `duration` for inline visual preview.
- Spec file ends abruptly after the root-message example (missing closing fence and reply example) — noted as upstream incompleteness; also a 1222/1244 typo in the duration rule.

## NIP-C0 — Code Snippets — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/C0.md (SHA de78fe87)
- Kind 1337; content = code; optional `l` (lowercase language), `name`, `extension`, `description`, `runtime`, `license` (SPDX short id REQUIRED when available; repeatable for multi-license), `dep`, `repo` (URL or NIP-34 `30617:<pubkey>:<d>` address + relay hint).

## NIP-F4 — Podcasts — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/F4.md (SHA e32ec588)
- Each podcast = own keypair (MuSig2 shared ownership possible). Kind 10154 replaceable show metadata (clients ignore kind 0); kind 54 episodes (markdown content, repeatable `audio` enclosures); authored-podcasts list for two-way authorship verification.
- **Spec inconsistency**: prose says kind 10164 for the authored-podcasts list but example uses 10064, and README registers 10064 ("Authored podcasts list", NIP-51). 10064 treated as canonical. Favorites = NIP-51 kind 10054.
- Rationale section explicitly targets RSS weaknesses (no pagination, no per-episode references, Podping, walled gardens).

## NIP-B0 — Web Bookmarking — HIGH
- Source: https://github.com/nostr-protocol/nips/blob/master/B0.md (SHA 3907478c)
- Kind 39701 addressable bookmark; `d` = URI with `https://` scheme stripped (queryable by `d`); `published_at`, `title`, `t` tags; comments MUST be kind 1111 (NIP-22).

## Cross-cutting notes
- None of the 15 NIPs in this cluster carry README "unrecommended" marks. Related marks: NIP-96 unrecommended (replaced by Blossom) — relevant because NIP-71 still references `service nip96`.
- README kind registry additions captured in cards: 5128/15128/35128 nsites (+34128 deprecated), 1622 deprecated git replies, 10064/10054 podcast lists, 818 merge requests.
