# NIP-07 — window.nostr & Web-Client Key Safety Standard

Source: https://github.com/nostr-protocol/nips/blob/master/07.md (interface); security standard: swarm-authored (ADR-0004)
Retrieved: 2026-09-23
Status: NIP-07 not formally marked. The security rules below are SWARM POLICY, not spec — do not cite them as protocol.
Confidence: HIGH for the interface; policy sections = swarm standard v1.

## Interface (spec facts)
Browser extensions expose `window.nostr` with `getPublicKey()`, `signEvent(event)`, and optionally `nip04`/`nip44` encrypt/decrypt methods. The web app never sees the private key.

## The core danger (engineering fact)
NIP-07 has NO permission model by design: any script executing in the page can call `sign_event`/`nip04_decrypt` blind. XSS = key misuse without key theft. Content rendering of untrusted events is therefore a key-security surface.

## Swarm web-client key-safety standard (mandatory for swarm-built web clients)
1. NEVER accept or handle raw `nsec` in a web app. Offer NIP-07, NIP-46 bunker, or ncryptsec (NIP-49) import into a dedicated signer only.
2. CSP baseline: strict Content-Security-Policy (nonces/hashes, no `unsafe-inline` scripts), `object-src 'none'`, `base-uri 'none'`.
3. Event content is hostile: sanitize/escape ALL rendered content; no `dangerouslySetInnerHTML`-class rendering of event content, URLs, or media metadata without sanitization.
4. Signer UX: the signer must display kind + content summary before signing; per-origin permission memory with revocation UI.
5. Decrypt methods (`nip04_decrypt`/`nip44_decrypt`) are decryption-oracle capabilities — request sparingly, scope in the signer, never auto-approve.
6. Subresource integrity for third-party assets; minimize third-party scripts (each is a signing-capability holder).
7. Dependency discipline: lockfiles + SBOM (see knowledge/security/SUPPLY-CHAIN.md) — a compromised npm package inherits window.nostr access.
