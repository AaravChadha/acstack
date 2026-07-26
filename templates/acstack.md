# acstack project config

Copy this file to `.claude/acstack.md` in your project (or `~/.claude/acstack.md`
for personal defaults everywhere). acstack skills read it before acting.

Everything is optional — missing keys fall back to pack defaults. Unknown keys
and sections are ignored, never errors. Resolution order: pack default →
`~/.claude/acstack.md` → this file's `## Settings` → a `## <skill-name>`
section here. This file is the ONLY place client, company, and collaborator
context belongs — never inside the pack's skills.

## Settings

- mode: standard              # standard | hackathon
- tracking: document          # document (PLAN.md checkboxes) | tickets (GitHub Issues)
- push: direct                # direct (git push) | branch-pr (feature branch + PR)
- branch-prefix: feature/     # used when push is branch-pr
- db: shared-prod             # shared-prod | local | none — /migrate-check strictness
- attribution: none           # none (no AI mentions/trailers in generated docs & commits) | standard
- telemetry: on               # on (local-only usage log) | off
- subtask-commit-format: completed task <number> (<description>)
- journal-commit-format: Journal <date>: <summary>

## Collaborators

<!-- Name (github: handle) — area. Used for owner tags in hackathon plans
     and PR routing. Example:
- Priya Nair (github: priyanair) — frontend
- Rohan Mehta (github: rohanm) — data pipeline -->

## Conduct

<!-- Project- or user-specific conduct rules, applied IN ADDITION to the ten
     defaults in the pack's CONDUCT.md. /learn promotes repeated corrections
     here. Example:
- Never touch files under legacy/ without asking. -->

## Notes for skills

<!-- Free-form project context skills read verbatim: client naming rules,
     deploy cadence, review expectations, domain landmines. -->

## migrate-check

<!-- Per-skill overrides. Example:
- backup-command: pg_dump "$DATABASE_URL" > backups/pre_$(date +%Y%m%d_%H%M%S).sql -->
