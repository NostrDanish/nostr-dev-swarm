# NIP-21 — `nostr:` URI scheme

Source: https://github.com/nostr-protocol/nips/blob/master/21.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Standardizes a common URI scheme — `nostr:` — for referencing Nostr entities inside content, HTML pages, and any URI-aware context, maximizing interoperability.

## Event kinds
None defined (this is a URI convention, not an event spec).

## Tags defined/used
None defined by this NIP itself; `nostr:` URIs appear in `.content` of other events and relate to `q`/`p` tags via NIP-18/NIP-27.

## Content format
The URI is `nostr:` + a NIP-19 bech32 identifier — all NIP-19 entities EXCEPT `nsec` (never embed private keys in URIs). Valid: `npub`, `nprofile`, `note`, `nevent`, `naddr`.

## Semantics & rules
- Identifiers after `nostr:` are exactly the NIP-19 bech32 strings (minus `nsec`).
- HTML linking: `<link rel="alternate" href="nostr:naddr1...">` associates a webpage with the same content as a Nostr event (e.g. Markdown article served both as HTML and as kind 30023).
- `<link rel="me" href="nostr:nprofile1...">` or `rel="author"` assigns authorship of a webpage to a Nostr profile.

## Security & privacy notes
- `nsec` is explicitly excluded — a `nostr:nsec1...` URI would leak the private key; clients should refuse to generate it.
- Relay hints embedded in `nevent`/`nprofile`/`naddr` can be used for tracking or to steer users to malicious relays.

## Interoperability notes
- Foundation for NIP-27 (text note references) and NIP-18 `q` tags (quotes of `nostr:` mentions). Web clients (njump etc.) register as handlers for `nostr:` URIs. Nearly universal across clients for mention rendering.

## Example
```
nostr:npub1sn0wdenkukak0d9dfczzeacvhkrgz92ak56egt7vdgzn8pv2wfqqhrjdv9
nostr:nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gpp4mhxue69uhhytnc9e3k7mgpz4mhxue69uhkg6nzv9ejuumpv34kytnrdaksjlyr9p
```
```html
<head>
  <link rel="alternate" href="nostr:naddr1qqyrzwrxvc6ngvfkqyghwumn8ghj7enfv96x5ctx9e3k7mgzyqalp33lewf5vdq847t6te0wvnags0gs0mu72kz8938tn24wlfze6qcyqqq823cph95ag" />
</head>
```
(from spec)

## Open questions / uncertainties
- No registry for who handles `nostr:` links at OS/browser level; behavior varies by platform.
