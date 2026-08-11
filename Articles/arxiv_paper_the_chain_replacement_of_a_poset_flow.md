# Every Way of Getting There: Chains, Flows, and the Shape of Concurrency

## A tale of two computations

Imagine two processes running on the same machine. One writes to a file; the other
updates an index. Neither depends on the other, so the operating system is free to
run them in either order, or to interleave them. If you draw the possible states of
the system, you get a little square: the bottom corner is "nothing done yet", the
top corner is "both done", and the two side corners are the two half-finished
states. Every legal execution is a path in that square that only ever moves up and
to the right.

Now ask a question that sounds trivial and is not: *how many essentially different
ways are there to get from the bottom to the top?* If you only care about the final
result, there is one way. If you care about the order of the two operations, there
are two. If you care about the exact interleaving down to the instruction, there are
infinitely many — but they all deform continuously into one another, so in a
homotopical sense there are again only two. Directed algebraic topology is the
subject that makes this "in a homotopical sense" precise, and its central objects
are called **flows**: a set of states, together with, for each ordered pair of
states, a *topological space* of execution paths between them, and an associative
concatenation law that glues paths end to end.

The simplest flows come from partial orders. Given a poset $P$ — think: "state $x$
can evolve into state $y$" whenever $x \le y$ — you can build a flow whose states
are the elements of $P$ and whose space of paths from $x$ to $y$ is a single point
if $x < y$, and empty otherwise. All the information is in the order, and none of it
is in the topology. Such **poset flows** are the atoms out of which more complicated
directed spaces are assembled.

But a single point is a terrible model of a path space if you want to do homotopy
theory. Homotopy theory works by *replacement*: you swap your object for one that is
equivalent to it but built out of well-behaved, freely-attached pieces — a
*cofibrant* object — and only then start gluing. This article is about a particularly
beautiful replacement recipe for poset flows, one where the pieces you attach are
not chosen by an abstract small-object argument, but are read off directly from the
combinatorics of the poset itself. It is called the **chain replacement**, and the
mathematics behind it is the mathematics of *chains ordered by refinement*.

## Refinement: a poset hiding inside every interval

Fix a poset $P$ and two elements $x \le y$. A **chain from $x$ to $y$** is a finite,
totally ordered set of elements
$$x = t_0 < t_1 < \cdots < t_n = y,$$
all lying between $x$ and $y$. You can think of it as an itinerary: a way of getting
from $x$ to $y$ with prescribed stopovers. The set of all such itineraries is itself
partially ordered, not by the order of $P$, but by **refinement**: one itinerary is
below another when the second one includes all the stops of the first, plus possibly
more. Formally, if we record a chain by its underlying finite set $C \subseteq P$,
then $C \le D$ means $C \subseteq D$.

Call this poset $\mathrm{Ch}(x,y)$. It is the hero of the story. The chain
replacement of the poset flow of $P$ is the flow with the same states as $P$, but
whose space of paths from $x$ to $y$ is the *simplicial nerve* of $\mathrm{Ch}(x,y)$
— the space whose vertices are the itineraries, whose edges join an itinerary to any
refinement of it, whose triangles fill in composable pairs of refinements, and so
on. Instead of a single anonymous path from $x$ to $y$, you get a whole
combinatorial space of them, one for every way of subdividing the journey.

Here is the first, and most important, thing to notice. Among all itineraries from
$x$ to $y$ there is one that is coarser than all the others: the two-stop trip
$\{x, y\}$ itself, with no stopovers at all. Every chain from $x$ to $y$ contains $x$
and contains $y$, so $\{x,y\} \subseteq C$ always.

> **The Cone Theorem.** *For $x \le y$ in a poset, the refinement poset
> $\mathrm{Ch}(x,y)$ has a least element, namely the two-element chain $\{x,y\}$.*

A poset with a least element is what topologists call a **cone**: its nerve
deformation-retracts onto that least element, and is therefore contractible.
Contractible means: homotopically indistinguishable from a point. And a point is
exactly what the original poset flow had for a path space. So the chain replacement
has changed the path spaces enormously as combinatorial objects — from a single
point to a space with, for example, $13$ vertices when $P$ is the Boolean lattice on
three elements and $x, y$ are its bottom and top — while changing nothing at all up
to homotopy. That is precisely what a *replacement* is supposed to do.

The numerical shadow of contractibility can be stated and checked entirely with
finite sums, and it is worth stating because it holds for a reason that is
completely elementary and completely convincing:

> **Acyclicity of cones.** *Let $R$ be a finite poset containing an element $z$
> comparable with every element of $R$. Then*
> $$\sum_{C} (-1)^{|C|} = 0,$$
> *the sum ranging over all totally ordered subsets $C \subseteq R$, the empty one
> included. Equivalently, summing over the nonempty ones gives $-1$: the Euler
> characteristic of a point.*

