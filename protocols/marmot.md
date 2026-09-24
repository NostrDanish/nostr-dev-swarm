# Marmot Protocol — MLS-based E2EE group messaging over Nostr

Source: https://github.com/marmot-protocol/marmot (adopted spec: README.md, mip-coverage.md, transports/nostr.md) ; https://www.whitenoise.chat/build (reference client docs) ; https://nostrbook.dev/groups (NIP-EE summary) ; https://nips.nostr.com/EE
Retrieved: 2026-09-23
Confidence: HIGH for adopted-spec wire format (read directly from transports/nostr.md); MEDIUM for NIP-EE-era details and maturity assessments (secondhand). Spec churns fast — re-check before implementing.

## What it is
End-to-end encrypted group messaging: Nostr public keys for identity, MLS (RFC 9420) as continuous group key agreement, Nostr event-shaped app payloads inside MLS. Core invariants: identity = Nostr key, content = event-shaped payloads, key agreement = MLS. Transport is agnostic in principle; Nostr relays are the first transport binding (QUIC mentioned). Design goals: redundant delivery (group survives relay failure/block), metadata minimization. Supersedes **NIP-EE** (merged 2025-08-27, now "unrecommended — superseded by Marmot Protocol"). The intermediate MIP-00..06 documents are deprecated; the spec is now organized by surface: `foundation/`, `protocol-core/`, `app-components/`, `transports/`, `features/`.

## Wire format (Nostr transport v1)

| Kind | Role | Key rules |
|---|---|---|
| `30443` | KeyPackage (addressable) | content = base64 MLSMessage (`mls_key_package`); tags `d` (random 32-byte slot id, reused on replacement), `mls_protocol_version:1.0`, `i` (KeyPackageRef hex), id-list tags `mls_ciphersuite`/`mls_extensions`/`mls_proposals`/`app_components` (0x-prefixed 16-bit hex); must advertise app component `0x8009` (account-identity-proof v2) |
| `1059`→`13`→`444` | Welcome | NIP-59 gift wrap → seal → unsigned kind-444 rumor; rumor content = base64 MLSMessage (`mls_welcome`); `e` tag = consumed KeyPackage event id; `relays` tag = group message relays; published to recipient's kind-10050 inbox relays |
| `445` | Group message | exactly one `h` tag = hex nostr_group_id; signed by fresh ephemeral key per event; content = base64(12-byte nonce ‖ ChaCha20-Poly1305 ciphertext of MLS message) under `group_event_key = MLS-Exporter("marmot","group-event",32)` (per-epoch); optional NIP-40 `expiration` ONLY on application messages |
| `10050` | Inbox relays | NIP-17 kind reused unchanged for Welcome delivery |
| `10002` | KeyPackage discovery | NIP-65 write-capable relay set (no dedicated 10051 anymore) |
| `446` | Push notification rumor | optional feature, gift-wrapped to notification server |

Legacy (NIP-EE/MIP era, 2025): kind 443 KeyPackage, 10051 KeyPackage relays list, group-data extension `0xF2EE` (`marmot_group_data`). Adopted spec split 0xF2EE into app components (`marmot.group.profile.v1`, `marmot.transport.nostr.routing.v1` = nostr_group_id + relay list, `marmot.group.blossom.image.v1`, `marmot.group.message-retention.v1`, ...).

## Trust model
- Nostr identity key ≠ MLS signing key: nsec compromise does NOT decrypt group messages; each device is a separate MLS leaf (multi-device).
- Forward secrecy + post-compromise security from MLS ratchet — the core advantage over NIP-17 gift wraps (compromised nsec = all history; O(N) fan-out).
- Sender privacy: 445 envelopes use throwaway signing keys; sender identity established inside MLS after decryption. Relays see only random group id, ephemeral pubkey, timing.
- Receivers MUST verify NIP-01 id+signature before trusting envelope fields; strict tag cardinality (duplicate/missing required tag = malformed); transport evidence (relay timestamps, arrival order, event ids) MUST NOT decide group state; dedup on MLS-message-derived ids, not Nostr event ids.
- Receiver epoch handling: trial-decrypt against retained candidate epochs only; undecryptable events are deferred (`transport_deferred`) and retried on epoch change.

## Known limits (May 2026 assessments)
Experimental; cross-client compat untested. Large groups (~150+) deferred pending MLS "light welcomes". KeyPackage deletion is best-effort relay deletion. Commit ordering timestamp-based. Non-members can spam envelopes that reach trial decryption (client CPU budgets are local policy).

## Implementations
WhiteNoise (reference, whitenoise.chat), OpenChat/Scramble (github.com/DavidGershony/openChat), Nymchat (Marmot default for new groups, NIP-17 fallback). Marmot MDK (Rust core) with FFI.
