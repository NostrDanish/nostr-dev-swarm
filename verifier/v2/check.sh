#!/usr/bin/env bash
# Verifier v2 — runs v1 then v2-specific checks
ROOT="${1:-/mnt/agents/work/nostr-dev-swarm}"
HERE="$(cd "$(dirname "$0")" && pwd)"
fail=0
chk(){ if eval "$2"; then echo "PASS: $1"; else echo "FAIL: $1"; fail=1; fi }

bash "$HERE/../v1/check.sh" "$ROOT" || fail=1

# v2.1 marker coverage across all knowledge/
miss=$(grep -rL -e 'Source:' -e 'SWARM POLICY\|swarm policy\|swarm standard' "$ROOT/knowledge/" --include='*.md' 2>/dev/null | wc -l)
chk "all knowledge/ files have provenance markers (missing $miss)" "[ '$miss' -eq 0 ]"

# v2.2 provenance honesty
chk "ORG-THREAT-MODEL exists" "[ -f '$ROOT/threat-models/ORG-THREAT-MODEL.md' ]"
for i in 0001 0002 0003 0004 0005; do
  n=$(ls "$ROOT/decisions/ADR-$i"-*.md 2>/dev/null | wc -l)
  chk "ADR-$i exists" "[ '$n' -ge 1 ]"
done

# v2.3 drift guard: no NIP-44 padding constants in agents/
drift=$(grep -rl '65536\|extended prefix' "$ROOT/agents/" 2>/dev/null | wc -l)
chk "no padding constants in agents/ ($drift)" "[ '$drift' -eq 0 ]"

# v2.4 no 'silently' loophole near signing boundary
sil=$(grep -rn 'never silently' "$ROOT/README.md" "$ROOT/OPERATING_MANUAL.md" 2>/dev/null | wc -l)
chk "'silently' loophole absent ($sil)" "[ '$sil' -eq 0 ]"

exit $fail
