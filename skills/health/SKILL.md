---
name: health
description: Read-only project checkup - three docs present and fresh, CLAUDE.md pointer intact, conduct block current, config valid, secrets clean, attribution honored, learnings alive, tickets-mode prerequisites met. Every failed check comes with its exact fix command, never applied. Use when the user asks for a health check, a project checkup, or whether the project setup is sane.
argument-hint: "[notes]"
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git ls-files:*), Bash(git grep:*), Bash(git remote get-url:*), Bash(ls:*), Bash(cat:*), Bash(grep:*), Bash(command -v:*), Bash(readlink:*), Bash(diff:*), Bash(gh auth status:*), Bash(gh issue list:*), Bash(gh label list:*)
---

# /health — the five-minute project checkup

Answers one question: is this project's acstack setup sound, or quietly
rotting? Named /health, not /doctor — Claude Code ships a built-in
/doctor for its own install, and this skill examines your project, not
your tooling (naming verdict 2026-07-27).

`Adjacent skills:` /audit docs (deep doc-vs-reality drift triples;
/health is the quick structural checkup) · /resume (where the work is;
/health is whether the setup is broken) · /triage (grooms the backlog;
/health checks the scaffolding around it).

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; prints the pull command when behind
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + pack known-bug-classes, capped 6KB
else
  echo "runtime off — proceeding without recall/update-check"
fi
```
<!-- /acstack:runtime -->

<!-- acstack:principles -->
## Operating principles

- Be direct. Push back in writing when the plan or the user is wrong. No sycophancy.
- Never delete a decision. Supersede it: `~~old~~ → **Verdict (YYYY-MM-DD):** new call — reason.`
- Never fix, tune, or delete a test or eval case to raise a score. Log the miss honestly and leave the case unchanged.
- Name exact things: regex patterns, function signatures, model names, before → after numbers. Never "fixed bugs".
- Attribution: follow the project's `attribution` setting (default `none`) — no AI-tool mentions in generated docs, no attribution trailers in commits or PRs. Commit with explicit `-m`/`-F` messages only.
- Config: read `.claude/acstack.md` at the project root (fall back to `~/.claude/acstack.md`) before acting. `## Settings` keys override pack defaults; a `## <skill-name>` section overrides both. Unknown keys and sections are ignored.
- Docs: BRIEF.md (frozen seed) / PLAN.md (living plan) / JOURNAL.md (rolling journal). If the repo uses legacy names (PLANNING_PROMPT.md / PLANNING.md / STATUS.md), use those instead — never create both.
- Recall: if `LEARNINGS.md` exists at the project root, read it before starting.
- Conduct: follow the `acstack-conduct` block in this repo's AGENTS.md — the word is the mode; the user sets the pace.
<!-- /acstack:principles -->

**One document set.** Resolve exactly ONE BRIEF/PLAN/JOURNAL set and name
its path in the report's scope line. If more than one candidate set exists
— a monorepo, nested products, an `apps/*` tree each with its own docs —
list the candidates and STOP. Never pick one silently: a confident answer
about the wrong product is worse than no answer (conduct rule 8).

## Stance

Read-only, always. Every ✗ finding names the exact command or edit that
would fix it — and applies none of them. /health diagnoses; the user
(or /plan, /learn, /journal on request) treats.

## The checks

Exact commands for each live in `references/health-checks.md`. Run all
that apply; skip none silently — a check that can't run (e.g. copy
install instead of symlinks) is reported as `skipped — <why>`.

1. **Docs.** BRIEF/PLAN/JOURNAL present (legacy names accepted and
   named as such). JOURNAL stale if work commits postdate its last
   update. PLAN has an open phase with a runnable exit criterion.
2. **Pointer.** CLAUDE.md is exactly the one-line `@AGENTS.md` pointer.
   Anything else is flagged — never silently rewritten (/plan's rule).
3. **Conduct.** The marker-fenced `acstack-conduct` block exists in
   AGENTS.md and matches the installed pack's CONDUCT.md block. Stale →
   show the refresh edit.
   **Referrals.** The `acstack-referrals` block exists too and matches
   the pack's. It rosters the skills an agent cannot see
   (`disable-model-invocation: true`), so its absence costs the user
   every typed-only skill silently — fix is `/plan seed`, idempotent.
   **One product per repo.** More than one document set below the root,
   or a workspace marker, is reported as **info** — unsupported, not
   broken — naming every set found. The pack models one product per
   repository; with two, a document-reading skill would report on the
   wrong one with full confidence.
4. **Config.** `.claude/acstack.md` readable; keys outside the README
   table listed as info (the extension hook, not an error); mode
   prerequisites consistent — `tracking: tickets` with no gh, no auth,
   or no remote is a ✗.
5. **Secrets.** No .env-class file tracked; no gitignore negation
   un-ignoring one; no obvious key patterns in tracked files; .env
   absent from history (in history → the key is burned; say "rotate").
6. **Attribution.** Recent commit messages honor the `attribution`
   config — default `none` means any AI trailer or tool mention is a ✗.
7. **Learnings.** LEARNINGS.md present and touched within `stale-days`
   (default 30, `## triage` section) — otherwise an info line pointing
   at /learn. A project that stops learning is drifting; this is info,
   not failure.
8. **Tickets extras** (`tracking: tickets` only). gh installed and
   authenticated, the pack label set present, the issue template
   present, stale-issue count vs `stale-days` (count only — the sweep
   itself is /triage's job).

Checks whose artifacts land in wave 4 — hook installed, VERSION and
update-check freshness, conduct-in-global — are added by that wave, and
are not reported as missing before then.

## Report shape

First line is the verdict: `HEALTHY` or `<N> issues, <M> info`. Then
the table — check | ✓ / ✗ / info / skipped | evidence | fix command —
one row per check above, in order. Close with scope: what was checked,
what was skipped and why. No prose padding between the verdict and the
table; the table is the report.
