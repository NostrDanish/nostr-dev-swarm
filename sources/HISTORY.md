# HISTORY — Nostr origins, design philosophy, protocol comparisons

Source: https://fiatjaf.com/nostr.html (original essay, Tier 1) ; https://github.com/nostr-protocol/nostr (original README, Tier 1) ; https://arxiv.org/abs/2402.05709, https://arxiv.org/abs/2505.22962 (academic, Tier 2) ; comparisons: https://d-central.tech/decentralized-social-protocols-comparison/ (Tier 3 but spec-sourced), https://www.siftree.com/blog/nostr-vs-at-protocol-(bluesky)-a-complete-guide, https://fediview.com/articles/mastodon-vs-bluesky-vs-nostr-2026/, https://www.linkedin.com/posts/atomicpoet_its-true-that-at-protocol-and-nostr-offer-activity-7285042869365624833-4tji (Tier 3) ; adoption critique https://punkscience.ca/tech-briefs/nostr-as-social-media.html (Tier 3)
Retrieved: 2026-09-23
Confidence: HIGH for fiatjaf's own rationale (primary sources); MEDIUM for third-party comparisons (labeled Tier 3); MEDIUM-LOW for adoption metrics.

## Origin story
- Created by fiatjaf (anonymous Lightning dev). Original essay fiatjaf.com/nostr.html; original repo github.com/nostr-protocol/nostr (public domain). Self-described: "The simplest open protocol that is able to create a censorship-resistant global 'social' network once and for all."
- Triad: "It doesn't rely on any trusted central server, hence it is resilient; it is based on cryptographic keys and signatures, so it is tamperproof; it does not rely on P2P techniques, and therefore it works."
- NIPs dates: NIP-01 draft dated 2020-11-15 per codeberg nip-index (Tier 2).

## Why "relays, not servers" (fiatjaf's rationale)
- "A relay is very simple and dumb. It does nothing besides accepting posts from some people and forwarding to others. Relays don't have to be trusted. Signatures are verified on the client side." Relays never talk to each other — no server-to-server federation by design.
- Identity = keypair, so relay bans don't cost you identity or followers; relays may have any policy; if all else fails, paid relays guarantee a publisher ("there will always be some Russian server willing to take your money").
- Diagnosed failures of alternatives (essay):
  - Twitter: ads, addiction mechanics, non-chronological feeds, bans/shadowbans, spam.
  - Mastodon/ActivityPub: identities attached to third-party-controlled domains; server-owner "despotism… often worse than that of a big company"; migration "doesn't work in an adversarial environment (all followers are lost)"; server-to-server fan-out scales poorly with many instances; abandoned amateur servers ≈ banning everyone.
  - SSB: too complicated, rigid per-user append-only chain, P2P-first ("pubs" an afterthought).
  - Everyone-runs-a-server designs: impractical; domains still censorable.
- On "why hasn't anyone done this before": companies want money, P2P activists refuse servers entirely — "both fail to see the specific mix of both worlds that Nostr uses."
- Scaling/storage philosophy: a handful of relays suffices since relays don't replicate to each other; spam = relay-local problem (payment, hashcash, auth) + client-side unlisting; heavy content handled by relay policy/market.
- Self-acknowledged hardest problem: relay discovery for followed keys → later answered by the NIP-65 outbox model.

## Sourced comparisons

### vs ActivityPub (Mastodon/Fediverse)
- Academic (arXiv:2402.05709): relays "interact solely with users… decoupling the fixed association between a user and a server"; users push to any/multiple relays, so posts survive relay failure/censorship.
- Portability (d-central, spec-sourced): Mastodon "Move" migrates followers only — "Your posts will not be moved, due to technical limitations"; content unsigned and server-custodial (lost if server dies); new handle/URI on move. Nostr: nothing to move — the keypair is server-independent.
- Identity: ActivityPub has no user-held key and no DIDs in the ratified spec (FEP-ef61 portable objects experimental, unshipped). Strengths honestly noted: largest mature network, zero key management, human-readable handles, cheap servers, password reset.

### vs AT Protocol (Bluesky)
- ATProto wins on recoverability: `did:plc` rotation keys + 72h recovery window; first-class account migration (CAR export/import, constant DID+handle); W3C DID-core alignment (did:plc/did:web).
- Nostr wins on gatekeeper-free identity: self-generated key, no directory, no cost; resistance = broadcast signed events to many independent relays.
- Shared honest limits: Nostr key is un-rotatable — lost/stolen nsec is permanent (rotation only in unmerged PR #1452); ATProto depends today on a single Bluesky-run PLC directory + DNS handles, and dominant relay/AppView can defederate ("verifiable exit, not permissionless immutability"). ATProto infra (relay/firehose) is expensive to run — de facto operator concentration (Trottier, Tier 3). Nostr relays are "dumb" and cheap, but if every relay your audience reads drops you, reach collapses: "takedown-resistant, not takedown-proof."

### Adoption reality check (Tier 3)
punkscience.ca: Nostr solved identity-layer portability/censorship resistance but not relay economics, discovery, moderation/spam, or key UX; "never crossed 100,000 weekly active users in any week of 2025." Treat metrics as approximate.

## Takeaways for the swarm
- Protocol minimalism is the design bet: one generic signed event + dumb relays → ecosystem diversity via NIPs, at the cost of weak discovery/moderation/key-recovery.
- Any design we ship must respect: client-side signature verification, relay redundancy (never depend on one relay), key UX danger (no recovery), and outbox-model relay discovery.
