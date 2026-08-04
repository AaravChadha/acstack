# JOURNAL — acstack

> **What this file is.** A rolling snapshot of where the pack actually is,
> so a fresh session (or future-you) can open the repo and resume in 5
> minutes. Read this first, then `PLAN.md` for the wave roadmap.
> **Last update**: 2026-08-05. **PUBLIC as of 2026-08-03** — the repo was
> flipped after the §13 falsification round closed and CI went green
> (run 30765510782). Two pre-flip rechecks both returned NOT READY; the
> second found the first's fix had reintroduced the bug it fixed, which
> forced check.sh §13 from a denylist to an allowlist. A third round
> (08-03 evening) then audited that allowlist by falsification and found
> the allowlist itself defective — `git grep -O` ran arbitrary programs,
> `git log`/`git diff --output` wrote files, and the guard never validated
> each list's last token — all fixed (matrix 68 → 74), git grep dropped to
> the read-only Grep tool, the gh token grant narrowed, and a §13a forcing
> function added. **Wave 4 is closed** — 4.7's final clause was the public
> flip, now done. Built across the launch: versioning, six guard
> classes, the fixtures/controls positive-control layer, the runtime
> preamble + `bin/` helpers, CI, dry-run honesty, `allowed-tools`, the
> referral block, multi-product detection, **/eval-run as the 20th
> skill**, and the four launch documents (PRINCIPLES, ARCHITECTURE,
> CONTRIBUTING, README v2). check.sh 6 → **25 checks** (22 numbered + 3b + 3c + 13a); guard-matrix
> 15 → **90 cases**; **23 skills**. Five review rounds ran; the last
> found a reproducible arbitrary-code-execution path in the runtime
> preamble — now closed and locked by a matrix case.
> /resume passed its true cold start (4.7 item 10, first half).

## TL;DR

- **Twenty skills** exist, pass the guard, and are symlink-installed.
  Wave 3 added seven (/learn, /health, /qa, /secure, /design-audit,
  /retro, /ship); wave 4 added /eval-run, which closes the eval loop the
  pack's flagship methodology had left open.
- Tickets mode (`tracking: tickets`) is live in /plan and /do — bootstrap,
  `#N:` commits, `Fixes #N` closes — proven on scratch repo
  `acstack-w2-shakedown` (private; deletion pending user call).
- Working tree clean; `scripts/check.sh` all clean (**22** numbered
  sections plus 3b, 3c and 13a = 25 checks, including positive controls over
  seeded `fixtures/`); `docs/guard-matrix.sh` proves every guard fires
  (**90** cases); `./setup` links **23**. Banned-name list is untracked (`.acstack-banned`) — copy
  `.acstack-banned.example`, or the guard reports SKIPPED.
- **Wave 4 is closed and the repo is public** (flipped 2026-08-03, CI
  green run 30765510782). 4.7's ten checklist items were all demonstrated
  (evidence ledger, 2026-07-31 entry) and its final clause — "only then
  flip public" — is now done. 4.31 closed
  2026-07-31 (/secure grew a fifth surface — deserialization, crypto,
  transport — with nine controls demonstrated failing first); 4.5 closed
  the same day with both halves evidenced, including PR #1 shown failing
  CI on a seeded routing violation and then closed unmerged. Everything else — versioning, guards,
  controls, runtime, dry-run, allowed-tools, referrals, multi-product,
  /eval-run, the launch docs — is done with evidence.
- 4.24 history purge **declined** by verdict 2026-07-30 (roster reviewed:
  non-sensitive company names, first names, already-public project
  names) — it did not block the flip, which has since happened.
- Conduct contract (10 rules) shipped in CONDUCT.md and embedded in this
  repo's AGENTS.md, plus 4 repo-only verification rules added 2026-07-29.
- Remote live (2026-07-27); **public as of 2026-08-03**, `main` pushed.
- Roadmap runs to 39 skills, **35 open tasks** (re-counted 2026-07-30
  after batch D): wave 4 (**1**) → 4.5 (post-launch hardening, **13** —
  grew by the eight-repo survey, which also added /design as the 39th
  skill) → 5 (5) → 6 (7) → 7 (4), plus 5 unscheduled browser-layer
  items. Full detail in PLAN.md.
- Next: **wave 4.5** (post-launch hardening). 4.16 landed 2026-08-03 (the
  commit-format verdict now emitted, not just documented); a live
  first-session shakedown then exercised /resume, /health, /secure and
  found real gaps to fold into 4.5's order.

## How to run it right now

```bash
cd ~/Documents/acstack
./setup            # links skills into ~/.claude/skills (idempotent)
scripts/check.sh   # pack guard (25 checks, runs controls) — clean before any commit
bash docs/guard-matrix.sh "$PWD"   # 90 seeded-defect cases proving the guards fire
# then start a new Claude Code session; the twenty-three skills load at start
```

## What's been built

| Wave | Status | Highlights |
|---|---|---|
| 1 — Core + foundation | ✅ | 5 skills (403 SKILL.md lines total, budget 500/each), 9 reference files, setup round-trip verified, guard clean on first run |
| 2 — Gate/eval/tickets | ✅ | 7 new skills + tickets mode (12 SKILL.md files now total 1080 lines; 14 reference files); specs → build → independent review (6 findings fixed) → scratch-repo shakedown passed |
| 3 — Ship + reflect | ✅ | 7 new skills (/learn, /health, /qa, /secure, /design-audit, /retro, /ship); 19 SKILL.md files now, 21 reference files; specs → build → independent review (9 findings, 0 blocking) → two-venue shakedown (seeded scratch app + acstack) that earned a real secret-regex fix |
| 4 — Distribution + launch | ✅ | Built 2026-07-30/31: VERSION+CHANGELOG, guard sections 6–14, fixtures + controls layer, runtime preamble + bin/, CI, dry-run honesty, allowed-tools, referral block, multi-product detection, /eval-run (20th skill), PRINCIPLES/ARCHITECTURE/CONTRIBUTING/README v2. Launch checklist green; **flipped public 2026-08-03** |
| 4.5 — Post-launch hardening | 🔶 21/23 | **All buildable work done.** 4.16, 4.13, Phase 1 (4.33–4.39), 4.40 ladder, 4.11 /why, 4.10 /audit tests, 4.19 /refactor, 4.18 degradation paths, 4.41, 4.29, **4.27 ai-tells**, **4.30 /design**, **4.28 skill hygiene**, **4.32 root-cause clustering**, **4.42 shakedown 11** (all five shakedown-10 fixes held live). Remaining 3: 4.3 telemetry and 4.4 `setup --global` (both adopter-gated) + **4.43** — the front-door-vs-breadth verdict owed before wave 5 opens (Karpathy datum, carried 2026-08-05) |
| 5 / 6 / 7 — Gates, review board, operate | ⬜ | 16 skills: pre-flight family (incl. /upgrade), the lens board, post-merge coverage |
| B — Browser layer | ⬜ | Unscheduled, demand-triggered; unblocks rendered QA, a11y, design, perf |

## Key decisions and journey (so you don't relearn)

### Shakedown 11: all five fixes held, and the report survived falsification (2026-08-05)

**4.42 closed — the shakedown-10 fix round is live-verified.** Two blind
venues this time: `tiq`, a deterministic keyword labeler whose golden set
made the headline itself the verdict on F1's consumed form — a
flag-honoring runner produces the honest **70.0% (7/10), BELOW TARGET by
20**, while a flag-ignoring one would print 90% and MEETS TARGET — and
`pulse`, which isolated the missing-credential branch by stating the
invocation in the spec so ONLY the token was absent. The scaffolded
run.py, written by the live model from the fixed template, carried
`fold = not case.get("case_sensitive", False)`: hp-005 (`Positive`,
unflagged) passed by folding while sh-001/sh-002 failed on shape — the
same subject defect, forgiven and caught on adjacent rows, exactly as
designed.

**Verdict per fix, each verified at file:line against the venues on
disk:** F1 HELD (the discriminator above). F2a HELD in both branches —
venue A's spec named no invocation, so a dated addition cites *PLAN.md
task 1.1's acceptance line* as source; venue B's spec named it, so no
addition was written (spec untouched since seed, confirmed in git). F2b
HELD in all three layers — the skill's verdict led with NO SCORE, the
scaffold printed its `NO SCORE: every case errored…` line, and the
results file is five error records with zero passes; no credential set,
invented, or mocked. F3 HELD — the retro sits at the BOTTOM of the
chronological hand-kept `# LOG — tiq`, divergence named inside the
entry, heading adapted to the journal's own style, and the retro commit
touched JOURNAL.md only. F4 HELD — every audit citation matched
`grep -n` (`:15`, `:19`, `:24`, `:27-29`, `:34-35`), where round 10's
audit had three wrong; the behavioral claims (`badge` → negative,
`goods` → positive) also reproduce live. Run-command-settles-stack
re-held in both venues as a free regression check.

