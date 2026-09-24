# /do — hackathon lane (`mode: hackathon`)

Read this when the project's AGENTS.md carries the `acstack:hackathon-lane`
block (see `/do`'s pointer to this file for why the block, not the config,
is the switch). It changes two things: before the task starts, the session
gets onto its own task branch built from the local `main`; and after step
4's commit, `/do` merges the task into `main` itself. Everything else is unchanged, including the
rule that a task with no `**Acceptance:**` line is not ticked.

## Why the lane exists

At a timed event with several sessions running at once, the failure is not
bad code reaching `main`. It is integration that never happens. Measured
2026-09-23 with four sessions on one project: **0 of 4** finished tasks
reached `main`, because each session committed on its own branch and
stopped, and the task that depended on two others refused to start because
their work was not on `main` yet. Merging the three branches by hand took
under a second with no conflicts. The missing piece was the step, not git.

## Scope, stated

- **One machine, several sessions, one clone.** Every session works in its
  own git worktree of the same repository, so they share one local `main`.
  Several *people* on several machines each have their own `main`;
  reconciling those needs a pull or push, which this lane does not do.
- **What it drops, on purpose:** review before merge, CI before merge, a
  linear history (step 3's merge commits land on `main`), and other tracks'
  checks being re-run on the merged tree. A landing re-runs its own task's
  acceptance, plus a parent's acceptance or a phase's exit criterion only
  when that landing completes them.
- **It does not read the date.** Switching it off after the event means
  removing the `acstack:hackathon-lane` block from AGENTS.md (and
  `mode: hackathon` from `.claude/acstack.md`).
- **Permission rules.** Step 3's `git merge` goes through the user's rules
  as written. Step 6's `git update-ref` is what actually moves `main`, and a
  rule on `git merge *` does not cover it, so a user who wants every landing
  gated adds `Bash(git update-ref *)` to their `ask` rules. This paragraph
  describes the possibilities; it is not something to repeat as a fact. A
  session usually cannot see whether its own command was approved at a
  prompt or allowed with none, so the report states only what the session
  observed, and never "no prompt fired". Measured 2026-09-23: in a live
  rehearsal all three sessions reported "no permission prompt" while the
  operator reported approving prompts in every terminal, because an earlier
  version of this paragraph told them to say so.
- **Stored counts are not supported.** Two tracks changing the same count
  either merge silently to a wrong number (identical edits) or conflict and
  stop the landing. Step 5(a) re-derives a count after a merge, which fixes
  the first case only when the project has a tool for it. The hackathon
  template stores none.
- **Rolling `main` back during the event:** stop every session first. A
  session already mid-landing can land again on top of the rolled-back
  `main`, because nothing tells it the move was deliberate.
- **"Nothing was dropped" is about history, not file contents.** Step 7
  checks that the commits on `main` before your landing are still in it. A
  commit made in a checkout that has `main` checked out can still delete
  another track's file with that history intact, which is why nobody edits
  in the main checkout.

## When the lane applies

- **The project's AGENTS.md has no `acstack:hackathon-lane` block:** say so
  and follow standard mode. Personal instructions may forbid merging
  without a pull request, and that block is the project's written
  permission to do otherwise.
- **The default branch is not called `main`:** read `main` below as that
  branch's name, and `refs/heads/main` as `refs/heads/<name>`.
- Otherwise, **before writing anything**, get onto a task branch as below.

## Before the task: a task branch built from the local `main`

Work out where the session is, one command per call:
`git rev-parse --path-format=absolute --git-dir`,
`git rev-parse --path-format=absolute --git-common-dir` and
`git branch --show-current` (prints nothing on a detached HEAD). The session
is in the **main checkout** when the first two print the same path, and in a
**worktree** when they differ.

**Do this section before `/do`'s own "Before starting" reads PLAN.md.** The
main checkout can sit on an older commit than `main`, because landings move
`main` without touching it, so its PLAN.md can be missing tasks and ticks
that are already on `main`. Read PLAN.md, and check whether another track's
work has landed, only from inside the worktree after C, or with
`git show refs/heads/main:PLAN.md`.

**Find this task's branch by its ID, not by a name you choose.**
`git for-each-ref --format='%(refname:short)' 'refs/heads/<branch-prefix><id>-*'`
lists branches already made for task `<id>` (for example `feature/1.4-*`
for task 1.4). A slug is only chosen when that prints nothing. If it prints
more than one, stop and list them.

**One task, one session.** The lane cannot tell a worktree whose session
stopped from one whose session is still working, for example waiting at a
permission prompt. Give each task to one session.

**A. In the main checkout, on a detached HEAD.** This is how the AGENTS
block tells sessions to start. It does not matter which commit the checkout
sits on, since the worktree is built from `refs/heads/main` itself.
- An existing branch for this task that `git worktree list --porcelain`
  shows checked out → move the session into that worktree with the
  EnterWorktree tool and continue at C (this resumes a task that stopped).
- An existing branch for this task that no worktree has →
  `git worktree add .claude/worktrees/<branch-name-without-prefix> <branch>`,
  move in, continue at C.
- None → `git worktree add -b <branch-prefix><id>-<slug> .claude/worktrees/<id>-<slug> refs/heads/main`,
  move in, continue at C. **Check the folder first:** if
  `.claude/worktrees/<id>-<slug>` already exists (a worktree reused for a
  later task keeps its first name), use `<id>-<slug>-2`, then `-3`. Checking
  after is too late: a `git worktree add -b` that fails on the folder has
  already created the branch, and the retry then fails on the branch.

If the EnterWorktree tool is not available, tell the user to open a new
session inside that folder and run the task there, and stop. **Why from
`refs/heads/main`:** `claude --worktree` and EnterWorktree's own creation
branch from `origin/main` by default, and this lane never pushes, so that
base lacks every task merged so far. To run the demo in the main checkout,
bring it up to date with `git switch --detach main` once no session is
mid-landing. If that refuses because untracked files would be overwritten
(typically a lockfile such as `package-lock.json` left by a local
`npm install`), move those files aside, switch, and install again.

**B. In the main checkout, on a branch** (including `main`): stop, and tell
the user to run `git switch --detach main` there and start the session
again. A commit made on `main` in a checkout is exactly how another
session's merged work gets reverted (a checkout whose `main` was moved
underneath it shows the other session's files as deleted, and its next
commit records that deletion).

