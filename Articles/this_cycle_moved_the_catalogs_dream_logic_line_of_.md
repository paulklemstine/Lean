# The Logic of Dreams: How to Reason Soundly Inside a Contradiction

## A thought that should not survive

Imagine you believe two things at once: that the door is locked, and that the door
is *not* locked. In ordinary, classical logic this is a catastrophe — and not a
metaphorical one. There is a famous, airtight argument, known since the Middle Ages
as *ex contradictione quodlibet* ("from a contradiction, anything follows"), that
turns a single contradiction into a proof of *literally everything*. Once you accept
"the door is locked" and "the door is not locked," classical logic will cheerfully
sell you "the moon is made of cheese" and "you are the King of France" with the same
confidence.

The argument is short and feels unstoppable:

1. The door is locked. (premise)
2. The door is not locked. (premise)
3. Therefore: the door is locked **or** the moon is cheese. (from 1, weakening a
   true statement into a longer "or")
4. But the door is *not* locked (line 2), so the first half of that "or" is dead.
5. Therefore the surviving half must be true: the moon is cheese.

That last move — "an *or* is true, one side is false, so the other side holds" — is
called **disjunctive syllogism**, and it is the secret detonator. Feed it a
contradiction and it explodes your entire system into triviality, where every
sentence is provable and nothing means anything.

For most of the twentieth century, logicians treated this explosion as the price of
doing business. But a stubborn minority asked a different question: *what if we could
build a logic that absorbs a contradiction the way a dream absorbs an impossibility —
without the whole world dissolving?*

This is the story of one such logic, the **Logic of Paradox**, and of an effort to
map, with mathematical exactness, *which laws of reasoning survive inside it and which
ones die.* The answer is beautifully clean, and can be summed up in a single slogan we
will earn over the course of this article:

> **Structural rules survive. Connective elimination rules die.**

## A third truth value

The trick that tames explosion is older and stranger than it sounds: add a third
truth value.

