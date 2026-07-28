# JOURNAL — acstack

> **What this file is.** A rolling snapshot of where the pack actually is,
> so a fresh session (or future-you) can open the repo and resume in 5
> minutes. Read this first, then `PLAN.md` for the wave roadmap.
> **Last update**: 2026-07-27 (third entry that day). Waves 1, 2, AND 3
> built, reviewed, and shakedown-passed — 19 skills, the full roster. The
> repo is now on GitHub (private). Wave 4 (distribution + launch) is next.

## TL;DR

- Nineteen skills — the full roster — exist, pass the guard, and are
  symlink-installed. Wave 3 added the last seven: /learn, /health, /qa,
  /secure, /design-audit, /retro, /ship.
- Tickets mode (`tracking: tickets`) is live in /plan and /do — bootstrap,
  `#N:` commits, `Fixes #N` closes — proven on scratch repo
  `acstack-w2-shakedown` (private; deletion pending user call).
- Working tree clean; `scripts/check.sh` all clean; `./setup` links 19.
- Conduct contract (10 rules) shipped in CONDUCT.md and embedded in this
  repo's AGENTS.md.
- Remote live (2026-07-27): private `AaravChadha/acstack`, `main` pushed;
  public flip waits on the wave-4 launch checklist.
- Next: wave 4 (distribution + launch) — runtime preamble, bin/, VERSION,
  telemetry, CI, README v2, launch checklist.

## How to run it right now

```bash
cd ~/Documents/acstack
./setup            # links skills into ~/.claude/skills (idempotent)
scripts/check.sh   # pack guard — must be clean before any commit
# then start a new Claude Code session; the twelve skills load at start
```

## What's been built

| Wave | Status | Highlights |
|---|---|---|
| 1 — Core + foundation | ✅ | 5 skills (403 SKILL.md lines total, budget 500/each), 9 reference files, setup round-trip verified, guard clean on first run |
| 2 — Gate/eval/tickets | ✅ | 7 new skills + tickets mode (12 SKILL.md files now total 1080 lines; 14 reference files); specs → build → independent review (6 findings fixed) → scratch-repo shakedown passed |
| 3 — Ship + reflect | ✅ | 7 new skills (/learn, /health, /qa, /secure, /design-audit, /retro, /ship); 19 SKILL.md files now, 21 reference files; specs → build → independent review (9 findings, 0 blocking) → two-venue shakedown (seeded scratch app + acstack) that earned a real secret-regex fix |
| 4 — Distribution + launch | ⬜ | runtime, CI, launch checklist |

## Key decisions and journey (so you don't relearn)

### Wave 3 built, reviewed, and shakedown-passed (2026-07-27 evening)

Starting state: 12 skills, wave-3 items specced at heading level only,
repo local-only. Ending state: 19 skills (the full roster), repo on
GitHub (private), wave 3 ticked with evidence.

Process ran the same spec → approval → build → check → review → shakedown
order as wave 2. Specs first (`docs/wave-3-specs.md`, all seven at
waves-1/2 fidelity), one commit per skill in the order /learn → /health →
/qa → /secure → /design-audit → /retro → /ship, `check.sh` clean before
every commit, each commit carrying its own README rows so no doc-drift
window opened.

**Two decisions settled at spec time (both parked for the user, both
recorded):** browser probe **deferred** to first real need — wave 3 ships
the http probe with the seam designed for both modes, so browser mode is
additive later (locked-decision-8's no-penalty bet); /retro ships
**without** a usage-stats section (it arrives with wave-4 telemetry, so
no placeholder). All seven skills are model-invocable — the first
zero-user-only wave; the report-shaped five can only mis-fire into
thoroughness, /learn follows /ticket's frictionless-capture precedent,
and /ship follows /do's (it acts, but only on explicit ship intent, and
every failing gate stops the release with no force path).

**The probe seam is the wave's architectural deliverable.** A probe
exposes reach/act/observe; the skill's method and report never name a
transport. http is implemented; an attempted `probe: browser` declines
honestly with the dated deferral and offers http. The report skeleton is
identical either way — that identity is the seam proof the exit criterion
demanded, and when the browser probe lands only the reference file grows.

