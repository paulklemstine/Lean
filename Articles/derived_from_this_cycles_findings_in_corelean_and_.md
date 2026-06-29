# Counting Connections: How a Single Growing Number Reveals the Shape of Data

## A dial, a cloud of points, and the moment everything connects

Imagine you are handed a fistful of stars — a scattering of points floating in
space — and a single dial. The dial controls a distance. When you turn it up,
you draw a line between every pair of points that happen to be closer than the
dial's current setting. Turn the dial all the way down and you see nothing but
isolated dust. Turn it up and lines flicker into existence, one by one, until
finally every point is joined to every other and the whole cloud blazes as a
single connected web.

This little game — points, a dial, and lines that appear as distances shrink
below a threshold — is one of the most important ideas in modern data science.
It is the engine behind **topological data analysis (TDA)**, a field that tries
to recover the *shape* of a dataset: its loops, its clusters, its voids. The
growing web of lines is called the **Vietoris–Rips graph**, named after two
early-twentieth-century topologists, and the act of slowly turning the dial is
called building a **filtration**.

There is a deceptively simple quantity hiding in this picture, one you can read
off at every setting of the dial without any heavy machinery: *how many lines
are currently drawn?* Call it the **edge count**. As the dial turns up, the
edge count can only grow — lines never disappear once drawn. Plot the edge count
against the dial setting and you get a staircase that climbs from zero up to its
maximum. That staircase is the **edge-count profile**, and it turns out to be a
small, robust, and surprisingly informative fingerprint of your data.

This article is about that staircase: what it is, the precise rules it obeys, and
why those rules — humble as they look — make the edge count a genuine
*structure-preserving* summary of geometric data.

## The construction, made precise

Let us pin down the objects. Suppose you have a finite collection of points,
and any two of them, $x$ and $y$, have a well-defined distance $d(x, y)$. (We
ask only that distances behave sensibly: a point is at distance zero from
itself, distances are symmetric, and the triangle inequality holds. Such a
collection is called a *metric space*.)

For each setting $\varepsilon$ of the dial, define a graph — a network of nodes
and links — called the **Rips graph at scale $\varepsilon$**:

> The nodes are the points of your space. Two *distinct* nodes $x$ and $y$ are
> joined by an edge exactly when $d(x, y) \le \varepsilon$.

That is the whole definition. The points within reach of one another at the
current dial setting get connected; everyone else stays apart.

The **edge count at scale $\varepsilon$** is simply the number of edges in this
graph. As a function of the dial, this gives the **edge-count profile**: a map
that takes a threshold and returns a whole number, the population of links at
that threshold.

Three facts about this profile turn it from a curiosity into a tool. Each is a
theorem that has been verified down to the last logical step.

## Fact one: the staircase only ever climbs

**Monotonicity.** *If $\varepsilon_1 \le \varepsilon_2$, then the edge count at
$\varepsilon_1$ is at most the edge count at $\varepsilon_2$.*

This is the formal statement of the intuition that lines never vanish as you
widen the dial. The reasoning is a two-step chain. First, turning the dial up
can only *add* edges: if $d(x, y) \le \varepsilon_1$ and
$\varepsilon_1 \le \varepsilon_2$, then certainly $d(x, y) \le \varepsilon_2$,
so every edge present at the smaller scale is still present at the larger one.
The Rips graph at $\varepsilon_1$ is therefore a *subgraph* of the one at
$\varepsilon_2$. Second, a subgraph cannot have more edges than the graph
containing it. Put together: the edge count is **monotone** — a nondecreasing
function of the scale.

This is the spine of the whole story. A monotone staircase is exactly the kind
of object that *persistence* — the "P" in persistent homology — is built to
read. The places where the staircase jumps are the scales at which new structure
snaps into place.

## Fact two: it starts at the floor and never exceeds the ceiling

Two boundary facts bracket the staircase from below and above.

**Empty at the start.** *At threshold $0$, the edge count is exactly zero.*

In a genuine metric space, two *different* points always sit a strictly positive
distance apart. So at dial setting $0$, no pair qualifies for an edge: the graph
is empty, and the edge count is $0$. The staircase begins on the floor.

**Bounded at the top.** *At every threshold, the edge count never exceeds the
total number of unordered pairs of points.*

You can only ever draw a line between two points, and there are only finitely
many pairs to choose from. So no matter how far you turn the dial, the edge
count is capped by the number of available pairs — for $n$ points, that ceiling
is at most $\tfrac{n(n-1)}{2}$ genuine pairs of distinct points. The staircase
climbs, but it cannot climb forever; it levels off once every pair is connected.

Together these say the profile lives in a finite box: it starts at $0$, rises
monotonically, and saturates at a value determined purely by the number of
points. Everything interesting happens in *where* and *how fast* it climbs.

## Fact three: shrinking maps shrink the staircase

The richest fact is about *relationships between datasets*. Suppose you have two
point clouds, call them $\alpha$ and $\beta$, and a way of placing the first
inside the second: a map $f$ that sends each point of $\alpha$ to a point of
$\beta$. Suppose this map has two virtues:

- It is **injective** — distinct points of $\alpha$ go to distinct points of
  $\beta$. Nothing is glued together.
