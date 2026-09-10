# /deps upgrade — the procedure

> **What this file is.** The upgrade mode's procedure, split out of SKILL.md
> so a `review` invocation does not pay for it (4.49's split rule, §29's
> threshold). Read it when `/deps upgrade <package> <target-version>` is
> invoked. It reuses review's manifest procedure for the call-site search
> and follows the gate anatomy in
> `../../migrate-check/references/gate-shape.md` — cited, not restated.

## 0. Resolve the three versions

| Version | Read from | If it cannot be read |
|---|---|---|
| **Pinned** — the rollback pin | the lockfile's resolved entry for the package, or the `version` in the `package.json` under `node_modules/<pkg>/` — whichever is **below** the target. If both already equal the target (the bump was installed before the gate ran), the pin is what the manifest declared before the bump: take it from the request, or report it unresolved | the manifest range, reported **as a range** with a line saying the pin could not be resolved |
| **Declared** | the manifest line (`package.json`, `pyproject.toml`, `go.mod`, …) — cite it | — |
| **Target** | the argument. A bare major (`4`) means the highest published `4.x` per `npm view <pkg> versions` | registry unreachable: say so; the target is then exactly what was typed |

The report's second line states all three and where each came from.

## 1. Read the target's metadata and changelog

Source precedence — the first that exists wins, and the report names it:

1. the optional third argument — an unpacked target package (what
   `npm pack <pkg>@<target>` unpacks to) holding `package.json` and a
   changelog;
2. `node_modules/<pkg>/` when its `package.json` `version` equals the target
   (the target is already installed, e.g. in a scratch tree);
3. `npm view <pkg>@<target> dependencies peerDependencies engines` — a
   registry read of metadata only. **The registry serves no changelog**, and
   this skill's allowlist has no network tool beyond `npm view`, so a
   changelog is never fetched.

The changelog is the file that names the breaking changes: `CHANGELOG.md`,
`HISTORY.md`, `CHANGES.md` or `RELEASES.md` in the target tree, read for the
headings above the pinned version (exclusive) up to the target (inclusive).
**If no changelog is readable, say so, record one destructive row whose fact
is missing, and return `NO-GO` naming the fact** and the cheapest way to
supply it (install the target in a scratch tree, or name the changelog's
path in the request). Gate-shape §2: an unknown is classified destructive
until told otherwise, never optimistically.

## 2. Find the call sites

Review's check 1 procedure, pointed at one package: search the source —
not the lockfile, not the manifest, not `node_modules` — for every import
or require of `<pkg>`, then for every use of the API each breaking entry
names. Cite `file:line`. Distinguish forms when the entry does: an entry
removing *the positional form* affects a site that passes a string first,
and does not affect one that passes an object. When an entry names an API
and no site uses it, say so with the search you ran.

## 3. Classify every changelog entry

One row per entry between pinned and target, nothing omitted — a report
listing only the problems cannot be checked for completeness (gate-shape
§2). Destructive means *some existing caller here breaks*, which is
gate-shape's own definition:

| Entry | Class | The row's note |
|---|---|---|
| breaking, with at least one affected call site | **destructive** | the sites, `file:line` each |
| breaking, with zero affected call sites | **additive** in effect | "breaking upstream, 0 call sites here — not a blocker" |
| breaking, affected sites unknown — dynamic access, a re-export, a fact you lack | **destructive** | the fact that is missing |
| additive, deprecation, fix | **additive** | — |

## 4. Flag transitive bumps

Diff `dependencies`, `peerDependencies` and `engines` between the pinned
and target metadata (step 1's source, or `npm view <pkg>@<version>` for
each side). List every changed range. A transitive **major** bump is
flagged, not classified: it becomes a row of its own — destructive until its
changelog is read — only when this repo imports that transitive package
directly. An `engines` change that excludes the runtime this repo declares
is destructive.

## 5. A safe alternative per destructive row

The cheapest way to the same outcome without the break, one per row:

- **the migration** — the replacement form at each affected site, which is
  exactly what a migration note would contain;
- **stay** — the highest published version below the breaking one (`npm view
  <pkg> versions`), named exactly;
- **an adapter** — a shim keeping the old call shape, where the entry allows.

"There is no non-breaking way to take this" is a legitimate cell. A blank
cell is not.

## 6. Verdict

Literally the first line of the report: `**NO-GO**` or `**GO**`, then the
evidence (gate-shape §1). `NO-GO` when any destructive row lacks a migration
note naming each affected site and its replacement. The note may live in the
request, in a repo file (`UPGRADE.md`, `MIGRATION.md`, a changeset entry),
or in a PR description; "we'll deal with it" is not a note. `GO` means "no
destructive row without a migration path", never "this upgrade is safe" —
say so when the distinction could mislead.

## Report

1. The verdict line.
2. Pinned / declared / target, each with its source (step 0).
3. The classification table — every entry, including the additive ones.
4. Transitive bumps, each with old range → new range, and whether this repo
   imports the package directly.
5. **Rollback pin:** the exact installed version and the manifest line that
   restores it.
6. **Not checked:** registry lookups that failed, versions the changelog
   skips between pinned and target, ecosystems other than npm (the registry
   reads in steps 0, 1 and 4 are npm-only today, so elsewhere they are
   reported as not-run), and callers outside this repo.

## Hard rules

- Never runs an install or an update, never edits the manifest or lockfile.
- A registry lookup that failed is reported as not-run; a changelog that
  could not be read is a `NO-GO` naming the fact — neither is a pass.
- Every destructive row cites `file:line` and carries an alternative.
