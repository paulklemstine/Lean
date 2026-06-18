# The Shadow of an Equation: How to Erase a Variable Without Losing the Truth

## A problem older than algebra itself

Suppose you are handed a tangle of equations. Some of them speak of quantities
you care about — call them *x*, the visible world. Others drag in helper
quantities — call them *y*, the hidden machinery you would rather not think
about. A robot arm's elbow angle, a camera's unknown depth, the slack variable
a scheduler invented to balance a constraint: these are all *y*. They were
useful for writing the problem down, but in the end you want a clean statement
about *x* alone.

The art of throwing away the *y*'s while keeping every true consequence about
the *x*'s has a name as old as algebra: **elimination**. When Bézout, Euler,
and Sylvester computed resultants to decide when two curves meet; when a
modern solver projects a system of polynomial constraints onto the coordinates
you can measure; when a database engine answers a query that mentions only a
few columns of a vast join — they are all eliminating variables. Elimination
is the act of computing a *shadow*: the faithful silhouette that a
high-dimensional object casts onto the lower-dimensional space you live in.

This article is about a new and surprisingly clean way to describe that shadow.
The punchline can be stated in a single sentence: **the true shadow of a system
of equations is exactly the overlap of all the shadows you get by guessing the
hidden variables.** Guess wildly, guess cleverly, guess in every possible
way — then take what *all* your guesses agree on, and you have recovered the
elimination exactly, with nothing lost and nothing spuriously added. Under a
mild and natural "separation" hypothesis, this is a theorem, not a heuristic.

## Equations as relationships, not just zeros

To get there we need to widen our lens slightly. In school we learn to think of
an equation as something set to zero: *x² − 2 = 0*. But the deeper object is
the **relationship** it imposes. Saying *x² = 2* is really declaring that two
*different-looking expressions* — *x²* and *2* — are to be treated as **the same
thing** from now on. Algebra calls such a "treat these as equal" rule a
**congruence**.

A congruence is a wonderfully flexible bookkeeping device. It is simply a way of
declaring certain pairs of polynomials equal, with one rule: the declarations
must respect addition and multiplication. If you have decided *A* equals *B*,
then *A + C* must equal *B + C*, and *A·C* must equal *B·C*. Nothing more.
Every system of equations generates a congruence: the smallest "treat-as-equal"
rule that honors all your stated identities and is closed under the arithmetic.
The quotient world you get by collapsing equal things is exactly the algebraic
model of your constraint system.

