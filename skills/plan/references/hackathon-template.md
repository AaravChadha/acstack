# Hackathon PLAN.md template — 24–48h, 2–4 people or sessions

Same grammar as plan-template.md, compressed for a timed event. Differences:
clock windows instead of days, build-order arrows, owner tags, a file
ownership table, a demo script, and a submission checklist. Owners come from
the config's `## Collaborators`; an owner can be a person or one of several
sessions run by one person.

**Every task carries its own `**Acceptance:**` line.** `/do` will not tick a
box without one, so a plan that leaves them out makes every task stop and
wait for the user to approve a check. Measured 2026-09-23: four sessions ran
`/do` on this template's old shape, which had no acceptance lines, and
**0 of 4** tasks were ticked. Write each acceptance so it uses only files
that are committed, plus the dependencies installed from committed files
(the lane installs them in each worktree first): a `.gitignore`d file (a local `.env`, a data file) is
never on `main`, so an acceptance that reads one can pass for its author and
fail for everyone else. Write it to run from the project root with no `cd`
(`python -m pytest api/tests`, `npm --prefix web test`): the session's shell
keeps the folder a `cd` moved it to, and its next `git` command then runs in
the wrong place. **For a web app, never start or call a server in an
acceptance.** A server started in the background outlives the command; the
next run's server then fails to bind and the check talks to the old one,
running old code. Measured 2026-09-24: a second server started on the same
port logged `Address already in use`, and the check's `curl` got the first
server's old content. Dev servers such as Vite and Next also move to the
next free port instead of failing. Use the framework's test client
(FastAPI's `TestClient`, Flask's `test_client()`, `supertest` for Express),
or for a front end its build or unit tests.

A Python folder needs a committed `pytest.ini` with `pythonpath` set to it,
so `api/.venv/bin/python -m pytest api/tests` finds its modules from the
root; a Node folder needs a `test` script whose runner is a dev dependency
(`npm --prefix web test`). A task that needs a secret key or data too big to
commit gets an acceptance that uses a stub or a small committed sample; the
real call is checked by hand in the demo.

**Phase 0 commits the project's setup to `main` before any session
starts**, on a branch called `main` (`git init -b main`, or
`git branch -m main` if git made `master`): everything `/plan` wrote
(BRIEF.md, PLAN.md, AGENTS.md with the fast-lane block below, CLAUDE.md,
`.claude/acstack.md` with `mode: hackathon`), the `.gitignore` below, the
dependency files with their lockfiles, and the test setup above. Each
session's worktree is built from `main`, so a file that is not committed
there does not exist in it. Then install the hook that refuses any commit
on `main`, in every checkout of this clone (task branches and the lane's
swap are unaffected; it is local and never committed):

```bash
h="$(git rev-parse --git-common-dir)/hooks/pre-commit"
printf '%s\n' '#!/bin/sh' '[ "$(git symbolic-ref -q HEAD)" = refs/heads/main ] && { echo "refused: no commits on main during the event; use the operator route"; exit 1; }' 'exit 0' > "$h"
chmod +x "$h"
```

