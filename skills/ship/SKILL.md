---
name: ship
description: "Branch-level release with five gates before the act - clean-state, tests, eval-vs-target, docs drift, and attribution sweep; any failing gate stops the release with its output. Then push, and under push: branch-pr open a report-shaped PR wiring the issue-closing reference in tickets mode or PLAN task IDs in document mode. Use when the user asks to ship, release, cut, or open the PR for a feature or branch."
argument-hint: "[branch | notes]"
---

# /ship — release a feature, gate by gate

/do ships one subtask; /ship ships a feature branch — the accumulated
commits, checked as a set. The value is the gates: "ready to merge"
usually rests on things nobody re-verified, and /ship verifies each one
before anything outward-facing happens. There is no force path — a
failing gate stops the release and hands the output to the user.

`Adjacent skills:` /do (ships one subtask; /ship releases a branch) ·
/audit code (review for defects; /ship runs release gates, not a code
read) · /qa and /secure (called before shipping when the change warrants
it; /ship does not re-run them).

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

## The five gates

Run in order; each reports before the act. Any gate that fails STOPS the
release with its evidence — the user decides what to fix. Exact commands
and the PR body template live in `references/ship-gates.md`.

**One documented exception:** gate 4's journal-mention check *proposes*
`/journal` rather than blocking. It matches commit subjects verbatim
against JOURNAL.md, and journals rarely quote subjects, so it is
near-always negative even for well-journaled work — a check that weak
must not hold a release. Every other gate blocks. The exception is named
here so the rule stays true everywhere else.

1. **State.** Working tree clean; current branch is not the default (on
   default → offer to cut `<branch-prefix><slug>`, don't ship from it);
   the branch is ahead of the default by the commits being shipped.
2. **Tests.** Run the project's suite — the `test-command` config key if
   set, otherwise auto-detected — and record the summary numbers verbatim.
   No suite and no `test-command` → say so plainly; a missing suite is
   never a silent pass.
3. **Eval.** If `eval/spec.md` exists, run the eval by its own run
   command and compare headline vs target. Below target BLOCKS the ship
   (this is what makes "the eval is the spec" bite at release time). No
   eval → one honest line, gate passes.
4. **Docs.** Cheap drift pass, not a full audit: README quickstart still
   true; the shipped work's PLAN exit criterion run if runnable; JOURNAL
   mentions the work (if not → propose /journal before shipping). Deep
   drift stays /audit docs.
5. **Attribution.** Sweep the branch's commit messages and the intended
   PR body per the `attribution` config — default `none` means any AI
   trailer or tool mention fails the gate, listing the offenders.

## The act

Only when all five pass. Push per `push` config. **Whether a PR follows
depends on that config** — everything below about PR bodies applies only
under `push: branch-pr`.

**Under `push: direct` there is no PR to open.** Say so plainly, push the
branch, and report the gate evidence as the release record — do not
invent a PR step the config disabled. If the user wants a PR anyway,
they ask; `/ship` never flips the config on their behalf. **`gh` is
required only where a PR is actually opened** — that is `push:
branch-pr`, and tickets mode's issue-closing links. Under `push:
direct` a missing `gh` blocks nothing: check the precondition where it
applies, and on failure name which one failed and stop with the branch
pushed.

Under `push: branch-pr`, the PR body is report-shaped: what-and-why lede,
a per-gate evidence table (the test/eval numbers, the doc checks), and an
out-of-scope line. Under `push: direct` the same content is delivered as
the report itself, since there is no PR to carry it.

- **Tickets mode:** the PR carries `Fixes #N` for each issue the branch
  completes (from the commits' `#N` refs and the milestone) and is tied
  to that milestone. Preconditions as above, plus a GitHub remote.
- **Document mode:** the body names the PLAN task IDs shipped; a phase
  exit criterion that passed in gate 4 is ticked per /do's convention —
  committed to the branch (`completed <phase> exit criterion`) BEFORE the
  push, so the tick ships with the work and gate 1's clean-tree assertion
  stays honest. No orphan post-push edit.

**The report's first line is the verdict** — `SHIPPED — <PR url>`,
`BLOCKED at gate <n> — <reason>`, or `PUSHED (no PR — push: direct)` —
then one line per gate as its evidence. A reader who stops after one
line must still know whether the release happened. /ship opens the PR;
it never merges — the merge is a human act.
