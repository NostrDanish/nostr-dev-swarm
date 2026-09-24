# NIP-73 — External Content IDs

Source: https://github.com/nostr-protocol/nips/blob/master/73.md
Retrieved: 2026-09-23
Status: `draft` `optional` (no unrecommended mark)
Confidence: HIGH (spec-read)

## Purpose
Standardize referencing established global external identifiers (ISBNs, podcast GUIDs, ISANs, DOIs, URLs, geohashes, ISO 3166 codes, blockchain txs/addresses, hashtags) in events so clients can query all events associated with a given external ID.

## Event kinds
none defined — tags usable on any kind.

## Tags defined/used
- `i` tag carries the external ID value; `k` tag carries the ID *kind* so clients can filter by type.

| Type | `i` tag value | `k` tag |
|---|---|---|
| URLs | `<URL, normalized, no fragment>` | `web` |
| Books | `isbn:<id, without hyphens>` | `isbn` |
| Geohashes | `geo:<geohash, lowercase>` | `geo` |
| Countries | `iso3166:<code, uppercase>` | `iso3166` |
| Movies | `isan:<id, without version part>` | `isan` |
| Papers | `doi:<id, lowercase>` | `doi` |
| Hashtags | `#<topic, lowercase>` | `#` |
| Podcast Feeds | `podcast:guid:<guid>` | `podcast:guid` |
| Podcast Episodes | `podcast:item:guid:<guid>` | `podcast:item:guid` |
| Podcast Publishers | `podcast:publisher:guid:<guid>` | `podcast:publisher:guid` |
| Blockchain Tx | `<blockchain>:[<chainId>:]tx:<txid, hex, lowercase>` | `<blockchain>:tx` |
| Blockchain Address | `<blockchain>:[<chainId>:]address:<address>` | `<blockchain>:address` |

Optional URL hint as third element of the `i` tag: `["i", "isan:0000-0000-401A-0000-7", "https://www.imdb.com/title/tt0120737"]`.

## Content format
Unchanged; references live purely in tags.

## Semantics & rules — normalization requirements
- URLs: normalized, no fragment.
- ISBN: **without hyphens** (search APIs return them hyphenless; adding hyphens back needs a library).
- Geohash: MUST be lowercase.
- ISO 3166: MUST be uppercase; alpha-2 countries (`iso3166:VE`) or subdivisions (`iso3166:US-CA`).
- ISAN: SHOULD drop the version part (edits not relevant).
- DOI: lowercase.
- Blockchain: `<blockchain>` any L1 (`bitcoin`, `ethereum`, `solana`, …); optional numeric `<chainId>` for EVM etc. Bitcoin: `bitcoin:tx:<hex lowercase>` / `bitcoin:address:<bech32 lowercase | base58 case-sensitive>`; Ethereum: `ethereum:1:address:0x…` / `ethereum:100:tx:0x…`.

## Security & privacy notes
- Referencing geohashes/addresses in public events can leak user location or financial interests; normalization makes correlation by indexers trivial.
- URL hints are author-supplied and could point to phishing lookalikes of the referenced object.

## Interoperability notes
- `k` tag enables single-tag filters (`#k`) for "all events about books" etc.; pairs naturally with NIP-32 labeling-style `i` usage elsewhere.
- Podcast GUIDs align with the Podcasting 2.0 namespace.

## Example
Real spec example:
```yaml
[
  ["i", "bitcoin:tx:a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d"],
  ["k", "bitcoin:tx"]
]
```

## Open questions / uncertainties
- "URL, normalized" is not algorithmically defined (trailing slash, default ports, case of host vs path are unspecified).
- No registry process for adding new ID types beyond the table.
