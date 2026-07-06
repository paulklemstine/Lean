# Counting the Shapes of Symmetry: When Maps Become Graphs

## A puzzle about perfect symmetry

Imagine you are handed a mysterious, highly symmetric object — a tiling of a
surface, a polytope, or some higher-dimensional honeycomb — and told that it is
*perfectly regular*: every local piece looks exactly like every other, and the
object's symmetries can carry any piece onto any other in exactly one way. How
many such objects are there? Can you list them all?

This sounds like an impossibly open-ended question. Regular structures come in
bewildering variety, and the higher the dimension, the harder they are to
picture. Yet there is a beautiful strategy that mathematicians use again and
again: **turn the geometric object into a graph, and count the graphs instead.**
Graphs — dots joined by lines — are among the most thoroughly catalogued objects
in all of mathematics. If we can faithfully encode our elusive symmetric shapes
as graphs of a particular, recognizable type, then a shelf full of existing
graph catalogues suddenly becomes a classification of the shapes.

This article is about one clean, rigorous step in exactly that program. The
shapes in question are called *regular 4-maniplexes*, and the graphs they turn
into are *tetravalent* graphs — graphs in which every vertex has exactly four
lines coming out of it. The step we make precise and prove here is the linchpin
that makes the whole translation possible: we show, from first principles, that
the graph attached to such an object is guaranteed to be four-valent, no
exceptions.

## From flags to involutions

To describe a symmetric shape combinatorially, mathematicians break it into its
smallest indivisible pieces, called **flags**. In a polygon, a flag is a
(vertex, edge) pair sitting together; in a polyhedron, a flag is a (vertex,
edge, face) triple; and in general, a *rank-$n$* object has flags that are
maximal nested chains of faces of every dimension from $0$ up to $n-1$.

Here is the key structural fact that powers everything. Given a flag, there is,
for each dimension $i$, exactly **one** other flag that agrees with it in every
respect *except* the $i$-dimensional piece. Swapping to that unique neighbor is
an operation we call $\sigma_i$. These swaps have three striking properties:

- **They are involutions.** Applying $\sigma_i$ twice returns you to where you
  started: $\sigma_i(\sigma_i(x)) = x$. Swapping the $i$-piece and then swapping
  it back changes nothing.
- **They have no fixed points.** A flag always genuinely moves under $\sigma_i$,
  because there is always a *different* flag sharing all the other pieces:
  $\sigma_i(x) \neq x$.
- **Distant swaps commute.** If two dimensions $i$ and $j$ are far apart — more
  precisely, if they differ by at least $2$ — then changing the $i$-piece and
  changing the $j$-piece do not interfere: $\sigma_i(\sigma_j(x)) =
  \sigma_j(\sigma_i(x))$. This is the famous *string* condition, and it is what
  makes these objects "string" maniplexes.

A **rank-$n$ maniplex** is, at heart, nothing more than a set of flags equipped
with $n$ such swaps $\sigma_0, \sigma_1, \dots, \sigma_{n-1}$ obeying these
rules. A **4-maniplex** is the rank-4 case: four swaps $\sigma_0, \sigma_1,
\sigma_2, \sigma_3$. This is the abstract combinatorial skeleton of a
four-dimensional regular structure, stripped of all geometry and reduced to pure
symmetry data.

## Building the flag graph

Now we make a graph. The **flag graph** has one vertex for each flag, and we
join two flags by an edge whenever one is obtained from the other by a single
swap. Formally, flags $v$ and $w$ are adjacent exactly when

$$w = \sigma_i(v) \quad \text{or} \quad v = \sigma_i(w) \quad \text{for some } i.$$

Because each $\sigma_i$ is its own inverse, these two conditions are really the
same relation viewed from both ends, so the graph is undirected. Because no swap
fixes a flag, the graph has no loops. What could its vertices' degrees be?

Intuitively, each flag $v$ has one neighbor for each dimension: $\sigma_0(v),
\sigma_1(v), \sigma_2(v), \sigma_3(v)$. That is four neighbors, so the graph
*ought* to be four-valent. But there is a subtlety that a careful reader — and a
careful proof — must not skip: **what if two different swaps happen to send $v$
to the same place?** If $\sigma_1(v)$ equalled $\sigma_2(v)$, then $v$ would have
fewer than four distinct neighbors, and the count would collapse. To guarantee
four-valence we need to know the four images are genuinely distinct.

## The theorem

This is precisely the gap our main result closes. We isolate the essential
hypotheses into a clean, dimension-agnostic package. Fix a set of objects
(call it the flag set), and suppose we are given $n+1$ maps
$\sigma_0, \dots, \sigma_n$ on it such that:

