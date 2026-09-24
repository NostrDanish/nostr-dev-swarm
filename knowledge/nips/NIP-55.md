# NIP-55 — Android Signer Application

Source: https://github.com/nostr-protocol/nips/blob/master/55.md
Retrieved: 2026-09-23
Status: `draft` `optional` (no unrecommended mark)
Confidence: HIGH (spec-read)

## Purpose
Two-way communication between an Android signer app (holds the private key) and any Nostr client on the same device (another Android app or a web page), so the client never handles the private key.

## Event kinds
none defined

## Tags defined/used
none (protocol-level spec; all pubkeys in hex)

## Content format
**Terminology**: user / client / signer / user-pubkey / package name (e.g. `com.example.signer`).

**Methods** (request `type` + payload):
| Method | Payload | Extra params | Result |
|---|---|---|---|
| `get_public_key` | _(empty)_ | `permissions` | user-pubkey |
| `sign_event` | event JSON | `current_user` | signature + signed event |
| `nip04_encrypt` / `nip44_encrypt` | plaintext | `pubkey`, `current_user` | ciphertext |
| `nip04_decrypt` / `nip44_decrypt` | ciphertext | `pubkey`, `current_user` | plaintext |
| `decrypt_zap_event` | event JSON | `current_user` | decrypted event JSON |

- `current_user` = hex pubkey logged into the client; `pubkey` = counterparty key; optional client-chosen `id` echoed back to match async responses.
- `permissions` passed with `get_public_key` are objects `{ "type": <method>, "kind"?: <kind> }` used to pre-authorize background Content Resolver calls, e.g. `[{"type":"sign_event","kind":22242},{"type":"nip44_decrypt"}]`.

## Semantics & rules — three transports
**Setup**: client declares the `nostrsigner` scheme in `AndroidManifest.xml` `<queries>`; detection via `packageManager.queryIntentActivities(Intent(ACTION_VIEW, Uri.parse("nostrsigner:")))`. Connection flow: (1) client sends `get_public_key`; (2) signer returns user-pubkey + its package name; (3) client stores both and SHOULD NOT re-call `get_public_key` while logged in; (4) further requests addressed to that package name.

**1. Intents** (Android clients; signer opens, user approves manually):
- Payload is the `nostrsigner:<payload>` URI data; other params are intent extras (`type`, `id`, `current_user`); result returned via `registerForActivityResult`.
- Result extras: `result`, `id`, `event` (signed JSON, sign_event only), `package` (get_public_key only), `rejected` (`true` when user rejected).
- Non-`RESULT_OK` resultCode = signer failure (e.g. crash); user rejection is `RESULT_OK` + `rejected=true` — distinct cases.
- Batch signing: client adds `FLAG_ACTIVITY_SINGLE_TOP | FLAG_ACTIVITY_CLEAR_TOP`; signer (which must declare `android:launchMode="singleTop"`) returns a `results` JSON array.

**2. Content Resolver** (background, no signer UI; only for permissions the user chose to remember):
- Client queries `content://<package-name>.<TYPE>` (e.g. `SIGN_EVENT`, `NIP44_ENCRYPT`) with `selectionArgs` = `[payload, pubkey, current_user]`.
- Cursor columns: `result` (+ `event` for sign_event). Returns `null` or a `rejected` column when: user didn't enable "remember my choice", user-pubkey unknown to signer, unknown type, or user set always-reject (client SHOULD NOT fall back to Intent in that case).

**3. Web** (web clients; no intent result channel):
- Request is a `nostrsigner:` URL: `nostrsigner:<payload>?type=<method>&pubkey=<hex>&callbackUrl=<url>`; result appended to `callbackUrl`, else copied to clipboard.
- Params: `type`, `pubkey`, `callbackUrl`, `returnType` (`signature`|`event`), `compressionType` (`none` default | `gzip` → returned event is `"Signer1"` + Base64(gzip(json)), because intents/URLs have length limits).
- Spec advises NIP-46 for web apps instead — every request pops the signer UI.

## Security & privacy notes
- IPC threat model: any app can register the `nostrsigner` scheme; clients MUST address requests to the stored signer `package` name (except initial `get_public_key`) so a malicious app can't intercept signing requests by claiming the scheme.
- `current_user` lets the signer bind approvals to the account the client claims, mitigating cross-account signing confusion.
- Content Resolver's background approval is only as strong as the user's remembered permissions — over-broad pre-authorization (e.g. unbounded `sign_event`) turns malware on-device into a silent signer; kind-scoped permissions mitigate.
- The `rejected` vs crash distinction prevents clients from retry-looping rejected requests.
- Web flow exfiltrates results through a URL/clipboard — clipboard results are readable by other apps.

## Interoperability notes
- Implemented by Amethyst-style signers (e.g. Amber); NIP-46 is the recommended pattern for web/remote cases.
- gzip `Signer1` prefix convention is specific to this NIP.

## Example
Real spec snippet:
```kotlin
val intent = Intent(Intent.ACTION_VIEW, Uri.parse("nostrsigner:$payload")).apply {
  `package` = signerPackageName        // omit only for get_public_key
  putExtra("type", "sign_event")
  putExtra("current_user", userPubkey)
}
launcher.launch(intent)
```
And web: `nostrsigner:${encodedJson}?compressionType=none&returnType=signature&type=sign_event&callbackUrl=https://example.com/?event=`

## Open questions / uncertainties
- No authentication of the *client* app to the signer beyond user approval prompts.
- Batch `results` array format is shown via a Kotlin `Result(...)` object; cross-language serialization detail is implicit.
