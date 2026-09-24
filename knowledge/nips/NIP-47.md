# NIP-47 — Nostr Wallet Connect (NWC)

Source: https://github.com/nostr-protocol/nips/blob/master/47.md
Retrieved: 2026-09-23
Status: `draft` `optional` (not unrecommended)
Confidence: HIGH (spec-read)

## Purpose
Lets a client app remotely control a Lightning wallet via E2E-encrypted messages over Nostr relays — the wallet service holds the keys/node API access; the client holds only a per-connection secret. Extensions live in https://github.com/nostr-wallet-connect/nwc.

## Event kinds
- `13194` — replaceable: **info event** published by wallet service; `content` = space-separated supported methods (e.g. `pay_invoice get_balance make_invoice lookup_invoice get_info`).
- `23194` — ephemeral: **request** (client → wallet service).
- `23195` — ephemeral: **response** (wallet service → client).

## Tags defined/used
- `encryption` — space-separated schemes (`nip44_v2 nip04`); absence of tag implies legacy NIP-04 only.
- `extensions` — supported NWC extension spec ids (e.g. `02 03 04`).
- `p` — counterparty pubkey (request tags wallet service; response tags client). Both SHOULD have exactly one.
- `e` — response tags the request event id.
- `expiration` — optional unix ts; requests received after it should be ignored.

## Content format
Request/response `content` = NIP-44 (preferred) or NIP-04 (legacy) encrypted JSON-RPC-ish object.
- Request: `{method, params}`.
- Response: `{result_type (MUST equal method name), error: {code, message} | null, result: {...} | null}`.
- Connection URI: `nostr+walletconnect://<wallet-service-pubkey>?relay=wss://...&secret=<32-byte-hex>[&lud16=...]`. `relay` (required, multiple allowed), `secret` (required — the **client's** ephemeral secret key), `lud16` (recommended).

## Semantics & rules
Core methods: `pay_invoice` (params: `invoice` bolt11, optional `amount` msats, `metadata`; result: `preimage`, optional `fees_paid`), `make_invoice` (amount msats, description/description_hash, expiry; returns invoice + payment_hash), `lookup_invoice` (payment_hash or invoice; states: pending/settled/accepted/expired/failed), `get_balance` (msats), `get_info` (alias, pubkey, network, methods, extensions).
- Error codes: `RATE_LIMITED`, `NOT_IMPLEMENTED`, `INSUFFICIENT_BALANCE`, `QUOTA_EXCEEDED`, `RESTRICTED`, `UNAUTHORIZED`, `INTERNAL`, `UNSUPPORTED_ENCRYPTION`, `OTHER`, plus method-specific `PAYMENT_FAILED`, `NOT_FOUND`.
- Wallet service MUST authorize the requester's pubkey before acting; `secret` in URI is used by the client to sign and encrypt; wallet service uses the corresponding pubkey. Wallet service SHOULD NOT store the client secret and MUST NOT depend on knowing it for general operation.
- Wallet service pubkey in the URI SHOULD be unique per client connection (authorization granularity, revocability, privacy).
- Encryption negotiation: client reads `encryption` tag from info event; MUST pick a scheme the wallet service supports; always prefer `nip44_v2`; absence of tag ⇒ NIP-04 assumed (deprecated).
- Events are ephemeral: choose relays that don't close idle connections; relays should retain until consumed/stale.

## Security & privacy notes
- **Funds at risk**: the connection URI `secret` is a full spending credential (subject to wallet-side budgets/quotas). Leakage of the URI or relay-side metadata + any encryption weakness = theft up to wallet-enforced limits. URI must be treated like a password.
- Legacy NIP-04 encryption is deprecated (weak); wallets/clients lacking the `encryption` tag silently fall back to it — implementers MUST prefer NIP-44 and treat NIP-04 as compat-only.
- Relay sees kinds/tags/timing (metadata leak: payment frequency, counterparty pubkeys) though not content. Custodial setups should use a dedicated authenticated relay.
- User identity key is deliberately NOT used; unique keys per connection prevent linking payment activity to the user's main npub.
- `preimage` returned in `pay_invoice` result is the payment proof — only visible inside the encrypted payload.
- Budget/permission enforcement (`QUOTA_EXCEEDED`, `RESTRICTED`) is entirely wallet-service-side; NIP-47 core defines no granular auth model (deferred to NWC extensions).

## Interoperability notes
- Independent of NIP-57 zaps but commonly used to pay zap invoices; `lud16` param bootstraps the user's Lightning address profile field.
- Extended by NWC repo specs (02.md onward: notifications, auth flows, etc.); `01.md` there mirrors this core.

## Example
Real spec connection string:
```
nostr+walletconnect://b889ff5b1513b641e2a139f661a661364979c5beee91842f8f0ef42ab558e9d4?relay=wss%3A%2F%2Frelay.damus.io&secret=71a8c14c1407c113601079c4302dab36460f0ccd0ad506f1f2dc73b5100e4f3c
```

## Open questions / uncertainties
- Relay delivery guarantees for ephemeral events are implementation-defined; dropped events = stuck payments with no protocol-level retry semantics.
- No standard for rotating/revoking connections beyond deleting wallet-side authorization.
