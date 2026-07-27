# acstack

A skill pack for Claude Code that encodes an engineering discipline: frozen
briefs, plans with runnable exit criteria, journals with exact numbers,
decisions that get superseded instead of deleted, eval scores that are never
inflated, and a hard gate before anything touches a shared database.

Where other packs simulate a team, acstack encodes a discipline — and all of
its memory lives in **your repo**, as committed markdown, not in hidden
machine state.

## Skills

| Skill | What it does | Typical invocation |
|---|---|---|
| `/plan` | Frozen BRIEF.md → written architecture pushback (the gate) → living PLAN.md with runnable exit criteria; honest replanning; hackathon mode; tickets-mode bootstrap | `/plan seed` |
| `/challenge` | Interrogate the BRIEF: premise attacks, a narrower wedge, cost/hours/blast-radius reality checks, proceed/narrow/rethink verdict | `/challenge` |
| `/plan-review` | Engineering lock on PLAN.md: data-flow trace, failure modes, test matrix, hidden assumptions → LOCKED or CHANGES REQUIRED | `/plan-review` |
| `/eval-spec` | The eval is the spec: golden set with category minimums + refusal cases + pinned grader, written before the system exists | `/eval-spec search` |
| `/do` | Complete one numbered subtask (or issue, in tickets mode): execute → verify acceptance → tick the exact box → commit plan+code together → push or PR | `/do 3.2.1` |
| `/ticket` | Capture a brain-dump as a well-formed work item — GitHub issue or PLAN.md task; unknowns marked TBD, never invented | `/ticket "…"` |
| `/investigate` | Root-cause before any fix: minimal repro, hypotheses vs evidence, three-strikes stop rule | `/investigate "500 on save"` |
| `/resume` | Five-minute catch-up: where the project is, divergence flags, next 3 unblocked tasks | `/resume` |
| `/triage` | Backlog hygiene: stale, dupes, missing acceptance, ready work, milestone burn — report first, apply on approval | `/triage` |
| `/journal` | End-of-session JOURNAL.md entry: exact bugs, before→after numbers, eval failure classification, PLAN.md sync | `/journal` |
| `/audit` | code: evidence-led defect report · docs: doc-says/reality-is drift check · eval: failure classification + never-inflate rule | `/audit code src/` |
| `/migrate-check` | Read-only pre-flight for migrations against shared Postgres; per-statement classification; written GO/NO-GO | `/migrate-check` |
| `/learn` | Capture a durable lesson to LEARNINGS.md (symptom → cause → fix, seen-count); recurring lessons promoted into the pack's known-bug-classes | `/learn "…"` |
| `/health` | Read-only project checkup: docs, pointer, conduct block, config, secrets, attribution, learnings, tickets prerequisites — every ✗ with its exact fix command | `/health` |
| `/qa` | Exercise the running app through the probe layer: happy-path flows, adversarial inputs, auth-gate probing; PASS/FAIL report with exact repro commands (http now; browser deferred) | `/qa http://localhost:3000` |
| `/secure` | Confidence-gated security review: findings need an exploit scenario + high/medium/low rating; sweeps auth gates, secrets, injection, LLM tool-use; reports only | `/secure src/` |
| `/design-audit` | Static UI convention check: off-palette colors, wrong name casing, dishonest data labels, AI-slop, leaked internal language — file:line findings with fixes | `/design-audit src/ui/` |

## Install

```bash
git clone https://github.com/AaravChadha/acstack.git ~/Documents/acstack
cd ~/Documents/acstack && ./setup
```

Start a new Claude Code session; the seventeen skills above load as slash
commands. Uninstall with `./setup --uninstall` — it removes only symlinks
that point into this repo.

Requirements: git and a POSIX shell. Nothing else — no runtime, no package
manager, no build step. macOS/Linux; on Windows, copy the `skills/*`
directories into `~/.claude/skills/` manually (symlink support is a roadmap
item).

## The three documents

acstack skills create and maintain three files in each project, each with a
different mutability rule — that difference is the whole design:

- **BRIEF.md** — the frozen seed: context, constraints, non-negotiables,
  out-of-scope, and open questions, ending in a gate that demands written
  architecture pushback before any code. **Never edited after commit** — it
  is the arbitration document for scope disputes.
- **PLAN.md** — the living plan: phases with runnable exit criteria,
  numbered checkbox tasks with acceptance lines. **Changes only additively**
  — strikethrough + dated verdict, decimal phases, breadcrumbs; nothing is
  deleted.
- **JOURNAL.md** — the rolling journal: dated entries recording what
  actually happened, with exact names and before→after numbers. **Grows
  every session** — it's how future-you resumes in five minutes.

Repos that already use the legacy names (`PLANNING_PROMPT.md` /
`PLANNING.md` / `STATUS.md`) are detected and respected — no renames forced.
Project `CLAUDE.md` stays a one-line `@AGENTS.md` pointer; agent rules and
the conduct block live in `AGENTS.md`.

## Conduct

`CONDUCT.md` is the agent interaction contract — ten rules for how the agent
behaves with you (the word is the mode; the user sets the pace; when unsure,
ask; offers hold no expectations; commits carry referenced subjects and no
tool trailers). `/plan seed` installs its marker-fenced block into your
project's AGENTS.md.

## Per-project configuration

Copy `templates/acstack.md` to `.claude/acstack.md` in a project (or
`~/.claude/acstack.md` for personal defaults). Resolution order: pack
default → personal global → project `## Settings` → per-skill section.
Unknown keys and sections are ignored — that's the extension mechanism.

| Key | Values (default first) | Consumed by |
|---|---|---|
| `mode` | `standard` \| `hackathon` | /plan |
| `tracking` | `document` \| `tickets` | all tracking-aware skills |
| `push` | `direct` \| `branch-pr` | /do |
| `branch-prefix` | `feature/` | /do |
| `db` | `shared-prod` \| `local` \| `none` | /migrate-check |
| `attribution` | `none` \| `standard` | all skills |
| `telemetry` | `on` \| `off` (local-only either way) | runtime (coming) |
| `stale-days` | `30` (days; set in a `## triage` section) | /triage, /health |
| `base-url` | (unset; set in a `## qa` section) | /qa |
| `palette`, `product-names` | (unset; set in a `## design-audit` section) | /design-audit |
| `subtask-commit-format` | `completed task <number> (<description>)` | /do |
| `journal-commit-format` | `Journal <date>: <summary>` | /journal |

`attribution: none` (the default) means generated docs, commits, and PR
bodies carry no AI-tool mentions and no attribution trailers. Flip to
`standard` if your project or event requires disclosure.

## Operating principles

Every skill carries this block verbatim (canonical copy below;
`scripts/check.sh` enforces byte-identity):

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

## Repo layout

```
CONDUCT.md            # the agent interaction contract (10 rules)
setup                 # symlink installer / uninstaller
scripts/check.sh      # pack guard: principles drift, banned names, budgets
templates/acstack.md  # per-project config template
skills/<name>/        # one directory per skill: SKILL.md + references/
```

## Development

Run `scripts/check.sh` before committing pack changes. It fails on
principles-block drift, personal/client names in pack content, oversized
SKILL.md files, and shell syntax errors.

## Credits

Structure and ambition inspired by [garrytan/gstack](https://github.com/garrytan/gstack);
the methodology here takes a different road — repo-owned memory, honest
measurement, and zero runtime dependencies.

## License

MIT — see [LICENSE](LICENSE).