1. each $\sigma_i$ is an involution ($\sigma_i \circ \sigma_i = \mathrm{id}$);
2. each $\sigma_i$ is fixed-point-free ($\sigma_i(x) \neq x$ for all $x$);
3. non-adjacent maps commute (if $|i - j| \geq 2$ then $\sigma_i \circ \sigma_j
   = \sigma_j \circ \sigma_i$); and
4. **the images are separated:** for any single object $v$ and any two distinct
   indices $i \neq j$, we have $\sigma_i(v) \neq \sigma_j(v)$.

Call such a package an **involution family** of size $n+1$. From it we build the
graph exactly as above: $v$ and $w$ are adjacent when some $\sigma_i$ carries one
to the other.

> **Theorem (Regularity of the involution-family graph).** *For a finite flag
> set, the graph induced by an involution family of size $n+1$ is regular of
> degree $n+1$: every vertex has exactly $n+1$ neighbors.*

The proof is a small gem of bookkeeping. Fix a vertex $v$. Its neighbors are, by
definition, precisely the objects of the form $\sigma_i(v)$ — because if $v =
\sigma_i(w)$, then applying $\sigma_i$ to both sides and using that it is an
involution shows $w = \sigma_i(v)$ as well. So the neighbor set of $v$ is exactly
the image of the map $i \mapsto \sigma_i(v)$ ranging over the $n+1$ indices.
Hypothesis (4) says this map is injective: distinct indices give distinct
images. An injective map from a set of size $n+1$ has an image of size exactly
$n+1$. Therefore $v$ has precisely $n+1$ neighbors, and since $v$ was arbitrary,
the graph is $(n+1)$-regular. $\blacksquare$

Setting $n = 3$ — four swaps, the rank-4 case — gives the headline consequence:

> **Corollary.** *The flag graph of a 4-maniplex is tetravalent: every vertex
> has exactly four neighbors.*

## Why this is the keystone

At first glance, proving "the graph is four-valent" might look like a footnote.
It is anything but. It is the hinge on which an entire classification program
swings.

The grand conjecture behind this work is that **the perfectly regular
4-dimensional structures are in exact one-to-one correspondence with the
tetravalent graphs in existing censuses.** In one direction, each regular
4-maniplex hands you its flag graph, which — by the corollary above — lands
inside the world of four-valent graphs. In the other direction, a four-valent
graph carrying the right extra structure (its edges colored by four "swap
colors," with the string condition encoded locally) reconstructs a unique
maniplex. If both directions hold, then *counting regular 4-maniplexes is the
same as counting the relevant tetravalent graphs* — and those have already been
enumerated, vertex count by vertex count, in painstakingly assembled censuses.

For that bridge to be trustworthy, the very first plank must be solid: the flag
graph must *always* be four-valent, with no accidental coincidences reducing a
vertex's degree. The theorem above certifies exactly that, and it does so at the
level of generality where it belongs — for any rank, from the same four clean
axioms.

## A hidden dividend: everything is even

The involution structure carries a bonus that has nothing to do with graphs and
everything to do with counting. Because each swap $\sigma_i$ is a fixed-point-free
involution, it pairs up the flags into disjoint two-element orbits: $x$ with
$\sigma_i(x)$, forever. A set that can be partitioned into pairs must have an
*even* number of elements. So **every 4-maniplex has an even number of flags** —
in fact, its flag count is divisible by high powers of two once you account for
several independent pairings at once.

The small regular examples make this vivid. Their flag counts run $120$, $384$,
$1152$, $14400$ — and every one of these is divisible by $24$. This is not a
coincidence but a shadow of the same pairing phenomenon, hinting at sharper
divisibility laws (divisibility by $8$ always, by $24$ in the regular case) that
the four-involution structure quietly enforces.

## The bigger picture

What makes this story satisfying is how a purely local rule — "each flag has one
unique neighbor per dimension, and those neighbors are all different" — pins
down a global numerical fact — "the graph is exactly four-valent" — which in turn
unlocks a *classification* by handing the problem to a catalogue someone else
already built. It is mathematics as translation: recast a hard, high-dimensional
question about symmetry as an easy, well-studied question about graphs, verify
the dictionary entry by entry, and let existing knowledge do the rest.

The four-valence theorem is one dictionary entry, stated and proved with full
rigor. It is small, but it is load-bearing. And it generalizes without effort:
the same argument shows a rank-$n$ structure yields an $n$-valent graph, so the
same translation strategy stands ready for symmetric shapes in every dimension.
Count the graphs, and you have counted the shapes.
