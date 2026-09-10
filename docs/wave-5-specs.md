# Wave-5 specs — gates: pre-flight + verification

> **What this file is.** Per-item designs for wave 5, written at wave start
> per PLAN.md's process, at the same fidelity as waves 2–4. Build follows
> approval, one increment at a time, in the build order at the end.
> **Drafted:** 2026-08-17. ~~**Status: awaiting approval — nothing below is
> built yet.**~~ **Status (2026-08-17, later): approved; build in progress**
> in the order at the end, one increment per commit. The packaging question — how many skills these five tasks
> become — was ruled before the designs, as **shape D (four skills)**; it
> changes what exists, so it could not be deferred to build time. The
> rejected shapes are kept with their reasons, including one argument of
> mine that was withdrawn.

Wave 5's goal, from PLAN.md: generalize `/migrate-check`'s shape — read-only,
classify every change additive vs destructive, end in a written GO/NO-GO —
into the lane no surveyed pack occupies, plus the one verification skill
worth building.

---

## The binding constraint, measured first

Every `description:` loads at **every session start for every user**, whether
or not anything is invoked. §28 caps the total at **12,000 chars**, 600 per
description, and 4.59 set that cap *deliberately below what the roadmap would
cost if every planned skill shipped as a skill*. That is not an accident to
route around; it is the mechanism forcing this decision.

Measured 2026-08-17, not recalled:

| | |
|---|---|
| Current total | **9,139 / 12,000** |
| Headroom | **2,861** |
| Skills | 23, mean **397**, max **510** (`/design`) |
| Wave 5 at five skills × mean | **1,985**, leaving **876** |
| Still unbuilt after wave 5 | wave 6 (7 tasks) + wave 7 (4) = **11** |

876 chars across 11 remaining tasks is ~80 each — roughly a sentence. **Wave
5 as five model-invocable skills does not starve itself; it starves waves 6
and 7.** 4.66 already did this arithmetic for one item, costing `/careful` at
~405 chars against the same 2,861.

So the wave's first question is not "how do these five work" but "how many
descriptions do these five cost".

---

## RESOLVED — packaging: shape D (four skills)

Ruled 2026-08-17, after the budget arithmetic turned out **not** to
discriminate. Waves 6–7 are 11 tasks; folded hard they still cost ~5
descriptions ≈ 1,985 chars. Every candidate shape leaves less than that:

| Shape | New descriptions | Est. cost | Leaves 6–7 | Short by |
|---|---|---|---|---|
| A — five skills as PLAN words them | 5 | ~2,005 | ~856 | ~1,130 |
| **D — chosen** | **4** | **~1,705** | **~1,155** | ~830 |
| B — `/gate` folding 5.2 + 5.3 | 3 | ~1,400 | ~1,460 | ~525 |
| C — widen shipped `/migrate-check` | 2 | ~1,050 | ~1,810 | ~175 |

**None of them fit.** §28's cap gets revisited before wave 6 under every
option — which is what 4.59 built it to force. Once the budget stops
separating the options, the criterion becomes which shape is best designed.

**Shape D — the chosen four:**

| Skill | Absorbs |
|---|---|
| `/contract-check` | 5.2 |
| `/careful` | 5.3 |
| `/deps` — modes `review` (default), `upgrade` | 5.1 + 5.5 |
| `/verify` | 5.4 |

D is PLAN as written with exactly one fold, and the fold is the defensible
one: 5.1 and 5.5 read the same manifest and the same call sites, so they
differ by *question asked*, not by surface touched — a mode split. Three of
four items ship exactly as specced, and no new abstraction is introduced.

**Why `/careful` stays standalone.** Its cost is the only one in this
comparison that was ever **measured**: 4.66 costed it at ~405 chars and ruled
that a gate must fire *when the model is about to act*, which is why it
declined typed-only for this shape. A description covering two subjects fires
less precisely than one covering a single subject, and this is the item where
that loss is least affordable.

**A rejected** — spends 70% of remaining headroom on 31% of remaining tasks
and leaves waves 6–7 unbuildable without a cap change, having burned the
slack that would have funded the argument for one.

