# NIP-46 — Nostr Remote Signing ("bunkers")

Source: https://github.com/nostr-protocol/nips/blob/master/46.md
Retrieved: 2026-09-23
Status: not formally marked (file has no status header)
Confidence: HIGH for protocol mechanics; MEDIUM for deployment specifics.

## Model
JSON-RPC-like request/response between a client and a remote signer over kind **24133** events with NIP-44-encrypted content, p-tagging the counterparty.

Three keypairs: client-keypair (ephemeral, disposable), remote-signer-keypair (transport), user-keypair (the identity actually signing). Clients MUST call `get_public_key` after connect.

## Bootstrap
- Signer-initiated: `bunker://<remote-signer-pubkey>?relay=...&secret=...`
- Client-initiated: `nostrconnect://<client-pubkey>?relay=...&secret=...&perms=...`
- The `secret` MUST be validated — prevents connection spoofing.

## Methods
`connect`, `sign_event`, `ping`, `get_public_key`, `nip04_encrypt`, `nip04_decrypt`, `nip44_encrypt`, `nip44_decrypt`, `switch_relays`, `logout`.
Permissions expressed as `method[:kind]` lists. Signers may respond `result: "auth_url"` with URL in `error` for out-of-band auth challenges.

## Discovery
NIP-05 (`nostr.json?name=_` with a `nip46` section) and NIP-89 kind 31990 with `k` = 24133.

## Security notes (swarm-enforced)
- The signer is a trusted component: it holds the user key. Threat-model it like an HSM with a network API.
- Per-app/per-kind permission scoping is mandatory UX, not optional.
- AI agents MUST NOT be signers; AI produces unsigned intents → policy engine → human/trusted approval → signer (ADR-0002).
- Signer software supply chain is critical: the nsecbunkerd incident (2026-06, repo wiped upstream) shows the risk. Known signers: Amber (Android, NIP-55+NIP-46, GPG-signed releases), bunker46, Signet (self-described rewrite), nos2x (NIP-07, not 46), nsec.app/noauth.
- Relay availability is a liveness dependency: signer and client must share reachable relays; `switch_relays` exists for this.

## Concrete attack scenarios (added post-challenge, ADR-0004)
- **auth_url phishing:** the signer supplies the URL the client renders; a malicious/compromised signer can serve a credential-phishing page under the guise of an auth challenge. Clients must display the URL origin prominently; signers should only use first-party URLs.
- **Decryption oracle:** `nip04_decrypt`/`nip44_decrypt` let any connected client decrypt arbitrary historical DMs. Per-method permission scoping is mandatory; decrypt methods should be off by default and separately gated.
- **Standing session:** once connected, a client holds `sign_event` capability until `logout`. Signers need session revocation UI, per-session rate limits, and idle expiry. Compromised-session handling must be defined before deployment.