**Independent review (9 findings, 0 blocking).** A subagent reviewed all
seven skills against the spec and pack conventions; guard-enforced
dimensions (principles byte-identity, banned names, budgets, read-only
stances) verified clean. Fixed: a no-op `while` loop and a
regex-not-fixed-string journal grep in ship-gates.md; the document-mode
PLAN tick now commits to the branch before push (it had dirtied the tree
gate 1 certifies clean); README config table (`push` missing /ship,
`journal-commit-format` missing /retro); a stale `/doctor` reference in
CONDUCT.md (which ships into adopter projects); /secure's verdict rule
made unambiguous so a medium-only report can't hide behind "no
high-confidence findings"; the known-bug-classes lookalike trio corrected
(U+202F/U+00A0/U+2013, not emoji); two high-noise greps tightened.
Genericized the one finance-flavored example (portfolios/holdings →
orders) per the generic-core rule. Not changed: three skills name
accurate `Adjacent skills:` neighbors beyond the spec's non-exhaustive
list — enhancement, kept.

**Shakedown across two venues earned a real fix.** On acstack itself
(document mode): /health produced an honest report — correctly flagging
the mid-wave-stale JOURNAL and the deliberately-external BRIEF (acstack's
seed is the design doc outside the repo); /secure ran clean (`no
findings` on a markdown-and-shell pack); /retro produced a real trend
(verdict on-plan, honest "no eval/ — not assessable", browser-probe and
GitHub-remote risks both retired this session). On a seeded scratch app
(stdlib http server with a hardcoded key, an unauthenticated `/admin`, an
unvalidated int cast, an off-palette color, an unlabeled mock-data
chart): /qa http mode found the auth gap (200 on unauth `/admin`) and the
`limit=abc` crash, passed the benign adversarial inputs, and the browser
mode declined honestly — seam proven; /secure found the key and the auth
gap with high confidence; /design-audit flagged the `#ff00aa` off-palette
color, the `mockData` revenue chart, and the slop copy while sparing the
in-palette token colors; /ship ran all five gates on a feature branch
that hardened the crash (verified: `limit=abc → 400`); /learn captured a
lesson, bumped `seen` on the repeat without duplicating, and proposed
promotion at seen ≥ 2.

**The fix the shakedown earned:** the seeded key `sk-live-…` made both
/secure and /health report clean — `sk-[A-Za-z0-9]{20,}` stops at the
first hyphen after the prefix, so it misses `sk-proj-…` (OpenAI project
keys), `sk_live_…` (Stripe), and `sk-live-…`. Widened both patterns to
`sk[-_][A-Za-z0-9_-]{20,}`, verified against all three formats plus a
bare `sk-…`, and promoted the class into known-bug-classes.md via
/learn's own promotion path (applied here because this is the pack repo
and the gap is verified). A genuine security miss a passing-looking sweep
would have hidden.

**Incidental find (test-harness, not a pack defect):** an early /qa
server never died and held port 8799, so later "fresh" servers silently
failed to bind and a fix looked broken (`limit=abc → [000]`) until the
stale process was hard-killed — then the fix verified correctly. Chased
it down rather than reporting a false gate failure; noting it so the next
shakedown kills prior servers first.

**What wave 3 does NOT change (intentional):** no Playwright/browser
probe (deferred; seam ready), no /retro usage-stats (wave 4), no wave-4
runtime (preamble, bin/, VERSION, telemetry, CI, `setup --global`), no
Linear/Jira. The `gh pr create` + `Fixes #N` plumbing /ship reuses was
proven end-to-end by /do in the wave-2 scratch repo and was not re-run
against a live remote this wave (stated, not a gap).

