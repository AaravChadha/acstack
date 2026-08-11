# Mode: cold — orienting in a repo with no doc triad

`/resume`'s default path reads BRIEF / PLAN / JOURNAL. **An unfamiliar
repo has none of them**, and the skill's whole promise — oriented in five
minutes — is exactly what someone opening a stranger's codebase needs.
This mode is that promise without the documents.

**Trigger:** no BRIEF/PLAN/JOURNAL and no legacy equivalent
(PLANNING_PROMPT / PLANNING / STATUS). Say which you looked for and that
none were found, then switch — do not report "no documents" and stop, and
do not silently behave as though the repo were empty.

## The iron rule

**You are reading, not planning.** This mode produces an orientation
brief and nothing else. It does not create documents, propose a roadmap,
or infer what the project *should* do next. A stranger's repo is the
place where a confident invented plan does the most damage: it reads as
knowledge and is a guess.

Where no reason is recorded, say **`no recorded rationale`** — the `/why`
stance, applied to structure. "This is probably for X" is the failure
mode; nobody can tell your inference from a fact once it is written down.

## What to read, in this order

Stop when the brief below can be written. Most repos need the first three.

1. **README and its neighbours** — what it claims to be, how it says to
   run it. Try the quickstart if it is cheap; a broken quickstart is the
   single most useful thing you can report on day one.
2. **The manifest** — `package.json`, `pyproject.toml`, `go.mod`,
   `Cargo.toml`, `Gemfile`. Dependencies name the stack faster than any
   directory tree, and the scripts section names the real entry points.
3. **Layout** — top-level directories only. Where does source live, where
   do tests live, is there a `docs/`. Do not walk the whole tree.
4. **Git history, shaped not listed** — `git log --oneline -30` for what
   is active, `git log --format='%an' | sort | uniq -c | sort -rn | head`
   for who touches it, and the age of the newest commit. A repo whose
   last commit is two years old is a different situation from one touched
   yesterday, and that is the fact a newcomer most needs.
5. **CI config** — `.github/workflows/`, `.gitlab-ci.yml`. What must pass
   is the project's own definition of done, and it is usually the only
   written one.
6. **Config and secrets surface** — `.env.example`, `config/`. Name what
   must be set to run it. Never read a real `.env`.

## The brief — 10 lines or fewer

- **What this is**, one line, from the README — quoted or paraphrased,
  and flagged if the README and the code disagree.
- **Stack and entry point** — how you would actually start it.
- **How it is tested**, and what CI enforces.
- **Where the work is happening** — the directories the last 30 commits
  touch, not the biggest directories.
- **Activity** — newest commit date, contributor count.
- **What you could not determine**, named explicitly.

## What NOT to do

- **Do not scaffold.** No BRIEF, no PLAN, no CLAUDE.md. Offering `/plan
  seed` once is allowed under conduct rule 9 — as an offer, never acted on
  unprompted, never repeated.
- **Do not list "next 3 unblocked tasks".** That is the default mode's
  output and it depends on a plan. Here there is none, and a list of
  invented tasks is precisely the confident guess this mode exists to
  avoid. If the repo has an issue tracker and `gh` works, the open issues
  are a fact you may report; your ideas are not.
- **Do not audit.** Defects you trip over get one line at the end under
  "worth a look", not a report. `/audit code` is the skill for that, and
  conflating them buries the orientation the user asked for.
