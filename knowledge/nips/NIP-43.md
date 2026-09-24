# NIP-43 — Relay Access Metadata and Requests

Source: https://github.com/nostr-protocol/nips/blob/master/43.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay`; not marked unrecommended in README
Confidence: HIGH (spec-read)

## Purpose
Defines how relays advertise **membership lists and roles**, and how clients request admission to a relay (invite-claim join, invite issuance, leave). Targets closed/member-only relays. Every relay-generated event MUST be signed by the pubkey in the relay's NIP-11 `self` field, and every NIP-43 event (both directions) carries a NIP-70 `-` protected tag.

## Event kinds
| kind | class | role |
|---|---|---|
| 33534 | addressable | relay role definition (`d` = role id; tags `label`, `description`, `color` hue 0–360, `order` int) |
| 13534 | replaceable | relay membership list: repeated `member` tags with hex pubkey + optional role ids as subsequent args |
| 8000 | regular | "add user" announcement (`p` tag) |
| 8001 | regular | "remove user" announcement (`p` tag) |
| 28934 | ephemeral | join request — MUST have `claim` tag with invite code; `created_at` MUST be now ± a few minutes |
| 28935 | ephemeral | invite response — relay-signed, `claim` tag; relays generate on the fly when REQ'd |
| 28936 | ephemeral | leave request; `created_at` MUST be now ± minutes |

## Tags defined/used
- `-` (NIP-70 protected) — required on essentially all kinds in this NIP (33534, 13534, 8000, 8001, 28936 explicitly; join request example includes it).
- `d` — role id on 33534.
- `member <pubkey> [role-id...]` — on 13534.
- `p` — member pubkey on 8000/8001.
- `claim` — invite code on 28934/28935.

## Content format
Not specified / unconstrained — all semantics in tags; examples show empty content.

## Semantics & rules
- **Membership is dual-attested**: 13534 "should not be considered exhaustive or authoritative" — both the relay's 13534 AND the member's own `kind:10010` event should be consulted to determine membership.
- **Join**: relay MUST answer 28934 with an `OK` message indicating claim status. Failed claims SHOULD use NIP-42's `"restricted: "` prefix. Examples from spec:
  - `["OK", <id>, false, "restricted: that invite code is expired."]`
  - `["OK", <id>, true, "duplicate: you are already a member of this relay."]`
  - `["OK", <id>, true, "info: welcome to wss://relay.bunk.skunk!"]`
- On success relay SHOULD update 13534 and MAY publish 8000; on leave (28936) SHOULD update 13534 and MAY publish 8001.
- **Invites on demand**: because 28935 is ephemeral, relays must opt in by generating claims when queried — enables per-request unique codes, selective issuance, expiry.
- **Gating**: clients MUST only REQ 28935 from, and send 28934 to, relays advertising NIP-43 in NIP-11 `supported_nips`.
- Role-based differential relay policies are allowed but "no mechanism for introspection is defined at this time."

## Security & privacy notes
- Everything rides on NIP-70 protection + NIP-11 `self` key: only the relay can mint roles/lists/invites; only the authenticated author can publish their own requests. A relay not honoring NIP-70 could accept forged 13534/28935 from anyone.
- Claim codes are bearer credentials; time-windowing `created_at` on 28934/28936 limits replay.
- Membership lists are public metadata — leaks who uses a closed relay.

## Interoperability notes
- Hard dependency on NIP-70 (`-` tag), NIP-11 (`self`), NIP-42 (OK prefix conventions), and NIP-51 kind 10010 (member-side attestation).
- NIP-86 role methods (`createrole`/`assignrole` etc.) mirror 33534 role fields (`label`, `description`, `color`, `order`) — management-API counterpart.
- nostream README documents NIP-43 invite codes: kind 28934 join implemented, `nostream invite create` CLI, opt-in `nip43.allowInviteRequests` for on-the-fly 28935 minting. strfry/nostr-rs-relay do not list it.

## Example
Join request (from spec):
```yaml
{
  "kind": 28934,
  "pubkey": "<user pubkey>",
  "tags": [["-"], ["claim", "<invite code>"]]
}
```
Role definition (from spec):
```yaml
{
  "kind": 33534,
  "pubkey": "<nip11.self>",
  "tags": [["-"], ["d", "28b7e50f"], ["label", "king"],
           ["description", "ruler of the relay"], ["color", "37"], ["order", "1"]]
}
```

## Open questions / uncertainties
- The join-request example includes `-`, but the prose only mandates `-` explicitly for 28936, 33534, 13534, 8000, 8001; whether 28934 strictly requires it is ambiguous in wording.
- No introspection for what a role *grants*; policy mapping is relay-internal.
- 13534 non-authoritative stance means membership truth is fuzzy when relay and user lists disagree.
