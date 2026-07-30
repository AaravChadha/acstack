# Wave-4 specs — distribution + launch

> **What this file is.** Per-item designs for wave 4, written at wave
> start per PLAN.md's process, at the same fidelity as waves 1–3. Build
> follows approval, one increment at a time, in the build order at the
> end. **Drafted:** 2026-07-30. **Status:** awaiting approval — nothing
> below is built yet.
> **Standing verdicts applied:** the wave-4 / 4.5 split (2026-07-29) —
> telemetry (4.3), `setup --global`/`--hook` (4.4), /audit tests (4.10),
> /why (4.11), commit-format implementation (4.16), and degradation
> paths (4.18) are NOT in this wave; the founding doc's C-lite runtime
> spec binds 4.2 with two recorded supersessions (bash 3.2+ replaced
> "POSIX sh only", 2026-07-29 constraint correction; telemetry and the
> SessionStart hook split out of the runtime commit); /do no longer
> pushes (4.25, closed); the cut order and do-not-cut set in PLAN's
> risk note stand.

## Cross-cutting

- **Guard first, then the change.** Every item that adds or alters a
  check lands its failing control before or with the change — extend
  `docs/guard-matrix.sh` (or `scripts/controls.sh`, new in 4.15) first,
  watch it fire, then build. This is the wave's own convergence lesson:
  three audit rounds ran 25 → ~39 → ~35 findings with the share caused
  by the previous fix pass at 0% → 25% → 60%; the matrix broke that
  cycle and prose re-reading did not.
- **Missing acceptance lines.** 4.1, 4.2, 4.5, and 4.6 carry no
  `**Acceptance:**` line in PLAN.md (the 2026-07-29 /resume cold start
  hit exactly this). This spec supplies one for each; on approval, the
  first build commit also adds those four lines to PLAN.md so /do and
  /resume have them.
- **No new required dependencies.** `bin/` is bash 3.2+ like `setup`
  and `check.sh`; CI runs on GitHub's runners; the eval runner is
  scaffolded into the *project's* stack, so the project carries that
  dependency, never the pack. Optional-dependency claims are corrected
  wholesale in 4.26.
- **Config addition:** one new Settings key, `runtime: on | off`
  (default `on`), consumed by the 4.2 preamble. README's table and
  `templates/acstack.md` gain the row in 4.2's commit.
- **A recurring defect found while speccing (2026-07-30):** check.sh's
  header comment and README's Development paragraph each enumerate five
  guard checks while the script has six sections (3b, the POSIX-ERE
  hazard check, is in neither list). Same stale-enumeration class the
  second audit round fixed once already. Carried in 4.17 below: the
  header becomes the single enumeration, README points at it.
- Every commit: `check.sh` clean first; AGENTS.md commit style; no
  banned names (fixture content stays generic).

## 4.23 CONDUCT rule 10 — resolve the self-contradiction

Smallest item, scheduled first because 4.16 (wave 4.5) would otherwise
implement a format against contradictory text.

- **Rule 10 body:** drop `T4:` entirely — it is emitted by no skill and
  appears in no config default. Tickets-mode example: `#42: dedupe
  scheme aliases`; document mode keeps `completed task 3.2.1 (dedupe
  scheme aliases)`. The Good/Bad example lines at the rule's foot lose
  `T4:` the same way.
- **Condensed block, rule 10 line:** rewritten to name both current
  shapes explicitly (`#42: …` tickets / `completed task 3.2.1 (…)`
  document) instead of "`T4: …` / `#42: …` per tracking mode".
- **AGENTS.md:** its embedded conduct block gets the identical line
  (same commit — /health's currency check diffs the two), and its
  commit-style exception note is re-read against the new wording (the
  exception itself is unchanged).
- **Not touched:** the 2026-07-29 verdict's NEW formats (`task 2.3.2:`
  / `ticket #2:`) — those land in 4.16 with /do, /ship, and README
  together. This item only makes today's documentation agree with
  today's reality. Wave-2's JOURNAL wording stays historical.

**Acceptance (PLAN):** `T4:` appears nowhere as a live format
(`git grep -nw 'T4:' -- ':!JOURNAL.md' ':!PLAN.md' ':!docs/'` clean on
live-format files); rule 10's body and condensed block agree; CONDUCT.md
and AGENTS.md blocks match.