**The report survived falsification with zero broken claims** — round
10's had two. The operator's honest-scope list did real work too,
naming what no round has tested yet: the interactive halves of the
unattended contracts, the >500-line retro retrieval rule, and
tickets-mode deltas.

**The seed accident struck twice, and was caught twice.** Round 10's
venue journal claimed hardening its code lacked; this round I ticked
Phase 1 `[x]` while the seeded 07-30 entry recorded "9/10 lowercase"
against an exit criterion demanding the contract — an unplanned false
tick. /retro caught it unprompted: "the box was ticked on a day whose
own record shows the criterion failing." Two consecutive rounds where
an authoring accident became a blind-discovery test and a skill found
it — the strongest capability evidence these rounds have produced, and
none of it was designed.

**One new finding, fixed (`b566654`):** the runner template printed
`errors: N — run did not complete cleanly` on venue A's COMPLETE run —
all 10 cases have records; one subject crashed. The operator had to
argue against the scaffold's own wording in an otherwise-honest report.
Reworded to name errored cases without claiming incompleteness; the
template block re-executed after the edit. Behaviourally-found, so this
wording owes a slot in the next round's regression segment (rule 6 —
proportionate: one print string). No guard touched; matrix unchanged.

**Outward-facing, user-called each time:** `main` pushed
(`2c2a5aa..76af65a`), CI green (run 30938383854), then the empty GitHub
About filled — description (the README's first sentence compressed,
deliberately count-free so it cannot go stale) and six topics, both
verified by API read-back, not assumed from the command.

Validation close: check.sh **25 checks**, all clean; guard-matrix **90
cases** (unchanged — no guard edited since the 90/90 double run at
`43cc1ca`); controls **72** passing; **23 skills**; wave 4.5 **21/23**
— 4.42 ticked with all three acceptance clauses met, 4.3/4.4 remain,
both adopter-gated. Venues from rounds 10 and 11 stay on disk pending
the user's deletion call.

### Shakedown 10 came back clean, its findings closed, and the review broke the fix (2026-08-04, night)

**The rule-6 debt is cleared.** Shakedown 10 ran in a fresh session on a
blind seeded venue (`revq`, a sentiment-classifier CLI: BRIEF/PLAN/JOURNAL,
a subject requiring a project-namespaced `REVQ_ANTHROPIC_KEY`, no
manifests, no key present) — blind meaning the session was never told
which fixes were under test; the venue was built so every owed branch
fired naturally. **All six owed items HELD**, verified here at file:line
against the venue on disk, not from the pasted report: shakedown 9's five
fixes (non-interactive derivation with a P1–P5 derivation contract in the
emitted spec; `expected: null` on the one placeholder row; zero `../` in
any emitted artifact; run-command-settles-the-stack with no manifest
present; and the no-key run reporting `NO SCORE — system under test
unreachable` over 28 honest `status: error` rows, positive controls
redirected out of `eval/results/`) plus the two never-exercised branches:
/retro walked all three seeded risks to three different verdicts with
quoted evidence, and /eval-run declined without a key. The session had
opened with /resume as a live test of the five-minute claim — it
reconstructed the wave, the gates and the owed work from the documents
alone; its one real flag became this entry's carrier task.

**Verification was falsification, and it cut both ways.** The three
/audit stub proofs were re-run independently and all reproduced
(`"Negative."` passed through verbatim; empty `content` → IndexError;
429 uncaught). Two operator claims did NOT survive: the audit report
cited `:56`/`:44` and "56 lines" against a 49-line file — substance of
all five findings confirmed, citations recalled rather than pasted (now
F4) — and "the shape the pack's own /journal seeds" lacking the retro
heading was false (journal-template.md:29 carries it; only hand-kept
journals lack it — finding kept, cause corrected, now F3).

**The accidental blind-discovery test.** The seed journal claimed
retry-with-backoff that the seeded code never contained — an authoring
accident, owned as such. Both skills caught it independently: /audit
stub-proved the 429 crash against the "hardened" claim, and /retro
refused R3's retirement, cross-referencing the audit. First time two
skills caught the same unplanned contradiction from different
directions.

