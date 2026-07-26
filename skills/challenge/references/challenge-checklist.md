# Challenge checklist — reality checks and forcing questions

## The three reality checks

### Cost / tier ceiling

Answer with arithmetic, not adjectives:

- What are the hard numeric limits of every free/cheap tier the BRIEF
  depends on (API requests/day, tokens/minute, rows, storage, seats,
  build minutes)?
- At the BRIEF's own usage estimate, which limit is hit first, and after
  how many users/days?
- What does the first paid tier cost, and does the Context's budget line
  absorb it?
- Is there a per-unit cost (per query, per document, per user) that scales
  with success? Success-triggered cost cliffs are the ones that hurt.

### Hours reality

- Sum the plan-shaped work the BRIEF implies (build + eval + deploy +
  the unglamorous 30%: auth, error states, data cleanup).
- Divide by the hours/week the Context actually claims. State the result
  in calendar weeks, next to any deadline the BRIEF names.
- Name the single most expensive item and ask whether it's in the wedge
  or droppable.

### Blast radius

- Who exactly touches this in week one, and what do they lose if it's
  wrong or down — time, money, trust, data?
- Is week-one failure recoverable by apology, or does it burn the pilot
  relationship the BRIEF depends on?
- Does any failure mode touch data the user can't restore? If yes, that's
  a BRIEF-level non-negotiable, not an implementation detail.

## Forcing-question bank — pick what fits the project type

**Any project**
1. What observable event tells you this worked — by when?
2. What's the cheapest experiment that could kill the idea this week?
3. If you could only ship one screen/command/endpoint, which one?

**Data / analysis products**
4. Who owns the source data, and what breaks when its format changes
   without notice?
5. What's the freshness requirement — and what does the answer cost?
6. When the data is wrong, who notices first: you or the user?

**LLM features**
7. What does "good enough" mean as a number, measured how? (If unanswered,
   the verdict cannot be `proceed` — point at /eval-spec.)
8. What happens on a confident wrong answer — who catches it before it
   costs something?
9. Which inputs must the system REFUSE rather than attempt?

**Consumer / multi-user apps**
10. Why does the second user show up? The tenth?
11. What's the empty-state experience before any data exists?

**Internal / pilot tools**
12. Who is the one named person whose week this improves, and have they
    said so?
13. What does the pilot user do today without it — and is that actually
    worse?

## Using the bank

Pick 4–7 questions that fit; renumber them in the report. Skip the ones
the BRIEF already answers — asking answered questions signals the brief
wasn't read, and the whole point of this skill is that it was.
