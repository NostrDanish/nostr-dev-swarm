# Research Log — Nostr Wave 2: Relay Infrastructure & Groups

Researcher: NOSTR PROTOCOL DEEP-RESEARCHER (Nostr Dev Swarm)
Date: 2026-09-23
Primary source: https://github.com/nostr-protocol/nips (master, via GitHub MCP `get_file_contents`)
Cards written to: knowledge/nips/NIP-{28,29,40,43,45,62,66,67,70,72,78,86}.md
Relay implementation sources:
- strfry README: https://github.com/hoytech/strfry/blob/master/README.md — claims NIPs 1, 2, 4, 9, 11, 28, 40, 42, 45, 70, 77
- nostr-rs-relay README: https://github.com/scsibug/nostr-rs-relay/blob/master/README.md — claims 1, 2, 5, 9, 11, 12, 15, 16, 20, 22, 28, 33, 40, 42 (+91); NOT 45/62/66/70/86
- nostream README: https://github.com/Cameri/nostream/blob/main/README.md — claims 28, 40, 45, 62, 65 among others; has a dedicated "NIP-43 invite codes" section (kind 28934 implemented, opt-in 28935 minting via `nip43.allowInviteRequests`, `nostream invite create` CLI)
- khatru README: https://github.com/fiatjaf/khatru — framework (custom policies/auth/storage), no fixed NIP list; repo in maintenance mode, superseded by fiatjaf.com/nostr/khatru
- relay29: https://github.com/fiatjaf/relay29 — NIP-29 group-state library with `khatru29` and `strfry29` backends
- nips README: https://github.com/nostr-protocol/nips/blob/master/README.md — unrecommended marks: NIP-28 and NIP-72 both "try NIP-29 instead"

---

## NIP-28 — Public Chat (kinds 40–44)
- Card: HIGH confidence. Spec is short and client-centric; zero relay requirements — moderation (hide kind 43 / mute kind 44) is advisory client behavior keyed to the viewing user's own moderation events.
- Kind 41 is in the "regular" range but specified as de-facto replaceable ("only the most recent kind 41 per `e` tag value MAY be available") — a pre-NIP-33 relic; clients must sort by created_at themselves since relays won't enforce.
- Clients SHOULD ignore kind 41 from non-channel-authors — the only authenticity rule in the NIP.
- Status conflict to note in UI copy: spec header `draft unrecommended optional` + README strikethrough, both redirecting to NIP-29. Implemented anyway by strfry, nostr-rs-relay, nostream (all three list NIP-28).
- Supersession is functional, not just editorial: NIP-29 adds relay-enforced write access, which NIP-28's "impose no requirements on relays" design deliberately lacks.
- Source: https://github.com/nostr-protocol/nips/blob/master/28.md

## NIP-29 — Relay-based Groups (kinds 9000–9030, 39000–39005, 9021/9022)
- Card: HIGH confidence. Largest spec in this cluster; the depth targets all confirmed: moderation kinds 9000–9010 (put-user/remove-user/edit-metadata/delete-event/create-group/delete-group/create-invite/update-pin-list) and addressable 39000 (metadata), 39001 (admins), 39002 (members), 39003 (roles), 39004 (livekit participants), 39005 (pins). README reserves 9000–9030 and 39000–39009; 9003/9004/9006, 9011–9030 unassigned in spec text.
- Non-obvious mechanics: `previous` tag (first 8 hex chars of recent event ids, ≥3 recommended, relays reject unknown references) is an anti-fork-replay hack; "late publication" rejection protects against timestamped-backfill unless the relay accepts migrated groups.
- Forks/migrations are first-class: same group id can live on multiple relays with divergent 39000/39001; detection via admins' and friends' kind 10009 relay hints (clients MUST check when primary relay is down; admin pubkeys SHOULD be cached locally).
- Subgroups section is newer and strict: max one `parent` tag, relays MUST reject cycles/self-parents/missing parents/cross-admin parenting and metadata edits that drop existing `child` tags; membership explicitly does NOT cascade parent→child; NIP-11 advertisement `nip29.subgroups`.
- LiveKit AV: NIP-98-authed token endpoint `/.well-known/nip29/livekit/<group-id>`; JWT `sub` MUST start with 64-char lowercase hex pubkey; support probe = HTTP 204 on `/.well-known/nip29/livekit`.
- Join semantics worth quoting: relays MUST reject 9021 for non-added users, MUST use `duplicate: ` prefix for existing members; `closed` groups only honor invites (9009 `code`).
- Implementation: reference stack is fiatjaf/relay29 (Go; group state machine + moderation actions) usable via khatru29 or strfry29 plugin wrapper. None of strfry/nostr-rs-relay/nostream core READMEs claim NIP-29.
- Source: https://github.com/nostr-protocol/nips/blob/master/29.md ; https://github.com/fiatjaf/relay29

