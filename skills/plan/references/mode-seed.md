# /plan — mode: seed

Loaded when the dispatch selects `seed`. Split out of SKILL.md by 4.49 so the four other modes do not pay for it; the text is unchanged.

## Mode: seed — write the frozen BRIEF

Interview the user (or take their brain-dump) and write `BRIEF.md` following
`references/brief-template.md`. Required sections — if the user hasn't
supplied one, ask; never silently skip:

**When nobody can answer** — a non-interactive or unattended run — asking is
not an option and inventing is worse. Write the section as
`TBD — not supplied at seed time`, list every TBD together at the top of the
report, and say plainly that the BRIEF is incomplete until they are filled.
A BRIEF with honest gaps is a usable frozen record; one with invented
context is a lie that later work is measured against. Never guess a
constraint, an audience, or a domain landmine — those are exactly the fields
whose fabrication costs the most.

- **Context** — who this is for, why now, what stage, solo or team.
- **Source data / domain landmines** — the gotchas an implementer must know
  (formats, quirks, do-NOT rules). Prompt for these explicitly; every domain
  has them.
- **Architecture Decision: <choice>, NOT <rejected>** — with the reasoning.
- **What I want help with FIRST** — numbered validation items, ending with
  "Don't write code yet."
- **Constraints** — including explicit non-negotiables.
- **What's intentionally out of scope.**
- **Open questions I haven't resolved** — unknowns admitted in writing.
- The closing gate line: validate the architecture with written pushback
  BEFORE any code — be direct, push back, don't be sycophantic.

**BRIEF.md is frozen once committed.** Later corrections are recorded in
PLAN.md as dated decisions with an `(Originally X, changed YYYY-MM-DD)`
breadcrumb. The brief stays an honest record of what was believed at the
start — that is its entire value.

Seed housekeeping (same invocation):
- Ensure `CLAUDE.md` is exactly `@AGENTS.md`. If it has real content, flag it
  and propose moving the content to AGENTS.md — never silently rewrite.
- Ensure AGENTS.md contains the pack's `acstack-conduct` block. **Resolve
  the pack root first** — `setup` symlinks only `skills/*/`, so CONDUCT.md
  and `templates/` are NOT on any path relative to the user's project:

  ```bash
  link="$(readlink "$HOME/.claude/skills/plan" 2>/dev/null || true)"
  pack_root="$(dirname "$(dirname "$link")")"
  # An empty $link makes dirname return "." — which would read the USER'S
  # OWN ./CONDUCT.md and install a foreign block as if it were the pack's.
  # Verify before trusting it:
  [ -n "$link" ] && [ -f "$pack_root/CONDUCT.md" ] || echo "PACK ROOT NOT RESOLVED"
  ```

  If that prints `PACK ROOT NOT RESOLVED` (a copy install rather than
  symlinks, or the skill invoked from elsewhere), **stop and ask the user
  for the pack path.** Do not fall back to a relative path.

  Read the marker-fenced block from `$pack_root/CONDUCT.md` and copy it
  **verbatim**. If the readlink fails (a copy install rather than
  symlinks), say so and ask the user for the pack path — **never
  reconstruct the block from memory.** An invented conduct block is worse
  than none: it looks authoritative and binds the agent to rules the pack
  never wrote. Refresh only between the markers; never touch content
  outside them.
- Ensure AGENTS.md also contains the `acstack-referrals` block, copied
  verbatim from `$pack_root/AGENTS.md` by the same rules (resolve the
  pack root, never reconstruct from memory, refresh only between its
  markers). It rosters the skills an agent cannot see — without it,
  `/plan` and `/eval-spec` are invisible to every session, which means a
  user who never learns to type them has effectively installed a
  smaller pack.
- Create an empty `LEARNINGS.md` if none exists (a place for /learn later).
- Offer to copy `$pack_root/templates/acstack.md` to `.claude/acstack.md`
  if absent — same resolution, same honest stop if it fails.

