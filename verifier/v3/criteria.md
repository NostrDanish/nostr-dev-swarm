# Verifier v3 — acceptance criteria (deep-research expansion)

Extends v1+v2. New checks:

1. Per-NIP card coverage: knowledge/nips/ contains >= 60 NIP-*.md card files
   (beyond INDEX.md / EXTERNAL-REGISTRIES.md).
2. Every card carries Source:, Retrieved:, Status:, Confidence: markers and the
   required sections (## Purpose, ## Event kinds, ## Security & privacy notes).
3. Adjacent-protocol files exist: knowledge/nips/EXTERNAL-REGISTRIES.md,
   protocols/marmot.md, protocols/blossom-buds.md, knowledge/networking/NEGENTROPY.md,
   sources/HISTORY.md.
4. Research artifacts: >= 6 wave files in /mnt/agents/output/research/ matching
   nostr_wave*.md.
5. All v1+v2 checks still pass.
