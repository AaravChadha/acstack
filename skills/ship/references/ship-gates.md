# Ship gates — exact commands and the PR body template

Each gate reports before the act; a failure prints its evidence and
stops the release. No gate is skipped silently — a gate that can't run
(no suite, no eval) reports that fact and says whether it passes or
blocks.

## 1. State

```bash
git status --porcelain            # empty = clean tree
git rev-parse --abbrev-ref HEAD   # current branch
```

**Resolving the default branch — do NOT use `git rev-parse origin/HEAD`.**
`origin/HEAD` is unset in any repo made by `git init` + `git remote add`
(only `git clone` sets it). That command then *fails with exit 128 while
still printing `origin/HEAD` on stdout*, so a naive pipeline yields the
literal string `HEAD`, `git log HEAD..HEAD` returns zero commits, and gate
1 blocks every release with "nothing to ship". Verified on this repo.
Resolve in this order and stop if none succeeds:

```bash
d="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')"
[ -n "$d" ] || for c in main master trunk; do
  git show-ref -q --verify "refs/heads/$c" && d="$c" && break
done
# validate before use — a name that does not resolve is not a default branch
if [ -z "$d" ] || ! git rev-parse --verify -q "$d" >/dev/null; then
  echo "BLOCKED — cannot determine the default branch; pass it explicitly"
else
  git log --oneline "$d"..HEAD    # the commits being shipped (non-empty)
fi
```

**Two traps this avoids.** `git remote show origin` looks like a good
second step and is not: it is a **network call** on every gate-1 run (it
can hang on an auth prompt), and when the remote's HEAD is unborn it
prints `HEAD branch: (unknown)`, so `$d` becomes the literal string
`(unknown)` — swapping one bad sentinel for another. The `rev-parse
--verify` line is what makes that impossible: whatever `$d` holds must
resolve to a real ref before it is used.

**`$d` is a shell variable and does not survive into the later gates**,
which run as separate commands. Gates 4 and 5 below re-resolve it with
the same block, or take the branch name as a literal. Never assume it
carries over.

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
git log --oneline "$d"..HEAD                # the commits being shipped
# README quickstart still runs (where cheap)
# the shipped work's PLAN exit criterion, if runnable

# journal mention — guard the empty case FIRST
subjects="$(git log "$d"..HEAD --format='%s')"
if [ -z "$subjects" ]; then
  echo "journal check skipped — no commits in range (see gate 1)"
elif printf '%s\n' "$subjects" | grep -Fqf - JOURNAL.md; then
  echo "journal mentions the work"
else
  echo "journal silent"
fi
```

**Why the empty guard is load-bearing:** `grep -Fqf -` with a zero-byte
pattern file **matches everything** on BSD grep (macOS), so an empty
commit range would report "journal mentions the work" from no evidence at
all — a false pass, which this pack treats as worse than no check.

Note the check is deliberately weak in the other direction too: it matches
commit subjects verbatim against JOURNAL.md, and journals rarely quote
subjects, so "journal silent" is the common answer even for well-journaled
work. It therefore **proposes `/journal` and never blocks** — treat a
silent result as a prompt to look, not as evidence of absence.

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
