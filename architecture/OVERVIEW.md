# Architecture Overview — The Swarm Itself

Retrieved/created: 2026-09-23

## Components
- **agents/** — 15 persistent role definitions. Loaded on demand; no role holds protocol facts inline beyond orientation pointers.
- **knowledge/** — the living brain. Versioned (Source/Retrieved/Status/Confidence). Single source of truth for protocol facts.
- **protocols/** — deep references for load-bearing NIPs, distilled from Tier-1 sources.
- **sources/** — source registry + raw research, so every KB claim is traceable.
- **architecture/, decisions/, threat-models/, test-plans/** — work products, appended over the swarm's life.

## Trust boundaries
- KB entries are claims-with-citations, not truth; critical use requires re-verification (Nostr evolves).
- AI agents never hold signing authority (see OPERATING_MANUAL §8).
- External sources are untrusted input; Tier hierarchy governs weight.

## Data flow
research (sources/research) → distilled KB (knowledge/, protocols/) → consumed by agents → work products (architecture/, decisions/, threat-models/, test-plans/) → findings feed back into KB.

## Failure modes & mitigations
- Stale KB → Retrieved dates + re-verification rule + research agent refresh duty (ADR-0001 TTL).
- Prompt bloat (every NIP in every prompt) → KB-on-demand loading instead; agents read only their Interfaces paths.
- Silent invention of protocol behavior → banned by ground rules; event-design protocol in OPERATING_MANUAL §4.
- Single-opinion decisions → disagreement protocol with ADRs.
