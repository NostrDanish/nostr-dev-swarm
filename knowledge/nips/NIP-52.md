# NIP-52 — Calendar Events

Source: https://github.com/nostr-protocol/nips/blob/master/52.md
Retrieved: 2026-09-23
Status: `draft` `optional`; not marked unrecommended in README.
Confidence: HIGH (spec-read)

## Purpose
Calendar events representing an occurrence at a specific moment or between moments — addressable and deletable per NIP-09. Terminology note: "calendar event" (this NIP) vs "event" (generic Nostr event).

## Event kinds
- `31922` — **Date-Based Calendar Event** (addressable). All-day/multi-day; timezone-insignificant (anniversaries, holidays, vacations).
- `31923` — **Time-Based Calendar Event** (addressable). Start/end timestamps.
- `31924` — **Calendar** (addressable list). Collection of calendar events; users can have multiple (personal, work, meetups...).
- `31925` — **Calendar Event RSVP** (addressable). Attendance intention response.

## Tags defined/used
Common to 31922/31923:
- `d` (required, unique id), `title` (required), `summary`, `image`, `location` (repeated: address, GPS, room, call link), `g` (geohash), `p` (repeated: pubkey + optional relay + role), `t` (hashtag), `r` (references: web pages, docs, call links, recordings), `a` (reference to kind 31924 calendar requesting inclusion).
- Deprecated: `name` (use only if `title` unavailable).
- 31922 adds: `start` (required, inclusive, ISO 8601 `YYYY-MM-DD`, must be < `end`), `end` (optional, EXCLUSIVE end date; omitted → ends same date as start).
- 31923 adds: `start`/`end` (unix seconds; end optional → instantaneous), `start_tzid`/`end_tzid` (IANA TZ DB names; end_tzid omitted → same as start), `D` (REQUIRED day-granularity timestamp `floor(unix_seconds()/86400)`; multiple `D` tags SHOULD cover the event's timeframe — enables day-level relay queries).
- 31924: `d`, `title` (required), `a` (repeated refs to 31922/31923 events).
- 31925 RSVP: `a` (required, coordinates of calendar event), `e` (optional, specific revision id), `d` (required), `status` (required: `accepted`/`declined`/`tentative`), `fb` (optional: `free`/`busy`; MUST be omitted/ignored if status=declined), `p` (optional, calendar event author).

## Content format
31922: content SHOULD be description. 31923/31924: description, required but MAY be empty string. 31925: optional free-form note.

## Semantics & rules
- **Collaborative Calendar Event Requests**: a calendar event tagging a 31924 calendar via `a` = request for inclusion; the calendar owner approves by adding an `a` tag for the event to the calendar. Enables multi-user contribution to calendars they don't own.
- Calendar events are NOT required to belong to any calendar.
- RSVP semantics: being `p`-tagged on a calendar event ≈ invitation; clients MAY prompt RSVP. Any user may RSVP even untagged; authorization semantics intentionally undefined (up to event creator). What happens when a calendar event changes after RSVP is intentionally undefined. RSVP `e` tag pins to a specific revision; clients SHOULD treat it as revision-specific.
- **Intentionally unsupported**: recurring calendar events — complexity (timezones, DST, leap years, one-off changes) pushed to clients, which duplicate metadata across individual events.

## Security & privacy notes
- Attendance intentions (RSVP) are public by default; `fb` reveals free/busy schedule information.
- Invitation ≠ authorization; spec leaves gatekeeping to creators.

## Interoperability notes
- NIP-09 deletion; NIP-01 addressable coordinates; geohash convention shared with other location NIPs; `D` tag mirrors day-bucket query patterns.

## Example
Real spec example (time-based event, abridged):
```yaml
{
  "kind": 31923,
  "content": "<description>",
  "tags": [
    ["d", "<random-identifier>"],
    ["title", "<title>"],
    ["start", "<unix ts>"], ["end", "<unix ts>"],
    ["D", "82549"],
    ["start_tzid", "America/Costa_Rica"],
    ["p", "<pubkey>", "<relay>", "<role>"]
  ]
}
```

## Open questions / uncertainties
- Recurrence explicitly out of scope; client-level duplication strategy not standardized.
- RSVP authorization and post-RSVP edits deliberately undefined.
