# NIP-44 — Encrypted Payloads (Versioned)

Source: https://github.com/nostr-protocol/nips/blob/master/44.md
Retrieved: 2026-09-23
Status: `optional`
Confidence: HIGH.

## v2 construction
1. secp256k1 ECDH shared secret between sender and receiver keys
2. HKDF-extract with salt `nip44-v2` → conversation key
3. Per message: random 32-byte nonce → HKDF-expand (info = nonce, L=76) → ChaCha20 key + HMAC key
4. ChaCha20 encrypt padded plaintext; HMAC-SHA256 over nonce‖ciphertext (AAD)
5. Payload = concat(version=0x02, nonce, ciphertext, mac), base64

## Padding
Powers-of-two scheme. Length prefix: 2-byte u16 for plaintext < 65536 bytes; 6-byte extended (2 zero bytes + u32) for larger. Min plaintext 1 byte (padded to 32); max 2^32−1. ⚠ Spec evolved: older copies document only the 2-byte prefix — check which revision an implementation targets.

## Validation requirements
Version byte must be 0x02 (0x00 reserved, 0x01 deprecated/undefined, leading `#` = unknown future version); base64 length ≥ 132 chars; decoded ≥ 99 bytes. Bound input sizes before decryption (RUSTSEC-2026-0227 resource-exhaustion precedent).

## Explicit limitations (from the spec)
No deniability. No forward secrecy. No post-compromise security. No post-quantum security. Leaks IP/date/partial size. No attachments. NOT a drop-in NIP-04 replacement. Defines no event kinds by itself.

## Usage
- NIP-17 DMs and NIP-59 gift wrap build on NIP-44.
- NIP-51 private list items: JSON-stringified tag array NIP-44-encrypted to author's own key in `.content`.
- NIP-46 uses NIP-44 for kind-24133 transport.

## Test vectors & audit
Vectors: https://github.com/paulmillr/nip44 (NIP publishes the vector file's sha256). v2 audited by Cure53 (Dec 2023).
