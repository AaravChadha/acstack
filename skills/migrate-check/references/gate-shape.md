# The gate shape — canonical

> **What this file is.** The report anatomy every acstack gate shares.
> `/migrate-check` originated it and keeps it here; every other gate cites
> this file rather than restating it (wave-5 specs, per 4.17 sub-guard 4 —
> convert duplicates to citations, never copies). `/contract-check` cites it
> today; wave 5's remaining gates enrol as they land, each adding its own
> citation in its own commit — a skill cannot cite one that does not exist
> yet, which check.sh §8 enforces. If you are changing the shape, change it
> here and nowhere else.

A gate answers one question: **may this change proceed?** It is read-only, it
classifies every change it was given, and it ends in a written verdict. It
never fixes anything.

## 1. Verdict first

Line one is `GO` or `NO-GO`, then the evidence. A reader who stops after one
line must not be misled by what they missed. Never bury the verdict under
the analysis that produced it.

**Literally the first line — no preamble.** Not "analysis complete, here is
the verdict", not a restatement of what was asked, not a separator. The
first characters of the report are the verdict token. Observed 2026-08-17:
two live runs of the same gate on the same diff, one opening `**NO-GO** —`
and the other opening *"GO/NO-GO analysis complete. Here is the verdict."*
with the verdict four lines down. Both reached the right answer; only one
was readable by someone who stopped after a line.

`NO-GO` is not a refusal to help — it is a finding, and it is only useful
with the next two sections attached.

## 2. Classify every change, including the safe ones

One row per change, **additive** or **destructive**, with nothing omitted.
A report listing only the problems cannot be checked for completeness: a
reader has no way to tell a change that passed from a change that was never
looked at.

- **additive** — existing callers keep working untouched.
- **destructive** — some existing caller breaks, or some existing data or
  history becomes unreachable.

When a change's class depends on a fact you do not have, say which fact and
classify it destructive until told otherwise. A gate that guesses optimistically
is worse than no gate, because it converts an unknown into a false assurance.

## 3. A safe alternative for every destructive row

A gate that only says no is a blocker, not a tool. Each destructive row
carries the cheapest way to get the same outcome without the break — the
add-new-then-deprecate pattern in most cases:

| Instead of | Do |
|---|---|
| renaming or removing a thing callers use | add the new one, deprecate the old, remove in a later major |
| tightening what is accepted | accept both, warn on the old form |
| dropping something callers read | add the replacement first, mark the old optional, drop later |

If no safe alternative exists, say that explicitly. "There is no
non-breaking way to do this" is a legitimate and useful finding; silence in
that column reads as an oversight.

## 4. Never fixes

Gates block and explain. They do not edit the change under review, and they
do not edit the thing that would make the verdict pass. The operator decides;
the gate supplies the basis for deciding.

## 5. State what the verdict does not cover

Every gate has an edge it cannot see — a caller outside this repo, a runtime
consumer no static read reaches, a config a deployment overrides. Name it in
the report. A `GO` that silently means "GO as far as I could see" is the
overclaim the pack refuses everywhere else.