## 4.1 VERSION + CHANGELOG + issue template

- **`VERSION`:** single line, semver. Starts `0.4.0` (waves as minors:
  0.1–0.3 shipped unnumbered); the public-flip commit in 4.7 sets
  `1.0.0`.
- **`CHANGELOG.md`:** keep-a-changelog-lite — one `## <version> —
  <date>` section per release, newest first, seeded retroactively with
  0.1.0/0.2.0/0.3.0 entries distilled from the journal's wave closes
  (dates 2026-07-27), plus `## Unreleased` on top while a wave is open.
- **Issue template:** `.github/ISSUE_TEMPLATE/bug.yml` with a required
  `acstack version` field whose description names the exact commands
  (`cat VERSION; git -C ~/Documents/acstack rev-parse --short HEAD`).
- **Guard (lands first):** new check.sh assertion — `VERSION` parses
  `^[0-9]+\.[0-9]+\.[0-9]+$` and equals the first versioned heading in
  CHANGELOG.md. Guard-matrix gains a must-fail case (seeded mismatch)
  before the guard is written.

**Acceptance (spec-supplied, to be added to PLAN):** VERSION and
CHANGELOG exist and agree; the template's version field is `required:
true`; the mismatch guard demonstrated firing.

## 4.2 The runtime — slim preamble + bin/ helpers

The founding doc's C-lite spec, minus what the split moved out. Nothing
here writes telemetry (4.3) and nothing installs hooks (4.4);
`~/.acstack/` holds exactly one file after this item: the update-check
stamp.

- **The preamble** is a marker-fenced block (`<!-- acstack:runtime -->`
  … `<!-- /acstack:runtime -->`) at the top of every SKILL.md body,
  byte-identical across all 19 skills (/eval-run inherits it when 4.12
  lands), canonical copy in README.md —
  the principles-block mechanism exactly, enforced by the same diff
  loop. Hard budget: **12 lines** inside the markers, as a named
  constant in check.sh (`PREAMBLE_BUDGET=12`); raising it requires a
  visible commit editing the constant (founding doc, trust item 9).
- **What the 12 lines say** (each documented line-by-line in
  ARCHITECTURE.md, 4.6): resolve the pack root by `readlink` of the
  invoked skill's symlink (the `/plan seed` pattern from b0d34c8); if
  that fails, or `bin/` is absent, or `acstack-config runtime` says
  `off` → say one honest line ("runtime off — proceeding without
  recall/update-check") and continue as pure markdown. Otherwise run,
  tolerating failure of each: `bin/acstack-config` (echo the keys this
  skill consumes and where each resolved from), `bin/acstack-update-check`,
  `bin/acstack-recall`.
- **`bin/acstack-config`** — resolve a key through the precedence chain
  (pack default → `~/.claude/acstack.md` → project `## Settings` →
  per-skill section), print `key=value (source)`. Read-only.
- **`bin/acstack-update-check`** — at most one `git fetch` per day via
  a stamp file `~/.acstack/update-stamp`; always `|| true`;
  offline-safe (no network → silent success); when behind upstream,
  print the exact `git -C <pack> pull` command and nothing else. Never
  pulls on its own.
- **`bin/acstack-recall`** — print project `LEARNINGS.md` plus the
  pack's `known-bug-classes.md`, jointly capped at ~6KB (truncate with
  an honest `[recall truncated at 6KB]` line). Missing files → empty
  output, exit 0.
- All three: bash 3.2+, shellcheck'd by check.sh section 5 (they join
  the loop), no arguments needed beyond the key name for config.
- **AGENTS.md's preamble rule** ("no bash preambles until the wave-4
  runtime lands") is satisfied, not edited — the rule already scopes
  post-runtime preambles to the documented budget.

**Acceptance (spec-supplied, to be added to PLAN):** with `runtime:
off`, invoking a skill runs no pack command and creates nothing under
`~/.acstack/`; with defaults, a first run creates the stamp and a
second same-day run does not fetch; a no-network run exits 0 silently;
recall output is capped and degrades to empty; check.sh fails on a
seeded one-skill preamble drift and on a 13-line preamble (both
demonstrated via guard-matrix first).

## 4.17 Guard coverage — six sections into check.sh

