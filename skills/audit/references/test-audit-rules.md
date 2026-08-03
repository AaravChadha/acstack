# Test-audit rules — tests that pass without catching

A green suite is evidence only if its tests could have failed. These are the
ways a test passes while catching nothing. Same stance as the eval rules:
**never fix, tune, or delete a test to raise a number** — report it and leave
it, because a deleted bad test hides the coverage gap it was proving.

> **Regex note.** `git grep -E` is POSIX ERE — `\b` and `\s` do NOT work
> (`\b` matches nothing at all, `\s` parses as a literal `s`). Use `-w` for
> word boundaries and `[[:space:]]` for whitespace. Apply these with the
> **Grep tool**; if a harness exposes none, use plain `grep -rnE` — never
> shell `git grep`, whose `-O` runs an arbitrary program.

Every hit is a **candidate**, not a finding. Confirm by reading the test:
some are legitimate (a smoke test that only asserts "no exception" is honest
if it says so; a skip with a linked issue and a date is bookkeeping, not
rot). Report `file:line`, why it cannot catch a regression, and the smallest
change that would give it teeth.

## 1. Assertion-free tests

A test that calls the unit and asserts nothing passes as long as no
exception escapes. It is a smoke test wearing a unit test's name.

```bash
git grep -nE '^[[:space:]]*(def test_|it\(|test\(|func Test)' -- 'test*' '*test*' '*spec*'
git grep -cE '(assert|expect|should|require\.|assert\.)' -- 'test*' '*test*' '*spec*'
```

Cross-read the two: a file whose test count exceeds its assertion count has
at least one assertion-free test. Then open it — the count alone is a lead.

## 2. Tautological assertions

An assertion that cannot fail: comparing a value to itself, asserting a
literal, or re-asserting the mock's own return value.

```bash
git grep -nE 'assert(True\(True\)|[[:space:]]+True|[[:space:]]+1 == 1|[[:space:]]+not[[:space:]]+False)'
git grep -nE 'expect\((true|1|"[^"]*")\)\.(toBe|toEqual)\((true|1|"[^"]*")\)'
git grep -nE 'assert(Equal|Equals|_eq)?\([[:space:]]*[A-Za-z_.]+,[[:space:]]*[A-Za-z_.]+[[:space:]]*\)'
```

The third command is deliberately **over-broad and judgment-led**: the sharp
case is `assertEqual(x, x)` — comparing a value to itself, which looks like a
real comparison and can never fail — but POSIX ERE has **no backreferences**,
so no `git grep -E` can express "the same identifier twice". (`\1` is not a
weak match here, it is an *invalid escape*: the whole grep errors out and
matches nothing, exactly like `\b`. That mistake shipped in this very file
and its positive control caught it on the first run; check.sh §3b now guards
backreferences too.) Read the hits and keep only the self-comparisons.

## 3. Mocks stubbing the unit under test

When the mock replaces the very thing the test claims to exercise, the test
asserts that the mock returned what the mock was told to return.

```bash
git grep -nE '(mock|patch|stub|spyOn)' -- 'test*' '*test*' '*spec*'
```

For each hit, name the unit under test and the patched target. Same module
path = the test proves nothing about that unit. This one is judgment: a mock
at the process boundary (network, clock, filesystem) is correct practice.

## 4. Unread snapshots and accumulating skips

```bash
git grep -nE '(toMatchSnapshot|__snapshots__|\.snap)'
git grep -nE '(@pytest\.mark\.skip|@unittest\.skip|it\.skip|xit\(|describe\.skip|t\.Skip)'
git grep -nE '(it\.only|describe\.only|fit\(|fdescribe\()'
```

A snapshot nobody reads is a diff nobody reads: report the count and when
each was last modified. Skips are reported as a **count with a trend** — a
suite accumulating skips is losing coverage silently. `.only` is the
dangerous one: it silently disables every sibling test in the file, so a
committed `.only` means the suite has been running a fraction of itself.

## 5. The mutation spot-check — the only direct proof

Everything above is a smell. This is the experiment: **break the production
code deliberately and confirm the suite goes red.**

Pick 2–3 load-bearing functions. In each, make one behavior-changing edit
(invert a condition, return a constant, drop a filter, off-by-one a
boundary). Run the suite. A mutation that leaves the suite green is a
**confirmed** coverage hole — not a smell, a proof — and it names exactly
which behavior is unprotected.

**Revert every mutation before reporting.** State that you did, and verify
it: a mutation left behind is a defect this audit introduced. If the working
tree was dirty before you started, say so and do NOT mutate — you cannot
prove you reverted cleanly.

Report each as: function, the mutation, suite result. Green-under-mutation
is the finding; red is the suite doing its job and worth stating too.
