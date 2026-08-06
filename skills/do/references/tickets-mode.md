# /do — tickets mode

Loaded when `tracking: tickets` is the resolved config. Split out of SKILL.md by 4.49; the text is unchanged. Document mode is the default and is the sequence in SKILL.md itself.

## Tickets mode (`tracking: tickets`)

Preconditions first: `gh` present and authenticated, GitHub remote exists.
Any failure → name the exact missing precondition, offer document mode.

1. **Pick up.** `/do 42` (or `#42`) takes that issue. Bare `/do` proposes
   the top unblocked open issue in the current milestone (no `blocked`
   label) and confirms before starting — it never just begins.
2. **Branch.** `<branch-prefix><n>-<slug>` (e.g. `feature/42-fix-parser`)
   — issue work is branch work. Created locally; not pushed.
3. **Work and commit.** Subjects use the tickets shape per CONDUCT rule 10:
   `#42: <subject>`. Issue-body checklist items are ticked via
   `gh issue edit` as they complete — the issue tracks progress the way
   PLAN.md checkboxes do in document mode.
4. **Verify.** Run the issue's `## Acceptance criteria` before anything
   closes. A failing acceptance becomes an issue comment with the exact
   output — the issue stays open, the failure is not papered over.
5. **Close via merge.** Work that completes the issue carries `Fixes #42`
   in the final commit body; partial work references `#42` without `Fixes`.
   The branch stays local until the user pushes it or runs `/ship` — the
   issue closes when the branch merges, which is a human act either way.
6. **Report and propose** as in document mode; "groupable next" =
   unblocked issues in the same milestone touching the same files.
