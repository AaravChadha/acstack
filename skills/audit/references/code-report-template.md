# Code audit report template

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
  bank: `../../qa/references/adversarial-inputs.md`): misspellings
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
