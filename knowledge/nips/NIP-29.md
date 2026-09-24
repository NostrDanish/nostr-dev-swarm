# NIP-29 — Relay-based Groups

Source: https://github.com/nostr-protocol/nips/blob/master/29.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay`; recommended by README (NIP-28 and NIP-72 both redirect here)
Confidence: HIGH (spec-read)

## Purpose
Groups that live on and are governed by a **specific relay**: writable by a closed set of users, optionally readable by outsiders. There is no "create group" protocol message — a relay simply begins enforcing rules around a group **id** (a random string of any length). Groups can migrate to another relay (copying events, keeping admins) or **fork** (same id, different admins/moderation policy on a different relay) — forks are explicitly a feature, not a bug.

## Event kinds
| kind(s) | class | role |
|---|---|---|
| 9000–9020 (range 9000–9030 reserved per README kind table) | regular | moderation/group-control events, sent by relay master key or authorized admins: 9000 `put-user` (`p` + optional roles), 9001 `remove-user` (`p`), 9002 `edit-metadata` (all group-metadata fields), 9005 `delete-event` (`e`), 9007 `create-group`, 9008 `delete-group`, 9009 `create-invite` (`code`), 9010 `update-pin-list` (`e`/`a` full list) |
| 9021 | regular | join request (user → relay; optional `code` tag for invite) |
| 9022 | regular | leave request (relay auto-issues 9001) |
| 39000 | addressable | group metadata (relay-signed, `d` = group id) |
| 39001 | addressable | group admins (`p` tags with roles) |
| 39002 | addressable | group members list (may be partial/absent) |
| 39003 | addressable | group roles supported by the relay |
| 39004 | addressable | livekit participants (AV room presence) |
| 39005 | addressable | group pinned events (`e` and `a` tags, ordered) |
| 10009 (NIP-51) | replaceable | user's list of groups with relay hints — used for migration/fork detection |

## Tags defined/used
- `h` — REQUIRED on every user/moderation event sent to a group; value = group id.
- `previous` — timeline references: first 8 hex chars (4 bytes) of event ids among the last ~50 events seen on that relay (excluding own events); ≥3 recommended, relays expected to enforce and reject references to events not in their DB. Anti-out-of-context-fork hack.
- `d` — group id on the relay-generated 39000-series metadata events.
- `code` — invite code on 9021 join requests.
- On 39000: `name`, `picture`, `banner`, `about`, `private` (only members read), `restricted` (only members write), `hidden` (hide metadata from non-members), `closed` (join requests ignored), `livekit` (AV support), `supported_kinds` (stringified kind numbers; empty = AV-only group).
- Subgroups: `parent` and ordered `child` tags on 39000.
- `participant` tags on 39004; `role` tags on 39003.

## Content format
- Moderation events: `content` = optional human-readable reason string.
- 39000-series: relay-generated addressable events, `content` empty or descriptive text (39000 has empty content; metadata lives in tags). Signed by the relay's NIP-11 `self` pubkey; spec: relays "shouldn't accept" these from anyone else (SHOULD-level, corrected post cross-check — not MUST NOT); one instance per group at a time.
- Group referencing: `naddr1...` pointing at the 39000 event (pubkey = relay self key, `d` = group id, relay hint); optional `?invite=<code>` suffix (valid because `?` is outside the bech32 charset).

## Semantics & rules
- **Join flow**: user sends 9021 with `h` tag (+ optional `code`). Relay MUST reject if user hasn't been added; error SHOULD explain final vs pending review vs special handling (e.g. payment). If already a member, MUST reject with `duplicate: ` prefix. On accept, relay emits 9000.
- **Leave flow**: 9022 → relay automatically issues 9001 removing the user.
- **Authorization**: spec: relays "should reject" 9000-series moderation events from pubkeys not authorized per role/relay policy (SHOULD-level, corrected post cross-check). Group state is expected to be fully reconstructible from the canonical sequence of moderation events (spec: "It's expected that…" — expectation, not MUST).
- **Membership check**: latest of 9000/9001 for a user determines membership; absence ⇒ not a member. Clients MUST NOT assume membership inheritance between subgroups.
- **Late publication**: relays should reject messages with timestamps hours/days old, unless they deliberately accept migrated/forked groups.
- **Migration/fork detection**: clients SHOULD (MUST when primary relay is unreachable) check admins' and trusted friends' `kind:10009` for changed relay hints; admin pubkeys SHOULD be cached locally. On change, notify user and offer to migrate participation.
- **Replication**: groups SHOULD maintain a live replica relay preserving history; replica need not enforce moderation.
- **Subgroup rules**: parenting via `kind:9002` with a single `parent` tag (at most one; absence = root). Relay MUST reject cycles/self-reference, nonexistent parents, parents the author isn't admin of (per that parent's 39001), and metadata edits omitting existing `child` tags. Parent deletion (9008) promotes children to roots. Relay support advertised via NIP-11 `nip29: {"subgroups": true}`.
- **LiveKit AV**: token endpoint at `https://relay.tld/.well-known/nip29/livekit/<group-id>` with NIP-98-style auth (kind 27235, `u` tag = endpoint URL). JWT `sub` MUST begin with the user's 64-char lowercase hex pubkey (plus random suffix for multi-session). Relay support detection: `204` at `/.well-known/nip29/livekit`.
- Role names are relay policy (`39003` advertises them); this NIP deliberately does not define role capabilities.

## Security & privacy notes
- Group confidentiality depends entirely on the hosting relay; a `private` group is only private if the relay honors it (relay can read everything; forks change who is admin).
- `previous`-tag mechanism exists to prevent replaying group messages out of context into forked relays; clients should verify references to keep relays honest.
- Join-request rejections can leak whether a pubkey is already a member (`duplicate:` response).
- Invite codes (9009/9021) are bearer secrets — relay decides acceptance.

## Interoperability notes
- Kind 10009 defined in NIP-51 stores user's group list with relay hints; basis for fork detection.
- NIP-11 `self` pubkey is the anchor of authenticity for all 39000-series events.
- NIP-98 HTTP auth reused for LiveKit token endpoint.
- Groups can carry any other NIP's kinds (`supported_kinds`), plus `h` tag.
- Reference implementation: **relay29** (fiatjaf, khatru-based NIP-29 relay). khatru framework provides custom-policy hooks used to build such relays. strfry/nostr-rs-relay/nostream READMEs do not claim NIP-29 support.

## Example
Moderation event (from spec):
```yaml
{
  "kind": 90xx,
  "content": "optional reason",
  "tags": [["h", "<group-id>"], ["previous", "eb96c864", "2db75638", "b5d1065f"]]
}
```
Join request (from spec):
```json
{"kind": 9021, "content": "optional reason",
 "tags": [["h", "<group-id>"], ["code", "<optional-invite-code>"]]}
```

## Open questions / uncertainties
- Role→capability mapping intentionally unspecified; inter-relay governance portability is informal.
- 39002 members list may be partial/restricted — no authoritative membership proof beyond 9000/9001 history.
- Kind numbers 9003/9004/9006 and 9011–9030 within the reserved range are unassigned in the spec text.
