# acstack

A skill pack for Claude Code that encodes an engineering discipline: frozen
briefs, plans with runnable exit criteria, journals with exact numbers,
decisions that get superseded instead of deleted, eval scores that are never
inflated, and a hard gate before anything touches a shared database.

Where other packs simulate a team, acstack encodes a discipline — and all of
its memory lives in **your repo**, as committed markdown, not in hidden
machine state.

## Skills

| Skill | What it does | Typical invocation |
|---|---|---|
| `/plan` | Frozen BRIEF.md → written architecture pushback (the gate) → living PLAN.md with runnable exit criteria; honest replanning; hackathon mode; tickets-mode bootstrap | `/plan seed` |
| `/challenge` | Interrogate the BRIEF: premise attacks, a narrower wedge, cost/hours/blast-radius reality checks, proceed/narrow/rethink verdict | `/challenge` |
| `/plan-review` | Engineering lock on PLAN.md: data-flow trace, failure modes, test matrix, hidden assumptions → LOCKED or CHANGES REQUIRED | `/plan-review` |
| `/eval-spec` | The eval is the spec: golden set with category minimums + refusal cases + pinned grader, written before the system exists | `/eval-spec search` |
| `/do` | Complete one numbered subtask (or issue, in tickets mode): execute → verify acceptance → tick the exact box → commit plan+code together (local only — `/ship` publishes) | `/do 3.2.1` |
| `/ticket` | Capture a brain-dump as a well-formed work item — GitHub issue or PLAN.md task; unknowns marked TBD, never invented | `/ticket "…"` |
| `/investigate` | Root-cause before any fix: minimal repro, hypotheses vs evidence, three-strikes stop rule | `/investigate "500 on save"` |
| `/resume` | Five-minute catch-up: where the project is, divergence flags, next 3 unblocked tasks | `/resume` |
| `/why` | Decision archaeology: why is this like this — BRIEF constraints → dated PLAN verdicts → JOURNAL → git history, stopping at the first real answer and saying "no recorded rationale" rather than inventing one | `/why "the /health name"` |
| `/triage` | Backlog hygiene: stale, dupes, missing acceptance, ready work, milestone burn — report first, apply on approval | `/triage` |
| `/journal` | End-of-session JOURNAL.md entry: exact bugs, before→after numbers, eval failure classification, PLAN.md sync | `/journal` |
| `/audit` | code: evidence-led defect report · docs: doc-says/reality-is drift check · eval: failure classification + never-inflate rule | `/audit code src/` |
| `/migrate-check` | Read-only pre-flight for migrations against shared Postgres; per-statement classification; written GO/NO-GO | `/migrate-check` |
| `/learn` | Capture a durable lesson to LEARNINGS.md (symptom → cause → fix, seen-count); recurring lessons promoted into the pack's known-bug-classes | `/learn "…"` |
| `/health` | Read-only project checkup: docs, pointer, conduct block, config, secrets, attribution, learnings, tickets prerequisites — every ✗ with its exact fix command | `/health` |
| `/qa` | Exercise the running app through the probe layer: happy-path flows, adversarial inputs, auth-gate probing; PASS/FAIL report with exact repro commands (http now; browser deferred) | `/qa http://localhost:3000` |
| `/secure` | Confidence-gated security review: findings need an exploit scenario + high/medium/low rating; sweeps auth gates, secrets, injection and unsafe sinks, deserialization/crypto/TLS, LLM tool-use; reports only | `/secure src/` |
| `/design-audit` | Static UI convention check: off-palette colors, wrong name casing, dishonest data labels, AI-slop, leaked internal language — file:line findings with fixes | `/design-audit src/ui/` |
| `/retro` | Trend across sessions: velocity vs plan dates, eval-score trend, failure-category trends, open-risk status — written into JOURNAL.md | `/retro week` |
| `/eval-run` | Execute the eval: scaffold a runner for the project's stack when none exists, grade every case by its rule, write per-case results, and compute the headline from that file — never by hand | `/eval-run` |
| `/ship` | Branch-level release: five gates (clean state, tests, eval-vs-target, docs drift, attribution) then a report-shaped PR wiring `Fixes #N` or PLAN task IDs | `/ship` |

## Install

```bash
git clone https://github.com/AaravChadha/acstack.git acstack
cd acstack && ./setup      # clone anywhere; setup links from where it lives
```

Start a new Claude Code session; the twenty-one skills above load as slash
commands. Uninstall with `./setup --uninstall` — it removes only symlinks
that point into this repo.

