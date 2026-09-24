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

## When the lane applies

- **You are on `main` itself** (a single session in the main checkout):
  the commit already is the integration. Skip the rest of this file.
- **You are on a task branch in a worktree:** integrate as below.
- **The project's AGENTS.md has no `acstack:hackathon-lane` block:** say so
  and stop after the commit, as in standard mode. Personal instructions may
  forbid merging without a pull request, and that block is the project's
  written permission to do otherwise.

## Integrate into `main`

Run these from your worktree, after the commit in step 4, **one command per
call**. Chaining them with `&&`, `{ }` or `$( )` gets the whole line
refused by the harness, measured 2026-09-23, so read each result and carry
the value forward yourself.

1. `git worktree list --porcelain` — if any line reads exactly
   `branch refs/heads/main`, stop (see below). Moving `main` while it is
   checked out leaves that checkout's files stale, and one careless commit
   there reverts everyone's work.
2. `git rev-parse main` — this is `<base>`, the `main` you are merging onto.
   Write the full sha into the next steps.
3. `git merge-base --is-ancestor <base> HEAD` — exit 0 means nobody has
   merged since you branched, so there is nothing to bring in: skip to step
   4. Otherwise run `git merge --no-edit <base>`, which brings every other
   track's merged work into your branch. **Merge, not rebase:** a merge
   rewrites nothing, while a rebase rewrites your branch's commits.
   Measured 2026-09-23: with a rebase, the first session merged because its
   rebase had nothing to do, and the next two stopped at `git rebase`
   waiting for approval.
   **Run it as plain `git merge …`, never `git -C <path> merge …`.** The
   user's permission rules may ask before `git merge`, and a rule written as
   `git merge *` does not match the `-C` form; a session must not route
   around the user's own gate. If the merge asks for permission and nobody
   can answer, stop at the commit and say so.
4. **Re-run the task's `**Acceptance:**` command on the merged tree.** Other
   tracks' work is now in your tree; a check that passed without it proves
   nothing about this one. Failing → stop and report; do not merge.
5. Move `main` forward only if it is still `<base>`:

```bash
git update-ref refs/heads/main HEAD <base>
```

`update-ref` with the old value is a compare-and-swap: it fails with
`is at <sha> but expected <sha>` if another session merged in the meantime.
**On that failure, go back to step 2** and try again, at most three times;
then stop and report. Never drop the third argument. Without it, `main` is
set to your branch whatever it holds, and another session's merged task
disappears from `main` without any warning. Your branch always contains
`<base>` after step 3, so a successful swap only ever moves `main` forward.

**If step 1 finds `main` checked out:** name the path from
`git worktree list` and tell the user to run
`git -C <path> switch --detach main` there. Do not detach it yourself; it may
be another session's working tree.

**If the merge stops on a conflict:** run `git merge --abort`, name the
conflicting files, and stop. A conflict here means two tracks edited the
same file, which the plan's "File ownership" table exists to prevent. Say
which track owns the file. Never resolve it by picking a side.

**The one exception is PLAN.md checkboxes.** Two tracks ticking boxes on
neighbouring lines conflict in git even though neither is wrong. If every
conflicting line in the file is a checkbox line, keep every `[x]` from both
sides, which takes both sides rather than one, then `git add PLAN.md` and
`git commit --no-edit`. Anything else in the conflict → abort and stop, as
above.

## Report

Replace step 5's `committed locally — not pushed` with:

`merged into main at <short sha> (local, not pushed)`

plus the number of attempts if the compare-and-swap had to retry. Pushing
`main` to the remote stays the user's call (`git push origin main`); the
lane never pushes. To start the next task in the same worktree, branch from
the new `main`: `git switch -c <branch-prefix><id>-<slug> main`.
