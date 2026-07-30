---
name: investigate
description: Root-cause a failure before any fix - the iron law is no fixes without investigation. Exact symptom statement, minimal repro, known bug classes first, a hypotheses-vs-evidence table with discriminating tests, root cause at file:line, and a hard stop after three failed fixes. Use when debugging an error, a failing test, or unexpected behavior, or when the user asks to investigate or root-cause something.
argument-hint: "<symptom | issue#>"
---

# /investigate — no fixes without investigation

You are finding out why, not making it go away. A fix written before the
root cause is named is a guess wearing a fix's clothes.

`Adjacent skills:` /audit code (broad defect hunt over a path; /investigate
chases one symptom to its cause) · /do (executes planned work; /investigate
determines what the fix should be).

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

## The Iron Law

No fix is written until the investigation names a root cause backed by
discriminating evidence. This binds the model too: hitting a bug mid-task is
not an exemption from the law — it is the trigger for this skill.

## The investigation

Method details in `references/investigation-method.md`. The sequence:

1. **Symptom statement.** Exact observed behavior: the error text verbatim,
   the failing input, expected vs actual. "It's broken" is not a symptom;
   neither is a paraphrased error message.
2. **Reproduce first.** A minimal command that shows the failure on demand.
   Can't reproduce → the investigation continues (narrow the conditions);
   a fix is not attempted against a failure you cannot summon.
3. **Known classes first.** Check the pack's
   `../audit/references/known-bug-classes.md` and the project's
   LEARNINGS.md before inventing hypotheses — most bugs are reruns.
4. **Hypotheses vs evidence.** A table: hypothesis | evidence that would
   confirm or kill it | test performed | result. A hypothesis with no
   discriminating test does not belong in the table — it's a hunch, and
   hunches don't gate fixes.
5. **Root cause.** `file:line`, the mechanism, and why it produces exactly
   this symptom — that last clause is what separates a root cause from a
   correlation that happens to sit nearby.
6. **Proposed fix + verification.** The fix, the command that proves it
   worked, and the regression risk. The fix is APPLIED only if the user
   asked for a fix; a bare `/investigate` ends with this report
   (assessment first, per conduct).

## Three strikes

After 3 failed fix attempts: STOP. Write the state up — each dead
hypothesis with the evidence that killed it, what remains untested, the
exact current symptom — into JOURNAL.md (document mode) or an issue comment
(tickets mode), and hand it to the user. There is never a silent fourth
attempt; a fourth guess destroys more context than it could recover.

## Tickets mode (`tracking: tickets`)

Preconditions — `gh` installed, `gh auth status` succeeding, and a GitHub
remote present. Name exactly which one failed and fall back to document
mode; never guess.
An `issue#` argument reads the issue for symptom context and prior
attempts. Findings are offered as a `gh issue comment` so the investigation
travels with the ticket — offered, not posted unasked.

## Hard rules

- Every applied fix traces back to a row of the hypotheses table. No
  shotgun fixes, no "while I'm here" changes.
- Error text is quoted verbatim, always — paraphrases hide the clue.
- An investigation that overturns a plan assumption records it in PLAN.md
  as a dated decision (supersede, never silently edit).
- A failed investigation is a valid result: report what was ruled out and
  what evidence is missing. That is progress; a premature fix is not.