Crucially, this idea costs nothing extra and works far beyond ordinary numbers.
It works over the integers and the rationals, but also over **semirings** — number
systems where you can add and multiply but maybe not subtract. Those include
the Boolean world of *true*/*false* (where "plus" is OR and "times" is AND), and
the **tropical** worlds of optimization, where "plus" means *take the minimum*
and "times" means *ordinary addition*. In the tropical world, polynomials
compute shortest paths, optimal schedules, and cheapest assignments. A theorem
that speaks the language of congruences over arbitrary semirings therefore
speaks, simultaneously, to logic, to classical algebra, and to optimization.

## Two ways to compute a shadow

Now fix our two families of variables: the kept ones *x* and the doomed ones
*y*. There are two natural homomorphisms between the small world of
*x*-polynomials and the big world of *(x, y)*-polynomials.

The first is the **inclusion**, which we call **liftX**. It simply views an
*x*-polynomial as living in the bigger ring — it never mentions *y* at all. An
expression like *x₁² + 3x₂* is the same expression whether or not *y* exists in
the ambient vocabulary.

The second is **evaluation**, which we call **evalXY**. Pick a *guess* for the
hidden variables: a recipe φ that replaces each *y*-variable by some honest
*x*-polynomial. "Set *y* equal to *x²*." "Set *y₁ = x₁ + x₂* and *y₂ = 7*."
Each such recipe φ is a substitution, and substituting collapses the big world
back down to the small one: every *(x, y)*-polynomial becomes a pure
*x*-polynomial once you replace the *y*'s.

These two maps fit together by one tiny, decisive identity. If you first
*include* an *x*-polynomial into the big ring and then *substitute away* the
*y*'s, you get back exactly what you started with:

> **The retraction identity.** For every guess φ, evaluating after including is
> the identity: `evalXY φ (liftX p) = p`.

It is almost too obvious to state — including *x²* and then setting *y = (anything)*
does nothing to *x²*, because *x²* never contained a *y*. But this triviality is
load-bearing. It says that **liftX is a section of every evaluation map**: no
matter how you guess the hidden variables, the kept variables pass through
untouched. Two immediate consequences fall out for free: the inclusion is
*injective* (distinct *x*-polynomials stay distinct), and every evaluation is
*surjective* (every *x*-polynomial is the shadow of something upstairs — namely
its own lift).

## The true shadow versus the guessed shadows

With these maps in hand, a congruence *C* on the big *(x, y)*-world casts two
different kinds of shadow onto the small *x*-world.

**The true shadow — the elimination congruence.** Declare two *x*-polynomials
*f* and *g* equal exactly when their *honest inclusions* are already equal
upstairs, i.e. when *C* relates `liftX f` and `liftX g`. This is the genuine
elimination: it asks, *do f and g become the same once we impose all the
constraints, including everything the y's secretly enforce?* This is the shadow
we actually want — the projection of the upstairs world onto the *x*-axes,
honoring every hidden consequence. We call it **eliminationCong C**.

**A guessed shadow — the evaluation contraction.** Fix a single guess φ for the
*y*'s. Push the entire congruence *C* downstairs through that one substitution:
whenever *C* declared two big polynomials *F* and *G* equal, declare their
substituted images `evalXY φ F` and `evalXY φ G` equal too, and close up under
arithmetic. This produces a congruence on the *x*-world that depends on your
particular guess. A clever guess respects the hidden constraints and gives a
faithful shadow; a careless guess can glue together things that should have
stayed apart, producing a shadow that is *too coarse*. We call this guessed
shadow **evalContraction C φ**.

Here is the first half of the story, and it is the easy half:

> **The easy direction.** Every guessed shadow contains the true shadow:
> `eliminationCong C ≤ evalContraction C φ` for every φ.

In the language of congruences, "≤" means "coarser" — declares at least as many
things equal. So the statement reads: *no guess can ever be finer than the
truth.* Any equality forced by the genuine elimination is forced by every
substitution as well. The proof is the retraction identity wearing a disguise:
if `liftX f` and `liftX g` are *C*-equal upstairs, then applying evalXY φ to
both — which returns *f* and *g* unchanged — shows *f* and *g* are related in
the pushed-down congruence. Guesses can only lose information, never invent
detail finer than the truth.

## The meet of all guesses

The easy direction tells us each individual guess overshoots — it is too coarse,
it equates too much. But different guesses overshoot in *different directions*.
One substitution might wrongly glue *f* to *g*; a second might keep those apart
but wrongly glue *h* to *k*. So a natural idea presents itself: **don't trust
any single guess — trust only what all of them agree on.** Take the *meet*
(the greatest lower bound, the finest common refinement) of every guessed shadow
over every possible substitution φ:

> **Spectral evaluation elimination.** `elimEval C` is the infimum, over all
> guesses φ, of the guessed shadows `evalContraction C φ`.

The word *spectral* is apt. We are not committing to one evaluation point; we
are sweeping across the entire *spectrum* of evaluations, the whole landscape of
ways to interpret the hidden variables, and reading off the invariant that
survives. The easy direction immediately gives one half of the comparison:
since the truth sits below *every* guess, it sits below their meet:
`eliminationCong C ≤ elimEval C`.

The deep question is the reverse. Could the meet of all guesses *still* be
strictly coarser than the truth — could there be a pair *f*, *g* that the genuine
elimination keeps apart, yet *every* substitution wrongly glues together? If so,
no amount of guessing, however exhaustive, would ever recover the true shadow.

## The separation hypothesis, and the theorem

The reverse inclusion cannot hold for *completely* arbitrary congruences over
*completely* arbitrary semirings — you need just enough room to maneuver. The
precise condition is a **separation property**, and it captures exactly the
intuition that *the evaluations are rich enough to see everything*:

> **Evaluation Separation Property.** Whenever the true elimination keeps two
> *x*-polynomials *f* and *g* apart, *some* guess φ keeps them apart too: there
> exists a substitution whose pushed-down shadow does **not** glue *f* and *g*.

This is a "no blind spots" condition. It says the family of evaluations is a
faithful set of probes: any genuine distinction in the true shadow is witnessed
by at least one concrete substitution. It is the algebraic cousin of the
classical principle — running through Hilbert's Nullstellensatz, the Jacobson
radical, and the spectral philosophy of modern geometry — that *a ring is
understood through its points*, and that two things which agree at every point
must already be equal. Here the "points" are the evaluation guesses.

Once you grant this, the second half snaps into place by pure logic. Suppose
*f* and *g* are kept apart by the truth. By separation, some guess φ keeps them
apart in its shadow. But the meet of all guesses sits below that particular
guess, so the meet must keep them apart too. Contrapositively, anything the
meet glues, the truth glues. That is the reverse inclusion. Combining both
directions gives the centerpiece:

> **The Spectral Evaluation Elimination Theorem.** Under the Evaluation
> Separation Property, the meet of all guessed shadows equals the true shadow
> exactly: `elimEval C = eliminationCong C`.

Elimination — that ancient, often computationally fearsome operation of
projecting away variables — is *precisely* the overlap of all the easy,
mechanical substitution shadows. The hard global object equals an intersection
of simple local ones.

## You only need finitely many guesses

A meet over *all* possible substitutions is an infinite, idealized object. The
practitioner immediately asks: *how many guesses do I actually need?* The
answer is reassuring. There is a finite refinement of the separation property —
the **Finite Evaluation Separation Property** — which asks that for each
congruence there be a *fixed finite list* of guesses φ₁, …, φₙ that together
witness every distinction the truth makes. Under it:

> **The Finite Witness Theorem.** A finite family of evaluations reconstructs
> the elimination exactly: there exist finitely many guesses whose shadows
> already meet to the true shadow `eliminationCong C`.

This is what turns the philosophy into an algorithm. You do not sweep an
infinite spectrum; you probe with a finite, well-chosen battery of
substitutions, intersect their easily computed shadows, and out comes the
elimination — guaranteed correct, with a certificate that finitely many probes
suffice. It is the same passage that makes geometry computable: a variety is
cut out by finitely many equations, a compact space is covered by finitely many
charts, and here a projection is captured by finitely many evaluations.

## Sanity at the boundaries

A good theory agrees with common sense in the trivial cases, and this one does.
The **empty** congruence ⊥ — the one that declares nothing equal beyond literal
identity — has empty elimination: its true shadow, every guessed shadow, and the
whole spectral meet all collapse back to ⊥. Nothing was glued upstairs, so
nothing is glued downstairs. At the other extreme, the **total** congruence ⊤ —
the one that declares *everything* equal, the algebraic image of an
inconsistent system — has total elimination: the truth, every guess, and the
meet are all ⊤. A contradiction upstairs is a contradiction downstairs. The
machinery passes both stress tests cleanly.

There is also a refinement worth naming. Some guesses are *admissible*: their
shadow is already fine enough to sit below the truth rather than overshoot it.
If even one admissible guess exists, then restricting the meet to admissible
guesses *still* recovers the elimination exactly. In other words, you do not
need the wild guesses to drag the average down — the good guesses alone, met
together, already hit the truth on the nose.

## Where the hidden variables live: logic, optimization, geometry

Because everything is phrased over a general semiring, the theorem speaks
several dialects at once.

Over an ordinary ring like the rationals, this is classical elimination theory:
projecting an algebraic variety onto a coordinate subspace, with the
substitutions φ playing the role of rational sections. The separation property
is the geometric statement that the projection's closure is detected by enough
parametrized slices.

Over the **Boolean** semiring, polynomials are logical formulas, congruences are
theories, and eliminating *y* is *existential quantifier elimination* — deciding
what a formula says about the visible variables once the hidden ones are
quantified away. The substitutions are concrete witnessing terms, and the
theorem says a quantified statement is captured by the meet of its
instantiations.

Over the **tropical** (min-plus or max-plus) semiring — the native language of
scheduling, shortest paths, and discrete optimization — congruences encode
families of optimization constraints, and eliminating a variable is the
projection of a feasible region or the marginalization of an objective. The
evaluation guesses are candidate policies, and the theorem says the true
projected cost structure is the overlap of the cost structures induced by all
candidate policies — with a finite battery of policies sufficing.

A particularly clean setting is the family of **additively idempotent**
semirings — those where *a + a = a*, the defining quirk of the Boolean and
tropical worlds alike. There the natural notion of a **prime** congruence
emerges (one where a product lands in the "zero class" only if a factor does),
and one can ask for *prime separation*: any two things kept apart by a
congruence are kept apart by some prime congruence containing it. This is the
exact analog of the statement that a radical ideal is the intersection of the
primes above it — the Jacobson philosophy made concrete — and it is precisely
the kind of structural assumption that powers the separation hypothesis.

## Why this picture matters

Elimination has always carried a reputation for difficulty. Resultants
explode in size; Gröbner-basis projections can be doubly exponential;
quantifier elimination is a byword for computational pain. The reframing here
does not repeal those hardness facts — but it changes the *shape* of the
problem in a way that is both conceptually and practically valuable. It says the
forbidding global object is an *intersection of cheap local ones*. Each guessed
shadow is just a substitution followed by a closure: mechanical, parallelizable,
embarrassingly simple. The difficulty is concentrated entirely in *choosing
enough guesses* — and the Finite Witness Theorem promises that a finite,
in-principle-findable battery always suffices.

This is the same intellectual move that has powered mathematics for a century:
replace a hard global invariant by the meet (or the limit, or the sheaf) of
easy local data, and prove that nothing is lost in the passage. Cohomology does
it for topology; the local-global principles do it for number theory; the
spectrum does it for rings. Here we watch it happen for the humble, ancient,
indispensable act of erasing a variable.

The shadow of an equation, it turns out, is exactly the agreement of all its
guesses. Erase the hidden variable however you like — and what survives every
erasure is the truth.
