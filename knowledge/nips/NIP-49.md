# NIP-49 — Private Key Encryption (`ncryptsec`)

Source: https://github.com/nostr-protocol/nips/blob/master/49.md
Retrieved: 2026-09-23
Status: `draft` `optional` (no unrecommended mark)
Confidence: HIGH (spec-read)

## Purpose
Standard, password-based symmetric encryption of a user's secp256k1 private key, serialized as a bech32 `ncryptsec1…` string, so encrypted keys are portable across clients.

## Event kinds
none defined

## Tags defined/used
none

## Content format (`ncryptsec` construction)
1. **PASSWORD** — read from user; MUST be Unicode-normalized to **NFKC** before use.
2. **LOG_N** — one byte, power of 2 for scrypt rounds; table: LOG_N 16 → 64 MiB / ~100 ms; 18 → 256 MiB; 20 → 1 GiB / ~2 s; 21 → 2 GiB; 22 → 4 GiB.
3. **SALT** — 16 random bytes.
4. **SYMMETRIC_KEY** = `scrypt(password=PASSWORD, salt=SALT, log_n=LOG_N, r=8, p=1)` — 32-byte output. Temporary: zero and discard after use; never stored or reused.
5. **KEY_SECURITY_BYTE / ASSOCIATED_DATA** — one byte: `0x00` = key known to have been handled insecurely; `0x01` = NOT known to have been handled insecurely; `0x02` = client does not track this.
6. **NONCE** — 24 random bytes.
7. **CIPHERTEXT** = XChaCha20-Poly1305(plaintext = PRIVATE_KEY as 32 raw bytes (not hex/bech32), associated_data = KEY_SECURITY_BYTE, nonce = NONCE, key = SYMMETRIC_KEY).
8. **VERSION_NUMBER** = `0x02`.
9. Payload = concat(VERSION_NUMBER, LOG_N, SALT, NONCE, ASSOCIATED_DATA, CIPHERTEXT) — must be **91 bytes** before encoding.
10. `ENCRYPTED_PRIVATE_KEY = bech32_encode('ncryptsec', payload)`. Decryption is the exact reverse.

## Semantics & rules
- Encryption is non-deterministic by design (random salt + nonce).
- Rationale (Discussion section): scrypt chosen as the password KDF — "maximally memory hard" and preferred by consulted cryptographers over argon2; XChaCha20-Poly1305 favored over AES (wide library support, used in TLS/OpenSSH, "less associated with the U.S. government").

## Security & privacy notes
- Passwords make poor keys; scrypt's memory hardness is the brute-force barrier — low LOG_N choices weaken it, so the LOG_N byte is embedded so decryptors honor the encryptor's cost parameter.
- **Do NOT publish ncryptsec to Nostr**: an attacker amassing many encrypted keys improves cracking economics.
- Clients SHOULD zero memory of passwords and private keys before freeing.
- NFKC normalization is security-relevant: without it, visually identical passwords with different codepoints (e.g. U+212B vs U+00C5) produce un-decryptable keys on other platforms. Spec test: `"ÅΩẛ̣"` (U+212B U+2126 U+1E9B U+0323) → NFKC U+00C5 U+03A9 U+1E69.
- The key-security byte is authenticated (associated data) but not secret — it travels in the clear inside the payload.

## Interoperability notes
- Interoperable way to move password-encrypted keys between clients; complements NIP-06 (mnemonics) and nsec (NIP-19).
- Decryption test vector: `ncryptsec1qgg9947rlpvqu76pj5ecreduf9jxhselq2nae2kghhvd5g7dgjtcxfqtd67p9m0w57lspw8gsq6yphnm8623nsl8xn9j4jdzz84zm3frztj3z7s35vpzmqf6ksu8r89qk5z2zxfmu5gv8th8wclt0h4p` with password `nostr`, log_n=16 → privkey hex `3501454135014541350145413501453fefb02227e449e57cf4d3a3ce05378683`.

## Example
Real spec decryption vector (above) — encryption has no deterministic vector because of random salt/nonce.

## Open questions / uncertainties
- No versioning story beyond `0x02` (what 0x00/0x01 were is not documented here).
- Key-security-byte semantics rely on honest client reporting; a compromised or sloppy client can mislabel.
- LOG_N byte allows up to 255 — absurd values could DoS a decryptor (memory exhaustion); spec sets no upper bound.
