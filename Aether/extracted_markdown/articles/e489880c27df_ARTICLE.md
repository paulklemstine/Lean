# How Strong Is a Mathematical Theory? A Geometry of Ordinals

## The question behind the question

Every mathematician has, at some point, felt that one theory is *stronger* than
another. The axioms of arithmetic prove more than the axioms of a pocket
calculator; set theory proves more than arithmetic. But "stronger" is a vague,
almost emotional word. Can we make it precise? Can we attach a *number* to a
theory that says exactly how much it can prove?

For nearly a century, logicians have had a surprising answer: yes — but the
number is not an ordinary number. It is an **ordinal**, one of the transfinite
"counting numbers" that march past infinity. This number is called the
**proof-theoretic ordinal** of the theory, and it is one of the deepest
invariants in all of mathematical logic.

This article tells the story of a fresh, abstract way of thinking about these
ordinals — one that reveals theory-space to be a single, perfectly ordered chain,
that turns the measurement of strength into a *lattice homomorphism*, and that
uncovers a beautiful failure: the most natural notion of "distance between
theories" violates the triangle inequality, not by accident, but because of the
deep asymmetry of infinity itself.

## A quick tour of the infinite

To follow the story you only need a feeling for ordinals. Start counting:
0, 1, 2, 3, …. You never stop, but you can imagine the "limit" of all finite
numbers. That limit is the first infinite ordinal, written **ω** (omega). Then
you keep going: ω, ω+1, ω+2, …, and the limit of *those* is ω·2 = ω+ω. Push on
through ω·3, ω², ω^ω, and a tower of exponentials, and you reach the famous
ordinal **ε₀** ("epsilon-nought"), the smallest ordinal that ω cannot reach by
finite stacking.

Ordinals have arithmetic — you can add them and subtract them — but with a twist
that will become the hero of our story. Ordinal addition is **not commutative**.
Concretely:

> **1 + ω = ω, but ω + 1 ≠ ω.**

Adding one *in front of* infinity disappears into it; adding one *after* infinity
genuinely makes something new. Hold that thought. It is the engine of everything
surprising below.

## Measuring strength: the proof-theoretic ordinal

Here is the classical idea, due to Gentzen, Schütte, Feferman, and many others.
A theory can prove that certain orderings are *well-ordered* — that is, that they
have no infinite descending chains, so you can do induction along them. The
stronger the theory, the larger the orderings it can certify. The
**proof-theoretic ordinal** of a theory is, roughly, the supremum of all the
ordinals it can prove well-ordered.

The landmark results are unforgettable:

- Peano Arithmetic has proof-theoretic ordinal **ε₀**.
- The subsystem ATR₀ of second-order arithmetic has ordinal **Γ₀** (the Feferman–Schütte ordinal).
- Stronger systems climb to the Bachmann–Howard ordinal and far beyond.

These numbers are not decorations. Gentzen's celebrated consistency proof of
arithmetic *is*, in essence, the statement that ε₀ is well-ordered. The ordinal
is the precise amount of infinity you must assume to know that arithmetic will
never contradict itself.

## The abstract move: forget the syntax, keep the shape

The work behind this article asks a clean question. The classical theory is
heavy with syntax — encodings of proofs, formulas, derivations. What if we strip
all of that away and keep only the **shape** of what a theory certifies?

So we define a theory, abstractly, to be nothing more than its
**set of provably well-ordered ordinals**. We require this set to satisfy the two
properties any such set obviously has:

1. **It is bounded.** A real theory cannot certify arbitrarily large ordinals;
   there is a ceiling.
2. **It is downward closed** (an *initial segment*). If a theory can prove a big
   ordinal is well-ordered, it can certainly prove every smaller one is too.

We call such an object an **OrdinalTheory**, and we define its proof-theoretic
ordinal — its **PTO** — to be the *supremum* of its set of certified ordinals.
That single definition, `pto(T) = sup(provablyWO(T))`, is the whole engine.

This minimalism pays off immediately. Because every theory is now literally an
initial segment of the ordinals, we can prove things about *all possible
theories* at once, with the cleanest possible tools.

## First surprise: theory-space is a single chain

You might picture the universe of theories as a sprawling, branching web —
incomparable systems pointing in different directions. The abstract framework
says: **no**. It is a single line.

> **Totality Theorem.** For any two OrdinalTheories T₁ and T₂, either everything
> T₁ certifies is also certified by T₂, or vice versa. The two are always
> comparable.

The proof is a one-line miracle once you see it. Suppose neither contained the
other. Then T₁ certifies some ordinal *s* that T₂ does not, and T₂ certifies some
*t* that T₁ does not. But *s* and *t* are ordinals, so one is smaller — say
*s* < *t*. Since T₂ certifies *t* and is downward closed, T₂ must also certify
the smaller *s* — contradiction. Downward-closed subsets of a line are *nested*;
they cannot cross. So the entire space of theories, ordered by inclusion, is a
**chain**: a totally ordered hierarchy with no side branches.

This is a genuinely clarifying picture. Strength is one-dimensional.

## Second surprise: strength is a structure-preserving map

Theories can be combined. The **join** of T₁ and T₂ is the theory that certifies
whatever *either* one can; the **meet** certifies whatever *both* can. These are
the natural "or" and "and" of theories, and they make theory-space a *lattice*.

How does the strength measurement interact with these operations? Perfectly:

> **Lattice-homomorphism Theorem.**
> PTO(T₁ join T₂) = max(PTO(T₁), PTO(T₂)) and
> PTO(T₁ meet T₂) = min(PTO(T₁), PTO(T₂)).

