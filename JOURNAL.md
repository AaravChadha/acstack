# JOURNAL — acstack

> **What this file is.** A rolling snapshot of where the pack actually is,
> so a fresh session (or future-you) can open the repo and resume in 5
> minutes. Read this first, then `PLAN.md` for the wave roadmap.
> **Last update**: 2026-07-30. Wave 4 is in flight: specs approved
> (`docs/wave-4-specs.md`), batch A built and closed (4.23 conduct fix,
> 4.1 versioning, 4.17 guard coverage, 4.15 positive controls), 4.24
> history purge declined by user verdict, and the whole layer hardened by
> a 26-finding three-agent recheck that fixed seven silent-disable
> classes in the new guards themselves. check.sh 6 → 11 sections;
> guard-matrix 15 → 40 cases; 10 of 16 wave-4 items open. /resume passed
> its true cold start (4.7 item 10, first half).

## TL;DR

- Nineteen skills — the full roster — exist, pass the guard, and are
  symlink-installed. Wave 3 added the last seven: /learn, /health, /qa,
  /secure, /design-audit, /retro, /ship.
- Tickets mode (`tracking: tickets`) is live in /plan and /do — bootstrap,
  `#N:` commits, `Fixes #N` closes — proven on scratch repo
  `acstack-w2-shakedown` (private; deletion pending user call).
- Working tree clean; `scripts/check.sh` all clean (11 guard sections,
  including positive controls over seeded `fixtures/`);
  `docs/guard-matrix.sh` proves every guard fires (40 cases); `./setup`
  links 19. Banned-name list is untracked (`.acstack-banned`) — copy
  `.acstack-banned.example`, or the guard reports SKIPPED.
- Wave 4 batch A shipped 2026-07-30: VERSION `0.4.0` + CHANGELOG
  (guarded agreement), six new guard classes, the fixtures/controls
  positive-control layer, `T4:` retired from CONDUCT rule 10. Batch B
  (4.2 runtime, 4.5 CI) is next; 10 of 16 wave-4 items open.
- 4.24 history purge **declined** by verdict 2026-07-30 (roster reviewed:
  non-sensitive company names, first names, already-public project
  names) — the public flip is gated on the 4.7 checklist only.
- Conduct contract (10 rules) shipped in CONDUCT.md and embedded in this
  repo's AGENTS.md, plus 4 repo-only verification rules added 2026-07-29.
- Remote live (2026-07-27): private `AaravChadha/acstack`, `main` pushed;
  public flip waits on the wave-4 launch checklist.
- Roadmap runs to 38 skills, 39 open tasks: wave 4 (launch, 10 of 16
  open) → 4.5 (post-launch hardening, 8) → 5 (pre-flight gates) → 6
  (review board) → 7 (operate), plus 5 unscheduled browser-layer items.
  Full detail in PLAN.md.
- Next: wave-4 batch B — 4.2 (runtime preamble + `bin/`) then 4.5 (CI) —
  per the approved build order in `docs/wave-4-specs.md`.

## How to run it right now

```bash
cd ~/Documents/acstack
./setup            # links skills into ~/.claude/skills (idempotent)
scripts/check.sh   # pack guard (11 sections, runs controls) — clean before any commit
bash docs/guard-matrix.sh "$PWD"   # 40 seeded-defect cases proving the guards fire
# then start a new Claude Code session; the nineteen skills load at start
```

## What's been built

| Wave | Status | Highlights |
|---|---|---|
| 1 — Core + foundation | ✅ | 5 skills (403 SKILL.md lines total, budget 500/each), 9 reference files, setup round-trip verified, guard clean on first run |
| 2 — Gate/eval/tickets | ✅ | 7 new skills + tickets mode (12 SKILL.md files now total 1080 lines; 14 reference files); specs → build → independent review (6 findings fixed) → scratch-repo shakedown passed |
| 3 — Ship + reflect | ✅ | 7 new skills (/learn, /health, /qa, /secure, /design-audit, /retro, /ship); 19 SKILL.md files now, 21 reference files; specs → build → independent review (9 findings, 0 blocking) → two-venue shakedown (seeded scratch app + acstack) that earned a real secret-regex fix |
| 4 — Distribution + launch | 🔶 in progress | Batch A done (2026-07-30): versioning guarded, guard sections 7–11, fixtures + controls, conduct fix; 10 of 16 items open — runtime, CI, README v2, discoverability, eval runner, the 10-point demonstrated launch checklist |
| 4.5 — Post-launch hardening | ⬜ | 8 items split out 2026-07-29: telemetry, `setup --global`, /audit tests, /why, /refactor, remaining degradation paths |
| 5 / 6 / 7 — Gates, review board, operate | ⬜ | 16 skills: pre-flight family (incl. /upgrade), the lens board, post-merge coverage |
| B — Browser layer | ⬜ | Unscheduled, demand-triggered; unblocks rendered QA, a11y, design, perf |

