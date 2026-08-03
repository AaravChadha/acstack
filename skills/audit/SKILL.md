---
name: audit
description: Audit one of four targets. code - defect hunt producing a report with safety checks and adversarial verification evidence; docs - drift check of README/PLAN/JOURNAL against the actual tree, counts, and checkbox reality; eval - failure classification with the never-inflate rule; tests - finds tests that pass without catching, including a mutation spot-check. Use when the user asks to audit or review code, a PR, project docs, an eval report, or a test suite.
argument-hint: "code|docs|eval|tests [path | PR# | diff range]"
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git diff:*), Bash(git check-ignore:*), Bash(ls:*), Bash(grep:*), Bash(wc:*), Bash(gh pr view:*), Bash(gh pr diff:*)
---

# /audit — find what's wrong and report it honestly

Three targets, one stance: verdicts backed by evidence, misses logged rather
than massaged, and scope stated so the reader knows what was NOT checked.

`Adjacent skills:` /secure (security-only findings with exploit scenarios) ·
/qa (probes the running system; /audit reads code and docs) · /investigate
(root-causes one failure; /audit sweeps for many).

<!-- acstack:runtime -->
Run before the skill's steps — per invocation, not per session (4.36); failures degrade to markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; silent ONLY if already checked today
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + bug-class names, capped 3KB
else
  echo "runtime off — proceeding without recall/update-check"
fi
```
<!-- /acstack:runtime -->

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

**One document set.** Resolve exactly ONE BRIEF/PLAN/JOURNAL set and name
its path in the report's scope line. If more than one candidate set exists
— a monorepo, nested products, an `apps/*` tree each with its own docs —
list the candidates and STOP. Never pick one silently: a confident answer
about the wrong product is worse than no answer (conduct rule 8).

## Target: code

**First: does this target need the pass at all?** A diff that only moves
files, bumps a version, or changes generated output has nothing to audit —
say so in one line and stop. A review that manufactures findings because it
was invoked is worse than no review: it spends the reader's attention on
noise and trains them to skim the next one.

Hunt defects in the named path, diff range, or PR. Consult
`references/known-bug-classes.md` — check every class that applies to the
stack. **Check the do-not-flag list in
`references/code-report-template.md` before writing any finding.** Report
per that template:

- **Lede** — the verdict with concrete evidence (a failing input, a number),
  never adjectives.
- **Numbered sections**, each stating the rejected alternative and why.
- **Defects** with root cause, exact `file:line`, and the input that fails.
- **`Safety checks:`** — the exact commands run and what they matched.
- **`## Verification`** — concrete inputs → observed outputs, including
  adversarial cases from the canonical bank in
  `../qa/references/adversarial-inputs.md` (garbage strings, oversized
  input, regex-special chars, out-of-range values, empty query).
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
  fails, and a subtask `[ ]` whose artifact plainly exists. A phase heading
  `## [ ]` held open while its `**Exit criterion:**` is unmet is /do's gate,
  not drift — flag it only when the flip condition is met (the criterion
  passes, or none is declared and every child is checked).
- File-location tables vs actual paths.
- Run the README quickstart where cheap; a broken quickstart is drift.

Output: a verdict first — `NO DRIFT` or `<N> drift findings` — then a
numbered list of `doc says / reality is / fix` triples. Nothing else
counts as a docs finding. Close with scope: which documents and which
claims were checked, and which were too expensive to verify.

## Target: eval

Read the eval report or results file. **No results file → say so and
stop**; there is nothing to audit and a report written from the spec
alone would be fiction.

Output opens with the verdict — `headline verified` or
`<N> findings (headline overstated by <x>)` — then the evidence below,
and closes with scope (which cases were reviewed, which were not). Rules
per `references/eval-review-rules.md`:

- Every failure classified: prompt issue / grader brittleness / provider
  flake / data issue / parser issue / genuinely ambiguous.
- **The never-inflate rule is absolute:** never adjust a test case or its
  expected values to raise the score. `acceptable_failure` survives only
  with a written justification. A real miss is logged and left standing.
- Grader brittleness is distinct from subject failure and its remedy IS
  legitimate (asserting the concept instead of the literal wording;
  Unicode normalization before substring compare). Recommending a grader
  fix is not inflation — but the report says which remedy it recommends
  and why. /audit still does not apply it.
- Verify the report's own arithmetic and that its headline number matches
  the raw results file.

## Target: tests

A green suite is evidence only if its tests could have failed. This target
sweeps an existing suite for tests that pass without catching anything —
the never-inflate rule pointed at tests instead of eval scores.

**No test suite found → say so and stop.** A test audit written from the
source alone would be fiction, the same way an eval audit without a results
file would be.

Output opens with the verdict — `suite has teeth` or `<N> findings` — then
the evidence, then scope (which files were swept, which were not, and
whether the mutation spot-check ran). Rules and detection commands live in
`references/test-audit-rules.md`; the five classes are assertion-free
tests, tautological assertions, mocks stubbing the unit under test, unread
snapshots plus accumulating skips, and the mutation spot-check.

The spot-check is the only one that proves rather than suggests: break the
production code deliberately and confirm the suite goes red. A mutation
that leaves it green is a confirmed coverage hole. **Revert every mutation
before reporting, say that you did, and verify it** — a mutation left
behind is a defect this audit introduced. Never mutate a tree that was
already dirty; you could not prove a clean revert.

Nothing here is fixed: a bad test is reported and left standing, because
deleting it hides the coverage gap it was proving.