**B rejected** — folds `/careful` into `/gate operation`, trading measured
trigger precision for ~300 chars, in a comparison where no shape avoids the
cap conversation anyway. `/gate operation` is also a worse thing to type in a
hurry than `/careful`.

**C rejected, and the argument for it corrected rather than restated.** C was
initially argued as more than a budget play: that `/contract-check` and
`/careful` sitting beside `/migrate-check` would be a structural duplicate,
"the duplication 4.48 and 4.61 exist to catch". **That was wrong.** 4.48
concerns a duplicated count derivation and 4.61 duplicated conditional
content *inside one skill*; neither covers two skills sharing a report shape.
The pack already ships five report-shaped skills — `/audit`, `/qa`,
`/secure`, `/health`, `/triage` — that share verdict-first structure and are
not duplicates of each other. Shared shape lives in the conventions and in
§10's guard.

With that argument withdrawn, C's remaining case was budget alone, bought by
renaming the pack's hardest safety trigger: `/migrate-check` is shipped,
shakedown-proven, and carries a `MUST be run before any migration` line that
adopter files already point at. Not worth it for a smaller share of a
shortfall. **Keeping the name while adding targets was also rejected** — a
skill called `migrate-check` performing contract and operation gating is a
name that lies about scope, which is the rot this repo keeps fixing.

**What C was right about, kept:** the three gates do share real content. That
is handled by citation, not by merging — see Cross-cutting below.

## Cross-cutting

**The gate anatomy**, taken from `/migrate-check` rather than invented — it
is the wave's stated template and the only member already shipped:

1. **Verdict first.** `GO` / `NO-GO` on line one, then evidence per finding.
   §10 already requires verdict-first for report-shaped skills.
2. **Classify every change**, additive vs destructive, one row each — never a
   summary that omits the ones that passed.
3. **A safe alternative per destructive row** (`/migrate-check`'s
   add-new-then-deprecate column), because a gate that only says no is a
   blocker, not a tool.
4. **Never fixes.** It blocks and explains.

**That anatomy gets one canonical home, cited — not copied.** `/migrate-check`
originated the shape and keeps it: `skills/migrate-check/references/
gate-shape.md` holds the classification rules and the safe-alternative
convention, and `/contract-check` and `/careful` cite it. This is 4.17
sub-guard 4's settled answer to shared content — *convert duplicates to
citations* — and it is why shape C's merge was unnecessary. Cross-skill
citations resolve because every install symlinks all skill directories
together, and §8's crossref guard verifies each target exists, so drift is
caught rather than trusted. Cost: **zero descriptions**.

**Read-only posture, split as the exit criterion's 2026-08-14 verdict
requires.** 5.1, 5.2, 5.3, 5.5 declare no write-capable tools and enrol in
check.sh §13's `READONLY_SKILLS`; that list currently states its own size
(§33), so enrolling changes the stated number and the guard will catch a
mismatch. **5.4 stays outside by design** — verifying a claim means running
the project's own acceptance commands, which write caches, temp files and
test databases. Its constraint is its own and must be stated in its SKILL.md:
*it never edits the project, the claim, or the acceptance it is auditing.*

**What every new skill owes, from the existing guards** — none of this is new
work invented here, it is what check.sh already enforces:

- `Adjacent skills:` routing line (§7)
- verdict-first line (§10)
- `allowed-tools` declaring only documented-read-only commands for the four
  (§13), and `/verify` explicitly outside with its reason (§13a)
- description ≤600 chars and within the running total (§28)
- the runtime preamble block (§12)
- a fixture + control proving each new detector fires (§11), and a
  guard-matrix case per new guard, **seeded and shown failing before the
  guard is written** — AGENTS.md's rule, and check.sh's own comment orders it
- `count:skills` and `count:matrix-cases` updated in the same commit (§23)

**Five seeded scratch projects.** The wave's exit criterion is *each gate
returns a written verdict against a seeded scratch project*, and every
acceptance in PLAN names its plants. These are fixtures, not shakedown
venues: they live in `fixtures/` and are exercised by `controls.sh`, so the
verdicts are re-checked on every run rather than once at build.

---

## 5.2 `/contract-check` — breaking-change pre-flight

