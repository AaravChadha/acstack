# /triage — tickets mode

Loaded when `tracking: tickets` is the resolved config. Split out of SKILL.md by 4.49; the text is unchanged. Document mode is the default and is in `document-mode.md`.

## Tickets mode (`tracking: tickets`)

Preconditions — `gh` installed, `gh auth status` succeeding, and a
GitHub remote present. Any failure names WHICH one failed and offers
document mode; never guess. The sweep:

1. **Stale.** Open issues with no activity in `stale-days` days → propose
   close-with-reason (`superseded by #M` / `no longer planned — <reason>`)
   or re-prioritize into a milestone. Staleness is evidence of drift, not
   a death sentence — the proposal says which, per issue.
2. **Duplicates.** Candidate pairs with the overlapping text QUOTED as
   evidence. The newer closes as `duplicate of #N` — only after the user
   confirms the pair is real.
3. **Missing acceptance.** Issues without an `## Acceptance criteria`
   section → listed, labeled `needs-acceptance`; the report proposes
   acceptance lines where the issue body implies them.
4. **Unblocked-but-unassigned.** In the current milestone, no `blocked`
   label, no assignee → surfaced as ready work, ordered by milestone
   position.
5. **Milestone burn.** Per milestone: open/closed counts, the exit
   criterion restated from its description, and an honest verdict on
   whether what remains can meet it — "12 open, 3 weeks of history says
   2/week" is a verdict; "tight but doable" is not.