Lands early so every later item builds under it. Each sub-guard gets a
guard-matrix must-fail case seeded and demonstrated BEFORE the guard is
written (AGENTS.md rule 2; check.sh's own comment already orders it:
"extend that FIRST, then this").

1. **Routing line:** `grep -L 'Adjacent skills:' skills/*/SKILL.md`
   must be empty.
2. **Cross-references resolve:** every `/skill-name` token in a
   SKILL.md that matches `^/[a-z][a-z-]+$` must name a directory under
   `skills/` or appear on a short inline exception list (URL paths like
   `/admin` occur in examples; the list lives beside the guard with a
   comment per entry). Every `references/<file>` mentioned in a
   SKILL.md must exist under that skill's directory; cross-skill
   citations (`skills/<other>/references/…`, introduced by sub-guard 4)
   must exist from the repo root.
3. **Config-key reachability:** every key in README's config table
   appears in `templates/acstack.md`, and the skill the table names as
   consumer mentions the key. (This is 4.7 checklist item 3's
   mechanical half.)
4. **Shared-snippet canonicalization + drift.** Verdict built into this
   spec: **convert duplicates to citations** rather than guarding
   byte-identity across differently-shaped files. Canonical homes:
   secret-scan patterns → `skills/secure/references/security-surfaces.md`
   (/health cites it); the six eval failure buckets →
   `skills/audit/references/eval-review-rules.md` (/journal cites); the
   adversarial input bank → `skills/qa/references/adversarial-inputs.md`
   (/eval-spec and /audit cite, and the bank absorbs the three-way
   divergence first: "empty query", "prompt-injection-shaped", HTML and
   Unicode cases merge into the canonical list). Cross-skill citations
   are safe where README pointers were not: every install symlinks all
   skill dirs together, so `skills/<x>/references/…` resolves on any
   machine with the pack, unlike "this project's README". The guard then
   checks each citation's target file exists (per sub-guard 2).
5. **Verdict-first present:** an enumerated list of the report-shaped
   skills (audit, challenge, design-audit, health, migrate-check,
   plan-review, qa, resume, retro, secure, triage — enumerated here,
   per the set-claims rule, and re-verified at build) must each contain
   a line matching `[Vv]erdict` in their report-shape section. A
   presence-of-stance check, stated as such — it proves the stance is
   written, not obeyed.
6. **Frontmatter parses:** extend section 3 to assert every frontmatter
   line matches `key: value` shape with a known key
   (`name|description|argument-hint|allowed-tools|disable-model-invocation`),
   and that the parsed description is non-empty after the existing
   hazard checks.

Plus the stale-enumeration fix from Cross-cutting: check.sh's header
comment becomes the single list of sections (updated in the same commit
as any new section — stated as a rule in the header itself), and
README's Development paragraph points at it instead of enumerating.

**Acceptance (PLAN):** each of the six fires against a seeded defect
and is silent on the clean tree — all six demonstrations recorded in
guard-matrix (target: 15 → ≥27 cases).

## 4.15 Positive controls for the check-shaped skills

New `fixtures/` tree and `scripts/controls.sh`, wired as a check.sh
section and run by CI. A control re-runs a skill's **documented
mechanical check** (the exact grep/classification command its
references file prints) against a fixture containing a known instance,
and fails when the command misses the plant. Stated honestly: controls
prove the documented commands work; they cannot prove the model's
judgment around them — that half stays with shakedowns.

- `fixtures/secure/` — a planted `sk-live-…`-style key (generic value),
  a `!.env` gitignore negation, an unauthenticated admin route sketch.
  Control: the secret patterns and negation grep from
  security-surfaces.md each hit.
- `fixtures/design-audit/` — an off-palette `#ff00aa`, a `mockData`
  chart labeled as real, hedge copy ("simply", "seamlessly"). Control:
  the palette and slop greps from design-conventions.md hit all three.
- `fixtures/health/` — a mini project dir with a non-pointer CLAUDE.md
  and a tracked `.env`. Control: the two health-checks.md commands hit.
- `fixtures/audit/` — a code file seeded with a known-bug-classes entry
  (the U+202F lookalike class). Control: that class's documented
  detection grep hits.
- `fixtures/migrate-check/` — a migration `.sql` with a `DROP TABLE`
  and a column rename. Control: the SQL classification patterns mark
  both destructive.
