# PLAN — internal tools (SEEDED FIXTURE for /triage clustering, task 4.32)

The NEGATIVE case, and the more important half of the fixture. Six open
tasks with **no shared root cause** — different subsystems, different
mechanisms, different fixes. A correct clustering pass proposes **nothing**
here and says so.

This exists because a clustering step that always finds clusters is
astrology. Any grouping produced from this file is a false positive, and
the only way to produce one is to widen a "cause" until it stops explaining
anything ("all six touch the codebase").

Do NOT add a shared cause to these; scripts/controls.sh asserts the shape.

## [ ] Wave 1 — Housekeeping

- [ ] **1.1** Add a keyboard shortcut for the command palette.
  **Acceptance:** `Cmd+K` opens it from any screen.
- [ ] **1.2** The build fails on Node 22 because a dev dependency uses a
  removed API. **Acceptance:** `npm run build` passes on Node 22.
- [ ] **1.3** Onboarding docs still reference the retired staging URL.
  **Acceptance:** no occurrence of the old host in `docs/`.
- [ ] **1.4** Rate-limit the password-reset endpoint.
  **Acceptance:** the eleventh request in a minute returns 429.
- [ ] **1.5** Dark mode misses the settings sidebar.
  **Acceptance:** the sidebar honours the theme token in both themes.
- [ ] **1.6** Postgres connection pool exhausts under the nightly import.
  **Acceptance:** the import completes without a pool-timeout error.

<!--
FIXTURE ANSWER KEY: there is no cluster here. A shortcut, a Node version
bump, a stale doc, a missing rate limit, a theming gap and a pool-sizing
problem share nothing but the repository they live in. The correct output
is "no root-cause groups found", which is a real result rather than a
failed sweep.
-->
