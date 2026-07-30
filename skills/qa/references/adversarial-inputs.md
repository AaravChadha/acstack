# Adversarial input bank — by surface type

Draw from every section whose surface the target has. The expected
outcome for all of these is a CONTROLLED rejection — a 4xx, a validation
message, an empty-but-well-formed result. A 5xx, a stack trace, or a
silent wrong answer is always a finding, however absurd the input.

## Free-text fields (search boxes, names, notes)

- Garbage tokens: `hdcf`, `zzzz` — plausible-looking nonsense; the
  classic "search worked in the demo" killer.
- 500-character string (one token, no spaces).
- Regex-special characters: `.*+?()[]{}|\^$` — as one input.
- Empty string, and whitespace-only (`"   "`).
- Unicode: an emoji, plus the known-bug-classes lookalike trio — a
  U+202F narrow no-break space and a U+00A0 NBSP inside a phrase, and a
  U+2013 en-dash where a hyphen is expected.
- An HTML/script fragment: `<b>x</b><script>1</script>` — expect it
  escaped or rejected, never rendered or executed.
- Prompt-injection-shaped input for any field an LLM will read
  ("ignore previous instructions and …") — expect it treated as data,
  never obeyed.

> **Canonical bank.** This file is the single home of the adversarial
> input list; /eval-spec's adversarial category and /audit's
> verification set cite it rather than keeping their own copies (the
> three copies had already diverged before 2026-07-30).

## Numeric fields

- `0`, `-1`, and the domain's plausible maximum × 1000.
- A float where an integer is expected (`3.7`).
- A string where a number is expected (`"ten"`).
- Scientific notation (`1e9`) and leading zeros (`007`).

## Identifiers (path params, lookups)

- A well-formed but nonexistent ID → expect 404, not 500, not an empty
  200 that looks like success.
- A malformed ID (`abc` where numeric, truncated UUID).
- ANOTHER USER'S valid ID while authenticated as the first user →
  expect 403/404; a 200 is an auth finding for /secure.

## Query parameters

- Required parameter missing entirely.
- The same parameter duplicated with conflicting values (`?limit=1&limit=999`).
- Unknown extra parameters (should be ignored, not fatal).

## Request bodies (POST/PUT — safety rule applies)

- Empty body with `Content-Type: application/json`.
- Malformed JSON (`{"a":`).
- Wrong content type (form-encoded where JSON expected).
- Oversized payload (~1 MB of filler) → expect a size limit, not a hang.
- Extra unexpected fields (mass-assignment probe: do they get stored?).

## Auth surfaces

- No token/session at all → every gated endpoint must return 401/403.
- A syntactically valid but garbage token (`Bearer aaaa.bbbb.cccc`).
- An expired token when one can be produced cheaply.

## Reading results

Two findings classes recur; name them precisely:

- **Fails open:** absurd input produced a 200 with wrong-but-plausible
  output — worse than a crash, because nobody notices.
- **Fails loud:** a 5xx or stack trace — an error-hygiene finding; the
  trace's contents (paths, queries, versions) are handed to /secure.