- It is **nonexpanding** — it never stretches distances. For any two points,
  $d\big(f(x), f(y)\big) \le d(x, y)$. The image is, if anything, more huddled
  together than the original.

Such a map is a faithful, possibly-compressing embedding of one cloud into
another. The theorem says:

**Domination.** *If $f : \alpha \to \beta$ is injective and nonexpanding, then
at every scale the edge count of $\alpha$ is at most the edge count of $\beta$.*

Here is why. Take any edge of $\alpha$ at scale $\varepsilon$: a pair $x, y$ with
$x \ne y$ and $d(x, y) \le \varepsilon$. Apply $f$. Because $f$ is injective,
$f(x) \ne f(y)$ — the edge does not collapse into a single point. Because $f$ is
nonexpanding, $d(f(x), f(y)) \le d(x, y) \le \varepsilon$ — the images are still
close enough to be joined. So the image $\{f(x), f(y)\}$ is a genuine edge of
$\beta$ at the *same* scale. Distinct edges of $\alpha$ map to distinct edges of
$\beta$ (again because $f$ is injective). We have packed all of $\alpha$'s edges
into $\beta$'s edge set without collisions, so $\beta$ has at least as many.

Read this as a statement about *information*: faithfully embedding a small,
tightly-packed dataset into a larger one can only *increase* the population of
connections at every scale. The edge-count profile respects embeddings. In the
language of category theory, the construction "point cloud $\mapsto$ edge-count
profile" is a **functor**: it does not merely assign a number to each dataset,
it assigns a *comparison* to each faithful map between datasets, and these
comparisons stack up consistently.

## Why the "functor" framing matters

It is one thing to attach a number to a dataset. It is another — and far more
powerful — to attach numbers in a way that honors the maps *between* datasets.
That is the difference between a thermometer reading and a law of physics.

The three facts above say precisely that the edge-count profile is a
**morphism-aware invariant**:

- *Within* one dataset, as you vary the scale, you get a monotone staircase
  (Fact one), boxed between a floor and a ceiling (Fact two).
- *Between* datasets, every faithful nonexpanding embedding induces a clean
  inequality between staircases (Fact three).

This is exactly the structure a working data scientist wants. If a noisy sample
is a faithful sub-sample of a cleaner one, its staircase sits below the cleaner
one's, scale for scale. If you compress a dataset without identifying distinct
points, you cannot manufacture spurious connections. The profile is *stable
under the operations that ought to preserve shape* and *responsive to the scale
parameter that exposes shape*.

## The profile as a discrete derivative of distance

There is a beautiful second reading of the staircase. Each *jump* in the
edge-count profile happens at a particular distance — the distance of the pair
of points that just became close enough to connect. So the heights and locations
of the jumps encode, exactly, the **multiset of pairwise distances** in your
data: the full histogram of "how far apart is every pair?"

In this sense the edge-count profile is a kind of *discrete derivative* of the
distance distribution. Reading the staircase from bottom to top is reading off
the sorted list of all pairwise distances, one rung at a time. Two datasets with
the same histogram of pairwise distances have identical profiles; the profile is
a complete fingerprint of *that histogram*, even though — as with any
fingerprint — different shapes can occasionally share one.

This connects the humble edge count to deep questions in geometry. The list of
pairwise distances is one of the oldest invariants of a point configuration, and
asking when it determines the configuration is a classical and subtle problem.
The edge-count profile repackages that list as a single monotone function, ready
to be compared, bounded, and pushed through maps.

## Where this lives in the wild

Vietoris–Rips constructions are not a toy. They are the backbone of persistent
homology pipelines used to:

- **Find loops and voids in scientific data** — from the spatial distribution of
  galaxies, to the cavities in protein-folding landscapes, to cycles in
  neural-activity recordings.
- **Compare shapes robustly** — because the construction degrades gracefully
  under noise, small perturbations of the points cause only small changes in the
  resulting structures.
- **Summarize high-dimensional point clouds** — where direct visualization is
  hopeless but a one-dimensional staircase is easy to plot, store, and compare.

The edge count is the simplest, cheapest summary in this whole toolkit. It does
not capture loops or voids on its own — those need higher-dimensional analogues —
but it is the ground floor on which the rest is built, and its monotonicity and
functoriality are inherited, in spirit, by the more elaborate invariants above
it. Understanding the edge count cleanly is understanding the load-bearing wall
of the entire edifice.

## The view from the top of the staircase

Strip away the jargon and here is what we have established. Take any finite cloud
of points with a notion of distance. Slowly grow a connection radius. The number
of connections you have drawn is a staircase that:

1. **only climbs** as the radius grows,
2. **starts empty** and **never overflows** the total number of pairs, and
3. **respects faithful, non-stretching maps** between datasets, so embedding a
   small cloud into a bigger one can never make the small cloud's staircase
   overtake the big one's.

Three short sentences; three theorems, each pinned down with full rigor. The
edge-count profile is not a heuristic or an approximation. It is an exact,
order-preserving, map-respecting fingerprint of geometric data — a single
growing number that quietly remembers the shape of the cloud it came from.

The next time you picture a constellation and imagine the lines between the
stars, remember: as your imaginary dial turns, you are tracing a monotone
staircase that no faithful embedding can cheat, no perturbation can shatter, and
no amount of compression can inflate. That staircase is the shape of your data,
counting itself into existence one connection at a time.
