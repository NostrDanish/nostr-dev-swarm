# NIP-48 — Bridged events

Source: https://github.com/nostr-protocol/nips/blob/master/48.md
Retrieved: 2026-09-23
Status: `draft` `optional` (no unrecommended mark)
Confidence: HIGH (spec-read)

## Purpose
Let Nostr events bridged from other protocols (ActivityPub, AT Protocol, RSS, plain web) link back to their source object so clients can reconcile duplicated bridged content or display a link to the origin.

## Event kinds
none defined — `proxy` tags may be added to any event kind; presence indicates the event did NOT originate on Nostr.

## Tags defined/used
- `["proxy", <id>, <protocol>]`
  - `<id>`: ID of the source object; format depends on protocol; must be universally unique regardless of protocol.
  - `<protocol>`: protocol name, e.g. `"activitypub"`.

### Supported protocols (extensible)
| Protocol | ID format | Example |
|---|---|---|
| `activitypub` | URL | `https://gleasonator.com/objects/9f524868-c1a0-4ee7-ad51-aaa23d68b526` |
| `atproto` | AT URI | `at://did:plc:zhbjlbmir5dganqhueg7y4i3/app.bsky.feed.post/3jt5hlibeol2i` |
| `rss` | URL with guid fragment | `https://soapbox.pub/rss/feed.xml#https%3A%2F%2Fsoapbox.pub%2Fblog%2Fmostr-fediverse-nostr-bridge` |
| `web` | URL | `https://twitter.com/jack/status/20` |

## Content format
Unchanged — normal event content; only the tag is added.

## Semantics & rules
- Clients may use the tag to deduplicate content bridged through multiple paths and to render "view original" links.
- Adding a `proxy` tag asserts off-protocol origin.

## Security & privacy notes
- The tag is self-asserted: nothing cryptographically proves the event mirrors the claimed source object; a malicious bridge or author could attach arbitrary `proxy` IDs. Trust derives from the bridge's pubkey reputation.
- Bridged content republishes data authored on other networks — consent/removal semantics of the source network do not propagate to Nostr relays.

## Interoperability notes
- References FEP-fffd (Proxy Objects) on the Fediverse side and the Mostr bridge as the canonical ActivityPub↔Nostr example.
- Protocol list explicitly "may be extended in the future".

## Example
Real spec example — kind-1 note with:
```json
["proxy", "https://gleasonator.com/objects/8f6fac53-4f66-4c6e-ac7d-92e5e78c3e79", "activitypub"]
```

## Open questions / uncertainties
- No rule for multiple `proxy` tags on one event (multi-origin mirroring).
- "Universally unique" ID requirement is asserted but not enforceable across protocol namespaces.