## NIP-40 — Expiration Timestamp
- Card: HIGH confidence. One tag (`expiration`, unix seconds), no new kinds; does not affect ephemeral storage.
- All relay duties are SHOULD/MAY: MAY persist indefinitely, SHOULD NOT serve expired, SHOULD drop expired on ingress — so clients MUST filter locally; never a guarantee.
- Spec's own warning: not a security feature (public while stored; third-party archiving). Sharp contrast with NIP-62's MUST-delete + anti-rebroadcast (different strength tiers, not contradictory).
- Client gate: SHOULD NOT send expiration events to relays not listing 40 in supported_nips.
- Implemented by all three classic relays (strfry, nostr-rs-relay, nostream) — widest relay adoption in this cluster alongside NIP-28.
- Source: https://github.com/nostr-protocol/nips/blob/master/40.md

## NIP-43 — Relay Access Metadata and Requests
- Card: HIGH confidence. Full membership flow confirmed: roles 33534 (addressable) / member list 13534 (replaceable) / add-remove 8000-8001 / join 28934 (claim tag) / invite 28935 / leave 28936. All relay-side events signed by NIP-11 `self`; all carry NIP-70 `-`.
- Dual-attestation rule: 13534 is explicitly "not exhaustive or authoritative"; truth = relay's 13534 AND member's kind 10010.
- 28934/28936 have `created_at` freshness windows (± few minutes); failures use NIP-42 `restricted: ` OK prefix; success strings include `duplicate: ` and `info: welcome...` examples.
- 28935 being ephemeral is a deliberate security design: relays mint claims on-the-fly per REQ (unique/expiring/selective codes).
- Cross-NIP: depends on NIP-70 and NIP-42; role fields mirror NIP-86's createrole/editrole params (label/description/color/order) — 86 is the write API, 43 the published state. Spec prose only mandates `-` on some kinds while examples include it everywhere — noted as open question.
- Implementation: nostream is the only mainstream relay README documenting NIP-43 (invite codes, 28934/28935). strfry/nostr-rs-relay: not listed.
- Source: https://github.com/nostr-protocol/nips/blob/master/43.md ; nostream README "NIP-43 invite codes" section

## NIP-45 — Event Counts (COUNT verb + HyperLogLog)
- Card: HIGH confidence. `["COUNT", id, filters...]` → `{"count": n}`, optional `approximate`, optional `hll` (512-hex-char / 256-byte register dump). Refusal MUST be CLOSED.
- HLL offset derivation is the trickiest part and was captured in full: first `#`-tag attr → first item → 64-hex (id/pubkey as-is; address → pubkey part; else sha256) → hex char at position 32 → base-16 + 8. Merge = per-register max. Relay side is the only interop-critical half; estimator left unspecified ("check some implementation source code").
- Deterministic offset exists so relays can cache/precompute HLLs per target; canonical precomputable filters enumerated (reactions/reposts/quotes/replies/comments/followers).
- Attack vector documented in spec: grinding pubkeys for leading zero bits at the sampled position inflates counts per-target; mitigation = only trust counts from admission-filtered relays.
- Filters without a single tag attribute: HLL behavior explicitly undefined.
- Implementation: strfry and nostream; nostr-rs-relay does NOT list 45.
- Source: https://github.com/nostr-protocol/nips/blob/master/45.md

