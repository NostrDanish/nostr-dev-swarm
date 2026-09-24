# NIP-59 — Gift Wrap

Source: https://github.com/nostr-protocol/nips/blob/master/59.md
Retrieved: 2026-09-23
Status: `optional` `relay`
Confidence: HIGH.

## Three layers
1. **rumor** — any unsigned event (deniable if leaked)
2. **seal** — kind **13**: rumor NIP-44-encrypted to receiver, signed by the REAL author; tags MUST be empty
3. **gift wrap** — kind **1059**: seal NIP-44-encrypted, signed by a random ONE-TIME key, `p`-tagged to recipient

Kind **21059** = ephemeral gift wrap for real-time use (relays MUST NOT store); 1059 for asynchronous delivery (NIP-17).

## Rules
- All encryption is NIP-44.
- Seal/wrap timestamps SHOULD be randomized (in the past); independent random expiration per layer recommended.
- Relays: should require NIP-42 AUTH for gift wraps; SHOULD serve 1059 only to p-tagged recipient; SHOULD delete 1059s whose p-tag matches a NIP-09/NIP-62 deletion author.

## Security notes
- Clients MUST verify seal pubkey == rumor pubkey.
- One-time wrap keys must come from a cryptographic RNG; never reused.
- Wrap hides author and metadata structure from relays, but relay still sees recipient p-tag + timing.
