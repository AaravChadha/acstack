# /do — hackathon lane (`mode: hackathon`)

Read this only when the resolved config sets `mode: hackathon`. It changes
one thing: after step 4's commit, `/do` merges the task into `main` itself.
Everything before the commit is unchanged, including the rule that a task
with no `**Acceptance:**` line is not ticked.

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
  own git worktree of the same repository, so they share one `main`. Several
  *people* on several machines each have their own `main`; reconciling
  those needs a pull or push, which this lane does not do.
- **What it drops, on purpose:** review before merge, CI before merge, a
  linear history (step 3's merge commits land on `main`), and every track's
  checks being re-run on the merged tree. Only the landing task's
  acceptance is re-run.
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
  rehearsal all four landing sessions reported "no permission prompt" while
  the operator had approved prompts in every terminal, because an earlier
  version of this paragraph told them to say so.

## When the lane applies

- **You are on a task branch in a worktree:** integrate as below.
- **You are on `main`, or on a detached HEAD:** stop after the commit and
  say so. The lane needs every session on its own branch; a commit made on
  `main` in a checkout is exactly how another session's merged work gets
  reverted (a checkout whose `main` was moved underneath it shows the other
  session's files as deleted, and its next commit records that deletion).
- **The project's AGENTS.md has no `acstack:hackathon-lane` block:** say so
  and stop after the commit, as in standard mode. Personal instructions may
  forbid merging without a pull request, and that block is the project's
  written permission to do otherwise.
- **The default branch is not called `main`:** read `main` below as that
  branch's name, and `refs/heads/main` as `refs/heads/<name>`.

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
   published `main` failed with `ModuleNotFoundError`. Anything listed →
   commit it (if it belongs to the task) or remove it, then start again.
   **`git status` does not list ignored files.** An acceptance that reads a
   file matched by `.gitignore` (a local `.env`, a data file) passes here
   and may fail for everyone else, and this lane cannot tell. If the task's
   acceptance needs any ignored file, say so in the report.
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
   something other than what will be published. Failing → stop and report;
   do not merge.
5. **Re-derive, then close what the merge completed.** The merge may have
   brought in other tracks' ticks and their edits to anything stored.
   (a) If the project stores counts, re-derive them with its own tool now,
   **every time**, whether or not your task closes anything: two tracks'
   identical count edits merge with no conflict and leave the number wrong.
   (b) If every child of your task's parent is now `[x]`, run the parent's
   `**Acceptance:**` if it has one, and tick the parent only if it passes.
   (c) If every task in the phase is now `[x]`, run the phase's
   `**Exit criterion:**` and tick the phase heading only if it passes; that
   is `/do`'s own phase rule, applied to the merged tree. Commit whatever
   changed as one more commit before step 6. In this lane nobody integrates
   after you, so nothing else will do this.
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
to step 1** and try again, at most three times; then stop and report.

7. **Check the swap did what it should.** `git reflog show refs/heads/main -n 2 --format=%H`
   prints the new and the previous position of `main`, newest first. Then
   `git merge-base --is-ancestor <previous> <new>` must exit 0: the old
   `main` is inside the new one, so nothing was dropped. Exit 1 means
   another session's work fell off `main`. Put it back at once with
   `git update-ref refs/heads/main <previous> <new>`, then stop and report.

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
to the remote stays the user's call
(`git push origin main`); the lane never pushes. To start the next task in
the same worktree, branch from the new `main`:
`git switch -c <branch-prefix><id>-<slug> refs/heads/main`.
