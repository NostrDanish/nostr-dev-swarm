# NIP-71 — Video Events

Source: https://github.com/nostr-protocol/nips/blob/master/71.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
Dedicated video posts of externally hosted content, meant to surface in video-specific clients (Netflix/YouTube/TikTok-like) rather than microblogging clients, with all media metadata embedded.

## Event kinds
- `21` — **normal video** (regular) — longer, mostly horizontal/landscape.
- `22` — **short video** (regular) — short-form, mostly vertical/portrait ("stories/reels/shorts").
- `34235` — **addressable normal video** (addressable; `d` tag required).
- `34236` — **addressable short video** (addressable; `d` tag required).
The normal/short split is stylistic, not size-based: "nothing except cavaliership and common sense prevents a short video from being long, or a normal video from being vertical."

## Tags defined/used
- `imeta` (NIP-92, primary source of video info; one per **variant**). This NIP adds imeta properties beyond NIP-92/94:
  - `duration` (recommended) seconds, floating point.
  - `bitrate` (recommended) average bits/sec.
  - `waveform` (optional, audio only) space-separated amplitude integers, <100 values.
  - Inherited/used: `dim` (distinguishes variants), `m` (MIME; distinguishes variants, e.g. `video/mp4` vs `application/x-mpegURL` HLS), `url`, `x` (sha256), `image` (preview image at same resolution; repeated = fallbacks), `fallback` (mirror URLs, weighted equally with `url` — clients SHOULD use any), `service nip96` (lookup file by hash via author's NIP-96 server list), `l <lang> ISO-639-1 ov` on audio imeta (`ov` flags the ORIGINAL-language track).
- Required: `title`; for 34235/34236 also `d` (unique user-chosen identifier).
- `published_at` — first-publish unix timestamp (string).
- `text-track` (repeated) — link to WebVTT, type (captions/subtitles/chapters/metadata), optional language. In examples, holds an "encoded kind 6000 event" + relay urls.
- `content-warning`, `alt`, `segment` (repeated: start `HH:MM:SS.sss`, end, chapter title, thumbnail URL), `t`, `p` (participants), `r` (reference links).
- `origin` (imported content): `["origin", "<platform>", "<external-id>", "<original-url>", "<optional-metadata>"]` for platform-migration tracking.

## Content format
`.content` = summary/description of the video.

## Semantics & rules
- **Variants**: each `imeta` = one rendition (resolution/container/audio track). Clients should detect separate audio tracks and prefer them over in-video audio to allow smooth resolution switching without interrupting audio.
- Addressable kinds enable metadata corrections, legacy-platform ID preservation, and URL migration without republishing.
- Referencing: `["a", "34235:<pubkey>:<d>", "<relay>"]` / `34236` for shorts.

## Security & privacy notes
- `x` sha256 lets clients verify downloads; `service nip96` enables hash-based retrieval.
- External hosting: use `fallback` mirrors for resilience.

## Interoperability notes
- NIP-92/94 (imeta), NIP-96 (file servers; note README marks NIP-96 unrecommended in favor of Blossom), NIP-68 kind 20 (mixed picture/short-video feeds), kind 6000 events for text tracks.

## Example
Real spec imeta variant set (abridged):
```json
["imeta",
  "dim 1920x1080",
  "url https://myvideo.com/1080/12345.mp4",
  "x 3093509d1e0bc604ff60cb9286f4cd7c781553bc8991937befaacfdc28ec5cdc",
  "m video/mp4",
  "image https://myvideo.com/1080/12345.jpg",
  "fallback https://myotherserver.com/1080/12345.mp4",
  "service nip96",
  "bitrate 3000000",
  "duration 29.223"]
["imeta", "url https://myaudio.com/audio/en/12345.mp3", "m audio/mp3", "l en ISO-639-1 ov", "waveform 0 7 35 ...", "bitrate 320000", "duration 29.24"]
```

## Open questions / uncertainties
- `text-track` format differs between prose (WebVTT link + type + lang) and example (encoded kind 6000 event) — underspecified.
- `duration` also appears as a top-level tag in the addressable example, though defined as an imeta property — minor inconsistency.
- NIP-96 reliance sits awkwardly with README's "NIP-96 unrecommended, replaced by Blossom" mark.
