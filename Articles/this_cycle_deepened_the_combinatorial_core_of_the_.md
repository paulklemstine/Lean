# Many Worlds of Mathematics: The Modal Logic of the Set-Theoretic Multiverse

## A universe that refuses to make up its mind

In 1963, Paul Cohen proved something that unsettled the foundations of
mathematics. He showed that the Continuum Hypothesis — the innocent-sounding claim
that there is no infinity strictly between the counting numbers and the real number
line — can be neither proved nor disproved from the standard axioms of set theory.
Kurt Gödel had already shown it could not be *disproved*; Cohen supplied the missing
half. Together they revealed that our best theory of infinity is silent on one of the
most natural questions we can ask about it.

Cohen's tool for this feat was a technique called **forcing**. Starting from a model
of set theory — think of it as a self-contained mathematical universe — forcing lets
you *build a new, larger universe* in which some previously undecided statement
becomes true. Want the Continuum Hypothesis to hold? Force it. Want it to fail? Force
that instead. Neither universe is more "correct" than the other; both are perfectly
legitimate worlds of mathematics.

This is the picture behind the **set-theoretic multiverse**: instead of one true
universe of sets, imagine a vast branching landscape of them, each reachable from
others by forcing. In this article we take that landscape seriously as a
mathematical object in its own right, and ask a surprisingly fruitful question: *what
is the logic of moving between worlds?*

The answer turns out to be a beautiful piece of **modal logic** — the logic of
possibility and necessity — with three concrete payoffs we will describe: a precise
identification of *which* logic the multiverse obeys, a clean dichotomy between
statements that can flip freely and statements that latch permanently, and a
counting theorem showing that undecidability is not a rare pathology but the
overwhelming norm.

## Possibility and necessity, made precise

Modal logic adds two operators to ordinary logic. We write $\Diamond p$ for "$p$ is
**possible**" and $\Box p$ for "$p$ is **necessary**." In everyday speech these are
vague; in the multiverse they become razor-sharp.

Picture the worlds as points, with an arrow $w \to v$ meaning "$v$ is a forcing
extension of $w$" — you can travel from $w$ to $v$ by forcing. Then, evaluated at a
world $w$:

$$\Box p \text{ holds at } w \iff p \text{ is true in *every* world reachable from } w,$$

$$\Diamond p \text{ holds at } w \iff p \text{ is true in *some* world reachable from } w.$$

So "$p$ is necessary" means *no amount of forcing can escape $p$*, and "$p$ is
possible" means *some forcing achieves $p$*. The Continuum Hypothesis is possible
(force it) and its negation is possible (force that), so neither the hypothesis nor
its negation is necessary. Undecidability, rephrased, is exactly the statement that
$\Diamond p$ and $\Diamond \neg p$ both hold.

## Which logic does the multiverse speak?

Different arrangements of the arrows — the **accessibility relation** — give
different modal logics. A century of work has catalogued exactly which logical
principles correspond to which geometric properties of the arrows. This dictionary,
the theory of *frame correspondences*, is the technical heart of our story, and it is
strikingly clean. Each famous modal axiom is *equivalent* to one simple property of
the accessibility relation:

- **Axiom T**, $\Box p \to p$ ("what is necessary is true"), holds precisely when
  every world can reach itself — the relation is **reflexive**.
- **Axiom 4**, $\Box p \to \Box\Box p$ ("necessity is itself necessary"), holds
  precisely when the relation is **transitive**: reachability composes.
- **Axiom B**, $p \to \Box\Diamond p$, holds precisely when the relation is
  **symmetric**: every arrow can be run backwards.
- **Axiom 5**, $\Diamond p \to \Box\Diamond p$, holds precisely when the relation is
  **euclidean**: any two worlds reachable from a common source can reach each other.
- **Axiom .2**, $\Diamond\Box p \to \Box\Diamond p$ (the *directedness* axiom), holds
  precisely when the relation is **confluent**: any two worlds reached from a common
  source share a further common destination.

The word "precisely" is doing real work here — in every case the axiom and the
frame property are *equivalent*, each implying the other. This is what lets us read
off the logic of the multiverse from the shape of its arrows.

Now, what *is* the shape of the forcing arrows? Here lies the crux. If you model a
generic extension as changing only *finitely much* information, forcing looks
symmetric — you can undo it — and the logic collapses to the maximal system **S5**,
where every axiom above holds. But this hides something. Genuine iterated forcing is
**directed**: you can always amalgamate two extensions into a common larger one, yet
you can *never* force your way back to a smaller ground model. The true order is
directed but **antisymmetric**.

The cleanest model of a directed antisymmetric order is the humble number line
$(\mathbb{N}, \le)$: from any point you can go up (and amalgamate any two futures by
taking their maximum), but never down. Testing the axioms against this order settles
the question decisively:

> **Main separation.** On the directed antisymmetric extension order, axioms **T**,
> **4**, and **.2** all hold, while axioms **B** and **5** both fail. The logic of
> directed forcing is therefore **S4.2** — strictly weaker than **S5**.

The single culprit is **symmetry**. It is the one frame condition that separates the
two logics: assume you can undo forcing and you get S5; face the fact that you cannot,
and you land exactly on S4.2, the system independently identified by Hamkins and Löwe
as the modal logic of forcing. In $(\mathbb{N}, \le)$ symmetry fails ($0 \le 1$ but
not $1 \le 0$), and euclideanness fails with it, while reflexivity, transitivity, and
confluence survive intact.