**C. In a worktree on a task branch** (a branch other than `main`), in this
order. "This task's branch" means a branch whose name starts with
`<branch-prefix><id>-`, the dash included, so `1.1-` never matches `1.10-`.
0. `git rev-parse -q --verify MERGE_HEAD` — if it prints a sha, an earlier
   landing stopped halfway through step 3's merge. Run `git merge --abort`:
   it undoes only that unfinished merge, the task's commits stay, and
   step 3 merges again. Never finish it by removing files: the half-done
   merge holds other tracks' work, and removing it deletes that work from
   `main`. Then `git status --porcelain --untracked-files=all` must print
   nothing except files that pass the cache checks below, and changes
   **this session made for this same task earlier in this conversation** (a
   retry after a failed acceptance). Anything else (a file you did not
   write here, a leftover from another task) → stop and list it; it would
   otherwise ride into this task's commit or block the next step.
1. `git log --no-merges --format='%h %s' refs/heads/main..HEAD` lists this
   branch's own commits that are not on `main`. `--no-merges` leaves out the
   lane's own merges of `main` into the branch (step 3 below), which bring in
   only commits already on `main`.
   - **None, on this task's branch:** go to 2.
   - **None, on another branch:** get onto this task's branch. An existing
     one (see above) that `git worktree list --porcelain` shows checked out
     elsewhere → stop and name that worktree; the task continues there. An
     existing one checked out nowhere → `git switch <branch>` and **start C
     again at 0**, since it may hold unlanded commits of its own. None →
     `git switch -c <branch-prefix><id>-<slug> refs/heads/main`, then go to 2.
     A session doing a second task in the same worktree lands here.
   - **Some, on this task's branch:** every commit on it was made for this
     task, whatever its subject says (step 5's closing commit, a fix-up, a
     configured commit format). Read this task's box in this worktree's
     PLAN.md. **`[x]`:** the task was finished but never landed, for
     example stopped at an unanswered merge or `update-ref` prompt, a failed
     swap, or a failed merged-tree acceptance; do not redo it, which
     overrides `/do`'s "already done, stop" rule for this case, and go
     straight to "Integrate into `main`". **`[ ]`:** the task is unfinished;
     skip 2, finish it on this branch, then commit and integrate as usual.
   - **Some, on any other branch:** stop and name them; starting this task
     here would land that work inside it.
