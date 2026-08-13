# /plan — tickets mode

Loaded when `tracking: tickets` is the resolved config. Split out of SKILL.md by 4.49 so document-mode runs do not pay for it; the text is unchanged.

## Tickets mode (`tracking: tickets`)

Opt-in per project. Preconditions checked on every tickets-mode invocation:
`gh` present and authenticated, GitHub remote exists. Any failure → name
the exact missing precondition and offer document mode; never guess.

- **seed** is unchanged — BRIEF.md is identical in both modes.
- **build** slims PLAN.md to: purpose blockquote, Gate verdict, milestone
  index table (Milestone | Goal | Exit criterion), the decision log
  (dated `> **Decision:**` blocks — kept IN-DOC in both modes: trackers
  bury close-reasons in comments, the doc keeps them visible),
  cross-cutting risks, and open items. Tasks live as issues, not
  checkboxes.
- **One-time bootstrap — performed by `build`, never by `seed`.** It is
  idempotent, so re-running `build` is the way to repair a partial
  bootstrap. **Why `build` owns it:** milestones are one-per-phase and
  phases do not exist until `build` has written them; `seed` produces
  BRIEF.md, which has no phases to map. This bullet carried no owning mode
  until 2026-08-14, and a live `/health` filled the gap by guessing
  `/plan seed` — the one mode the bullet above rules out (4.73).
  Existing objects are left untouched, never overwritten:
  - Labels, created only if absent: `blocked`, `needs-acceptance`, `bug`,
    `feature`, `chore`.
  - Milestones: one per phase; the phase's exit criterion becomes the
    milestone description (its definition of done).
  - `.github/ISSUE_TEMPLATE/task.md`: scaffold with `## Acceptance
    criteria`, `## Files touched`, `## Out of scope` — so hand-filed
    issues arrive well-formed too.
    **This one is a FILE, and it governs nobody until it is committed and
    pushed** — GitHub serves issue templates from the default branch, so a
    local copy shapes nothing for anyone else. Labels, milestones and
    issues are API objects and exist the moment they are created; the
    template is not, and `/plan` does not push (that is `/ship`'s job).
    **The split is imposed by GitHub, not chosen** — it cannot be designed
    away, so the bootstrap must NAME it: report the template as written but
    **not yet in effect**, with the commit as the outstanding step. Left
    unsaid until 2026-08-14, when a live bootstrap produced a template that
    `ls` found and the API returned 404 for (4.74).
- **Task → issue mapping:** title = task title; body = acceptance criteria
  (runnable where possible) + file paths + out-of-scope; subtasks → a
  checklist in the issue body; milestone = the task's phase.
- **replan** in tickets mode: decision-log supersessions work exactly as in
  document mode; scope moves between milestones are recorded as a dated
  decision in PLAN.md plus a milestone change on the issue.

