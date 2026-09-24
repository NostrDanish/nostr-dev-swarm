# NIP-BE — Nostr BLE Communications Protocol

Source: https://github.com/nostr-protocol/nips/blob/master/BE.md
Retrieved: 2026-09-23
Status: `draft` `unrecommended` `optional`; top-of-file warning: "unrecommended: only implemented once and unclear whether it works, requires review".
Confidence: HIGH (spec-read)

## Purpose
Let Nostr apps communicate and synchronize over Bluetooth Low Energy, emulating the NIP-01 WebSocket client–relay structure over BLE's client–server (GATT) pattern, including offline mesh-style event sync via NIP-77 negentropy.

## Event kinds
none defined — transport-level spec; messages are standard NIP-01 messages (`EVENT`, `EOSE`, NEG-* from NIP-77).

## Tags defined/used
none

## Content format
- **Advertisement**: Service UUID `0000180f-0000-1000-8000-00805f9b34fb`, data = device UUID (ByteArray).
- **GATT service** = Nordic UART Service with Write characteristic `87654321-0000-1000-8000-00805f9b34fb` (Write) and Read characteristic `12345678-0000-1000-8000-00805f9b34fb` (Notify, Read).
- **Role assignment**: the device with the highest device UUID becomes GATT Server ("Relay"), the other GATT Client. Fixed-role devices advertise `FFFF…FF` (server) or `0000…00` (client).
- **Framing**: each NIP-01 message is DEFLATE-compressed, then split into batches `[batch index (first 2 bytes)][batch n][is-last flag (last byte)]` to fit BLE MTU (20–23 bytes BLE 4.2; 256 bytes BLE >4.2). Only 1 message in flight at a time; MTU negotiable; **max message size 64KB**, larger rejected.
- **Workflows**: client→relay via writes; relay→client via Notify on the read characteristic, then client reads. Half-duplex sync: client sends `NEG-OPEN`, then alternating `write-success`/`read-message` rounds exchanging `EVENT`s until both sides send `EOSE`; event spread to connected peers via write (to server peer) or empty-notification + read-message (to client peer).

## Semantics & rules
- Devices must track which events have been sent to each connected peer; intermittent links (gaps of hours/days) are expected, hence NIP-77 set-reconciliation rather than live subscriptions.
- Sync pauses once both ends report no missing events.

## Security & privacy notes
- Spec defines **no pairing/encryption requirement** at the BLE layer — events rely on Nostr signatures for authenticity, but metadata (who syncs with whom, event flow) is visible to BLE observers; advertisement of a stable device UUID enables physical tracking.
- 64KB cap + one-message-at-a-time is a DoS/framing guard, but the chunk-reassembly buffer is a memory-pressure surface.
- BLE MITM could drop/reorder batches; DEFLATE on attacker-influenced data is a decompression-bomb consideration (bounded by 64KB).

## Interoperability notes
- Builds directly on NIP-01 message structure and NIP-77 (`NEG-OPEN`/`NEG-MSG`) for sync.
- Header warning notes it was implemented only once and its correctness is unverified — treat as experimental; real deployments need independent review.

## Example
Real spec example: Kotlin `splitInChunks`/`joinChunks` functions implementing DEFLATE compression, 500-byte chunking with 2-byte index prefix and trailing last-batch flag, and reassembly by sorting on `chunk[0]`.

## Open questions / uncertainties
- Role election by "highest UUID" has no tie/change handling mid-session.
- The reference Kotlin chunker uses one byte for the index (`chunkIndex.toByte()`) despite the spec's 2-byte header — spec/code mismatch.
- No version negotiation; BLE 4.2 vs >4.2 MTU handling left to "negotiated in advance".
