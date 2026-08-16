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

## The Iron Law

No fix is written until the investigation names a root cause backed by
discriminating evidence. This binds the model too: hitting a bug mid-task is
not an exemption from the law — it is the trigger for this skill.

## The investigation

**The verdict leads the report.** Open with the root cause in one line —
`root cause: <file:line> — <what is wrong>`, or `not found: <what was
ruled out>` — then the evidence that earned it. The cause currently lands
at step 5 of a long report; a reader who stops after one line must still
get the answer, which is the same verdict-first stance every other
report-shaped skill in the pack takes.

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

   **Naming a class requires having read it.** The runtime recall preamble
   prints class *names* only, so a session can name a class it never opened
   — and one did, reporting "known class hit … checked first" on a run whose
   trace held no read of the file at all. Say which you did, in these words:

   - read the class → cite it, `known-bug-classes.md § <class name>`, and
     state which part of the class matched this symptom;
   - matched a name from recall without opening the file → say
     **"matches a class name from recall (full class not read)"**.

   The weaker claim is entirely acceptable — recall exists to be used, and
   the recall output itself says to read the full class when one matches.
   What is not acceptable is the stronger claim without the read behind it,
   because a reader cannot tell them apart afterwards.
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

**Invoked with no `issue#`, the offer still has to resolve to something.**
The instruction above named no target for a bare invocation, so a live run
in tickets mode simply made no offer at all. Do one of two things, and say
which:

- an open issue plainly describes this failure → name it and offer the
  comment against it, still unposted;
- none does → say so in one line — "no issue matches this failure; filing
  one is `/ticket`'s job" — and stop there. Do not open an issue to have
  somewhere to put the comment.

## Hard rules

- Every applied fix traces back to a row of the hypotheses table. No
  shotgun fixes, no "while I'm here" changes.
- Error text is quoted verbatim, always — paraphrases hide the clue.
- An investigation that overturns a plan assumption records it in PLAN.md
  as a dated decision (supersede, never silently edit).
- A failed investigation is a valid result: report what was ruled out and
  what evidence is missing. That is progress; a premature fix is not.
