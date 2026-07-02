# The Shape of a Shortcut: How Parity Sketches Compress Distance

Imagine you are handed a vast road network — millions of intersections, tens of
millions of streets — and asked a deceptively simple question: *how far apart are
these two intersections?* Computing the exact answer means tracing shortest paths,
an expensive operation when the map is enormous and the questions never stop
coming. Engineers who build map services, social networks, and graph databases have
long dreamed of a cheaper trick: attach to every intersection a short *label*, a few
bits of data, so that comparing two labels gives you a fast estimate of the true
distance between them.

But a fast estimate is only useful if you know which way it can be wrong. An
estimate that might be too large *or* too small is nearly worthless — you can never
trust it. What you really want is a *one-sided* guarantee: a label comparison that
is never an *over*-estimate, so that the number it hands you is always a certified
lower bound on the real distance. If the labels say two points are at least ten
blocks apart, you can bank on it.

This article is about a clean and general mechanism for producing exactly such
one-sided labels, and about a subtle geometric twist that determines whether the
mechanism works at all. The punchline is a single principle we will call the
**No-Stretching Property**: a broad family of cheap, parity-based labelings can only
ever *contract* distances — collapse faraway points closer together — but can never
*stretch* them. And there is a catch that trips up the naive approach: to make the
guarantee hold, you must measure distance between labels in the right geometry. Get
the geometry wrong and an innocent-looking labeling appears to stretch a single
edge into a chasm.

## Coloring the streets

Here is the setup. Take a connected graph $G$ — think of intersections as vertices
and streets as edges. Now partition the edges into $t$ **classes**. You can color
the streets however you like: by neighborhood, by direction, by speed limit, by
whim. Each class $i$ gets its own private "token," a generator we will call
$\mathrm{gen}\, i$. These tokens live in a very simple algebraic world: the group
$(\mathbb{Z}/2\mathbb{Z})^t$ of binary vectors under coordinate-wise
exclusive-or (XOR), where adding a token to itself cancels it out. Everything is
parity; everything is mod 2.

Now walk the graph. Start at any vertex with the all-zeros label. Every time you
cross a street of class $i$, XOR the token $\mathrm{gen}\, i$ into your running
label. When you arrive at a vertex, the accumulated XOR is that vertex's label.
This is the **quotient labeling** $\ell : V(G) \to Q$, and $Q$ is a certain quotient
of the parity space that we will make precise in a moment.

The defining local feature of this construction is disarmingly simple:

> **Adjacent vertices either share the same label or differ by exactly one token.**

Cross a single street of class $i$, and your label changes by exactly
$\mathrm{gen}\, i$ (or, if that token happens to be zero in the quotient, not at
all). This is the seed from which everything grows.

## When cycles fold the space

If the graph had no cycles — if it were a tree — the story would end almost
immediately, and the labeling would be a perfect, distance-preserving map into a
hypercube. But real graphs have cycles, and cycles impose *constraints*.

Consider walking around a closed loop. You return to where you started, so your
label must return to its starting value. That means the XOR of all the tokens
collected around the loop must be zero. Each cycle thus contributes a linear
equation over $\mathbb{Z}/2\mathbb{Z}$ relating the tokens. Collect all of these
equations and you get the **cycle-class parity space** $C$: the subspace of
$(\mathbb{Z}/2\mathbb{Z})^t$ spanned by the class-incidence vectors of the cycles.
Encode it as a matrix $A$ — the **cycle-class parity matrix** — whose row space is
$C$.

The tokens don't really live in the full space $(\mathbb{Z}/2\mathbb{Z})^t$; they
live in the *quotient* $Q = (\mathbb{Z}/2\mathbb{Z})^t \big/ C$, where two parity
vectors are identified whenever they differ by something in $C$. And here is the
first crisp theorem:

> **Quotient Dimension Theorem.** The label space $Q$ has dimension
> $t - \operatorname{rank}(A)$, where $\operatorname{rank}(A) = \dim C$.

The proof is a one-line consequence of the rank–nullity relationship for
quotients: the dimension of the ambient space, $t$, splits as the dimension of the
subspace $C$ plus the dimension of the quotient. Every independent cycle constraint
"folds" one coordinate away. A graph with many independent cycles yields a tightly
compressed label; a tree yields no folding at all.

## The heart of the matter: contractions never stretch

Now for the engine that drives the whole theory. Strip away the parity, the
tokens, the cycles, and look at the bare bones. We have a map $\varphi$ from the
vertices of one graph $G$ to the vertices of another graph $H$, with a single
gentle property: **whenever two vertices are adjacent in $G$, their images are
either adjacent in $H$ or equal.** Call such a map *edge-contracting*. It never
tears an edge apart; it either preserves it as an edge or collapses it to a point.

> **Contraction Theorem.** If $G$ is connected and $\varphi : V(G) \to V(H)$ is
> edge-contracting, then for all vertices $u, v$,
> $$ d_H(\varphi(u), \varphi(v)) \le d_G(u, v). $$

This is the discrete cousin of a $1$-Lipschitz map — a map that never increases
distances. The proof is a small gem of induction. Take a shortest path in $G$ from
$u$ to $v$, of length $d_G(u,v)$. Walk along it, applying $\varphi$ to each step. An
edge that maps to an edge stays a step; an edge that collapses simply disappears.
The result is a walk in $H$ from $\varphi(u)$ to $\varphi(v)$ that is *no longer*
than the original — possibly shorter, if some edges collapsed. Since the distance
in $H$ is the length of the *shortest* walk, it can only be smaller still. Distances
can drop, never climb.