**First, because PLAN calls it "the cheapest build in these three waves — the
template already exists and is shakedown-proven."** Building it first also
establishes the shared gate skeleton the other targets reuse.

**Input:** a diff (`git diff`, a range, or a PR). **Surface examined:**
function signatures, API response shapes, public exports, config keys.

**Classification rules**, each decidable rather than judgment:

| Change | Class | Safe alternative |
|---|---|---|
| Public export renamed or removed | destructive | add the new name, deprecate the old, remove next major |
| Field dropped from a response shape | destructive | add the replacement, mark the old optional, drop next major |
| Signature narrowed (param added without default, type tightened) | destructive | new overload or optional param with the old default |
| Config key renamed or removed | destructive | read both, warn on the old |
| Anything added, optional-by-default | additive | — |

**The failure it exists to prevent, named in PLAN:** *a rename reported as
additive.* The fixture plants exactly that, and the control asserts the
rename is classified destructive — a `/contract-check` that returns GO on the
fixture is the defect.

**Fixture:** `fixtures/contract-check/` — a before/after pair carrying the four
planted changes from PLAN's acceptance plus a clean additions-only twin. The
twin is the must-not-fire control and it can genuinely fail, since a
blanket-NO-GO implementation would pass the first half of the acceptance.

## 5.1 `/deps review` — dependency hygiene

**Input:** the manifest plus the tree. **Checks, in decidability order** —
this order matters, because the report must not present a judgment call with
the same confidence as a fact:

1. **Never imported** — decidable with certainty. Grep every declared package
   for an import/require/use site. PLAN names this *the discriminator*.
2. **Stdlib would do it** — a named list per ecosystem, cited, not guessed.
3. **Unmaintained** — no release in >2 years, read from the registry, with
   the date shown.
4. **License conflict** — declared project license vs each dependency's,
   with both named.

Findings 2–4 carry their evidence inline so a reader can overrule them; only
1 is stated flatly. **Every finding cites the manifest line.**

**Fixture:** `fixtures/deps/` — a manifest with the four planted defects and
a clean twin.

## 5.5 `/deps upgrade` — upgrade pre-flight

Distinct problem, same surface: *upgrading is a breaking-change problem, not
a justification problem.* Reads the changelog between pinned and target,
classifies each entry additive vs breaking **against the call sites this repo
actually has** — a breaking change in an unused API is not a blocker and
saying so is the value — flags transitive bumps, and ends GO/NO-GO with the
rollback pin named.

**Acceptance shape from PLAN:** on a repo pinned to an older major with a
known breaking change, names the change and the affected call sites, and
returns **NO-GO without a migration note**. That last clause is the sharp
one: the gate does not accept "we'll deal with it" as a plan.

**Sequencing:** built after 5.1 so both share one manifest-reading procedure
in `references/`, per 4.49's split rule.

**Built 2026-09-10.** Landed as `## Mode: upgrade` in the skill with the
procedure in `references/upgrade.md`; the split was forced by §29 (review's
43 conditional lines plus a second branch), and the call-site search reuses
review's check 1 by reference rather than through a shared file — 5.1 shipped
its manifest procedure inline, so there was nothing in `references/` to
share. Two facts the design above did not state: the changelog is read
**locally** — an unpacked target tree named as an optional third argument, or
`node_modules/` when the target is already installed — because the read-only
allowlist has no network tool beyond `npm view`, which serves no changelog;
and the fixture's twin shares the seeded changelog byte for byte and differs
only by call sites, so neither a blanket `NO-GO` nor a grep-for-BREAKING gate
can pass the pair. **Fixture:** `fixtures/deps/upgrade/` and
`fixtures/deps/upgrade-clean/`.

## 5.3 `/careful` — GO/NO-GO for destructive operations

**Inherits 4.66's deferral, and inherits its measurements.** The report
**must** state, because 4.66 measured it on ten probe arms:

- `permissions.deny` **survives** `--dangerously-skip-permissions`;
- it is **defeated outright** by `sh -c`, `bash -c` and script files (arm F);
- matching is **prefix-only at token boundaries**, so `Bash(git push --force:*)`
  misses `git push origin main --force` (arms H and I).

