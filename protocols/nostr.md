# Nostr Protocol — Overview

Source: https://github.com/nostr-protocol/nips (master, README SHA 1185974a48f42e018c12cb346536b331cd7bfff9)
Retrieved: 2026-09-23
Confidence: HIGH.

## What Nostr is (engineering definition)
"Notes and Other Stuff Transmitted by Relays": a minimal open protocol where identities are secp256k1 keypairs, content is signed JSON events, and transport is dumb relays speaking JSON over WebSockets. No central server, no global state, no consensus — cryptographic authenticity + relay plurality instead.

## Core model
- **Identity** = secp256k1 keypair (npub/nsec via NIP-19). No account registration; no key rotation exists — compromise is terminal.
- **Event** = `{id, pubkey, created_at, kind, tags, content, sig}`; id = SHA-256 of canonical serialization; sig = BIP-340 Schnorr over id. See protocols/nip-01.md.
- **Relays** = store-and-forward servers; store per kind-class policy; serve filters over WS; described by NIP-11 documents.
- **Clients** = sign locally, subscribe with filters, verify everything. Trust is client-side.

## Design consequences
- Censorship resistance comes from relay plurality + portable identity (NIP-65 outbox model), not from any single relay.
- Storage/ephemerality is expressed in kind ranges (regular / replaceable / ephemeral / addressable).
- Spec vs convention vs implementation reality often diverge; the nips README is not exhaustive; check https://github.com/nostr-protocol/registry-of-kinds and implementation behavior.

## Key sub-protocols (see per-NIP files in this directory)
NIP-01 base · NIP-42 relay auth · NIP-44 v2 encryption · NIP-46 remote signing · NIP-50 search · NIP-59 gift wrap · NIP-65 relay lists · NIP-77 negentropy sync · NIP-98 HTTP auth · NIP-B7 Blossom blob storage.

## Engineering stance of this swarm
Nostr is infrastructure: coordination, identity, knowledge, and tooling layer — not just social media plumbing. Verify every protocol claim against current sources before relying on it; Nostr evolves fast.
