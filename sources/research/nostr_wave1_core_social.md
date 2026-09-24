# Research Log — Nostr Dev Swarm, Wave 1: CORE SOCIAL cluster

Researcher: NOSTR PROTOCOL DEEP-RESEARCHER (subagent)
Date: 2026-09-23
Method: all 15 specs fetched live from `nostr-protocol/nips` master via GitHub MCP `get_file_contents`; README.md also fetched to verify unrecommended markers (none of the 15 target NIPs are marked unrecommended).
Cards written to: `knowledge/nips/NIP-{NN}.md`

## NIP-02 — Follow List (`final` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/02.md
- Kind 3 follow list = list of `p` tags `["p", <pubkey>, <relay-url>, <petname>]`; `.content` unused.
- Full-replace semantics: new list must contain ALL entries; relays/clients SHOULD delete past lists on receipt.
- New follows SHOULD be appended at the end to preserve chronological order — non-obvious ordering rule.
- Includes a full petname scheme: chained resolution `~/erin/charlie`, absolute roots `~npub1.../name`, petnames restricted to ASCII letters/numbers/`_`.
- Uses listed: backup, profile discovery, relay sharing (censorship resistance), petnames.
- NIP-24 documents the deprecated kind-3 content relay-object format (`{url: {read, write}}`) — NIP-65 supersedes it.

## NIP-10 — Text Notes and Threads (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/10.md
- Kind 1 = plaintext note; Markdown/HTML SHOULD NOT be used.
- Marked e-tags PREFERRED: `["e", <id>, <relay-url>, <marker>, <pubkey>]`, marker ∈ {`reply`, `root`}; direct reply to root uses ONLY `root` marker (single e-tag).
- Non-obvious: kind-1 replies MUST NOT target other kinds — NIP-22 kind 1111 is the mandated replacement.
- e-tag `<pubkey>` (5th element) feeds the outbox model: fetch referenced event from its author's write relays when hints fail.
- p-tag inheritance rule: reply to E by a1 with p-tags [p1,p2,p3] ⇒ reply p-tags = [a1,p1,p2,p3].
- Positional e-tags (0/1/2/many semantics) are DEPRECATED, kept only for reading old events; deprecated because mention/reply ambiguity.
- `q` tags for NIP-21 citations keep quotes out of reply threading.

## NIP-13 — Proof of Work (`draft` `optional` `relay`)
Source: https://github.com/nostr-protocol/nips/blob/master/13.md
- Difficulty = leading zero BITS of the 32-byte NIP-01 id (not hex digits); hex digits ≤7 contribute leading zeros (e.g. `002f...` = 10 bits).
- Mining via `["nonce", <counter>, <target>]` tag; recompute id per iteration; update `created_at` recommended.
- Committed target difficulty (3rd nonce entry) lets clients reject lucky sub-target spam: require 40, committed 30 → reject even if 40 achieved. Clients MAY reject notes lacking the commitment.
- Delegated PoW explicitly allowed: event id does not commit to the signature, so mining can be outsourced (mobile use case).
- Reference validation code in C and JS included in spec.

## NIP-14 — Subject tag (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/14.md
- `["subject", <string>]` on kind 1; email-style thread subjects.
- Replies SHOULD replicate the subject; MAY prepend `Re:`.
- Subjects should be <80 chars; clients trim longer ones.
- Spec names more-speech as an implementer; otherwise thin adoption.

## NIP-18 — Reposts (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/18.md
- kind 6 = repost of kind 1 ONLY; content = stringified JSON of reposted note (may be empty, not recommended).
- e-tag with reposted id is REQUIRED and MUST include a relay URL as 3rd entry; p-tag with author SHOULD be included.
- NIP-70-protected events: reposts SHOULD always have EMPTY content (else relay-auth protection is defeated) — key non-obvious rule.
- kind 16 = generic repost for any non-kind-1 event; SHOULD carry `k` tag (stringified reposted kind).
- Reposting a replaceable event: SHOULD include `a` coordinate tag; if `a` absent ⇒ specific version is reposted and full JSON MUST be embedded in content.
- Quote reposts: NIP-21 mentions (nevent/note/naddr) MUST be converted to `q` tags — keeps quotes out of reply threads and enables quote counting.

## NIP-21 — `nostr:` URI scheme (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/21.md
- `nostr:` + NIP-19 bech32 entity; ALL NIP-19 identifiers allowed EXCEPT `nsec`.
- HTML integration: `<link rel="alternate" href="nostr:naddr1...">` binds a webpage to a Nostr event; `rel="me"`/`rel="author"` binds authorship to a nprofile.

## NIP-22 — Comment (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/22.md
- kind 1111, plaintext only (no HTML/Markdown), always scoped to a root event OR external NIP-73 I-tag.
- Uppercase tags = ROOT scope (`A`/`E`/`I`, `K`, `P`); lowercase = PARENT (`a`/`e`/`i`, `k`, `p`). `K` and `k` MUST always be present.
- Top-level comment: root and parent tags identical. Comment on addressable parent: include BOTH `a` and `e` (specific id) tags.
- External scopes use NIP-73 values: `web` URLs, `podcast:item:guid`, hashtags, geohashes; examples cover blog posts, NIP-94 files, websites, podcast episodes.
- Replaces kind-1 replies for non-kind-1 targets (NIP-10 forbids cross-kind kind-1 replies; NIP-23 mandates kind 1111 for article replies).

## NIP-23 — Long-form Content (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/23.md
- kind 30023 addressable Markdown articles; `.created_at` = last update, `published_at` tag = first publication.
- Hard authoring constraints: MUST NOT hard-wrap paragraphs; MUST NOT support HTML in Markdown.
- Standard optional metadata tags: `title`, `image`, `summary`, `published_at`; topics via `t`.
- Editability via `d` tag; clients must hide stale versions when relays don't enforce replacement.
- kind 30024 drafts DEPRECATED → use NIP-37 draft events.
- Replies MUST use NIP-22 kind 1111. Explicitly: kind-1 social clients should not be expected to implement NIP-23.

