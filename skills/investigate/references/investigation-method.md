# Investigation method — hypotheses, evidence, and when to stop

## What counts as a discriminating test

A test discriminates when its two possible outcomes point at different
hypotheses. "Add a print statement and look around" is not discriminating;
"if the row count after the join is 0, the filter ate it; if it's 40, the
writer dropped it" is. Before running anything, write down what each
outcome would mean. If both outcomes leave you believing the same thing,
the test is theater.

Cheap discriminating tests, in rough order of preference:

- Feed the failing input to the suspect component in isolation.
- Bisect the pipeline: check the data at the midpoint, then halve again.
- Diff a working case against the failing case and shrink the diff until
  one difference remains.
- `git bisect` when the failure is new and the history is runnable.
- Read the exact library version's source for the call in question —
  documented behavior and actual behavior diverge more often than assumed.

## The table

| Hypothesis | Evidence that would confirm / kill | Test performed | Result |
|---|---|---|---|
| Filter drops rows with NULL region | 0 rows post-filter for NULL-region input / same count | Ran query with filter removed | 40 rows — killed |

Rules:

- One row per hypothesis, stated as a mechanism ("X does Y to Z"), not a
  vibe ("something with the filter").
- The evidence column is filled in BEFORE the test is run.
- Killed hypotheses stay in the table with their evidence — they are the
  proof the surviving hypothesis earned its place.

## Correlation vs cause

The root-cause statement must answer: why does this mechanism produce
EXACTLY this symptom — this error text, this input, this frequency? A
candidate that explains "a" failure but not "this" failure is a nearby
correlation. The classic tells: the fix that works but you don't know why,
the bug that "went away", the change that fixes the test but not the repro.

## Repro discipline

- Minimal: strip the repro until removing anything makes the failure stop.
  What remains is a map of the cause's dependencies.
- On demand: a failure that reproduces "sometimes" isn't reproduced yet —
  find the missing condition (ordering, timing, state left by a prior run,
  specific data) before hypothesizing.
- Recorded: the repro command goes in the write-up verbatim, so the fix's
  verification is "run the repro, watch it pass".

## The three-strikes write-up

After the third failed fix attempt, produce this and stop:

```markdown
### Investigation halted after 3 attempts — <symptom, one line>
**Repro:** <exact command> → <exact failure output>
**Dead hypotheses:**
1. <hypothesis> — killed by <evidence> (attempt: <what was tried>)
2. …
3. …
**Untested:** <hypotheses that still lack a discriminating test, and what
each test would need>
**State restored:** <confirmation the three failed fixes were reverted>
```

Document mode: this block goes into JOURNAL.md under today's entry.
Tickets mode: it goes to the issue as a comment. Either way the user
decides what happens next — more time, a different angle, or deliberate
deferral with the write-up as the breadcrumb.

Failed fixes are REVERTED before the write-up. Three dead guesses layered
into the working tree is how one bug becomes three.
