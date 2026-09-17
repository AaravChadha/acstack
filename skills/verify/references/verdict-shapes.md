# Verdict shapes — the report template and four worked examples

## Template

```markdown
**Verdict: <CONFIRMED | OVERSTATED | FALSE | UNVERIFIABLE>**

**Claim as given:** <quoted verbatim, with its source — PR #N, a session
message, a ticked box at file:line>

**Restated as testable:** <the proposition that must hold>
<if this is a guess because the claimant is unavailable, say so here>

**Acceptance found:** <file:line, quoted> — or *none found*, which is the
UNVERIFIABLE case.

**Command run:**
```
$ <exact command>
<verbatim output, not summarised>
```

**What this establishes:** <the narrow thing the output proves>
**What it does not:** <the adjacent things a reader might assume>
```

The last two lines are not padding. A passing command proves one
proposition; the reader will generalise unless told where the edge is.

## Worked: CONFIRMED

> **Claim:** "The shard partition covers every case."

Restated: the union of all N shards equals the declared case set, with no
duplicates and none missing.

Acceptance found at `PLAN.md` — *"the full matrix runs as N shards whose
`RAN=` counts sum to the case count derived by `count-check`'s
`matrix-cases` rule."*

```
$ for i in 1 2 3 4; do bash docs/guard-matrix.sh "$PWD" --shard $i/4; done
RAN=47 ... RAN=47 ... RAN=47 ... RAN=46
SUM=187  declared=187
```

**Establishes:** the four shards partition the 187 declared cases exactly.
**Does not establish:** that the cases themselves are adequate, or that a
fifth shard would be handled — only this N was run.

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

> **Claim:** "The guard was proven both arms, so the roster check is sound."

Restated: a roster row omitting any declared target makes `check.sh` fail.

```
$ # remove the 'docs' target from the roster row, then:
$ bash scripts/check.sh | grep audittargets
$ echo "exit=$?"
exit=1
```

No output, exit 1 from `grep` — the guard did **not** fire. `grep -n`
prepends the path, and `./docs/SKILLS.md` contains the literal string
`docs`, so the row matched the filename.

**Establishes:** the named acceptance does not hold for at least one input.
**Does not establish:** that the guard is worthless — it fires correctly on
every target whose name does not appear in a path. FALSE is a verdict on the
**claim**, not a score for the work.

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
