#!/usr/bin/env bash
# Verifier v3 — v1+v2 plus deep-research expansion checks
ROOT="${1:-/mnt/agents/work/nostr-dev-swarm}"
HERE="$(cd "$(dirname "$0")" && pwd)"
fail=0
chk(){ if eval "$2"; then echo "PASS: $1"; else echo "FAIL: $1"; fail=1; fi }

bash "$HERE/../v2/check.sh" "$ROOT" || fail=1

# v3.1 card coverage
cards=$(ls "$ROOT/knowledge/nips/"NIP-*.md 2>/dev/null | wc -l)
chk "per-NIP cards >= 60 (found $cards)" "[ '$cards' -ge 60 ]"

# v3.2 card markers & sections
bad_src=$(grep -rL 'Source:' "$ROOT/knowledge/nips/"NIP-*.md 2>/dev/null | wc -l)
bad_ret=$(grep -rL 'Retrieved:' "$ROOT/knowledge/nips/"NIP-*.md 2>/dev/null | wc -l)
bad_st=$(grep -rL 'Status:' "$ROOT/knowledge/nips/"NIP-*.md 2>/dev/null | wc -l)
bad_cf=$(grep -rL 'Confidence:' "$ROOT/knowledge/nips/"NIP-*.md 2>/dev/null | wc -l)
bad_sec=$(grep -rL '## Security & privacy notes' "$ROOT/knowledge/nips/"NIP-*.md 2>/dev/null | wc -l)
chk "cards missing Source: ($bad_src)" "[ '$bad_src' -eq 0 ]"
chk "cards missing Retrieved: ($bad_ret)" "[ '$bad_ret' -eq 0 ]"
chk "cards missing Status: ($bad_st)" "[ '$bad_st' -eq 0 ]"
chk "cards missing Confidence: ($bad_cf)" "[ '$bad_cf' -eq 0 ]"
chk "cards missing security section ($bad_sec)" "[ '$bad_sec' -eq 0 ]"

# v3.3 adjacent-protocol files
for f in knowledge/nips/EXTERNAL-REGISTRIES.md protocols/marmot.md protocols/blossom-buds.md knowledge/networking/NEGENTROPY.md sources/HISTORY.md; do
  chk "$f exists" "[ -f '$ROOT/$f' ]"
done

# v3.4 research artifacts
waves=$(ls /mnt/agents/output/research/nostr_wave*.md 2>/dev/null | wc -l)
chk "research wave files >= 6 (found $waves)" "[ '$waves' -ge 6 ]"

exit $fail
