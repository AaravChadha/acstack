# CONTRIBUTING

Read `PRINCIPLES.md` first — most review comments here are one of those
principles applied. `docs/ARCHITECTURE.md` explains the layers.

## The one hard rule

**`scripts/check.sh` must be clean before every commit.** A failing
guard blocks the commit. Fix the drift; do not skip the check.

```bash
scripts/check.sh                    # 21 numbered sections + 3b/3c/13a = 24 checks, includes positive controls
bash docs/guard-matrix.sh "$PWD"    # every guard shown firing on a seeded defect
./setup && ./setup --uninstall      # installer round-trip
```

CI runs the first two plus `shellcheck` on every PR — the installer
round-trip is local-only, since it writes outside the repo. One honest
gap: CI has no `.acstack-banned` (that list is untracked by design), so
the banned-name section prints SKIP there and **local pre-commit is the
enforcement point for names**.

> **Reviewing someone else's branch: read the diff before you run the
> guard.** `check.sh` section 11 runs `scripts/controls.sh`, which
> executes `fixtures/eval-run/eval/run.py` — a tracked file any pull
> request can edit. Checking out an untrusted branch and running the
> guard first would execute the contributor's Python on your machine.
> Read the diff to `fixtures/` and `scripts/` first; the rest of the
> guard is worth nothing if the thing you ran to get it was theirs.
> (CI is not this vector: the workflow triggers on `pull_request`, not
> `pull_request_target`, so a fork's run gets a read-only token and no
> secrets.)

## Adding or changing a guard: matrix first

Extend `docs/guard-matrix.sh`, run it, and **watch your new case fail**
before you write the guard. Then write it and watch the case pass.

This is not ceremony. This repo has shipped three checks that ran and
did not work: a secret regex that stopped at the first hyphen and
reported clean on a planted key; a description guard whose first
positive control passed because the text it tested had already been
fixed; and a palette check whose `\b` matched nothing at all, because
`git grep -E` is POSIX ERE, where `\b` is not a word boundary and `\s`
is a literal `s`. Use `[[:space:]]` and `-w`.

Across three audit rounds the share of findings *caused by the previous
round's fixes* ran 0% → 25% → 60%. Writing prose creates defects at a
real rate; writing the test first is what broke that curve.

## Adding a skill

1. `skills/<name>/SKILL.md`, under 500 lines (typical is ~118). Detail
   that is not needed every time goes in `references/`, cited from
   SKILL.md with a note on when to read it.
2. Copy the `acstack:principles` and `acstack:runtime` blocks
   **verbatim** — check.sh diffs them byte-for-byte against README's
   canonical copies. Edit the principles block only in README.md.
3. Carry an `Adjacent skills:` routing line naming real neighbors and
   how they differ.
4. Scope the `description` to explicit intent, and **quote it if it
   contains `: ` or ` #`** — unquoted YAML truncates at space-hash, and
   `/ship` shipped a whole wave with its trigger sentence silently
   discarded because the file was re-read instead of parsed.
5. Report-shaped skills state their verdict first. Read-only skills
   declare `allowed-tools` with no `Write`, `Edit`, or unscoped `Bash`.
6. Cross-skill references use `../other/references/file.md`, never
   `skills/other/…` — the latter resolves in this repo and dangles on
   every install.
7. **A check-shaped skill ships a positive control**: a fixture under
   `fixtures/<skill>/` containing a known instance of what it must
   catch, plus an assertion in `scripts/controls.sh` that fails when the
   documented command misses the plant.
8. Add the README skills-table row in the same commit — no doc-drift
   window between commits.

### Test the skill's behavior, not just its text

Before writing a skill, run its scenario **without** it and record what
the agent actually does, including the rationalizations it offers. That
baseline is the red half of red-green: it tells you what the skill must
change, and it is the only way to know afterward that the skill did
anything. A skill that produces the same output as no skill is
decoration with a line budget.

## Verifying your change

Four rules, each from a defect this repo shipped:

- **Verify the consumed form, not the authored form.** The file you
  wrote is not evidence. Check the parsed frontmatter, the live skill
  listing, the command's actual output.
- **Prove a new check fails before trusting that it passes.**
- **Anything you name as needed work gets a task in the same edit** —
  or a written note that it was deliberately declined. Recording is not
  scheduling.
- **A claim about a set enumerates the set.** "The six read-only skills"
  was written without opening six files, and one of them wasn't
  read-only. Count it, list it, or don't claim it.

## Commits

Lowercase `<verb> <object> (<detail>)` subject, a brief what-and-why
body, no attribution trailers — no `Co-Authored-By`, no "Generated
with". (This subject style is a deliberate exception to CONDUCT rule
10's work-item reference: the pack has no per-commit ticket ID. Rule
10's no-attribution half still binds.)

State numbers in the body: `matrix 43 → 46`, `19 → 20 skills`. "Fixed
bugs" is not a commit message.

## Local setup

Copy `.acstack-banned.example` to `.acstack-banned` and add any client,
company, or collaborator names you must keep out of pack content. The
file is untracked deliberately — it names the very things it protects.
Without it, check.sh reports SKIP for that section, which is correct
behavior and not a pass.