The proof is a single sentence, and it is the kind of argument that makes
combinatorics feel like magic. Pair each totally ordered subset $C$ with the subset
$C \mathbin{\triangle} \{z\}$ obtained by deleting $z$ if it is there and inserting
$z$ if it is not. Because $z$ is comparable with everything, inserting it keeps the
subset totally ordered; deleting an element certainly does. The operation is an
involution with no fixed points, and it changes the size by exactly one, hence flips
the sign. So the sum cancels against itself, term by term. Applied to
$\mathrm{Ch}(x,y)$ with $z = \{x,y\}$ — a cone point because it is below everything
— it says that the path spaces of the chain replacement have the Euler
characteristic of a point.

## Composing itineraries, and taking them apart

A flow is not just a family of path spaces; it is a family of path spaces with a
composition. If you have an itinerary from $x$ to $y$ and one from $y$ to $z$, you
should be able to travel the first and then the second. Concretely: take the union
of the two underlying sets. The result is a chain from $x$ to $z$ through $y$, and
this operation is associative, since union is. It is also **monotone in each
variable**: refining either leg refines the whole trip. Monotonicity is what makes
the composition a map of nerves, i.e. a continuous composition of path spaces. So
the chain replacement really is a flow — a category-without-identities, enriched in
posets.

Composition is not merely well behaved; it is invertible in the strongest possible
sense. Given a chain $E$ from $x$ to $z$ that happens to pass through $y$, you can
cut it at $y$: let $E_{\le y}$ be the part of $E$ below $y$ and $E_{\ge y}$ the part
above. Because $E$ is totally ordered, every one of its points is on one side or the
other, so gluing the halves back recovers $E$ exactly. Conversely, cutting a
concatenation at the joint returns the two legs you started with. And both cutting
and gluing preserve refinement.

> **Unique Factorisation Theorem.** *For $x, y, z$ in a poset, concatenation is an
> isomorphism of posets*
> $$\mathrm{Ch}(x,y) \times \mathrm{Ch}(y,z) \;\cong\; \{\,E \in \mathrm{Ch}(x,z) : y \in E\,\},$$
> *with inverse given by cutting at $y$. Both maps preserve and reflect refinement.*

Passing to nerves, this says the composition law of the chain replacement identifies
the product of two path spaces with an honest *subspace* of the path space of the
composite — the subspace of executions that actually stop at $y$. That is the sort of
rigid, on-the-nose statement one almost never gets in homotopy theory, and it is the
engine behind everything that follows.

## Chains know the Möbius function

Refinement posets are not exotic; they are old friends in disguise. Counting chains
with signs is the definition of one of the most useful gadgets in enumerative
combinatorics, the **Möbius function** $\mu(x,y)$ of a finite poset. It is defined by
the recursion $\mu(x,x) = 1$ and $\sum_{x \le z \le y}\mu(x,z) = 0$ for $x < y$, and
it is the inverse of the "sum over everything below" operator — the abstract engine
behind inclusion–exclusion, behind the classical Möbius function of number theory
(take $P$ to be the divisors of $n$), and behind $(-1)^k$-style sign rules
everywhere.

> **Philip Hall's Theorem.** *For $x, y$ in a finite poset,*
> $$\sum_{C \,:\, x \to y} (-1)^{|C|} = -\mu(x,y),$$
> *the sum ranging over all chains from $x$ to $y$, weighted by the number of their
> elements.*

The proof is a decapitation. Every chain from $x$ to $y$ with $x < y$ has a largest
element, namely $y$; remove it and you are left with a chain from $x$ to some
$z$ with $x \le z < y$, and this correspondence is a bijection between chains from
$x$ to $y$ and pairs (a point $z \in [x,y)$, a chain from $x$ to $z$). Removing an
element flips the sign, so the alternating chain count satisfies exactly the
defining recursion of $-\mu$.

Strip the two endpoints off every chain and what remains is an arbitrary totally
ordered subset of the *open* interval $(x,y)$. So Hall's theorem is equivalent to a
statement of pure topology:

> **Möbius as Euler characteristic.** *For $x < y$ in a finite poset, $-\mu(x,y)$ is
> the alternating face count of the order complex of the open interval $(x,y)$; with
> the usual dimension conventions, $\mu(x,y)$ is the reduced Euler characteristic of
> that complex.*

Combine this with the acyclicity of cones and you get a vanishing criterion that
costs nothing to check and is often decisive:

> **Vanishing criterion.** *If the open interval $(x,y)$ contains an element
> comparable with every element of $(x,y)$, then $\mu(x,y) = 0$.*

Two threads that started far apart — a homotopy-theoretic replacement for directed
spaces, and a nineteenth-century sign-counting device — turn out to be the same
computation viewed from two sides.

## Gluing, and why order-reflection is not a technicality