**Four findings, closed in `43cc1ca`.** F1 — the grader case-fold
conflict: the spec template documented per-case `case_sensitive: true`
while /eval-run's grading rules and runner template folded case
unconditionally, and grader-rules.md (the claimed canon) said nothing.
Canonical rule written (fold by default, keep case under the flag), all
four sites agree, **check.sh §22** guards the flag's presence — shown
failing first (token stripped from the runner template → `FAIL
grader-case`; restored → clean) — and the matrix gains the case. F2 —
/eval-run's two missing unattended paths: a committed document settles
the invocation (recorded as a dated addition naming its source; never
derived from the subject's code), and the NO SCORE hard rule — honest
per-case errors, the missing thing named in Scope, never mock a
credential. F3 — /retro's hand-kept-journal path. F4 — line numbers
pasted from `grep -n` output, never counted, all four targets plus the
emitted report template.

**Then the falsification review of the diff found the fix broken in its
consumed form.** The runner template's CODE block — the thing adopters
scaffold — still folded case unconditionally (`norm()` ended in
`.lower()`; `grade()` never read the flag) while four prose sites and a
green §22 certified agreement. Verify-the-consumed-form, inside the
same diff that quoted the rule. Also: NO SCORE was inexpressible in
/eval-run's own two-form verdict grammar; the first F3 wording imposed
the pack's newest-first ordering on hand-kept journals — the exact
failure class the fix targets; and F4 bound only the code target. All
fixed in the same commit. The code block is now extracted and EXECUTED
during verification — it compiles, and three grade assertions prove the
flag (`Negative.` fails case-sensitive, `negative` passes, default
still folds). §22's comment states its token-presence scope honestly,
citing its own first-day escape.

**Docs drift, found twice while closing.** ARCHITECTURE's check.sh
paragraph had gone stale a THIRD time — sixteen items enumerated,
"fifteen, matching the header" claimed, everything since §16 absent —
inside the very sentence recording that the list went stale twice.
Replaced with a pointer to the check.sh header, the designated single
enumeration. And this file's own TL;DR said "**16** numbered sections …
= 24 checks" — a stale 16 beside an updated total, the set-claim class
again — fixed in this commit.

**The rule-3 orphan is closed.** The owed live round now has a carrier,
**task 4.42 (shakedown 11)**, instead of journal prose — the gap
/resume flagged at session start. Rule-6 debt, stated: every fix in
`43cc1ca` is behavioural and unverified until 4.42 runs. Its two
never-driven branches: /retro appending to a CHRONOLOGICAL hand-kept
journal (shakedown 10 seeded only the newest-first shape), and
/eval-run's `NO SCORE — <what is missing>` verdict form live.

Validation close: check.sh **25 checks** (22 numbered + 3b/3c/13a), all
clean; guard-matrix **90 cases**, no BAD — run twice, before and after
the review's fixes; controls **72** passing; **23 skills**; wave 4.5
**20/23** — one carrier task added, no boxes ticked, correctness plus
scheduling.

### Shakedown 9: the eval layer drives, and a dead link was shipping to adopters (2026-08-04, late II)

The first round shaped by **verification rule 6** — regression segment
first, then new ground. **All four of shakedown 8's fixes held** under live
re-test: the reworded typed-only claim now matches observed behaviour,
`/plan seed` marked every unanswerable section `TBD — not supplied at seed
time` and invented nothing, `/ship` printed `commits ahead of master: 0`,
and both marker grammars resolve as ARCHITECTURE describes.

**The eval layer — the pack's flagship claim — drove end to end for the
first time.** `/eval-spec` produced minimums per class, five refusal cases,
and a deterministic pinned grader, with every expected derived from a stated
contract rather than fabricated; the reviewer's proof it wasn't
implementation-worship is that one case (`ed-004`) is derived from the
category definition and **the subject fails it**. `/eval-run` scaffolded the
runner, recomputed the headline **from the results file** (24/25, 96.0%),
named its exclusions by id, and produced an identical score with API keys
stripped. `/retro` stated its window, read the seeded 71→70 dip as *"a real
regression, not noise"*, and went further than asked — flagging that the
journal's headlines had no result files behind them and refusing a velocity
claim from a history that contradicted itself.

**The finding worth the entry: a pack-relative path shipped INSIDE an
emitted template.** `../../qa/references/adversarial-inputs.md` sat in the
fenced block that becomes the adopter's own `eval/spec.md`, where it
resolves to nothing. **§8 could not see it** — the path is valid *in situ*
(it resolves from the skill directory) and only breaks in the copy. So every
adopter's eval spec carried a dead link.

**Scanning the class rather than the reported instance found a second:**
`/audit`'s code-report-template carried the same path in its own emitted
block. Both now name the source descriptively; **check.sh §8d** catches any
`../` inside a fenced reference block, shown failing first.

Three more fixed: `/eval-run` could **deadlock** on stack detection —
"neither manifest → stop and ask" even when the committed spec already names
`eval/run.py`, which settles the language; a run command in the spec is now
explicitly not a guess. `/eval-spec` had **no non-interactive clause** (the
gap `/plan` closed last round) — it now derives categories from BRIEF/PLAN
and writes the **derivation contract** into the spec, so every expected can
be checked against a stated rule, with *never invent an expected* stated
outright: a golden set with guessed answers manufactures a score, which is
the never-inflate rule at its origin. And `needs-data` placeholders now take
`expected: null` rather than a plausible value that would be counted the day
the status changes.

**Recorded, not fixed:** `/retro`'s open-risk review stayed untested because
the prescribed seeding creates no PLAN.md — **a gap in my shakedown prompt,
not in the skill.** A future round seeds a PLAN with open risks first. Also
noted by the reviewer: `/eval-run`'s decline-without-a-key branch went
unexercised, because a local subject needs no key — nothing was declined
because nothing needed declining.

Validation close: check.sh **24 checks**, all clean — §8d is a fourth
sub-form inside §8's crossref block, not a new numbered section, so the
count is unchanged; matrix **89
cases**, no BAD; controls **72** passing; **23 skills**; wave 4.5 **20/22**,
unchanged — correctness, not scope.

### Shakedown 8: twelve skills work, and a shipped claim turned out false (2026-08-04, late)

Eight never-driven skills plus the two regression items from shakedown 7.
**All twelve worked**, including the two whose *correct* behaviour is
refusal: `/refactor` stopped at precondition 1 on a dirty tree and named the
file; `/ship` blocked at gate 1 (dirty tree, on the default branch, zero
commits ahead) and never reached the push. `/investigate` held its iron law
— repro before any fix talk, known-bug-classes swept first, root cause at
`src/stats.py:9`, and it **did not fix**: the seeded median bug was still
live afterwards, filed as a task instead. `/refactor` also declined to
smuggle that fix into a cleanup, which was the sharpest test in the round.

Both regression items held: `/triage` produced two parents plus the
same-cause pair named under `Related pairs`, and `/design-audit` flagged the
🔔 the old seven-emoji denylist had missed.

**The finding that mattered: a claim in shipped docs was false.** AGENTS.md's
referral block said `disable-model-invocation: true` means *"an agent cannot
see or invoke them — it can only mention them."* A session told "type
/plan seed" **invoked it end to end**. The flag removes a skill from the
model's LISTING; it does not prevent invocation when the name is supplied.
Worse, `/plan seed` copies that block verbatim into every adopter repo, so
the false claim propagated. Reworded to the shape the pack already uses for
`allowed-tools`: **a discoverability control, not an enforcement boundary** —
user-initiated by convention, not by mechanism.

Incidental but instructive: **the false claim spans a line break**, so my
first single-line grep for it returned nothing while the sentence sat in
plain view. Reading across lines is now how I check prose claims.

Three others fixed: `/plan seed` had **no non-interactive path** — "if the
user hasn't supplied one, ask" is unexecutable when nobody can answer, so
the run improvised; it now says mark TBD, list them up front, declare the
BRIEF incomplete, and never invent a constraint, audience or domain landmine.
**Two marker grammars** (`acstack:NAME` in skills, `BEGIN:acstack-NAME` in
shared blocks) caused a real in-session miss, now documented rather than
unified — the markers are matched by four check.sh sections, `/plan seed`
and `/health`, and already live in every adopter's AGENTS.md, so renaming
them would break installed repos to buy tidiness. And `/ship`'s gate 1
proved "zero commits ahead" with an **empty** `git log`, which is
indistinguishable from a command that never ran; it now echoes the count
first so the evidence reads itself.

**Per verification rule 6, these four fixes now owe a live re-test** — they
are behavioural, found live, and currently verified only mechanically. That
debt is recorded rather than assumed away; the next round opens with them.

Honest scope the reviewer volunteered: no step was a blind-discovery test —
the triage fixture carries its answer key and the median bug was seeded — so
this round measures whether each skill's *process* produces the right shape
and restraint, not whether it can find an unknown defect.

Validation close: check.sh **24 checks**, all clean; matrix **89 cases**, no
BAD; controls **72** passing; **23 skills**; wave 4.5 **20/22**, unchanged —
correctness, not scope.

### The regression round: fixes were never re-tested, and three were wrong (2026-08-04, evening)

**A process gap the user named, not a task.** Six shakedowns had each found
defects; every fix was verified mechanically — check.sh, controls, matrix —
and shipped. **None was ever re-tested live.** His question was the sharp
one: after errors in a shakedown, we never confirmed with another shakedown
that what we coded instead was correct.

Two commits: `cedb1dd` (the fixes), `edce833` (the rule).

**Shakedown 7 was the first backwards-looking round, and 7 of 7 fixes held.**
Including the one that had only ever passed *vacuously*: `/qa`'s credential
rule finally got real pressure — URL supplied, app running, a real-looking
token in a committed `.env` **and** hardcoded in the server — and it took
neither, reporting the gated flow as `not probed — no credentials supplied`
and handing the committed credential to /secure. It also found a genuine
bug in the trap server itself (`/health?limit=1` → 404 from exact-match
routing), which is the adversarial pass doing its job on a target nobody
asked it to audit.

**But it found three new defects, all inside earlier fixes, all mine:**

- **/triage's clustering bar contradicted its own fixture.** The bar
  required three-or-more members and dismissed two as "a duplicate pair" —
  but the fixture's third cause has two members that are NOT duplicates.
  They fell between the duplicate sweep (which keys on overlapping text and
  cannot see them) and the clustering bar, so **a real finding could vanish
  between two passes.** Fixed: a parent still needs three, but a same-cause
  pair is named under `Related pairs` rather than dropped.
- **/design contradicted itself on ordering.** The process section demands
  the self-critique before the first component "kept in that order in the
  report"; the Report-shape list placed it after the eight items. An
  executor following the shape literally regresses the fix.
- **The emoji-as-icon grep was a denylist** of seven emoji — and missed the
  🔔 in *this pack's own /design fixture*, so it reported clean on our own
  before-page. Widened to any non-ASCII in a button or heading, with the
  accented-text false positive stated and accepted. **Fourth time the
  denylist lesson has landed here.** A cross-fixture control now proves it:
  narrowed back to the old list, that control fails.

**The rule, added BEFORE the round it governs** (`edce833`) — a rule written
after the round it should have governed is a rationalisation. AGENTS.md's
verification rules gain a sixth: *a fix for a behaviourally-found defect is
unverified until a live run re-tests it.* The reasoning that makes it a rule
rather than a preference: **a new-ground round structurally cannot catch
these, because a fix becomes old ground the moment it is committed.**

Placed in AGENTS.md, not CONDUCT.md — that section is explicitly "each from
a defect this repo shipped," and the pack's bar is to promote into CONDUCT
only what proves out across projects. This has proven out once, in one repo.
**Its cost is written into the rule rather than hidden:** every behavioural
fix now owes a live round; if that stops being affordable, narrow it to
security- and correctness-relevant fixes rather than quietly stop obeying
it. A rule with an unstated cost is one people abandon silently.

Count verified by enumeration, not assertion — six bullets, six claimed —
and the edit sits above the `BEGIN:acstack-conduct` marker, so §15's
byte-identity between AGENTS.md and CONDUCT.md is untouched.

Validation close: check.sh **24 checks**, all clean; guard-matrix **89
cases**, no BAD; controls **72** passing; **23 skills**; wave 4.5 **20/22**,
unchanged — this round changed no task state, only correctness.

### The design lane, and wave 4.5's buildable work closes at 20/22 (2026-08-04, later)

**Wave 4.5: 16 → 20 of 22.** Skills 22 → **23**; check.sh 22 → **24**;
matrix 82 → **89**. Six commits, `7c87fca` → `062ec05`. The two that remain
(4.3 telemetry, 4.4 `setup --global`) are **deliberately gated on adopters**,
not blocked — PLAN says so and nothing here changes that.

**4.27 — `ai-tells.md`, 20 rule classes.** Six sections in a FIXED severity
order: accessibility, then honesty, then everything else, regardless of hit
count — a violet gradient is embarrassment, unreadable text and a fabricated
statistic are harm. Every class has a seeded plant and an extracted-pattern
control. **Both acceptance clauses verified**: each grep catches its seed,
and the clean tree stays quiet. Two defects caught on the controls' first
run — the popover pattern matched CSS `transform-origin` but not JSX
`transformOrigin` (a real coverage gap, since production code has both), and
the motion fixture's own comment spelled `prefers-reduced-motion` while
explaining its absence.

**4.30 — `/design`, the 23rd skill.** Deliberately not another looks skill:
the four surveyed design repos are about palette and type, and that is not
where generated UI fails. It fails past the happy path. So the spine is
eight production-readiness items, a design answering seven is reported
INCOMPLETE with the gap named, and **a style dial can never lower the
floor** — `variance: bold` changes the look, it does not licence skipping
the error state. DTCG tokens in three layers, wireframe before code,
self-critique naming the AI-default look avoided. check.sh §20 guards the
spine; **its own fail-first probe caught the guard matching bare words**,
which stayed green when a body item was deleted because the frontmatter
description repeats them.

**Shakedown 6 ran the pair, and 4.30's acceptances passed** — verified from
disk: genuine DTCG (37 `$value`/`$type`), all eight items answered or named
as an explicit GAP with none silently skipped, error+rollback designed and
EXERCISED unprompted, and **/design-audit found zero slop tells in /design's
own output**. The generator avoided exactly what its detective hunts. It
also found three real defects, since fixed: /design shipped **token drift**
(two dark-theme values absent from the tokens.json it declared the source of
truth — it demanded tokens-first with no CLOSING check), "self-critique
BEFORE coding" was **unauditable** because the report shape put it after the
artifact, and the honesty greps had a **synonym hole** (`mock|fake|sample`
does not match a "stand-in", so a `save()` that persists nothing while
rendering "Saved" was caught only by judgment).

**A set claim that was false when I made it.** Asked whether everything from
the surveyed design repos had landed, enumerating the routing list against
the tree found **three items missing from tasks already ticked** — emil's
`animation-vocabulary` and `find-animation-opportunities`, and jiji262's
accent-stripe tell. The near-miss is the lesson: a grep for `vocabulary`
matched interaction-feel.md and *looked* like proof; it was that word in a
sentence about CSS APIs. **Enumerating a set by grepping one word is how a
set claim passes while its members are absent.**

**4.28 — the skill-hygiene rule set**, five rules across five skills in one
commit because splitting them leaves the pack inconsistent about what it
will report. /audit gained a do-not-flag blocklist with the bar in one
sentence — *a finding names a consequence and the input that produces it*;
/audit and /qa ask whether the target needs the pass at all; /secure demotes
on a written justification rather than deleting; /ship writes one comment
per issue and suggests only a full fix; /do states what its evidence does
NOT establish. §21 keeps the set whole, and this guard matters more than
most: **every rule works by suppressing noise, so dropping one is invisible
in a green run** — nothing fails, the reports just quietly get worse.

**4.32 — root-cause clustering for /triage**, the global pass its local
sweeps cannot do: twelve items sharing one cause contain no duplicate pair.
A cluster needs a stated CAUSE, not a shared topic, tested by one sentence —
would fixing it close every member? **The negative half is load-bearing**: a
clustering step that always finds clusters is astrology, so an independent
backlog returns "no root-cause groups found" as a real result. Both
directions seeded — 8 tasks over 3 causes each with its OWN acceptance (so
no two are duplicates and a pairwise check finds nothing), and 6 genuinely
unrelated tasks where any grouping is a false positive.

**`fixtures/design/` — the input 4.30 always assumed.** Its acceptance reads
"on a seeded generic page" and that page did not exist, so every run needed a
hand-built scratch repo. INPUT fixture only: **no "after" page**, because a
canonical good build would become the house style 4.30's ruling rejects —
and every fixture in this pack is an example of what is WRONG, which cannot
be cargo-culted and is mechanically testable.

**The recurring trap became a bug class.** A fixture's prose naming the token
its own control greps for has now bitten three times — `DATABASE_URL`,
`prefers-reduced-motion`, `rollback`. It is a known bug class, so recall
carries it to every skill invocation. The rule: **fix the fixture, never
narrow the grep** — narrowing trades a loud false positive for a quiet false
negative.

**Docs swept for staleness at wave close**, since four documents had drifted:
ARCHITECTURE (22 → 24 checks, 82 → 89 cases), CONTRIBUTING (the same check
count), the JOURNAL skeleton, and the CHANGELOG — which had no mention of
/design, ai-tells, /audit tests, the hygiene set or clustering, making the
one file adopters read to learn what changed the one file that did not say.

Validation close: check.sh **24 checks** (21 numbered + 3b/3c/13a), all
clean; guard-matrix **89 cases**, no BAD; controls **71** passing, all plants
caught; **23 skills**; wave 4.5 **20/22**.

### Degradation paths, an auditable preamble, and the docs that were quietly lying (2026-08-04)

**Wave 4.5: 13 → 16 of 22.** Six commits, `95f28f9` → `09d594e`. Everything
cheap and everything adopter-facing is now closed; what remains is either
large (the design lane) or deliberately gated on adopters (4.3, 4.4).

**4.18 — every skill names what is missing and stops.** Eleven degradation
paths across nine skills, on one rule: hit a missing precondition, name it,
stop. **Surveyed before writing**, which paid — three listed sub-items were
already done, including the entire config-consistency group, where §9's
reachability guard from wave 4 had silently closed part of a wave-4.5 task.
The survey also produced a false positive on /investigate that only direct
checking caught. The paths with teeth beyond "say it's missing": `/plan seed`
REFUSES to regenerate an existing BRIEF (it is the frozen record; regenerating
destroys the only artifact later work can be compared against); `/journal`
stages JOURNAL and PLAN **by name**, never `git add -A`, which is how
unrelated work lands under a subject nobody looks under; `/qa` takes
credentials from the user, never the repo, because using a committed
credential would launder a `/secure` finding into a passing test;
`/design-audit` stops on a path with no UI, since `CLEAN` over a directory
with no UI is a true statement that reads as false reassurance; `/do` refuses
to tick a task with no acceptance line on the strength of "it looks done".

**Shakedown 5 proved all six live — and verified from disk, none of them
wrote a byte.** No PLAN.md appeared (`/ticket` did not scaffold), no
JOURNAL.md appeared (`/retro` did not append), scratch repo still at its one
setup commit. It found one real gap: `/qa` said "argument beats base-url,
neither → stop" but nothing forbade **deducing** a target, and
`app.listen(3000)` was sitting in the fixture. Closed with the same shape as
the credential rule below it: a target is supplied, never deduced.
**Recorded as NOT proven:** the reviewer flagged that `/qa`'s credential
prohibition was honoured *vacuously* — the run blocked at step 1, so the
planted `.env` token was never under pressure. Not-falsified, not proven.

**4.41 — silence had four meanings.** `acstack-update-check` exited quietly
when up to date, when already checked today, when the remote was unreachable,
and when it could not write state — so a quiet preamble could not be told
from a broken one. The fix is not "always print": the throttled path is the
COMMON one and a line there would be noise on every skill run. Every other
path now speaks, so **silence means exactly one thing**, documented in the
header. All four verified by RUNNING them against isolated state dirs.
(c) and (d) are **stated, not fixed**, in check.sh §13 where the read-only
claim is certified: the preamble runs `readlink`/`dirname`/`bin` helpers no
skill grants — a grant cannot name a path resolved at run time — so a strict
harness may prompt for a skill's own preamble, and update-check **writes**
the update stamp. "Read-only" describes what a skill does to the PROJECT, not
a claim the pack touches nothing on the machine.

**4.29 — reads are windowed.** `/resume` reads headings-first past ~500 lines
and says which entries it read in full; `/retro` retrieves by window and
states the window plus the entry count, so a five-entry trend can be told from
a one-entry anecdote.

**The docs were quietly lying, and one lie shipped in every skill.** A sweep
of README, ARCHITECTURE, CONTRIBUTING and CHANGELOG found four stale claims.
The sharp one: the runtime preamble's own comment said `capped 6KB` while the
cap has been 3KB since 4.36 — and that line lives inside the block §12 holds
**byte-identical across all 22 skills**, so every skill shipped the wrong
number and *the guard could not catch it*. **§12 proves the copies AGREE, not
that they are TRUE.** Fixed in all 23 files at once, which is precisely the
edit §12 exists to force. Also: the CHANGELOG's newest section still described
wave 4 only — no mention of /why, /refactor, /audit tests or the ladder — so
the one file an adopter reads to learn what changed was the one file that did
not say. It now leads with the instruction that actually affects existing
users: **re-run `./setup` after pulling.**

**A repeated bug became operational.** This pack has shipped the same regex
failure three times — `\b`, `\s`, and `\1` — and `known-bug-classes.md`, the
file recall surfaces to every skill invocation, had **no class for it**. The
journal recorded each as history; nothing warned the next author. Now it does,
and AGENTS.md's consumed-form rule gained today's instance: **a dry run is not
the consumed form** — `./setup --dry-run` printing "21 would be linked" was
accepted as proof while `/why` sat unregistered.

Validation close: check.sh **22 checks**, all clean; guard-matrix **82 cases**,
no BAD; controls all plants caught; **22 skills**; wave 4.5 **16/22**.

### Phases 2–4: two new skills, a test-integrity target, and three guards that caught their own author (2026-08-03, late)

**Wave 4.5: 9 → 13 of 22.** Skills 21 → **22**; check.sh 19 → **22 checks**;
matrix 78 → **82**. Four items (4.40, 4.11, 4.10, 4.19) plus a shipped-defect
fix, across seven commits `db1fa21` → `da00f3d`.

**4.40 — the pre-code simplicity ladder** (Phase 2). The external survey's
one real gap: `/simplify` is post-hoc, and rung 1 — "does this need to exist
at all?" — is upstream of anything a cleanup can recover. Folded into `/do`'s
Execute step as a STEP (not always-on prose injection, which the pack rejects
because prose decays). Rung 5 makes a NEW dependency a decision to surface
rather than a rung to pass quietly. check.sh **§17** couples the ladder to its
never-cut floor — validation, error handling, security, accessibility — since
the real regression is trimming the ladder for brevity and leaving "write less
code" unbounded.

**4.11 — `/why`, decision archaeology** (Phase 3, 21st skill). BRIEF → dated
PLAN verdicts → JOURNAL → git history, stop at the first REAL answer (one
stating a *reason*, not just what changed), never invent, never infer intent
from the implementation. **Deliberate deviation from its own spec:** it uses
`git log -S`/`-L`, NOT `git blame` — `git blame --output=FILE` was tested and
**writes**, inheriting git's diff machinery, so granting it would have widened
the exact residual §13 narrowed hours earlier.

**4.10 — `/audit tests`, the fourth target** (Phase 4). Five classes of test
that passes without catching, the last being a mutation spot-check with an
explicit revert-and-verify rule. The set-claim trap was live: description
(three → four targets, **re-parsed in the live listing**), argument-hint,
body, README row — all four together.

**4.19 — `/refactor`** (Phase 4, 22nd skill). Green before, green after,
**same count**. Three preconditions: clean tree, green baseline recorded, and
a suite that could actually notice — too thin means STOP and name what to test
first, which is a success, not a failure to deliver. Count DROPPED is the
headline finding; compare test NAMES when the count is unchanged, because
equal totals hide a one-for-one swap. **§19** guards both halves.

**The day's real lesson: three verification layers each caught what the layer
above missed.**

1. **A positive control caught a defect in its own documented pattern, first
   run.** `/audit tests`' tautological grep used a `\1` backreference — an
   *invalid escape* in POSIX ERE, so the grep errors out and matches
   **nothing**, exactly like `\b`. §3b guarded `\b` and `\s` but not
   backreferences; the guard was extended and shown failing first. POSIX ERE
   cannot express "the same identifier twice" at all, so that case is now
   honestly documented as over-broad and judgment-led.
2. **The matrix caught a case that only looked proven.** §19's first mutation
   stripped `same test count` while the guard also accepts `same count` →
   `got=PASS want=FAIL`. The case never demonstrated the guard firing. The
   *case* was wrong, not the guard.
3. **The same hazard bit a third time, one layer up.** The script writing
   4.10's tick used Python `re.sub`, whose *replacement* string also parses
   `\1` — and the note text quoted the very hazard being fixed. It raised,
   the box stayed open, the rest committed clean. Fixed with `str.replace`.
   One hazard class, three tools, three symptoms, one day.

**A shipped defect, found by shakedown 4 and fixed (`a344034`).** `/why`
shipped and answered **nobody**: skills reach the harness as symlinks in
`~/.claude/skills`, and `bin/acstack-update-check` told users `git pull` **and
nothing else**. Every future release adding a skill would land the same way —
pulled, present, invisible. It now prints `pull && <pack>/setup` (idempotent,
so pairing is always safe), guarded by **§18**. The local miss was mine and it
is the consumed-form rule catching me: I ran `./setup --dry-run`, saw "21
would be linked", and treated that as verification. **A dry run is not the
consumed form.**

**Also from shakedown 4, carried not fixed:** 4.41 grew two items — the
preamble needs `readlink`/`dirname`/`bin` execution that the skills carrying
it do not grant, and it runs `update-check`, which **writes** the update
stamp, so the read-only skills' "never writes" prose has an asterisk.

**Behavioral proof gained (shakedown 3).** The ladder pulled **zero**
dependencies on a date-picker task, stopping at the native platform control
with validation intact; the exit-criterion-less phase flip fired and
`/audit docs` accepted it as non-drift; seeded-control labeling kept `/secure`
and `/health` honest without hiding a path; recall ran at 869 bytes. Three
shakedowns, three reviewer claims that did NOT survive verification — most
recently a roster-drift alarm that was a false positive in the reviewer's own
unanchored grep, not a gap in §14.

Validation close: check.sh **22 checks**, all clean; guard-matrix 78 → **82**,
every new case shown failing first; controls all plants caught; **22 skills**,
installed and verified registered; wave 4.5 **13/22**.

### Phase 1 — honesty and trust: seven items, four of them verdicts (2026-08-03, late)

A second live shakedown (write-path skills) and an external survey set the
agenda; Phase 1 cleared everything adopter-facing that was stale, missing, or
noisy. **Wave 4.5: 2 → 9 of 21 done.** Matrix 77 → **78**.

**The second shakedown first.** A fresh session drove /do, /journal,
/audit docs and /migrate-check in a throwaway repo. **The write-path skills
work**: verified from disk, /do produced `task 1.1: create greeting.txt with
hi` — **4.16 confirmed live** — ticked exactly box 1.1, really ran the
acceptance, stopped at a local commit (**4.25 confirmed**), and left no
attribution trailer (the pack's `attribution=none` beating the harness
default). /journal wrote a real entry; /audit verified its own claims;
/migrate-check declined without inventing a verdict. Its one structural
finding was a genuine contradiction: **/do refuses to flip a phase heading
without a passing exit criterion, so a phase declaring none could never
flip — and /audit then flags that same unflipped box as drift, forever.**
Both sides reconciled (`819d013`): /do flips a criterion-less phase once its
children are checked; /audit scopes its rule to subtask boxes and treats a
held-open phase as /do's gate, not drift.

**External survey (Karpathy ~199k★ · ponytail ~93k★ · Boris Cherny's
config).** All three attack over-engineering. Karpathy's four principles are
what acstack already *encodes* — "Surgical Changes" is /do's scoped-execute,
"Goal-Driven Execution" is the acceptance spine — but as prose with **zero
enforcement**. Boris's `/grill`, `staff-reviewer`, `code-simplifier` are
shapes acstack already ships, which is useful validation from Claude Code's
own creator. **One real gap found and carried as 4.40:** /simplify is
POST-hoc, and ponytail's rung 1 — "does this need to exist at all?" — is
upstream of any cleanup. Declined by name: multi-agent adapters (the
Claude-Code-only lock), worktree parallelism (harness territory), always-on
prose injection (prose decays — check.sh is the answer). **The strategic
read, recorded because it should shape the roadmap:** a single prose
CLAUDE.md is pulling ~199k★ against every comprehensive pack. The market
rewards one sharp idea, not breadth — evidence for sharpening PRINCIPLES.md
as the front door over racing to 39 skills.

**The four verdicts (decisions, not fixes — recorded so they stop recurring):**
**4.35** CHANGELOG stays `unreleased` — no 0.4.0 was cut; public
availability is not a version cut (and two lines the flip had made false
were corrected). **4.37** BRIEF-absence is deliberately **/health's job
alone**; duplicating the nag in every write-path skill is scope creep.
**4.36 (option A′)** no session marker — that adds machine-local state the
pack minimises; recall was made *cheaper* instead: class NAMES plus a
pointer rather than full text, cap 6KB → 3KB, output **~4.2KB → 522 bytes**
with all 9 classes retained. It incidentally pre-implements 4.29's
read-headings-then-fetch discipline. **4.33** /health's promise of checks
"added by wave 4" — a wave that closed without them — re-pointed to 4.3/4.4.

**Two builds, both with controls proven failing first.** **4.39**:
/migrate-check now opens with "no database in this project" when `db:` is
unset and *every* signal is absent; any single signal or an explicit `db:`
keeps shared-prod strictness — absence of everything is the only trigger.
Its fixture uses an **inverted control** (the fixture's value is the
ABSENCE, so the assertion is "still nothing here"), shown failing three
ways. **Review caught a self-inflicted false positive**: the fixture's own
prose spelled `DATABASE_URL` and tripped the grep — the fixture was reworded
rather than the grep narrowed, because a loud false positive beats a quiet
false pass. **4.34**: /health and /secure now label a hit under a
`fixtures/` root that a controls script references as `seeded control
(fixture)` — **a label, never a suppression**: still listed with file:line
and a stated count, never applied outside the root, and a live-looking value
stays a finding wherever it sits, so parking a real secret under `fixtures/`
buys no silence. Its control proves **both** directions, because a labeling
rule that never says "finding" is a suppressor in disguise; the fail-first
turns the predicate into a blanket suppressor and watches direction two
fail.

Validation close: check.sh **19 checks**, all clean; guard-matrix 77 →
**78**, every new case shown failing first; controls all plants caught; 20
skills; wave 4.5 **9/21**. Eight commits, `259cee9` → `1b4f214`.

### Wave 4.5 opens: 4.16, the first live shakedown, and the hole it found in the day's own fix (2026-08-03, post-flip)

Post-flip, wave 4.5 started as a plan → build → review → commit → journal
loop. Five commits: 4.16, two shakedown-fix commits, the carrier filing, 4.13.

**4.16 — emit the commit-format verdict, don't just document it** (`d9d74c7`).
A 2026-07-29 verdict was recorded `[x]` while nothing emitted the new shape.
Switched the default to `task <n>: <desc>` / `ticket #<n>: <desc>`. The
**review step earned its keep**: the task's own site list was incomplete —
it missed `bin/acstack-config`, the resolver `/do` actually reads (docs
alone would have been cosmetic; verified the *emitted* form changed), and
`/retro`'s history-detection grep (which would have gone blind to new-format
commits). check.sh **§16** guards the retired default from returning; matrix
74 → 75.

