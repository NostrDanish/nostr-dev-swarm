# NIP-32 — Labeling

Source: https://github.com/nostr-protocol/nips/blob/master/32.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
Generic labeling of events, pubkeys, relays, URLs, and topics. Use cases: distributed moderation, collection management, license assignment, content classification.

## Event kinds
- `1985` — **Label** (regular event; deliberately NOT addressable/replaceable). Attaches labels to targets.

## Tags defined/used
- `L` — **label namespace** (uppercase). Any string; SHOULD be unambiguous (ISO standard or reverse-domain notation). RECOMMENDED to enable namespace-level search. Special namespace `ugc` = user-generated content. `L` values starting with `#` (e.g. `#t`) mean the label target should be associated with the label's value — i.e. attaching standard nostr tags (`t`, etc.) to targets.
- `l` — **label** (lowercase). Any string. If an `L` tag exists, `l` tags MUST carry a mark matching an `L` value in the same event; if no `L`, a mark SHOULD still be included; absent mark implies `ugc`.
- Targets: one or more of `e`, `p`, `a`, `r`, `t` REQUIRED on kind 1985 (relay hints SHOULD be included with `e`/`p` per NIP-01).
- Self-reporting: `l`/`L` MAY be placed on other event kinds, in which case labels refer to the event itself.

## Content format
Labels should be short, meaningful strings; longer rationale/discussion goes in `content`.

## Semantics & rules
- Vocabulary guidance: explore existing designs first; reverse-domain notation encouraged but namespaces are public/open (use a fitting namespace even if it points to someone else's domain).
- Vocabularies MAY fully qualify labels (`["l", "com.example.vocabulary:my-label"]`); if so, ALL labels SHOULD be qualified (no mixing).
- Heuristic: labels should be reusable across many targets. Unique values ("John Doe", "3.18743") are values, not labels — use another mechanism.
- Bulk re-labeling: request deletion via NIP-09 and republish; addressable events rejected due to `d`-tag standardization complexity.
- Publishers SHOULD limit a labeling event to a single namespace to avoid query ambiguity.

## Security & privacy notes
- Labels are public assertions; anyone can label anything — trust/moderation semantics must be layered by consumers (who labeled matters, not just what).
- No authenticity of the label-target relationship is implied beyond the labeler's signature.

## Interoperability notes
- Self-label examples reuse ISO-3166-2 (place) and ISO-639-1 (language); NIP-68 picture events reuse `L`/`l` ISO-639-1 for text-in-image language.
- `#`-prefixed namespaces bridge to standard tag vocabularies (`#t` topics).
- Appendix lists known ontologies (e.g. CLARIAH social ontology categories).

## Example
Real spec example — moderation suggestion for a chat event:
```json
{
  "kind": 1985,
  "tags": [
    ["L", "nip28.moderation"],
    ["l", "approve", "nip28.moderation"],
    ["e", "<kind40_event_id>", "<relay_url>"]
  ]
}
```
Self-labeling example (kind 1 note, ISO-639-1): `["L", "ISO-639-1"], ["l", "en", "ISO-639-1"]`.

## Open questions / uncertainties
- No standard ranking/trust model for competing labels — left to clients.
- Appendix "known ontologies" is explicitly non-exhaustive.
