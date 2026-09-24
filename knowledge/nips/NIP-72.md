# NIP-72 — Moderated Communities (Reddit Style)

Source: https://github.com/nostr-protocol/nips/blob/master/72.md
Retrieved: 2026-09-23
Status: `draft` `unrecommended` `optional` — README marks it **unrecommended**: "try NIP-29 instead"; in-file warning banner says the same.
Confidence: HIGH (spec-read)

## Purpose
Public, Reddit-style communities: an addressable community definition with a moderator roster; anyone posts by tagging the community; moderators issue signed **approval** events; clients show approved posts. No relay enforcement — moderation is client-interpreted, like NIP-28.

## Event kinds
| kind | class | role |
|---|---|---|
| 34550 | addressable | community definition (`d` identifier, metadata, moderator `p` tags, relay hints) |
| 1111 (NIP-22) | regular | community posts/comments (current style) |
| 1 | regular | legacy community posts (backwards-compat query only — SHOULD NOT be used for new posts) |
| 4550 | regular | moderator approval of a post |
| 6 / 16 (NIP-18) | regular | cross-posting reposts into communities |

## Tags defined/used
- On 34550: `d`, `name` (SHOULD be displayed over `d` when present), `description`, `image` (with `<W>x<H>` size arg), `p` with `"moderator"` marker + optional relay URL, `relay` tags with markers `author` / `requests` / `approvals` (or none) to indicate where community traffic lives.
- On posts (kind 1111, NIP-22 comment scopes): top-level posts set BOTH uppercase and lowercase scope tags to the community: `A`/`a` = `34550:<author-pk>:<d>`, `P`/`p` = community author, `K`/`k` = `34550`. Nested replies keep uppercase `A`/`P`/`K` scoped to the community, lowercase `e`/`p`/`k` pointing at the parent post/reply.
- On 4550 approvals: one or more community `a` tags (always prefix `34550:` — prefix disambiguates community pointers from replaceable-post pointers), `e` and/or `a` tag of the approved post, `p` of the post author (notifications), `k` with the post's kind.

## Content format
- 4550 SHOULD embed the **full JSON-stringified approved post** in `content`. For `e`-tag approvals of replaceable events this is MUST-in-spirit: relays delete old versions, so without the embedded copy the approved version may be unfindable.
- Cross-posts: `content` of the kind 6/16 repost MUST be the **original event**, not the approval event.

## Semantics & rules
- Anyone may issue approvals; clients MAY pick which to honor but SHOULD at least honor approvals from moderators listed in the 34550.
- Moderators MAY revoke approvals via NIP-09 deletion requests.
- Approving replaceable events, three ways: `e` tag = approve that exact version; `a` tag = blanket-approve future edits; both = display original + updated versions with UI remarks.
- Clients SHOULD treat any non-`34550:*` `a` tag in an approval as the post being approved, for all `34550:*` `a` tags as target communities.
- Moderator-rotation hazard (non-obvious): since clients key approval validity on the *current* moderator list, removing a moderator can vanish their approved posts — recommended mitigations: multiple moderators approve each post; on full rotation, new moderators must re-sign approvals for historical posts or "the community will restart"; owner can periodically re-sign moderators' approvals.

## Security & privacy notes
- Approval legitimacy is social: clients must verify approver ∈ current moderator set; nothing stops fake approvals, so clients ignoring this see spam.
- Rotation hazard above is effectively a history-erasure vector whenever the owner edits the 34550 moderator list.
- All content public; no confidentiality.

## Interoperability notes
- Built on NIP-22 comments (kind 1111, A/a/P/p/K/k scope tags), NIP-18 reposts (cross-posting), NIP-09 (approval revocation).
- NIP-51 kind 10004 ("communities list") lets users bookmark communities.
- Deprecated in favor of NIP-29 relay-based groups. Relay support: NIP-72 needs no relay features (client-only convention).

## Example
Approval (from spec):
```yaml
{
  "kind": 4550,
  "tags": [
    ["a", "34550:<event-author-pubkey>:<community-d-identifier>", "<relay>"],
    ["e", "<post-id>", "<relay>"],
    ["p", "<post-author-pubkey>", "<relay>"],
    ["k", "<post-request-kind>"]
  ],
  "content": "<the full approved event, JSON-encoded>"
}
```

## Open questions / uncertainties
- `relay` tag marker semantics (`author` vs `requests` vs `approvals` vs unmarked) are loosely defined.
- No rule for resolving conflicting 34550 definitions of the same `d` from different pubkeys (community identity = author pubkey + d, but discovery can collide).
- Deprecated status means client support is shrinking; interop risk high.