**To install and run the core:** git and bash 3.2+ (the version macOS
ships). No runtime, no package manager, no build step. macOS/Linux; on
Windows, copy the `skills/*` directories into `~/.claude/skills/`
manually. Native symlink support is **not scheduled** — with a copy
install, pack updates need a re-copy, and the per-invocation runtime
stays off (it resolves the pack through the symlink).

**Optional, per capability.** Each degrades honestly — the skill names
the missing binary and stops, or falls back to a documented tier. None
is needed to install:

| You want | You also need |
|---|---|
| Tickets mode (`tracking: tickets`) | `gh`, authenticated, with a GitHub remote — used by /plan, /do, /ticket, /triage, /investigate, /resume, /retro, /health, /ship |
| `/qa` | `curl` (http probe). Browser mode is deferred — it declines with the dated verdict |
| `/migrate-check` under `db: shared-prod` | `pg_dump` for the backup path (or your own `backup-command`) |
| `/eval-run` | Your project's own stack (`python3` or `node`) — and a model API if *your system under test* calls one. The pack never calls one |
| Contributing | `shellcheck` (CI runs it; local runs skip it if absent) |

### What the pack writes

Everything it touches, so you can predict it before installing:

| Path | Written by | When |
|---|---|---|
| `~/.claude/skills/<skill>` | `./setup` | Install — symlinks only; `--uninstall` removes exactly these |
| `BRIEF.md`, `PLAN.md`, `JOURNAL.md` | /plan, /do, /journal, /retro | On use |
| `LEARNINGS.md` | /plan seed (empty), /learn | On use |
| `CLAUDE.md` | /plan seed | Rewritten to the one-line `@AGENTS.md` pointer — flagged first if it has content, never silently |
| `AGENTS.md` | /plan seed | Conduct + referral blocks, between markers only |
| `.claude/acstack.md` | /plan seed | **Offered**, not created |
| `eval/` | /eval-spec, /eval-run | Only when you ask for an eval |
| `~/.acstack/update-stamp` | the runtime | One line, the last update-check date. The only machine-local state; `runtime: off` writes nothing |

Nothing leaves your machine except `git fetch` in the once-a-day update
check, and `gh` calls you initiate in tickets mode. There is no
telemetry — the `telemetry` key is reserved and unimplemented.

## See it work

A real session on a small Python project. Every command was run and every
output pasted verbatim. The commands use double quotes throughout so they
survive copy-paste — an earlier version of this section did not, which is
exactly the kind of thing this pack exists to catch.

The project counts word frequencies; the plan says what "correct" means.
The defect blocks only reproduce *before* the fix — that is the point of
showing them — so each is labelled with the state it runs against. The
short hashes below are from the scratch project this was recorded in;
they are labels for the two states, not commits you can check out.

**Task 1.1.1 — `/do` runs the acceptance line before doing the work:**

```
$ python3 -c "from wordfreq import top_words; assert top_words(\"don't don't stop\")[0] == (\"don't\", 2); print('acceptance PASSES before any work')"
acceptance PASSES before any work
```

It already passes — the tokenizer's character class includes the
apostrophe, so the task was written against a bug that does not exist.
The box is ticked with a verdict and **no code is written**. A runnable
acceptance line can tell you the work is unnecessary; prose criteria
never do.

**Task 1.1.2 — real work.** Quoted words count as separate words
(before the fix):

```
$ python3 -c "from wordfreq import top_words; print(top_words(\"'the' the the\"))"
[('the', 2), ("'the'", 1)]

$ python3 -c "from wordfreq import top_words; assert top_words(\"'the' the the\") == [('the', 3)]" 2>&1 | tail -1
AssertionError
```

Fix: strip surrounding quotes, keep internal ones. Both acceptances after the change:

```
$ python3 -c "from wordfreq import top_words; assert top_words(\"'the' the the\") == [('the', 3)]; print('PASS')"
PASS
$ python3 -c "from wordfreq import top_words; assert top_words(\"don't don't stop\")[0] == (\"don't\", 2); print('PASS')"
PASS
```

The second is 1.1.1 re-run — the earlier task still holds. Then plan and
code commit together, locally:

```
$ git log --oneline
f054971 completed task 1.1.2 (strip surrounding quotes from words)
fa331d6 add plan
dfd3459 add wordfreq
```

`/do` never pushes — publishing is `/ship`'s job, behind five gates.

