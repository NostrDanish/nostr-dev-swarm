# NIP-17 — Private Direct Messages

Source: https://github.com/nostr-protocol/nips/blob/master/17.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay`
Confidence: HIGH.

## Construction
Unsigned rumor (usually kind **14** chat or kind **15** file message) → kind-13 seal (signed by real author) → kind-**1059** gift wrap (random one-time key), wrapped separately to each receiver AND the sender. See protocols/nip-59.md and protocols/nip-44.md.

## Rules
- Chat room identity = set of `pubkey` + `p` tags; changing membership = new room; optional `subject` tag.
- Clients MUST verify seal pubkey == rumor pubkey (anti-impersonation).
- Seal/wrap `created_at` SHOULD be randomized up to 2 days in the past (timing-analysis resistance).
- Kind **10050** lists a user's DM inbox relays; clients MUST publish only to those; relays SHOULD serve 1059 only to the p-tagged recipient (enforced via NIP-42 AUTH).
- Kind-15 file messages: `file-type`, `encryption-algorithm` (aes-gcm), `decryption-key`, `decryption-nonce`, `x`/`ox` SHA-256 tags; file URL in content.

## Privacy limits (engineering facts)
- Metadata (sender/receiver pubkeys via p-tags, timing, relay visibility) still leaks to relays; gift wrap hides content, not existence.
- Inherits NIP-44 limitations: no forward secrecy, no post-compromise security.

## Supersedes
NIP-04 legacy DMs (unrecommended/deprecated).
