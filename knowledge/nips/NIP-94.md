# NIP-94 — File Metadata

Source: https://github.com/nostr-protocol/nips/blob/master/94.md
Retrieved: 2026-09-23
Status: `draft` `optional` (no unrecommended mark)
Confidence: HIGH (spec-read)

## Purpose
Organize and classify shared files as Nostr events so relays can filter/index them and dedicated file-sharing clients can be built. Explicitly NOT expected to be implemented by social (kind 1) or longform (kind 30023) clients.

## Event kinds
- `1063` — file metadata event (regular kind).

## Tags defined/used
- `url` — URI to download the file.
- `m` — MIME type, lowercase.
- `x` — **SHA-256 hex of the file** as served at `url`.
- `ox` — **SHA-256 hex of the ORIGINAL file, before any transformations done by the upload server** (e.g. recompression). Lets clients verify lineage to the uploader's original bytes.
- `size` (opt) — bytes. `dim` (opt) — `<width>x<height>` pixels.
- `magnet` (opt) — magnet URI. `i` (opt) — torrent infohash.
- `blurhash` (opt) — loading placeholder.
- `thumb` (opt) — thumbnail URL (+ sha256), same aspect ratio. `image` (opt) — preview URL (+ sha256), same dimensions.
- `summary` (opt) — text excerpt. `alt` (opt) — accessibility description.
- `fallback` (opt, repeatable) — alternate file sources if `url` fails.
- `service` (opt) — serving service type, e.g. NIP-96.

## Content format
`.content` = free-text description/caption of the file.

## Semantics & rules
- `x` binds the event to the exact bytes currently served; `ox` preserves the hash of the pre-transformation original — together they let clients detect server-side modification and still verify the authentic original. (NIP-92 reuses this vocabulary inline via `imeta`.)
- Suggested use cases: file-indexing relays (e.g. torrent promotion), Pinterest-like portfolios, distributing configs/software updates.

## Security & privacy notes
- Hash tags enable integrity checks after download, but the event author controls the hashes — authenticity rests on the author's signature, not the hash alone.
- Magnet/infohash tags facilitate P2P distribution with the usual legal/exposure caveats; public file catalogs are trivially scrapeable.
- `fallback` URLs are author-supplied alternates that could serve different bytes than `x` commits to.

## Interoperability notes
- Tag schema shared with NIP-92 (`imeta`) and reused by NIP-96 (server responses) and Blossom-style flows.
- Plain `kind:1063` means any relay can index by `#m`, `#x`, etc.

## Example
Real spec template:
```yaml
{
  "kind": 1063,
  "tags": [
    ["url", "<URI of file>"],
    ["m", "<MIME type>"],
    ["x", "<Hash SHA-256>"],
    ["ox", "<Hash SHA-256>"],
    ["size", "<size in bytes>"],
    ["dim", "<width>x<height>"],
    ["magnet", "<magnet URI>"],
    ["i", "<torrent infohash>"],
    ["blurhash", "<value>"],
    ["thumb", "<thumbnail URI>", "<Hash SHA-256>"],
    ["image", "<preview URI>", "<Hash SHA-256>"],
    ["summary", "<excerpt>"],
    ["alt", "<description>"]
  ],
  "content": "<caption>"
}
```

## Open questions / uncertainties
- Which tags are strictly required is not stated in MUST terms (url/m/x are implied core).
- No rule for updating file references — kind 1063 is not addressable, so superseding a file event relies on deletion/new events.
