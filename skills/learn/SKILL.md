---
name: learn
description: Capture a lesson as a durable LEARNINGS.md entry - one-line lesson, symptom, cause, fix, context, and a seen-count; dedups against existing entries and proposes promoting recurring lessons into the pack's known-bug-classes. Use when the user says they learned something, wants to capture a lesson or gotcha, or when an investigation closes with a cause worth keeping.
argument-hint: "<lesson | notes>"
---

# /learn — one durable lesson at a time

The project's memory for things that bit once and will bite again.
/journal records what a session did; /learn records what a session
taught — small enough to capture in a minute, durable enough that a
future session avoids the same hole.

`Adjacent skills:` /journal (whole-session record; /learn one durable
lesson) · /investigate (its closed write-ups are /learn's best input) ·
/ticket (captures work to do; /learn captures knowledge learned).

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ -n "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; prints the pull command when behind
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + pack known-bug-classes, capped 6KB
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

## Capture

Shape the input into one LEARNINGS.md entry:

```markdown
### <one-line lesson> (YYYY-MM-DD)

- **Symptom:** <what was observed — exact error, exact wrong output>
- **Cause:** <the mechanism, at file:line when known>
- **Fix:** <what actually resolved it>
- **Context:** <project area, tech, file — when known>
- **Seen:** 1
```

If LEARNINGS.md doesn't exist, create it with this header, then append:

```markdown
# LEARNINGS

> Durable lessons from this project — symptom → cause → fix. Read by
> acstack skills at session start; grown by /learn.
```

What the input doesn't say and the repo can't cheaply tell you is marked
`TBD — needs <what>`, never invented (/ticket's rule). A lesson whose
cause is still a guess is captured with `- **Cause:** unconfirmed —
<hypothesis>` — honest uncertainty beats confident fiction, and
/investigate can firm it up later.

## Dedup before append

Scan LEARNINGS.md for an existing entry with the same cause. On a match,
propose bumping instead of duplicating: increment `**Seen:**`, append
`last seen YYYY-MM-DD`, and add any new context — the count is the
signal that makes promotion honest.

## Promotion

When an entry's `**Seen:**` reaches 2+, or the lesson is plainly
project-independent, propose promoting it into the pack's
`../audit/references/known-bug-classes.md`, outputting the exact
entry in that file's format:

```markdown
## <class name>

- **Symptom:** …
- **Cause:** …
- **Check:** <the grep or test that catches it early>
```

In the acstack repo itself the edit is applied on approval. In any other
project, the text is output for the user to carry over — the pack is
never edited silently from a project.

## Report and stop

Report the entry as written (or the bump applied) and the promotion
outcome if one was proposed. The entry rides the project's next commit
by default; a standalone `add learning (<slug>)` commit only on request.
Capturing a lesson never starts fixing anything (CONDUCT rule 5).