## Buttons and switches

Once we know the multiverse obeys S4.2, a lovely classification of *statements*
emerges. Hamkins coined two vivid names.

A **switch** is a statement you can toggle freely: from every world, both the
statement and its negation remain achievable by further forcing. The Continuum
Hypothesis is the archetypal switch — no matter where you stand, you can force it on
or force it off.

A **button** is a statement you can *press but never un-press*: once it becomes true,
it stays true in every further extension. Mathematically, a button is exactly a
statement that is **monotone** along the accessibility order — true at $w$ forces it
true at every $v$ reachable from $w$.

These are not arbitrary labels; they have exact structural characterizations.

> **Buttons are fixed points of necessity.** Over any reflexive frame, a statement is
> a button if and only if it equals its own necessitation: $\Box p = p$ at every
> world. In words, a button is a statement that is true exactly when it is *bound* to
> stay true.

The proof is a two-line dance. If $p$ is monotone and true at $w$, then it is true at
every reachable $v$, so $\Box p$ holds — and conversely $\Box p$ implies $p$ by
reflexivity, giving the fixed-point equation. Running the equation in the other
direction recovers monotonicity.

Buttons also behave like well-mannered logical citizens. If $p$ and $q$ are both
buttons, so are $p \wedge q$ and $p \vee q$: pressing two permanent statements
together, or either of them, yields another permanent statement. And they obey the
distributive law $p \wedge (q \vee r) = (p \wedge q) \vee (p \wedge r)$. In the
language of algebra, **the buttons form a distributive lattice** — a clean, orderly
sublattice living inside the wild multiverse.

Switches, meanwhile, admit an equally crisp description in the fully connected
multiverse where every world can reach every other (the picture of forcing as
finite-information change):

> **Switches are exactly the contingent statements.** In the fully connected
> multiverse, a statement is a switch if and only if it is *non-constant* — true at
> some world and false at another.

And the two notions are genuinely opposed:

> **No statement is both a real switch and a nontrivial button.** If a statement can
> always be forced false yet also latches permanently once true, then it can never
> have been true at all — it is false everywhere.

So every world sorts its statements into buttons (which latch) and switches (which
flip), and the boundary between them is not a matter of taste but a lattice-theoretic
and fixed-point invariant.

## Independence is the rule, not the exception

The final movement is a counting argument, and it delivers a punchline that reframes
the whole subject. Fix $n$ mutually independent atomic statements — think of $n$
knobs, each of which forcing can set to true or false without disturbing the others.

A **branch** of the multiverse is one complete setting of all $n$ knobs, a truth
assignment to the atoms. There are exactly $2^n$ branches — the vertices of an
$n$-dimensional Boolean cube.

A **sentence** is any Boolean combination of the atoms: any function that reads a
branch and returns true or false. Since each of the $2^n$ branches can be sent to
either value independently, there are exactly

$$2^{(2^n)}$$

sentences. This is a staggeringly fast-growing number: for $n = 3$ atoms there are
already $2^8 = 256$ sentences; for $n = 4$ there are $2^{16} = 65{,}536$.

A sentence is **settled** if the multiverse decides it — either it is **valid** (true
on every branch) or **refutable** (true on no branch). How many sentences are
settled? Exactly two: the constant "always true" and the constant "always false."
*Every other sentence is independent* — it is true on some branches and false on
others, so no amount of forcing pins it down.

The count is now immediate. Out of $2^{(2^n)}$ sentences, exactly $2$ are settled, so

$$\#\{\text{independent sentences}\} = 2^{(2^n)} - 2.$$

And the proportion of settled sentences, $2 / 2^{(2^n)}$, races to zero at
double-exponential speed. Therefore:

> **Independence is generic.** The proportion of independent sentences among all
> sentences tends to $1$ as the number of independent atoms grows without bound.

This is the deepest reframing of the multiverse perspective. The Continuum Hypothesis
is not a strange exception, a lone undecidable curiosity to be quarantined. It is a
representative citizen of an overwhelming majority. Among all the questions one can
pose by combining independent atoms of set theory, the settled ones — the tidy
"always true" and "always false" — are two lonely points drowned in a sea of $2^{(2^n)}$
possibilities. Undecidability is not the disease of mathematics. Statistically, it is
the healthy default.

## Why this matters

There is a temptation, when confronted with an undecidable statement, to feel that
mathematics has failed us — that a good enough axiom, cleverly chosen, would banish
the ambiguity. The multiverse view answers that temptation with a shrug and a smile.
Undecidability is woven into the combinatorial fabric of the subject. The right
response is not to eliminate the branches but to *study the branching* — to treat
"true in some universe" and "true in all universes" as first-class mathematical
notions with their own precise logic.

That logic is S4.2: rich enough to reason confidently about what forcing can and
cannot achieve, honest enough to admit that you can never travel back to where you
started. Within it, statements sort cleanly into switches that flip and buttons that
latch, and the settled statements are revealed as a vanishing minority. Far from a
foundational embarrassment, the multiverse is a structured, quantifiable, and
genuinely beautiful landscape — a reminder that in mathematics, as in physics, the
existence of many worlds need not cost us any rigor at all.
