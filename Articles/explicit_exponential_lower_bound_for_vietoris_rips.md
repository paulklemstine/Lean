# The Price of Approximation: Why Shrinking Data Shapes Hits a Wall at √2

## A shape hidden in a cloud of points

Imagine you are handed a scatter of points — the pixels of a scanned leaf,
the atoms in a protein, the readings from thousands of sensors. Buried in
that cloud is *shape*: loops, holes, voids, branches, the connective tissue
of the data. The central promise of the modern field of *topological data
analysis* is that this shape can be extracted, measured, and compared, even
when the raw data is noisy and high-dimensional.

The workhorse behind that promise is a beautifully simple construction. Fix a
scale $r$. Draw a ball of radius $r/2$ around every point, and whenever a
group of points is mutually close — every pair within distance $r$ — declare
that group to be a "filled-in" cell. A pair becomes an edge, a close triple
becomes a triangle, a close quadruple becomes a tetrahedron, and so on. As
you slowly turn the dial on $r$ from $0$ upward, these cells appear and merge,
and the loops and voids that persist across a wide range of scales are the
robust topological features of the data. This growing family of shapes is the
**Vietoris–Rips filtration**, and it is one of the most-used objects in all of
applied topology.

There is a catch, and it is a brutal one. If $r$ is large enough that all $n$
of your points are mutually close, then *every* subset of those points forms a
cell. The number of cells is $2^n$. Ten points can already generate more than
a thousand cells; fifty points generate more than a quadrillion. The very
construction that reveals the shape of data threatens to bury us under an
avalanche of combinatorial bookkeeping.

## The natural escape — and its mysterious limit

Faced with an exponential explosion, the natural instinct of a computer
scientist is to *approximate*. We don't need the exact filtration; we need
one that is close enough that the topological features it reports are the true
ones, only slightly blurred in scale. This is made precise by the notion of a
**$c$-approximation**: a smaller, "finitely presented" family of shapes $G(r)$
that tracks the true Vietoris–Rips filtration up to a multiplicative fudge
factor $c \ge 1$ in the scale parameter. Concretely, every genuine cell that
appears by scale $t$ must show up in $G$ by scale $c\,t$, and $G$ is never
allowed to invent a cell that the true filtration hasn't produced by scale
$c\,t$. The closer $c$ is to $1$, the more faithful the approximation.

Over the past fifteen years, a small industry of clever algorithms has grown
up to build such approximations with far fewer than $2^n$ cells. And these
algorithms all seem to run into the *same wall*. They can achieve a modest
approximation factor $c$ efficiently — but only up to a point. The magic
number where the efficient methods stop working is

$$c = \sqrt{2} \approx 1.414.$$

Above $\sqrt 2$, compact approximations are known. Below $\sqrt 2$, every known
method blows up again. Why $\sqrt 2$? And is the wall real, or just a failure
of imagination — could some future, cleverer algorithm break through it?

This article is about a result that shows the wall is **genuine**, pins down
its exact location, and — most strikingly — measures precisely how the cost of
crossing it grows as you push the approximation factor down from $\sqrt 2$
toward perfect fidelity.

## The main result, in plain terms

Here is the headline. There is a single, explicit family of tiny data sets —
one for each size $n$ — with the following property. Fix any approximation
quality $c$ strictly better than the threshold, that is, any $c \in [1,
\sqrt2)$. Then **every** $c$-approximation of the Vietoris–Rips filtration of
the $n$-point data set must store at least

$$2^{\lfloor \gamma(c)\cdot n\rfloor}$$

cells, where the exponent is governed by the *effective rate*

$$\gamma(c) \;=\; \frac{\sqrt2/c - 1}{\sqrt2 - 1}.$$

No cleverness helps: this is a lower bound on *any* approximation whatsoever,
not just the ones we happen to know how to build. The number of cells is
exponential in $n$, so no compact presentation exists below $\sqrt 2$.

The exponent $\gamma(c)$ is where the story becomes vivid. It is an honest,
computable number, and it does exactly what intuition demands:

- At $c = 1$ — a *perfect*, non-approximating summary — we get $\gamma(1) = 1$,
  recovering the full $2^n$ catastrophe.
- Throughout the whole regime $1 \le c < \sqrt 2$, the rate stays strictly
  positive, $0 < \gamma(c) \le 1$, so the blow-up is always genuinely
  exponential.
- As $c$ creeps up toward the threshold, $c \to \sqrt2^{-}$, the rate melts
  away continuously to zero, $\gamma(c) \to 0$.

That last point is the punchline. The guaranteed exponential rate does not
switch off abruptly at $\sqrt 2$; it *fades* to nothing exactly as you
approach the threshold, and no non-trivial rate survives at $c = \sqrt2$
itself. The mysterious barrier at $\sqrt 2$ turns out to be the precise place
where the exponential penalty vanishes. The wall is not a cliff — it is a
slope that becomes vertical exactly at $\sqrt 2$.

## How a wall is built out of a ruler

What kind of data set could force such behaviour? The construction is a small
marvel of economy: instead of points in space, we specify distances directly,
building a *graded* metric on $n$ labelled points.

Give each point $i$ (numbered $0, 1, \dots, n-1$) a personal **radius**

$$\text{radius}(n,i) \;=\; 1 + (\sqrt2 - 1)\cdot\frac{i+1}{n}.$$

As $i$ runs from $0$ to $n-1$, these radii sweep upward through the narrow
window $(1, \sqrt2\,]$, like the evenly spaced marks on a ruler stretched
between $1$ and $\sqrt2$. Now declare the distance between two *different*
points $i$ and $j$ to be the *larger* of their two radii:

