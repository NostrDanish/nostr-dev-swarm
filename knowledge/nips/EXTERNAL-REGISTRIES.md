# EXTERNAL REGISTRIES — registry-of-kinds, NKBIPs, Marmot kinds

Source: https://github.com/nostr-protocol/registry-of-kinds ; https://github.com/nostr-protocol/nips (README kind table + external links) ; https://github.com/decent-newsroom/newsroom/tree/master/documentation/NKBIP (mirror of wikistr.com NKBIP texts) ; https://github.com/marmot-protocol/marmot
Retrieved: 2026-09-23
Confidence: HIGH for registry-of-kinds and NKBIP kind assignments (Tier 1 repos); MEDIUM for wikistr canonical text (verified via mirrors, canonical pages are JS-rendered Nostr events); Marmot kinds marked per-version below.

## 1. nostr-protocol/registry-of-kinds

- Machine-readable registry of event kind definitions. The NIPs README kind table explicitly defers to it: "For a machine-readable registry of all known event kinds prefer https://github.com/nostr-protocol/registry-of-kinds (or alternative registries following the same YAML schema)."
- The entire registry is ONE file: `schema.yaml` (~78 KB). Structure:
  - YAML anchors at top define reusable tag shapes (`_profile`, `_event`, `_addr`, `_kind`, `_ptag`, `_etag`, `_qtag`, `_imetatag`, `_emojitag`, ...).
  - `generic_tags:` — globally valid tags: `t`, `L`, `l`, `expiration`, `h`.
  - `kinds:` — map kind-number → { `description`, `in_use`, `content.type` (`json`|`free`), `multiple` (repeatable tags), `tags` (typed tag chains) }.
  - Tag values are typed: `pubkey`, `id`, `addr`, `relay`, `url`, `timestamp`, `kind`, `free`, `lowercase`, `hex`, `geohash`, `imeta`, `constrained` (e.g. NIP-10 markers `either: [reply, root]`).
- Registration policy: "Any reasonable event definition can be added here. Implementation and how-to-use guides must exist elsewhere." → permissive shape registry, NOT a standards gate. Changes land via PRs editing schema.yaml.
- Intended use: automatic event validation (e.g. relays at ingestion). `nak validate` (fiatjaf's CLI) validates events against this schema.
- Also ships `browser/` — a small Vite web viewer for the registry.
- Relationship to NIPs README table: README maps kind → prose NIP; registry-of-kinds maps kind → machine-checkable schema. Use both.

## 2. NKBIPs (Nostr Knowledge Base Interoperability Proposals)

Canonical home: wikistr.com articles by pubkey fd208ee8c8f283780a9552896e4823cc9dc6bfd442063889577106940fd927c1 ("liminal"), linked directly from the NIPs README kind table. Earlier draft repo: https://github.com/limina1/NKBIPs.

### NKBIP-01 — Curated Publications
- Kind `30040` Publication Index (addressable): empty content; `title` tag required; `a` tags (`["a","<kind:pubkey:dtag>","<relay>","<event-id>"]`) in display order (sections or nested 30040s); required `auto-update` tag (`yes|ask|no`); derivative works: `p` + `E` tags; optional `type` (book/illustrated/magazine/documentation/academic/blog), `source`, `i` (ISBN), `version`.
- Kind `30041` Publication Content: section/chapter; `d` + `title` required; content may be AsciiDoc with `[[wikilinks]]`.
- Wikistr `bookstr` macro: `[[bible: John 3:16 | KJV]]` style references.

### NKBIP-02 — Vector Embeddings
- Kind `1987` ("AI Embeddings / Vector lists" in NIPs README). Tags: `e` (embedded event) required; `model` (name+version+download link) required; `type` (text/image/audio/video) required; `vector` (comma-separated floats) required; optional `dims`, `norm`, `hash`/`hash_type`, `source`.
- Purpose: compute embeddings once, publish for reuse → semantic search, recommendation, clustering over Nostr content.

### NKBIP-03 — Citations
- Kind `30` internal Nostr reference (`c` tag `<kind>:<pubkey>:<hex-id>`), `31` external web reference (`u` URL, `accessed_on`), `32` hardcopy reference (`page_range`, `doi`, `published_in`...), `33` prompt reference (`llm` tag = AI model cited).
- Content = cited text. In-content markup: `[[citation::end|foot|foot-end|inline|quote::nevent1...]]`, AI variants `prompt-end`/`prompt-inline`.

### Wider family (per nostr.blue / gc-alexandria, Tier 2)
NKBIP-04 Directory System (kinds 30042–30045), NKBIP-06 Nostr MIME types (`M` tag), NKBIP-08 book wikilinks (`book::` macro). Implementations: Alexandria, wikistr, nostr.blue.

## 3. Marmot-registered kinds (see protocols/marmot.md for full spec)

NIPs README maps 443/444/445 → Marmot. IMPORTANT version split:

| Kind | NIP-EE / MIP era | Current adopted spec (transports/nostr.md) |
|---|---|---|
| 443 / 30443 | 443 = KeyPackage | **30443** (addressable) KeyPackage, `d`-slot + `mls_*` capability tags |
| 444 | Welcome event | unsigned Welcome **rumor** inside NIP-59 (13 inside 1059) |
| 445 | Group event | Group message: ephemeral-signed, `h` tag = nostr_group_id, ChaCha20-Poly1305 over MLS exporter key |
| 10051 | KeyPackage relays list | **removed** — use NIP-65 kind 10002 write relays |
| 10050 | — | NIP-17 inbox relay list, reused for Welcome delivery |
| 446 | — | optional push-notification rumor (gift-wrapped) |