Validation close: `check.sh` clean on every wave-3 commit; skills 12 →
19; SKILL.md files 12 → 19 (largest still /plan at 145 of 500 budget);
reference files 14 → 21; setup round-trip 19 linked, 0 skipped; the seven
new skills registered in the model-facing list mid-session (no restart
needed for model-invocable skills — confirms wave 2's incidental find).

#### Retro (2026-07-27 — wave 3)

- **Velocity vs plan:** wave 3 scoped at 7 skills, all 7 delivered in one
  session; no dated per-phase targets in PLAN, so velocity is reported as
  raw close-rate, not vs-plan slippage.
- **Eval trend:** no `eval/` in this repo — not assessable (the pack is
  skills + shell, not an eval'd product). One honest line, as designed.
- **Failure-category trends:** this session — doc-drift (README config
  rows, CONDUCT `/doctor`), reference-command bugs (no-op loop,
  regex-vs-fixed-string), and one security-regex gap. The regex gap is
  the sole recurrence-worthy class and was promoted to known-bug-classes.
- **Risk review:** browser-probe timing → **retired** (deferred by
  verdict); GitHub remote → **retired** (created private this session);
  document-mode commit style → **still open** (owner: user).

### Wave 2 built, reviewed, and shakedown-passed (2026-07-27)

Starting state: 5 skills, 13 commits, wave-2 items specced at heading level
only. Ending state: 12 skills, 30 commits, wave 2 ticked with evidence.

Process ran spec → build → check → review → verify, in that order. Specs
first (`docs/wave-2-specs.md`, all eight items at wave-1 fidelity), then
one commit per skill in the build order, `check.sh` clean before every
commit, an independent review pass, then the exit-criterion shakedown.

**Invocation-split revision (before build):** /challenge, /plan-review,
and /triage flipped from user-only to model-invocable with intent-scoped
descriptions. **Why model-invocable and not the stricter flag:** users
don't memorize twelve commands; the conduct contract (rules 2 and 5)
already blocks uninvited gate-firing, and these skills are report-shaped
so a mis-fire costs thoroughness, never state. /eval-spec stays user-only
(creates committed artifacts, sets targets). Added the disambiguation
rule: when a phrase matches several skills, present candidates with
one-liners; every new SKILL.md carries an `Adjacent skills:` routing line.

**Independent review earned its step:** 6 findings, 1 blocking —
`stale-days` was implemented but undocumented in README's config table
and templates/acstack.md; /challenge's report shape contradicted the
verdict-up-front stance the spec itself demanded (fixed: verdict is now
the report's first line, scope section added, spec revised with a dated
note); /investigate's tickets section was missing the precondition check;
a phantom BRIEF "stakes section" was reworded.

**Shakedown evidence (scratch repo `acstack-w2-shakedown`, private):**
bootstrap created 4 labels + 2 milestones and proved idempotency on
re-run — including leaving GitHub's default `bug` label untouched;
/ticket turned a brain-dump into well-formed issue #5; /do closed #1 via
`feature/1-scaffold-cli-count` + `Fixes #1` on direct push (acceptance
`count → 4` run first, checklist ticked via `gh issue edit`); /triage
closed dupe #6 with quoted overlap evidence and labeled acceptance-less
#7 `needs-acceptance`; /eval-spec landed 25 golden cases (10/5/5/5,
refusal target 100% standalone) while no `ask` code existed, closing #4;
/plan-review caught a real gap — M2's exit criterion ran `eval/run.py`
that no issue created — verdict CHANGES REQUIRED, gap filed as #8, then
locked. `stale-days: 0` was a config override to make staleness testable
on a day-old repo.

**Why a scratch repo and not acstack itself:** this repo is the living
demo of document mode (converting it guts the default mode's showcase);
/triage's test requires seeded rot a healthy repo doesn't have; and
first-run mistakes belong in a throwaway, not a permanent public history.

**What wave 2 does NOT change (intentional):** no wave-3 skills, no
runtime/preamble/telemetry (wave 4), no Linear/Jira (GitHub Issues only
at launch, locked decision), no remote for acstack itself.

**Incidental finds:** model-invocable skills registered mid-session
without a restart — softens wave 1's "start a new session" note (the
restart is still needed for user-only skills to be *verified*, since
they never appear in the model-facing list). CONDUCT.md's Extending
section still said "nine defaults" from before rule 10 — fixed this
session. /investigate and /resume passed review but haven't chased a
real failure / cold start yet; their first real use is their true
shakedown.

Validation close: `check.sh` all clean on every one of the session's 17
commits; skills 5 → 12; SKILL.md lines 403 → 1080 (largest file 145 of
500 budget); reference files 9 → 14; setup round-trip 12 linked, 0
skipped.

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
| ~~GitHub remote~~ | Resolved 2026-07-27: private `AaravChadha/acstack` created, `main` pushed and tracking | Done |
| ~~Fresh-session check~~ | Resolved 2026-07-27: typed `/plan` in a fresh session and it engaged seed mode — loading works; user-only skills simply don't appear in the VS Code extension's subset autocomplete (CLI shows all) | Done |
| Scratch repo deletion | `acstack-w2-shakedown` — contents verified disposable 2026-07-29 (backup taken); policy decided: never reuse, always create fresh per wave | `gh auth refresh -s delete_repo`, then `gh repo delete` — owner: user |
| ~~Document-mode commit style~~ | Resolved 2026-07-29: both modes symmetric — `task 2.3.2: <desc>` / `ticket #2: <desc>`; `#` kept for GitHub auto-linking. Implementation pending (CONDUCT rule 10, /do, /ship, README) | Done (decision) |
| ~~Browser probe timing~~ | Resolved 2026-07-27: deferred to first real need; wave 3 ships http with the seam browser-ready | Done |

## Important file locations

| Path | Purpose |
|---|---|
| `PLAN.md` | Wave roadmap with exit criteria |
| `CONDUCT.md` | The 10-rule interaction contract (canonical) |
| `README.md` | Canonical `acstack:principles` block + config reference |
| `scripts/check.sh` | Pre-commit guard — run it, always |
| `templates/acstack.md` | Per-project config template |