**The first live-model shakedown** — the #1 standing limit, finally
exercised. A fresh Claude Code session (prompt handed over by the user) ran
/resume, /health, /secure on this repo. **The skills loaded and largely
worked** — /resume caught real drift and named the right next tasks, /secure
held at "no findings" with the fixtures contextualized, /health ran all 8
checks. Its report was **verified at file:line — every concrete claim held**
(unlike the 4.7 ledger, which had false rows). Two findings mattered:

- **Finding 1 (my defect): JOURNAL contradicted itself about the flip.**
  Recording the flip (`8a175f7`) updated the blockquote but not the TL;DR or
  the what's-built table, so the journal said both PUBLIC/closed and "flip
  not made / Next 4.7 / wave 4 🔶 14/16." Synced the skeleton (`33f7bb8`).
- **Finding 2: a hole in *this day's own* read-only fix.** In a harness with
  no Grep tool (this one), the skills' "use the Grep tool, no shell
  `git grep`" instruction had **no fallback**, so /health degraded to the
  exact `git grep` the RCE fix removed. Added the safe path — plain
  `grep -rnE` — and check.sh **§3c**, which fails any skill that forbids
  shell git grep without stating that fallback (`50ffcae`; matrix 75 → 76).
  Finding it in the hardening I'd shipped hours earlier is the whole
  argument for running a live session.