$$d(i,j) \;=\; \text{radius}\big(n, \max(i,j)\big), \qquad d(i,i) = 0.$$

This rule looks almost too simple to be a distance, but it satisfies every
axiom a metric must obey — symmetry, positivity, zero exactly on the diagonal
— and it satisfies something even stronger. Because every non-zero distance is
just a single radius value, the distance from $i$ to $k$ can never exceed the
larger of the two "legs" $d(i,j)$ and $d(j,k)$. That is the *ultrametric*
inequality, a super-charged triangle inequality familiar from the world of
$p$-adic numbers and hierarchical clustering. The graded metric is not just a
metric; it is an ultrametric, and the whole non-zero distance spectrum lives
snugly inside the interval $[1, \sqrt2]$.

The ruler is the engine. Fix a working scale $s$. The points whose radius is
at most $s$ form what we call the **active set** at scale $s$. Because
distances are governed by the *larger* index, any two active points are
automatically within $s$ of each other: the active set is a *clique* — a group
that is mutually close at scale $s$. And here the exponential explosion is
reborn on purpose: a mutually-close clique of $m$ points forces *all* $2^m$ of
its subsets to be genuine cells of the Vietoris–Rips complex. Its entire power
set is present. Geometry has been converted, cleanly and without waste, into
exponential combinatorics.

## Turning the crank

The final step is to combine the ruler with the definition of approximation,
and out drops the exponent. Suppose $G$ is any $c$-approximation. Choose the
working scale $s = \sqrt2 / c$. Two facts collide:

1. Because $G$ is a $c$-approximation, every genuine cell present at scale
   $\sqrt2/c$ must appear in $G$ by scale $c \cdot (\sqrt2/c) = \sqrt2$. So all
   the cells of the active clique at scale $\sqrt2/c$ are forced into the
   single snapshot $G(\sqrt2)$.
2. How big is that active clique? A point $i$ is active at scale $\sqrt2/c$
   exactly when $1 + (\sqrt2 - 1)(i+1)/n \le \sqrt2/c$, which rearranges to
   $i + 1 \le n\,\gamma(c)$. The number of qualifying points is therefore
   $\lfloor n\,\gamma(c)\rfloor$.

Put the two together: $G(\sqrt2)$ must contain the entire power set of an
active clique of size $\lfloor n\,\gamma(c)\rfloor$, and hence

$$\big|\,G(\sqrt2)\,\big| \;\ge\; 2^{\lfloor n\,\gamma(c)\rfloor}.$$

That is the whole argument. A graded ruler between $1$ and $\sqrt2$ picks out
an active clique whose size is dialed precisely by the approximation factor;
the clique forces its full power set into the approximation; and the count of
that power set is the exponential lower bound. The value of $c$ enters in
exactly one place — the length of the ruler segment that stays active — and
that is why $c$, and only $c$, controls the exponent through $\gamma(c)$.

## Why $\sqrt 2$, really

The number $\sqrt2$ is not arbitrary; it is the geometric heartbeat of the
whole subject. Take the corners of a right-angled configuration — the standard
unit directions in space — and any two of them sit at distance exactly
$\sqrt2$. This is the smallest scale at which a "spread-out" cluster suddenly
becomes fully connected, and it is the reason the Vietoris–Rips construction
has a natural $\sqrt2$ resonance. Our graded ruler is engineered to live in
precisely the danger zone $[1, \sqrt2]$ where this resonance operates. Squeeze
the approximation factor below $\sqrt2$ and you are demanding fidelity inside
that zone; the construction responds with an exponential number of cells. Relax
it to $\sqrt2$ and the active window shrinks to a single point — the rate
$\gamma$ hits zero — and the pressure is released. The threshold and the
vanishing of the rate are two faces of the same coin.

## What this means for practice

For anyone who computes with the shape of data, the result is a piece of
hard-won honesty. It says: **do not go hunting for a below-$\sqrt2$
approximation algorithm that is small on all inputs.** No such algorithm can
exist, and the reason is not subtle inefficiency but a fundamental
combinatorial obstruction that we can now write down in closed form. The good
news travels with the bad: because $\gamma(c) \to 0$ as $c \to \sqrt2$, the
penalty for approximation factors *just* below the threshold is mild — the
guaranteed blow-up rate is small — so the practically important regime of
"barely sub-$\sqrt2$" approximations is exactly the regime where the lower
bound is gentlest. The theory draws a sharp, quantitative map of where effort
is wasted and where it can still pay off.

More broadly, the argument is a small showcase of how three different
mathematical worlds can meet on a single object. Metric geometry supplies the
graded ultrametric. Extremal combinatorics supplies the clique-to-power-set
counting engine. And the interleaving theory that underpins approximation
algorithms supplies the bridge that converts "close filtrations" into "many
stored cells." The $\sqrt2$ threshold is where all three speak at once — and,
now, where they agree on an exact answer.

## The shape of the answer

Thresholds are the punctuation marks of mathematics: the places where behaviour
changes character, where "possible" turns into "impossible." For years, $\sqrt2$
has been folklore in topological data analysis — the scale where efficient
approximation was believed to end. The result described here turns folklore into
theorem. It exhibits an explicit family of data sets, an explicit and vanishing
rate $\gamma(c) = (\sqrt2/c - 1)/(\sqrt2 - 1)$, and a clean three-line argument
that forces $2^{\lfloor n\,\gamma(c)\rfloor}$ cells into any $c$-approximation
below the threshold. The wall at $\sqrt2$ is real, we can see exactly how it is
built, and we can measure precisely how steeply it rises as we lean against it.
