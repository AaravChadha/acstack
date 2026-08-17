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