- `fixtures/qa/` — a ~40-line stdlib http server with an unauth gated
  route and an uncaught `limit=abc` cast, plus the documented curl
  probes. Its control needs a live process, so it is NOT in per-commit
  controls.sh: it runs in the wave shakedown (procedure documented in
  the fixture's README, kill-stale-servers-first per the wave-3
  incidental find).
- Each control demonstrated in both directions once: fixture seeded →
  documented command hits (control passes); command deliberately broken
  (the `\b` class) → control fails loudly.

**Acceptance (PLAN):** seeding each fixture makes its check fire;
breaking the documented command makes the control fail; controls.sh
runs clean on the real tree.

## 4.5 CI — the guard on every PR

`.github/workflows/check.yml`: on push to main and on every PR —
checkout, run `scripts/check.sh`, run `docs/guard-matrix.sh`, run
`scripts/controls.sh` (already inside check.sh, listed separately so a
matrix regression is named in CI output), `shellcheck -S warning setup
scripts/*.sh bin/*` (ubuntu's shellcheck; same severity as check.sh
uses locally). No secrets, no tokens beyond the default. Known honest
gap, stated in the workflow's comment: CI has no `.acstack-banned` (the
list is untracked BY DESIGN), so the banned-names section prints SKIP
and the run reports "no failures, but 1 check(s) SKIPPED" — the local
pre-commit run stays the enforcement point for names.

**Acceptance (spec-supplied, to be added to PLAN):** a PR carrying a
seeded guard violation fails CI; a clean PR passes with the SKIP line
visible in the log.

## 4.22 `setup --dry-run` tells the truth

Every dry-run line states intent, not completion: `would link <name>`,
`would relink <name> (was -> <target>)`, `would remove <name>`;
non-actions keep their real wording (`ok`, `skip`); summaries become
`N would be linked, M skipped.` / `N would be removed.` and the
"Start a new Claude Code session" hint is suppressed. The `would: ln
-s …` echo from `run()` stays (it shows the exact command). Install
path also stops printing `mkdir` as done.

**Acceptance (PLAN):** against a scratch `CLAUDE_SKILLS_DIR`, dry-run
install and dry-run uninstall print only would-forms, and a
`find <dir>` before/after diff is empty both times.

## 4.8 `allowed-tools` on the five read-only skills

/secure, /health, /design-audit, /audit, /resume — /migrate-check is
the template (it already ships the pattern), /qa excluded (network
tool shape), /retro excluded (writes JOURNAL.md; the 2026-07-29
correction).

- Each whitelist is derived at build time from the commands the
  skill's own SKILL.md + references actually document — Read, Grep,
  Glob, plus scoped `Bash(git status:*)`-style entries; tickets-aware
  ones (/resume, /health) add read-only `gh` (`Bash(gh issue list:*)`,
  `Bash(gh auth status:*)`, `Bash(gh label list:*)`). No entry may be
  bare `Bash`.
- **Guard (lands first):** new check.sh section — the five named
  skills carry `allowed-tools`; the value contains no `Write`, `Edit`,
  `NotebookEdit`, or unscoped `Bash`. Guard-matrix case: a fixture
  frontmatter with `Write` seeded → fires.
- **Honest scope:** the guard proves the declaration; *enforcement* is
  Claude Code's permission layer. One live-session probe (ask /resume
  to edit a file; observe the block) is run once and recorded as 4.7
  evidence — that is the "seeded write attempt must fail" in PLAN's
  acceptance, and it is a runtime demonstration, not a check.sh line.

**Acceptance (PLAN):** five declarations present; check.sh asserts the
no-write property and its control fires; the live write-attempt block
recorded.

## 4.9 Referral block — discoverability for typed-only skills

Roster = the set carrying `disable-model-invocation: true`, which is
exactly **/plan and /eval-spec** (verified against frontmatter
2026-07-30).

- **AGENTS.md:** marker-fenced `<!-- BEGIN:acstack-referrals -->`
  table: skill → one-line definition → suggest-when (/plan: repo lacks
  the three documents or the user is starting something new; /eval-spec:
  an LLM-shaped feature is heading to build with no `eval/`).
- **CONDUCT rule 9:** the decided half-sentence clause — a referral is
  an offer under rule 9's contract: named once, never repeated, silence
  is not consent. Full text and condensed block both, CONDUCT.md and
  AGENTS.md in the same commit (the /health currency pair again).
