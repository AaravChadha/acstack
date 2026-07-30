# ARCHITECTURE — how the pieces fit

Four layers, each with one job: **skills** (the instructions), **config**
(what varies per project), **runtime** (the eleven lines that run before
a skill's steps, under a budget of twelve), and **guards** (what makes the claims mechanical).
Nothing here is generated; every file is hand-maintained markdown or
bash, and that is a deliberate constraint — see PRINCIPLES.md.

## Layout

```
AGENTS.md             this repo's binding rules + the conduct and referral blocks
CONDUCT.md            the interaction contract (10 rules) — ships into adopter repos
CONTRIBUTING.md       how to add to the pack
PRINCIPLES.md         why the discipline is shaped this way
VERSION, CHANGELOG.md release record; check.sh enforces their agreement
setup                 symlink installer / uninstaller
bin/                  three runtime helpers (bash 3.2+)
scripts/check.sh      the guard — its header enumerates all 14 sections
scripts/controls.sh   positive controls: documented checks vs seeded fixtures
fixtures/<skill>/     one known planted defect per check-shaped skill
docs/guard-matrix.sh  seeded-defect cases proving each guard fires
templates/acstack.md  per-project config template
skills/<name>/        SKILL.md (+ references/ loaded on demand)
```

## Skills

One directory per skill, one `SKILL.md`, optional `references/*.md` read
only when the skill needs them. Frontmatter carries `name`,
`description`, `argument-hint`, and optionally `allowed-tools` and
`disable-model-invocation`.

Two size rules, both guarded: SKILL.md stays under 500 lines (the pack
runs ~110 average), and detail that is not needed on every invocation
lives in `references/`. This is progressive disclosure — the description
is always in context, the body loads on invocation, the references load
on demand.

**Invocation split.** Most skills are model-invocable with descriptions
scoped to explicit intent. Exactly two — `/plan` and `/eval-spec` —
carry `disable-model-invocation: true` because they create committed
artifacts and set targets. An agent cannot see those two, so it cannot
recommend them; the `acstack-referrals` block in AGENTS.md exists to
close that gap, and check.sh asserts the roster matches the flag set.

**Cross-skill references** use relative paths (`../audit/references/…`).
Every install symlinks all skill directories side by side, so those
resolve on any machine. Repo-root-relative paths (`skills/audit/…`) do
*not* resolve on an install and are a guard failure.

## Config

Resolution order, most specific last: pack default → `~/.claude/acstack.md`
→ project `.claude/acstack.md` `## Settings` → a per-skill
`## <skill-name>` section. Unknown keys and sections are ignored — that
is the extension mechanism, not an oversight.

`bin/acstack-config` implements exactly this chain and prints
`key=value (source)` so the resolution is visible rather than assumed.

When layered config must be truncated to fit a budget, drop the most
local layer first and keep the user-wide one — the broader setting is
more likely to be a deliberate standing choice.

## Runtime

A marker-fenced block at the top of every SKILL.md, byte-identical
across all of them, canonical copy in README.md. Budget: **12 lines**,
enforced by `PREAMBLE_BUDGET` in check.sh. Raising it requires editing
that constant in a visible commit — the budget is the accretion brake.

Line by line (the block is 11 lines inside the markers, one under
budget):

1. **`Run once before the skill's steps; any failure degrades to pure markdown:`**
   — states the contract to the reading agent: this is best-effort, and
   failure is not an error.
2. **` ```bash `** — opens the block.
3. **`pack="$(dirname "$(dirname "$(readlink …/skills/health …)")")"`**
   — resolves the pack root through an installed symlink. `setup` links
   only `skills/*/`, so `bin/`, `CONDUCT.md`, and `templates/` are on no
   path relative to the user's project; this is the only way to find
   them. `2>/dev/null || true` means a copy install (no symlink) yields
   an empty string instead of an error.
4. **`if [ -x "$pack/bin/acstack-config" ] && ! … runtime | grep -q '=off'; then`**
   — two conditions in one line: the helpers must exist and be
   executable (false on a copy install or a partial clone), and
   `runtime` must not resolve to `off`. Testing the resolved value
   rather than reading the file honors the whole precedence chain.
5. **`"$pack/bin/acstack-config" || true`** — echoes resolved keys with
   their sources, so a skill's behavior traces to a setting.
6. **`"$pack/bin/acstack-update-check" || true`** — at most one
   `git fetch` per day; prints the pull command when behind; never pulls.
7. **`"$pack/bin/acstack-recall" || true`** — LEARNINGS.md plus the
   pack's known-bug-classes, capped at 6KB. Every one of these three
   carries `|| true`: a broken helper must never block the actual work.
8. **`else`** — the degradation branch.
9. **`echo "runtime off — proceeding without recall/update-check"`** —
   one honest line. The skill still runs; it just runs as pure markdown.
10. **`fi`** — closes.
11. **`` ``` ``** — closes the block.

### bin/

Three helpers, bash 3.2+, no arguments beyond a key name, all read-only
against the repo and all shellcheck'd by check.sh:

- **`acstack-config [key] [skill]`** — resolves through the precedence
  chain; prints `key=value (source)`. With no arguments, prints every
  key that has a value.
- **`acstack-update-check`** — writes `~/.acstack/update-stamp` **before**
  fetching, so an offline day still counts as checked and a broken
  network cannot cause a fetch storm. Offline exits 0 silently.
- **`acstack-recall`** — prints project LEARNINGS.md plus the pack's
  known-bug-classes, jointly capped at 6KB with an explicit
  `[recall truncated at 6KB]` marker. Missing files produce empty output
  and exit 0.

`~/.acstack/` holds exactly one file. There is no telemetry.

## Guards

Three layers, each answering a different question.

**`scripts/check.sh` — is the pack internally consistent?** Fourteen
numbered sections plus 3b; the header comment is their single enumeration, updated in the
same commit as any new section (that list went stale twice when copies
lived elsewhere). It covers principles-block byte-identity, banned
names, frontmatter parsing and description safety, POSIX-ERE hazards in
documented greps, line budgets, shell syntax and shellcheck,
VERSION/CHANGELOG agreement, routing lines, cross-reference resolution,
config-key reachability, verdict-first stance, positive controls,
runtime-block identity and budget, read-only tool declarations, and the
referral roster.

**`scripts/controls.sh` — do the documented checks actually work?** For
each check-shaped skill it extracts the detection command *from the
reference file at run time* and runs it against a fixture carrying a
known plant. Editing a documented pattern therefore edits what gets
tested: a regressed regex fails here rather than silently in the field.
`/eval-run`'s control is the sharpest — a seeded failing case must
produce 5/6 (83.3%), and it also asserts that every case excluded
from the denominator is NAMED — silent exclusion moves no percentage,
so it is invisible in the number alone.

**`docs/guard-matrix.sh` — does each guard fire?** 55 cases, each
seeding one defect into a copy of the real tree and asserting the
expected failure class, plus must-pass cases so a guard cannot pass by
failing everything. **Extend the matrix first, watch the case fail, then
write the guard.** `/qa`'s control needs a live server, so it is a documented shakedown
procedure (`fixtures/qa/README.md`) instead — stated rather than
pretended into a per-commit check.

**What the guards cannot do,** stated because a green run should not be
mistaken for more than it is: check.sh proves *declarations* — that a
skill declares a read-only tool set, that a fixture exists, that a rule
is written down. It cannot prove the permission layer enforces the
declaration, that a model actually halted on an ambiguous repo, or that
a report's judgment was sound. Those are shakedown evidence, and the
launch checklist demands them separately.

## Installer

`setup` symlinks each `skills/*/` into `~/.claude/skills/`
(`CLAUDE_SKILLS_DIR` overrides). Symlinks rather than copies so repo
edits take effect on the next session with no sync step, and so
`--uninstall` can identify exactly what the pack owns — only links
resolving into this repo are ever removed. It never deletes a real file
or directory, even with `--force`. Under `--dry-run` every line reads
`would link` / `would remove` and nothing is touched.
