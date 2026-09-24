# NEGENTROPY — range-based set reconciliation internals

Source: https://github.com/hoytech/negentropy ; https://github.com/hoytech/negentropy/blob/master/docs/negentropy-protocol-v1.md (wire spec) ; https://logperiodic.com/rbsr.html (theory article, D. Hoyte) ; https://github.com/hoytech/strfry (deployed usage) ; https://nips.nostr.com/77 (Nostr transport)
Retrieved: 2026-09-23
Confidence: HIGH (Tier 1 spec + wire document + author article read directly; arXiv:2603.19820 corroborates deployment status).

## What it is
Set-reconciliation ("anti-entropy repair") protocol by Doug Hoyte (Log Periodic), based on Aljoscha Meyer's Range-Based Set Reconciliation (SRDS 2023, arXiv:2212.13567). Given two parties with overlapping record sets, it efficiently determines the symmetric difference (who has what the other lacks). Basis of NIP-77 Nostr syncing and strfry relay sync.

## Data model
- Each record maps to `(timestamp: u64, id: 32 bytes)`. ID = cryptographic hash of the record (canonicalize first); timestamp is any ordering criterion (similar timestamps should cluster together for efficiency).
- Max u64 (`2^64-1`) is reserved as the "infinity" timestamp; timestamps need not be unique.
- No in-place updates: changing a record = delete old ID + insert new ID.

## Algorithm (range reconciliation)
1. Both sides sort records by (timestamp asc, id lexicographic). A contiguous slice = a **range**, addressed by **bounds**: timestamp + shortest ID-prefix that separates it from the previous range's last record (prefix empty if timestamps differ). Lower bound inclusive, upper exclusive.
2. Messages alternate client→server→client. Message = version byte + ordered ranges; each range = upper bound + mode + payload:
   - `Skip` (mode 0): no further processing; adjacent Skips coalesce.
   - `Fingerprint` (mode 1): 16-byte digest of all IDs in range. Match → range provably identical, closed. Mismatch → receiver SPLITS its own range and recurses (sub-ranges must fully cover parent bounds).
   - `IdList` (mode 2): full ID list; base case — reconciles the range immediately. Empty range = IdList of length 0 (cheaper than an "empty fingerprint", which unlike Meyer's design is never used).
3. Termination: when the client's reply is a full-universe Skip (empty message), the client knows its `have`/`need` sets.
4. Splitting strategy is implementation-defined (N equal buckets, timestamp-weighted, recent-as-IdList, randomized bounds for fingerprint-attack resistance). Never answer a range with a single Fingerprint range (non-termination risk).
5. **Frame size limit** option: over-limit diffs are deferred via a coalesced trailing Fingerprint range → more round-trips; `have`/`need` may then contain duplicates (applications must dedupe).

Efficiency: ~`log16(N)/2` round trips when mostly in sync — ≈3 round-trips for 1M records, 4 for 1B (logperiodic.com/rbsr.html). Bandwidth scales with number of differences, not set size.

## Fingerprint construction (Protocol V1, exact)
```
sum     = Σ ids  (mod 2^256, each id as 32-byte LITTLE-ENDIAN uint)
payload = sum || varint(count of elements in range)
fingerprint = SHA-256(payload)[0:16]
```
Additive-homomorphic ("incremental") hash: cached fingerprints update in O(1) on insert/delete instead of re-hashing the range (motivation vs `sha256(concat)` in the rbsr article; XOR-combine discussed as alternative).

## Wire format (V1)
- Version byte `0x61`; server replies with max-supported version byte if it can't handle one (downgrade path).
- Varint: base-128, MSB-first, high bit set on all but last digit.
- Bounds delta-encode timestamps (`1 + offset`, infinity = 0); idPrefix 0–32 bytes, omitted trailing bytes = 0.
- Implicit trailing Skip-to-infinity if last range doesn't end at infinity.
- Debug with `fq` (fiatjaf contributed a negentropy decoder).

## Storage / transport split
- **Negentropy computes only the diff (ID sets). Record transfer is external** — in Nostr, missing events move via ordinary `REQ`/`EVENT` after reconciliation.
- Storage interface is pluggable. C++ reference ships Vector / BTreeMem / BTreeLMDB / SubRange backends; relays maintain per-filter BTrees. "Anti-Entropy LMDB" fork (E. Amparore) caches aggregates in LMDB branch pages → measured 4–10x fingerprint speedup. arXiv:2603.19820 further improves with in-tree order-statistics aggregates.
- **Nostr transport = NIP-77**: `NEG-OPEN` / `NEG-MSG` / `NEG-CLOSE` message types over the existing relay WebSocket, frames hex-encoded; works client↔relay and relay↔relay. Advantages over `since`-filter catch-up: provably complete (no clock-drift gaps), fewer round-trips.

## Implementations (per repo README)
C++ (reference), JS (reference), Rust (Yuki Kishimoto), Go (Illuzen; fiatjaf's Nostr-specific Go), C bindings, C# (bezysoftware), Kotlin (Vitor Pamplona), Perl (N. Hubbard, Net::Nostr::Negentropy). Cross-language conformance fuzz suite in `test/`.

## Deployed users
strfry (`strfry sync <relay> [--dir both]`, `strfry negentropy` BTree management), nostria-relay, NDK `@nostr-dev-kit/sync`, Citrine aggregator, **ngit-grasp GRASP-02 proactive sync** (with REQ+EOSE fallback). Explored for Waku Sync. Also usable for cheap multi-relay event counts without downloading filter results (strfry).
