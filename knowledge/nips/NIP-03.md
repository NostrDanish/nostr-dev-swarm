# NIP-03 — OpenTimestamps Attestations for Events

Source: https://github.com/nostr-protocol/nips/blob/master/03.md
Retrieved: 2026-09-23
Status: `draft` `unrecommended` `optional` — README warning: "unrecommended: vulnerable to one specific attack, needs update"
Confidence: HIGH (spec-read)

## Purpose
Anchors a Nostr event's existence/integrity into the Bitcoin blockchain via an OpenTimestamps (OTS) proof, proving the event existed no later than a given Bitcoin block.

## Event kinds
- `kind:1040` — regular event containing an OTS attestation for another event.

## Tags defined/used
- `e` — `<target-event-id>`, `<relay-url>`: the event being timestamped (required).
- `k` — `<target-event-kind>`: kind of the target event.

## Content format
`content` = base64-encoded full contents of an `.ots` file. The file MUST contain at least one Bitcoin attestation; SHOULD contain a **single** Bitcoin attestation (fewer bytes) and no "pending" attestation references (useless here).

## Semantics & rules
- The OTS proof MUST prove the referenced `e` event **id** as its digest (i.e., the 32-byte event id is the hashed message committed into Bitcoin).
- Verification: decode content, run `ots verify` against an esplora server; confirms the digest was committed at/before a specific block height.

## Security & privacy notes
- Funds not directly at risk, but the proof binds to the event **id**, not content semantics — id is a sha256 of the serialized event, so proof covers the full signed event.
- README explicitly warns the NIP is "vulnerable to one specific attack" (not detailed in the spec text) and is marked unrecommended — do not rely on it for authoritative timestamping without understanding the attack; consider whether attacker-controlled key reuse/re-signing or relay-time ambiguity is at play.
- Relay URL hint in `e` tag is informational; proof validity is independent of relay availability.

## Interoperability notes
- Toolchain: `nak` (fetch event), `jq`, `ots` CLI; verification example uses blockstream.info esplora API.
- Independent of any payment/zap NIPs; purely an attestation layer.

## Example
Real spec verification flow:
```bash
nak req -i e71c6ea722987debdb60f81f9ea4f604b5ac0664120dd64fb9d23abc4ec7c323 wss://nostr-pub.wellorder.net | jq -r .content | ots verify
# timestamp validated at block [810391]
```

## Open questions / uncertainties
- The "one specific attack" cited in the README is not described in the spec file — attack vector unspecified.
- No guidance on handling multiple/conflicting 1040 attestations for the same event.
