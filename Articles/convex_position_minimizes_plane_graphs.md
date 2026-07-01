# When Fewer Crossings Means Fewer Graphs: The Surprising Frugality of the Convex Polygon

Take a handful of pins and press them into a corkboard, no three of them ever
lining up in a perfect row. Now start connecting them with straight strands of
thread, but obey one rule: **no two strands may cross.** How many different
tangle-free patterns can you make?

This innocent-sounding question hides one of the more tantalizing puzzles in
combinatorial geometry. The number of crossing-free straight-line graphs — call
them **plane graphs** — depends dramatically on *where* the pins are. Scatter
them one way and you can weave an astronomically large number of patterns.
Scatter them another way and your options shrink. The central mystery is: **which
arrangement of $n$ pins gives you the *fewest* possible tangle-free patterns?**

The long-standing conjecture, and the subject of this article, is beautifully
crisp: **the fewest plane graphs occur when the points sit in convex position** —
that is, when every pin lies on the boundary of their common convex hull, like the
vertices of a regular polygon. Convexity, the most "spread-out" and orderly
configuration imaginable, is conjectured to be the stingiest.

At first glance this feels backwards. Convex position looks so *clean*. Shouldn't
clean mean *more* structure, more patterns? The resolution of that paradox is the
heart of the story.

## Counting the patterns

Let's make the question precise. Place $n$ points in the plane in **general
position**: no three of them collinear. A **plane graph** is any set of straight
segments joining pairs of these points such that no two segments cross in their
interiors. (Segments sharing an endpoint are fine; that's a shared corner, not a
crossing.) The empty pattern counts. The single-edge patterns count. Full
triangulations count. We tally *all* of them.

When the points are in convex position, something wonderful happens: the geometry
collapses into pure combinatorics. Label the points $0, 1, \dots, n-1$ as they
appear around the hull. A segment is now just a **chord** — a pair $\{i,j\}$ with
$i < j$. And two chords $\{a,b\}$ and $\{c,d\}$ cross **if and only if their
endpoints interleave** around the circle:
$$a < c < b < d \quad \text{or} \quad c < a < d < b.$$
No coordinates, no slopes, no determinants — crossing has become a statement about
the *cyclic order* of four labels. This is the special magic of convex position,
and it is what makes the convex case computable at all.

Let $N(n)$ denote the number of plane graphs on $n$ convex points. Patiently
enumerating the small cases gives
$$N(0)=1,\; N(1)=1,\; N(2)=2,\; N(3)=8,\; N(4)=48,\; N(5)=352,\;\dots$$
a sequence that climbs like clockwork. Its growth rate is known to be exponential,
$$N(n) \approx c \cdot n^{-3/2}\cdot \beta^n, \qquad \beta \approx 11.65.$$
So a convex $50$-gon already admits more plane graphs than there are atoms in a
galaxy.

## The paradox, resolved by triangles

Here is why convex position is *frugal* rather than lavish. The number of plane
graphs is governed, in a precise sense, by how many **triangulations** the point
set admits — the maximal tangle-free patterns that chop the whole figure into
triangles. Every triangulation is itself a plane graph, and — crucially — **every
subset of a plane graph is again a plane graph.** Delete any strands you like from
a valid pattern and you still have a valid pattern. So a single triangulation with
$E$ edges instantly spawns $2^E$ plane graphs: one for each subset of its edges.

Now count edges. Euler's formula for a triangulated point set with $n$ points, of
which $h$ lie on the convex hull, gives a triangulation exactly
$$E = 3n - 3 - h$$
edges. Read that formula carefully: **the more points on the hull, the fewer edges
in each triangulation.** When the hull is large, the boundary "uses up" points
that could otherwise sit in the interior and spawn extra internal edges.

Convex position is the extreme case $h = n$: *every* point is on the hull. That
leaves the smallest possible edge count, $E = 3n - 3 - n = 2n - 3$, and therefore
the smallest guaranteed cache of $2^{E}$ plane graphs. Push points into the
interior — shrink the hull to size $h < n$ — and each triangulation grows to
$3n-3-h > 2n-3$ edges, guaranteeing *strictly more* plane graphs. The orderliness
of convexity is exactly what starves it of interior triangles.