Classical logic gives every statement exactly one of two labels: **true** or
**false**. The Logic of Paradox, due to the philosopher Graham Priest, adds a third,
which we write **bb** and read as *"both"* — both true and false at once. Think of it
as the truth value of the locked-and-unlocked dream door, of the Liar paradox ("this
sentence is false"), or of an inconsistent database told two incompatible things that
refuses to crash.

So we have three values, and they come in a natural order of "increasing truthiness":

```
ff   <   bb   <   tt
false   both   true
```

Here **ff** is plain false, **tt** is plain true, and **bb** sits in the middle: it
is *partly* true, enough to count, but tangled up with falsehood. The two values
that count as "true enough to assert" — **bb** and **tt** — are called the
**designated** values. A statement is *accepted* in this logic exactly when its
value is designated, i.e. when it is at least **bb**. A contradiction's home is
**bb**: it is asserted (designated) and yet not cleanly, purely true.

Now we define the connectives, and here is where the magic hides:

- **Negation** flips **tt** and **ff** as usual — but it *fixes* **bb**. The
  negation of "both true and false" is again "both true and false." In symbols,
  `neg tt = ff`, `neg ff = tt`, and crucially `neg bb = bb`. A glut is its own
  mirror image.
- **And** (conjunction) takes the *minimum* of the two values in our order:
  `conj a b = min(a, b)`. An "and" is only as true as its weakest part.
- **Or** (disjunction) takes the *maximum*: `disj a b = max(a, b)`. An "or" is as
  true as its strongest part.

That single fixed point — `neg bb = bb` — is the whole ballgame. It is why the dream
door can be locked and unlocked at the same time without tearing reality apart, and,
as we will see, it is simultaneously the reason two cherished classical laws survive
and the reason two others perish.

## Watching explosion fail

Let us replay the moon-is-cheese argument, but now in the Logic of Paradox, with the
door assigned the glut value **bb**.

Let `p` mean "the door is locked," and give it the value **bb**: locked and
unlocked at once. Let `q` be the wild conclusion, "the moon is cheese," and give it
the value **ff**: plainly false.

- Is `p` accepted? Its value is **bb**, which is designated. Yes.
- Is `¬p` accepted? `neg bb = bb`, designated. Yes — the contradiction is fully on
  the table.
- Is the "or" `¬p ∨ q` accepted? It is `max(bb, ff) = bb`, designated. Yes.
- Is `q` accepted? Its value is **ff**, *not* designated. **No.**

So here is a world in which both `p` and `¬p ∨ q` hold, yet `q` does **not**. The
inference "from `p` and `¬p ∨ q`, conclude `q`" — disjunctive syllogism — has a
counterexample. It is not a valid law of this logic. The detonator has been
defused. You can believe a contradiction about the door without being forced to
conclude anything about the moon.

In the formal development this is the theorem named, plainly,
**`disjunctive_syllogism_fails`**: the premise set `{p, ¬p ∨ q}` does *not* entail
`q`. Its twin, **`mp_fails`**, says the same thing in the closely related dress of
*modus ponens* ("from `p` and `if p then q`, conclude `q`"), since "if p then q" is
just "¬p or q" in disguise. In the Logic of Paradox, the two most automatic moves
in all of reasoning are simply not available.

This is unsettling. If modus ponens fails, what is *left*? The surprising answer is:
an enormous, well-organized chunk of logic survives completely intact. To see exactly
which chunk, we need to separate two very different *kinds* of rule.

## Two species of rule

Logical rules come in two families, and the central discovery here is that
paraconsistency treats them in opposite ways.

The first family is the **structural rules**. These are not about *and*, *or*, or
*not* at all. They are about the bookkeeping of argument itself — how premises and
conclusions relate, regardless of their internal grammar. Three are fundamental:

- **Reflexivity:** if `A` is one of your premises, then `A` is a consequence. You
  are allowed to conclude what you already assumed.
- **Monotonicity (also called weakening):** if `A` follows from some premises, it
  still follows after you *add* more premises. Extra information never destroys a
  conclusion you already had.
- **Cut (transitivity of reasoning):** if `A` follows from your premises, and `B`
  follows once you add `A`, then `B` already followed from the original premises.
  Lemmas are legitimate; you can chain arguments together.

Together, these three say that "consequence" behaves like a sensible *closure
operation*: a tidy, composable notion of "what follows from what." This package is
called a **Tarskian closure operator**, after Alfred Tarski, who isolated exactly
these axioms as the skeleton of any respectable consequence relation.

The second family is the **connective rules**, which *are* about the meaning of
*and*, *or*, and *not*. These split further into two sub-species:

- **Introduction rules** *build* a connective. For example, **adjunction**: from `A`
  and `B` separately, conclude `A ∧ B`. Or **addition**: from `A`, conclude
  `A ∨ B` (an "or" is true if either side is). These rules take true things and
  package them up.
- **Elimination rules** *take a connective apart* to draw a sharper conclusion.
  Disjunctive syllogism is the eliminative rule for "or": it uses an "or" plus the
  falsity of one side to extract the other. Modus ponens is the eliminative rule for
  "if-then."

With this vocabulary, the headline result of this work can finally be stated in its
full, crisp form:

> In the Logic of Paradox, **all three structural rules survive, and so do the
> connective introduction rules — but the connective elimination rules fail.**

## Why the structure survives

Here is the lovely part: the structural rules survive for reasons that have *nothing
to do with three-valuedness*. They are too abstract to care.

Start with how "consequence" is defined. We say a premise set `Γ` **entails** `A`
when *every model of `Γ` also makes `A` accepted* — where a "model" is any
assignment of truth values to atoms that makes everything in `Γ` come out
designated. Consequence quantifies over all the worlds consistent with your
premises.

Now watch the structural rules fall out almost for free:

- **Reflexivity** holds because if `A` is *in* `Γ`, then by definition every model
  of `Γ` already accepts `A`. Nothing to prove; it's baked in.
- **Monotonicity** holds because a model of a *larger* premise set is automatically
  a model of any *smaller* one inside it. Shrinking your demands can only add
  models, never remove the conclusion. (Formally, `entails_monotone`: if `Γ ⊆ Δ`
  and `Γ` entails `A`, then `Δ` entails `A`.)
- **Cut** holds because if every model of `Γ` accepts `A`, then every model of `Γ`
  is *also* a model of "`Γ` together with `A`," so any conclusion `B` valid there
  is valid here too. (Formally, `entails_cut`: from `Γ ⊢ A` and `Γ, A ⊢ B` conclude
  `Γ ⊢ B`.)

Not one of these arguments ever opened up the meaning of *and*, *or*, or *not* — they
manipulate only the quantifier "for every model," which is precisely why they are
immune to the glut. **Paraconsistency is a property of the connectives, not of the
plumbing.**

## Why the introductions survive but the eliminations die

The connective rules are a different matter, and here the third truth value finally
makes itself felt — in *both* directions.

Consider **adjunction** (build an "and"). Suppose `A` is accepted and `B` is
accepted; is `A ∧ B`? Recall that "and" is the *minimum* in the order
`ff < bb < tt`, and that "accepted" means "at least **bb**." If both `A` and `B` sit
at **bb** or above, their minimum sits at **bb** or above too. Accepted-ness is
closed under taking minimums. The introduction goes through. This is captured by a
tiny but pivotal value-level lemma called **`desig_conj`**: *the minimum of two
designated values is designated.* From it, adjunction follows in one line
(`entails_and_intro`).

The same story tells itself for **addition** (build an "or"). "Or" is the *maximum*,
and a maximum is at least as large as either input, so if `A` is accepted then
`A ∨ B` is accepted no matter what `B` is. The value-level lemma here is
**`desig_disj_left`**: *the maximum of a designated value with anything is
designated.* Addition follows immediately (`entails_or_intro_left`).

So the introductions live because **acceptance is preserved by `min` and `max`** —
a pure monotonicity fact about the order on truth values.

Now the elimination rules. Why does disjunctive syllogism die where adjunction
thrives? The classical justification of "from `A ∨ B` and `¬A`, conclude `B`"
silently assumes something deeper than monotonicity: it assumes that a statement and
its negation cannot *both* be acceptable — that if `¬A` is accepted, then `A` is
firmly ruled out, so the live part of the "or" must be `B`. In two-valued logic this
is guaranteed: exactly one of `A`, `¬A` is true.

But the glut **bb** breaks that guarantee. Because `neg bb = bb`, a statement at
value **bb** and its negation are *both* accepted simultaneously. There is no
"disjointness" between a value and its negation. So when you know `¬A` is accepted,
you have learned *nothing* that forces `A` to be unacceptable — `A` might be a glut,
accepted right alongside its own negation. The elimination has had its legs cut out
from under it. The very fixed point `neg bb = bb` that lets the door be locked and
unlocked is *exactly* the fact that invalidates disjunctive syllogism.

One value, **bb**, thus explains the whole picture at once. It is why the classical
laws of *excluded middle* (`A ∨ ¬A` is always accepted) and *non-contradiction*
(`¬(A ∧ ¬A)` is always accepted) remain valid — those are introduction-flavored and
only need `max`/`min` monotonicity. And it is why disjunctive syllogism and modus
ponens fail — those are elimination-flavored and need a disjointness that the glut
denies. The survivors and the casualties are two faces of a single coin.

## Recapturing what we lost — but only when it's safe

A logic that *never* lets you do modus ponens would be crippling. Most of the time
our beliefs are perfectly consistent, and we *want* the powerful classical
inferences. The Logic of Paradox is wise enough to suspend them only when a genuine
contradiction is in play — but can we make it *automatically* switch the classical
rules back on whenever no contradiction is actually forced?

We can, with a refinement that gives this whole research line its evocative name:
**dream logic**. The idea is to be *stingy with gluts.* When you evaluate what your
premises commit you to, don't survey *all* models — survey only the **most
parsimonious** ones, the models that introduce a glut **only where the premises
genuinely force one.** Formally, attach to each model its *glut set* (the atoms it
sends to **bb**), and keep only the **minimal-glut models** — those whose glut set
cannot be shrunk any further while still satisfying the premises. Consequence
restricted to these thrifty models is written `entailsMin`, and the resulting
system is nicknamed **LPm**.

Now replay modus ponens on a *consistent* set of premises: `p`, and "if `p` then
`q`." Are we forced to accept any glut here? No — there is a perfectly classical
model in which everything is plainly true and nothing is a glut. The thrifty,
minimal-glut models therefore carry *no gluts at all*; they are ordinary two-valued
worlds. And in a two-valued world, modus ponens works fine. So `q` follows after
all. This is the theorem **`entailsMin_recovers_mp`**: on the consistent premises
`{p, p ⊃ q}`, the dream logic LPm *recovers* the conclusion `q` that the cautious LP
threw away.

This is the heart of the "dream logic" slogan: **reason classically when you can,
paraconsistently only when you must.** When your beliefs are coherent, you get the
full strength of ordinary logic back automatically; the contradiction-tolerance kicks
in only in the precise corner where a contradiction is unavoidable.

There is a price, and it is illuminating. The thrifty relation LPm is **not
monotone**: adding a premise can *retract* a conclusion, because the new premise can
*force* a glut that the old minimal models avoided, shifting which models count as
minimal (recorded as `retraction_nonmonotone`). So LPm trades one structural rule —
monotonicity — for the power to recover classical inference. The cautious LP keeps all
the structure; the bold LPm keeps more classical conclusions. Neither dominates, and
that tension locates *exactly* which structural rule you must spend to buy back
classical strength.

## The deepest cut: gluts add nothing

We close with the most striking theorem of all, which answers a natural worry. We've
seen that the Logic of Paradox *loses* inferences compared to classical logic. Does
it *gain* anything in return — does it prove new "always true" theorems that
classical logic doesn't?

A formula is **LP-valid** if it comes out accepted in *every* assignment, including
all the glut-laden ones. It is **classically valid** if it comes out true in every
ordinary two-valued assignment. Since the classical assignments are a *subset* of
all assignments (the glut-free ones), anything LP-valid is automatically classically
valid — that direction is easy and is recorded as `LPvalid_imp_classicallyValid`.

The hard and beautiful direction is the converse, and it holds:

> **Priest's characterization.** A formula is LP-valid **if and only if** it is
> classically valid. The glut world and the classical world certify *exactly the
> same tautologies.*

Why is the converse subtle? You might hope to "squeeze" any glut by nudging every
**bb** up to **tt** and check the formula still comes out accepted. But negation is
*antitone* — it flips the order — so squeezing in one direction for an "and" goes the
wrong way once a "not" wraps around it. The naive squeeze fails on exactly the
negation case. The fix is an asymmetric maneuver called the **Collapsing Lemma**: a
*single* collapse sending every glut **bb** up to **tt** is shown to preserve every
classical output of the evaluation simultaneously — even through negations and
through both branches of a binary connective. With that one structural induction, the
converse falls.

The moral is quietly profound. Gluts **subtract inferences but add no theorems.**
The Logic of Paradox is, in the precise sense of validity, *conservative* over
classical logic: it never asserts a new universal truth, it only refuses certain
demolitions — the same skyline of tautologies, viewed from a world that has simply
decided not to detonate when it meets a contradiction.

## What it all means

Step back and the architecture is remarkably humane. The plumbing of reasoning — that
premises yield conclusions, that lemmas chain, that adding facts doesn't break old
inferences — survives even a logic built to swallow contradictions. What
paraconsistency surgically removes is exactly, and only, the explosive move that lets
a single inconsistency metastasize into universal nonsense. And when no inconsistency
is actually present, the thrifty "dream" refinement quietly hands the classical power
back.

This matters beyond philosophy. Real reasoning systems — inconsistent databases,
conflicting sensor readings, legal codes with contradictory clauses, knowledge bases
scraped from a messy world — routinely contain contradictions they cannot afford to
"explode" over. A logic that localizes a contradiction, reasons soundly around it, and
snaps back to classical strength wherever the data is clean is an engineering ideal.
The Logic of Paradox, and its dreaming refinement, show that such a logic is not only
possible but *structurally beautiful*: a precise inventory of what you keep, what you
lose, and exactly what it costs to get it back.

The dream door can be locked and unlocked at once. The world does not end. And, it
turns out, almost all of logic comes along for the dream.