Later: `/resume` to catch up, `/investigate` when something breaks,
`/audit code` before you trust a change, `/secure` before you ship it.
Nothing runs on its own — you type it.

### Two commands are shadowed, deliberately

Skills override built-ins, and two of these collide:

- **`/plan`** shadows built-in plan mode. Shift+Tab still enters it.
- **`/resume`** shadows built-in session resume. `claude -r` still works.

Both were kept because the names are correct for what they do. If a
shadow bites in practice, tell us — it's a documented tradeoff, not a
settled one.

Separately: `/plan` and `/eval-spec` are typed-only
(`disable-model-invocation: true`), so they never appear in the
model-facing skill list, and the VS Code extension's autocomplete shows
only a subset of commands — the CLI menu shows all. Both are cosmetic;
typing the command always works.

## The three documents

acstack skills create and maintain three files in each project, each with a
different mutability rule — that difference is the whole design:

- **BRIEF.md** — the frozen seed: context, constraints, non-negotiables,
  out-of-scope, and open questions, ending in a gate that demands written
  architecture pushback before any code. **Never edited after commit** — it
  is the arbitration document for scope disputes.
- **PLAN.md** — the living plan: phases with runnable exit criteria,
  numbered checkbox tasks with acceptance lines. **Changes only additively**
  — strikethrough + dated verdict, decimal phases, breadcrumbs; nothing is
  deleted.
- **JOURNAL.md** — the rolling journal: dated entries recording what
  actually happened, with exact names and before→after numbers. **Grows
  every session** — it's how future-you resumes in five minutes.

Repos that already use the legacy names (`PLANNING_PROMPT.md` /
`PLANNING.md` / `STATUS.md`) are detected and respected — no renames forced.

**One product per repository.** Every skill assumes a single
BRIEF/PLAN/JOURNAL set. Monorepos and multi-product repos are *not*
supported: a skill that finds more than one candidate set names the
candidates and stops rather than guessing, and `/health` reports the
shape as info. Know this before installing — the alternative would be a
`/retro` confidently reporting on the wrong product.
Project `CLAUDE.md` stays a one-line `@AGENTS.md` pointer; agent rules and
the conduct block live in `AGENTS.md`.

## Conduct

`CONDUCT.md` is the agent interaction contract — ten rules for how the agent
behaves with you (the word is the mode; the user sets the pace; when unsure,
ask; offers hold no expectations; commits carry referenced subjects and no
tool trailers). `/plan seed` installs its marker-fenced block into your
project's AGENTS.md.

## Per-project configuration

Copy `templates/acstack.md` to `.claude/acstack.md` in a project (or
`~/.claude/acstack.md` for personal defaults). Resolution order: pack
default → personal global → project `## Settings` → per-skill section.
Unknown keys and sections are ignored — that's the extension mechanism.

| Key | Values (default first) | Consumed by |
|---|---|---|
| `mode` | `standard` \| `hackathon` | /plan |
| `tracking` | `document` \| `tickets` | all tracking-aware skills |
| `push` | `direct` \| `branch-pr` — governs **/ship only**; /do never pushes | /ship |
| `branch-prefix` | `feature/` | /do (branch name), /ship |
| `test-command` | (auto-detected; set to override) | /ship |
| `db` | `shared-prod` \| `local` \| `none` | /migrate-check |
| `attribution` | `none` \| `standard` | all skills |
| `runtime` | `on` \| `off` — `off` degrades every skill to pure markdown (no recall, no update-check) | the runtime preamble (every skill) |
| `telemetry` | `off` \| `on` — local-only either way; **not implemented yet** | runtime (4.3) |
| `stale-days` | `30` (days; set in a `## triage` section) | /triage, /health |
| `base-url` | (unset; set in a `## qa` section) | /qa |
| `palette`, `product-names` | (unset; set in a `## design-audit` section) | /design-audit |
| `backup-command` | `pg_dump "$DATABASE_URL" > backups/pre_<ts>.sql` (set in a `## migrate-check` section) | /migrate-check |
| `## Collaborators` | (unset; a section, not a key) | /plan (hackathon owner tags) |
| `subtask-commit-format` | `task <number>: <description>` | /do |
| `journal-commit-format` | `Journal <date>: <summary>` | /journal, /resume, /retro |

`attribution: none` (the default) means generated docs, commits, and PR
bodies carry no AI-tool mentions and no attribution trailers. Flip to
`standard` if your project or event requires disclosure.

### Tickets-mode preconditions

Skills that touch a tracker (`tracking: tickets`) check three things on
every invocation. Each skill states these inline so it reads correctly
on its own inside your repo; this section is the human-facing summary:

