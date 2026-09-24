# NIP-A0 — Voice Messages

Source: https://github.com/nostr-protocol/nips/blob/master/A0.md
Retrieved: 2026-09-23
Status: `**Status:** Draft` (header bold marker rather than backtick labels); README lists it normally (not unrecommended).
Confidence: HIGH (spec-read)

## Purpose
Short voice messages, typically up to 60 seconds, as dedicated Nostr events with optional waveform preview metadata.

## Event kinds
- `1222` — **root voice message** (regular).
- `1244` — **voice message reply** (regular); MUST follow NIP-22 comment structure.

## Tags defined/used
- Optional per other NIPs (`t` hashtags, `g` geohash, ...); kind 1244 uses NIP-22 thread tags.
- Optional `imeta` (NIP-92) for visual preview without downloading the audio:
  - `waveform` — space-separated amplitude integers, <100 values.
  - `duration` — audio length in seconds.
  - `url` — mirrors the content URL.

## Content format
`content` MUST be a direct URL to an audio file. Audio SHOULD be `audio/mp4` (.m4a, AAC or Opus) for broad compatibility/efficiency; clients MAY support `audio/ogg`, `audio/webm`, `audio/mpeg`. Duration SHOULD be ≤60 s; publishers SHOULD enforce or warn.

## Semantics & rules
- Root/reply split mirrors kind-1/kind-1111: 1222 standalone, 1244 threaded replies per NIP-22.
- Waveform imeta enables rendering a visual preview inline before download.

## Security & privacy notes
- Audio hosted externally (examples use Blossom, e.g. blossom.primal.net); URL-only content means no in-event hash pinning is mandated (imeta `x` not used in spec example).
- Voice is biometric-identifying data; public voice notes are strongly identifying.

## Interoperability notes
- NIP-22 (replies), NIP-92 (imeta), Blossom hosting in practice.

## Example
Real spec example (only example in the spec; file ends here):
```json
{
  "kind": 1222,
  "content": "https://blossom.primal.net/5fe7df0e46ee6b14b5a8b8b92939e84e3ca5e3950eb630299742325d5ed9891b.mp4",
  "tags": [
    ["imeta",
      "url https://blossom.primal.net/5fe7df0e46ee6b14b5a8b8b92939e84e3ca5e3950eb630299742325d5ed9891b.mp4",
      "waveform 0 7 35 8 100 100 49 8 4 16 8 ...",
      "duration 8"]
  ]
}
```

## Open questions / uncertainties
- The spec file ends abruptly at the root-message example (no closing code fence, no kind-1244 reply example) — likely an incomplete edit upstream.
- Typo: duration limit paragraph for 1244 says "Clients publishing `kind: 1222` events" (should probably say 1244).
- No hash/integrity tag required for the audio file.
