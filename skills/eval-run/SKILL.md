---
name: eval-run
description: "Execute a project's eval and produce a results file - locate the golden set, scaffold a runner for the project's stack when none exists, grade every case by its own rule, and write per-case results plus a headline computed from that file. Reports verdict-first against the spec's target and never edits a golden case to raise a score. Use when the user asks to run the eval, score the golden set, or produce eval results."
argument-hint: "[eval-dir | notes]"
---

# /eval-run — execute the eval, honestly

`/eval-spec` writes the target before the code exists; `/audit eval`
reviews results after; `/ship`'s gate 3 compares a headline to a target.
All three assumed a runner nobody produced. This skill is that runner —
the step that turns "the eval is the spec" from a claim into a loop.

Running an eval **costs money and time** when the system under test
calls a model API. State the case count and that cost before executing,
then run — the user asked for a run, so this is not a permission
request (conduct rule 5), it is a disclosure.

`Adjacent skills:` /eval-spec (writes the spec and golden set before any
code; /eval-run executes it) · /audit eval (audits the results this
produces, including recomputing the headline) · /ship (gate 3 compares
this headline against the spec's target).

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

## The sequence

1. **Locate the eval.** `eval/spec.md` and `eval/golden.jsonl` (or the
   directory named in the argument). Either missing → say WHICH is
   missing, point at `/eval-spec`, and stop. Never scaffold a golden
   set here; writing the target is a deliberate act that belongs to
   /eval-spec, and inventing cases at run time is the never-inflate
   rule's exact failure mode.
2. **Prefer the runner that exists.** If `spec.md`'s run command names a
   runner present in the repo, run THAT and skip step 3 — an existing
   eval artifact is never regenerated (/eval-spec's step-0 rule).
3. **Scaffold only when there is none.** Detect the stack:
   `package.json` → `eval/run.mjs`; `pyproject.toml` or
   `requirements.txt` → `eval/run.py`; neither, or both → **stop and
   ask**. Never guess a stack. Build from
   `references/runner-template.md`.

   **A run command in the spec settles the stack — it is not a guess.** If
   `spec.md` names `eval/run.py`, the language is already decided by the
   committed spec, and stopping to ask which stack to use is a deadlock over
   a question already answered. Take the extension from the spec's run
   command and say that is where it came from. Only a spec that names no
   runner leaves the question genuinely open.

   The runner needs one fact the spec often lacks: **how to invoke the
   system under test** — a CLI command, an HTTP endpoint, or a function
   import. If `spec.md` does not say, ask, then record the answer in
   spec.md's run section as a dated addition (that file is living; the
   golden set is not).
4. **Run it, then read the file.** The runner writes
   `eval/results/<UTC-timestamp>.jsonl`. The headline is computed from
   that file — overall %, per-category %, refusal % — and never
   assembled by hand from what the run appeared to do. If the two ever
   disagree, the file wins and the discrepancy is the finding.
5. **Report** (shape below). Propose PLAN edits; apply none.

## Grading rules

Per case, from its `grade_rule`, aligned with the canonical grader rules
in `../eval-spec/references/grader-rules.md` and with `/audit eval`:

- `exact` — normalized equality: trim, collapse whitespace, NFKC, and
  fold case. Same answer, not same keystrokes.
- `concept` — the expected concept is present. The scaffold implements
  this as normalized substring containment, which is the FLOOR, not the
  ideal: it is literal enough to produce brittleness. When a case fails
  here and the answer was right, widen the grader — never touch the
  case (/audit eval's "grader brittleness" bucket).
- `numeric-tolerance:<x>` — parse both sides, compare within ±x
  absolute, or ±x% relative to the expected value when the suffix is
  `%` (both forms are documented by /eval-spec's template).
- `rubric:<name>` — not machine-gradeable. The runner records the
  answer, marks the case `needs-rubric-review`, and **excludes it from
  the headline while naming it**. A human or a judge model scores the
  rubric's named dimensions; a rubric with unnamed dimensions is a spec
  defect, not a pass.

Denominator discipline, because a headline is only as honest as what it
counts: cases marked `"status": "needs-data"` are **skipped and reported
as skipped**, never counted as passes; `"status": "superseded"` cases
are excluded entirely; `rubric:` cases are excluded from the headline
because no machine graded them, and are reported for review;
`acceptable_failure` applies only when the case carries a written
`reason` (in either shape it is written — a bool with a sibling
`reason`, or an object), never to an ungraded case, and every
application is listed.

**Every exclusion is named in the report.** A case that leaves the
denominator quietly moves no percentage at all, so it cannot be caught
by looking at the number — which makes silent exclusion the most
dangerous of the false-pass family.

## Hard rules

- **Never edit `golden.jsonl` to raise a score.** A genuinely wrong case
  is superseded through /eval-spec, with a new id and a written reason.
  Editing a case to pass is the one thing this pack refuses outright.
- **Never hand-transcribe the headline.** It comes from the results
  file, every time.
- A run that errors part-way reports what completed and what did not —
  a partial run is never presented as a full score.
- The results file is committed with the run: an eval score whose
  evidence is not in the repo is an assertion.

## Report shape

Verdict first — `<headline>% vs target <n>%` plus `MEETS TARGET` or
`BELOW TARGET by <x>` — then:

- per-category table (category | cases | passed | % | target)
- failures, grouped by the /audit eval buckets (prompt issue, grader
  brittleness, provider flake, data issue, parser issue, genuinely
  ambiguous) — classification proposed, since confirming it is /audit's
  job
- `acceptable_failure` applications, each with its reason
- skipped cases and why
- the results file path, and the exact command that produced it
- **Scope:** what was NOT run (needs-data cases, categories with no
  cases, an unreachable system under test)

## Positive control

A golden set containing one deliberately failing case MUST produce a
sub-100% headline. A runner that reports 100% by construction — because
it counts skips as passes, swallows errors, or compares nothing — is
the false-pass class this pack exists to catch, and it is indetectable
from a green report. `fixtures/eval-run/` seeds exactly that case.
