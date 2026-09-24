# NIP-5A — Static Websites (nsites)

Source: https://github.com/nostr-protocol/nips/blob/master/5A.md
Retrieved: 2026-09-23
Status: `draft` `optional`; README lists it normally (not unrecommended). README kind registry marks kind `34128` as "Legacy nsite manifest [5A] (deprecated)".
Confidence: HIGH (spec-read)

## Purpose
Host static websites from Blossom blobs, with site manifests published as Nostr events. A host HTTP server resolves a pubkey/site identifier to a manifest, maps URL paths to sha256 blob hashes, and fetches the files from Blossom servers.

## Event kinds
- `15128` — **Root site** manifest. Replaceable (single per pubkey; MUST NOT include a `d` tag).
- `35128` — **Named site** manifest. Addressable; MUST include a `d` tag site identifier ("subdomain"-like smaller sites under a pubkey).
- `5128` — **Manifest snapshot**. Regular event; immutable point-in-time capture of a root or named site; version timestamp = `created_at`; addressable by event id.
- (Deprecated per README: `34128` legacy nsite manifest.)

## Tags defined/used
| Tag | Role |
|---|---|
| `path` | REQUIRED, one or more. Format `["path", "/absolute/path", "sha256hash"]` mapping absolute paths to blob sha256 |
| `x` | Recommended. `["x", "<sha256-hex>", "aggregate"]` — aggregate hash of the manifest for indexable versioning. Exactly one, mandatory, in kind 5128 |
| `d` | Site identifier, named sites only. For canonical URLs MUST match `^[a-z0-9-]{1,13}$`, not end with `-` (1–13 chars because DNS label = 63 chars and pubkeyB36 consumes 50) |
| `a` | For copied sites: immediate parent nsite (exactly one, required on copies). Also used by snapshots to reference the snapshotted site |
| `A` | For copied sites: origin nsite of the copy lineage (exactly one, required on copies; copied unchanged across derived copies). Snapshots copy `A` unchanged or omit if source lacks it |
| `server` | Blossom server hints for blob retrieval |
| `title`, `description` | Human-readable site info |
| `source` | Source repo/archive URL; MAY be a `nostr://` git URL per NIP-34 or absolute `https://` git URL; archives MUST be `https://` |
| `app` | `["app", "<kind>:<pubkey>:<d-tag>", "<relay>"]` referencing upstream app descriptor events (e.g. NIP-89 handlers); aggregate-hash computation MUST ignore `app` tags |

## Content format
`content` is empty in all examples; manifest data lives entirely in tags.

## Semantics & rules
- **Aggregate hash**: computed ONLY from `path` tags; order-independent; ignores all other tags and event fields. Algorithm: for each path tag emit line `"<sha256hash> <absolute-path>\n"`, sort lines lexicographically ascending, concatenate as UTF-8, SHA-256, lowercase hex. Two manifests are equivalent iff same aggregate hash.
- **Copying nsites**: pinning another author's site under your namespace. Copied sites SHOULD copy all applicable tags; MAY change kind/identifier (root↔named, different `d`). `a`/`A` tags are the stable lineage references. Non-copied sites SHOULD NOT include `a`/`A`.
- **Snapshots** (kind 5128): MUST copy source's `path` tags, exactly one `x` tag exactly matching the source aggregate, exactly one `a` tag referencing the source site. Other tags optional.
- **Host server canonical URL formats** (single DNS label to avoid wildcard-cert limits):
  - Root site: `<npub>.nsite-host.com`
  - Snapshot: `v<snapshotIdB36>.nsite-host.com` (label matches `^v[0-9a-z]{50}$`)
  - Named site: `<pubkeyB36><dTag>.nsite-host.com` (label matches `^[0-9a-z]{50}[a-z0-9-]{1,13}$`, no trailing `-`; pubkeyB36 = raw 32-byte pubkey in lowercase base36, exactly 50 chars; dTag appended with NO separator)
  - Parse order: valid npub → root site; `^v...$` → snapshot; else named-site pattern; else 404/not found.
- **Path resolution**: look up requested path in `path` tags; if path has no filename, fall back to `index.html` (`/` → `/index.html`, `/blog/` → `/blog/index.html`); not found → `/404.html` fallback. SHOULD verify served blob sha256 matches tag; mismatch → treat as not found.
- **Blob retrieval**: prefer manifest `server` tags; if the pubkey has a kind `10063` (BUD-03 user server list), host MUST try those servers via BUD-01 `GET /sha256`; if no 10063 and no `server` tags → MUST return 404. MUST forward `Content-Type`/`Content-Length` from Blossom; MAY infer `Content-Type` from file extension.

## Security & privacy notes
- Content integrity via sha256 pinning: host SHOULD verify blob hash, so corrupted/wrong blobs are not served.
- Address formats expose pubkey openly (by design); npub-based root domains leak identity of site author.
- Copies preserve lineage publicly (`a`/`A`), so provenance is visible.

## Interoperability notes
- Built on Blossom (BUD-01 retrieval, BUD-03 server lists) and NIP-34 (`nostr://` git URLs for `source`).
- `app` tags interoperate with NIP-89 app handlers and other descriptor kinds (e.g. 32267 Software Application).
- Example one-liner for aggregate hash uses `nak` + `jq` + `sha256sum`.

## Example
Real spec example (root site manifest, abridged):
```json
{
  "kind": 15128,
  "pubkey": "266815e0c9210dfa324c6cba3573b14bee49da4209a9456f9484e5106cd408a5",
  "content": "",
  "tags": [
    ["path", "/index.html", "186ea5fd14e88fd1ac49351759e7ab906fa94892002b60bf7f5a428f28ca1c99"],
    ["path", "/about.html", "a1b2c3d4..."],
    ["x", "<site-aggregate-sha256>", "aggregate"],
    ["server", "https://blossom.example.com"],
    ["title", "My Nostr Site"],
    ["source", "https://github.com/example/my-nostr-site"]
  ]
}
```
Spec also provides named-site, copied-site, derived-copy, snapshot, and snapshot-of-copy examples.

## Open questions / uncertainties
- Non-canonical (longer/invalid) `d` tags are permitted for named sites but break canonical host URLs — behavior of such sites on canonical hosts is out of scope.
- Multi-relay manifest discovery (which relays a host should query) is not specified beyond Blossom hints.