The reason one builds cofibrant replacements is to glue. In directed topology one
constantly wants to take a flow, identify a sub-flow inside it, and attach something
new along that sub-flow. Whether the resulting path spaces are what you expect
depends on whether the sub-flow sits inside the big one as a *cofibration* — a
"free" inclusion, like attaching a cell.

Suppose $P$ sits inside $Q$ as a sub-poset, via a map $f$ that is not only injective
and order-preserving but **order-reflecting**: $f(u) \le f(v)$ holds *only if*
$u \le v$. Then two maps relate the refinement posets. Pushing forward sends a chain
$C$ of $P$ to its image $f(C)$, a chain of $Q$ from $f(x)$ to $f(y)$. Pulling back
— the **trace** — sends a chain $E$ of $Q$ to the set of points of $P$ whose images
lie on $E$. Order-reflection is exactly what makes the trace land in chains of $P$:
the points it selects are comparable in $Q$, and reflection converts that back into
comparability in $P$. Without it, the trace can produce an antichain, and everything
collapses.

These two maps fit together perfectly. Tracing an image gives back the original
chain, and pushforward is left adjoint to the trace: $f(C) \le E$ if and only if
$C \le \mathrm{trace}(E)$. In the language of order theory they form a *Galois
coinsertion*, and adjoint monotone maps induce homotopy equivalences of nerves — the
structural reason the induced map of path spaces behaves.

Two further facts complete the picture, and they are exactly the combinatorial
avatars of "cofibration" and "pushouts preserve path spaces":

> **Sieve property.** *The chains of $Q$ that come from $P$ form a lower set for
> refinement: anything coarser than an image is again an image.*

> **Splitting.** *The refinement poset of chains of $Q$ from $f(x)$ to $f(y)$ is the
> disjoint union of the chains transported from $P$ and the chains not supported on
> $P$; the first part is a lower set and the second an upper set.*

The path space of the big flow is thus, on the nose, the old path space plus an
independent remainder. Replace the old part by something homotopy-equivalent, glue,
and the remainder is untouched — which is what "pushouts along the chain replacement
of an order-reflecting inclusion preserve spaces of execution paths" means when you
unwind it.

Is order-reflection really needed, or is it a convenience? Here is the smallest
possible answer. Let $P$ be the two-element **antichain** $\{a, b\}$ — two states,
neither leading to the other — and let $Q$ be the two-element **chain** $0 < 1$. The
map $a \mapsto 0$, $b \mapsto 1$ is injective and order-preserving. It is not
order-reflecting: $0 \le 1$ in the target while $a \not\le b$ in the source. And the
conclusion fails as loudly as it can: the target has a chain from $0$ to $1$, namely
$\{0,1\}$, every point of which lies in the image of $P$, while the source has *no
chain from $a$ to $b$ whatsoever*. There is a path downstairs that is entirely
"visible" from upstairs yet has no upstairs origin. Any theorem of the form "chains
supported on the image come from the source" must therefore assume order-reflection.
The hypothesis is not decoration; it is load-bearing.

## What the numbers look like

The combinatorics is vivid enough to compute by hand. In the four-element chain
$0 < 1 < 2 < 3$, the chains from $0$ to $3$ are determined by which of the two
interior points you stop at, so there are $2^2 = 4$ of them, with sizes $2, 3, 3, 4$
and alternating sum $1 - 1 - 1 + 1 = 0 = -\mu(0,3)$, correctly reflecting that the
Möbius function of a chain vanishes on non-covering intervals.

In the Boolean lattice $B_n$ of subsets of an $n$-element set, a chain from $\emptyset$
to the whole set is the same thing as an ordered partition of that set into nonempty
blocks, so the counts are the *ordered Bell numbers* $1, 3, 13, 75, \dots$. For
$n = 3$ the thirteen chains have alternating sum $1$, and indeed $\mu(\emptyset,
\{1,2,3\}) = (-1)^3 = -1$. And every one of those thirteen chains contains the
two-element chain $\{\emptyset, \{1,2,3\}\}$ — the cone point, quietly guaranteeing
that this thirteen-vertex space is a disguised point.

## Why it matters

Concurrency is where this began, and it is where it returns. A concurrent program
with $n$ independent atomic actions has a state space shaped like an $n$-cube, and
questions about deadlock, about scheduling, about which interleavings are genuinely
different, become questions about paths in a directed space. The tools of ordinary
homotopy theory do not apply directly, because time cannot be reversed; flows are one
of the frameworks built to repair that. The chain replacement provides those
frameworks with something they badly need: an explicit, finite, computable cofibrant
model, built from nothing but the combinatorics of refinement, together with a
precise account of when gluing along a subsystem leaves the space of executions
intact.

And along the way it quietly re-derives Philip Hall's theorem, exhibits the Möbius
function as an Euler characteristic, and produces a vanishing criterion for $\mu$
from a two-line involution. It is one of the pleasures of mathematics that the right
definition — here, *order chains by refinement* — pays for itself several times over
in fields that did not know they were related.