This is the mechanism the conjecture rests on, and we can make one clean piece of
it completely rigorous.

## What we can prove, precisely

**A universal doubling principle.** For *any* plane graph $F$ on our points, the
total number of plane graphs is at least $2^{|F|}$, because the $2^{|F|}$ distinct
subsets of $F$ are all plane. This turns "find one good pattern" into "get an
exponential horde for free."

**Two concrete exponential floors for the convex $n$-gon.**

- *The star.* Join vertex $0$ to every other vertex. These $n-1$ chords all share
  the endpoint $0$, so no two of them can interleave — the star is plane. Its
  subsets give
  $$N(n) \ge 2^{\,n-1}.$$

- *The fan.* Take the star and add all $n$ boundary edges $\{k, k{+}1\}$. A
  boundary edge hugs two neighbors and leaves no room for an endpoint to slip
  between them, so it crosses nothing. The result is a full triangulation with
  $2n-3$ edges, and hence
  $$N(n) \ge 2^{\,2n-3}.$$
  This floor is *exactly tight* at $n=3$, where $2^{2\cdot 3 - 3} = 2^3 = 8 = N(3)$
  — reassuring proof that the model is faithful and the bound is no accident.

**The arithmetic heart of the conjecture.** Define the triangulation-subset floor
for a configuration with hull size $h$ to be $L(n,h) = 2^{\,3n-3-h}$. Then, as a
function of the hull size, $L(n,h)$ is *strictly decreasing* in $h$ and attains its
**minimum precisely at $h = n$**, convex position. In one clean inequality this
captures the paradox: among all guaranteed floors, convexity's is the lowest.
Every departure from convexity provably raises the floor.

## The evidence beyond the floor

The floors above are honest but modest: $2^{2n-3} \approx 2.83^n$, far below the
true convex growth rate of $\approx 11.65^n$. Does the *actual* count also favor
convexity? Here the evidence sharpens into something striking.

Suppose a configuration is *far* from convex — its hull contains only a
vanishingly small fraction of the points, of order $n / \log n$. Then the sheer
number of ways to triangulate its crowded interior forces the plane-graph count up
to $\Omega(12.24^n)$. Compare that with convex position's $\approx 11.65^n$: the
non-convex configuration has **strictly, exponentially more** plane graphs. So at
the two ends of the spectrum — maximally convex versus maximally clustered — the
inequality points firmly in the conjecture's direction. Convex position, the
sparse-interior extreme, sits at the bottom.

## A hidden coin flip

There is one more delightful gem. Consider any single hull edge — a segment
between two neighboring extreme points. Because it lies on the very boundary of the
figure, *nothing* can cross it. So in any plane graph you may toggle that edge on
or off freely, and the result is still plane. Toggling is a perfect pairing of
patterns: each plane graph *with* the edge is matched to exactly one *without* it,
and vice versa, with no pattern ever paired to itself.

A pairing with no fixed points means the patterns come in twos — so **the number of
plane graphs is always even** (for $n \ge 2$). A parity fact, falling out of pure
geometry, with a one-line proof. And it hints at something larger: if a single hull
edge acts as an independent on/off switch, perhaps *all* $h$ hull edges act as $h$
independent switches, multiplying the count by $2^h$. That is one of the bold
conjectures this line of work now puts on the table.

## Why it matters

Extremal questions like this one — *which configuration minimizes or maximizes some
count?* — are the load-bearing walls of discrete geometry. Triangulations and
crossing-free graphs are not abstract curiosities: they underpin mesh generation in
engineering, terrain modeling in geography, wireless network design, and the
data structures that make computational geometry fast. Knowing which point sets are
"poor" in crossing-free structures and which are "rich" tells algorithm designers
where the hard and easy instances live.

And the aesthetic payoff is real. The claim that the humble convex polygon — the
first shape any child draws — is the unique global minimizer of a wildly
exponential count is the kind of statement mathematics exists to chase. We have
pinned down its mechanism, proved its arithmetic core, bracketed the extremes, and
uncovered an unexpected parity along the way. The summit — a proof that convex
position minimizes the count for *every* $n$ — remains unclimbed. But the route is
now marked, and the view from the ridge is spectacular.
