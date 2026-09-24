# /do — hackathon lane (`mode: hackathon`)

Read this only when the resolved config sets `mode: hackathon`. It changes
two things: before the task starts, the session gets onto its own task
branch built from the local `main`; and after step 4's commit, `/do` merges
the task into `main` itself. Everything else is unchanged, including the
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
  removing `mode: hackathon` from `.claude/acstack.md` and the
  `acstack:hackathon-lane` block from AGENTS.md.
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
- **Stored counts are not supported.** A count that two tracks both change
  conflicts at landing, and the landing stops. The hackathon template stores
  none; a project that adds one resolves those conflicts by hand.
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
`git rev-parse --path-format=absolute --git-common-dir`,
`git branch --show-current` (prints nothing on a detached HEAD),
`git rev-parse HEAD` and `git rev-parse refs/heads/main`. The session is in
the **main checkout** when the first two print the same path, and in a
**worktree** when they differ.

**A. In the main checkout, detached at the local `main`** (git dir equals
common dir, no current branch, and HEAD equals `refs/heads/main`): this is
how the AGENTS block tells sessions to start. Create the task's worktree from the local `main`:

`git worktree add -b <branch-prefix><id>-<slug> .claude/worktrees/<id>-<slug> refs/heads/main`

then move the session into it with the EnterWorktree tool, passing that
path. If that tool is not available, tell the user to open a new session
inside the new folder and run the task there, and stop. **Why from the
local `main`:** `claude --worktree` and EnterWorktree's own creation branch
from `origin/main` by default, and this lane never pushes, so that base
lacks every task merged so far.

**B. In the main checkout on any other HEAD** — on the `main` branch, or
detached somewhere that is not the local `main`: stop and say so. A commit
made on `main` in a checkout is exactly how another session's merged work
gets reverted (a checkout whose `main` was moved underneath it shows the
other session's files as deleted, and its next commit records that
deletion).

**C. In a worktree on a task branch:** two checks, in this order.
1. `git log --oneline refs/heads/main..HEAD` must print **nothing**. Any
   commit listed is earlier work that never landed, typically a task whose
   acceptance failed on the merged tree. Stop and name those commits:
   starting the next task here would land that work inside it.
2. `git merge-base --is-ancestor refs/heads/main HEAD` — exit 0 means the
   branch already has everything merged so far. Exit 1 means it was made
   from something older: run `git merge --ff-only refs/heads/main`, which
   only moves the branch forward and cannot conflict, since check 1 showed
   the branch holds nothing of its own. If that merge asks for permission
   and nobody can answer, stop and say so.

**D. In a worktree on a detached HEAD:** stop and say so.

## Caches the stack writes

Steps 1 and 4 below require `git status --porcelain` to print nothing, and
running a Python or Node acceptance can leave an untracked cache. Plain
`git status --porcelain` names only the highest untracked folder (`?? pkg/`
for `pkg/__pycache__/m.pyc`), which hides what is inside, so list every
untracked file with `git status --porcelain --untracked-files=all`. A file
may be treated as cache **only if all of these hold**, checked one command
at a time:
- one of its path components is exactly `__pycache__`, `.pytest_cache` or
  `node_modules` (never a general name such as `build` or `dist`, which can
  hold source); call that folder the cache folder;
- `git ls-files -- <cache folder>` prints nothing (git tracks nothing in it);
- for `__pycache__`, every file in the cache folder ends in `.pyc`.

Then append that exact folder name followed by `/` to
`<common dir>/info/exclude`,
where `<common dir>` is the output of
`git rev-parse --path-format=absolute --git-common-dir`. That
file is local to this clone, shared by every worktree, and never committed,
so no track edits a shared file and nothing conflicts. If any condition
fails, the entry is not a cache: stop and report it.

## Integrate into `main`

Run these from your worktree, after the commit in step 4, **one command per
call**, and carry each value forward yourself. In a rehearsal on 2026-09-23
a line that grouped commands in `{ }` with quotes was refused outright
("Contains brace with quote character (expansion obfuscation)"), and
`$( )` would be needed to carry the sha within one line; single commands
went through.

1. `git status --porcelain` — must print **nothing**. `main` receives your
   commits and nothing else, so an uncommitted or untracked file your task
   needs would pass the check here and be missing on `main`. Measured: an
   untracked `helper.py` let the acceptance pass in the worktree, and the
   published `main` failed with `ModuleNotFoundError`. A cache that passes
   every check in "Caches the stack writes" is excluded as described there;
   anything else listed → commit it (if it belongs to the task) or remove
   it, then start again.
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
4. **Re-run the task's `**Acceptance:**` command on the merged tree,** then
   `git status --porcelain` again, which must still print nothing. A check
   that passed without the other tracks' work proves nothing about this
   tree, and a check that wrote tracked or untracked files has tested
   something other than what will be published. A new entry that passes
   every check in "Caches the stack writes" is excluded as described there;
   anything else → stop and report. Failing acceptance → stop and report; do
   not merge.
5. **Re-derive, then close what the merge completed.** The merge may have
   brought in other tracks' ticks and their edits to anything stored.
   (a) If the project stores counts anyway, re-derive them with its own
   tool now, **every time**: two tracks' identical count edits merge with no
   conflict and leave the number wrong (see Scope: a count conflict stops
   the landing).
   (b) If every child of your task's parent is now `[x]`, run the parent's
   `**Acceptance:**` if it has one, and tick the parent only if it passes.
   (c) If every task in the phase is now `[x]`, run the phase's
   `**Exit criterion:**` and tick the phase heading only if it passes. A
   phase with no exit criterion flips when every child is checked, which is
   `/do`'s own phase rule. Commit whatever changed as one more commit before
   step 6. In this lane nobody integrates after you, so nothing else will
   do this.
6. **Run step 2's check again, immediately before the swap.** Step 3's merge
   can wait at a permission prompt for as long as the user takes to answer,
   and the main checkout may have been switched onto `main` meanwhile.
   Re-checking right before the swap leaves only the gap between two
   commands; it does not close it, so the user's side of the rule (never
   switch the main checkout onto `main` while any session is mid-task) still
   matters. Then move `main` forward only if it is still `<base>`:

```bash
git update-ref refs/heads/main HEAD <base>
```

`<base>` is the 40-character sha from step 3, **never a name** such as
`main` or `HEAD`: a name is resolved at the moment of the swap, so it always
matches, and the swap then succeeds even when another session merged in the
meantime. With the sha, `update-ref` is a compare-and-swap: it fails with
`is at <sha> but expected <sha>` if `main` moved. **On that failure, go back
to step 1** and try again, at most five times; then stop and report. With
several sessions waiting at the same permission prompt, each approval moves
`main` under the others, so a retry is expected rather than a fault, and
each retry asks for the gated commands again.

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
