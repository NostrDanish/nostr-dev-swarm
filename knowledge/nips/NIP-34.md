# NIP-34 — `git` stuff

Source: https://github.com/nostr-protocol/nips/blob/master/34.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README. README lists kind `1622` as "Git Replies (deprecated)" under NIP-34.
Confidence: HIGH (spec-read)

## Purpose
All ways code collaboration using/adjacent to git can be done over Nostr: repository announcements, repository state, patches, pull requests, issues, status tracking, and grasp server lists. Foundation of Nostr-native git workflows (e.g. ngit, gitworkshop, GRASP servers).

## Event kinds
- `30617` — **Repository announcement** (addressable). Author asserts maintainership of the primary project unless a `u` tag (subordinate fork) is included.
- `30618` — **Repository state announcement** (addressable). Optional source of truth for branch/tag refs.
- `1617` — **Patch** (regular). `content` = `git format-patch` output.
- `1618` — **Pull Request** (regular). Points to proposed changes in a git repo.
- `1619` — **PR Update** (regular). Changes the tip of a referenced PR.
- `1621` — **Issue** (regular). Markdown conversational threads (bugs, features, questions).
- `1630`–`1633` — **Status** (regular): 1630 Open, 1631 Applied/Merged (patches) / Resolved (issues), 1632 Closed, 1633 Draft.
- `10317` — **User grasp list** (replaceable list, NIP-65-like). `g` tags = grasp service websocket URLs in preference order.
- (Deprecated per README: `1622` git replies — replies now use NIP-22 comments.)

## Tags defined/used
**30617:** `d` (repo-id, usually kebab-case; the ONLY required tag), `name`, `description`, `web` (browse URL, repeated), `clone` (git clone URL, repeated), `relays` (relays the repo monitors for patches/issues, repeated), `r` with `"euc"` marker (earliest unique commit id), `maintainers` (repeated), `u` (subordinate fork pointer: `"30617:<pubkey>:<identifier>|<git-url-https-preferred>"`, relay hint, author pubkey), `t` hashtags.
**30618:** `d` matching the announcement; `refs/<heads|tags>/<name>` → commit-id (may repeat or appear zero times); `HEAD` → `ref: refs/heads/<branch>`.
**Patch (1617):** `a` (repo address), `r` (euc), `p` (owner/others), `t root` (first patch in series; omitted for later patches), `t root-revision` (first patch of a revision), optional stable-commit-id tags: `commit`, `r <current-commit-id>`, `parent-commit`, `commit-pgp-sig` (empty string if unsigned), `committer` (name, email, timestamp, tz offset minutes).
**PR (1618):** `a`, `r` (euc), `p`, `subject`, `t` labels, `c` (tip commit of PR branch), `clone` (≥1 URL where commit is fetchable), `branch-name` (optional recommended), `e <root-patch-event-id>` (marks PR as revision of a patch to close), `merge-base`.
**PR Update (1619):** `a`, `r`, `p`, NIP-22 `E` (PR event id) + `P` (PR author), `c` (new tip), `clone`, `merge-base`.
**Issue (1621):** `a`, `p`, `subject`, `t` labels.
**Status (1630–1633):** `e <id> "" root` (target root), `e <revision-id> "" reply` (accepted revision), `p` owner/author/revision-author, optional `a`, `r` (euc) for filter efficiency; for 1631: `q` per applied/merged patch, `merge-commit` + `r <merge-commit-id>` when merged, `applied-as-commits` + `r` per commit when applied.

## Content format
- Patch: raw `git format-patch` text; first patch in a series MAY be a cover letter.
- PR/Issue/Status: Markdown text. Announcements/state/grasp lists: empty content, tag-driven.

## Semantics & rules
- **Repo identity across forks**: `r`/`euc` = earliest unique commit id — normally the root commit; for a permanent fork, the first commit after the fork. Lets clients subscribe to "all patches for this project" regardless of where repos are hosted.
- **Patches vs PRs**: patches SHOULD be used if each event is under 60kb, otherwise PRs. Patches/PRs SHOULD go to the repo announcement's `relays` and carry an `a` tag to the repo address.
- Patch series threading: later patches use NIP-10 `e reply` to previous patch; first patch of a revision replies to the original root patch.
- **Status validity**: most recent status (by `created_at`) from either the issue/patch author or a maintainer wins. A patch-revision's status = root patch's status, except `Closed` (1632) if root is 1631 Applied/Merged and the revision isn't tagged in that 1631 event.
- **Nostr clone URL** (works with `git clone` via git-remote-nostr helper): `nostr://<naddr>`; `nostr://<npub|nip05>/<identifier>`; `nostr://<npub|nip05>/<relay-hint>/<identifier>`. Relay-hint and identifier MUST be percent-encoded (RFC 3986 §2.1); `wss://` may be omitted in relay hints. Identifier = the `d` tag of the 30617 event.
- **Grasp**: kind 10317 lists preferred grasp servers (grasp = git remote helper + relay + REST/git server combo referenced via njump naddr link in spec); functionally parallel to NIP-65 relay lists and NIP-B7 blossom lists.

## Security & privacy notes
- Maintainer assertion is self-published; trust flows from the announcement author's key plus `maintainers` tags.
- Optional `commit-pgp-sig` and `committer` tags preserve commit-id stability (proposer's commit id survives application), enabling signed-commit provenance; empty string signals unsigned commit.
- Status events only authoritative from author/maintainer keys — clients must verify authorship.

## Interoperability notes
- NIP-10 (threading), NIP-22 (replies/comments), NIP-34 URLs referenced by NIP-5A `source` tags and NIP-C0 `repo` tags.
- git-remote-nostr helper bridges standard git tooling; `nostr://` URLs compatible with `git clone`.
- GRASP servers (e.g. relay.ngit.dev-style deployments) implement the server side.

## Example
Real spec examples:
```
nostr://npub15qydau2hjma6ngxkl2cyar74wzyjshvl65za5k5rl69264ar2exs5cyejr/relay.ngit.dev/ngit
nostr://danconwaydev.com/ws%3A%2F%2Flocalhost%3A7334/my-local-only-repo
```
Repository state:
```yaml
{
  "kind": 30618,
  "content": "",
  "tags": [
    ["d", "<repo-id>"],
    ["refs/heads/main", "<commit-id>"],
    ["HEAD", "ref: refs/heads/main"]
  ]
}
```

## Open questions / uncertainties
- Spec explicitly lists "inline file comments kind" as a possible later addition (separate kinds for patches vs merged files).
- `u` tag fork semantics and multi-maintainer authority resolution are minimally specified.
- The grasp reference is an njump naddr link rather than a spec document.
