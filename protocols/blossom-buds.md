# Blossom BUDs — BUD-by-BUD reference (complements blossom.md)

Source: https://github.com/hzrd149/blossom (README.md + buds/00.md … buds/12.md, read in full)
Retrieved: 2026-09-23
Confidence: HIGH (Tier 1 spec repo, all 13 documents read directly).

BUDs = "Blossom Upgrade Documents" (BUD-00: RFC-2119 language; a BUD may define server requirements or pure client-side conventions). Blobs = raw binary addressed by SHA-256. All BUDs are `draft`; only BUD-00 and BUD-01 are `mandatory`.

## BUD table

| BUD | Title | Level | Endpoints / events | Summary |
|---|---|---|---|---|
| 00 | Blossom Upgrade Documents | mandatory | — | Meta-document: common language, blob definition |
| 01 | Server requirements & blob retrieval | mandatory | `GET /<sha256>[.ext]`, `HEAD /<sha256>[.ext]` | Endpoints at domain root; CORS `*`; `X-Reason` error header; correct `Content-Type` (default `application/octet-stream`); optional 3xx redirect ONLY to URLs containing the same hash; Range requests recommended; optional `Sunset` header for retention |
| 02 | Blob upload | optional | `PUT /upload` | Server MUST NOT modify bytes, MUST hash exact bytes; 201 new / 200 existing; optional `X-SHA-256` pre-declaration (409 on mismatch). Defines **Blob Descriptor**: `{url (must have file ext), sha256, size, type, uploaded}` + optional `magnet`/`infohash`/`ipfs` |
| 03 | User Server List | optional | kind `10063` | Replaceable event, ordered `server` tags (most trusted first). Clients MUST upload to ≥ first server. Retrieval fallback: take LAST 64-char hex in a URL as the hash → walk author's 10063 list → well-known servers |
| 04 | Mirroring blobs | optional | `PUT /mirror` | Body `{"url": ...}`; server fetches, verifies hash vs auth token `x` tag; enables redundancy without client re-upload |
| 05 | Media optimization | optional | `PUT /media`, `HEAD /media` | Trusted server-side optimization/transcoding; returns descriptor of the NEW blob; optimization is entirely server's choice; pattern: upload to trusted /media → /mirror result elsewhere |
| 06 | Upload requirements | optional | `HEAD /upload` | Preflight with `X-SHA-256`, `X-Content-Type`, `X-Content-Length`; advisory only, never a guarantee; not a substitute for `HEAD /<sha256>` existence check |
| 07 | Payment required | optional | any (402) | `402` + `X-Cashu` (NUT-24) and/or `X-Lightning` (BOLT-11) headers; retry same request with proof (cashuB token / preimage) in same header; HEAD endpoints MUST NOT be retried with proofs; failed proof → 400 + X-Reason; extensible to new X-{method} headers |
| 08 | Nostr File Metadata Tags | optional | response field | Servers MAY add `nip94` array (NIP-94 tags: url, m, x, size, magnet, i, ...) to blob descriptors from /upload and /mirror |
| 09 | Blob Report | optional | `PUT /report` | Body = signed NIP-56 kind 1984 event with `x` tags of blob hashes; servers MAY use trusted moderators, MAY block deleted hashes from re-upload, SHOULD publish ToS |
| 10 | Blossom URI Schema | optional | `blossom:` URIs | `blossom:<sha256>.<ext>[?xs=server&as=pubkey&sz=bytes]`; ext defaults `.bin`; resolution order: `xs` hints → `as` author server lists (BUD-03) → well-known fallback; verify `sz` on download |
| 11 | Nostr Authorization | optional | kind `24242` | Auth = signed kind-24242 event: human-readable content, required NIP-40 `expiration`, `t` verb (`get\|upload\|list\|delete\|media`), optional `server` (domain) and `x` (hash) scoping; header `Authorization: Nostr <base64url(event)>`; per-endpoint verb + x-tag matrix; WARNING: unscoped delete tokens replayable across servers |
| 12 | Blob management | optional | `GET /list/<pubkey>` (unrecommended), `DELETE /<sha256>` | List: cursor+limit pagination (`since`/`until` deprecated for pagination); Delete: servers MUST accept; multiple x tags ≠ multi-delete |

## Endpoint → BUD map
`GET|HEAD /<sha256>` = BUD-01 · `PUT /upload` = BUD-02 · `HEAD /upload` = BUD-06 · `PUT /mirror` = BUD-04 · `PUT|HEAD /media` = BUD-05 · `PUT /report` = BUD-09 · `GET /list/<pubkey>` + `DELETE /<sha256>` = BUD-12 · auth for all = BUD-11 · payments = BUD-07.

## Event kinds
`24242` authorization token (BUD-11); `10063` user server list (BUD-03, = NIP-B7 server list).

## Security notes for implementers
- Verify blob hash after download/mirror; server-hash match is the integrity model.
- Scope auth tokens with `server` + `x`; keep expirations short (unscoped tokens replay anywhere).
- `X-Reason` is human-readable only; clients MUST NOT parse it for control flow.
- Redirect targets must still carry CORS + Content-Type headers (proxy or extension-based MIME).
