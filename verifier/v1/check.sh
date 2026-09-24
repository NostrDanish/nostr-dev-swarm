#!/usr/bin/env bash
# Verifier v1 for NOSTR DEV SWARM deliverable
ROOT="${1:-/mnt/agents/work/nostr-dev-swarm}"
fail=0
chk(){ if eval "$2"; then echo "PASS: $1"; else echo "FAIL: $1"; fail=1; fi }

# 1. structure
for d in agents knowledge protocols architecture decisions threat-models test-plans sources; do
  chk "dir $d exists" "[ -d '$ROOT/$d' ]"
done
for d in nips event-kinds tags relays clients sdk security cryptography networking; do
  chk "knowledge/$d exists" "[ -d '$ROOT/knowledge/$d' ]"
done
for a in chief-architect nostr-protocol security-redteam cryptography networking backend frontend rust-systems devops-sre qa-testing performance privacy research code-review product-ux; do
  chk "agent $a.md exists" "[ -f '$ROOT/agents/$a.md' ]"
done
chk "README.md exists" "[ -f '$ROOT/README.md' ]"
chk "OPERATING_MANUAL.md exists" "[ -f '$ROOT/OPERATING_MANUAL.md' ]"

# 2. knowledge content
chk "nips/INDEX.md exists" "[ -f '$ROOT/knowledge/nips/INDEX.md' ]"
nips=$(grep -cE '^\| *NIP-[0-9]+' "$ROOT/knowledge/nips/INDEX.md" 2>/dev/null || echo 0)
chk "nips INDEX lists >=30 NIPs (found $nips)" "[ '$nips' -ge 30 ]"
kinds=$(grep -rhoE '^\| *[0-9]+(-[0-9]+)? *\|' "$ROOT/knowledge/event-kinds/" 2>/dev/null | wc -l)
chk "event-kinds registry >=20 kinds (found $kinds)" "[ '$kinds' -ge 20 ]"
srcmiss=$(grep -rL 'Source:' "$ROOT/knowledge/nips/" "$ROOT/protocols/" --include='*.md' 2>/dev/null | wc -l)
chk "all nips+protocols files have Source: (missing $srcmiss)" "[ '$srcmiss' -eq 0 ]"
retmiss=$(grep -rL 'Retrieved:' "$ROOT/knowledge/nips/" "$ROOT/protocols/" --include='*.md' 2>/dev/null | wc -l)
chk "all nips+protocols files have Retrieved: (missing $retmiss)" "[ '$retmiss' -eq 0 ]"
for p in nostr.md nip-01.md nip-44.md nip-46.md nip-50.md nip-77.md blossom.md; do
  chk "protocols/$p exists" "[ -f '$ROOT/protocols/$p' ]"
done

# 3. challenge log
tm=$(ls "$ROOT/threat-models/"*.md 2>/dev/null | wc -l)
chk "threat-models >=1 file ($tm)" "[ '$tm' -ge 1 ]"
adr=$(ls "$ROOT/decisions/"*.md 2>/dev/null | wc -l)
chk "decisions >=1 ADR ($adr)" "[ '$adr' -ge 1 ]"
sr=$(ls "$ROOT/sources/"*.md 2>/dev/null | wc -l)
chk "sources >=1 registry ($sr)" "[ '$sr' -ge 1 ]"
chal=$(grep -rl 'challenge' "$ROOT/decisions/" "$ROOT/threat-models/" 2>/dev/null | wc -l)
chk "challenge record exists ($chal)" "[ '$chal' -ge 1 ]"

# 4. no placeholders
ph=$(grep -ri 'TODO: fill\|lorem ipsum' "$ROOT" --include='*.md' 2>/dev/null | grep -v verifier | wc -l)
chk "no placeholders ($ph)" "[ '$ph' -eq 0 ]"

exit $fail
