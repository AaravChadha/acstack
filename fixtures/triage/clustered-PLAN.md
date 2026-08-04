# PLAN — checkout service (SEEDED FIXTURE for /triage clustering, task 4.32)

Eight open tasks. **Three underlying causes**, and no two tasks are
duplicates — which is the point: a pairwise duplicate check finds nothing
here. The pass should find three CAUSES — two as proposed parents,
the third as a named pair (see the expected output below).

Do NOT "fix" or reword these; scripts/controls.sh asserts the shape.
The causes are recorded at the bottom so the fixture states its own answer.

## [ ] Wave 1 — Checkout

- [ ] **1.1** Order confirmation email shows the total as `0.00` for
  multi-currency carts. **Acceptance:** a EUR+USD cart emails the true total.
- [ ] **1.2** Refund amounts are off by a few cents on split payments.
  **Acceptance:** a split refund reconciles to the charge exactly.
- [ ] **1.3** The CSV export totals column disagrees with the dashboard.
  **Acceptance:** export and dashboard agree for the same date range.
- [ ] **1.4** Search returns nothing for names typed with a trailing space.
  **Acceptance:** `"alice "` finds the same rows as `"alice"`.
- [ ] **1.5** Coupon codes fail when pasted from the email (they arrive
  with a non-breaking space). **Acceptance:** a pasted code validates.
- [ ] **1.6** Customer names with accents sort after `Z` in the admin list.
  **Acceptance:** `Ångström` sorts with the A's.
- [ ] **1.7** The nightly reconciliation job silently processes zero rows
  when it starts before midnight UTC. **Acceptance:** a 23:50 start covers
  the full day.
- [ ] **1.8** Weekly revenue emails omit the last day of the week.
  **Acceptance:** a Sunday-to-Saturday email includes Saturday.

<!--
FIXTURE ANSWER KEY — the three causes a correct clustering pass should name:

  A. Money is held as a float, so every arithmetic path rounds differently.
     Members: 1.1, 1.2, 1.3
  B. User-supplied text is compared raw, without Unicode normalisation or
     trimming. Members: 1.4, 1.5, 1.6
  C. Date ranges are computed in local time while stored in UTC, so the
     boundary day is dropped. Members: 1.7, 1.8

EXPECTED OUTPUT: two proposed PARENTS (causes A and B, three members each)
plus cause C reported under `Related pairs` — named with its evidence, no
parent proposed, because a parent over two items is more structure than it
earns. C is NOT a duplicate pair: 1.7 and 1.8 have different acceptances and
the duplicate sweep cannot see them, so a pass that drops it silently has
lost a real finding between two sweeps. That gap was found by shakedown 7,
when this fixture demanded "three groups" and the skill's own bar could
only produce two.

Note none of these pairs is a DUPLICATE: fixing 1.1 does not fix 1.3, and
each task has its own acceptance. Only the cause is shared, which is
exactly the finding no pairwise check can produce.
-->
