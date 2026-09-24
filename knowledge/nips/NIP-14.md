# NIP-14 — Subject tag in Text events

Source: https://github.com/nostr-protocol/nips/blob/master/14.md
Retrieved: 2026-09-23
Status: `draft` `optional` (README lists normally)
Confidence: HIGH (spec-read)

## Purpose
Defines the `subject` tag for kind-1 text events, so clients displaying threaded message lists can show a subject line (email-style) instead of the first few words of the message.

## Event kinds
| kind | class | role |
|------|-------|------|
| 1 | regular | Text note that may carry a `subject` tag |

## Tags defined/used
- `subject` (optional): `["subject", <string>]` — the thread/subject title.

## Content format
Normal kind-1 plaintext content; subject lives only in the tag.

## Semantics & rules
- When replying to a message with a subject, clients SHOULD replicate the subject tag.
- Clients MAY adorn the subject to denote a reply, e.g. prepending `Re:`.
- Subjects should generally be shorter than 80 chars; longer subjects will likely be trimmed by clients.

## Security & privacy notes
- Subject is plaintext metadata visible to all; don't put sensitive info there.
- Subjects can be spoofed/misleading (no binding to content); clients shouldn't treat them as authoritative summaries.

## Interoperability notes
- Spec explicitly notes implementation in more-speech. Support is spotty elsewhere; most mainstream microblogging clients ignore it.

## Example
```json
{
  "kind": 1,
  "tags": [["subject", "Re: Nostr Dev Swarm kickoff"]],
  "content": "..."
}
```
(constructed example per spec format)

## Open questions / uncertainties
- Interaction with NIP-22 comment threads (kind 1111) is unspecified — the NIP predates NIP-22 and only mentions kind 1.
