# The Price of Shape: Why Some Data Refuses to Be Compressed

## A shape hidden in a cloud of points

Imagine you are handed a cloud of points — the pixels of an image, the readings
of a sensor network, the genetic profiles of a population. Buried in that cloud
is *shape*: clusters, loops, voids, tendrils. The modern toolkit for extracting
that shape is called *topological data analysis*, and its workhorse is a
beautifully simple construction called the **Vietoris–Rips complex**.

The recipe is this. Pick a distance scale $r$. Look at your points. Whenever a
group of points is *mutually* close — every pair within distance $r$ — declare
that group a "simplex," a filled-in triangle, tetrahedron, or
higher-dimensional analogue. As you slowly turn the dial on $r$ from small to
large, more and more simplices switch on. Loops appear and later fill in; voids
open and later close. The record of *when* each feature is born and dies is a
fingerprint of the data's shape, and it is remarkably robust to noise.

There is only one problem, and it is a serious one: the Vietoris–Rips complex
can be *enormous*. With $n$ data points, the number of simplices can reach
$2^n$ — for a mere $100$ points, that is more simplices than there are atoms in
the observable universe. So the central engineering question of the field is:
**can we cheat?** Can we build a smaller structure that captures *almost* the
same shape — say, one that is faithful up to a small stretching factor $c$ of
the distance scale?

This article is about a sharp and slightly humbling answer: **below a certain
threshold, you cannot cheat at all.** The threshold is the number $\sqrt{2}
\approx 1.414$, and the reason is a chain of ideas connecting geometry, graph
theory, and information theory into a single argument.

## The simplest hard example: points that are all equally far apart

To prove that something is *impossible in general*, mathematicians reach for the
cleanest possible worst case. Here it is: take $n$ points that are **all the same
distance apart**. Every pair is at distance exactly $d$; there are no near
neighbors and no far strangers, just perfect symmetry.

Does such a configuration actually exist in real geometry? Yes — beautifully so.
Take the $n$ standard unit vectors in $n$-dimensional Euclidean space:
$(1,0,\dots,0)$, $(0,1,0,\dots,0)$, and so on. Any two of them differ in exactly
two coordinates, one becoming $1$ and the other becoming $0$, so the distance
between any two is
$$\sqrt{1^2 + 1^2} = \sqrt{2}.$$
These $n$ points form a perfect equidistant cloud, all pairs at distance exactly
$\sqrt{2}$. This is why $\sqrt{2}$ is not an arbitrary number in this story: it is
the natural separation of the most symmetric point cloud in Euclidean space.

Now watch what the Vietoris–Rips construction does to this cloud. Set the scale
to $r = \sqrt{2}$. Every pair of points is within range, so **every** subset of
points is mutually close — every subset is a simplex. The Vietoris–Rips complex
is the *entire* collection of subsets of an $n$-element set, and there are
exactly $2^n$ of those. The equidistant cloud is the maximally expensive case:
it fills in completely, all at once.

## From geometry to graphs: the clique dictionary

Here is the first of three bridges. Turn the point cloud into a **graph**: draw a
vertex for each point, and connect two points with an edge whenever they are
within the scale $r$. Call this the *proximity graph*.

A remarkable fact — so clean it deserves to be called a dictionary — is that the
Vietoris–Rips complex is *exactly* the collection of **cliques** of this graph. A
clique is a set of vertices that are all pairwise connected: a fully-connected
club. A set of points is a Vietoris–Rips simplex precisely when all its pairs are
close, which is precisely when they form a clique in the proximity graph.

> **The Clique Dictionary.** For any dissimilarity $D$ and scale $r$ (with each
> point within $r$ of itself), the Vietoris–Rips complex at scale $r$ is
> identical to the set of all cliques of the proximity graph at scale $r$.

This translation is powerful because it moves a geometric question into the
well-developed language of *extremal graph theory* — the study of how large
graph-theoretic quantities can get.

And extremal graph theory answers our counting question instantly. How many
cliques can a graph on $n$ vertices have? Every clique is in particular *some*
subset of the $n$ vertices, and there are $2^n$ subsets, so:

> **The Extremal Bound.** Any graph on $n$ vertices has at most $2^n$ cliques.
> Equality holds precisely for the *complete graph* — the one where every pair is
> connected — in which every one of the $2^n$ subsets is a clique.

Our equidistant cloud at scale $\sqrt{2}$ produces exactly the complete graph, so
it hits this ceiling: exactly $2^n$ cliques, the extremal maximum. The most
symmetric geometry corresponds to the most connected graph, which carries the
most cliques. The three "extremes" line up perfectly.

