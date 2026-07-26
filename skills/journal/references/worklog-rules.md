# Work-log granularity rules

The journal's value is proportional to its specificity. Every rule below is
a Bad:/Good: pair; when an entry reads like the Bad side, rewrite it.

**Open with the before-state and why it was bad — in user terms.**
Bad: "Improved latency."
Good: "A simple lookup totalled ~94s; a user asking a follow-up watched a
spinner for a minute and a half."

**Name the exact thing.**
Bad: "Fixed OCR bugs."
Good: "`_parse_ingredients` `[A-Z]{5,}` header check was case-insensitive
due to a leaked `re.IGNORECASE` flag → scoped via inline `(?i:...)` on
keywords only."

**Parameters, not adjectives.**
Bad: "Kept a reasonable amount of history."
Good: "Last 6 messages (3 Q+A pairs) kept verbatim, each capped at 2000
chars."

**Every non-obvious pick gets a `**Why X and not Y**` block.**
Bad: "Used a 0.50 threshold."
Good: "**Why a 0.50 cosine threshold:** empirical — legitimate matches land
0.55–0.85, unrelated topics drop below 0.40."

**State what did NOT change.**
Anything that might be oversold gets an explicit "What it does NOT change"
list: wall-clock, token spend, eval scores — whatever a reader might wrongly
assume improved.

**Record the roads not taken.**
"Two things we DIDN'T do (intentional):" with the reason each was rejected —
the next person will otherwise re-propose them.

**Before → after numbers on everything.**
`drawdown errors 21 → 0` · `flagged files 60/90 → 8/123` · `RM07 84s → 53s`
· `tool count 6 → 5`. A change without a delta is an anecdote.

**Close with validation, as a delta.**
Bad: "Tests pass."
Good: "Full pytest: **88 passed, 40 skipped** (was 79/40; +9 new, no
regressions)."

**Log incidental and self-indicting discoveries.**
"The `len(TOOLS) == 4` assertion was already stale before this change" is
exactly the sentence that saves the next debugging session. Honesty about
your own misses is what makes the journal trustworthy.

**Deferrals are sequenced, never bare.**
Bad: "Streaming deferred."
Good: "Deferred until a clean post-graft eval baseline exists — don't want
streaming bugs entangled with tool-routing bugs if the eval regresses."

**Cost and scale impact when relevant.**
"+1–3K input tokens per follow-up turn (mostly cached prefix); at 350-user
scale that's the +$50–100/month delta."