- **/plan seed** installs the referral block beside the conduct block;
  **/health** gains a row (block present; roster current vs installed
  skills).
- **Guard (lands first):** check.sh extracts the roster's skill names
  from the fenced table and diffs against
  `grep -l 'disable-model-invocation: true' skills/*/SKILL.md`.
  Guard-matrix case: fixture table with a stale row → fires.

**Acceptance (PLAN):** check.sh fails when the table's set differs
from the flag-carrying set — demonstrated both directions.

## 4.14 Multi-product detection — honest halt, not support

- **/health row:** signals strongest-first per PLAN — >1 BRIEF/PLAN/
  JOURNAL below root; workspace markers (`pnpm-workspace.yaml`,
  `lerna.json`, `turbo.json`, `workspaces` in package.json,
  `[workspace]` in Cargo.toml, `go.work`); `apps/`/`packages/`/
  `services/` each with a manifest. Reported as **info** ("unsupported
  shape"), never a failure.
- **Scope lines:** every document-reading skill (the 14 enumerated in
  PLAN's cross-cutting rule, re-counted at build) resolves exactly one
  document set and names its path; more than one candidate → list them
  and stop. One shared sentence, added per-skill (kept standalone-
  readable — the wave-2 README-pointer regression is the counter-
  example).
- **README:** the constraint stated in "The three documents" section —
  before install, not after a wrong /retro.
- **Fixture:** `fixtures/multi-product/` — two subdirs, each with its
  own BRIEF/PLAN/JOURNAL. Its control (controls.sh) runs the
  documented detection command and asserts both sets found.

**Acceptance (PLAN):** on the seeded two-product fixture, /health names
both document sets and /resume halts listing candidates instead of
picking one (shakedown-verified; the mechanical half in controls.sh).

## 4.12 /eval-run — close the flagship loop

Frontmatter: `name: eval-run`, `argument-hint: "[eval-dir | notes]"`,
model-invocable — running an eval is an explicit, named act (/do
precedent); before executing it states the case count and that
execution may call a model API, and conduct rules 2/5 gate anything
beyond the run. `Adjacent skills:` /eval-spec (writes the spec;
/eval-run executes it), /audit eval (reviews the results; /eval-run
produces them), /ship (gate 3 compares the headline to target).

**Method.**

1. Locate `eval/spec.md` + `eval/golden.jsonl`. Either missing → name
   which, point at /eval-spec, stop.
2. If spec.md's run command names a runner that exists → run it,
   never rewrite it (the /eval-spec step-0 rule: an existing eval
   artifact is never regenerated).
3. Else scaffold the runner for the project's stack — `package.json` →
   `eval/run.mjs`, `pyproject.toml`/`requirements.txt` → `eval/run.py`,
   neither → stop and ask (never guess a stack). Template in
   `references/runner-template.md`. The runner needs one project fact
   the spec may not carry: how to invoke the system under test (CLI,
   HTTP endpoint, or function import) — if spec.md lacks it, interview
   and write it into spec.md's run section as a dated addition.
4. The runner: reads golden.jsonl; skips `"status": "needs-data"`,
   excludes superseded cases from the denominator; applies each case's
   `grade_rule` per grader-rules (concept-not-wording, Unicode
   normalization, explicit tolerances); honors `acceptable_failure`
   only when the case carries its reason; writes
   `eval/results/<UTC-timestamp>.jsonl` — one record per case: `id`,
   `category`, `pass`, `expected`, `actual`, `grade_rule`,
   `acceptable_failure_applied` — and prints the headline (overall %,
   per-category, refusal %) **computed from that file**, never
   assembled in prose.
5. Report verdict-first: headline vs spec target, failures by category,
   the results path. PLAN edits only proposed. Never edits
   golden.jsonl — a wrong case is superseded via /eval-spec's rule.

**Positive control (rides 4.15's pattern):** a golden set with one
deliberately failing case must produce a sub-100% headline — a runner
that reports 100% by construction is the false-pass class, and this is
the check that catches it.

**Acceptance (PLAN):** on a scratch project with a golden set, /eval-run
produces a results file and headline that /audit eval can recompute and
ship gate 3 can compare. Shakedown note, stated honestly: the scratch
target is a deterministic toy (lookup-table CLI), which exercises every
runner mechanic offline; the model-API call slot ships in the template
but is not spent against a live API unless the user opts to.

## 4.26 README requirements + footprint honesty

- **Requirements:** "git and bash 3.2+, nothing else" scoped to
  *install*. A small per-capability table: tickets mode → `gh` (nine
  skills); /qa → `curl`; /migrate-check under `db: shared-prod` →
  `pg_dump` for the backup path; /eval-run → the project's own stack +
  a model API when the system under test needs one; CI → GitHub.
- **Footprint:** every file the pack touches, before installing:
  `~/.claude/skills/*` symlinks (`setup`); BRIEF/PLAN/JOURNAL,
  LEARNINGS.md, CLAUDE.md rewritten to the pointer, AGENTS.md conduct +
  referral blocks, offered `.claude/acstack.md` (`/plan seed`);
  `~/.acstack/update-stamp` (runtime, 4.2); `eval/` (on request,
  /eval-spec + /eval-run). Nothing else, and nothing over the network
  except `git fetch`.

**Acceptance (PLAN):** a reader can predict every file touched and
every binary invoked before installing — reviewed against the actual
list above, which this spec makes checkable.

## 4.6 Docs — PRINCIPLES, ARCHITECTURE, CONTRIBUTING, README v2

Built late, after the things it documents exist.

- **PRINCIPLES.md:** the discipline in one page — the principles block
  with the *why* behind each line (never-inflate, supersede-don't-
  delete, repo-owned memory, honest degradation), and the positioning
  line. No new claims; everything traceable to CONDUCT.md or PLAN.
- **docs/ARCHITECTURE.md:** how skills/config/runtime/guard fit; every
  preamble line documented individually (founding doc trust item 8 —
  the count of documented lines must equal the block's line count);
  the `bin/` contracts; the fixtures/controls layer; why symlinks.
- **CONTRIBUTING.md:** run check.sh before every commit; guard-first
  rule for new checks (with the convergence numbers as the reason);
  skill authoring constraints (budget, principles block, routing line,
  positive control required for check-shaped skills); commit style;
  the banned-names setup.
- **README v2:** see-it-work walkthrough (a short, curated
  /plan-seed → /do → /journal transcript on a generic toy project);
  the shadowing disclosure (/plan and /resume shadow built-ins;
  Shift+Tab and `claude -r` remain; user-only skills are absent from
  the VS Code extension's autocomplete subset); install unchanged;
  4.26's corrected requirements/footprint preserved verbatim;
  Development section pointing at check.sh's header list (4.17).

**Acceptance (spec-supplied, to be added to PLAN):** ARCHITECTURE's
preamble documentation count equals the preamble's line count;
README v2 carries walkthrough + both disclosures; the 4.17
cross-reference and config-reachability guards pass over all four
files.

## 4.24 Purge the roster from history — before the flip

> **Superseded (2026-07-30), the day after drafting:** the purge is
> **declined** by user verdict — the roster is company names with
> non-sensitive association, bare first names, and already-public
> project names. The section below is kept as the record of what was
> evaluated and how it would have been done; none of it is built, and
> build-order step 14 is retired. 4.7 item 8 is now working-tree-only.

**Recommendation as drafted (superseded above):**
`git filter-repo --replace-text` over squash-to-root. The repo's own
history is the pack's evidence — the journal cites commits by hash as
proof — and a single-root squash destroys that story while *still*
dangling every cited hash. filter-repo keeps the shape and changes
only what it must.

Procedure, in order: (1) full backup clone, verified; (2) replacements
file generated from `.acstack-banned`; (3) `git filter-repo
--replace-text` on a fresh clone; (4) from filter-repo's commit-map,
rewrite the cited hashes in JOURNAL.md/PLAN.md in one follow-up commit
(`git log -SD709d70`-style sweep to enumerate the citations first);
(5) push to a **freshly created** GitHub repo and retire the old one —
recreation beats force-push because GitHub retains unreachable objects
on the existing repo, and the repo is private with zero forks/watchers
today, so recreation costs nothing (needs the same `delete_repo` scope
already pending for the scratch repo). (6) Acceptance grep.

**Acceptance (PLAN):** `git log -p --all | grep -riEwf .acstack-banned`
empty on the repo that goes public. This blocks the flip; it cannot be
fixed after.

## 4.7 The launch checklist — executed, not asserted

The gate itself, run last. Evidence ledger: the wave's journal entry
carries a ten-row table — item → exact command or named artifact →
result — with no row resting on "looks right".

Execution notes per item: (1–2) guard demonstrations and parsed
descriptions come free from 4.15/4.17's matrix runs — cite the runs.
(3) cross-references: the 4.17 guards plus a manual pass over
README/docs. (4) fresh-machine: a clean user account or Linux
container; procedure: clone → `./setup` → new session lists 18
model-invocable skills (20 installed, minus /plan and /eval-spec which
are typed-only but must still invoke) → `--uninstall` removes exactly
20 links → reinstall. (5) the
multi-agent audit runs as **2–4 focused, budgeted subagents** (the
standing fan-out cap), context-free, over PLAN + all skills; (6) the
main-thread pass follows; every finding resolved or declined in
writing. (7) demo transcript: curated, real project, never a shakedown
leftover (the scratch-repo policy). (8) credits line verified;
working-tree sweep only — the history half was retired with 4.24's
2026-07-30 decline. (9) every wave-4 acceptance command re-run
with output pasted. (10) /resume's cold start is already evidenced
(2026-07-29 session: correct wave, divergence flags, three unblocked
tasks, plus three findings — cite the journal entry); /investigate
chases a real failure from this wave's builds — historically a certain
supply; if the wave somehow ships defect-free, it waits for the first
real one rather than faking it.

Then `VERSION` → 1.0.0, CHANGELOG 1.0.0 section, flip public.

## Build order and commits

One commit per increment, AGENTS.md subject style, check.sh clean
before each. Guards and controls inside each increment land before the
thing they check.

1. `resolve conduct rule 10 contradiction (T4 retired)` — 4.23, plus
   the four missing PLAN acceptance lines from Cross-cutting.
2. `add version and changelog (guarded agreement)` — 4.1.
3. `add guard coverage sections (six classes, matrix-first)` — 4.17.
4. `add positive-control fixtures and controls runner` — 4.15.
5. `add runtime preamble and bin helpers (budget-guarded)` — 4.2.
6. `add ci workflow (check, matrix, controls, shellcheck)` — 4.5.
7. `fix setup dry-run to report intent (would-forms)` — 4.22.
8. `declare allowed-tools on the five read-only skills` — 4.8.
9. `add referral block for typed-only skills (roster guarded)` — 4.9.
10. `add multi-product detection (honest halt)` — 4.14.
11. `add eval-run skill (runner scaffold, results contract)` — 4.12.
12. `correct readme requirements and footprint claims` — 4.26.
13. `add principles, architecture, contributing, readme v2` — 4.6.
14. ~~4.24 (user-gated; commits per its procedure).~~ Declined
    2026-07-30 — see the superseded 4.24 section.
15. 4.7 execution + flip.

The PLAN risk note's cut order (4.22 → 4.26 → 4.8 → 4.9) and
do-not-cut set stand unchanged; the order above puts every do-not-cut
item before every cuttable one except 4.22, which is deliberately
early because it is a ten-minute fix.

## Wave verification (the PLAN exit criterion, expanded)

- 4.7 IS the wave's verification; no separate shakedown repo unless
  4.12's scratch project needs isolation — per the scratch-repo policy
  it is created fresh (`acstack-w4-evalrun`, local directory is enough;
  no tickets-mode need), seeded with the lookup-table toy and a golden
  set, thrown away after.
- The fixtures tree is permanent (it is the positive-control layer,
  not a shakedown), and `fixtures/qa/`'s live-server control runs once
  here with stale servers killed first.
- Guard-matrix target: 15 → ≥27 cases, every new guard shown firing;
  controls.sh clean on the real tree, failing on each seeded break.

## What wave 4 does NOT include (intentional)

- Telemetry (4.3), `setup --global`/`--hook` (4.4), /audit tests
  (4.10), /why (4.11), /health's agent-instruction row (4.13), the
  commit-format implementation (4.16), the degradation-path sweep
  (4.18), /refactor (4.19) — all wave 4.5.
- The browser layer (B.1–B.5), waves 5–7 skills, Linear/Jira, a
  preamble generator (revisit only if the preamble churns), any
  network telemetry ever.
- Windows-native symlinks (copy-with-warning stands).
