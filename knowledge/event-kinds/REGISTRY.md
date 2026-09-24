# Event Kind Registry

Source: https://github.com/nostr-protocol/nips/blob/master/README.md (Event Kinds table) + 01.md (ranges)
Retrieved: 2026-09-23
Confidence: HIGH for ranges; MEDIUM for external-registry entries.

## Kind ranges (NIP-01)

| Range | Class | Semantics |
|---|---|---|
| 1000-9999, 4-44, 1, 2 | Regular | Relays expected to store all |
| 10000-19999, 0, 3 | Replaceable | Latest per (pubkey, kind) MUST be kept |
| 20000-29999 | Ephemeral | Relays not expected to store |
| 30000-39999 | Addressable | Latest per (kind, pubkey, d-tag) MUST be kept |

Notes: kind is 0–65535; equal-timestamp replaceable conflict → lowest id wins; NIP-90 reserves 5000-5999 (requests), 6000-6999 (results), 7000 (feedback).

## Named kinds

| 0 | User Metadata | NIP-01 |
| 1 | Short Text Note | NIP-10 |
| 3 | Follows | NIP-02 |
| 4 | Encrypted DM (legacy) | NIP-04 (unrecommended) |
| 5 | Event Deletion Request | NIP-09 |
| 6 | Repost | NIP-18 |
| 7 | Reaction | NIP-25 |
| 8 | Badge Award | NIP-58 |
| 9 | Chat Message | NIP-C7 |
| 11 | Thread | NIP-7D |
| 13 | Seal | NIP-59 |
| 14 | Direct Message | NIP-17 |
| 15 | File Message | NIP-17 |
| 16 | Generic Repost | NIP-18 |
| 17 | Reaction to a website | NIP-25 |
| 20 | Picture | NIP-68 |
| 21 | Video Event | NIP-71 |
| 22 | Short-form Portrait Video | NIP-71 |
| 24 | Public Message | NIP-A4 |
| 30-33 | reference kinds (internal/external web/hardcopy/prompt) | NKBIP-03 (external) |
| 40 | Channel Creation | NIP-28 (unrecommended) |
| 41 | Channel Metadata | NIP-28 |
| 42 | Channel Message | NIP-28 |
| 43 | Channel Hide Message | NIP-28 |
| 44 | Channel Mute User | NIP-28 |
| 54 | Podcast Episode | NIP-F4 |
| 62 | Request to Vanish | NIP-62 |
| 64 | Chess (PGN) | NIP-64 |
| 78 | Application-specific Data | NIP-78 |
| 443 | KeyPackage | Marmot (external) |
| 444 | Welcome Message | Marmot (external) |
| 445 | Group Event | Marmot (external) |
| 818 | Merge Requests | NIP-54 |
| 1018 | Poll Response | NIP-88 |
| 1021 | Bid | NIP-15 (unrecommended) |
| 1022 | Bid confirmation | NIP-15 |
| 1040 | OpenTimestamps | NIP-03 (unrecommended) |
| 1059 | Gift Wrap | NIP-59 |
| 1063 | File Metadata | NIP-94 |
| 1068 | Poll | NIP-88 |
| 1111 | Comment | NIP-22 |
| 1222 | Voice Message | NIP-A0 |
| 1234 | Draft Checkpoint | NIP-37 |
| 1244 | Voice Message Comment | NIP-A0 |
| 1311 | Live Chat Message | NIP-53 |
| 1337 | Code Snippet | NIP-C0 |
| 1617 | Patches | NIP-34 |
| 1618 | Pull Requests | NIP-34 |
| 1619 | Pull Request Updates | NIP-34 |
| 1621 | Issues | NIP-34 |
| 1622 | Git Replies (deprecated) | NIP-34 |
| 1630-1633 | Status | NIP-34 |
| 1971 | Problem Tracker | nostrocket (external) |
| 1984 | Reporting | NIP-56 |
| 1985 | Label | NIP-32 |
| 1987 | AI Embeddings / vector lists | NKBIP-02 (external) |
| 2003 | Torrent | NIP-35 |
| 2004 | Torrent Comment | NIP-35 |
| 2022 | Coinjoin Pool | joinstr (external) |
| 4550 | Community Post Approval | NIP-72 (unrecommended) |
| 5128 | nsite manifest snapshot | NIP-5A |
| 7374 | Reserved Cashu Wallet Tokens | NIP-60 |
| 7375 | Cashu Wallet Tokens | NIP-60 |
| 7376 | Cashu Wallet History | NIP-60 |
| 7516 | Geocache log | NIP-CC |
| 7517 | Geocache proof of find | NIP-CC |
| 8000 | Add User | NIP-43 |
| 8001 | Remove User | NIP-43 |
| 9000-9030 | Group Control Events | NIP-29 |
| 9041 | Zap Goal | NIP-75 |
| 9321 | Nutzap | NIP-61 |
| 9734 | Zap Request | NIP-57 |
| 9735 | Zap Receipt | NIP-57 |
| 9802 | Highlights | NIP-84 |
| 10000 | Mute list | NIP-51 |
| 10001 | Pin list | NIP-51 |
| 10002 | Relay List Metadata | NIP-65, NIP-51 |
| 10003 | Bookmark list | NIP-51 |
| 10004 | Communities list | NIP-51 |
| 10005 | Public chats list | NIP-51 |
| 10006 | Blocked relays list | NIP-51 |
| 10007 | Search relays list | NIP-51 |
| 10008 | Profile Badges | NIP-51, NIP-58 |
| 10009 | User groups | NIP-51, NIP-29 |
| 10011 | External Identities | NIP-39 — ⚠ COLLISION: 51.md assigns 10011 to "Favorite follow sets"; README assigns NIP-39. Flagged upstream conflict; verify current state before use. |
| 10012 | Favorite relays list | NIP-51 |
| 10013 | Private event relay list | NIP-37 |
| 10015 | Interests list | NIP-51 |
| 10017 | Git authors | NIP-34 |
| 10018 | Git repositories | NIP-34 |
| 10019 | Nutzap Mint Recommendation | NIP-61 |
| 10020 | Media follows | NIP-51 |
| 10030 | User emoji list | NIP-51 |
| 10050 | DM inbox relays | NIP-51, NIP-17 |
| 10054 | Favorite podcasts list | NIP-51 |
| 10063 | Blossom server list | NIP-B7 |
| 10064 | Authored podcasts list | NIP-51 |
| 10096 | File storage server list | NIP-96 (deprecated) |
| 10101 | (listed in README kind table; purpose per NIP-54 wiki ecosystem) | 54 |
| 10102 | (listed in README kind table; purpose per NIP-54 wiki ecosystem) | 54 |
| 10133 | Payment Targets | NIP-A3 |
| 10154 | Podcast Metadata | NIP-F4 |
| 10166 | Relay Monitor Announcement | NIP-66 |
| 10312 | Room Presence | NIP-53 |
| 13194 | Wallet Info | NIP-47 |
| 13534 | Membership Lists | NIP-43 |
| 15128 | Root nsite manifest | NIP-5A |
| 17375 | Cashu Wallet Event | NIP-60 |
| 22242 | Client Authentication | NIP-42 |
| 23194 | Wallet Request | NIP-47 |
| 23195 | Wallet Response | NIP-47 |
| 24133 | Nostr Connect | NIP-46 |
| 24242 | Blobs on mediaservers | NIP-B7 |
| 27235 | HTTP Auth | NIP-98 |
| 28934 | Join Request | NIP-43 |
| 28935 | Invite Request | NIP-43 |
| 28936 | Leave Request | NIP-43 |
| 30000 | Follow sets | NIP-51 |
| 30002 | Relay sets | NIP-51 |
| 30003 | Bookmark sets | NIP-51 |
| 30004 | Curation sets | NIP-51 |
| 30005 | Video sets | NIP-51 |
| 30006 | Picture sets | NIP-51 |
| 30007 | Kind mute sets | NIP-51 |
| 30008 | Badge sets | NIP-51, NIP-58 |
| 30009 | Badge Definition | NIP-58 |
| 30015 | Interest sets | NIP-51 |
| 30017 | Stall | NIP-15 |
| 30018 | Product | NIP-15 |
| 30019 | Marketplace UI/UX | NIP-15 |
| 30020 | Product auction | NIP-15 |
| 30023 | Long-form Content | NIP-23 |
| 30024 | Draft Long-form (deprecated path) | NIP-23 |
| 30030 | Emoji sets | NIP-51 |
| 30040 | Curated Publication Index | NKBIP-01 (external) |
| 30041 | Curated Publication Content | NKBIP-01 (external) |
| 30063 | Release artifact sets | NIP-51 |
| 30078 | Application-specific Data | NIP-78 |
| 30166 | Relay Discovery | NIP-66 |
| 30267 | App curation sets | NIP-51 |
| 30311 | Live Event | NIP-53 |
| 30312 | Interactive Room | NIP-53 |
| 30313 | Conference Event | NIP-53 |
| 30315 | User Statuses | NIP-38 |
| 30382 | User Trusted Assertion | NIP-85 |
| 30383 | Event Trusted Assertion | NIP-85 |
| 30384 | Addressable Trusted Assertion | NIP-85 |
| 30402 | Classified Listing | NIP-99 |
| 30403 | Draft Classified Listing | NIP-99 |
| 30617 | Repository announcements | NIP-34 |
| 30618 | Repository state announcements | NIP-34 |
| 30818 | Wiki article | NIP-54 |
| 30819 | Redirects | NIP-54 |
| 31234 | Draft Event | NIP-37 |
| 31922 | Date-Based Calendar Event | NIP-52 |
| 31923 | Time-Based Calendar Event | NIP-52 |
| 31924 | Calendar | NIP-52 |
| 31925 | Calendar Event RSVP | NIP-52 |
| 31989 | Handler recommendation | NIP-89 |
| 31990 | Handler information | NIP-89 |
| 32267 | Software Application | (no NIP cited in README) |
| 34235 | Addressable Video Event | NIP-71 |
| 34236 | Addressable Short Video | NIP-71 |
| 34128 | Legacy nsite manifest (deprecated) | NIP-5A |
| 34550 | Community Definition | NIP-72 (unrecommended) |
| 35128 | Named nsite manifest | NIP-5A |
| 37516 | Geocache Listing | NIP-CC |
| 37517 | Geocache Curation List | NIP-CC |
| 38172 | Cashu Mint Announcement | NIP-87 |
| 38173 | Fedimint Announcement | NIP-87 |
| 38383 | P2P Order events | NIP-69 |
| 39000-39009 | Group metadata events | NIP-29 |
| 39089 | Starter packs | NIP-51 |
| 39092 | Media starter packs | NIP-51 |
| 39701 | Web bookmarks | NIP-B0 |

## Completeness note
This registry reproduces the README kind table (retrieved 2026-09-23) in full to our knowledge, including external-cited entries (marked). The README itself states its table is NOT exhaustive — always cross-check https://github.com/nostr-protocol/registry-of-kinds before allocating a kind. Challenged and corrected 2026-09-23 (protocol-challenger gap finding: several kinds had been silently dropped in the first pass; re-applied 2026-09-24 after an edit-race loss).

## Design rules for new kinds (binding for this swarm)
1. Never invent a kind without checking this registry + https://github.com/nostr-protocol/registry-of-kinds + current NIPs first.
2. Choose the class deliberately: regular vs replaceable vs ephemeral vs addressable — this decides relay storage behavior.
3. Document: Kind, Purpose, Required tags, Optional tags, Content format, Author semantics, Replaceability, Addressability, Deletion semantics, Relay requirements, Indexing strategy, Privacy implications, Security implications, Example event, Compatibility.
4. Deprecated kinds remain in this registry for historical interoperability even where their NIP is unrecommended.
