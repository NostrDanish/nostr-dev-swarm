# NIP-64 — Chess (Portable Game Notation)

Source: https://github.com/nostr-protocol/nips/blob/master/64.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
Represent chess games as Nostr notes in PGN (Portable Game Notation) — human-readable and supported by most chess software.

## Event kinds
- `64` — **Chess PGN note** (regular).

## Tags defined/used
- No mandatory tags. `alt` (NIP-31) MAY be used to describe the note for non-supporting clients, e.g. `"Fischer vs. Spassky in Belgrade on 1992-11-04 (F/S Return Match, Round 29)"`.

## Content format
`.content` is a string representing a PGN database: tag pairs (`[Event "..."]`, `[Site ...]`, `[Date ...]`, `[Round ...]`, `[White ...]`, `[Black ...]`, `[Result ...]` — the Seven Tag Roster) followed by movetext with optional comments `{...}`. Minimal valid content: `1. e4 *` or even `*` (game state unknown/abandoned).

## Semantics & rules
- Clients SHOULD display content as a chessboard.
- Publish in PGN **export format** (strict, machine-generated); consume expecting **import format** (lax, human-written).
- Clients SHOULD validate formatting and that all moves comply with chess rules.
- Relays MAY validate PGN and reject invalid notes.

## Security & privacy notes
- No special concerns; content is plain text. Validation (clients/relays) guards against malformed or illegal-move games.

## Interoperability notes
- Interops with the whole PGN ecosystem (chess software, lichess pgn-viewer widget).
- Spec links: PGN specification + supplement (graphical elements, clock values, eval annotations), formal syntax, import/export format definitions (mliebelt/pgn-spec-commented).

## Example
Real spec examples:
```yaml
{"kind": 64, "content": "1. e4 *"}
```
```yaml
{
  "kind": 64,
  "tags": [["alt", "Fischer vs. Spassky in Belgrade on 1992-11-04 (F/S Return Match, Round 29)"]],
  "content": "[Event \"F/S Return Match\"]\n[Site \"Belgrade, Serbia JUG\"]\n...\n1. e4 e5 2. Nf3 Nc6 3. Bb5 {This opening is called the Ruy Lopez.} 3... a6\n... 43. Re6 1/2-1/2"
}
```
Also lichess arena examples with extended headers (WhiteElo, TimeControl, ECO, Termination) and multi-game databases.

## Open questions / uncertainties
- No kind defined for chess-related social actions (challenges, move-by-move play) — this NIP is purely game notation.
- Relay-side validation is optional, so invalid PGN may persist.
