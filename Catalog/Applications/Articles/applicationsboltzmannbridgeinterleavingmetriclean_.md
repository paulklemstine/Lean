# When "Distance Zero" Means "Infinitely Far": Fixing the Geometry of Shape

## A puzzle hiding in the mathematics of data

Imagine you are handed two photographs of a coastline taken decades apart, and
asked a deceptively simple question: *how different are these two shapes?* Not
how different the pixels are — anyone can subtract pixel from pixel — but how
different the **shapes** are. Where are the bays, the peninsulas, the islands,
the holes? Which features survive the passage of time, and which were just noise
that the tide erased?

This is the central question of a young and beautiful branch of mathematics
called **topological data analysis**, or TDA. Over the last two decades it has
become one of the most powerful lenses we have for seeing structure in messy,
high-dimensional data — from the folds of proteins, to the voids in the
large-scale distribution of galaxies, to the firing patterns of neurons in the
brain. The promise of TDA is that **shape is robust**: small changes in the data
should produce only small changes in the measured shape. A grain of sand on the
beach should not turn a peninsula into an island.

To make that promise precise, mathematicians need a *ruler* — a way to measure
the distance between two shapes-of-data. And this article is about a subtle,
almost philosophical flaw that crept into one natural attempt to build that
ruler, and the elegant repair that fixed it. The flaw is this: the ruler could
report that two shapes which are *infinitely far apart* are in fact at distance
**zero**. The repair is to change the number system the ruler lives in — to allow
it, when honesty demands, to answer "infinity."

It is a story about how the right choice of *where your numbers live* can turn a
broken measuring stick into a genuine geometry.

## The shape of data, one scale at a time

Let us begin with the raw material. Suppose you have a cloud of data points — say
the locations of cell-phone towers across a country, or the atoms in a molecule,
or measurements of a thousand patients along a hundred clinical axes. You want to
know the shape this cloud traces out. Are the points clustered into separate
groups? Do they wrap around to form loops? Do they enclose hollow cavities?

The trouble is that a finite set of points, taken literally, has no interesting
shape at all — it is just dust, a collection of isolated specks. The insight at
the heart of TDA is that shape only emerges when you decide **how close is close
enough to be connected.** Pick a scale — call it *t*. Then draw an edge between
any two points closer than *t*; fill in a triangle whenever three points are all
mutually within *t*; fill in a tetrahedron for four such points; and so on. The
result is a geometric object built out of points, edges, triangles, and their
higher-dimensional cousins, all glued together. Mathematicians call such an
object a **simplicial complex**, and the individual pieces — a point, an edge, a
triangle — are called **simplices** or **faces**.

Now here is the crucial move. Do not pick just one scale. Pick *all* of them at
once. As you slowly turn the dial on *t* from zero upward, you watch the shape
grow: first isolated points, then a sprawl of edges, then triangles snapping into
place, components merging, loops being born and later filled in. This growing
family of complexes, nested one inside the next, is called a **filtration**.

In the mathematics we will describe, a filtration is captured abstractly and
cleanly. To each possible simplex *σ* (each candidate point, edge, triangle, …)
we assign a single number, its **weight** — the scale at which it is first born.
A natural rule governs these weights: *a face cannot be born after something
built on top of it.* If the triangle exists, its three edges and corners must
already exist. Formally, whenever one simplex *σ* is contained in another simplex
*τ*, we require

> weight(*σ*) ≤ weight(*τ*).

That single monotonicity rule, together with the convention that the empty
simplex is born at the very beginning (weight ≤ 0), is the entire definition. The
shape at scale *t* — written **sublevel(*t*)** — is then simply the collection of
all simplices whose weight is at most *t*:

> sublevel(*t*) = { *σ* : weight(*σ*) ≤ *t* }.

Turning up *t* can only admit more simplices, never expel them, so the family is
genuinely nested: if *t₁ ≤ t₂* then sublevel(*t₁*) ⊆ sublevel(*t₂*). This nested
family is the fingerprint of the data's shape across all scales at once.

The canonical example is the **Vietoris–Rips filtration**, where the weight of a
simplex is its *diameter*: the largest distance between any two of its vertices.
A pair of points becomes an edge exactly when the dial *t* reaches the distance
between them; a triple becomes a triangle when *t* reaches their largest pairwise
distance. This is the construction that turns a bare table of pairwise distances —
nothing but a grid of numbers *d(x, y)* — into a full multi-scale shape.

## The promise of stability, and the ruler that measures it

Now we can state the promise precisely. Suppose two data sets are *almost the
same*: every pairwise distance in the first is within some small ε of the
corresponding distance in the second. Then their entire filtrations — their whole
multi-scale shapes — should be *almost the same* too. This is the celebrated
**stability theorem** of persistent homology, first proved by Cohen-Steiner,
Edelsbrunner, and Harer (CESH). It is the theorem that makes TDA trustworthy: it
guarantees that the features you detect are properties of the underlying
phenomenon, not artifacts of measurement noise.

