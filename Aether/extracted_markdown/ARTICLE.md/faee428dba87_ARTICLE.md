# Close Proofs: The Hidden Order Behind "Which Proof System Is Stronger?"

Imagine you are handed two different methods for proving mathematical statements.
Maybe one is the familiar machinery of high-school algebra; another is a clever
geometric trick; a third is a sprawling computer-search procedure. A natural
question nags at you: *which one is more powerful?* Not which one you happen to
like, or which one your teacher used, but which one can — in principle, and
without wasting too much paper — establish more truths, faster.

This question is older than computers, but it became precise and urgent in 1979,
when Stephen Cook and Robert Reckhow turned it into a research program at the
heart of theoretical computer science. Their insight was deceptively simple. A
*proof system* is just a way of certifying truths: it produces objects we call
proofs, each proof "concludes" some statement, and each proof has a *size* — the
number of symbols, lines, or computational steps it costs. One system is *at
least as strong* as another if it can re-prove everything the other proves
**without blowing up the size by more than a polynomial factor**. Two systems
that can each efficiently mimic the other are, for all practical purposes, the
same.

Cook and Reckhow noticed something startling: this efficiency relation is the
secret skeleton of one of the deepest open problems in mathematics. **If some
proof system could prove every true tautology with proofs of merely polynomial
size, then the complexity classes NP and coNP would coincide** — a collapse
nearly as dramatic as P = NP. Conversely, the way to *separate* NP from coNP is
to march up an infinite tower of ever-stronger proof systems, showing each one
still has tautologies it cannot prove efficiently. The whole program lives or
dies on the structure of a single ordering: the ordering of proof systems by
relative efficiency.

This article is about the *shape* of that ordering. Not about any one proof
system, but about the entire landscape they form when you stack them by power.
What does this landscape look like? Does it have a bottom? A top? Tall towers?
Wide plateaus of mutually-incomparable systems? Is it a tidy lattice, or
something wilder? These are the questions we answer — and the answers are
beautiful, surprising, and now established with the full rigor of a verified
mathematical theory.

## From systems to "degrees"

The first move is one mathematicians make instinctively: when an ordering has
ties, collapse the ties. Two proof systems that simulate each other efficiently
should be thought of as a single point. Each such point is called a **p-degree**
(short for "polynomial-simulation degree"), by direct analogy with the *Turing
degrees* of computability theory, which classify problems by relative
solvability. The Turing degrees famously form an intricate, much-studied
universe; the p-degrees are their efficiency-aware cousin, and they have been far
less explored.

Once you pass to p-degrees, the messy preorder ("at least as strong as," with
ties everywhere) becomes a genuine **partial order**: a clean poset in which
A ≤ B means "B is at least as strong as A," and A = B means they are
efficiency-equivalent. Our task is to chart this poset.

To make the charting tractable, we use a trick that turns logic into
arithmetic. Picture the simplest possible family of proof systems: for any
"cost function" *a*(*n*) — a rule assigning a size to each statement *n* — build
the system whose proof of statement *n* costs exactly *a*(*n*). Call it the
*size-a system*. Now the central question — when does one such system simulate
another? — has a startlingly clean answer.

> **The Domination Principle.** The size-*a* system efficiently simulates the
> size-*b* system **if and only if** the cost function *a* is bounded by some
> polynomial applied to *b*. In symbols: there is a monotone, polynomially
> bounded function *f* with *a*(*n*) ≤ *f*(*b*(*n*)) for every *n*.

In one stroke, this converts every question about the geometry of proof power
into a question about the *growth rates* of functions. Is one system stronger
than another? Compare how fast their cost functions grow. Are two systems
incomparable? Find an input where each cost function outruns any polynomial in
the other. This is the engine that drives everything below.

## A worked separation: linear versus Fibonacci