2. `git merge-base --is-ancestor refs/heads/main HEAD` — exit 0: the branch
   already has everything merged so far. Exit 1: run
   `git merge --ff-only refs/heads/main`. If it fails (for example
   "untracked working tree files would be overwritten") or asks for
   permission and nobody answers, stop and report git's message.

**D. In a worktree on `main` or on a detached HEAD:** stop and say so. A
commit on `main` there moves `main` with no merge, no swap and no prompt.

## Caches the stack writes

Step C0 and Integrate steps 1, 4 and 5 require a clean `git status`, and
running a Python or Node acceptance can leave an untracked cache. Plain `git status --porcelain`
names only the highest untracked folder (`?? pkg/` for
`pkg/__pycache__/m.pyc`), which hides what is inside, so list every
untracked file with `git status --porcelain --untracked-files=all`. A file
is cache **only if all of these hold**, checked one command at a time:
- it lies inside a folder named exactly `__pycache__` or `.pytest_cache`
  (at any depth), or inside a `node_modules` folder that sits directly
  beside a tracked `package.json` (for `web/node_modules/`,
  `git ls-files -- web/package.json` prints it). Never a
  general name such as `build` or `dist`, and never a `node_modules` with no
  `package.json` beside it, which can hold a track's source;
- `git ls-files -- <that folder>` prints nothing (git tracks nothing in it);
- for `__pycache__`, every file in that folder ends in `.pyc`.

Then add that folder's **exact path**, anchored with a leading slash
(`/pkg/__pycache__/`, `/node_modules/`), as one line of
`<common dir>/info/exclude`, where `<common dir>` is the output of
`git rev-parse --path-format=absolute --git-common-dir`. That file is local
to this clone, shared by every worktree, and never committed, so no track
edits a shared file; the anchored path hides only that folder, never a
same-named folder elsewhere. If any condition fails, it is not a cache:
stop and report it, and name the line from the hackathon template's
`.gitignore` that would cover it, if one does; `.gitignore` belongs to
Phase 0, so the user adds that line on `main`.

**Limit:** worktrees under `.claude/worktrees/` sit inside the main
checkout, and Node looks for `node_modules` in parent folders, so an
acceptance in a worktree can pass using packages installed only in the main
checkout. Install dependencies in each worktree (`npm install` there)
before relying on a Node acceptance. **pytest does the same with
`conftest.py`:** with no pytest configuration file in the project, pytest in
a worktree can pick up the main checkout's `conftest.py`, so a test passes in
the worktree and fails elsewhere. Commit a `pytest.ini` (or
`[tool.pytest.ini_options]` in `pyproject.toml`) so each worktree is its own
root. **An editable install does it too:** a venv made in the main checkout
with `pip install -e .` imports the main checkout's code, not the
worktree's, so the check runs old code, and its traceback points at a file
in the main checkout, which nobody edits. Make the venv inside each
worktree, or run the checks without an editable install.

## Integrate into `main`

Run these from your worktree, after the commit in step 4, **one command per
call**, and carry each value forward yourself. In a rehearsal on 2026-09-23
a line that grouped commands in `{ }` with quotes was refused outright
("Contains brace with quote character (expansion obfuscation)"), and
`$( )` would be needed to carry the sha within one line; single commands
went through.

