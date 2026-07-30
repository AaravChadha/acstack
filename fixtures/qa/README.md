# /qa fixture — live-server control (shakedown-run, not per-commit)

This control needs a running process, so it is deliberately NOT in
`scripts/controls.sh`. Run it during the wave shakedown:

```bash
pkill -f 'node server.js' || true   # a held port faked a broken fix in wave 3
node fixtures/qa/server.js &
sleep 1
curl -s -o /dev/null -w '%{http_code}\n' 'http://localhost:8799/health'          # expect 200
curl -s -o /dev/null -w '%{http_code}\n' 'http://localhost:8799/admin'           # 200 here IS the seeded auth gap — /qa must flag it
curl -s -o /dev/null -w '%{http_code}\n' 'http://localhost:8799/items?limit=abc' # connection drop / 5xx — the seeded crash /qa must flag
kill %1
```

Pass condition for the control: /qa's report flags the /admin 200 as an
auth finding and the `limit=abc` crash as an error-hygiene finding, and
passes /health. A /qa run that reports this fixture clean has a broken
check somewhere — that is the point of the fixture.
