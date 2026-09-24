# NIP-12 — Generic Tag Queries

Source: https://github.com/nostr-protocol/nips/blob/master/12.md
Retrieved: 2026-09-23
Status: unlisted/withdrawn — file exists but is a stub: "Moved to [NIP-01](01.md)." Marked `final` `mandatory`. Not listed in the repo README. Git history: PR #703 (2023-08-13) "merge nips 12, 16, 20 and 33 into nip 01".
Confidence: HIGH (spec-read)

## Purpose
Originally defined generic tag queries in filters (the `#e`, `#p`, `#<letter>` filter keys). Content was merged into NIP-01, where filter `#<single-letter>` tag queries now live.

## Event kinds
none defined

## Tags defined/used
Historically defined filter semantics for single-letter tags (`e`, `p`, etc.); current normative text is in NIP-01 ("Filters" section).

## Content format
Stub file contains only the header and the pointer: "Moved to NIP-01".

## Semantics & rules
See NIP-01: filters may include `#<single-letter>` arrays; relays must match events having that tag with any listed value.

## Security & privacy notes
n/a — pointer stub.

## Interoperability notes
Treat NIP-12 references in old documentation/libraries as NIP-01 filter semantics.

## Example
n/a — no content in stub.

## Open questions / uncertainties
None — file intentionally hollowed out; retained so historical links to 12.md resolve.