The simplest interesting fact about the landscape is that it is not flat — there
exist genuinely different degrees. To see this we pit two cost functions against
each other: the **linear** cost *a*(*n*) = *n*, and the **Fibonacci** cost
*a*(*n*) = *F*(*n*), the *n*-th Fibonacci number 1, 1, 2, 3, 5, 8, 13, 21, …,
which grows exponentially fast (roughly like the golden ratio raised to the
*n*-th power).

Which way does simulation go? The linear system easily simulates the Fibonacci
system: to match a tiny Fibonacci proof you only need a linearly larger one,
since *n* itself is a perfectly polynomial (indeed linear) bound. But the reverse
fails spectacularly. The Fibonacci numbers grow faster than *any* polynomial, so
no polynomial in *F*(*n*) can keep up with the runaway gap — there is no monotone
polynomial bound *f* with *F*(*n*) ≤ *f*(*n*) for all *n*. The Domination
Principle then certifies, with no hand-waving, that **the Fibonacci system
cannot efficiently simulate the linear system.**

The conclusion: the linear degree sits *strictly below* the Fibonacci degree.
This is a "strict 2-chain" — two points, one genuinely above the other. It is the
miniature of every separation result in proof complexity: find a cost (a class of
hard tautologies) that one system pays cheaply but the other cannot.

## How tall is the tower? Infinitely.

Two distinct degrees is a start, but the real question is whether the landscape
has *depth*. Can we keep finding strictly stronger systems forever, or do we hit
a ceiling? The answer is that the tower is **infinitely tall**, and the proof is
a small gem of growth-rate engineering.

The natural first guess for an infinite ladder is to crank up an exponential:
take the systems with cost 2^(*k*·*n*) for *k* = 1, 2, 3, …. Surely each rung
beats the last? It does not. All these rungs are secretly the *same* p-degree,
because 2^((*k*+1)·*n*) = (2^(*k*·*n*))² is just a polynomial blow-up of its
predecessor — squaring is polynomial, so the Domination Principle collapses the
whole ladder to a single point. This is exactly the kind of trap the structure
sets for the unwary, and exactly why the formal verification matters.

The fix is elegant: don't grow the exponent linearly, grow it *polynomially*.
Consider the ladder of cost functions

> *a_k*(*n*) = 2^(*n*^*k*),  for *k* = 1, 2, 3, …

Now the *k*-th rung costs 2 raised to the *k*-th power of *n*. The leap from rung
*k* to rung *k*+1 changes the exponent from *n*^*k* to *n*^(*k*+1) = *n*·*n*^*k*.
Multiplying the exponent by *n* is a far more violent change than any polynomial
in 2^(*n*^*k*) can absorb: a polynomial of degree *c* only multiplies the
exponent by *c*, and for *n* larger than *c* the term *n*·*n*^*k* simply runs
away. The arithmetic heart of the matter is the inequality

> (2^(*n*^*k*) + 2)^*c* < 2^(*n*^(*k*+1))   for suitable large *n*,

which says no fixed polynomial power of one rung can reach the next. Each rung is
strictly stronger than the one below, forever.

> **Infinite Height.** The cost functions 2^(*n*^*k*) realize an infinite,
> strictly increasing chain of p-degrees. The landscape of proof power contains
> towers of every finite height — and an infinite one.

This is not a heuristic. Every step — the collapse of the naive ladder, the
super-polynomial gap of the corrected ladder, the strict increase of each rung,
and the fact that these really are *distinct points* in the poset of degrees —
has been pinned down completely.

## Is the landscape a lattice? Meets, yes.

A poset is most pleasant when any two points have a *meet* (a greatest common
lower bound) and a *join* (a least common upper bound). For p-degrees, one half
of this holds with a wonderfully concrete construction.

