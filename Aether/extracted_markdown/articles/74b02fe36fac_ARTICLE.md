# A Logic Where Contradictions Live — And the World Doesn't End

## A thought that should destroy everything

Suppose I tell you two things at once: "It is raining" and "It is not raining."

In the logic you were taught in school, this is a catastrophe. Not because the
weather is confusing, but because of a single, ruthless rule that classical logic
enforces without mercy. The rule is called *explosion*, and in Latin it carries the
swagger of a medieval slogan: **ex contradictione quodlibet** — "from a
contradiction, anything follows."

Here is how the disaster unfolds. If you accept "It is raining," then you must also
accept the weaker claim "It is raining, OR the moon is made of cheese" — after all,
the first half is true, so the whole *or* is true. But you also accepted "It is not
raining." And "It is raining or the moon is cheese," combined with "it is not
raining," leaves only one survivor: the moon is made of cheese. By the same trick I
can prove that you owe me a billion dollars, that 2 + 2 = 5, and that this sentence
is written in ancient Sumerian. One contradiction, and *every* statement becomes
provable. The logical universe collapses into a single grey point where everything
is true and nothing means anything.

This is not a quirk. It is a theorem. And it means classical logic is *brittle*: a
single inconsistency anywhere in your knowledge — one bad sensor reading, one
clashing database entry, one paradoxical sentence — and the whole structure is, in
principle, worthless.

For most of the twentieth century this was treated as simply the price of doing
business. But a stubborn minority of logicians asked a heretical question: what if
we could build a logic that *tolerates* contradiction — one where "it is raining and
it is not raining" can be true without the moon turning to cheese?

This article is about one such logic, the **Logic of Paradox** (LP), and about a
recent piece of work that rebuilds it from the absolute ground up and proves, with
complete rigor, exactly *why* it survives contradictions where classical logic dies.
The surprise at the heart of the story is that the structural skeleton holding the
logic together turns out to have almost nothing to do with paradox at all.

## The third value

The fix, first proposed by the philosopher Graham Priest, is disarmingly simple. In
classical logic a statement has one of two values: **true** or **false**. LP adds a
third: a statement can be **both**.

Call the three values:

- **tt** — true *only*,
- **ff** — false *only*,
- **bb** — *both* true and false at once. Logicians call this a "glut."

Picture them on a vertical ladder of truthfulness, with falsehood at the bottom and
truth at the top:

```
        tt   (true only)      ← top
        bb   (both)           ← middle
        ff   (false only)     ← bottom
```

Now we need to say how the connectives — *not*, *and*, *or* — behave on these three
values. The recipes are exactly what you'd guess from the ladder:

- **AND** takes the *lower* of its two inputs (the more pessimistic one). "Rain AND
  sunshine" is only as true as its weakest part.
- **OR** takes the *higher* of its two inputs (the more optimistic one). "Rain OR
  sunshine" is as true as its strongest part.
- **NOT** flips the ladder top-to-bottom: it turns *tt* into *ff* and *ff* into *tt*.

And here is the linchpin, the single most important fact in the whole theory. What
does NOT do to the glut?

> **NOT(both) = both.**

The middle rung maps to itself. A statement that is both true and false has a
negation that is *also* both true and false. The glut is a *fixed point* of
negation. Hold onto this; everything pivots on it.

Finally we need to know which values count as "asserted" — which ones we are willing
to *accept*. The natural answer: a statement is acceptable if it is **at least partly
true**. So *tt* counts (it's true), and *bb* counts (it's partly true), but *ff* does
not. Logicians call the acceptable values **designated**.

That's the entire engine. Three values, three connectives that are just *min*, *max*,
and *flip*, and one designation rule. From here, everything else is a consequence.

## The model that believes everything

Let's now do something that is flatly impossible in classical logic.

Consider the world in which *every single atomic statement* is set to the glut value
*bb*. Everything is both true and false. Call it the **absolute glut**.

What is the value of *any* formula in this world? Take "rain AND snow": both inputs
are *bb*, AND takes the minimum, and the minimum of *bb* and *bb* is *bb*. Take "rain
OR snow": maximum of *bb* and *bb* is again *bb*. Take "NOT rain": negation of *bb*
is *bb*. No matter how you nest *and*, *or*, and *not*, you can never escape the
middle rung. Every formula, however baroque, evaluates to *bb*.

