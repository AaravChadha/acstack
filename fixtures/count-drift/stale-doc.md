# Seeded stale-count document (fixture for PLAN 4.48)

INPUT fixture. Every marked count below is deliberately WRONG against the
real repository, so `scripts/count-check.sh` must reject this file. A run
that reports this file clean means the guard stopped comparing.

- The pack ships <!-- count:skills -->99<!-- /count --> skills.
- `scripts/check.sh` runs <!-- count:checks -->4<!-- /count --> checks.
- Wave 4.5 stands at <!-- count:wave45-done -->1<!-- /count --> done.
