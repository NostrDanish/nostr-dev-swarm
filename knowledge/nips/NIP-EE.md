# NIP-EE — E2EE Messaging using the Messaging Layer Security (MLS) Protocol

Source: https://github.com/nostr-protocol/nips/blob/master/EE.md
Retrieved: 2026-09-23
Status: `final` `unrecommended` `optional`; top-of-file warning: "unrecommended: superseded by the [Marmot Protocol](https://github.com/marmot-protocol/marmot)".
Confidence: HIGH (spec-read)

## Purpose
Standardize MLS (RFC 9420) over Nostr for efficient E2EE direct and group messaging with privacy (metadata protection), confidentiality, forward secrecy, post-compromise security, large-group scalability (linear→log), and multi-device membership. Nostr relays perform the MLS Authentication Service and Delivery Service roles; the MLS implementation (e.g. OpenMLS) handles keys/ratcheting/group state.

## Event kinds
- `443` — KeyPackage event (advertises MLS ciphersuite/extensions + a group signing key; enables async adds).
- `444` — Welcome event (MLS `Welcome` object; NIP-59 gift-wrapped; MUST never be signed).
- `445` — Group event (all in-group traffic: `Proposal`/`Commit`/`Application`; published under a **fresh ephemeral keypair each time**).
- `10051` — KeyPackage relays list (`relay` tags; where the user publishes KeyPackages).

## Tags defined/used
- kind 443: `mls_protocol_version` (req, `1.0`), `ciphersuite` (MLS CipherSuite ID, e.g. `0x0001`), `extensions` (array of MLS extension IDs), `client` (opt: name, handler event id, relay), `relays` (opt; where published, for later deletion), `-` (opt NIP-70 protected).
- kind 444: `e` (req, ID of the KeyPackage event used), `relays` (req).
- kind 445: `h` = nostr group ID (from the group-data extension).

## Content format
- kind 443 `.content` = hex-encoded serialized MLS `KeyPackageBundle`.
- kind 444 `.content` = serialized `MLSMessage` containing the MLS `Welcome`; sealed + gift-wrapped per NIP-59.
- kind 445 `.content` = TLS-style serialized `MLSMessage`, NIP-44-encrypted — but the `conversation_key` is derived from a **Nostr keypair generated from the MLS `exporter_secret`**: the hex exporter_secret (32 bytes, label `nostr`, rotated each epoch) is used as the private (sender) key, its pubkey as receiver key, then standard NIP-44.

## Semantics & rules
- **Groups**: random 32-byte MLS group ID, effectively permanent, MUST never be published to relays. Required MLS extensions: `required_capabilities`, `ratchet_tree`, `nostr_group_data`; `last_resort` highly recommended.
- **Credentials**: MUST be MLS `BasicCredential` with `identity` = the user's 32-byte hex Nostr pubkey; clients MUST block changes to the identity field in proposals. The credential's MLS **signing key MUST differ from the Nostr identity key** and SHOULD be rotated (MUST rotate regularly) for post-compromise security.
- **`nostr_group_data` extension** (required capability): `nostr_group_id` (32-byte, used in `h` tags, CAN change), `name`, `description`, `admin_pubkeys` (MLS has no admin concept — clients MUST check this list before changing group data/membership; all members may still propose/commit their own credential updates), `relays`.
- **KeyPackages**: publish ≥1 to be reachable; multiple with different ciphersuites/extensions allowed. SHOULD use "last resort" KeyPackages to avoid invite races; clients SHOULD delete the KeyPackage on listed relays after successfully processing a group request, MUST NOT delete if the Welcome can't be processed (e.g. signing key lives on another device), and MUST rotate the signing key immediately after joining via a last-resort package.
- **Welcome**: sender of the `Commit` sends the Welcome gift-wrapped (NIP-59); SHOULD wait for relay ack of the commit first. Large groups (>~150): welcomes exceed max event size; light-client welcomes are future work.
- **Group events**: new ephemeral keypair per event (obfuscates participant count/identity). Inner application messages are **unsigned** Nostr events (kind 9 for chat, kind 7 for reactions, etc.) with `pubkey` = member identity key; clients MUST check inner pubkey matches the sender's MLS credential; inner events MUST stay unsigned (unpublishable if leaked) and MUST NOT include `h` or group-identifying tags.
- **Commit race conditions**: committer MUST wait for ≥1 relay ack before applying its own commit. On competing commits for the same epoch: apply lowest `created_at`; tie → lowest event `id`. Clients SHOULD retain prior group state briefly to recover from forks.

## Security & privacy notes
- MLS keys are deleted after each use; clients must not persist secrets (esp. the exporter secret) longer than necessary. FS/PCS guarantees of MLS are preserved.
- **Nostr identity-key compromise does not decrypt past or future MLS messages** — the scheme deliberately never depends on the identity key for message crypto.
- Metadata: the only group metadata on relays is the nostr group ID in `h`; ephemeral pubkeys per event hide who/how many post; gift-wrapped welcomes hide invites (NIP-17-style).
- KeyPackage reuse risk is mitigated by immediate signing-key rotation on join (also improves group FS).
- Device compromise is catastrophic: recommendations include self-destructing messages, removing inactive members, encrypting group state at rest with a secret unrelated to identity key/group state, secure enclaves, regular signing-key rotation.

## Interoperability notes
- Stacks on NIP-44, NIP-59, NIP-70, NIP-17 concepts; inner events reuse NIP-C7 kind 9 etc.
- **Superseded by the Marmot Protocol** (per header) — new implementations should evaluate Marmot (marmot-protocol/marmot) rather than deploying NIP-EE as-is.

## Example
Real spec example (KeyPackage event):
```json
{
  "kind": 443,
  "pubkey": "<main identity pubkey>",
  "content": "<hex serialized KeyPackageBundle>",
  "tags": [
    ["mls_protocol_version", "1.0"],
    ["ciphersuite", "0x0001"],
    ["extensions", "0x0001, 0x0002"],
    ["relays", "<array of relay urls>"],
    ["-"]
  ]
}
```

## Open questions / uncertainties
- Large-group Welcome handling left as "will be updated" — unresolved in this NIP.
- `nostr_group_data` extension references a rust-nostr implementation file rather than an inline wire format — implementations must match that code.
- Marked `final` yet `unrecommended`/superseded — its finality is historical; Marmot diverges.