Given two proof systems *P* and *Q*, build their **direct sum** *P* ⊕ *Q*: a
proof in the combined system is *either* a *P*-proof *or* a *Q*-proof, and it
costs whatever it cost in its home system. This is the "run whichever you like"
system. It clearly simulates both *P* and *Q* — you can always just use the
relevant half. And it is the *most efficient* system that does so: any system *R*
that simulates both *P* and *Q* must simulate the direct sum too, because to
translate a *P*-or-*Q* proof, *R* simply applies whichever of its two
translations is appropriate. The polynomial blow-up needed is just the *maximum*
of the two individual blow-ups — and crucially, the maximum of two monotone
polynomial bounds is again a monotone polynomial bound.

> **Meets exist.** For any two proof systems, the direct sum is their greatest
> lower bound in the simulation order. Consequently, any two systems have a
> common lower bound (the order is "down-directed"), and the p-degrees form a
> **meet-semilattice**.

The intuition is satisfying: combining the strengths of two systems while paying
only the cheaper price wherever possible is precisely the operation of taking a
meet of their *blow-up costs* — a pointwise maximum of slow-downs, which is a
pointwise minimum of strengths.

## What is still wild

Here the story turns from "tidy" to "untamed," and that is what makes the
p-degrees a frontier rather than a finished textbook chapter. While meets always
exist, **joins do not in general** — there are pairs of degrees with no single
least upper bound, so the p-degrees are a meet-semilattice but *not* a lattice.
And the landscape is not merely tall; it is also **infinitely wide**. Using a
classical number-theoretic decomposition (splitting the natural numbers into
infinitely many infinite "spike sets" by their 2-adic valuation, then planting an
exponential spike on each), one can build an infinite family of proof systems
that are **pairwise incomparable** — an infinite antichain. No two of them
simulate each other; they are genuinely different directions of strength, side by
side. This immediately tells us the simulation order is *not total*: efficiency
of proofs is fundamentally a partial, many-dimensional notion, not a single
yardstick.

The landscape also has a **floor**. There is a least p-degree — the trivial
system whose proofs cost nothing — and it sits strictly below the entire height
ladder. And between any two of our separated degrees, the order can be *dense*:
by thinning a cost function on a sparse set of inputs (Fibonacci on the even
numbers, linear on the odd), one constructs a degree lying strictly between the
linear and Fibonacci degrees, witnessing that there is always room in between.

Put together, the emerging portrait of the p-degrees is this: a poset with a
bottom element, infinite ascending towers, infinitely wide antichains, meets
everywhere but joins only sometimes, and pockets of density. It is at once
structured and unruly — exactly the kind of object that rewards patient
exploration.

## Why this matters

It is tempting to file all this under "abstract order theory," but the stakes are
concrete. The Cook–Reckhow program is the established route toward separating NP
from coNP, and through it, toward understanding the limits of automated reasoning,
SAT solvers, and the very possibility of short proofs for hard problems. Every
real proof system used in practice — resolution, cutting planes, Frege systems,
the algebraic and semidefinite systems behind modern optimization — occupies some
point in exactly this poset. Knowing the *shape* of the poset tells us what kinds
of separations are even possible: where towers can rise, where antichains force
genuinely orthogonal techniques, where meets let us combine methods for free, and
where the absence of joins warns us that two strengths cannot always be merged
into one.

There is also a deeper aesthetic payoff. The Turing degrees taught us that
"solvability" is an astonishingly rich universe rather than a simple yes/no.
The p-degrees promise the same lesson one level finer: *efficient provability* is
not a number but a landscape — with depth, breadth, floors, and frontiers. The
results gathered here are the first reliable contour lines on that map: the
Domination Principle that turns logic into arithmetic; the linear-versus-Fibonacci
separation; the polynomial-exponent ladder that climbs forever; and the direct-sum
meet that gives the order its semilattice spine.

The map is far from complete. We do not yet know the full *order type* of the
p-degrees — which abstract posets can be embedded into them, how meets and the
missing joins interact, how the antichains and towers weave together. But for the
first time, the core landmarks are fixed and certain. The order-theoretic core of
the Cook–Reckhow program is no longer folklore. It is a theorem.
