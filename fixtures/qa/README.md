# /qa fixture — live-server control (shakedown-run, not per-commit)

This control needs a running process, so it is deliberately NOT in
`scripts/controls.sh`. Run it during the wave shakedown:

```bash
# Match the path, not just 'server.js': pkill -f substring-matches the FULL
# command line, and 'node server.js' is not a substring of
# 'node fixtures/qa/server.js'. The pattern below was wrong until
# 2026-07-31, so the stale-server guard could never fire — the exact
# failure it exists to prevent (a held port faked a broken fix in wave 3).
pkill -f 'fixtures/qa/server.js' || true
node fixtures/qa/server.js &
sleep 1
curl -s -o /dev/null -w '%{http_code}\n' 'http://localhost:8799/health'   # expect 200
curl -s -o /dev/null -w '%{http_code}\n' 'http://localhost:8799/admin'    # 200 here IS the seeded auth gap — /qa must flag it

# LAST, because it kills the server: the limit cast is an UNCAUGHT
# JSON.parse, so the process exits rather than returning an error. curl
# reports http_code=000 and exit 52 (connection reset) — NOT a 5xx.
# An uncaught exception taking down the process is a worse finding than
# a 500, and /qa must report it as such rather than as a bad status code.
curl -s -o /dev/null -w '%{http_code}\n' 'http://localhost:8799/items?limit=abc' || true

pkill -f 'fixtures/qa/server.js' || true   # not `kill %1`: the job is already dead
```

Pass condition for the control: /qa's report flags the /admin 200 as an
auth finding and the `limit=abc` crash as an error-hygiene finding —
naming that the process **died** rather than returned an error — and
passes /health. Probe order is load-bearing, not cosmetic: the crash
probe must come last or everything after it observes a dead server and
/qa reports a cascade of phantom failures. A /qa run that reports this fixture clean has a broken
check somewhere — that is the point of the fixture.