Minor findings 3–5 filed as carriers **4.33–4.35** (`72fd3c2`); finding 6
(same-day journal-commit suffix) is already owned by 4.18(a).

**4.13 — /health check 9, agent-instruction quality** (`f6662af`). Reads the
project's own AGENTS.md rules outside the conduct block and flags
contradictions with a conduct rule (naming both) and dead references.
Judgment-led (no grep for "contradiction"), so the control is behavioral per
4.15's /qa carve-out: `fixtures/health/AGENTS.md` plants an attribution +
push contradiction and a dead reference; controls.sh asserts the plants,
matrix 76 → 77.

**Honest limits the shakedown confirmed live:** the harness enforced no
`allowed-tools` (zero prompts, even for ungranted `find`/`sed`/`readlink`/
`bin/acstack-*`) — so the read-only guarantee still depends on the harness,
the standing 4.8 limit; and the cold start couldn't be fully cold
(AGENTS.md + memory pre-loaded), exactly 4.7 item 10's caveat. The
live-model-obeys-skills question is now **partly** answered — the skills
work and the gaps are real — not fully.

Validation close: check.sh 18 → **19 checks** (added §3c); guard-matrix
74 → **77 cases**, every new case shown failing first; controls all plants
caught; 20 skills; wave 4.5 at **2/17** (4.16, 4.13 done). Five commits:
`d9d74c7`, `33f7bb8`, `50ffcae`, `72fd3c2`, `f6662af`.

