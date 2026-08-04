# Code audit report template

## Do NOT flag these

Checked before any finding is written. Each is a real thing reviewers report
that costs the reader more than it returns:

- **Pre-existing issues outside the diff.** Real, but not this change's
  doing. Reporting them as findings of *this* review makes the author
  responsible for the repo's whole history. Name them in `Scope` as
  observed-but-out-of-range if they matter.
- **Correct code that merely looks wrong.** Unusual is not broken. If you
  cannot state the input that fails, you have a question, not a finding —
  ask it as a question.
- **Pedantic nitpicks.** Naming preferences, ordering, "I'd have written
  this differently." A finding needs a consequence.
- **Anything a linter or formatter already catches.** If the project's
  tooling would flag it on the next run, the tooling is the right place —
  say the tool is missing or misconfigured instead, once.
- **Lines with an explicit silencing comment** (`eslint-disable`,
  `# noqa`, `# type: ignore`) — unless the *reason given is wrong*, which is
  itself the finding, stated against the reason rather than the line.

The bar in one sentence: **a finding names a consequence and the input that
produces it.** Everything else is a question, a note in `Scope`, or silence.

The shape of a report a reviewer can act on without asking follow-ups.

```markdown
<Lede: the verdict with evidence. One short paragraph, no preamble.>

## 1. <Finding or area>

<What was found, with root cause and exact location `file.ts:42`. State the
alternative you rejected and why: "Chose X over Y because Y would still
<consequence>.">

**Safety checks:** <the exact searches run and what they matched — e.g.
"a Grep-tool search for `sandbox` matched only the sandbox files themselves —
no imports, no nav entry, no route config.">

## 2. <Next finding>

...

## Verification

- <input> → <observed output>, including the adversarial set (canonical
  bank — the `/qa` skill's `adversarial-inputs.md` reference): misspellings
  resolve, `zzzz` returns nothing, empty query / out-of-range page /
  regex-special chars / 500-char input all return 200.
- <build/typecheck/lint results, against a production build where relevant.>

**Known gap:** <what was NOT verified and why it's acceptable for now — or
that it isn't, and what it blocks.>

**Scope:** <what was deliberately left out to keep the audit focused, and
any pre-existing unrelated breakage noticed but not touched.>
```

## Worked lede (the texture)

> Reviewer logins go out this week, and any logged-in user can reach
> `/sandbox` by typing the URL — verified as a non-admin account: HTTP 200,
> 186KB of component previews built on hardcoded mock data.

A lede names the stakes, the reproduction, and the evidence in two
sentences. "The code has some security issues" is not a lede.
