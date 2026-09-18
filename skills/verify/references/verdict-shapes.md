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
```

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

Acceptance found at `fixtures/verify/PLAN.md:9-10` - the claimant's, not one
invented here.

Ran against: `feature/5.4-verify` @ the working tree, which is the revision
the claim was made about.

```
$ python3 wc.py count "a b c"
3
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

> **Claim:** "Fixed the network claim in the README."

Restated: README's statement of what leaves the machine matches what the
tree can actually run.

The claim is true in part, and both parts must be named:

- **Passed:** `npm view` was added, and it is genuinely used by `/deps`.
- **Failed:** `/ship` pushes and opens PRs, `/qa` sends HTTP to whatever
  endpoint it is pointed at, and every skill's runtime preamble runs an
  update check that `git fetch`es once a day. Three paths still unlisted.

**OVERSTATED, not FALSE:** something real was fixed. Reporting FALSE here
would be its own overstatement, and the claimant would be right to reject
the verdict — which costs you the next one.

## Worked: FALSE

> **Claim:** "1.3 is done - longest returns the longest word."

Restated: `wc.py longest "a bb ccc"` prints `ccc`, which is task 1.3's own
acceptance line.

Acceptance found at `fixtures/verify/PLAN.md:13-14` - the claimant's own.

Ran against: `feature/5.4-verify` @ the working tree.

```
$ python3 wc.py longest "a bb ccc"
a
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
