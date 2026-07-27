# Ship gates — exact commands and the PR body template

Each gate reports before the act; a failure prints its evidence and
stops the release. No gate is skipped silently — a gate that can't run
(no suite, no eval) reports that fact and says whether it passes or
blocks.

## 1. State

```bash
git status --porcelain            # empty = clean tree
git rev-parse --abbrev-ref HEAD   # current branch
git rev-parse --abbrev-ref origin/HEAD | sed 's@^origin/@@'   # default branch
git log --oneline <default>..HEAD # the commits being shipped (non-empty)
```

- Dirty tree → BLOCK: "commit or stash first" with the porcelain output.
- On the default branch → offer to cut `<branch-prefix><slug>` and move
  the commits; never open a PR from default onto itself.
- Zero commits ahead → BLOCK: nothing to ship.

## 2. Tests

Detect the suite (config `test-command` wins; else the obvious one):

```bash
# examples — pick what the repo actually uses
npm test        # package.json test script
pytest -q       # python
go test ./...   # go
```

Record the summary line verbatim (`88 passed, 40 skipped`). Any failure
→ BLOCK with the failing test names. No detectable suite → report
"no test suite found — gate passes with that stated", never a silent
green.

## 3. Eval

```bash
test -f eval/spec.md && <the run command named in eval/spec.md>
```

Read the target from `eval/spec.md`, compute the headline from the raw
results file (never transcribe by hand — the never-inflate rule),
compare:

- headline ≥ target → pass, record both numbers.
- headline < target → BLOCK, record both numbers and the gap.
- no `eval/spec.md` → "no eval spec — gate passes", one line.

## 4. Docs

Cheap checks only; deep drift is /audit docs:

```bash
git log --oneline <default>..HEAD           # the commits being shipped
# README quickstart still runs (where cheap)
# the shipped work's PLAN exit criterion, if runnable
git log <default>..HEAD --format='%s' | grep -Fqf - JOURNAL.md \
  && echo "journal mentions the work" || echo "journal silent"
```

- README quickstart visibly broken → BLOCK.
- Shipped PLAN exit criterion runnable and failing → BLOCK.
- JOURNAL silent on the work → don't block; propose `/journal` first and
  let the user rule. (Fixed-string match — commit subjects carry `().[]`,
  which a regex grep would misread.)

## 5. Attribution

```bash
git log <default>..HEAD --format='%B' | grep -inE 'co-authored-by|generated with|🤖'
```

Under `attribution: none` (default) any hit FAILS the gate, listing the
offending commit subjects — they need `git commit --amend`/rebase before
shipping. Under `attribution: standard`, this gate is informational.

## PR body template

```markdown
## What & why
<one-paragraph lede: what this branch delivers and why now>

## Gates
| Gate | Result |
|---|---|
| State | clean tree, N commits ahead of <default> |
| Tests | <summary line, verbatim> |
| Eval | <headline vs target, or "no eval spec"> |
| Docs | quickstart ok · PLAN exit <ran/na> · journal <mentions/proposed> |
| Attribution | clean per `attribution: <value>` |

## Shipped
<tickets mode: Fixes #N per completed issue>
<document mode: PLAN task IDs, and which phase heading was ticked>

## Out of scope
<the adjacent thing this PR deliberately does not do>
```

Attribution applies to this body too: no tool mentions or trailers under
`none`. The body is authored from the gate evidence — never padded with
claims a gate didn't check.
