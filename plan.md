# Plan — NOSTR DEV SWARM bootstrap

## Objective
Create a Nostr-native virtual senior engineering organization as a reusable repo:
agent role definitions + a living, source-verified Nostr knowledge base,
bootstrapped from authoritative sources, then challenged by security/protocol reviewers.

## Stage 0 — Plan & verifier
- This file.
- `verifier/v1/criteria.md` + `verifier/v1/check.sh` (structural + content checks).
- Append-only `verifier/README.md` index; timestamped runs under `verifier/runs/`.

## Stage 1 — Research (parallel explore subagents, foreground)
- Agent R1: NIP inventory — current NIP list, status (final/draft/etc.), event kinds, tags,
  from https://github.com/nostr-protocol/nips (Tier 1 source). Output: structured markdown.
- Agent R2: Ecosystem map — relay implementations, clients, SDKs/libraries, tooling
  (Blossom, negentropy, indexers). Tier 1/2 sources only.
- No skill files needed; Orchestrator-designed guidance (source hierarchy, citation discipline).

## Stage 2 — Build scaffold (coder subagent + orchestrator integration)
Directory tree:
```
nostr-dev-swarm/
├── README.md
├── agents/                # 15 role definitions (chief-architect .. product-ux)
├── knowledge/
│   ├── nips/              # per-NIP cards + INDEX.md (from Stage 1)
│   ├── event-kinds/       # kind registry
│   ├── tags/              # tag conventions
│   ├── relays/  clients/  sdk/  security/  cryptography/  networking/
├── protocols/             # nostr.md, nip-01.md, blossom.md, nip-44.md, nip-46.md, nip-50.md, nip-77.md ...
├── architecture/  decisions/  threat-models/  test-plans/  sources/
└── OPERATING_MANUAL.md    # phases 1-6 workflow, disagreement protocol, output format
```
- Each knowledge entry carries: source URL, retrieved date (2026-09-23), spec status,
  implementation status, confidence.

## Stage 3 — Challenge (parallel reviewer/verifier subagents)
- Protocol challenger: verify KB claims against authoritative sources; flag errors/inventions.
- Security/red-team challenger: critique scaffold + KB for security/privacy gaps.
- Integrate findings into `decisions/` and corrections into KB.

## Stage 4 — Package & verify
- Run verifier script; append run record.
- Copy final tree to `/mnt/agents/output/nostr-dev-swarm/` and tar.gz archive.
- Final response references deliverables.

## Validation gate
Verifier must pass (structure + knowledge-base content rules + challenge-log present)
before handoff.

---

# Phase 2 expansion — "Deep research everything Nostr" (2026-09-23, goal round 2)

Route: A (wide→deep), adapted: deliverable = KB depth, not a prose report.
Research artifacts land in /mnt/agents/output/research/ (skill rule) AND distilled
per-NIP cards land in knowledge/nips/ directly (card = structured data, written
by the researching agent to avoid lossy context transfer).

Wave 1 — parallel deep-dive agents (non-overlapping clusters):
  W1 core social NIPs (02,10,13,14,18,21,22,23,24,25,27,30,36,38,39)
  W2 relay infra & groups (28,29,40,43,45,62,66,67,70,72,78,86)
  W3 money & markets (03,15,47,60,61,69,75,87,90,99,A3)
  W4 content & media (5A,32,34,35,52,54,64,68,71,84,88,A0,C0,F4,B0)
  W5 identity, keys & misc (06,26,37,48,49,55,73,92,94,A4,BE,C7,CC,EE + withdrawn 12/16/20/33 investigation)
  W6 adjacent protocols & registries (registry-of-kinds, NKBIP-01/02/03, Marmot/MLS,
     Blossom BUDs deep, GRASP, negentropy internals, history/philosophy)
Then: cross-check wave (verifier spot-checks new cards), verifier v3 (card-count +
marker checks), re-package deliverable.

# Phase 3 — Publish (2026-09-24, goal round 3)
Push the knowledge base to its own GitHub repo: NostrDanish/nostr-dev-swarm.
