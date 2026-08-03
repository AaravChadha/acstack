---
name: refactor
description: "Behavior-preserving cleanup with proof - the suite runs green BEFORE and green again AFTER with the same test count, because a suite that shrinks during a refactor is the finding, not a detail. Stops when the tree is dirty, the baseline is red, or the suite is too thin to detect a behavior change, naming what to test first. Use when the user asks to refactor, clean up, restructure, or simplify existing code without changing what it does."
argument-hint: "[path | symbol | notes]"
---

# /refactor — cleanup you can prove didn't change behavior

A refactor is the one change that promises nothing will be different. That
promise is worthless unsupported: the failure mode is not a dramatic break,
it is a small behavior change nobody notices for a month, or a test quietly
deleted because it went red.

So this skill treats the suite as the instrument and refuses to work with a
broken one. Green before, green after, **same test count** — a suite that
shrinks during a refactor is the headline finding, not a footnote.

`Adjacent skills:` /audit tests (tells you whether the green is worth
anything — run it first on a suite you don't trust) · /investigate (why is
it BROKEN; /refactor requires it already works) · /do (feature work; a
refactor changes no behavior).

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; prints the pull command when behind
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

## Preconditions — all three, before touching anything

1. **Clean tree.** Uncommitted changes make before/after unattributable:
   you cannot prove your refactor preserved behavior if something else was
   already in flight. Dirty → say so, name the files, stop.
2. **Green baseline, recorded.** Run the suite and record the **exact
   count** (`N passed, M skipped`). Red baseline → stop: preservation
   cannot be proven against a broken instrument, and "it was already
   failing" is how a real regression gets absorbed.
3. **A suite that could notice.** Ask whether these tests would fail if the
   target code changed behavior. If the answer is no — no tests cover the
   target, or only assertion-free ones do — **stop and name what to test
   first**. Refactoring under an instrument that cannot detect the failure
   is not a safe operation, it is an unobserved one. `/audit tests` is the
   full version of this question; run it when the suite is unfamiliar.

Stopping here is a success, not a failure to deliver: it converts an
invisible risk into a stated one.

## The sequence

1. **State the scope up front** — which files and which transformations
   (extract, inline, rename, dedupe, move), and explicitly what will NOT
   change. The scope is a commitment the report is checked against.
2. **Refactor** — behavior-preserving edits only, in small steps.
3. **Re-run the suite.** Compare against the recorded baseline:
   - **Still green, same count** → the promise held. Report the numbers.
   - **Red** → the refactor changed behavior. Fix the code, never the test.
   - **Count DROPPED** → the headline finding. A test was deleted,
     renamed out of collection, or skipped. Report which, and restore it.
   - **Count ROSE** → say so and why. A refactor that adds tests is not
     wrong, but it is no longer only a refactor, and unremarked growth
     hides a swap (one deleted, one added, count unchanged is the case
     the count alone misses — compare NAMES, not just totals).
4. **Report with before → after numbers**, never adjectives: the baseline
   count, the final count, the files touched, and the scope you committed
   to at step 1.

## Hard rules

- **Never delete, skip, weaken, or rewrite a test to make the suite
  green.** This is the never-inflate rule pointed at refactoring: a test
  going red during a refactor is the instrument working. Changing it to
  pass converts a caught regression into a shipped one.
- **No behavior changes smuggled in.** A bug found mid-refactor is
  reported, not fixed in the same pass — fixing it changes behavior, which
  is exactly what this pass promised not to do. Propose it as separate
  work.
- **No opportunistic scope.** Adjacent code that is also ugly stays ugly
  unless it was in the stated scope. Reviewers cannot verify a diff whose
  boundary moved during the work.
- **Compare test NAMES, not just counts,** when the count is unchanged but
  the suite was touched — equal totals hide a one-for-one swap.
- **The proof is the numbers.** "Tests still pass" is not a report;
  `88 passed, 4 skipped → 88 passed, 4 skipped` is.