## NIP-62 — Request to Vanish (kind 62)
- Card: HIGH confidence. Hardest deletion primitive: MUST delete everything from pubkey up to request's created_at (including NIP-09 events) when relay URL tagged; `ALL_RELAYS` uppercase literal for global; MUST prevent re-broadcast (durable suppression); MUST honor even for unpaid/non-member users of paid relays.
- SHOULD also delete NIP-59 gift wraps p-tagging the user — i.e. deletes other people's DMs to you; notable third-party-data wrinkle.
- Kind-5 against kind-62 has no effect (no un-vanish); relays MAY retain the signed request for bookkeeping; clients SHOULD target only tagged relays (global version SHOULD be blasted wide).
- "Legally binding in some jurisdictions" is asserted by the spec, not substantiated — flagged in card.
- Implementation: nostream lists 62 explicitly. strfry/nostr-rs-relay don't; strfry operators can approximate via `strfry delete --filter '{"authors":[...]}'`.
- Source: https://github.com/nostr-protocol/nips/blob/master/62.md

## NIP-66 — Relay Liveness Monitoring (30166 / 10166)
- Card: HIGH confidence. Discovery mechanics confirmed: 30166 addressable with `d` = RFC-3986-normalized relay URL (hex pubkey fallback for non-URL relays); content may embed observed NIP-11 JSON; measured values MAY deliberately contradict advertised NIP-11.
- Tag vocabulary: rtt-open/read/write (ms), n (clearnet/tor/i2p/loki), T (PascalCase relay type, vocabulary deferred to nips issue #1282), N (supported NIPs), R (limitations flags with `!` negation), t topics, k kinds (`!`), g geohash, l language. Multi-values = repeated tags, never packed.
- 10166 monitor announcement: frequency, per-test timeout, c checks, g; monitors SHOULD also publish kind 0 + kind 10002.
- Risk section is normative: clients MUST NOT require 30166 to connect; SHOULD NOT trust one monitor (WoT filtering, multi-monitor, sanity threshold on filter results).
- Internal conflict found: `timeout` tag prose (index1=ms, index2=test) contradicts the example `["timeout","open","5000"]`; recorded in card open questions.
- Implementation: monitor-side NIP (nostr.watch-lineage crawlers); no relay README support needed/listed.
- Source: https://github.com/nostr-protocol/nips/blob/master/66.md

## NIP-67 — EOSE Completeness Hint
- Card: HIGH confidence. Third EOSE element: `["EOSE", sub, ["finish"|"more"|"auth", ...]]`. Presence definitive, absence not; unknown hints MUST be ignored; legacy fallback = paginate with until=oldest created_at.
- Solves two named heuristic failures: relay cap < client limit (silent data loss) and count == cap (wasted round trip).
- `"auth"` hint has an ordering MUST: NIP-42 AUTH challenge must precede the hinted EOSE. Relays SHOULD include all same-timestamp boundary events before finishing (created_at tie problem).
- Backward compat argument: positional indexing + permissive JSON parsers.
- Very recent addition; zero implementations found in surveyed relay READMEs — adoption unknown. Watch strfry/khatru changelogs.
- Source: https://github.com/nostr-protocol/nips/blob/master/67.md

## NIP-70 — Protected Events (`["-"]` tag)
- Card: HIGH confidence. Default relay behavior MUST be reject; accepting relays MUST require NIP-42 AUTH and pubkey equality. Reposts of protected events MUST NOT embed the JSON; violators SHOULD be summarily rejected.
- Framing is explicitly social: spec admits information can't truly be contained; the tag lets cooperative relays refuse to facilitate "pirates." Not access control — reads are unrestricted.
- Downstream usage is the real depth: NIP-43 mandates `-` on all six of its kinds; NIP-29 ecosystems use it for closed feeds. It's an infrastructure primitive, not an app feature.
- Gap noted: relay-to-relay sync (negentropy, strfry router) could bypass AUTH-gated write checks; spec silent.
- Implementation: strfry lists 70 (only mainstream relay README that does); khatru policies enable equivalents; nostr-rs-relay/nostream not listed.
- Source: https://github.com/nostr-protocol/nips/blob/master/70.md

## NIP-72 — Moderated Communities (34550 / 4550)
- Card: HIGH confidence. Reddit-style: addressable community def 34550 (d + name/description/image + moderator p-tags + relay-marker tags), posts are NIP-22 kind 1111 with dual-scope tags (uppercase A/P/K = community, lowercase = parent), approvals kind 4550 embedding the full post JSON.
- Non-obvious load-bearing detail: approvals of replaceable posts via `e` MUST embed content because relays purge old versions; moderator rotation can erase community history since validity keys on the current 34550 roster — mitigations (multi-approvals, owner re-signing) are in-spec.
- Backwards-compat: legacy kind-1 + `a` tag posts may still be queried but SHOULD NOT be created.
- Cross-posting via NIP-18 kind 6/16 with content = original event (not the approval).
- Status conflict: README strikethrough "unrecommended: try NIP-29" + in-file banner, yet it's the more decentralized model (no relay enforcement). NIP-29 wins on enforcement, NIP-72 on relay-agnosticism — real design tradeoff.
- Relay support: none needed (client-side convention).
- Source: https://github.com/nostr-protocol/nips/blob/master/72.md

## NIP-78 — Arbitrary custom app data (78 / 30078)
- Card: HIGH confidence. 30078 addressable (d = app/context string), 78 regular for multi-record apps (group by unique tag); content/tags fully app-defined.
- The one relay rule: SHOULD require NIP-42 AUTH before accepting or serving, and SHOULD serve only to the authenticated owner — a SHOULD, so privacy cannot be assumed; spec's intent is private user data (remoteStorage analogy).
- Explicit anti-interop stance: "not meant to be used as a generic interchange format"; interoperable data must get dedicated kinds.
- Encryption of payloads is conventional (NIP-44) but unspecified — flagged as open question.
- No relay README claims needed; any relay with NIP-42 + generic storage suffices (nostream lacks NIP-42 in README list — caveat for "private" 78 storage there).
- Source: https://github.com/nostr-protocol/nips/blob/master/78.md

## NIP-86 — Relay Management API
- Card: HIGH confidence. Full 25-method list captured: supportedmethods; ban/unban/list pubkeys; allow/unallow/list pubkeys; create/edit/delete/assign/unassign roles; listeventsneedingmoderation; allow/ban/list events; changerelayname/description/icon; allow/disallow/list kinds; block/unblock/list IPs.
- Transport: POST to the relay's own WS URI with `Content-Type: application/nostr+json+rpc`; `{method, params[]}` → `{result, error?}`; all mutations return boolean true.
- Auth binding: NIP-98 event in Authorization header, `u` = relay URL, and — stricter than base NIP-98 — the `payload` tag is REQUIRED (binds body hash; anti body-swap replay). 401 on missing/invalid.
- No admin ACL specified — who may call what is relay policy; list methods expose sensitive ops data.
- Cross-NIP: role methods mirror NIP-43 kind 33534 fields exactly (86 = management plane, 43 = data plane); changerelay* mutates NIP-11 fields.
- Implementation: no surveyed relay README lists 86 by number; khatru's custom-HTTP-handler design is the natural host; nostream ships equivalent admin via CLI instead. Treat relay support as fragmented.
- Source: https://github.com/nostr-protocol/nips/blob/master/86.md

---

## Cluster-level observations
- Deprecation axis: 28 and 72 are both unrecommended → 29. Both are client-side-moderation models; 29's differentiator is relay-enforced write access + relay-signed state (39000-series by NIP-11 `self` key). Same `self`-key trust anchor pattern appears in NIP-43.
- NIP-70 `-` is the connective tissue of the relay-side cluster: mandated by NIP-43 on all kinds, philosophically aligned with 29's closed groups, dependent on NIP-42 — which is also the gate for NIP-78 privacy and NIP-67's `"auth"` hint. NIP-42 support is the de facto dividing line between modern and legacy relays (strfry + nostr-rs-relay have it; nostream README does not list 42).
- Deletion strength ladder: NIP-40 (advisory expiry) < NIP-09 (requests, keepable) < NIP-62 (MUST delete + anti-rebroadcast + claimed legal force).
- Counting/liveness are monitor/aggregation-layer concerns (45, 66, 67) with explicit distrust semantics (HLL grinding attack, monitor WoT, EOSE hint asymmetry) — a shared "don't trust, corroborate" design ethos.
- Spec-quality issues found: NIP-66 timeout tag prose/example contradiction; NIP-43 inconsistent `-` tag mandating; NIP-45 estimator deliberately unspecified; NIP-86 lacks error taxonomy and ACL model.