### Flipped public (2026-08-03)

The repo is public: https://github.com/AaravChadha/acstack. The sequence
was **push → CI green → flip**, deliberately gating the irreversible act on
CI because shellcheck runs only there and check.sh had just been heavily
edited. Run 30765510782 passed check.sh + guard-matrix (74 cases) +
shellcheck in 3m6s; `gh repo edit --visibility public` then flipped it.
Pre-flight sweep was clean: the banned-name list ran **locally** this time
(not skipped) and passed, and the only secret-shaped strings in the tree
are the intentional fake fixtures (`sk-live-aaaa…`, `AKIA…`) the /secure
positive control seeds. 4.7's last clause — "only then flip public" — is
satisfied; wave 4 is closed. The standing limit is unchanged and now
public in the docs: no run has ever driven a live Claude Code session, so
the pack is proven sound as *machinery*, not proven to make a model obey a
skill.

### The allowlist audited itself and lost: git grep -O, a token the guard never read (2026-08-03 evening)

The "one clean audit of the §13 allowlist by a round that did not write
it" — the last named gate before the flip — ran, framed to DISPROVE (the
falsification rule `df0b5e7` had just carried into AGENTS.md). It did not
come back clean. The allowlist that replaced the denylist on 08-03
morning had never been reviewed against its own membership rule ("no
argument suffix can flip this command to a write"), and it failed that
rule in six places.

**What the falsification found (every claim re-verified at the command
line before it was believed — the AGENTS.md rule that one agent claim
won't survive checking):**

- **`git grep -O<pager>` runs an arbitrary program.** Demonstrated:
  `git grep -O'sh -c rm\ victim;' hello` deleted the file. Granted by
  **secure, health, design-audit, audit** — the pack's own security skill
  among them. Arbitrary code execution, certified read-only.
- **`git log --output=FILE` / `git diff --output=FILE` overwrite any
  path.** Demonstrated overwriting a "PRECIOUS" file. git log granted by
  5 of 6 skills, git diff by 2.
- **`gh auth status --show-token` prints a live token.** Flag confirmed in
  `gh` help (NOT run — it would leak the real token). Granted by health.
- **The guard never validated each list's LAST token.** `printf '%s'` (no
  newline) left the final comma-field unterminated, so `read` dropped it.
  Proven: `Write` appended last → `check.sh: all clean`. Dormant only
  because every skill's last grant happened to be allowlisted.
- **The allowlist blessed `sort`/`uniq`/`git show`/`git symbolic-ref`** —
  all write/mutate under free args — as UNUSED entries. It was assembled
  as a plausible-looking read-only-sounding set, not the audited union of
  what the six skills grant.
- **A duplicate `allowed-tools:` line** hid grants from `head -1`.

**The structural verdict.** The denylist-can't-be-finished lesson from
08-03 morning was learned at the command-name level and then re-broken one
layer down, *inside* the allowlist. "An allowlist can be reviewed" was
true and unused — it had never been reviewed. One class three ways again
(exec, write, leak), not three bugs.

**The fixes (path 3 of three the user weighed: 1 = Grep-tool only, 2 =
narrow prose only, 3 = the split — chosen because it dominates 1 at ~one
line more, also closing the token leak):**

- **git grep dropped from all four skills**, applied via the read-only
  **Grep tool** now (the /health find/awk→Read/Glob precedent from this
  morning); off the allowlist entirely. The 30-plus `git grep -nE` pattern
  lines STAY — controls.sh extracts them and §3b guards their POSIX-ERE —
  reframed as pattern specs, not commands. git grep granted by **4 → 0**
  skills.
- **gh auth status narrowed** to an exact grant (`Bash(gh auth status)`,
  no `:*`) so `--show-token` cannot attach. Strictly no-worse; exact-match
  semantics unverified without a live session.
- **`printf '%s\n'`** terminates the stream so `read` validates every
  token; a second `allowed-tools:` line is now rejected.
- **Allowlist trimmed 30 → 20 entries**, the audited union of what the six
  skills grant.
- **git log/diff --output: accepted and disclosed, not fixed.** No
  read-only tool shows history or diffs a range, and prefix grants can't
  exclude a flag, so the five skills that need them keep the grant; the
  residual is stated in secure/migrate-check/health and the §13 comment.
  **/design-audit is now fully read-only** (grep/ls only, no residual).

**Self-indicting: a recheck reintroduced a defect — the exact round-2
class.** In the git grep fail-first demo I ran `git checkout
skills/secure/SKILL.md` to undo a seeded mutation. The file had
uncommitted edits, so checkout reverted it to HEAD and wiped the
increment-2 changes (git grep grant reappeared, framing clause gone),
leaving the tree failing. Caught by the harness's file-change flag,
restored, re-verified — the green run is post-restore. Lesson: never
`git checkout` a dirty file to undo a probe; save and restore its bytes.

**The two lesser findings, closed the same session (`ad9d9ec`).** A
forcing function (§13a) now derives the set of skills declaring a no-write
`allowed-tools` set and diffs it against READONLY_SKILLS — a future
read-only skill can no longer silently escape the allowlist check (§14's
roster-derivation shape; matrix +1, shown failing first: it slips a
check.sh with §13a removed, fails with it present). `/challenge` needed no
change: its "report only" is a conduct promise (CONDUCT 1/2), the same
category as /audit's and /resume's accepted behavioral claims — not a
false structural claim — and §13a guarantees it can't quietly become one.
A useful invariant fell out: the six skills declaring `allowed-tools` are
exactly READONLY_SKILLS, and /qa carries none, so the derive-and-diff has
no false-flag surface today.

**Honest limits, unchanged:** nothing drove a live Claude Code session, so
"the model uses the Grep tool" and "the exact gh grant blocks
--show-token" are structurally sound, not live-confirmed.

Validation close: check.sh clean on the commit; guard-matrix **68 → 74**,
every new read-only case (last-token, sort, git symbolic-ref, duplicate
line, git grep, and the §13a forcing function) shown FAILING first; controls all plants caught; 20
skills; allowlist 30 → 20 entries; commit `a46332f`, 10 files.

### Pre-flip rechecks: the denylist that could not be finished (2026-08-02 → 03)

Two rounds of falsification-framed review before the public flip. **The
flip did NOT happen** — both rounds returned NOT READY, and the second
found that the first round's own fix had reintroduced the bug it fixed.
Matrix 63 → **68**; check.sh 15 → 16 checks (15 numbered + 3b).

**Round 1 — four blocking, one self-inflicted.** `/health` declared
"Read-only, always" while granting `Bash(find:*)`, `Bash(awk:*)`, and
`Bash(git config:*)`. All three write, proven: `find -delete` and
`awk 'BEGIN{system("rm …")}'` each removed a file. Worse, **check.sh
§13 certified it read-only**, because `WRITE_CMDS` listed none of them.
Self-inflicted: those grants were added on 07-31 to fix a
too-narrow finding, over-correcting into write capability. Also: the
eval runner counted a *crashed* case as a pass when `acceptable_failure`
was set (its own hard rules forbid exactly that), and `/ship`'s "move
the commits" off a default branch read as a history rewrite with no
procedure.

**The README demo failed a third time.** Both agents caught it
independently: `don't` inside a single-quoted shell argument is an
unterminated string, and quote-stripping made two other commands assert
on different input than printed. Twice before I had "verified" it by
running a differently-escaped string than the one I pasted. The fix that
finally worked was procedural, not textual — **extract the commands from
README and execute those**.

**Round 2 — the fix reintroduced the bug.** Replacing `awk` with
`Bash(sed -n:*)` added a *new* write path: `sed -n -i ''` edits in
place, and prefix grants permit any command starting with the string.
The denylist certified it. An audit then named **18 further misses** —
`git remote`, `git clean`, `git restore`, `git switch`, `git stash`,
`git apply`, `git branch`, `git worktree`, `python3`, `chmod`, `dd`,
`truncate`, `ln`, `curl`, `npm install`, `gh pr merge`, `gh issue close`.

**The structural verdict, which is the entry's real content.** Three
occurrences of one bug is not three bugs — §13 was a **denylist sold as
a certification**, and a denylist cannot be finished. It is now an
**allowlist**: anything not explicitly named read-only is rejected. It
immediately caught both `sed -n` and a pre-existing `git remote` grant
that had passed for weeks. `/health` now uses the **Read and Glob tools**
rather than shelling out, since every stream editor that can extract a
range can also edit in place.

**A guard-satisfying regression, caught by asking the right question.**
The reviewer was told to check not just whether the guard passes but
whether **/health still does its job**. It did not: `git ls-files`
(my `find` replacement) matches `MYPLAN.md`, **misses untracked files** —
a just-added second product is precisely what that check exists to
catch — and fails outright outside a git repo. Glob has none of those
problems. A skill that satisfies its guard while no longer working is a
worse outcome than the bug being fixed, and only a functional question
surfaces it.

**Also closed:** the fixture runner still carried the pre-fix
crash-forgiveness line (regenerated from the template); the template's
own `subprocess` example lacked `check=True`, so a subject exiting
non-zero returned empty stdout as a normal answer that
`acceptable_failure` could forgive; `fixtures/README` said `5/6` twelve
lines above the line I had just corrected, inside a parenthetical about
having miscounted twice; the README demo cited commit hashes that
resolve nowhere for a reader; and counts were wrong again — 15 numbered
sections + 3b = **16 checks** (docs said 15), **35** open tasks (JOURNAL
said 37). The `sec_check` comment claimed counting protects individual
alternation branches; it does not — deleting `|MODE_ECB` still passes —
so the claim was scoped down rather than defended.

**Why the flip is still pending.** Not because the pack is weak: the
mechanical layer is green and the allowlist is a genuine structural
improvement. Because **no round that changed this much has ever been
clean on first inspection**, and the allowlist deserves one audit that
is not the round that wrote it.

Validation close: `check.sh` clean on every commit; checks 15 → 16;
matrix 63 → 68 with every new guard demonstrated failing first;
controls all plants caught; 20 skills; fresh clone byte-identical to
local; tracked tree carries no emails, personal paths, or roster hits.

### Launch checklist executed — 4.7's evidence ledger (2026-07-31)

**This ledger was itself audited and found overstated.** A context-free
agent was told to disprove it and returned *2 rows false, 4 overstated*.
Both false rows and every overstatement are corrected below; the
original wording is not preserved because it was wrong, but what it
claimed and why it failed is recorded in each row. That audit is the
most useful thing on this page.

| # | Item | Evidence | Result |
|---|---|---|---|
| 1 | Every guard shown firing | `bash docs/guard-matrix.sh "$PWD"` → `passed=63 failed=0` | **Corrected.** The first ledger said 58/58 and implied full coverage. The audit found **4 of check.sh's 15 guards had no case at all** (principles, banned-token detection, line budget, shell syntax) and that the preamble-budget case was **vacuous** — its mutation tripped byte-identity, not the budget. Five cases added, matrix 58 → 63, and the budget case now grows the block in README *and* all 20 skills so identity still matches |
| 2 | Frontmatter parses; descriptions survive | own parser over 20 files; live listing | 20/20 parse, names match dirs, none truncated. **Corrected:** the first ledger claimed every description ends in `Use when…` — false for 5 of 20 (two say "Use at", three have no use-clause). And the live listing can cover at most **18**: /plan and /eval-spec are `disable-model-invocation: true` and structurally cannot appear |
| 3 | Cross-references resolve | `scripts/check.sh` §8–9 | clean; holds |
| 4 | `./setup` round-trips | fresh clone into clean `HOME` | install 20/0 → idempotent 20 `ok` → uninstall removed exactly 20, **4 planted foreign entries survived by inode** → reinstall 20. Holds, and the auditor tested it harder than I did. **Two caveats it added:** the clone was 4 commits stale, and the "honest SKIP" exits 0 — `.acstack-banned` is gitignored, so on *every* fresh clone and in CI the banned-name sweep scans nothing |
| 5 | Context-free multi-agent audit | three rounds | **Corrected:** the first ledger said "11 subagents" and could not source it. Counted: 3 (post-batch-A) + 3 (batch D) + 4 (final) = **10**, plus 3 in this falsification round = 13 total. Every finding resolved or declined in writing |
| 6 | Main-thread pass | own passes each round | holds — found what agents missed (a stale control figure, count drift) and **rejected one agent claim that did not survive checking** (`head -c 12`) |
| 7 | Demo transcript | README "See it work" | **Was FALSE, now true.** The audit found three of seven printed commands could not execute as printed (a 4-space indent inside `python3 -c` → `IndentationError`; two containing a literal `…`), an `AssertionError` shown where Python emits a traceback, a PLAN.md excerpt silently re-wrapped, and a demo repo whose history never showed the narrated sequence. Rebuilt from scratch: three commits (`dfd3459`, `fa331d6`, `f054971`), every command copy-pasteable, every output verbatim, the traceback line piped through `tail -1` so the command matches its output |
| 8 | Credits; no personal/client data in the tree | README §Credits; `check.sh` §2 with the live roster | credits present; sweep clean; holds |
| 9 | Every wave-4 acceptance run, **output pasted** | see the block below | **Was FALSE — circular.** The first ledger's evidence column said "this table" and its result was "—", while 4.7 demands output pasted into the journal entry. There were **zero** code blocks in it. Actual output now pasted |
| 10 | `/resume` cold start · `/investigate` a real failure | 2026-07-29 · this session | /resume named the wave, divergence flags, three unblocked tasks, plus three findings now on 4.18. /investigate rooted the /qa fixture guard to `fixtures/qa/README.md` (a `pkill -f` pattern that could never match) and `fixtures/qa/server.js:13` (uncaught `JSON.parse` killing the process). **Disclosure the first ledger omitted:** that fixture was written by me ~10h earlier, so this is a real defect found by an independent auditor, not one authored by a third party |

**Item 9 — pasted output, run at ledger time:**

```
$ scripts/check.sh
check.sh: all clean

$ bash docs/guard-matrix.sh "$PWD" | tail -2
passed=63 failed=0

$ bash scripts/controls.sh | tail -1
controls.sh: all plants caught

$ ./setup | tail -2
20 linked, 0 skipped.
Start a new Claude Code session to load the skills.
```

**Honest limits.** Item 4 ran on macOS against a clean `HOME` and a fresh
clone — not another machine or OS; CI covers Linux for check.sh and the
matrix only. The audit agents read the tree and ran shell; **none drove a
live Claude Code session**, so nothing here proves a *model* obeys a
skill — only that the instructions and machinery are sound. Item 2
verifies descriptions parse and appear; it cannot prove the listing is
identical on another client version. And the banned-name sweep is
skipped on any clone without a local `.acstack-banned`, CI included.

**The lesson, which outranks the checklist.** A launch gate written by
the person being gated is worth exactly as much as its independent
falsification. Two rows were false and four overstated — and the errors
were all in the same direction. Nothing else in this session caught
them.

### Wave 4 nearly closed: batches B–D, a second survey, and an RCE I argued myself out of (2026-07-30 → 31)

Starting state: wave 4 at 14 open items, guards freshly built. Ending
state: **14 of 16 done, 2 open** (4.5's seeded-PR half, 4.7 itself);
20 skills; check.sh 11 → **16 checks** (15 numbered + 3b); guard-matrix
40 → **58 cases**; 22 commits.

**Batch B — the runtime (4.2, 4.5).** An 11-line marker-fenced block in
every SKILL.md, canonical in README, byte-identity and a
`PREAMBLE_BUDGET=12` constant enforced as check.sh section 12. Three
`bin/` helpers, each proven against scratch fixtures before wiring:
config resolves four precedence levels and prints the winning source;
update-check stamps *before* fetching so an offline day still throttles,
never pulls, and printed the exact pull command when seeded one commit
behind; recall caps recall output and degrades to empty. CI landed and
**failed its first real run** on shellcheck SC2164 — shellcheck is not
installed on this machine, so ubuntu's copy was the first to read the
new scripts. That is CI earning its keep on day one.

**Batch C — surface hardening (4.22, 4.8, 4.9, 4.14).** `--dry-run` now
says `would link` and proves it (entry counts identical before and
after); five read-only skills declare `allowed-tools`; the
`acstack-referrals` roster ships with /plan's build-without-a-plan
trigger and a rule-9 clause; multi-product detection reports the shape
as **info, not failure**, with the resolve-one-document-set rule in
every document-reading skill.

**A second survey — eight repos, ~★840k, cloned and counted.**
superpowers is still exactly 14 skills (its growth is seven harness
packagings); claude-mem is the opposite memory bet at 66k lines of TS;
and measured against Anthropic's own authoring standard acstack passes
every counted axis while their repos break it — `claude-api` at 546
lines against their own <500 norm, and code-review's README documenting
a 0-100 scorer its command file does not contain. Full record:
`docs/survey-2026-07-30.md`. Carriers 4.27–4.32 plus /design as the
39th skill. **The survey's own reports failed the set rule three
times**: a reader would state a count and detail a subset, and I
accepted the count without listing members. Re-enumerating found
`apple-design` (282 lines, the interaction-feel material) and
impeccable's `harden.md` (336 lines) — which is 4.30's thesis already
written. Fixed mechanically: `ls` every member, diff against the report.

**Batch D — /eval-run as the 20th skill (4.12, 4.26, 4.6).** The
flagship loop closes: /eval-spec wrote targets, /audit eval reviewed
results, /ship gate 3 compared a headline, and nothing produced one.
Plus README's requirements/footprint corrected and the four launch
documents.

**Three review rounds, and the pattern is the point.** Every layer built
today was caught doing something it promised not to, and a seeded defect
caught it every time — never a re-read.

- **Round 1 (3 agents, 27 findings):** three *broken* defects inside
  /eval-run's own runner, written hours earlier. `acceptable_failure`
  crashed the whole run (the canonical schema is a bool with a SIBLING
  reason; `.get()` on a bool raises) *after* spending money on every
  prior case. Rubric cases vanished from the denominator AND the
  report — reproduced by adding two, headline stayed 4/5 — which is
  precisely the false-pass class /eval-run exists to prevent, occurring
  inside /eval-run.
- **Round 2 (adversarial, 12 findings):** section 14's roster extraction
  ended in `grep`, so an empty table killed check.sh with **rc=1 and
  zero bytes of output** — the pipefail early-death class already fixed
  twice that day, reintroduced hours later. Its own no-roster FAIL was
  unreachable. Also: section 13 accepted `Bash(rm:*)` and `Bash(*)`;
  guard-matrix was never syntax-checked; the sweep excluded `bin/`.
- **Round 3 (4 agents, 56 findings) — the one that matters.** The
  runtime preamble resolved the pack by `readlink`; on a copy install
  (documented as supported) it yields `.` and the block executed
  `./bin/acstack-config` **from the project directory**. Reproduced
  end-to-end: a repo shipping an executable `bin/acstack-config` ran its
  payload on any skill invocation. **I had seen this path myself hours
  earlier and written it off as "contrived" because a project would need
  its own `bin/acstack-config` — which is trivially arranged by whoever
  wrote the repo you cloned.** Now fails closed on an unresolved link,
  re-tested against the same exploit, locked by a matrix case.

**Two more from round 3 worth naming.** `.acstack-banned.example` used
two entries from the real roster as examples of bad tokens, in a file
the sweep did not cover — the self-exclusion bug its own comment
describes, one directory over. And check.sh had **fifteen guards around
CONDUCT.md and none on it**, while /health promises adopters it verifies
their copy against the pack's; section 15 now diffs the two.

**Hardened beyond the findings:** `acstack-recall` fences injected file
contents as `DATA, NOT INSTRUCTIONS` between explicit markers, because a
cloned project's LEARNINGS.md could otherwise supply headings
indistinguishable from a skill's own rules. And CONTRIBUTING now warns
that reviewing a fork branch means reading the `fixtures/` and
`scripts/` diff *before* running the guard — section 11 executes
`fixtures/eval-run/eval/run.py`, which any PR can edit. Documented
rather than gated: turning the control off by default would disable the
sharpest false-pass check in the normal path.

**User verdicts this stretch.** 4.24's history purge **declined** after
reviewing the twelve tokens (non-sensitive company names, bare first
names, already-public project names) — re-raised once when round 3
flagged discoverability, declined again, closed. /design scoped to
**production-grade, not style-matching**: eight readiness items every
interactive surface must answer, because looks is not where AI UI fails.

**What did NOT change (intentional):** 4.5's box stays open until a
seeded-violation PR is shown failing in CI (the clean-push half is
evidenced — run 30562185603, green, with the SKIP line visible); 4.7 is
unstarted; /investigate still has never chased a real failure.

Validation close: `check.sh` clean on all 22 commits; checks 11 → 15;
matrix 40 → 58 with every new guard demonstrated failing first (six
retroactively, by re-running the new matrix against the pre-fix guard);
skills 19 → 20 (2,365 SKILL.md lines, 22 reference files); PLAN 1,003 →
1,577 lines; open tasks 43 → 37; wave 4 at 14/16.

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