This is a precise, provable theorem — call it the **glut fixpoint**:

> In the world where every atom is "both," *every* formula evaluates to "both."

And since *bb* is designated — it's partly true — this single world **accepts every
formula simultaneously**. There is one model that says yes to everything.

Read that again, because in classical logic it is unthinkable. There, no model can
accept both "rain" and "not rain," let alone *every* sentence at once. In LP, such a
model exists, sits in plain sight, and is the simplest valuation imaginable: the
constant function that returns *bb*.

The immediate payoff is **paraconsistency** in its purest form. Take any statement
*A* and its negation *not-A*. Is the pair {*A*, *not-A*} satisfiable — can some world
accept both? Yes: the absolute glut accepts both, because it accepts *everything*. So
contradictions are *satisfiable*. The premise that detonates classical logic is, in
LP, just another Tuesday.

## Why the moon stays rock

Satisfiability is half the battle. The real prize is showing that explosion
genuinely *fails* — that from "*p* and not-*p*" you cannot derive an arbitrary
unrelated *q*.

For this we don't even need the absolute glut; we need a sharper, more surgical
world. Set the atom *p* to *bb* (both) and the atom *q* to *ff* (false only). Now
check the premises and the conclusion:

- *p* has value *bb* — designated. ✓ The first premise is accepted.
- *not-p* has value NOT(*bb*) = *bb* — designated. ✓ The second premise is accepted.
- *q* has value *ff* — **not** designated. ✗ The conclusion is rejected.

We have found a world that accepts both *p* and *not-p* but rejects *q*. That is a
*counterexample* to explosion. The inference "from *p* and not-*p*, conclude *q*" is
therefore **invalid** in LP. The contradiction stays quarantined; the moon stays
rock. Logicians give the surviving slogan a defiant name: **ex contradictione non
quodlibet** — "from a contradiction, *not* anything follows."

## The most beautiful part: the laws still hold

Here is where a lazy critic pounces. "You've gutted logic," they say. "Sure, you
avoid explosion — but only by throwing away the cherished laws of thought. Surely in
your mushy three-valued world the Law of Excluded Middle (everything is true or
false) and the Law of Non-Contradiction (nothing is both true and false) are
casualties."

They are not. This is the subtle, gorgeous heart of LP.

Take the **Law of Excluded Middle**: "*A* or not-*A*." Is it valid — designated in
*every* world? Run the three cases for *A*:

- If *A* is *tt*: "*A* or not-*A*" is *tt* OR *ff* = *tt*. Designated. ✓
- If *A* is *ff*: it's *ff* OR *tt* = *tt*. Designated. ✓
- If *A* is *bb*: it's *bb* OR *bb* = *bb*. Designated (partly true). ✓

In all three worlds, "*A* or not-*A*" is accepted. **Excluded middle is LP-valid.**

Now the **Law of Non-Contradiction**: "not(*A* and not-*A*)." The same three cases
give *tt*, *tt*, and — in the glut case — *bb* again, which is designated. So
**non-contradiction is also LP-valid.**

Stop and savor the apparent paradox. LP has a world (the absolute glut) that accepts
*every* contradiction *A*-and-not-*A*. And yet LP also certifies, as a universal law,
that "it is not the case that *A* and not-*A*." How can both be true?

Because LP draws a razor-sharp line between two ideas that classical logic conflates:

- **Validity** — being designated in *every* world. The Law of Non-Contradiction has
  this. It is never *rejected*.
- **Unsatisfiability** — being rejected in *some* world. A contradiction *lacks*
  this; it is sometimes accepted (in the glut world).

In classical logic, "valid law" and "its negation is unsatisfiable" are the same
coin. In LP they come apart. The Law of Non-Contradiction is always *at least partly
true* — but in the glut world it is *also* partly false, exactly as a contradiction
should be. The law holds; triviality does not follow. **Validity is separated from
triviality**, and that separation is the whole reason the logic is both safe and
non-trivial.

## The skeleton beneath the paradox

