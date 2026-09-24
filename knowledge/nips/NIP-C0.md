# NIP-C0 — Code Snippets

Source: https://github.com/nostr-protocol/nips/blob/master/C0.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
Share/store code snippets with code-specific metadata (language, extension, runtime, license) for discoverability, syntax highlighting, and better UX — unlike plain kind-1 notes.

## Event kinds
- `1337` — **Code snippet** (regular).

## Tags defined/used
All optional:
- `l` — programming language name, lowercase (`javascript`, `python`, `rust`).
- `name` — snippet name, commonly a filename (`hello-world.js`).
- `extension` — file extension without dot.
- `description` — what the code does.
- `runtime` — environment spec (`node v18.15.0`, `python 3.11`).
- `license` — MUST be a standard SPDX short identifier when available (`MIT`, `GPL-3.0-or-later`, `Apache-2.0`); MAY add a reference to license text as extra parameter; REPEATABLE for multi-licensing (recipient may choose any).
- `dep` — dependency required to run (repeatable).
- `repo` — origin repository: standard URL, OR a NIP-34 repo announcement address `"30617:<pubkey-hex>:<d-tag>"` with a recommended relay URL as extra parameter.

## Content format
`.content` = the actual code snippet text (whitespace preserved).

## Semantics & rules
- Client behavior SHOULDs: syntax highlighting per language, one-action copy, preserve whitespace/indentation, prominent language/extension display, "run" functionality when possible, show description.
- Client MAYs: editing, forking/modifying, executable environments from runtime/deps, download-as-file using `extension`, share with attribution.

## Security & privacy notes
- Executing remote snippets is dangerous — "run" functionality needs sandboxing (spec silent on this).
- License tag is a claim by the publisher; SPDX constraint improves machine-readability.

## Interoperability notes
- NIP-34 (repo references via 30617 addresses), SPDX license identifiers, kind number is the leetspeak joke 1337.

## Example
Real spec example:
```json
{
  "kind": 1337,
  "content": "function helloWorld() {\n  console.log('Hello, Nostr!');\n}\n\nhelloWorld();",
  "tags": [
    ["l", "javascript"],
    ["extension", "js"],
    ["name", "hello-world.js"],
    ["description", "A basic JavaScript function that prints 'Hello, Nostr!' to the console"],
    ["runtime", "node v18.15.0"],
    ["license", "MIT"],
    ["repo", "https://github.com/nostr-protocol/nostr"]
  ]
}
```

## Open questions / uncertainties
- No threading/revision model for snippet updates (regular kind, no addressable variant).
- `dep` format (name only vs name@version) unspecified.