In words: the strength of a combined theory is exactly the larger of the two
strengths, and the strength of the common core is exactly the smaller. The PTO
map carries the lattice of theories faithfully onto the ordinals. Measuring
strength is not just monotone — it is *structure-preserving*.

A cautionary note keeps us honest: the PTO map is **not injective**. Two
genuinely different theories can have the same strength. The cleanest example:
the theory certifying every ordinal *below* ω, and the theory certifying every
ordinal *up to and including* ω, are different sets — but both have supremum ω,
hence the same PTO. Strength is a faithful *homomorphism*, but it forgets fine
detail. In fact we can say exactly what it forgets:

> **Convexity Theorem.** The theories with a given strength form an *interval* in
> the chain. If T₁ ≤ T ≤ T₂ and the two endpoints have equal PTO, then everything
> sandwiched between them has that same PTO.

The fibers of the strength map are unbroken segments of the line — no gaps.

## The main act: a distance that breaks the rules

Here is where the story turns from clean to *beautiful*. If theory-space is a
line and each theory has an ordinal address, surely we can measure the
**distance** between two theories — how far apart their strengths are.

The obvious definition uses ordinal subtraction symmetrically:

> **depthDist(T₁, T₂) = (PTO(T₁) − PTO(T₂)) + (PTO(T₂) − PTO(T₁)).**

One of the two subtractions is always zero (the smaller minus the larger gives
0), so this just measures the ordinal gap between the two strengths. It is
obviously symmetric, and it is zero exactly when the two theories have equal
strength. It looks, for all the world, like a metric.

Along a chain, it behaves *impeccably* — better than impeccably:

> **Exact Additivity Theorem.** If T₁ ≤ T₂ ≤ T₃, then
> depthDist(T₁, T₃) = depthDist(T₁, T₂) + depthDist(T₂, T₃).

Not merely "the direct route is no longer than the detour" — the direct route is
*exactly equal* to the detour. Distances add up perfectly when you travel in one
direction along the hierarchy. This is the directed triangle inequality, and it
holds with equality.

So far, so metric. Now the twist. A true distance function must satisfy the
**triangle inequality** for *any* three points, in any arrangement. Does
depthDist? Astonishingly — **no.**

> **Triangle-Failure Theorem.** There exist theories T₁, T₂, T₃ with
> depthDist(T₁, T₃) > depthDist(T₁, T₂) + depthDist(T₂, T₃).

The counterexample is small and exact. Take three theories whose strengths are
**ω+1, ω, and 0**. Then:

- depthDist(T₁, T₃) = (ω+1) − 0 = **ω+1** (from strength ω+1 down to 0),
- depthDist(T₁, T₂) = (ω+1) − ω = **1** (a single step from ω+1 down to ω),
- depthDist(T₂, T₃) = ω − 0 = **ω** (the full plunge from ω down to 0).

The detour through T₂ should cost at least as much as the direct trip. But add up
the detour:

> depthDist(T₁, T₂) + depthDist(T₂, T₃) = **1 + ω = ω**.

And ω is **strictly less than** ω+1. The detour is *cheaper* than the direct
route! The triangle inequality is violated.

Look at *why*. The single step of size 1 from ω+1 down to ω is real — it is the
"+1" that ordinal addition refuses to absorb. But when we tack that 1 onto the
front of the big plunge ω, the non-commutativity of ordinal addition swallows it
whole: **1 + ω = ω**. The cost of the small step *vanishes* the moment it is
placed before a larger jump. The asymmetry of infinity erases short detours.

This is not a defect to be patched. It is a *discovery*. The geometry of
proof-theoretic strength is genuinely **directed**: distances are honest when you
travel one way along the hierarchy, but the symmetric "as-the-crow-flies"
distance is illusory, because in the world of ordinals, the order in which you
combine magnitudes matters. depthDist is what mathematicians call a *quasi-metric*
or *directed metric*, not a true metric — and the precise reason is the most
elementary non-commutativity in all of transfinite arithmetic.

## Why this matters

Three threads make this more than a curiosity.

**It clarifies the landscape of logic.** By distilling theories to their bare
order-theoretic shape, the framework proves — cleanly and in full generality —
that the hierarchy of logical strength is one-dimensional, that combining theories
behaves like max and min, and that strength is a lattice homomorphism. These are
exactly the structural facts a working proof theorist relies on, now established
from first principles.

**It locates a real obstruction.** The failure of the triangle inequality is a
precise, reproducible phenomenon with a named cause. It tells anyone hoping to
build a *metric* geometry of theories that they must either restrict to ordinals
where addition behaves (the "additive principal" ordinals, below which short
detours can never be absorbed) or replace ordinal addition with its commutative
cousin, the natural (Hessenberg) sum. The obstruction is a signpost pointing at
the right repair.

**It connects to the texture of infinity itself.** The whole drama hinges on
1 + ω = ω. The most innocent fact about transfinite arithmetic — that a finite
prefix dissolves into an infinite quantity — turns out to govern the large-scale
geometry of mathematical strength. That a fact this small should shape a
structure this large is the kind of resonance that makes mathematics worth doing.

## The shape of strength

We began with a vague feeling — that one theory is stronger than another — and
ended with a precise picture: a single transfinite chain, addresses given by
ordinals, combination given by max and min, and a distance that is honest in one
direction and gloriously broken in the other. The brokenness is the point. It is
infinity, reminding us that the order in which we approach it is never
irrelevant.
