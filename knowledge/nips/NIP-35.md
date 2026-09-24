# NIP-35 — Torrents

Source: https://github.com/nostr-protocol/nips/blob/master/35.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
A simple torrent index on Nostr: enough metadata to search content and construct a magnet link. No `.torrent` files are stored on Nostr.

## Event kinds
- `2003` — **Torrent** (regular).
- `2004` — **Torrent comment** (regular); works exactly like kind 1, follows NIP-10 tagging.

## Tags defined/used
- `x` — V1 BitTorrent Info Hash, as in magnet link `magnet:?xt=urn:btih:HASH` (BEP 53).
- `file` — `["file", "<full-path>", "<size-bytes>"]`, repeated; path includes torrent-internal prefix (e.g. `info/example.txt`).
- `tracker` — optional tracker URL (udp/http), repeated.
- `title` — torrent title.
- `t` — general category tags (`movie`, `tv`, `HD`, `UHD`, ...) SHOULD be included for searchability.
- `i` tag prefixes (structured external references):
  - `tcat:` — comma-separated text category path (e.g. `tcat:video,movie,4k`); SHOULD best-effort match newznab categories.
  - `newznab:` — category ID from the newznab spec (Prowlarr/NzbDrone standard categories).
  - `tmdb:`, `ttvdb:`, `imdb:`, `mal:`, `anilist:` — external DB ids.
  - Two-level prefixes where the DB supports multiple media types: `tmdb:movie:693134`, `ttvdb:movie:290272`, `mal:anime:9253`, `mal:manga:17517`.

## Content format
`content` = long pre-formatted description of the torrent.

## Semantics & rules
- Magnet link construction: `magnet:?xt=urn:btih:<x-tag>` plus trackers.
- URL mapping from `i` prefixes to site URLs is only a guide; general URL mapping is explicitly out of scope.

## Security & privacy notes
- No integrity/authenticity of the torrent contents beyond the info hash itself; indexer trust is out of scope.
- Publicly indexing torrents may carry legal exposure for relays/clients (not addressed by spec).

## Interoperability notes
- Bridges to BitTorrent ecosystem (BEP 53 magnet links) and *arr stack category systems (newznab/tcat).
- `i` tags predate/parallel NIP-73 external content IDs.
- Implementations listed: dtan.xyz, nostrudel.ninja.

## Example
Real spec example (abridged):
```json
{
  "kind": 2003,
  "content": "<long-description-pre-formatted>",
  "tags": [
    ["title", "<torrent-title>"],
    ["x", "<bittorrent-info-hash>"],
    ["file", "<file-name>", "<file-size-in-bytes>"],
    ["tracker", "udp://mytacker.com:1337"],
    ["i", "tcat:video,movie,4k"],
    ["i", "newznab:2045"],
    ["i", "imdb:tt15239678"],
    ["i", "tmdb:movie:693134"],
    ["t", "movie"], ["t", "4k"]
  ]
}
```

## Open questions / uncertainties
- V2 info hashes (BEP 52) not addressed (`x` is defined as V1 btih only).
- No moderation/takedown mechanism defined.