A gate that recommends a deny block without those three limits is
recommending a boundary that is actually friction — the overclaim 4.76
already refused to make in README.

**Operations covered:** history rewrites on shared branches, bulk deletes,
production config edits, secret rotation. **Verdict rule:** NO-GO when the
act is unrecoverable, with *the irreversibility named and the recovery path
stated*; GO when a working undo exists, with the undo named.

**This is the CONDUCT rule-5 clause's tool-shaped sibling, not its
duplicate.** The clause (4.77) makes a session stop and confirm; this makes
the analysis explicit and reusable. 4.77's shakedown-18 evidence — control
3/3 performed a force-push destroying a collaborator's only copy, clause arm
0/3 — is the fixture design already validated, and `~/shakedown-18` is a
working rig for the acceptance.

## 5.4 `/verify` — audit a completion claim

**Built last, per PLAN, and only with its stated angle:** the crowded lane is
gating yourself; the genuine gap is auditing a claim made by **someone
else** — another session, another agent, a teammate — against a **running**
system.

**Procedure:** re-derive what the acceptance demands *from the acceptance
text, not from the claim*; run it against the running system; report
**CONFIRMED / OVERSTATED / FALSE** with the command run and the output
observed.

- **FALSE** — the acceptance is not met. Command and output shown.
- **OVERSTATED** — true in part; **names the clause that failed**, which is
  the distinction that makes this skill worth building. Shakedown 18's
  falsification round is the precedent: 2 rows false and 4 overstated, every
  error in the author's favour.
- **CONFIRMED** — met, with the evidence.

**Outside the read-only set, by the exit criterion's verdict.** Its own
constraint, stated in its SKILL.md: *never edits the project, the claim, or
the acceptance it is auditing.* It runs things; that is the point.

**The honest hazard:** a claim whose acceptance is unrunnable — no command,
or one that cannot execute here. That returns neither CONFIRMED nor FALSE but
a fourth outcome, **UNVERIFIABLE**, naming what was missing. PLAN's
acceptance lists three verdicts; this adds the one a real run will hit, and
the addition is flagged here rather than discovered at build.

---

## Build order and commits

Ordered by cheapness and by what unblocks what:

1. **5.2** `/contract-check` — establishes the shared gate anatomy reference.
   `task 5.2: …`
2. **5.1** `/deps review` — establishes the shared manifest procedure.
3. **5.5** `/deps upgrade` — reuses 5.1's procedure.
4. **5.3** `/careful` — cites 5.2's anatomy reference, carries 4.66's limits.
5. **5.4** `/verify` — last, per PLAN, and the only one outside §13.

Each increment: skill + fixture + control + matrix case, counts updated in
the same commit, `scripts/check.sh` clean before it lands.

## Wave verification (the PLAN exit criterion, expanded)

- Each of the five returns a **written verdict** against its seeded fixture,
  and each fixture has a **clean twin** the gate must pass — a blanket-NO-GO
  implementation must fail the suite.
- 5.1, 5.2, 5.3, 5.5 appear in `READONLY_SKILLS`; §33's stated size updated;
  5.4 **absent** from it with its reason written in its SKILL.md.
- §28 total re-measured and recorded in the wave's journal entry, with the
  headroom left for waves 6–7 stated as a number.
- Every new guard shown failing on a seeded defect **before** it is trusted.

## What wave 5 does NOT include (intentional)

- **Widening `/migrate-check`** into the general gate — shape C, rejected
  above. Its structural argument was withdrawn (two skills sharing a report
  shape is not duplication) and its budget argument does not survive the fact
  that no shape avoids the §28 conversation. Keeping the name while adding
  targets was rejected separately: the name would then lie about scope.
- **A `/gate` abstraction.** Nothing in this wave introduces a new grouping
  concept; the three gates are siblings citing one shared anatomy.
- **Raising §28's cap.** If the budget does not fit, the answer is fewer
  descriptions or fewer skills, not a bigger cap; changing it is a 4.59
  decision and undoes what 4.59 was for.
- **Auto-fixing anything.** Every item here blocks and explains.
- **A `/careful` that claims `permissions.deny` is a boundary.** 4.66 arm F
  disproved that, and the report must say so.
