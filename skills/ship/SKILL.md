---
name: ship
description: Branch-level release with five gates before the act - clean-state, tests, eval-vs-target, docs drift, and attribution sweep; any failing gate stops the release with its output. Then push and open a report-shaped PR, wiring Fixes #N in tickets mode or PLAN task IDs in document mode. Use when the user asks to ship, release, cut, or open the PR for a feature or branch.
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

## The five gates

Run in order; each reports before the act. Any gate that fails STOPS the
release with its evidence — the user decides what to fix. Exact commands
and the PR body template live in `references/ship-gates.md`.

1. **State.** Working tree clean; current branch is not the default (on
   default → offer to cut `<branch-prefix><slug>`, don't ship from it);
   the branch is ahead of the default by the commits being shipped.
2. **Tests.** Run the project's suite if one exists (detected, or named
   in config); record the summary numbers verbatim. No suite → say so
   plainly; a missing suite is never a silent pass.
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

Only when all five pass. Push per `push` config, then `gh pr create`
with a report-shaped body: what-and-why lede, a per-gate evidence table
(the test/eval numbers, the doc checks), and an out-of-scope line.

- **Tickets mode:** the PR carries `Fixes #N` for each issue the branch
  completes (from the commits' `#N` refs and the milestone) and is tied
  to that milestone. Preconditions per the pack rule (gh, auth, remote).
- **Document mode:** the body names the PLAN task IDs shipped; a phase
  exit criterion that passed in gate 4 is ticked per /do's convention.

Report ends with the PR URL and one line per gate. /ship opens the PR;
it never merges — the merge is a human act.