## Key decisions and journey (so you don't relearn)

### Wave 4 batch A: guards built, then hardened by their own recheck (2026-07-30)

Starting state: wave 4 at 15 open items, specs unwritten, /resume never
cold-started. Ending state: specs approved and built through batch A —
4.23, 4.1, 4.17, 4.15 closed with evidence, 4.24 closed by decline —
leaving 10 of 16 wave-4 items open; check.sh 6 → 11 sections (141 → 304
lines); guard-matrix 15 → 40 cases; a permanent `fixtures/` +
`scripts/controls.sh` positive-control layer; 10 work commits plus this
entry.

**/resume's true cold start (4.7 item 10, first half) — passed, with
three findings.** Run before reading anything, per the wave-2 flag. It
correctly named the wave, the single unjournaled commit, and the
reconciling line count, and correctly said the next unit was
spec-writing, not task 4.1. Findings: (a) the unjournaled-range step
matches the literal `Journal <date>: <summary>` subject, so this repo's
multi-entry days (`Journal 2026-07-29 (3rd): …`) would count SIX
unjournaled commits instead of one; (b) no stated path for a task
without an `**Acceptance:**` line — true of 4.1/4.2/4.5 at the time;
(c) prose process-prerequisites (specs-at-wave-start lives in PLAN's
header blockquote) are invisible to checkbox-unblocked logic. (a) and
(b) now ride 4.18; (c) is a recorded known limitation — the fix would
mean parsing prose, and the mitigation is keeping such rules in the
header /resume does read.

**4.24 declined, not deferred (user verdict, 2026-07-30).** The roster
in history was reviewed verbatim before ruling: twelve tokens —
company names with non-sensitive association, bare first names, and
project names that are already public repos. History exposure accepted;
no rewrite, no repo recreation; the flip is no longer history-blocked
and 4.7 item 8 narrowed to the working tree. The working-tree ban and
guard stay — their rationale is generic pack content, not secrecy. The
evaluated `git filter-repo --replace-text` + fresh-repo procedure stays
in the spec as the record of what was declined.

**Specs at waves-2/3 fidelity** (`docs/wave-4-specs.md`, 553 lines at
commit, 569 now with as-built status). Guard-first build order; the four
missing PLAN acceptance lines supplied and landed with commit 1; snippet
drift resolved by citation because cross-skill `../` paths resolve on
every install where wave 2's README pointers did not; /eval-run specced
to shake down against a deterministic toy so no API spend is required.
Speccing itself found the THIRD stale-enumeration instance: check.sh's
header and README each listed five guard checks while six existed.

