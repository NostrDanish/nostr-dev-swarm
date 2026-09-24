# Cryptography Knowledge Base

Source: NIP-01/44/49/59/26 files at https://github.com/nostr-protocol/nips + BIP-340
Retrieved: 2026-09-23
Confidence: HIGH (spec-level).

## Core primitives used by Nostr
- **Signatures:** Schnorr over secp256k1 per BIP-340. Event sig = 64-byte Schnorr signature over the 32-byte event id (SHA-256 of the NIP-01 serialization).
- **Event id:** lowercase-hex SHA-256 of UTF-8 JSON `[0, pubkey, created_at, kind, tags, content]` with strict escape list (`\n \" \\ \r \t \b \f` only), no whitespace.
- **Encryption (NIP-44 v2):** secp256k1 ECDH → HKDF-extract (salt "nip44-v2") = conversation key → per-message HKDF-expand (info = random 32-byte nonce, L=76) → ChaCha20 + HMAC-SHA256 (nonce‖ciphertext as AAD) → base64 with version byte 0x02.
- **Padding (NIP-44 v2):** powers-of-two scheme; 2-byte u16 length prefix for plaintext < 65536, else 6-byte extended prefix (2 zero bytes + u32). Min plaintext 1 byte (padded to 32), max 2^32−1. NOTE: spec evolved — older copies document only the 2-byte prefix.
- **Key-at-rest (NIP-49):** `ncryptsec` = scrypt + XChaCha20-Poly1305 encrypted bech32 private key (91-byte payload v0x02; see knowledge/nips/NIP-49.md).
- **Mnemonic (NIP-06):** BIP39/BIP32 derivation — UNRECOMMENDED by README ("prefer a single nsec").
- **Legacy DM (NIP-04):** ECDH + AES-256-CBC base64 — UNRECOMMENDED/deprecated; detectable in NIP-51 content by "iv" field.

## Hard rules
1. Never invent cryptographic primitives or compose custom schemes; use audited constructions.
2. NIP-44 v2 known limitations: no deniability, no forward secrecy, no post-compromise security, no post-quantum security; leaks IP/date/partial size; NOT a drop-in NIP-04 replacement; defines no event kinds.
3. Validate NIP-44 payloads before decryption: version byte, base64 length ≥ 132 chars, decoded ≥ 99 bytes; bound input sizes (RUSTSEC-2026-0227 resource exhaustion precedent).
4. Test against official vectors: https://github.com/paulmillr/nip44 (NIP publishes vector-file sha256).
5. Signing isolation: keys live in a dedicated trusted component (NIP-07 extension, NIP-46 bunker, NIP-55 Android signer, or HSM); AI/application layers handle unsigned intents only.
6. Randomness: cryptographic RNG for nonces/ephemeral keys (NIP-59 one-time wrap keys); never reuse nonces.

## Audits
NIP-44 v2 audited by Cure53 (Dec 2023). Record future audits here with source + date.
