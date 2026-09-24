# NIP-70 — Protected Events

Source: https://github.com/nostr-protocol/nips/blob/master/70.md
Retrieved: 2026-09-23
Status: `draft` `optional` `relay`; not marked unrecommended in README
Confidence: HIGH (spec-read)

## Purpose
The `-` tag marks an event as **protected**: it may only be published to a relay *by its own author*, via NIP-42 authentication. Goal: let authors signal that an event is not intended for unlimited third-party redistribution — for closed-community relays, compartmentalized feeds, or paid-access content — and let cooperative relays refuse to act as redistribution points.

## Event kinds
No new kinds. `["-"]` may be added to **any** event kind.

## Tags defined/used
- `-` — a simple single-item tag: `["-"]`. Presence = protected. No values.

## Content format
Unchanged; protection is orthogonal to content. One extra rule: **reposts (NIP-18 kinds 6/16) of protected events MUST NOT embed the reposted event JSON** in `content`; relays SHOULD summarily reject reposts that embed it anyway.

## Semantics & rules
- **Default relay behavior MUST be to reject any event containing `["-"]`.** (Opt-in support: a relay that doesn't implement NIP-70 is compliant by rejecting.)
- Relays choosing to accept protected events MUST first require the NIP-42 `AUTH` flow, then accept the event **only if the authenticated pubkey == event pubkey**.
- Example flow from spec: client sends protected kind-1 → relay responds `["AUTH", "<challenge>"]` and `["OK", <id>, false, "auth-required: this event may only be published by its author"]` → client sends `["AUTH", {...}]` then re-sends the event → `["OK", <id>, true, ""]`.
- Rationale is explicitly social, not cryptographic: the spec acknowledges it's impossible to truly stop information spreading (a group member can copy-paste content elsewhere); the tag gives relays the means to refuse facilitating "pirates" out of respect for the author's intent.

## Security & privacy notes
- **Not an access-control or confidentiality mechanism.** Reading is unrestricted; anyone who can read the event can quote/republish its content manually. Protection applies only to relay-mediated verbatim republishing.
- Effectiveness depends on relays actually enforcing: a relay ignoring NIP-70 will store and serve the event normally.
- NIP-42 auth links the websocket session identity to the event author — prevents impostors reposting under the author's event id, not screenshots.
- Repost-embedding ban prevents the most trivial leak vector (NIP-18 reposts copying full JSON into `content`).

## Interoperability notes
- Hard dependency on NIP-42 AUTH for accepting relays; rejection uses the standard `auth-required:` OK prefix.
- Heavily reused by other NIPs: NIP-43 mandates `-` on all its relay-access events (28934/28935/28936/8000/8001/13534/33534); NIP-29 ecosystems use it for closed feeds.
- Interacts with NIP-18 repost rules (embedding prohibition).
- strfry README lists NIP-70 as supported. nostr-rs-relay and nostream READMEs do not list it. khatru offers `policies` hooks enabling equivalent custom logic.

## Example
From spec (protected note + auth-gated acceptance):
```yaml
/* client: */
["EVENT", {"id":"cb8f...","pubkey":"79be667e...","kind":1,"tags":[["-"]],
           "content":"hello members of the secret group","sig":"fa16..."}]
/* relay: */
["AUTH", "<challenge>"]
["OK", "cb8f...", false, "auth-required: this event may only be published by its author"]
/* client: */ ["AUTH", {}]  /* then resend EVENT */
/* relay: */ ["OK", "cb8f...", true, ""]
```

## Open questions / uncertainties
- Behavior for protected events arriving via relay-to-relay sync (negentropy etc.) is unspecified — sync could bypass the AUTH requirement unless relays apply the same rules.
- Whether relays should serve protected events to *any* reader or restrict reads is deliberately out of scope.
- No marker for "protected but redistributable with attribution" etc. — single binary semantics.
