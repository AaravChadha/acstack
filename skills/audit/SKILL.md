---
name: audit
description: Audit one of three targets. code - defect hunt producing a report with safety checks and adversarial verification evidence; docs - drift check of README/PLAN/JOURNAL against the actual tree, counts, and checkbox reality; eval - failure classification with the never-inflate rule. Use when the user asks to audit or review code, a PR, project docs, or an eval report.
argument-hint: "code|docs|eval [path | PR# | diff range]"
---

# /audit — find what's wrong and report it honestly

Three targets, one stance: verdicts backed by evidence, misses logged rather
than massaged, and scope stated so the reader knows what was NOT checked.

<!-- acstack:principles -->
## Operating principles

- Be direct. Push back in writing when the plan or the user is wrong. No sycophancy.
- Never delete a decision. Supersede it: `~~old~~ → **Verdict (YYYY-MM-DD):** new call — reason.`
- Never fix, tune, or delete a test or eval case to raise a score. Log the miss honestly and leave the case unchanged.
- Name exact things: regex patterns, function signatures, model names, before → after numbers. Never "fixed bugs".
- Attribution: follow the project's `attribution` setting (default `none`) — no AI-tool mentions in generated docs, no attribution trailers in commits or PRs. Commit with explicit `-m`/`-F` messages only.
- Config: read `.claude/acstack.md` at the project root (fall back to `~/.claude/acstack.md`) before acting. `## Settings` keys override pack defaults; a `## <skill-name>` section overrides both. Unknown keys and sections are ignored.
- Docs: BRIEF.md (frozen seed) / PLAN.md (living plan) / JOURNAL.md (rolling journal). If the repo uses legacy names (PLANNING_PROMPT.md / PLANNING.md / STATUS.md), use those instead — never create both.
- Recall: if `LEARNINGS.md` exists at the project root, read it before starting.
- Conduct: follow the `acstack-conduct` block in this repo's AGENTS.md — the word is the mode; the user sets the pace.
<!-- /acstack:principles -->

## Target: code

Hunt defects in the named path, diff range, or PR. Consult
`references/known-bug-classes.md` — check every class that applies to the
stack. Report per `references/code-report-template.md`:

- **Lede** — the verdict with concrete evidence (a failing input, a number),
  never adjectives.
- **Numbered sections**, each stating the rejected alternative and why.
- **Defects** with root cause, exact `file:line`, and the input that fails.
- **`Safety checks:`** — the exact commands run and what they matched.
- **`## Verification`** — concrete inputs → observed outputs, including
  adversarial cases (garbage strings, oversized input, regex-special chars,
  out-of-range values, empty query).
- **`Known gap:`** — what was not verified and why.
- **Scope** — what was deliberately not touched.

/audit reports; it does not fix. If the user wants fixes, they say so, and
fixes land as separate, reviewable commits.

## Target: docs

Drift check — every claim a doc makes that reality can contradict:

- Project-structure blocks vs the actual tree (`ls`/glob against the ASCII
  tree line by line).
- Stale counts vs greppable reality: tool counts, test counts, table counts,
  record counts.
- Checkbox state, both directions: a `[x]` whose Acceptance command now
  fails, and a `[ ]` whose artifact plainly exists.
- File-location tables vs actual paths.
- Run the README quickstart where cheap; a broken quickstart is drift.

Output: a numbered list of `doc says / reality is / fix` triples. Nothing
else counts as a docs finding.

## Target: eval

Read the eval report or results file. Rules per
`references/eval-review-rules.md`:

- Every failure classified: prompt issue / grader brittleness / provider
  flake / data issue / parser issue / genuinely ambiguous.
- **The never-inflate rule is absolute:** never adjust a test case or its
  expected values to raise the score. `acceptable_failure` survives only
  with a written justification. A real miss is logged and left standing.
- Grader brittleness is distinct from subject failure and IS legitimately
  fixable (asserting the concept instead of the literal wording; Unicode
  normalization before substring compare). Fixing the grader is not
  inflation — but log which one you did.
- Verify the report's own arithmetic and that its headline number matches
  the raw results file.