To express "almost the same shape," we need the ruler. The right notion is called
**interleaving**. Two filtrations *F* and *G* are said to be **δ-interleaved**
(for some shift δ ≥ 0) when each one, after sliding its scale up by δ, contains
the other:

> for every scale *t*:  *F*'s shape at *t*  ⊆  *G*'s shape at *t + δ*,
> and  *G*'s shape at *t*  ⊆  *F*'s shape at *t + δ*.

In words: anything that has appeared in *F* by scale *t* has appeared in *G* by
scale *t + δ*, and vice versa. The two growing shapes shadow each other, never
lagging by more than δ in the dial. The smaller the δ that works, the more nearly
identical the two shapes are.

This interleaving relation has three lovely structural properties, each a
near-tautology once you see it:

- **Reflexive.** Any filtration is 0-interleaved with itself.
- **Symmetric.** If *F* is δ-interleaved with *G*, then *G* is δ-interleaved
  with *F* — the definition is already symmetric in the two.
- **Composable (the triangle law).** If *F* is δ-interleaved with *G*, and *G*
  is δ′-interleaved with *H*, then *F* is (δ + δ′)-interleaved with *H*. You
  simply chain the inclusions: shift up by δ to get from *F* into *G*, then by δ′
  to get from *G* into *H*, a total shift of δ + δ′.

These are exactly the axioms of a **distance** in disguise. So the natural
definition of the **interleaving distance** between two filtrations is the
smallest shift that interleaves them:

> dist(*F*, *G*) = the infimum of all δ such that *F* and *G* are δ-interleaved.

And the stability theorem becomes a single crisp inequality: if the two data
sets' distance matrices differ by at most ε everywhere, then the interleaving
distance of their Vietoris–Rips filtrations is at most ε. Shape is
**1-Lipschitz** in the data: perturb the input by ε, and the measured shape moves
by no more than ε. The whole edifice of stability rests, remarkably, on one tiny
fact — that the *diameter* of a simplex changes by at most ε when every pairwise
distance changes by at most ε.

## The crack in the ruler

Here is where the story takes its turn. Everything above is true and clean — as
long as the two filtrations actually *can* be interleaved by some finite shift.
But what if they cannot? What if two shapes are so fundamentally different that
**no** shift δ, however large, ever makes one contain the other?

This is not an exotic edge case. It happens whenever the filtrations have genuinely
incompatible features that no amount of rescaling can reconcile. For such a pair,
the set of admissible shifts δ is **empty**. And now we must ask: what is "the
smallest element of the empty set"?

In ordinary real-number mathematics, there is a convention for the infimum of an
empty set of candidates, and inside the bounded world this software lives in, that
convention returns **zero**. So the ruler, faced with two shapes that are
infinitely far apart, confidently reports:

> dist(*F*, *G*) = 0.

This is a catastrophe. A distance of zero is supposed to mean *identical*. Here it
means *as different as two things can possibly be*. The ruler has its most extreme
reading and its most placid reading confused for one another.

Worse, this single misreading **destroys the triangle inequality**, the law that
makes a distance a distance. The triangle inequality says dist(*F*, *H*) ≤
dist(*F*, *G*) + dist(*G*, *H*): you can never shorten a journey by detouring
through a third point. But suppose *F* and *G* are genuinely close (small
distance), *G* and *H* are genuinely close (small distance), yet *F* and *H*
happen to be never-interleaved. Then the left side is the bogus large-but-recorded-
as-zero value, while the right side is a sum of two honest small numbers, and the
inequality can fail in spirit even as it superficially holds in the corrupted
arithmetic. The geometry collapses. We have a number we *call* a distance, but it
is not one. An earlier version of this theory recorded exactly this failure in its
own lab notebook — an honest admission that the real-number ruler was broken and
could not, within the real numbers, be repaired.

## The repair: let the ruler say "infinity"

The fix is as elegant as it is decisive, and it is a lesson that echoes throughout
mathematics: **when a structure misbehaves, sometimes the cure is not to change
the structure but to change the number system it reports into.**

Instead of measuring distances in the ordinary real numbers, measure them in the
**extended non-negative reals** — written ℝ≥0∞ — which is just the non-negative
real numbers with one extra symbol attached at the top: **∞**. In this enlarged
number system, the infimum of an empty set of candidates is no longer the
nonsensical zero. It is, correctly and automatically, **∞**.

So we redefine the ruler with exactly the same formula, but living in this larger
home:

> **eInterleavingDist(*F*, *G*)** = the infimum, taken in ℝ≥0∞, of the shifts δ
> over all δ that interleave *F* and *G*.

When the two shapes can be interleaved, this returns the same honest finite number
as before. When they cannot, it returns **∞** — the truthful statement that they
are infinitely far apart, infinitely incompatible. The most extreme reading and
the most placid reading are finally distinct again.

