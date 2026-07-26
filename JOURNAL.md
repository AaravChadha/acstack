# JOURNAL — acstack

> **What this file is.** A rolling snapshot of where the pack actually is,
> so a fresh session (or future-you) can open the repo and resume in 5
> minutes. Read this first, then `PLAN.md` for the wave roadmap.
> **Last update**: 2026-07-27. Wave 1 built, verified, and installed; repo
> now self-hosts its own conventions (this file, PLAN.md, AGENTS.md).

## TL;DR

- Five core skills exist, pass the guard, and are symlink-installed:
  /plan, /do, /journal, /audit, /migrate-check.
- 13 commits; working tree clean; `scripts/check.sh` all clean.
- Conduct contract (10 rules) shipped in CONDUCT.md and embedded in this
  repo's AGENTS.md.
- No GitHub remote yet — creation awaits an explicit go (PLAN.md open item).
- Next: wave 2 (gate, eval-spec, tickets mode) — specs written at wave start.

## How to run it right now

```bash
cd ~/Documents/acstack
./setup            # links skills into ~/.claude/skills (idempotent)
scripts/check.sh   # pack guard — must be clean before any commit
# then start a new Claude Code session; the five skills load at start
```

## What's been built

| Wave | Status | Highlights |
|---|---|---|
| 1 — Core + foundation | ✅ | 5 skills (403 SKILL.md lines total, budget 500/each), 9 reference files, setup round-trip verified, guard clean on first run |
| 2 — Gate/eval/tickets | ⬜ | 8 items specced at heading level in PLAN.md |
| 3 — Ship + reflect | ⬜ | 7 skills listed |
| 4 — Distribution + launch | ⬜ | runtime, CI, launch checklist |

## Key decisions and journey (so you don't relearn)

### Wave 1 built end-to-end (2026-07-27)

Starting state: repo had 2 commits (init + CONDUCT.md) and no skills;
`~/.claude/skills/` did not exist on this machine.

Built and committed in sequence: `setup` (installer), config template,
/do, /plan (+3 templates), /journal (+2 references), /audit (+3
references), /migrate-check (+SQL classification), `scripts/check.sh`,
README v1. 10 commits for the wave; every commit subject follows the
lowercase `<verb> <object> (<detail>)` + body convention with no trailers.

Validation: `check.sh` clean on first full run — principles block
byte-identical across 5 skills + README canonical, zero banned names,
all SKILL.md files 65–116 lines (limit 500). Installer round-trip:
5 linked → idempotent re-run (5 ok, no changes) → uninstall removed
exactly 5 → reinstall clean; all symlinks readlink into the repo.

**Why symlinks and not copies:** edits in the repo take effect on next
session with no sync step, and `--uninstall` can safely identify what the
pack owns (only links resolving into this repo are ever removed).

**Why the canonical principles block lives in README, not a shared file:**
relative includes from symlinked skill dirs resolve inconsistently across
tools; byte-identical duplication + a guard that diffs is deterministic.

**What wave 1 does NOT include (intentional):** tickets mode (`tracking:
tickets` is declined at runtime by /do with an honest message), the
per-invocation runtime preamble, telemetry, and the conduct `setup
--global` path — all deliberately deferred to waves 2/4 per PLAN.md.

### Conduct contract created and hardened (2026-07-26 → 27)

Ten rules, three of which came from live corrections during the pack's own
design sessions: explain-means-explain-only (rule 1), user-sets-the-pace
(rule 2), and expectation-free closing questions (rule 9 — "an offer is a
door left open, not a hand held out"). Rule 10 (referenced commit subjects,
what-and-why bodies, no attribution trailers) added 2026-07-27.

### Repo self-hosting (2026-07-27)

The pack now follows its own conventions: CLAUDE.md is the one-line
`@AGENTS.md` pointer, AGENTS.md carries the conduct block plus repo-binding
rules, PLAN.md holds the wave roadmap, this JOURNAL holds history.
check.sh's banned-name sweep extended to cover AGENTS.md, PLAN.md, and
JOURNAL.md so the self-hosting docs can't leak personal context either.

## What's still pending — from you

| Item | Why | What unblocks it |
|---|---|---|
| GitHub remote | Repo is local-only; no backup, no collaborator access | Explicit go for `gh repo create` (private) |
| Fresh-session shakedown | Skills verified statically, not yet run live | Open a new session; run /plan seed on a real project |
| Document-mode commit style | `completed task 3.2.1 (…)` vs terse `3.2.1: <desc>` | One-word decision |

## Important file locations

| Path | Purpose |
|---|---|
| `PLAN.md` | Wave roadmap with exit criteria |
| `CONDUCT.md` | The 10-rule interaction contract (canonical) |
| `README.md` | Canonical `acstack:principles` block + config reference |
| `scripts/check.sh` | Pre-commit guard — run it, always |
| `templates/acstack.md` | Per-project config template |
