# contract-check fixture

Seeds the four change classes PLAN 5.2's acceptance names, plus a clean
twin. `before/` → `after/` is the diff under review; `before/` → `clean/`
is additions-only and must return GO.

The plants, one per class:

| Plant | File | Class |
|---|---|---|
| `formatDuration` renamed to `humanizeDuration` | `api.js` | destructive (rename) |
| `legacy_id` dropped from the user response | `response.py` | destructive (field drop) |
| `parse(text)` gains a **genuinely required** `strict` parameter | `api.js` | destructive (signature narrowed) |

**The required-ness is explicit on purpose.** The first draft added a bare
second parameter, which in JS is *optional* — `strict` is `undefined` and the
old code path runs, so nothing breaks and `additive` is the correct answer. A
live run classified it additive and was right; the plant was wrong. It now
throws when `strict` is omitted, so an existing `parse(text)` caller fails.
| `retry_backoff_ms` added with a default | `config.example.toml` | additive |

**The rename is the discriminator.** In a diff it looks additive — one line
gone, one line added, same body — and reporting it as additive is the single
failure 5.2 exists to prevent.

The clean twin adds an optional config key and a new exported helper, and
touches nothing existing. A blanket-NO-GO implementation passes the first
half of the acceptance and fails here, which is why the twin exists and why
it cannot be satisfied by an empty diff.