1. `git status --porcelain --untracked-files=all` — must print
   **nothing**. `main` receives your commits and nothing else, so an
   uncommitted or untracked file your task needs would pass the check here
   and be missing on `main`. Measured: an untracked `helper.py` let the
   acceptance pass in the worktree, and the published `main` failed with
   `ModuleNotFoundError`. A cache that passes every check in "Caches the
   stack writes" is excluded as described there. Anything else listed that
   this task wrote → commit it; anything this task did not write → stop and
   name it. **Never commit a secrets file** (`.env`, `.env.local`, any
   `.env.*` but `.env.example`): stop and tell the user to add it to
   `.gitignore` on `main`.
   `git status --porcelain --ignored` also lists ignored files (`!!`
   lines). Those never reach `main`. Name any that are present in the
   report, as a fact about the worktree; whether the acceptance reads them
   is not something this step establishes, so do not claim it either way.
2. `git worktree list --porcelain` — if any line reads exactly
   `branch refs/heads/main`, stop (see below). Moving `main` while it is
   checked out leaves that checkout's files stale, and one ordinary commit
   there reverts everyone's work.
3. `git rev-parse refs/heads/main` — this 40-character sha is `<base>`.
   Always the full `refs/heads/main`: a tag called `main` makes the short
   name ambiguous. Then `git merge-base --is-ancestor <base> HEAD` — exit 0
   means nobody has merged since you branched: skip the merge. Otherwise
   run `git merge --no-edit <base>`, which brings every other track's merged
   work into your branch. **Merge, not rebase:** a merge rewrites nothing,
   while a rebase rewrites your branch's commits, and permission rules that
   ask before a rebase stopped two of three sessions in a rehearsal.
   **Run it as plain `git merge …`, never `git -C <path> merge …`.** A rule
   written as `git merge *` does not match the `-C` form, and a session
   must not route around the user's own gate. If the merge asks for
   permission and nobody can answer, stop at the commit and say so.
4. **If a merge into this branch changed a dependency file**
   (`package.json`, a lockfile, `requirements.txt`, `pyproject.toml`), in
   this run or in an earlier run of a resumed landing, install dependencies
   again in this worktree first, with the command that installs exactly
   what the committed files say and writes nothing: `npm ci` (never
   `npm install`, which rewrites the lockfile), `pip install -r
   requirements.txt`. If `npm ci` fails because no lockfile is committed,
   stop and say so; Phase 0 owns that file. Then **re-run the task's
   `**Acceptance:**` command on the merged tree,** then
   `git status --porcelain --untracked-files=all` again, which must still
   print nothing. A check that passed without the other tracks' work proves
   nothing about this tree, and a check that wrote tracked or untracked
   files has tested something other than what will be published. A new
   entry that passes every check in "Caches the stack writes" is excluded as
   described there; anything else → stop and report. **Failing acceptance:
   do not swap.** If the fix lies in this task's own files, make it on this
   branch, commit it, and start again at step 1. If it needs another track's
   file, stop and name the file and the track that owns it.
5. **Re-derive, then close what the merge completed.** The merge may have
   brought in other tracks' ticks and their edits to anything stored.
   (a) If the project stores counts anyway, re-derive them with its own
   tool now, **every time**: two tracks' identical count edits merge with no
   conflict and leave the number wrong (see Scope; when the two edits
   differ, they conflict instead and the landing stops).
   (b) If every child of your task's parent is now `[x]`, run the parent's
   `**Acceptance:**` if it has one, and tick the parent only if it passes.
   (c) If every task in the phase is now `[x]`, run the phase's
   `**Exit criterion:**` and tick the phase heading only if it passes.
   On a retry, run (b) and (c) again even when an earlier attempt already
   ticked the box here: the tree has changed. If the check now fails, stop
   and report; do not swap. A
   phase with no exit criterion flips when every child is checked, which is
   `/do`'s own phase rule. Stage **only** PLAN.md, plus any count file
   re-derived in (a), by name and commit it as one more commit, in this task's
   commit format (for example `task <id>: close 1.2`). Then
   `git status --porcelain --untracked-files=all` must print nothing again,
   caches aside: a parent acceptance or exit criterion that wrote files has
   tested something other than what lands, so stop and report. In this
   lane nobody integrates after you, so nothing else will do this.