1. `gh` is installed,
2. `gh auth status` succeeds,
3. the repo has a GitHub remote.

If any one fails, the skill names **which** precondition failed and offers
document mode. It never guesses, and it never silently degrades — an
honest halt beats a tracker operation against the wrong repo.

All nine tickets-aware skills apply it: /plan, /do, /ticket, /triage,
/investigate, /resume, /retro, /health, and /ship. Each states the three
preconditions inline rather than pointing here, so a skill read on its own
in your repo is complete — this section is the human-facing summary, not a
dependency.

## Operating principles

Every skill carries this block verbatim (canonical copy below;
`scripts/check.sh` enforces byte-identity):

<!-- acstack:principles -->
## Operating principles

- Be direct. Push back in writing when the plan or the user is wrong. No sycophancy.
- Never delete a decision. Supersede it: `~~old~~ → **Verdict (YYYY-MM-DD):** new call — reason.`
- Never fix, tune, or delete a test or eval case to raise a score. Log the miss honestly and leave the case unchanged.
- Name exact things: regex patterns, function signatures, model names, before → after numbers. Never "fixed bugs".
- Attribution: follow the project's `attribution` setting (default `none`) — no AI-tool mentions in generated docs, no attribution trailers in commits or PRs. Commit with explicit `-m`/`-F` messages only.
- Config: read `.claude/acstack.md` at the project root (fall back to `~/.claude/acstack.md`) before acting. `## Settings` keys override pack defaults; a `## <skill-name>` section overrides both. Unknown keys and sections are ignored.
- Docs: BRIEF.md (frozen seed) / PLAN.md (living plan) / JOURNAL.md (rolling journal). If the repo uses legacy names (PLANNING_PROMPT.md / PLANNING.md / STATUS.md), use those instead — never create both.
- Recall: if `LEARNINGS.md` exists at the project root, read it before starting.
- Conduct: follow the `acstack-conduct` block in this repo's AGENTS.md — the word is the mode; the user sets the pace.
<!-- /acstack:principles -->

## Runtime block

Every SKILL.md opens with this block verbatim (canonical copy below;
`scripts/check.sh` enforces byte-identity and a hard 12-line budget —
growing it is a deliberate, visible edit). It is the pack's entire
per-invocation runtime: config echo, a once-a-day update check that
never pulls, and capped recall of LEARNINGS.md plus the pack's
known-bug-classes. `runtime: off`, a copy install, or a missing pack
root all degrade every skill to pure markdown — the block's own else
branch says so honestly. Machine-local state is exactly one file,
`~/.acstack/update-stamp`; nothing phones home.

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; prints the pull command when behind
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + pack known-bug-classes, capped 6KB
else
  echo "runtime off — proceeding without recall/update-check"
fi
```
<!-- /acstack:runtime -->

## Repo layout

```
CONDUCT.md            # the agent interaction contract (10 rules)
PRINCIPLES.md         # why the discipline is shaped this way
CONTRIBUTING.md       # how to add to it (matrix-first, positive controls)
docs/ARCHITECTURE.md  # how skills, config, runtime, and guards fit
VERSION, CHANGELOG.md # release record; check.sh enforces their agreement
setup                 # symlink installer / uninstaller
bin/                  # three runtime helpers: config, update-check, recall
scripts/check.sh      # pack guard — its header enumerates every section
scripts/controls.sh   # positive controls: documented checks vs seeded fixtures
fixtures/<name>/      # one planted defect per check-shaped skill (+ multi-product)
docs/guard-matrix.sh  # seeded-defect cases proving each guard fires
templates/acstack.md  # per-project config template
skills/<name>/        # one directory per skill: SKILL.md (+ references/ where needed)
```

## Development

Run `scripts/check.sh` before committing pack changes. Its header
comment is the single enumeration of everything it guards — the list
lives beside the code because copies of it kept here went stale twice.
Banned-name checking reads your own untracked `.acstack-banned` list
(copy `.acstack-banned.example`; the list is deliberately NOT committed,
since it names the very clients it protects). `docs/guard-matrix.sh`
holds the seeded-defect cases proving each guard fires — extend it
BEFORE adding a guard.

## Credits

Structure and ambition inspired by [garrytan/gstack](https://github.com/garrytan/gstack);
the methodology here takes a different road — repo-owned memory, honest
measurement, and zero runtime dependencies.

## License

MIT — see [LICENSE](LICENSE).