So far this is a story about three truth values and a magic middle rung. But the
recent work that this article celebrates makes a deeper, more structural discovery,
and it is genuinely unexpected.

A *logic*, in the precise sense pinned down by Tarski and Łoś nearly a century ago,
isn't just a list of which formulas are valid. It is a *machine for drawing
consequences*, and that machine must obey certain housekeeping laws that have nothing
to do with truth tables. The question the new work asks is: which of those laws does
LP obey, and *how much of the three-valued weirdness do you actually need to prove
them?*

The answer is startling: **almost none.**

**Structurality.** The first law a real logic must obey is closure under
*substitution*: if a formula is valid, then so is every formula you get by uniformly
replacing its atoms with other formulas. ("*A* or not-*A*" being valid should
guarantee "(rain and snow) or not(rain and snow)" is valid too.) The proof rests on
a single clean fact — that evaluation *commutes* with substitution: plugging in
formulas and then evaluating gives the same answer as evaluating the plugged-in
pieces first and then assembling. This is a one-line induction over the shape of
formulas. It never inspects a truth value. It never mentions the glut. It would read
*identically* for classical logic, for fuzzy logic, for any logic built on a value
algebra. Structurality, the defining badge of "being a genuine logic," is completely
orthogonal to paraconsistency.

**The closure operator.** Tarski's grand abstraction was to view consequence as an
*operator*: feed it a set of premises Γ, and it returns Cn(Γ), the set of everything
those premises entail. A well-behaved consequence operator must be *reflexive*
(premises follow from themselves), *monotone* (more premises, more conclusions), and
*idempotent* — meaning that closing twice is the same as closing once: **Cn(Cn(Γ)) =
Cn(Γ).** Once you've drawn all the conclusions, drawing conclusions *again* adds
nothing new. LP's consequence relation satisfies all of this. The proof is pure
set-theoretic bookkeeping; again, not a single truth value is harmed in the making.

**Conservative recapture.** There is a refined, *non-monotone* cousin of LP — call
it LPm — that gets cleverer by restricting attention to the "most consistent" worlds
that satisfy your premises, deliberately excluding paranoid worlds like the absolute
glut whenever it can. The hope is that LPm recovers more of classical reasoning. The
new work proves that this refinement is **conservative**: every inference LP already
makes, LPm makes too. Minimizing the models only ever *adds* conclusions; it never
retracts one. LP sits safely inside LPm.

And here the two halves of the story click together into one insight. The single fact
that makes LP paraconsistent — the absolute glut, the world that believes everything
— is *precisely the world that LPm throws away* to recover classical strength. The
glut fixpoint and the recapture mechanism are two faces of one coin. The very thing
that protects you from explosion is the very thing you quarantine when you want
classical sharpness back. You can have safety, or you can have classical power, and
the dial between them is *exactly* how seriously you take the glut.

## Why this matters outside the seminar room

This is not merely a philosopher's curiosity. The moment you build any large,
automated reasoning system — a medical knowledge base, a legal expert system, a
sensor-fusion module on a robot, a sprawling AI knowledge graph — you *will* ingest
contradictory information. Two doctors disagree. Two statutes conflict. Two sensors
report incompatible readings. In a classical engine, a single such clash is a logical
landmine: step on it and, in principle, the system can "prove" anything, including
that the patient is both alive and a teapot.

A paraconsistent engine refuses to detonate. It localizes the contradiction, keeps
reasoning sensibly about everything else, and waits for the conflict to be resolved
rather than letting it poison the whole knowledge base. The mathematics in this
article is the rigorous foundation for that kind of robustness: a precise account of a
consequence relation that *tolerates inconsistency without becoming trivial*, that
still honors the classical laws of thought as valid, and whose structural backbone is
provably independent of the very feature (the glut) that makes it safe.

The deepest lesson is almost a koan. We tend to think that handling paradox must
require a radically alien kind of logic, one that abandons the old rules. The truth is
subtler and more reassuring. The scaffolding of logic — substitution, closure,
consequence — stands untouched. Only one rung of one ladder had to change: the
quiet decision that a statement may be both true and false, and that its negation,
gazing back, says exactly the same thing. From that one fixed point, an entire
consistent theory of inconsistency unfolds — and the world, contradictions and all,
keeps turning.