6. **Run step 2's check again, immediately before the swap.** Step 3's merge
   can wait at a permission prompt for as long as the user takes to answer,
   and the main checkout may have been switched onto `main` meanwhile.
   Re-checking right before the swap leaves only the gap between two
   commands; it does not close it, so the user's side of the rule (never
   switch the main checkout onto `main` while any session is mid-task) still
   matters. Then `git merge-base --is-ancestor <base> HEAD` once more: exit
   1 means this branch does not contain `<base>` (a sha carried over from an
   earlier attempt), and the swap below would still succeed and drop the
   commits in between, so go back to step 3. Then move `main` forward only
   if it is still `<base>`:

```bash
git update-ref refs/heads/main HEAD <base>
```

`<base>` is the 40-character sha from step 3, **never a name** such as
`main` or `HEAD`: a name is resolved at the moment of the swap, so it always
matches, and the swap then succeeds even when another session merged in the
meantime. With the sha, `update-ref` is a compare-and-swap: it fails with
`is at <sha> but expected <sha>` if `main` moved. **On that failure, go back
to step 1** with a fresh `<base>`, for at most **ten attempts in all**; then
stop and report. Each failure means another session landed, so the lanes as
a whole never stall, but one session can keep losing: a session that has
just landed branches from the tip of `main` and needs one approval, while
the one that lost needs a merge, a fresh acceptance run and a swap. In a
simulation of four sessions with 1-3 minute tasks, a session lost six times
in a row. Each retry asks for the gated commands again.

7. **Check your own swap.** `git reflog show refs/heads/main -n 10 --format=%H`
   lists where `main` has pointed, newest first; another session may already
   have moved it after you. Find the line equal to your commit (`git
   rev-parse HEAD`); the line after it is where `main` was just before your
   swap, `<previous>`. `git merge-base --is-ancestor <previous> HEAD` must
   exit 0: everything on `main` before your landing is inside it. Exit 1
   means your landing dropped commits, which only happens when `<base>` was
   not the sha from step 3. **Do not move `main` back yourself**; `main` may
   have moved again since, or the user may have moved it on purpose. Report
   `<previous>` and your commit, and stop. If your commit is not in the list,
   or has no line after it (a bare repository keeps no reflog by default),
   say the check could not run.

**If step 2 finds `main` checked out:** name the path from
`git worktree list` and tell the user to run
`git -C <path> switch --detach main` there. Do not detach it yourself; it may
be another session's working tree.

**If the merge stops on a conflict:** run `git merge --abort`, name the
conflicting files, and stop. A conflict here means two tracks edited the
same file, which the plan's "File ownership" table exists to prevent. Say
which track owns the file. Never resolve it by picking a side.

**The one exception is PLAN.md checkboxes.** Two tracks ticking boxes on
neighbouring lines conflict in git even though neither is wrong. If, for
every conflicting line, the two sides differ **only** by `[ ]` against
`[x]`, keep the `[x]`, which takes both sides' ticks, then `git add PLAN.md`
and `git commit --no-edit`. Any other difference, including a struck-out
`~~[x]~~` on one side or a line present on only one side → abort and stop,
as above.

## Report

Replace step 5's `committed locally — not pushed` with:

`merged into main at <short sha> (local, not pushed)`

plus the number of attempts if the compare-and-swap had to retry, and step
7's result. Say nothing about whether a permission prompt appeared unless
the session actually saw one; see "Permission rules" above. Pushing `main`
to the remote stays the user's call (`git push origin main`); the lane never
pushes. To start the next task in the same worktree, branch from the new
`main`: `git switch -c <branch-prefix><id>-<slug> refs/heads/main`.
