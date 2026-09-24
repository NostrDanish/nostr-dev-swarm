# NIP-01 — Basic Protocol Flow

Source: https://github.com/nostr-protocol/nips/blob/master/01.md
Retrieved: 2026-09-23
Status: `draft` `mandatory` `relay` (file header)
Confidence: HIGH.

## Event object
```json
{
  "id": "<32-byte lowercase hex SHA-256 of serialization>",
  "pubkey": "<32-byte lowercase hex>",
  "created_at": <unix seconds>,
  "kind": <0..65535>,
  "tags": [["<tag>", "<value>", ...], ...],
  "content": "<string>",
  "sig": "<64-byte lowercase hex Schnorr sig over id>"
}
```
Serialization for id: UTF-8 JSON `[0, pubkey, created_at, kind, tags, content]` — strict escape list (`\n \" \\ \r \t \b \f` only), no whitespace.

## Kind ranges
| Range | Class |
|---|---|
| 1000–9999, 4–44, 1, 2 | Regular (store all) |
| 10000–19999, 0, 3 | Replaceable (latest per pubkey+kind) |
| 20000–29999 | Ephemeral (don't store) |
| 30000–39999 | Addressable (latest per pubkey+kind+d) |

Equal timestamps → lowest id wins. Relays SHOULD return only the latest replaceable event per filter.

## Filters
`{ids, authors, kinds, "#<letter>": [...], since, until, limit}`
- Values within a list OR-ed; attributes AND-ed; multiple filters in one REQ OR-ed.
- `ids`/`authors`/`#e`/`#p` MUST be exact 64-char lowercase hex.
- `limit` applies to initial query only; `limit: 0` = no stored events, EOSE still sent, subscription stays live.

## Standard tags
`e` (event ref + optional relay + author), `p` (pubkey ref + optional relay), `a` (addressable ref `<kind>:<pubkey>:<d>`). All single-letter tags expected indexed; first value only.

## Messages
Client→relay: `EVENT`, `REQ`, `CLOSE`. Relay→client: `EVENT`, `EOSE`, `OK`, `CLOSED`, `NOTICE`.
`OK`/`CLOSED` prefixes: `duplicate`, `pow`, `blocked`, `rate-limited`, `invalid`, `restricted`, `mute`, `error`.

## Swarm implementation notes
- Verify sig before ANY processing or caching (RUSTSEC-2026-0224 precedent: cache poisoning bypassed verification).
- Bound tag counts, content length, filter complexity server-side; NIP-11 `limitation` advertises these.
- created_at is author-claimed — never use it as trusted ordering.