## NIP-24 — Extra metadata fields and tags (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/24.md
- kind 0 extra fields: `display_name` (name must still always be set), `website`, `banner` (~1024x768), `bot` boolean, `birthday` object with each field omittable.
- Deprecated: `displayName` → `display_name`, `username` → `name`.
- Deprecated kind-3 content relay map → NIP-65.
- Default tag meanings (when no specific NIP overrides): `r` = web URL ref, `i` = external id (NIP-73), `title` = name for NIP-51/52/53/99 items, `t` = hashtag that MUST be lowercase.

## NIP-25 — Reactions (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/25.md
- kind 7 reaction; content `+`/empty = like (MUST), `-` = dislike (MUST), emoji/`:shortcode:` = NOT like/dislike (SHOULD NOT) — display as emoji.
- e-tag to target REQUIRED with relay hint; p-tag to target author SHOULD; if extra e/p tags exist (not recommended) the TARGET must be LAST in each.
- Addressable targets: include `a` coordinate tag alongside `e`; `k` tag (stringified kind) MAY be included.
- External content reactions: MUST be kind 17 with NIP-73 `k`+`i` tags (e.g. `["k","web"],["i","https://..."]`); podcast example shows multiple k/i pairs for show+episode.
- Custom emoji reaction: content = exactly ONE `:shortcode:`, exactly one `emoji` tag (NIP-30).

## NIP-27 — Text Note References (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/27.md
- Inline `nostr:` NIP-19 codes in `.content` of any text-bearing event (kinds 1, 30023 named).
- `q`/notification tags are OPTIONAL and deliberate: omit `p` to mention without notifying; omit `e` to reference without appearing in replies — intended feature.
- Reading clients free to augment: replace with `@name`, internal links, web links, preview boxes; kind-1-only clients may punt naddr refs to hardcoded webapps.
- Supersedes deprecated NIP-08 (README marks NIP-08 unrecommended).

## NIP-30 — Custom Emoji (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/30.md
- `["emoji", <shortcode>, <image-url>, <optional emoji-set-address>]` on kinds 0, 1, 1111, 7, 30315.
- Shortcode charset restricted to alphanumerics + `-` + `_` (MUST).
- Optional 4th element points to a kind 30030 NIP-51 emoji set (`kind:pubkey:d-tag`).
- kind 0: only `name` and `about` fields emojified; other kinds: `.content` emojified.

## NIP-36 — Sensitive Content (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/36.md
- `["content-warning", <optional reason>]` tag; clients hide content behind click-to-reveal.
- MAY pair with NIP-32 `L`/`l` labels (namespace `content-warning` or external ontologies like `social.nos.ontology` with values like `NS-nud`) for structured querying.
- Self-declared only — does not replace reporting/moderation (NIP-56).

## NIP-38 — User Statuses (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/38.md
- kind 30315 addressable; `d` tag = status type; `general` and `music` are the two defined types; others allowed undefined.
- NIP-40 `expiration` tag optional; music status expiry should equal track end.
- Empty content = clear the status.
- MAY include `r`/`p`/`e`/`a` links; content may use NIP-30 custom emoji.

## NIP-39 — Linking Profiles to Other Platforms (`draft` `optional`)
Source: https://github.com/nostr-protocol/nips/blob/master/39.md
- kind 10011 (replaceable) with `i` tags `["i", "platform:identity", "proof"]`; exactly two params; clients SHOULD tolerate extra values for extensibility.
- Platform names: `a-z0-9._-/` only, no `:`; identities SHOULD be lowercased/normalized.
- Four claim types with distinct proof URL patterns: github (Gist ID), twitter (Tweet ID), mastodon (`instance/@user` + post ID), telegram (numeric user ID + `<ref>/<id>` channel message).
- All proofs are posts containing a fixed verification sentence with the npub; verification requires fetching the external platform.

## Cross-NIP conflicts / tensions noticed
1. **Reply routing split**: NIP-10 forbids kind-1 replies to non-kind-1 events and NIP-23 mandates NIP-22 kind 1111 for articles — but legacy clients still emit kind-1 replies to articles; readers must handle both.
2. **`i` tag overload**: NIP-24 defines `i` as generic external id (per NIP-73), NIP-39 uses `i` for platform identity claims (kind 10011), NIP-22 uses `I`/`i` for external comment scopes, NIP-25 uses `i` for external reaction targets. Same letter, different semantics keyed by event kind — implementers must dispatch on kind.
3. **`k` tag case asymmetry**: NIP-22's `K`/`k` = root/parent kinds; NIP-25's lowercase `k` = reacted event kind; NIP-18's `k` = reposted kind. Consistent intent (kind of target) but different tag alphabets per NIP.
4. **q-tag provenance**: defined in NIP-18 but referenced normatively by NIP-10 and NIP-22 — readers need all three specs for complete quote handling.
5. **kind 3 content**: NIP-02 says content unused; NIP-24 documents the deprecated relay-map content still found in the wild — parsers should tolerate both.
6. **NIP-39 twitter proofs**: spec's tweet-verification flow is largely unverifiable since X's API lockdown (operational caveat, spec unchanged).
7. **Deprecation web**: NIP-08 → NIP-27; kind 30024 → NIP-37; kind-3 relay content → NIP-65; kind-1 cross-kind replies → NIP-22. Cards capture each pointer.

## Failures
None. All 15 specs fetched successfully; all cards are Confidence: HIGH (spec-read).