## From counting to bits: the information-theoretic floor

Now the second bridge, into **information theory**. Suppose you want to store, or
transmit, or even just *address* a collection of $M$ objects. How many bits do
you need? To give each object a distinct binary label you need $\lceil \log_2 M
\rceil$ bits — no fewer. This quantity, the *bit complexity* of the collection,
is the honest description-length cost of the data.

For our equidistant cloud, the collection at the critical scale has $M = 2^n$
members, so its bit complexity is exactly $n$ bits. That is the floor: you cannot
describe this level of the complex in fewer than $n$ bits, because there are
genuinely $2^n$ distinct things to name.

The formal backbone of this step is a small pair of facts about the ceiling
logarithm. First, $\lceil \log_2 M \rceil$ bits always suffice: $M \le 2^{\lceil
\log_2 M\rceil}$. Second, and this is the one we need, if a collection has at
least $2^k$ members then its bit complexity is at least $k$. Applied with
$M = 2^n$, this pins the cost at no less than $n$ bits.

## Putting it together: you cannot cheat below √2

Now the payoff. An *approximation* of the Vietoris–Rips filtration — the thing an
efficient algorithm actually builds — is a family of complexes $G(t)$, one for
each scale, that is *interleaved* with the true filtration up to a stretch factor
$c \ge 1$. Concretely, the true complex at scale $t$ must sit inside $G(ct)$, and
$G(t)$ must sit inside the true complex at scale $ct$. The smaller $c$ is, the
more faithful the approximation.

Run this against the equidistant cloud. The true complex at scale $d$ has all
$2^n$ simplices, and it must be contained in $G(cd)$. Containment forces $G(cd)$
to have at least $2^n$ simplices too. And by the information-theoretic floor,
that level costs at least $n$ bits.

> **The Lower Bound.** Every $c$-approximation of the Vietoris–Rips filtration of
> the equidistant cloud has a level containing at least $2^n$ simplices, and
> therefore requiring at least $n$ bits of storage. No approximation, however
> clever, can escape the exponential blow-up on this configuration.

Why is $\sqrt{2}$ the threshold? Because the sharp exponential rate is governed
by the quantity
$$\gamma(c) = \tfrac{1}{2} - \log_2 c.$$
When $c = 1$ (exact representation) this is $\tfrac12$; it decreases as the
allowed stretch $c$ grows, and it stays strictly positive for every $c$ in the
whole range $1 \le c < \sqrt{2}$, hitting zero exactly at $c = \sqrt{2}$ (since
$\log_2 \sqrt 2 = \tfrac12$). A positive exponent $\gamma(c)$ means the cost
grows like $2^{\gamma(c)\, n}$ — genuinely exponential. Only once you are willing
to tolerate a stretch of $\sqrt{2}$ or more does the exponent vanish and the door
to compression finally open. This is why practical algorithms that *do* compress
Vietoris–Rips complexes always work at coarser scales: they are living on the
right side of the $\sqrt{2}$ wall.

## Three subjects, one wall

What makes this story satisfying is not any single step — each is elementary —
but the way three subjects snap into alignment at the same object:

- **Geometry** hands us the equidistant cloud, the most symmetric point set,
  realized concretely by the standard basis vectors at mutual distance $\sqrt2$.
- **Extremal graph theory** recognizes its proximity graph as the complete
  graph, the unique maximizer of the clique count, achieving the ceiling $2^n$.
- **Information theory** reads that count as $n$ irreducible bits, a hard floor on
  description length.

The same number, $2^n$, is simultaneously a *maximum* (of cliques), a *count* (of
simplices), and an *exponential of a bit-cost* ($n$ bits). The equidistant cloud
is the point where the geometric extreme, the graph-theoretic extreme, and the
information-theoretic extreme are the *same* extreme.

## Why it matters

Impossibility results are the guardrails of a field. Knowing that no algorithm
can compress the Vietoris–Rips filtration below the $\sqrt{2}$ threshold tells
practitioners exactly where *not* to spend their effort, and exactly what
tolerance they must accept to gain any compression at all. It reframes a
practical bottleneck — "our complexes are too big" — as a precise mathematical
law: below $\sqrt2$, the bits are simply there, and no encoding can wish them
away.

The deeper lesson is one that recurs throughout mathematics: hard problems often
have a single, symmetric worst case, and understanding that one case through as
many lenses as possible — geometric, combinatorial, information-theoretic — turns
a vague difficulty into an exact, quotable theorem. The equidistant cloud is
small, symmetric, and completely explicit, and yet it is the immovable object
against which every clever compression scheme, below the $\sqrt2$ threshold, must
break.
