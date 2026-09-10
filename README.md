# acstack

**Claude Code skills that prove their work instead of describing it.**

[![check](https://github.com/AaravChadha/acstack/actions/workflows/check.yml/badge.svg)](https://github.com/AaravChadha/acstack/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Stars](https://img.shields.io/github/stars/AaravChadha/acstack?style=flat&color=555)](https://github.com/AaravChadha/acstack/stargazers)

One idea, applied everywhere: a claim is only as good as the thing that can
falsify it. A phase is done when its named command passes — not when prose
says it went well. An eval score is recomputed from the results file on disk,
never tallied by hand. A guard counts as coverage only after it has been
shown firing on a seeded defect.

Where other packs simulate a team, acstack encodes a discipline — and all of
its memory lives in **your repo**, as committed markdown (BRIEF, PLAN,
JOURNAL, LEARNINGS), diffable in a pull request, not in hidden machine state.

**[See it work](#see-it-work)** · [Install](#install) ·
[Why you'd use it](#why-youd-use-it-and-why-you-wouldnt) · [Skills](#skills) ·
[Configuration](#configuration) ·
[Troubleshooting](#if-something-doesnt-work) · [More](#more)

## See it work

`/do` runs a task's acceptance line **before** doing the work. On a small
Python project, task 1.1.1 says quoted contractions must count as one word:

```
$ python3 -c "from wordfreq import top_words; assert top_words(\"don't don't stop\")[0] == (\"don't\", 2); print('acceptance PASSES before any work')"
acceptance PASSES before any work
```

It already passes — the tokenizer's character class includes the apostrophe,
so the task was written against a bug that does not exist. The box is ticked
with a verdict and **no code is written**.

A runnable acceptance line can tell you the work is unnecessary. Prose
criteria never do.

→ **[The full worked session](docs/EXAMPLE.md)** — the next task does real
work, with the failing output before the fix and both acceptances after it.

## Install

```bash
git clone https://github.com/AaravChadha/acstack.git acstack
cd acstack && ./setup      # clone anywhere; setup links from where it lives
```

Start a new Claude Code session; the <!-- count:skills -->25<!-- /count -->
skills load as slash commands. Uninstall with `./setup --uninstall` — it
removes only symlinks that point into this repo.

**Or install it as a plugin:**

```bash
claude plugin marketplace add AaravChadha/acstack
claude plugin install acstack@acstack
```

`claude plugin details acstack@acstack` prints the component inventory and
projected token cost before you commit to it. acstack's always-on payload is
<!-- count:skills -->25<!-- /count --> skill descriptions totalling ~10,075
characters, added to every session whether you invoke anything or not.

Pick `./setup` if you want the install auditable — a readable shell script
with a real `--dry-run` that never deletes a file it did not create. Pick the
plugin for one command and managed updates. **Do not run both**, or every
skill resolves twice.

**To install and run the core:** git and bash 3.2+ (the version macOS ships).
No runtime, no package manager, no build step. macOS/Linux; on Windows, copy
the `skills/*` directories into `~/.claude/skills/` manually — native symlink
support is **not scheduled**, so a copy install needs a re-copy on update and
the per-invocation runtime stays off.

**Optional, per capability.** Each degrades honestly — the skill names the
missing binary and stops, or falls back to a documented tier. None is needed
to install:

| You want | You also need |
|---|---|
| Tickets mode (`tracking: tickets`) | `gh`, authenticated, with a GitHub remote |
| `/qa` | `curl` (http probe). Browser mode is deferred — it declines with the dated verdict |
| `/migrate-check` under `db: shared-prod` | `pg_dump` for the backup path (or your own `backup-command`) |
| `/eval-run` | Your project's own stack (`python3` or `node`) — and a model API if *your system under test* calls one. The pack never calls one |
| Contributing | `shellcheck` (CI runs it; local runs skip it if absent) |

## Why you'd use it, and why you wouldn't

**Use it if:**

- You work with an agent across many sessions and lose the thread every time.
  `/resume` rebuilds context from the repo's own committed record.
- You want an agent's claims to be checkable. Every phase carries a runnable
  acceptance line, and `/do` runs it before ticking the box.
- You want project memory you can review in a pull request and take with you
  if you switch tools. It is markdown in your repo — no database, no vendor
  state.
- You want the agent to push back in writing rather than agree with you.
  That's rule 1 of the conduct contract, not a personality setting.

**Don't use it if:**

- **You have a monorepo or several products in one repository.** Every skill
  assumes a single BRIEF/PLAN/JOURNAL set; one that finds more names the
  candidates and stops rather than guessing. This is the clearest reason to
  walk away.
- **You want autonomy.** Nothing runs on its own — you type it. No hooks, no
  background agents, no watchers.
- **You want a simulated team.** No personas, no first names, no "as your
  architect I would say". Lenses and checklists instead.
- **You need claude.ai or the Skills API.** The pack keeps two frontmatter
  fields the Agent Skills spec doesn't define — `argument-hint` and
  `disable-model-invocation` — so it can't be uploaded to claude.ai or
  packaged with the official tooling. Strip them and you lose the CLI hints
  and the typed-only roster guard, nothing else
  ([the full cost](docs/SPEC-COMPAT.md)).

It is version `0.4.0`: the interfaces are stable enough to depend on and the
guards are real, but it is pre-1.0 and the roadmap is still moving.

## Skills

<!-- count:skills -->25<!-- /count --> skills across four stages. Every one is
typed — `/plan` and `/eval-spec` are additionally hidden from the model's own
skill list, so they only ever run when you ask for them.

### Plan

| Skill | What it does | Typical invocation |
|---|---|---|
| `/plan` | Frozen BRIEF.md → written architecture pushback → living PLAN.md with runnable exit criteria | `/plan seed` |
| `/challenge` | Interrogate the BRIEF: premise attacks, a narrower wedge, cost and blast-radius checks | `/challenge` |
| `/plan-review` | Engineering lock on PLAN.md: data-flow trace, failure modes, test matrix → LOCKED or CHANGES REQUIRED | `/plan-review` |
| `/eval-spec` | The eval is the spec: golden set, category minimums, refusal cases, pinned grader — written before the system exists | `/eval-spec search` |

### Build

| Skill | What it does | Typical invocation |
|---|---|---|
| `/do` | Complete one numbered subtask: execute → verify acceptance → tick the exact box → commit plan and code together, locally | `/do 3.2.1` |
| `/ticket` | Capture a brain-dump as a well-formed work item; unknowns marked TBD, never invented | `/ticket "…"` |
| `/investigate` | Root-cause before any fix: minimal repro, hypotheses vs evidence, three-strikes stop rule | `/investigate "500 on save"` |
| `/resume` | Five-minute catch-up: where the project is, divergence flags, next 3 unblocked tasks | `/resume` |
| `/why` | Decision archaeology: BRIEF → dated PLAN verdicts → JOURNAL → git history, stopping at the first real answer | `/why "the /health name"` |
| `/refactor` | Behavior-preserving cleanup with proof: green before and after, with the same test count | `/refactor src/parser.py` |
| `/design` | Production-grade UI: DTCG tokens, wireframe before code, eight production-readiness items, gaps named | `/design "settings page"` |

### Verify

| Skill | What it does | Typical invocation |
|---|---|---|
| `/audit` | Five targets — code, docs, eval, tests, skills — each with its own evidence rule | `/audit code src/` |
| `/secure` | Confidence-gated security review: a finding needs an exploit scenario and a rating. Reports only | `/secure src/` |
| `/qa` | Exercise the running app: happy-path flows, adversarial inputs, auth probing, exact repro commands | `/qa http://localhost:3000` |
| `/contract-check` | Breaking-change pre-flight for signatures, response shapes, exports, config keys → written GO/NO-GO | `/contract-check` |
| `/deps` | Dependency hygiene: is it imported, would stdlib do, is it maintained, does its license fit; `upgrade` mode pre-flights a version bump against your call sites → GO/NO-GO | `/deps` · `/deps upgrade zod 4` |
| `/migrate-check` | Read-only pre-flight for migrations against shared Postgres, per statement → GO/NO-GO | `/migrate-check` |
| `/eval-run` | Execute the eval, grade every case by its rule, compute the headline from the results file — never by hand | `/eval-run` |
| `/design-audit` | Static UI check: off-palette colors, dishonest data labels, AI-slop, leaked internal language | `/design-audit src/ui/` |

### Ship and reflect

| Skill | What it does | Typical invocation |
|---|---|---|
| `/ship` | Branch-level release behind five gates: clean state, tests, eval-vs-target, docs drift, attribution | `/ship` |
| `/journal` | End-of-session JOURNAL.md entry: exact bugs, before→after numbers, PLAN sync | `/journal` |
| `/retro` | Trend across sessions: velocity vs plan dates, eval-score trend, open-risk status | `/retro week` |
| `/learn` | Capture a durable lesson to LEARNINGS.md; recurring ones get promoted into known-bug-classes | `/learn "…"` |
| `/triage` | Backlog hygiene: stale, dupes, missing acceptance, ready work — report first, apply on approval | `/triage` |
| `/health` | Read-only checkup: docs, pointer, conduct block, config, secrets, attribution — every ✗ with its fix | `/health` |

`/plan` shadows built-in plan mode (Shift+Tab still enters it) and `/resume`
shadows built-in session resume (`claude -r` still works). Both kept
deliberately — the names are correct for what they do.

## The three documents

Three files per project, each with a different mutability rule — that
difference is the whole design:

- **BRIEF.md** — the frozen seed: context, constraints, non-negotiables,
  out-of-scope. **Never edited after commit**; it is the arbitration document
  for scope disputes.
- **PLAN.md** — the living plan: phases with runnable exit criteria, numbered
  tasks with acceptance lines. **Changes only additively** — strikethrough
  plus a dated verdict; nothing is deleted.
- **JOURNAL.md** — the rolling journal: dated entries with exact names and
  before→after numbers. **Grows every session**; it's how future-you resumes.

Repos on the legacy names (`PLANNING_PROMPT.md` / `PLANNING.md` /
`STATUS.md`) are detected and respected. Project `CLAUDE.md` stays a one-line
`@AGENTS.md` pointer; agent rules and the conduct block live in `AGENTS.md`.

## What the pack writes

Everything it touches, so you can predict it before installing:

| Path | Written by | When |
|---|---|---|
| `~/.claude/skills/<skill>` | `./setup` | Install — symlinks only; `--uninstall` removes exactly these |
| `BRIEF.md`, `PLAN.md`, `JOURNAL.md` | /plan, /do, /journal, /retro | On use |
| `LEARNINGS.md` | /plan seed (empty), /learn | On use |
| `CLAUDE.md` | /plan seed | Rewritten to the `@AGENTS.md` pointer — flagged first if it has content, never silently |
| `AGENTS.md` | /plan seed | Conduct + referral blocks, between markers only |
| `.claude/acstack.md` | /plan seed | **Offered**, not created |
| `eval/` | /eval-spec, /eval-run | Only when you ask for an eval |
| `~/.acstack/update-stamp` | the runtime | One line, the last update-check date. The only machine-local state |

Nothing leaves your machine except `git fetch` in the once-a-day update
check, and `gh` calls you initiate in tickets mode. There is no telemetry —
the `telemetry` key is reserved and unimplemented.

## Configuration

Copy `templates/acstack.md` to `.claude/acstack.md` (or `~/.claude/acstack.md`
for personal defaults). Resolution order: pack default → personal global →
project `## Settings` → per-skill section. One key per line as `key: value`; a
leading `- ` is optional and inline comments are stripped:

```markdown
## Settings

tracking: tickets
- stale-days: 14      # inline comments are stripped
```

Unknown keys are ignored — that's the extension mechanism. A *known* key that
yields no readable value is reported on stderr rather than silently
defaulting, because an unreadable config used to be indistinguishable from no
config at all.

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
| `banned-palette` | the violet-gradient family (set in a `## design-audit` section to override) | /design-audit |
| `variance`, `motion`, `density` | `balanced`, `standard`, `comfortable` (set in a `## design` section) | /design |
| `backup-command` | `pg_dump "$DATABASE_URL" > backups/pre_<ts>.sql` (set in a `## migrate-check` section) | /migrate-check |
| `## Collaborators` | (unset; a section, not a key) | /plan (hackathon owner tags) |
| `subtask-commit-format` | `task <number>: <description>` | /do |
| `journal-commit-format` | `Journal <date>: <summary>` | /journal, /resume, /retro |

`attribution: none` (the default) means generated docs, commits, and PR
bodies carry no AI-tool mentions and no attribution trailers.

Under `tracking: tickets`, every tracker-touching skill first checks that
`gh` is installed, `gh auth status` succeeds, and the repo has a GitHub
remote — naming **which** one failed and offering document mode. It never
guesses and never silently degrades.

## What every skill carries

Two marker-fenced blocks open every SKILL.md verbatim. The canonical copies
live here and `scripts/check.sh` enforces byte-identity across all
<!-- count:skills -->25<!-- /count --> of them, so changing a word is a
deliberate, visible edit to 26 files at once.

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

The runtime preamble is the pack's entire per-invocation runtime: config
echo, a once-a-day update check that never pulls, and capped recall of
LEARNINGS.md plus known-bug-classes, under a hard 12-line budget.
`runtime: off`, a copy install, or a missing pack root all degrade every
skill to pure markdown — the block's own else branch says so honestly.

<!-- acstack:runtime -->
Run before the skill's steps — per invocation, not per session (4.36); failures degrade to markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; silent ONLY if already checked today
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + bug-class names, capped 3KB
else
  echo "runtime off — proceeding without recall/update-check"
fi
```
<!-- /acstack:runtime -->

## Irreversible acts: the block the pack does *not* write for you

`./setup` writes symlinks and nothing else, so nothing here touches your
`settings.json`. That leaves a gap worth knowing about: measured 2026-08-14
on `claude 2.1.170`, a destructive command under
`--dangerously-skip-permissions` with no deny rule present ran with **no
prompt and no denial**. A `permissions.deny` entry is the one control that
still fires there, and it is two lines you paste yourself into
`~/.claude/settings.json` — including the throwaway repos where this class of
accident actually happens:

<!-- acstack:deny-set -->
```json
{
  "permissions": {
    "deny": [
      "Bash(gh repo delete:*)",
      "Bash(git push --force:*)",
      "Bash(git push -f:*)",
      "Bash(rm -rf:*)",
      "Bash(npx prisma migrate reset:*)"
    ]
  }
}
```
<!-- /acstack:deny-set -->

**This is friction, not a boundary, and it cannot be completed.** Three
limits, each measured rather than assumed:

1. **Indirection defeats it entirely.** `sh -c 'gh repo delete x'`,
   `bash -c '…'`, and any script that calls the command run straight through.
   Only the directly-typed form is caught, plus compound `a && b` chains.
2. **Matching is prefix-only, so reordered arguments escape.**
   `Bash(git push --force:*)` catches `git push --force origin main` and does
   **not** catch `git push origin main --force`. By the same rule
   `Bash(rm -rf:*)` misses `rm -fr`. Adding every variant is the trap, not
   the fix.
3. **The prefix must end at a token boundary.** A pattern whose prefix stops
   mid-token matches nothing at all.

It is a denylist, and this repo's own history is that a denylist cannot be
finished — `check.sh` §13 became an allowlist after two rounds of misses for
exactly that reason. `/health` reports how many entries are present and
deliberately returns **no pass/fail verdict**, because a green check here
would certify a safety property it cannot deliver.

Removing an entry is deleting a JSON key. `rm -rf` is the one most people
will want to drop first.

## If something doesn't work

| Symptom | Cause and fix |
|---|---|
| Slash commands don't appear | Skills load at session start — start a **new** Claude Code session after `./setup` |
| A specific skill is missing | Its symlink never got made. `ls -l ~/.claude/skills/<name>` — if absent or broken, re-run `./setup` |
| `/plan` and `/eval-spec` aren't in autocomplete | Deliberate: both are typed-only (`disable-model-invocation`). Typing the command always works |
| Every skill resolves twice | You installed via **both** `./setup` and the plugin. Remove one |
| Skills say "runtime off" | Expected on a copy install, with `runtime: off` set, or when the pack root can't be resolved through the symlink. Everything still works as plain markdown |
| A skill stops and names a missing binary | Working as designed — see [Optional, per capability](#install). Install the binary or use the documented fallback |

## More

| Document | What's in it |
|---|---|
| [docs/EXAMPLE.md](docs/EXAMPLE.md) | The full worked session, end to end |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Repo layout, and how skills, config, runtime and guards fit together |
| [CONDUCT.md](CONDUCT.md) | The agent interaction contract — ten rules for how the agent behaves with you |
| [PRINCIPLES.md](PRINCIPLES.md) | Why the discipline is shaped this way |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to add to it: matrix-first, positive controls, and the checks your change must pass |
| [docs/SPEC-COMPAT.md](docs/SPEC-COMPAT.md) | Where acstack diverges from the Agent Skills spec, and what it costs |

## Credits

Structure and ambition inspired by [garrytan/gstack](https://github.com/garrytan/gstack);
the methodology here takes a different road — repo-owned memory, honest
measurement, and zero runtime dependencies.

## License

MIT — see [LICENSE](LICENSE).
