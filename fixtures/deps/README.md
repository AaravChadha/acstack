# deps fixture

Seeds the four checks PLAN 5.1's acceptance names, one plant per check, in
`project/`. `clean/` is the must-not-fire twin.

| Plant | Package | Check |
|---|---|---|
| Declared, zero use sites in `src/` | `chalk` | 1 — never imported (**the discriminator**) |
| `Object.assign` does the same job | `object-assign` | 2 — stdlib replacement |
| Last release 2024-04-16, over two years ago | `left-pad` | 3 — unmaintained |
| `GPL-3.0` against the project's declared `MIT` | `fixture-copyleft-lib` | 4 — license conflict |

**Check 1 is the discriminator** because it is the only one decidable with
certainty; the other three are judgment calls carrying evidence. A run that
finds three and misses `chalk` has failed the acceptance regardless of how
good the other three look.

**`left-pad`'s staleness is real and was verified live** (`npm view left-pad
time.modified` → `2024-04-16`) rather than asserted. It will keep aging,
which is the right direction for this plant.

**The license plant is vendored metadata, deliberately.** Pinning a real
package's license into a fixture makes the fixture lie the day that package
relicenses — the same rot as a hardcoded count, which this repo has fixed
three times. `node_modules/fixture-copyleft-lib/package.json` declares
`GPL-3.0` locally, which is also how a real license scan reads it.

**The clean twin declares one dependency that passes all four checks:** `zod`
— imported and used, no stdlib equivalent (schema validation is not a
one-liner), MIT against the project's MIT, and last released days ago.
Verified live rather than assumed: `npm view zod license` → `MIT`,
`time.modified` → 2026-08-15.

**The first twin was defective and a live run caught it.** It declared
`object-assign`, which check 2 correctly flags as an `Object.assign`
ponyfill — so the must-not-fire control **could not pass**, and the run that
reported one finding on it was right. A control the baseline cannot satisfy
proves nothing, which is the same defect class as a must-not-fire case the
baseline already satisfies. Replaced, not argued with.

## upgrade mode (PLAN 5.5)

`upgrade/` seeds the acceptance: a repo pinned to an older major of a
dependency whose next major carries a known breaking change that its call
sites hit, and no migration note. `upgrade-clean/` is the must-pass twin.
Run each from inside its directory, naming the unpacked target tree as the
third argument (the target is not installed here, so it is the procedure's
first source):

```
/deps upgrade fixture-http-client 3.0.0 target/fixture-http-client
```

| Plant | Where | What the gate must do with it |
|---|---|---|
| Pinned `2.4.1`, declared `^2.4.1` | `node_modules/fixture-http-client/package.json`, `package.json` | name `2.4.1` as the rollback pin — the range is not a pin |
| Target `3.0.0` metadata + changelog | `target/fixture-http-client/` | the unpacked target tree, step 1's first source; the changelog is read from here, never fetched |
| Breaking entry **with** call sites — positional `createClient(url, options)` removed | `src/api.js`, `src/reports.js` (**the discriminator**) | destructive, both sites cited `file:line`, so `NO-GO` |
| Breaking entry **without** call sites — `client.request()` removed | nowhere in `src/` | listed, 0 call sites, not a blocker |
| Transitive major bump — `fixture-retry` `^1.2.0` → `^2.0.0` | the two `package.json` files | flagged, not classified: nothing here imports it directly |
| No `UPGRADE.md` / `MIGRATION.md` | — | the `NO-GO` stands — "we'll deal with it" is not a note |

**The twin shares the changelog byte for byte** (the control asserts it)
and differs only in `src/`: its one call site already uses the options-object
form, so the same two BREAKING entries have zero affected sites and the
verdict is `GO`. That is the discriminator a blanket `NO-GO` cannot pass
*and* one a grep-for-BREAKING gate cannot pass either — the whole point of
the mode is classifying against call sites, not against the word.

**The package is fictitious, deliberately.** Attributing an invented
changelog to a real package would be a fabricated record, and pinning a
real package's real history would tie the fixture to the registry. The cost
is stated rather than hidden: `npm view fixture-http-client …` fails here,
so the registry-backed reads (a bare-major target, the metadata fallback)
exercise their **not-run** path in this fixture, not their happy path.
Transitive-bump detection is exercised through the local metadata instead.
