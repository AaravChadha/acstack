# /triage — document mode

Loaded when `tracking` resolves to `document` (the default). Split out of SKILL.md by 4.49; the text is unchanged. The tickets deltas are in `tickets-mode.md`.

## Document mode

**No PLAN.md → stop and say so.** There is no backlog to groom, and
inventing one would be fiction. Name `/plan seed` and stop.

The same rot, PLAN.md-shaped:

1. **Checked but failing.** `[x]` whose `**Acceptance:**` command fails
   now → propose re-open: `~~[x]~~ → **Verdict (date):** re-opened —
   <what broke>`. Run cheap acceptance commands; name the expensive ones
   skipped.
2. **Done but unchecked.** `[ ]` whose artifact plainly exists → VERIFY
   the acceptance actually passes before proposing the tick; existence is
   not acceptance.
3. **No acceptance line.** Task groups without `**Acceptance:**` → listed
   with proposed runnable lines.
4. **Stale open items.** `## Open items` entries dated older than
   `stale-days` → propose: decide now, re-date with a reason, or record
   as deliberately deferred.
5. **Phase-state drift.** Phase headings whose `[ ]`/`[x]` disagrees with
   their children's state or their exit criterion's reality.
