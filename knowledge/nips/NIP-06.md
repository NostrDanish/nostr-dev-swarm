# NIP-06 — Basic key derivation from mnemonic seed phrase

Source: https://github.com/nostr-protocol/nips/blob/master/06.md
Retrieved: 2026-09-23
Status: `draft` `unrecommended` `optional`; file carries a top-of-file warning: "unrecommended: prefer a single nsec". README also marks NIP-06 unrecommended.
Confidence: HIGH (spec-read)

## Purpose
Define how to derive Nostr private keys from a BIP39 mnemonic seed phrase, so users can back up/restore identity with seed words and derive multiple accounts from one seed.

## Event kinds
none defined

## Tags defined/used
none

## Content format
- BIP39 (bips.xyz/39) generates mnemonic words and the binary seed.
- BIP32 (bips.xyz/32) derives the path `m/44'/1237'/<account>'/0/0` (coin type `1237` is Nostr's SLIP44 entry).
- A basic client uses `account` = 0 for a single key; incrementing `account` yields practically infinite keys from the 5-level hardened path. Clients may use other derivation paths for their own purposes.

## Semantics & rules
No network semantics — purely an offline key-derivation convention. Interoperability rests on all clients using the same BIP39 wordlist + BIP32 path.

## Security & privacy notes
- The file itself warns the scheme is `unrecommended` and to "prefer a single nsec" — mnemonic backup encourages seed-phrase handling patterns (writing down, cloud backup) that broaden the attack surface relative to a single random nsec; a leaked mnemonic compromises ALL derived accounts, and passphrase/derivation-path mismatches cause silent key loss across clients.
- Derived keys are deterministically tied to the seed: any account key compromise implies the mnemonic (and every sibling account) is at risk if the mnemonic is also exposed.
- Test vectors pin the derivation: mnemonic "leader monkey parrot ring guide accident before fence cannon height naive bean" → privkey `7f7ff03d…ccba9a`, pubkey `17162c92…5cd917`.

## Interoperability notes
- Coin type 1237 registered in SLIP44.
- Widely implemented historically (many older clients offered seed-phrase login), but modern guidance pushes nsec + remote signers (NIP-46) / Android signers (NIP-55) instead.

## Example
Real spec test vector: mnemonic `leader monkey parrot ring guide accident before fence cannon height naive bean` → private key (hex) `7f7ff03d123792d6ac594bfa67bf6d0c0ab55b6b1fdb6249303fe861f1ccba9a`, npub `npub1zutzeysacnf9rru6zqwmxd54mud0k44tst6l70ja5mhv8jjumytsd2x7nu`.

## Open questions / uncertainties
- Spec does not discuss BIP39 passphrases (25th word); clients supporting them diverge silently.
- No guidance on gap limits / account discovery, so multi-account restoration is client-specific.
