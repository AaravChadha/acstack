# Verdict shapes — the report template and four worked examples

## Template

~~~markdown
**Verdict: <CONFIRMED | OVERSTATED | FALSE | UNVERIFIABLE>**

**Claim as given:** <quoted verbatim, with its source - PR #N, a session
message, a ticked box at file:line>

**Restated as testable:** <the proposition that must hold>
<if this is a guess because the claimant is unavailable, say so here>

**Acceptance found:** <file:line, quoted> - or *none found*, which is the
UNVERIFIABLE case.

**Ran against:** <branch> @ <short SHA> - and whether that is the claim's
own revision. A verdict that does not say which tree it ran on is not a
verdict.

**Command run:**
```
$ <exact command>
<verbatim output, not summarised>
exit=<status>
```

**The exit status is not optional.** For a test runner, a linter or a
`grep`, success is carried by the status and the output may be empty, or
identical on pass and fail. A CONFIRMED that pastes only stdout has not
preserved the evidence that the command passed. Record it for every verdict,
and say so explicitly when a command could not execute at all — that is
UNVERIFIABLE, not FALSE.

**What this establishes:** <the narrow thing the output proves>
**What it does not:** <the adjacent things a reader might assume>
~~~

**The outer fence is ~~~ on purpose.** The template contains a fenced
block, and an inner ``` closes an outer ``` at the first match - which is how
the first version of this file rendered inside-out, dropping its central
field entirely. The pack's own rule is to verify the *consumed* form; a
template that only reads correctly in the source is not a template.

The last two lines are not padding. A passing command proves one
proposition; the reader will generalise unless told where the edge is.

## Worked: CONFIRMED

> **Claim:** "1.1 is done - counting works."

Restated: `wc.py count "a b c"` prints `3`, which is what task 1.1's own
acceptance line demands.

Acceptance found at `fixtures/verify/PLAN.md:12-13` - the claimant's, not one
invented here.

Ran against: `feature/5.4-verify` @ `9fac6a3`, tree clean
(`git status --porcelain` empty) — the revision the claim was made about.

```
$ python3 wc.py count "a b c"
3
exit=0
```

**Establishes:** the acceptance PLAN.md names for 1.1 holds on this tree.
**Does not establish:** that `count` is correct for any other input - this
acceptance tests exactly one string - nor anything about tasks 1.2 or 1.3.

*(Pasted from a real run in `fixtures/verify/`. An earlier version of this
example showed a `SUM=... declared=...` line that `guard-matrix.sh` never
emits - it came from a shell wrapper around the tool, not from the tool.
Composed output in the exemplar for a skill whose hard rule is "paste, never
summarise" is the defect this footnote exists to stop recurring.)*

## Worked: OVERSTATED

> **Claim:** "Phase 1 is done. Counting handles contractions and longest works."

Restated, three clauses, each with an acceptance already written:
1. *Phase 1 is done* - all of 1.1, 1.2 and 1.3 pass.
2. *Counting handles contractions* - task 1.2.
3. *longest works* - task 1.3.

Acceptance found at `fixtures/verify/PLAN.md:12-17` - one `**Acceptance:**` line
per subtask. **Every clause gets its own run.** An OVERSTATED verdict
asserted from reading, rather than from running each clause, is the failure
this example exists to prevent: it would be a verdict with no pasted output,
which the hard rules forbid.

Ran against: `feature/5.4-verify` @ `9fac6a3`, tree clean
(`git status --porcelain` empty).

```
$ python3 wc.py count "a b c"
3
exit=0
$ python3 wc.py count "don't stop"
2
exit=0
$ python3 wc.py longest "a bb ccc"
a
exit=0
```

**The clause that passed:** "Counting handles contractions." 1.2 demanded
`2` and printed `2`. 1.1 also passed: demanded `3`, printed `3`.

**The clause that failed:** "longest works." 1.3 demanded `ccc` and printed
`a`. Because 1.3 fails, clause 1 - "Phase 1 is done" - fails with it,
notwithstanding the ticked `[x]` box on that task.

**OVERSTATED, not FALSE:** two of three clauses hold. Reporting FALSE would
be its own overstatement, and the claimant would be right to reject the
verdict - which costs you the next one.

## Worked: FALSE

> **Claim:** "1.3 is done - longest returns the longest word."

Restated: `wc.py longest "a bb ccc"` prints `ccc`, which is task 1.3's own
acceptance line.

Acceptance found at `fixtures/verify/PLAN.md:16-17` - the claimant's own.

Ran against: `feature/5.4-verify` @ `9fac6a3`, tree clean
(`git status --porcelain` empty).

```
$ python3 wc.py longest "a bb ccc"
a
exit=0
```

Expected `ccc`. Got `a` - the first word by scan order, not the longest.

**Diagnostic probe, not the acceptance.** Reordering the same word set shows
the output tracks position rather than length:

```
$ python3 wc.py longest "ccc bb a"
ccc
```

That probe sharpens the verdict; it is **not** pasted as the acceptance
result, and it would not have rescued the claim if it had passed. Step 5
requires the probe; the hard rules forbid substituting it for the run.

**Establishes:** the acceptance PLAN.md names for 1.3 does not hold on this
tree.
**Does not establish:** anything about 1.1 or 1.2, which are separate claims
with separate acceptances - nor that `longest` is wrong for every input.
FALSE is a verdict on the **claim**, not a score for the work.

## Worked: UNVERIFIABLE

> **Claim:** "`banned-palette` is missing from the config helper's all-keys
> output."

No acceptance is stated anywhere for the helper's key listing — no task, no
test, no documented expected set. The claim may well be true; there is
nothing to run that would settle it.

**Report:** UNVERIFIABLE, naming what is missing (an expected-keys list the
helper can be checked against) and what would make it verifiable (a task
with an acceptance, or the README config table treated as the expected set).

**Never soften this to CONFIRMED because the claim looks plausible, or to
FALSE because it cannot be shown.** Both assert something about the system
that was never tested.

**Verdict (2026-09-19):** this claim is no longer UNVERIFIABLE on this repo,
and the example is kept because of how it stopped being one. 5.31 did the
thing the report asked for — it made README's config table the expected set,
as `check.sh` §43 — and the claim then verified as **CONFIRMED and
understated**: four documented keys were missing from the helper, not one.
The lesson survives its own example. UNVERIFIABLE was the right verdict at
the time, it named what would settle the question, and following that
instruction found a defect larger than the claim. A verifier who had softened
it to CONFIRMED would have recorded the right verdict for the wrong reason
and stopped at one key; a verifier who had softened it to FALSE would have
closed a real defect. Read the shape here, not the status of this one claim.

## Checking your own reading

Before writing the verdict, ask what would make it wrong. Two modes, both
observed live on 2026-09-17:

- **A match that is an example, not an instance.** A count marker quoted in
  backticks inside prose explaining the marker syntax was read as a stale
  claim. The text matched; the meaning did not.
- **A difference that is your misreading of the claim.** A reviewer's claim
  was called a divergence from the evidence; re-reading showed the claim had
  said something narrower and correct all along. The verifier was wrong, not
  the claimant.

Both produce a confident, wrong verdict — and a wrong verdict costs more
than a missing one, because it is acted on.
