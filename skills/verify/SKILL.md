---
name: verify
description: Audit a completion claim made by someone else - another session, agent, or teammate - against the running system rather than the diff. Re-derives what the claim's acceptance demands, runs it, and returns CONFIRMED, OVERSTATED, FALSE or UNVERIFIABLE with the command and its output. Never fixes, never edits the claim or the acceptance. Use when handed a "done", "all green", "merged" or "it works" you did not produce yourself.
argument-hint: "<the claim, or a path/PR carrying it>"
---

# /verify — audit someone else's claim against the running system

A claim is not evidence. `/verify` takes a completion claim you did **not**
produce — from another session, another agent, a teammate, a PR body — and
tests it against the system as it actually runs.

`Adjacent skills:` /do (runs acceptance before ticking its OWN box; /verify
audits a box someone else ticked) · /ship (five gates on your own branch) ·
/triage (sweeps checked boxes that now fail) · /audit code (hunts defects in
code; /verify tests one stated claim).

**The angle is the whole point.** `/do` already runs acceptance before
ticking, `/ship` has five gates, `/triage` catches boxes that now fail. Those
all audit *your own* work as you do it. The gap this fills is the claim that
arrived from **outside** — where nobody in this session watched the command
run. Do not re-cover the neighbours; if the claim is your own work from this
session, say so and point at `/do` or `/ship`.

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

## What it may and may not touch

`/verify` runs the project's own acceptance commands, so it is **not** in the
read-only set: those commands write caches, temp files and test databases.
Its constraint is its own and is stated rather than inherited:

- It **never edits the project**, the claim, or the acceptance it is auditing.
- It **never fixes** what it finds. A failing acceptance is the finding.
- It **never rewrites an acceptance to make it pass** — the pack's
  never-tune-a-test rule, applied to someone else's test.

## The sequence

1. **Restate the claim as a testable proposition, and show the restatement.**
   "Auth is done" is not testable; "every unauthenticated request to
   `/api/*` returns 401" is. The restatement is the first thing the report
   shows, because **the verdict is only as good as the reading** — and a
   verdict on a misread claim is worse than no verdict. If the claimant is
   available and the restatement is a guess, say it is a guess.
2. **Find the acceptance the claim names.** A PLAN task's
   `**Acceptance:**` line, an issue's acceptance section, a PR body's stated
   check. **Run the one the claim names, never one you invent** — inventing
   a kinder acceptance manufactures a CONFIRMED, and inventing a harsher one
   manufactures a FALSE.
3. **Run it against the running system**, and paste the command and its
   output verbatim. Reading the diff cannot produce any of these verdicts;
   that is `/audit code`'s job, not this one.
4. **Check your own reading before reporting.** Ask what would make this
   verdict wrong, and look for that. Two failure modes, both seen live:
   a match that is an *example* rather than an instance (a marker quoted in
   prose, a pattern inside a code fence), and a difference that is your
   misreading of the claim rather than a defect in the work.
5. **Report the verdict first**, then the evidence that earned it.

## The four verdicts

Every input lands on exactly one. A class that fits none is the defect this
enumeration exists to avoid — `/migrate-check` shipped with a Flagged class
matching neither of its two verdicts, found by review on 2026-09-17.

| Verdict | When | Requires |
|---|---|---|
| **CONFIRMED** | The named acceptance ran and passed | The command and its output, pasted. "It looks right" is not this verdict |
| **OVERSTATED** | True in part | The clause that passed **and** the clause that failed, named separately |
| **FALSE** | The named acceptance does not hold | The command run and the output observed — never an inference from reading |
| **UNVERIFIABLE** | No acceptance is named, or the system cannot be run here | What is missing and what would make it verifiable. This is a refusal, not a pass |

**UNVERIFIABLE is not a soft FALSE.** A claim nobody wrote an acceptance for
is a finding about the *claim*, and reporting FALSE would assert something
about the system that was never tested.

## Report shape

Verdict on the first line. Then: the claim as given, the restatement, the
acceptance as found (with its `file:line`), the command, its verbatim
output, and a closing scope line — what this establishes and what it does
not. A verdict with no pasted output is not a verdict.

Full report template and the worked verdicts:
`references/verdict-shapes.md`.

## Hard rules

- **One claim per invocation.** Several claims are several verdicts, and
  merging them hides which one failed.
- **Never fix, never edit, never re-run a failing acceptance "differently"**
  until it passes.
- **Paste, never summarise, the output.** A paraphrased failure is an
  assertion about a failure.
- If the claim is your own work from this session, stop and say so — that is
  `/do`'s job before ticking, or `/ship`'s before releasing.
