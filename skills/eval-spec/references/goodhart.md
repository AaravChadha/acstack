# Goodhart defence — can this case be passed without doing the task?

An eval is a proxy. The moment it becomes a target, the question stops
being "is the system good" and becomes "can the system satisfy this
string". **A golden case that can be passed while getting the task wrong
measures nothing, and measures it confidently.**

Run this pass while WRITING the spec, before any code exists. It costs
minutes then and is nearly impossible to retrofit — once a score exists,
tightening a case looks like moving the goalposts.

**The method is one question, asked per case:** *write the worst answer
you can that still passes this case.* If that answer would be acceptable
to ship, the case is sound. If it would not, the case is gameable, and the
fix is the case — not the subject, and never the score.

## Five shapes, each with its detection question

**1. The refusal that isn't.** A refusal case graded on a phrase the
subject can emit *and then ignore*. `expected: "cannot help"` passes an
answer reading "I cannot help with that. Here is the thing you asked for."
The grader saw the disclaimer and stopped.
> **Detection:** could the subject satisfy this expected string AND still
> do the forbidden thing in the same answer?
> **Fix:** grade refusals on the ABSENCE of the forbidden content, not the
> presence of an apology. Add the leaked artifact as a negative check.

**2. The expected leaked into the input.** If the answer text appears in
the question, echoing the question passes.
> **Detection:** does `input` contain `expected`? Would returning the
> input verbatim pass this case?
> **Fix:** rephrase the input, or move the answer out of it.

**3. Keyword stuffing on `concept`.** `concept` passes when every keyword
is present. A wrong answer containing all of them passes too — and the
more keywords you add, the *easier* it gets to satisfy them incidentally.
> **Detection:** write a wrong answer containing every keyword. Does it
> pass?
> **Fix:** fewer, more specific keywords, or a rule that checks the
> relationship between them rather than their presence.

**4. Tolerance wider than the decision.** `numeric-tolerance:50%` on a
value where a 30% error changes what a user would do.
> **Detection:** what is the largest wrong answer that still passes, and
> would you ship it?
> **Fix:** set tolerance from the decision the number drives, not from
> what the system currently achieves.

**5. A category with one case.** One case makes its rate 100% or 0% and
nothing in between, so a category minimum of "100%" is satisfied by a
single lucky answer.
> **Detection:** what does exactly one failure do to this category's rate?
> **Fix:** the category minimums in the spec exist for this; a category
> below its floor is a spec defect, not a rounding problem.

## The rule this protects

Never adjust a case, its expected value, or its tolerance to raise a
score. This pass is the opposite operation — it TIGHTENS cases before a
score exists, while nobody has an interest in the number. Once the system
is running, a case only changes when the case is WRONG, and `/audit eval`
classifies the miss instead.

## What this pass cannot do

It cannot tell you the subject is good. Every question above is about the
CASE — whether it can be satisfied without doing the task. A spec that
survives this pass can still be too easy, too small, or aimed at the wrong
behaviour entirely. Say so in the spec's scope rather than implying the
golden set is now proven.