**Batch A build.** 4.23: `T4:` retired from CONDUCT rule 10's body,
Good example, and both condensed blocks; verified by grep over live
files plus a byte-diff of the CONDUCT/AGENTS blocks. 4.1: VERSION
`0.4.0`, CHANGELOG with retroactive 0.1–0.3 entries and
`## 0.4.0 — unreleased` on top (recorded divergence from the spec's
literal `## Unreleased`, so the agreement guard compares exactly);
required-version issue template; the matrix gained a full-tree
seeded-defect section. 4.17: check.sh sections 7–10 (routing,
cross-references in four shapes, config-key reachability parsed from
README's table, verdict-first presence) plus strict frontmatter parse;
canonical snippet homes are /secure §2 (secret patterns), /audit
eval-review-rules (six buckets), /qa adversarial-inputs (the bank,
absorbing prompt-injection-shaped); **the crossref guard's first live
run caught three real repo-root-relative citations** (learn,
investigate, secure — forms that resolve in this repo but dangle on
every install), converted to portable `../` forms. 4.15: one planted
defect per check-shaped skill; controls.sh EXTRACTS each documented
detection command from its reference file at run time, so editing the
pattern edits what gets tested; **the control's first run caught its
own fixture lying** — the "NBSP" plant was a plain space. /qa's
live-server control is a documented shakedown procedure, stated rather
than pretended into a per-commit check.

**The recheck (user-requested): "make sure nothing already built has
errors or is stale."** Mechanical layer all green; three context-free
agents (docs-vs-tree, all-19-skills content, adversarial shell;
~290k tokens total) plus a main-thread pass returned 26 findings, none
broken-in-operation. The two worst were live-verified before reporting:
**one malformed banned-list entry (`broken(`) flipped the entire sweep
from FAIL to `all clean`** — grep's exit 2 (bad pattern) conflated with
exit 1 (no match), error eaten; and a comments-only list killed
check.sh before its own SKIP branch, which was therefore dead code.

**A.1 hardening — the guards' own false-pass class, fixed matrix-first
(31 → 40).** Loud failure on invalid banned entries; three early-death
sites now report instead of dying (comments-only list, headingless
CHANGELOG, unparseable config row); missing `fixtures/` is FAIL, not
silence; colon-suffixed and code-span dangling refs both extracted —
with prose separators excluded, which the real tree immediately
justified (`` `ls`/glob ``, `` `--amend`/rebase `` cleared, `/sandbox`
documented as a URL-example exception); config reachability requires
key-shaped matches (`` `k` ``, `k:`, or `<k>` — the placeholder form
the real tree uses for branch-prefix); the /audit raw-compare control
no longer matches bare English "in"; `ACSTACK_BANNED_FILE` is now
authoritative (set-but-missing SKIPs, never falls back to the user's
real roster) and matrix copies delete `.acstack-banned` before leaving
the repo. Canonicalization completed: journal-template's example bucket
`real miss` → `prompt issue`; /health's secrets section cites /secure
wholesale after the plain-command copies were found ALREADY drifted
(history glob `'*.env'` vs the canonical three); /health's config check
resolves the pack README via the §3 readlink; /triage's report-order
sentence untangled; /secure's truncated regex-note blockquote repaired.
Declined with reason: /plan-review's title stays above its verdict —
the stance governs the first content line and an H1 is not content.
Residual, standing with its July reason: check.sh 3b still inspects
only command-position `git grep` lines (now including `$`-prefixed).

**Read on the process.** The 2026-07-29 curve held in miniature: the
canonicalization pass itself introduced two defects (a worked example
missed, a half-cite that left drifted copies), and they were caught the
same day by the recheck instead of shipping — the guards-first
discipline plus independent recheck is what "writing prose creates
defects at a real rate" looks like when it is being managed rather than
discovered. Every new guard was demonstrated failing before it existed;
no exceptions.

**What did NOT change (intentional):** no 4.2 runtime and no 4.5 CI
(batch B, awaiting go); /investigate has still never chased a real
failure (4.7 item 10, second half); README's requirements claim stays
wrong until 4.26; the scratch-repo deletion stays owner: user.

Validation close: `check.sh` clean on all 10 work commits; sections
6 → 11; matrix 15 → 40 with every new guard shown failing first;
controls all caught; PLAN 926 → 1003 lines; wave 4: 16 listed, 6
closed, 10 open (a mid-session status message said 11 — miscounted,
caught by re-counting for this entry); skills unchanged at 19, with
content edits in 9 skill files.

### Third audit round: the guard was the leak, and my fixes were the bugs (2026-07-29, evening)

Four more agents — fix-verification, plan structure, execute-everything, and
a fresh-eyes adopter read — with each finding tagged **pre-existing** vs
**introduced by recent fixes**. That tagging is the session's most useful
output, because it answers whether this process converges.

**It does, but the curve is not what the raw counts suggest.** Findings ran
25 → ~39 → ~35 across three rounds, but the share caused by the *previous*
fix pass ran roughly 0% → 25% → **60%**. Round 3's fix-verification agent
tagged **9 of its 11 findings as caused by my own last five commits**. The
mechanism is in the git log: ~1,000 lines of prose were written in a day,
and prose has a defect rate. Each round was removing N defects and writing
back ~0.25N. Repeating it alone would converge slowly and never to zero.
What broke the cycle was writing `docs/guard-matrix.sh` (15 cases, 6
must-pass / 9 must-fail) BEFORE the fix — it reproduced all four
regressions, then passed 15/15 after. A matrix cannot silently regress; a
careful re-read can.

**The guard was the leak.** `check.sh` hardcoded a plaintext roster of real
client, company, and collaborator names — in a repo whose plan is to flip
public — and its sweep covered `skills/ templates/ docs/` and the root
markdown but **not `scripts/`**, so it could never catch itself. It was the
only place in the tracked tree those names appeared. Found by the agent
reading the repo as a stranger, which called it the single most damaging
thing present; that is right. The list now lives in untracked
`.acstack-banned` with `.acstack-banned.example` committed in its place,
the sweep includes `scripts/` and `setup` (verified by seeding a token into
check.sh and watching it fail), and a missing list now prints SKIP with a
final line of "no failures, but N check(s) SKIPPED" instead of "all clean".
**Not fixed by any edit:** the names remain in git history across two
commits — carrier 4.24, and the one launch item that cannot be repaired
after the flip.

**Two shipped checks found nothing at all.** `git grep -E` is POSIX ERE:
`\b` matches **nothing** and `\s` parses as a literal `s`. So
`/design-audit`'s primary palette check found zero hex colors in a file
containing two, and `/secure`'s secret sweep caught 1 of 3 planted secrets
— every assignment written with spaces around `=` was invisible. Both
pre-existing since wave 3, both reproduced on a fixture repo before and
after. Fixed with `[[:space:]]` and `-w` (`-w` rather than dropping the
boundary, because bare `(just|simply)` matches inside "justify" and
"adjustment"), and check.sh section 3b now fails on `\b` or `\s` in any
documented `git grep` command — anchored to command lines, because the
first version flagged the prose explaining the hazard.

**My own hardening was a regression.** The frontmatter guard added that
morning missed a hazard on a second `description:` line (`head -1`) and
falsely rejected three kinds of valid YAML: a quoted description with a
trailing comment, a `name:` with trailing whitespace, and any CRLF file.
Rewritten to parse the frontmatter block properly. Likewise the gate-1 fix
swapped one bad sentinel for another — `git remote show origin` prints
`HEAD branch: (unknown)` on an unborn remote HEAD, and is a network call on
every run. Replaced with local-only resolution plus `rev-parse --verify`,
tested across five repo shapes.

**`/plan seed` could not reach the files it installs.** `setup` symlinks
only `skills/*/`, so `CONDUCT.md` and `templates/` exist on no path from a
user's project — the pack's headline feature had an installer whose likely
failure was inventing the conduct block from memory. Now resolves the pack
root by `readlink` and stops honestly if that fails.

**Push removed from `/do` (verdict 4.25).** `/do` now commits locally and
reports `committed locally — not pushed`; the `push` key governs `/ship`
only. The decisive fact was that **`/do` is model-invocable** — only
`/plan` and `/eval-spec` are user-only — so an agent could reach it with
the user typing nothing, and an unattended push is the one step that cannot
be undone quietly. Removal beat switching the default to `branch-pr`,
which would have put `gh` on the critical path of the most-used skill and
made every subtask a self-reviewed PR. The real recheck already lives one
level up in `/ship`'s five gates.

Also fixed: `telemetry: on` shipped as the template default for a component
with no code; `CONDUCT.md` (which installs into adopter projects) promised
a `setup --global` flag that does not exist; README claimed POSIX shell
while both scripts are bash-only. And the plan's own carriers were partly
duplicates — 4.21 duplicated 4.18 across two waves while being marked both
do-not-cut and post-launch, and 4.20 duplicated 4.17.4 with an acceptance
its own remedy made unsatisfiable. Both folded; IDs retired, not reused.

Validation close: 5 commits, `check.sh` clean on each; guard sections
5 → 6; `docs/guard-matrix.sh` added (15 cases, 15 passing); PLAN 869 → 914
lines; open tasks 44 across waves 4/4.5/5/6/7 plus 5 deferred browser
items; skills unchanged at 19.

### Second audit round: four agents, ~39 findings, three broken checks (2026-07-29, later)

A four-agent re-check of the whole plan and all 19 skills — plan structure
after the wave split, verification that the morning's fixes actually
landed, cross-document consistency, and an adversarial pass told to find
what the earlier audits missed. It found more than the first round, and
the most valuable findings were about **checks that ran and did not work**.

**`/ship`'s gate 1 blocked every release on this repo.**
`git rev-parse --abbrev-ref origin/HEAD` exits 128 when `origin/HEAD` is
unset — true of any repo made by `git init` + `git remote add` rather than
`git clone`, including this one — while *still printing `origin/HEAD` on
stdout*. The documented pipeline therefore produced the literal string
`HEAD`, `git log HEAD..HEAD` returned zero commits, and gate 1 reported
"nothing to ship" forever. Replaced with a four-step resolution that can
never silently yield `HEAD`.

**Gate 4 reported evidence it did not have.** With an empty commit range,
`grep -Fqf -` receives a zero-byte pattern file, and BSD grep **matches
everything** — so it printed "journal mentions the work" from nothing.
Verified on macOS. The empty case is now guarded first, and the check's
opposite weakness is documented: it matches commit subjects verbatim
against a journal that rarely quotes them, so it proposes `/journal` and
never blocks. `/ship`'s "any failing gate STOPS the release" rule now
names that exception, because a rule with an unstated exception is not a
rule.

**The morning's own guard had a false negative in its own bug class.** A
description whose FIRST character is `#` is read by YAML as a comment and
the value becomes null — the same vanishing-trigger-sentence failure the
guard was written for after `/ship`. An agent proved it by building a fake
pack that passed clean. The guard now also catches malformed quoting, a
missing description, and a `name:` that disagrees with its directory; all
six branches were demonstrated firing before commit.

**A fix I made that morning was a regression.** Repointing five skills to
"README's tickets-mode section" is wrong: skills run inside *other* repos,
where README is that project's README and has no such section. A vague
pointer became a wrong one — the exact guess the fix targeted. All six
citations now state the three preconditions inline and are
standalone-readable. Same class: four skills cited a "pack's shared
verdict-first stance" documented nowhere.

**Three adopter-facing claims were false.** `CONDUCT.md` — the file
`/plan seed` installs into adopter projects — promised the conduct block
installs via `setup --global`; that flag does not exist. README claimed
"git and a POSIX shell" while both scripts shebang bash and use
`BASH_SOURCE` and process substitution. README and check.sh's own header
each listed four guard checks when there are five, every stale copy
omitting the newest one.

**Skill-level contradictions.** `/audit`'s eval reference told it to "Fix
the prompt / the source data / the parser" while SKILL.md says it never
fixes — the column is now the remedy to *recommend*. `/migrate-check`'s
non-Prisma fix had landed in step 2 only; steps 5, 6, 8 stayed Prisma-only
and its `allowed-tools` whitelist permits no other migration CLI, so it
now names those checks as skipped rather than implying coverage. `/ship`
contradicted itself three ways on whether a PR exists under
`push: direct`.

**The carrier defect recurred a fourth time, and my own rule missed it.**
Two skills proposed in analysis — refactor safety and dependency upgrade —
were never scheduled. The rule written that morning said "a *cross-cutting
rule* names its carrier task in the same edit" and these were *skills*, so
it did not catch them. Rule broadened to "anything named as needed work".
`/upgrade` landed as 5.5; `/refactor` went to 4.5 as **4.19** — putting it
in wave 5 would have broken that wave's "none of them can write" exit
criterion, the same set-property error as the `/retro` misclassification.

**What this round did NOT fix (carriers 4.20–4.23):** snippet
canonicalization (the adversarial-input bank has already diverged three
ways), generalizing `/do`'s degradation pattern to `/ticket`, `/triage`,
`/retro`, `/journal`, `setup --dry-run` reporting work it did not do, and
CONDUCT rule 10's self-contradiction over `T4:` — which must land before
4.16 or that task would cement a format nothing emits.

Validation close: 5 commits including this entry, `check.sh` clean on
each; guard sections 4 → 5, with all 6 branches demonstrated firing
against seeded defects; wave 4 11 → 15 items; roster 34 → 38 skills;
PLAN 809 → 869 lines. Numbers corrected against ground truth rather than
memory — and two of THIS entry's own figures were wrong on first write
(PLAN length and commit count) and caught by re-measuring before commit,
which is the verify-the-consumed-form rule applied to the journal itself:
skill average 87 → 93, `/ship` 74 → 98 lines, wave-1 starting commits
2 → 3 (git log), PLAN length 821 → 809 → 869.

### Roadmap to 38 skills, and an audit that found a shipped bug (2026-07-29)

Starting state: 19 skills, wave 3 closed, PLAN.md at 182 lines covering
waves 1–4, four open decisions. Ending state: same 19 skills, PLAN.md at
809 lines covering waves 1–7 plus a deferred browser layer, 36 open tasks
zero open decisions, and one live bug fixed. 10 commits, no skills built —
this was a planning and correction session, deliberately.

**Competitive survey (cloned, not recalled).** gstack was cloned and read
file-by-file: **53 user-facing skills** (59 SKILL.md files less the router,
4 OpenClaw duplicates, 1 example), v1.60.1.0, 71 top-level dirs, a Bun
runtime with compiled ~58MB binaries, a headless Chromium daemon, opt-in
Supabase telemetry, and an optional Postgres "brain" over MCP. Its README
still advertises "23 specialists and 8 power tools" — stale against its own
tree. Three peers were surveyed by subagent: obra/superpowers (14 skills),
GitHub spec-kit (10 commands), BMAD-METHOD (6 agent roles).

The scan that mattered checked four capabilities against all four packs.
**Test-quality auditing, decision archaeology, dependency hygiene, DB
migration safety, and evals/golden sets are absent from every one of them.**
Two corrections to earlier assumptions came out of it: `/verify` is *not*
white space (superpowers gates the agent on itself, spec-kit's
`/speckit.converge` diffs code against spec, BMAD runs an Acceptance
Auditor subagent), and acstack's tickets mode is *deeper* than spec-kit's,
whose issue export has no labels, milestones, or write-back.

**Size philosophy is a real fork.** gstack's SKILL.md files average ~1,054
lines and top out at 2,359; acstack's average 93, largest 149. Invoking
gstack's /ship loads 1,417 lines at once against acstack's 98 plus
references on demand. Anthropic's authoring guidance favours the smaller
number — one place where the bigger pack is the worse pattern.

**Waves 5–7 designed, then split into 5–7 plus 4.5.** Roster ends at 38
skills, about 70% of gstack's 53. The team-of-perspectives goal is met by
**lenses, not personas**: each reviewer reads a named artifact and returns
a verdict, no roleplay, no first names — which keeps "gstack simulates the
team; acstack encodes the discipline" true while still convening a board.
`/board` and the per-lens open slot were kept as *complements*, not
alternatives: /board decorrelates across checklists, but every finding
still originates from one, so five lenses cannot see what none of them
lists. Only the open slot reaches past enumeration.

**The live bug.** `/ship`'s description contained `wiring Fixes #N`, and
YAML ends an unquoted scalar at space-hash — silently discarding the entire
trigger clause. Verified both ways against the live skill listing: it
previously ended mid-sentence at "wiring Fixes" and now carries full text.
It shipped in wave 3 and the wave-3 review missed it **by reading the file
instead of the parsed result**. `check.sh` gained a guard (5 sections now,
was 4). The guard's own first positive control passed misleadingly, because
the fix had already removed the `#` the control was testing for — caught
only by re-seeding a genuine hazard.

**Two independent audits, 25 findings.** A PLAN.md formatting/consistency
audit and an all-19-skills thoroughness audit ran as context-free
subagents. Formatting came back clean (numbering, cross-refs, tables,
checkbox coherence). Substantive errors, mostly mine: 4.8 called /retro
read-only when it appends to JOURNAL.md and commits, so its acceptance
would have failed against a correct implementation; the `sk-live` incident
was recorded two contradictory ways and git settled it (`d709d70` is
"(shakedown finding)", `dfe291d` the review's) — **the shakedown found it
and /secure initially MISSED the planted key**; 6.6 credited the review for
it, weakening /board's argument by resting on a false example.

**The recurring defect the user caught.** Three cross-cutting rules —
multi-product detection, positive controls, commit format — were written as
binding decisions with **no task owning the work**. Found when the user
asked "did we add the multirepo thing"; the honest answer was that it was a
note with no carrier and nothing detected it. All three now have carriers
(4.14, 4.15, 4.16), plus a rule requiring future cross-cutting rules to
name their carrier in the same edit.

**Cross-skill consistency, closed.** "The pack rule" was cited by five
skills and defined nowhere canonical — README now carries it. Adjacency
routing lines were missing from all five wave-1 skills, `/plan` worst
(nothing routed to /challenge, /plan-review, or /eval-spec, the entire
planning chain); all 19 now carry one. `templates/acstack.md` had no `##
qa`, `## design-audit`, or `## ship` sections, so four documented config
keys were unreachable from the file adopters copy; all 14 keys now present.
The secret regex had **already drifted** between its two copies (`ghp_` in
one, absent in the other) — from the wave-3 fix touching only one file.

**Verdict-first, the pack's own stated stance, was violated by five of its
own skills** — /migrate-check and /ship put verdicts last, /audit docs
emitted bare triples with no verdict or scope *despite promising scope*,
/triage led with findings, and /plan-review buried it in a late section its
own wave-2 spec had required be first. All five fixed.

**Four verification rules added to AGENTS.md**, each traceable to a defect
this repo shipped: verify the consumed form not the authored form; prove a
new check fails before trusting it passes; a cross-cutting rule names its
carrier in the same edit; a claim about a set enumerates the set. Kept out
of CONDUCT.md deliberately — that is an interaction contract shipping to
adopters, and these are construction discipline. Promotion only if one
proves out across projects, the same bar /learn uses.

**Why guards over prose:** six of the ten defects were mechanically
detectable and none was guarded. The pack's own thesis is that mechanical
beats rhetorical — it is the whole argument for `allowed-tools` over a
prose promise. Carrier task 4.17 adds the six classes to check.sh; the four
AGENTS.md rules are explicitly the *lesser* half.

**Wave 4 split (18 → 11 + 7).** The dividing line: wave 4 is "nothing an
adopter touches is broken, missing, or lying"; wave 4.5 is "the pack is
more rigorous and more capable." 4.15 and 4.17 stayed because 4.7 literally
depends on them — the checklist demands every guard demonstrated firing, so
moving them would have forced 4.7 back to asserting. /audit tests and /why
moved *out*, superseding a same-day decision that pulled them in: the
reasoning held, but the denominator changed from 7 items to 18. Task IDs
were not renumbered, per the pack's own never-renumber rule.

**4.7 rewritten** from six asserted lines to nine demonstrated ones. Nothing
in it is satisfiable by re-reading a file, and it requires **both** a
context-free multi-agent audit and a main-thread pass — because this session
proved neither substitutes for the other: subagents found the truncated
description and the /retro misclassification that the author had re-read
without noticing, while the main thread found the misleading positive
control and the provenance contradiction, each needing context the other
lacked.

**What this session did NOT do (intentional):** built no skills, wrote no
wave-5/6/7 specs (those get written at wave start, per the standing
process), implemented none of the recorded decisions (commit format, the
six guards, positive controls — all carriers, not code), and did not delete
the wave-2 scratch repo (owner: user; contents verified disposable, backup
taken).

Validation close: `check.sh` clean on all 10 commits; check.sh sections
4 → 5; PLAN.md 182 → 769 lines; open tasks 4 → 34 across waves 4/4.5/5/6/7
plus 5 deferred browser items; AGENTS.md rules 5 → 9; skills unchanged at
19 (1743 SKILL.md lines, 21 reference files); open decisions 4 → 0.

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
19; SKILL.md files 12 → 19 (largest /plan at 149 of the 500 budget);
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

Starting state: repo had 3 commits (init, CONDUCT.md, CONDUCT rule 10) and no skills;
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