Everything else is a corollary of this one clean fact.

## The right geometry: Cayley, not coordinates

To apply the Contraction Theorem to our parity labeling, we must decide what the
target graph $H$ actually *is*. The vertices of $H$ are the labels — the elements
of $Q$. But when are two labels *adjacent*?

The tempting answer is the **coordinate hypercube** with Hamming distance: connect
two binary vectors when they differ in a single coordinate. This is the classical
picture, and it is where the naive intuition points. But it is *wrong*, and the way
it fails is instructive.

The correct target is the **Cayley graph** of the group $Q$ on the set of tokens
$S = \{\mathrm{gen}\, i\}$. Two labels $x$ and $y$ are adjacent precisely when they
are distinct and their difference $x - y$ is one of the tokens. (Because we are mod
$2$, each token is its own inverse, so the generating set is automatically
symmetric and the graph is undirected.) In this graph, taking "one step" means
adding one token — which is exactly what crossing one street does. With this
definition, the labeling is edge-contracting essentially by construction, and the
Contraction Theorem delivers the prize:

> **No-Stretching Theorem.** Let $G$ be connected with edges partitioned into $t$
> classes and tokens $\mathrm{gen}\, i \in Q$. If the quotient labeling $\ell$
> satisfies, on every edge, $\ell(u) - \ell(v) = \mathrm{gen}\, i$ for the class
> $i$ of that edge, then for all vertices $u, v$,
> $$ d_H(\ell(u), \ell(v)) \le d_G(u, v), $$
> where $H$ is the Cayley graph of $Q$ on the tokens. The labeling never stretches
> distances; it can only contract them.

## A triangle tells the tale

Why insist on the Cayley graph? A single triangle exposes the flaw in the
coordinate-hypercube picture with perfect clarity.

Take $K_3$, the triangle: three vertices $0, 1, 2$, all mutually adjacent, with
each of the three edges in its own class. Walking around the triangle is a cycle,
so the three tokens must XOR to zero — a single constraint. The cycle-class parity
space is one-dimensional, $C = \langle (1,1,1) \rangle$, and by the Quotient
Dimension Theorem the label space is $(\mathbb{Z}/2\mathbb{Z})^{3-1} =
(\mathbb{Z}/2\mathbb{Z})^2$, the four-element group.

Working it out, the tokens become
$$\mathrm{gen}\, 0 = (1,0), \quad \mathrm{gen}\, 1 = (0,1), \quad
\mathrm{gen}\, 2 = (1,1),$$
and the vertex labels are
$$\ell(0) = (0,0), \quad \ell(1) = (1,0), \quad \ell(2) = (1,1).$$

Look at the edge between vertices $0$ and $2$. In the graph it is a single street,
so $d_G(0,2) = 1$. Its label difference is $\ell(0) - \ell(2) = (1,1)$, which is
exactly the token $\mathrm{gen}\, 2$ — a single step in the Cayley graph. So the
Cayley distance is $d_H((0,0),(1,1)) = 1$, matching perfectly. No stretch.

But now measure the *same* labels in the coordinate hypercube with Hamming
distance. The vectors $(0,0)$ and $(1,1)$ differ in *two* coordinates, so their
Hamming distance is $2$. The labeling would appear to stretch a single edge into a
distance of $2$ — a genuine violation. The naive geometry is fooled precisely
because the cycle folded two coordinates into one token, and Hamming distance
double-counts the fold.

This little triangle is the whole moral in miniature. The map into the coordinate
hypercube stretches; the map into the Cayley graph does not. The cycles are what
force the two pictures apart, and the Cayley graph is the one that respects them.

## Why one-sidedness is the point

Return to the engineer with the enormous map. The No-Stretching Theorem says the
label distance is *never larger* than the true distance. Turn that around: the true
distance is *never smaller* than the label distance. A cheap parity sketch, computed
once and stored in a handful of bits per vertex, certifies a **lower bound** on the
real distance that can never be gamed.

And the guarantee composes beautifully. Because non-expansion survives taking
maxima, you can run *many* independent parity sketches — different edge colorings,
different token assignments — and take the largest lower bound any of them reports.
Each weak sketch is one-sided; their maximum is a stronger one-sided certificate.
This is exactly the kind of guarantee that verifiable query engines and graph
databases need, where a certified bound must hold against an adversary who controls
the index.

The flip side is equally illuminating. When does the labeling become a *perfect*
isometry — never contracting either — so that the sketch reports the exact distance?
The obstruction is precisely the cycles: the labeling is lossless exactly when the
cycle-class parity space is trivial, and each independent nonzero cycle contributes
one folded coordinate that shrinks a distance. The rank of the matrix $A$ is a
dial that interpolates between a perfect embedding (rank zero, a tree-like
partition) and a heavily compressed sketch (high rank, many folds).

## The larger landscape

Zoom out and this construction connects to a rich circle of ideas. Graphs that
*can* be embedded isometrically into a hypercube have a name — **partial cubes** —
and they include the median graphs central to metric graph theory, the structure of
solution spaces, and even models of concept formation. The parity-quotient
machinery is a lens on exactly this question: which partitions yield lossless
embeddings, and which merely yield one-sided sketches? Iterating the construction
toward the finest lossless partition is conjectured to land precisely on the
partial cubes, with the median graphs as its fixed points.

What began as a bookkeeping trick — XOR a token every time you cross a street —
turns out to sit at the confluence of coding theory, metric geometry, and practical
distance oracles. And it all rests on one sentence that a careful reader could
almost prove by hand: *a map that never tears an edge can never stretch a distance,
provided you measure distance in the geometry the map was built for.*
