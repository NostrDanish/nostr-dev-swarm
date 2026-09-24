# Tag Conventions

Source: https://github.com/nostr-protocol/nips/blob/master/01.md (+ per-NIP files listed below)
Retrieved: 2026-09-23
Confidence: HIGH for NIP-01 base tags; MEDIUM for the supplementary list (non-exhaustive).

## CRITICAL FINDING
The current nips README (verified 2026-09-23) **no longer contains a standardized-tags table**. Older revisions had one. Do not cite a "README tag registry" — it does not exist at master today. Normative base-layer tags live in NIP-01.

## NIP-01 standard tags (valid across all kinds)

| Tag | Form | Meaning |
|---|---|---|
| e | `["e", <32-byte hex event id>, <relay URL?>, <author pubkey?>]` | Event reference |
| p | `["p", <32-byte hex pubkey>, <relay URL?>]` | User reference |
| a | `["a", "<kind>:<pubkey>:<d-tag>", <relay URL?>]` | Addressable event reference (trailing colon for plain replaceable) |

Indexing convention (NIP-01): all single-letter tags (a–z, A–Z) are expected to be indexed by relays and filterable via `#<letter>` in filters; only the FIRST value of each tag is indexed.

## Supplementary tags observed in NIP files (non-exhaustive — verify in the defining NIP before use)

| Tag | Meaning | Defining NIPs |
|---|---|---|
| d | Unique identifier for addressable events | 01 (implicit), 23, 51, 99 |
| k | Stringified kind number of referenced/target event | 09, 25, 57, 73 |
| t | Hashtag/topic | 23, 51, 99 |
| r | Relay reference, optional read/write marker | 65 |
| i | External content identity / infohash | 73, 94 |
| g | Geohash | 99 |
| u | Absolute URL (HTTP auth) | 98 |
| m | MIME type | 94 |
| x / ox | SHA-256 of (transformed) file / of original | 94, 17 |
| P | Pubkey of zap request sender (uppercase) | 57 |
| q | Quote-repost reference `["q", <id-or-address>, <relay?>, <pubkey?>]` | 18 (definition), 17 (chat usage) |
| nonce | PoW commitment | 13 |
| expiration | Drop-after timestamp | 40 |
| subject | Conversation subject | 14, 17 |
| content-warning | Sensitive-content flag | 36 |
| delegation | Delegated signing | 26 (unrecommended) |
| proxy | Bridged-from protocol marker | 48 |
| emoji | Custom emoji shortcode | 30 |
| imeta | Inline media metadata | 92 |
| zap | Weighted zap split | 57 |
| `-` | Protected-event marker | 70 |
| client | Attribution (privacy opt-out advised) | 89 |
| payload | SHA-256 of HTTP request body | 98, 86 |
| method | HTTP method | 98 |
| relay / challenge | AUTH bindings | 42 |
| alt | Fallback description | 31 (unrecommended) |

## Rules
1. Single-letter tags get relay indexing; multi-letter tags generally do not — design accordingly.
2. Never reuse a standardized tag with different semantics.
3. When designing events, document required vs optional tags explicitly and check conflicts against this file first.
