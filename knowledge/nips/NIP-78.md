# NIP-78 — Arbitrary custom app data

Source: https://github.com/nostr-protocol/nips/blob/master/78.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay` (README title: "Application-specific data"); not unrecommended
Confidence: HIGH (spec-read)

## Purpose
remoteStorage-like "bring your own database" for apps that **do not want interoperability**: the user points an app at a preferred relay, and the app stores application-specific data there. Explicitly NOT for data meant to be exchanged between apps — interoperable data should get dedicated kinds instead.

## Event kinds
| kind | class | role |
|---|---|---|
| 30078 | addressable | single per-`d`-tag app data record; `d` should reference app name/context or any arbitrary string |
| 78 | regular | for storing/querying **multiple** events of the same type; apps should use a unique tag (even a `d` tag) for grouping |

## Tags defined/used
- `d` — on 30078, app-scoped identifier (arbitrary string). On 78, suggested as a grouping tag (any unique tag works).
- No other tags defined; "content and other tags can be anything or in any format."

## Content format
Completely application-defined. Frequently encrypted in practice (spec doesn't mandate it; NIP-44-encrypted blobs are a common convention for private settings).

## Semantics & rules
- **AUTH (the load-bearing relay rule)**: because this data is private to the user, relays SHOULD require the NIP-42 `AUTH` flow before accepting *or serving* kinds 78 and 30078, and SHOULD serve them **only to the authenticated owner** (client must authenticate with the event author's pubkey).
- Standard addressable semantics apply to 30078: latest per (pubkey, kind, d) wins.
- Use cases listed: personal client/app settings; propagating dynamic parameters to users without app updates; personal private data from non-Nostr apps using relays as a personal database.

## Security & privacy notes
- Privacy rests on (a) relay enforcing owner-only reads via NIP-42 and (b) content-level encryption — neither is a MUST. On an open relay, 30078 content is world-readable; assume plaintext = public.
- Cross-relay portability means the same private blob may sit on multiple relays with inconsistent enforcement.
- Because content format is arbitrary, clients must treat it as untrusted input.

## Interoperability notes
- Anti-interoperability by design — spec warns against using these kinds as a generic interchange format.
- Depends on NIP-42 for the suggested access control; NIP-33 addressable semantics for 30078.
- Relay support: generic kind storage, so any relay storing these kinds + NIP-42 can serve it.

## Example
Constructed example (spec gives none):
```json
{
  "kind": 30078,
  "tags": [["d", "myapp/settings/theme"]],
  "content": "{\"mode\": \"dark\"}"
}
```

## Open questions / uncertainties
- Owner-only serving is SHOULD, not MUST — actual behavior varies per relay; apps cannot rely on it.
- No standard for encrypting 78/30078 payloads (NIP-04/NIP-44 conventions exist in the wild but are unspecified here).
- Kind 78 (regular, non-replaceable) vs 30078 selection guidance is minimal; history accumulation on kind 78 is left to the app.