**On event day,** if your Claude Code settings `ask` before
`Bash(git update-ref *)`, remove that rule until the event ends and keep
`git merge` gated: each swap you approve after another session landed fails
and retries (see the lane's "Permission rules").

```markdown
# <Project name>
### <Event name> | <duration>

## Problem
<2-3 sentences. The judge-facing pain.>

## Solution
<Numbered 1-5 capability list — what it does, not how.>

## Tech Stack
| Layer | Choice | Reason |
|---|---|---|
| <layer> | <tool> | <why — free tier and setup speed count as reasons> |

## File ownership

| Track | Owner | Edits only | Reads from |
|---|---|---|---|
| A | <owner> | `<dir or files>` | — |
| B | <owner> | `<dir or files>` | Track A's function names, fixed in PLAN.md |

<Every file the plan will create is in exactly one "Edits only" cell. A
session that needs a change in another track's file asks that track; it does
not edit it. PLAN.md is shared: `/do` ticks one box per task, and new
tasks go in through the lane's operator route.
The dependency files (`package.json` and its lockfile, `requirements.txt` or
`pyproject.toml`) belong to Phase 0: it adds every dependency the plan
names and commits the lockfile, so no track edits them mid-event.>

## Phases

### [ ] Phase 0 — Setup `Friday 5–8pm` (~1 hr)
> Goal: <one sentence>

### [ ] Phase 1 — <core> `Friday 8pm → Saturday 12pm` (~3–4 hrs)
> Goal: <one sentence>
> **Build order:** 1.1 → 1.3 → 1.2 → 1.4 (share schemas after 1.3 to
> unblock teammates)

- [ ] **1.1 <task> (Track A — <owner>)** ← start here
  **Acceptance:** `<command>` prints `<expected>`.
- [ ] **1.3 <task> (Track A — <owner>)** ← do second, share with teammates
  immediately after
  **Acceptance:** `<command>` prints `<expected>`.
- [ ] **1.2 <task> (Track B — <owner>)** ← unblocks <owner 2>
  - [ ] 1.2.1 <leaf with exact file/endpoint/literal>
    **Acceptance:** `<command for this leaf>` prints `<expected>`.
  **Acceptance:** `<command>` prints `<expected>`.

<Physically reorder subtasks to match the build order — the document order
IS the execution order.>

## Demo Script for Judges

**Scenario 1 — <name> (shows <the feature>):**
> <spoken setup, one sentence>
- <click-path, one line>

<Close with a meta-judgment: which scenario is the strongest talking point.>

## Future Extensions (mention to judges, don't build)
- <each on one line>

## Submission checklist `<final window>`
- [ ] Confirm no secrets file was ever committed:
  `git log --all --name-only --format= | sort -u | grep -iE '(^|/)\.env|\.envrc$|secret|\.pem$|\.key$|service.?account|credential'`
  prints nothing, or only `.env.example` files. No name list is complete:
  also read `git ls-files` once for anything else that holds a key.
- [ ] README has run instructions verified on a teammate's clone.
- [ ] Any event-required sections present and **user-authored** — the
  agent never writes them (see the pack's attribution setting).
- [ ] Demo rehearsed once end-to-end, timed.
```

## The fast-lane block for AGENTS.md

In hackathon mode `/plan` also writes this block into the project's
AGENTS.md, between its markers, filling in the event end. A project's own
AGENTS.md is what overrides a personal "merge only through a PR" rule for
this one repo, so the lane has to be written here, not assumed.

```markdown
<!-- acstack:hackathon-lane -->
## Hackathon fast lane (this repo only, until <event end>)

This project is a timed event. For this repo, these rules replace any
"merge only through a pull request" or "one integrator merges" rule in
personal instructions.

- One session per track, each in its own git worktree and branch. Start
  each session with plain `claude` in this folder, with the folder on a
  detached `main` (`git switch --detach main`): on its first `/do`, the
  session creates its own worktree from the local `main` and moves into it.
  Not `claude --worktree`, which branches from `origin/main`, and this lane
  never pushes. Nobody edits files in the main checkout; it is where sessions
  start and where the demo runs.
- Give each session its task by ID (`/do 1.2`). A bare `/do` picks the
  first open task in the plan, which is the same task for every session.
- Edit only the files your track owns (PLAN.md, "File ownership"). For a
  change in another track's file, ask that track's session.
- During the event only `/do` changes the repo: `/journal`, `/retro`,
  `/learn`, `/ticket`, `/triage` and `/ship` wait until after submission.
  To change `main` outside a task (add a task, a `.gitignore` line, a
  dependency), ask a session to land it through the operator route in
  `/do`'s hackathon lane. Nobody commits on `main`; the Phase 0 hook
  refuses it.
- To see progress, read `git show main:PLAN.md`. The main checkout's copy
  is stale until someone runs `git switch --detach main` there.
- `/do` merges its own finished task into `main` as soon as the task's
  acceptance passes. There is no pull request, no review and no integrator.
- Before starting a task that builds on another track, check that the other
  track's work is already on `main`.
- Pushing `main` to the remote is a backup. Nothing waits for it.

This lane is for several sessions on one machine, sharing one clone. What
it gives up on purpose, for the length of the event: review before merge,
CI before merge, a protected `main`, and a linear history (merge commits
land on `main`). It does not read the date: afterwards, remove this block
and `mode: hackathon` to put them back.
<!-- /acstack:hackathon-lane -->
```

## The `.gitignore` for the event

Add these lines to whatever `.gitignore` the project scaffold wrote. `/do`
refuses to land a task while its worktree holds an untracked file, and each
line here is something a common tool leaves behind. In a reviewer's scratch
projects on 2026-09-24, a Python 3.9 `.venv` (572 files), `.coverage`,
`*.egg-info/` and `.next/` each stopped a landing, and `.env.local` escaped
a secrets check that looked only for `*.env`.

```gitignore
/.claude/worktrees/
__pycache__/
.pytest_cache/
.coverage
htmlcov/
*.egg-info/
.venv/
.next/
# one anchored line per folder that holds a package.json:
/node_modules/
# your stack's build output, anchored at its real path:
/dist/
.env
.env.*
!.env.example
.envrc
secrets.toml
*.pem
*.key
*serviceAccount*.json
*service-account*.json
# databases the app creates when it runs; commit seed data as SQL or CSV:
*.db
*.sqlite
*.sqlite3
```

`node_modules/` and `dist/` are anchored because the bare names match at any
depth, and a track can keep source in a folder with either name. Check the
scaffold's own `.gitignore` files too: a framework's `web/.gitignore` often
ignores `dist` unanchored. A lockfile is never ignored: Phase 0 commits it.

## Change rules under time pressure

Same as standard, faster notation:
- Dropped scope stays visible:
  `- [x] 3.1.2 ~~Implement external API~~ — using mock data (swap in if
  credits materialize)`
- Moved work leaves the one-line breadcrumb; decimal phases (`3.5`) for
  integrations discovered mid-event.
- Done-by attribution appended: `— done by <owner> in Phase 3`.
- A task or a decimal phase added mid-event goes in through the lane's
  operator route, one at a time.
- A task added mid-event gets its `**Acceptance:**` line when it is added,
  not later. Without it `/do` cannot finish the task.
