# NIP-86 — Relay Management API

Source: https://github.com/nostr-protocol/nips/blob/master/86.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README
Confidence: HIGH (spec-read)

## Purpose
A JSON-RPC-like management API for relays, served over **HTTP on the same URI as the relay's websocket endpoint**: moderation (ban/allow pubkeys & events), kind filtering, IP blocking, relay metadata editing, and role management (complementing NIP-43 roles).

## Event kinds
None directly — but authorization uses NIP-98 **kind 27235** HTTP-auth events.

## Tags defined/used
On the NIP-98 auth event: standard `u` tag (= the relay URL) and — diverging from vanilla NIP-98 — the **`payload` tag is required**.

## Content format
Trigger: HTTP(S) request to a WebSocket-upgradeable URI with header `Content-Type: application/nostr+json+rpc`.

Request body:
```json
{ "method": "<method-name>", "params": ["<array>", "<of>", "<parameters>"] }
```
Response:
```json
{ "result": {"<arbitrary>": "<value>"}, "error": "<optional error message, if the call has errored>" }
```

## Semantics & rules — full method list
| method | params | result |
|---|---|---|
| `supportedmethods` | `[]` | array of names of all other supported methods |
| `banpubkey` | `["<hex pubkey>", "<optional reason>"]` | `true` |
| `unbanpubkey` | `["<hex pubkey>", "<optional reason>"]` | `true` |
| `listbannedpubkeys` | `[]` | `[{"pubkey": ..., "reason": ...}, ...]` |
| `allowpubkey` | `["<hex pubkey>", "<optional reason>"]` | `true` |
| `unallowpubkey` | `["<hex pubkey>", "<optional reason>"]` | `true` |
| `listallowedpubkeys` | `[]` | `[{"pubkey": ..., "reason": ...}, ...]` |
| `createrole` | `[id, label, description, color, order]` | `true` |
| `editrole` | `[id, label, description, color, order]` | `true` |
| `deleterole` | `[id]` | `true` |
| `assignrole` | `["<hex pubkey>", "<role-id>"]` | `true` |
| `unassignrole` | `["<hex pubkey>", "<role-id>"]` | `true` |
| `listeventsneedingmoderation` | `[]` | `[{"id": ..., "reason": ...}, ...]` |
| `allowevent` | `["<hex event id>", "<optional reason>"]` | `true` |
| `banevent` | `["<hex event id>", "<optional reason>"]` | `true` |
| `listbannedevents` | `[]` | `[{"id": ..., "reason": ...}, ...]` |
| `changerelayname` | `["<new name>"]` | `true` |
| `changerelaydescription` | `["<new description>"]` | `true` |
| `changerelayicon` | `["<new icon url>"]` | `true` |
| `allowkind` | `[<kind number>]` | `true` |
| `disallowkind` | `[<kind number>]` | `true` |
| `listallowedkinds` | `[]` | `[<kind number>, ...]` |
| `blockip` | `["<ip address>", "<optional reason>"]` | `true` |
| `unblockip` | `["<ip address>"]` | `true` |
| `listblockedips` | `[]` | `[{"ip": ..., "reason": ...}, ...]` |

Relays may support any subset; `supportedmethods` is the discovery mechanism. All mutating methods return boolean `true` on success.

## Security & privacy notes
- **Authorization**: every request MUST carry an `Authorization` header with a valid NIP-98 event; `u` tag = relay URL, and unlike base NIP-98 the `payload` tag is **required** (binds the request body's hash into the signed event, preventing header-only replay with swapped bodies). Missing/invalid auth ⇒ HTTP 401.
- The spec defines no admin ACL — which pubkeys may call which methods is entirely relay policy.
- `listblockedips`/`listeventsneedingmoderation` expose sensitive operational data to whoever is authorized.

## Interoperability notes
- Binds NIP-98 (HTTP auth, kind 27235) with a stricter payload requirement.
- Role methods mirror NIP-43 `kind:33534` role fields (`label`, `description`, `color`, `order`) — NIP-86 is the management write-side, NIP-43 the published read-side.
- `changerelayname`/`description`/`icon` mutate the NIP-11 document fields.
- Implementations: khatru-based relays commonly expose NIP-86-style management; nostream provides equivalent admin via CLI. strfry/nostr-rs-relay READMEs don't mention NIP-86.

## Example
Constructed example (spec gives only schemas):
```
POST https://relay.example/  (Content-Type: application/nostr+json+rpc)
Authorization: Nostr <base64 kind-27235 event with u + payload tags>

{"method": "banpubkey", "params": ["<hex pubkey>", "spam"]}
→ {"result": true}
```

## Open questions / uncertainties
- No standard error-code taxonomy beyond the `error` string.
- No pagination/limits on list methods.
- Granularity of admin permissions (multi-admin relays) unspecified.
- `payload` requirement conflicts with plain NIP-98 clients that omit it for bodyless requests — here the body is always present, but tooling must support payload hashing.