And now the magic happens. With this one change, *every* axiom of a genuine
distance holds, **with no exceptions and no fine print**:

- **Vanishing on the diagonal.** eInterleavingDist(*F*, *F*) = 0. A shape is at
  distance zero from itself, because it is 0-interleaved with itself.
- **Symmetry.** eInterleavingDist(*F*, *G*) = eInterleavingDist(*G*, *H*)… more
  precisely, eInterleavingDist(*F*, *G*) = eInterleavingDist(*G*, *F*). The
  underlying interleaving relation is symmetric, so the two infima are over the
  same set of shifts.
- **The triangle inequality — unconditionally.** For *any* three filtrations,

  > eInterleavingDist(*F*, *H*) ≤ eInterleavingDist(*F*, *G*) + eInterleavingDist(*G*, *H*).

  No hypothesis that the filtrations be interleavable. No exceptional cases. The
  law that broke over the real numbers now holds for *all* shapes, including the
  infinitely-far-apart ones.

Why does the infinity symbol rescue the triangle inequality so cleanly? Because of
a beautiful arithmetic fact: in the extended reals, **infinity absorbs addition**.
∞ + anything = ∞. So if either *F*-to-*G* or *G*-to-*H* is infinite, the right-hand
side of the triangle inequality is automatically infinite, and the inequality
holds trivially — *no detour can be shorter than an infinite leg of the journey,
but neither does an infinite leg make the bound fail.* And when both legs are
finite, the old composable-interleaving argument carries through unchanged: chain
the shifts, and δ + δ′ does the job. The empty-set case that was fatal over the
reals becomes the easiest case of all. The very feature that broke the ruler —
the existence of never-interleaved pairs — is now handled effortlessly by the one
new symbol.

## From a broken number to a genuine geometry

The reward for this repair is not merely a patched formula. It is a **theorem**,
and a conceptually deep one. Because the three axioms — diagonal-vanishing,
symmetry, and the triangle inequality — now all hold, the space of all
filtrations, equipped with eInterleavingDist, becomes a bona fide **extended
pseudometric space**. ("Pseudo" because two genuinely different filtrations might
still sit at distance zero if they happen to have identical shapes at every scale;
"extended" because distances are allowed to be infinite.)

In plain terms: **the abstract, purely logical relation of "interleaving" has been
faithfully represented as a concrete geometry.** What began as a relation — a
yes/no question, "are these two shapes within δ of each other?" — has become a
landscape, a space in which filtrations are *points* and the interleaving distance
measures how far apart they sit. Every theorem about metric spaces — convergence,
continuity, completeness, limits — is now available to talk about shapes-of-data.
This is the kind of bridge mathematicians prize most: a faithful translation
between two ways of seeing, the *relational* and the *metric*, with each
illuminating the other. The triangle inequality, a metric statement, turns out to
be nothing but the *shadow* of the composability of interleavings, a relational
statement. The geometry is the relation, seen from a different angle.

And the stability theorem rides along for free in its sharpest form. In this new
extended geometry, if two distance matrices are within ε of each other, their
Vietoris–Rips shapes are within ε in eInterleavingDist. To make this utterly
concrete, the theory includes a worked certificate on two tiny three-point clouds:
a perfect unit triangle, and a slightly puffed-up triangle whose sides are all
1.1 instead of 1. Every pairwise distance differs by exactly 0.1, and the theorem
delivers the guarantee that their persistent shapes differ by at most 0.1 — a
fully verified, end-to-end instance of "small change in data, small change in
shape," now living safely inside a real geometry rather than a broken one.

## Why this matters beyond the equations

It is tempting to see this as a technicality — a footnote about empty sets and
infinity symbols. It is the opposite. It is a parable about mathematical honesty.

A measuring instrument that reports zero when the truth is infinity is not merely
imprecise; it is *dangerous*, because it lies most exactly when the stakes are
highest, when two things are most different. The repair did not paper over the lie
with an extra hypothesis ("assume the shapes are interleavable"). It went deeper
and asked: *what number system does this quantity actually live in?* The answer —
the extended reals, where infinity is a first-class citizen — turned a quantity
that merely *resembled* a distance into one that *is* a distance, with no
caveats.

This pattern recurs across mathematics and science. Probabilities want to live on
[0, 1], not the whole real line. Lengths and masses want to be non-negative.
Information content wants a logarithm. Time, in relativity, wants a minus sign in
its metric. Again and again, choosing the right home for your numbers is not
bookkeeping — it is the moment the mathematics starts telling the truth. Here, by
giving the interleaving distance the freedom to say "infinity," the entire theory
of persistence stability snaps into place as a single, exception-free geometry of
shape.

The next time you hear that some method can tell whether two complex data sets
have "the same shape," remember the quiet drama beneath it: a ruler that once
confused *identical* with *infinitely different*, and the single extra symbol — ∞
— that taught it, at last, to tell them apart.
