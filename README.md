# acstack

**Claude Code skills that prove their work instead of describing it.**

[![check](https://github.com/AaravChadha/acstack/actions/workflows/check.yml/badge.svg)](https://github.com/AaravChadha/acstack/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Stars](https://img.shields.io/github/stars/AaravChadha/acstack?style=flat&color=555)](https://github.com/AaravChadha/acstack/stargazers)

**Who this is for:** people who use a coding agent and have had it say work
was done when it wasn't. For example, it marked a task finished without
running anything, reported a score nobody checked, or trusted a check that
had never been seen to catch anything. If that has never been a problem for
you, you probably don't need this, and the
["Don't use it if" list](#why-youd-use-it-and-why-you-wouldnt) explains why.

The idea behind the whole pack is simple: a claim only counts if there is a
way to check it. A piece of work is done when the command written down to
test it passes, not when the agent says it went well. An eval score is
recalculated from the saved results, never added up by hand. A check only
counts once it has been seen catching a mistake planted on purpose.

Other packs act like a team of people. acstack is a set of working rules
instead. Everything it remembers is saved in **your repo** as ordinary
markdown files (BRIEF, PLAN, JOURNAL and LEARNINGS), so you can see every
change in a pull request. Nothing is hidden away on your machine.

**[See it work](#see-it-work)** · [Install](#install) ·
[Why you'd use it](#why-youd-use-it-and-why-you-wouldnt) · [Skills](#skills) ·
[Configuration](#configuration) ·
[Troubleshooting](#if-something-doesnt-work) · [More](#more)

## See it work

Tasks in the plan come with an acceptance command: a command that only passes
once the task is done. `/do` runs it **before** starting the work. Here is a real
example from a small Python project, where task 1.1.1 said a contraction like
"don't" must count as one word. This is the task's acceptance command and what
it printed:

```
$ python3 -c "from wordfreq import top_words; assert top_words(\"don't don't stop\")[0] == (\"don't\", 2); print('acceptance PASSES before any work')"
acceptance PASSES before any work
```

It passed before any work was done. The code that splits text into words
already kept the apostrophe inside a word, so the bug the task described did
not exist. The task was marked done with that finding, and no code was
written.

A check you can run can tell you the work isn't needed. A written description
of "done" never can.

**What this shows and what it doesn't.** That is the command's real output,
copied from the project it ran in. It is not a record of the whole agent
session. That project isn't this repo, so the command won't run here.
**[The full worked session](docs/EXAMPLE.md)** shows the same task with every
output copied exactly. It also shows the next task, which did need real work,
with the failing output before the fix.

## Install

```bash
git clone https://github.com/AaravChadha/acstack.git acstack
cd acstack && ./setup      # clone anywhere; setup links from where it lives
```

Then start a new Claude Code session, and the
<!-- count:skills -->26<!-- /count --> skills load as slash commands. To
uninstall, run `./setup --uninstall`. It removes only the symlinks that point
into this repo.

**Or install it as a plugin:**

```bash
claude plugin marketplace add AaravChadha/acstack
claude plugin install acstack@acstack
```

Before you commit to it, `claude plugin details acstack@acstack` shows what
the plugin contains and roughly how many tokens it costs. The part that is
always loaded is the <!-- count:skills -->26<!-- /count --> skill
descriptions, about 10,730 characters in total. They are added to every
session, even if you never use a skill.

Use `./setup` if you want to see exactly what the install does. It is a
readable shell script, its `--dry-run` is real, and it never deletes a file it
did not create. Use the plugin if you want one command and automatic updates.
**Don't use both**, or every skill will show up twice.

**To update the clone install:**

```bash
git -C acstack pull && acstack/setup    # setup again, or new skills stay unlinked
```

Don't skip the `./setup` step. `git pull` downloads new skills but doesn't
link them, so after a pull on its own, Claude Code can't see them. The plugin
install updates itself. [CHANGELOG.md](CHANGELOG.md) lists what changed in
each version.

## What to type first

There are three ways to start, depending on where you are:

| You have | Type | What happens |
|---|---|---|
| A new idea, nothing built | `/plan seed` | Writes BRIEF.md, pushes back on the design in writing, then writes a PLAN.md where every phase ends with a command that proves it is done |
| An existing project with a plan | `/resume` | Reads the three documents and the git state, then tells you where you are and the next three tasks that are ready to start |
| Something broken | `/investigate` | Writes down the symptom, reproduces it, tests each guess against evidence, and finds the cause at `file:line`. It stops after three failed fixes |

After that, use `/do <task>` to complete one task from start to finish, and
`/ship` when the branch is ready. Every other skill is in
**[the full roster](docs/SKILLS.md)**.

**What the core needs:** git and bash 3.2 or later (the version macOS
ships). There is no runtime, package manager or build step. It works on macOS
and Linux. On Windows, copy the `skills/*` folders into `~/.claude/skills/` by
hand. Symlink support on Windows is **not planned**, so you will need to copy them
again after each update, and the small script each skill runs at startup (the
runtime) stays off.

**Optional extras.** Some skills need an extra tool. If it is missing, the
skill tells you which one and stops, or falls back to a simpler mode that is
documented. You don't need any of these to install:

| You want | You also need |
|---|---|
| Tickets mode (`tracking: tickets`) | `gh`, logged in, and a GitHub remote |
| `/qa` | `curl` (for HTTP checks). Browser mode isn't built yet, and asking for it gets a clear no with the reason |
| `/migrate-check` under `db: shared-prod` | `pg_dump` for the backup (or your own `backup-command`) |
| `/eval-run` | Your project's own stack (`python3` or `node`), plus a model API if *the thing you are testing* calls one. The pack itself never calls one |
| Contributing | `shellcheck` (CI runs it, and local runs skip it if it is missing) |

## Why you'd use it, and why you wouldn't

**Use it if:**

- You work with an agent over many sessions and lose track every time.
  `/resume` catches you up from what is committed in the repo.
- You want to be able to check what an agent claims. `/do` runs a task's
  acceptance command before marking it done, and won't mark a task done if
  it has no acceptance command at all.
- You want project memory you can review in a pull request and take with you
  if you switch tools. It is plain markdown in your repo, with no database
  and nothing stored by a vendor.
- You want the agent to tell you in writing when it thinks you are wrong,
  instead of just agreeing. That is rule 4 of the conduct rules, not a
  personality setting.

**Don't use it if:**

- **You have a monorepo or several products in one repository.** Every skill
  expects one set of BRIEF/PLAN/JOURNAL files. If a skill finds more than
  one, it lists them and stops instead of guessing. This is the clearest
  reason not to use acstack.
- **You want the agent to act on its own.** Nothing runs unless you type it.
  There are no hooks, background agents or watchers.
- **You want a simulated team.** There are no personas, no named
  characters, and no "as your architect, I would say". The skills use
  checklists instead.
- **You need claude.ai or the Skills API.** The skills use two frontmatter
  fields that the Agent Skills spec doesn't define, `argument-hint` and
  `disable-model-invocation`, so they can't be uploaded to claude.ai or
  packaged with the official tools. If you remove those two fields, you lose
  only the command-line hints and the guard on which skills are typed-only
  ([the full cost](docs/SPEC-COMPAT.md)).

It is at version `0.4.0`. The interfaces are stable enough to rely on and the
guards really run, but it is not 1.0 yet and the roadmap is still changing.

## Skills

There are <!-- count:skills -->26<!-- /count --> skills in four stages, and
you run each one by typing it. `/plan` and `/eval-spec` are also hidden from
the model's own list of skills, so they only run when you ask for them.

| Stage | What it covers | The ones to start with |
|---|---|---|
| **Plan** | Turn an idea into a plan with runnable exit criteria, and attack it before building | `/plan`, `/challenge` |
| **Build** | Do one task end to end, capture work, root-cause failures | `/do`, `/ticket`, `/investigate` |
| **Verify** | Checks that give a written verdict on security, contracts, dependencies, migrations and evals | `/audit`, `/secure`, `/migrate-check` |
| **Ship and reflect** | Release behind five gates, then write down what happened | `/ship`, `/journal`, `/learn` |

`/audit` can check six things: code, docs, eval, tests, skills and the
readme. Each one has its own rule for what counts as evidence.

**[The full roster →](docs/SKILLS.md)** lists all 26, what each one does, and
how you usually run it.

Two skills have the same name as a Claude Code built-in. `/plan` shares its
name with built-in plan mode (Shift+Tab still turns plan mode on), and
`/resume` shares its name with built-in session resume (`claude -r` still
works). Both names were kept on purpose, because they describe what the
skills do.

## The three documents

Each project has three files, and each one follows a different rule about how
it can change. That difference is the whole design:

- **BRIEF.md** is the fixed starting point: the context, constraints,
  must-haves and what is out of scope. **It is never edited after it is
  committed**, and it settles any argument about scope.
- **PLAN.md** is the living plan: phases that each end with a runnable check,
  and numbered tasks with acceptance lines. **It only ever grows.** To change
  something, you strike through the old text and add a dated verdict.
  Nothing is deleted.
- **JOURNAL.md** is the running log: dated entries that name exact things and
  give before and after numbers. **It grows every session**, and it is how you
  pick up where you left off.

Repos that use the older names (`PLANNING_PROMPT.md` / `PLANNING.md` /
`STATUS.md`) are detected, and the skills use those instead. The project's
`CLAUDE.md` stays a one-line `@AGENTS.md` pointer, and the agent rules and
conduct block live in `AGENTS.md`.

## What the pack writes

Here is everything it writes, so you know before you install:

| Path | Written by | When |
|---|---|---|
| `~/.claude/skills/<skill>` | `./setup` | At install. Symlinks only, and `--uninstall` removes exactly these |
| `BRIEF.md`, `PLAN.md`, `JOURNAL.md` | /plan, /do, /journal, /retro | On use |
| `LEARNINGS.md` | /plan seed (empty), /learn | On use |
| `CLAUDE.md` | /plan seed | Replaced with the `@AGENTS.md` pointer. If it already has content, you are told first, never silently |
| `AGENTS.md` | /plan seed | Conduct + referral blocks, between markers only |
| `.claude/acstack.md` | /plan seed | **Offered**, not created |
| `eval/` | /eval-spec, /eval-run | Only when you ask for an eval |
| `~/.acstack/update-stamp` | the runtime | One line, the last update-check date. The only machine-local state |

The pack makes one network call on its own, and four more only when you run
certain commands.

**On its own**, with `runtime: on` (the default): the first skill you use each
day checks for updates with a single `git fetch` of this repo. This happens
once a day, whichever skill you run. Set `runtime: off` and nothing happens
on its own.

**Only when you run them:**

| You run | It sends |
|---|---|
| any skill in tickets mode | `gh` calls to your GitHub |
| `/deps` | one `npm view` per package, to read published metadata |
| `/ship` | `git push`, and `gh pr create` under `push: branch-pr` |
| `/qa` | HTTP requests to the endpoint you point it at |

There is no telemetry. The `telemetry` setting is reserved but does nothing
yet.

## Configuration

Copy `templates/acstack.md` to `.claude/acstack.md` in your project, or to
`~/.claude/acstack.md` for your own defaults across projects. Settings are
applied in this order, with later ones winning: the pack's defaults, your
personal file, the project's `## Settings`, then a section for one skill.
Write one setting per line as `key: value`. A leading `- ` is optional, and a
`#` followed by a space starts a comment:

```markdown
## Settings

tracking: tickets
- stale-days: 14      # inline comments are stripped
```

Settings the pack doesn't know are ignored, which is how you can add your own.
If a setting it *does* know has a value it can't read, it prints a warning
instead of quietly using the default. Before that change, a broken config
looked exactly the same as having no config at all.

| Key | Values (default first) | Consumed by |
|---|---|---|
| `mode` | `standard` \| `hackathon` | /plan |
| `tracking` | `document` \| `tickets` | all tracking-aware skills |
| `push` | `direct` \| `branch-pr`. Only affects **/ship**, because /do never pushes | /ship |
| `branch-prefix` | `feature/` | /do (branch name), /ship |
| `test-command` | (auto-detected; set to override) | /ship |
| `db` | `shared-prod` \| `local` \| `none` | /migrate-check |
| `attribution` | `none` \| `standard` | all skills |
| `runtime` | `on` \| `off`. With `off`, every skill runs as plain markdown (no recall, no update check) | the runtime preamble (every skill) |
| `telemetry` | `off` \| `on`. Local only either way, and **not built yet** | runtime (4.3) |
| `stale-days` | `30` (days; set in a `## triage` section) | /triage, /health |
| `base-url` | (unset; set in a `## qa` section) | /qa |
| `palette`, `product-names` | (unset; set in a `## design-audit` section) | /design-audit |
| `banned-palette` | the violet-gradient family (set in a `## design-audit` section to override) | /design-audit |
| `variance`, `motion`, `density` | `balanced`, `standard`, `comfortable` (set in a `## design` section) | /design |
| `backup-command` | `pg_dump "$DATABASE_URL" > backups/pre_<ts>.sql` (set in a `## migrate-check` section) | /migrate-check |
| `## Collaborators` | (unset; a section, not a key) | /plan (hackathon owner tags) |
| `subtask-commit-format` | `task <number>: <description>` (document mode; tickets mode always uses `ticket #<n>: <description>`) | /do |
| `journal-commit-format` | `Journal <date>: <summary>` | /journal, /resume, /retro |

`attribution: none` (the default) means the docs, commits and PR descriptions
the pack writes don't mention AI tools and carry no attribution lines.

With `tracking: tickets`, every skill that uses the tracker first checks
three things: `gh` is installed, `gh auth status` succeeds, and the repo has a
GitHub remote. If one fails, it tells you **which** one and offers document
mode instead. It never guesses, and it never quietly switches modes.

In tickets mode, commit subjects start with the issue number, as
`ticket #<n>: <description>`. For example, `ticket #42: fix login redirect`.
GitHub turns the `#42` into a link to the issue.

## What every skill carries

Every SKILL.md starts with the same two blocks, copied exactly. The master
copies live here, and `scripts/check.sh` checks that all
<!-- count:skills -->26<!-- /count --> skills match them byte for byte. So
changing one word means a deliberate, visible edit to 27 files at once (the
26 skills plus this README).

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

The second block, the runtime preamble, is the only code that runs each time
you use a skill. It prints your settings, checks for updates once a day (it
never pulls them), and shows a size-capped list of past lessons from
LEARNINGS.md and the pack's known bug classes. It is limited to 12 lines.
With `runtime: off`, a copy install, or a pack folder it can't find, every
skill runs as plain markdown instead, and the block's `else` branch says so.

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

`./setup` only writes symlinks, so it never touches your `settings.json`. That
leaves a gap you should know about. In a test on 2026-08-14 with
`claude 2.1.170`, running with `--dangerously-skip-permissions` and no deny
rule, a destructive command ran with **no prompt and nothing blocking it**. A
`permissions.deny` entry is the one thing that still stops it there. You paste
it into `~/.claude/settings.json` yourself, so it covers every repo, including
the throwaway ones where these accidents actually happen:

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

**This adds friction. It is not a hard barrier, and the list can never be
complete.** It has three limits, each tested rather than assumed:

1. **Running the command indirectly gets around it completely.**
   `sh -c 'gh repo delete x'`, `bash -c '…'`, and any script that calls the
   command all run without being stopped. It only catches the command when it
   is typed directly, including inside an `a && b` chain.
2. **These patterns only match the start of a command, so changing the
   argument order gets past them.** `Bash(git push --force:*)` catches
   `git push --force origin main` but **not** `git push origin main --force`.
   For the same reason, `Bash(rm -rf:*)` misses `rm -fr`. Trying to add every
   variation is a trap, not a fix.
3. **The pattern must end at a whole word.** A pattern that stops partway
   through a word matches nothing at all.

It is a list of things to block, and this repo has learned that a list like
that can never be finished. `check.sh` §13 was switched to a list of things
to allow after it missed cases twice. So `/health` only reports how many
entries you have, and deliberately gives **no pass or fail**, because a green
result here would promise a safety it can't deliver.

To remove an entry, delete its line from the JSON. `rm -rf` is the one most
people will want to drop first.

## If something doesn't work

| Symptom | Cause and fix |
|---|---|
| Slash commands don't appear | Skills load when a session starts. Start a **new** Claude Code session after `./setup` |
| A specific skill is missing | Its symlink never got made. Run `ls -l ~/.claude/skills/<name>`, and if it is missing or broken, run `./setup` again |
| `/plan` and `/eval-spec` aren't in autocomplete | That is on purpose: both are typed-only (`disable-model-invocation`). Typing the command always works |
| Every skill shows up twice | You installed with **both** `./setup` and the plugin. Remove one |
| Skills say "runtime off" | Expected on a copy install, with `runtime: off` set, or when the pack folder can't be found through the symlink. Everything still works as plain markdown |
| A skill stops and names a missing tool | That is expected. See [Optional extras](#install), then install the tool or use the documented fallback |

## About this document

This README is longer and has more tables than most. It has
<!-- count:readme-lines -->457<!-- /count --> lines,
<!-- count:readme-h2 -->16<!-- /count --> sections and
<!-- count:readme-rows -->62<!-- /count --> table rows. Six comparison
projects with over 100k stars had 96–346 lines, 4–12 sections and 0–19 table
rows when they were measured on 2026-09-17. `scripts/recount.sh` keeps this
README's own three numbers up to date, because writing a number about a
document inside that same document changes it. The first draft of this
paragraph was already wrong when it was written.

**The length is a deliberate choice, and saying so is the point.**
`/audit readme` treats a difference that isn't explained as a problem, and
one that is explained as a decision.

The reason is that acstack needs setting up, not just installing. The
settings, what each skill writes, and the permission rules are things you need
*while deciding* whether to use it, not afterwards. The full list of skills
did move to [docs/SKILLS.md](docs/SKILLS.md), because a list of every skill is
not what a new reader needs first. What is left here is what you would want to
check before committing to the tool.

If the page gets hard to scan, this should be revisited. The measurement is
quick to re-run, and the decision is easy to reverse.

## More

| Document | What's in it |
|---|---|
| [docs/EXAMPLE.md](docs/EXAMPLE.md) | The full worked session, end to end |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Repo layout, and how skills, config, runtime and guards fit together |
| [CONDUCT.md](CONDUCT.md) | Ten rules for how the agent behaves with you |
| [PRINCIPLES.md](PRINCIPLES.md) | Why the rules are shaped this way |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute: add a failing test case first, show each new check catching a planted mistake, and pass the required checks |
| [docs/SPEC-COMPAT.md](docs/SPEC-COMPAT.md) | Where acstack diverges from the Agent Skills spec, and what it costs |

## Credits

The structure and ambition were inspired by
[garrytan/gstack](https://github.com/garrytan/gstack). The method here is
different: memory lives in your repo, measurements are honest, and there are
no runtime dependencies.

## License

MIT. See [LICENSE](LICENSE).
