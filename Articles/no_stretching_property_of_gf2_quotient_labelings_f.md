# Distances That Can Only Shrink: How Cube Labelings Refuse to Stretch

## A map that never lies in one direction

Imagine you are handed a complicated road network — a tangle of towns and
roads — and asked to redraw it onto the corners of a cube. Not a literal cube,
but a *hypercube*: a high-dimensional generalization whose corners are labeled
by strings of zeros and ones, and where two corners are joined by an edge
exactly when their strings differ in a single bit. Your job is to pin each town
to one of these corners.

You might expect such a flattening to distort distances wildly. Some towns that
were far apart could end up neighbors; some neighbors could be flung apart. The
surprising and clean fact at the heart of this work is that **a natural family of
such labelings can only distort distances in one direction.** They may glue
faraway towns together — taking *shortcuts* — but they can *never* push close
towns apart. In the language of metric geometry, these maps are
*non-expansive*: the distance between two labels is always less than or equal to
the distance between the original towns.

This is the **No-Stretching Theorem**. It is a small statement with a wide reach,
touching coding theory, the geometry of graphs, and the surprisingly rich
combinatorics of *partial cubes*.

## The cast of characters

Let us set the stage with three objects.

**The graph.** Start with a connected graph $G$: a set of vertices (towns) joined
by edges (roads). The *graph distance* $d_G(u,v)$ between two vertices is the
number of edges in the shortest path connecting them. Connectedness simply means
every town can be reached from every other.

**The hypercube.** Fix a dimension $k$. The $k$-dimensional hypercube $Q_k$ has
as its vertices all binary strings of length $k$ — equivalently, all functions
from $\{1,2,\dots,k\}$ into the two-element field $\mathbb{Z}/2\mathbb{Z}$. Two
strings are adjacent precisely when they differ in exactly one coordinate. The
*Hamming distance* $\mathrm{H}(x,y)$ between two strings counts the coordinates
where they disagree:
$$\mathrm{H}(x,y) = \#\{\, i : x_i \neq y_i \,\}.$$
For example, $\mathrm{H}(0110, 0011) = 2$, because the strings differ in the
second and fourth positions.

**The labeling.** A *labeling* is simply a function $\ell$ that assigns to every
town $v$ of $G$ a corner $\ell(v)$ of the hypercube. We are interested in
labelings that behave gently along roads: for every edge $\{u,v\}$ of $G$, the
two endpoints either receive the *same* label, or labels that differ in *exactly
one bit*. Symbolically,
$$\ell(u) = \ell(v) \qquad \text{or} \qquad \mathrm{H}(\ell(u), \ell(v)) = 1.$$
Each step along a road flips at most one switch.

This single, local constraint — "each road changes at most one coordinate" — is
all the structure we need.

## Where such labelings come from

Why would anyone build such a labeling? The most natural source is an **edge
partition**. Suppose we sort the roads of $G$ into $t$ classes — perhaps by color,
by direction, or by some equivalence relation of our choosing. Assign to each
class its own coordinate. Now walk from a fixed home town to any town $v$, and
record, for each class, whether you crossed roads of that class an even or odd
number of times. That parity vector, read modulo $2$, becomes the label of $v$.

There is a subtlety: the parity vector seems to depend on which route you took.
But going around any closed loop returns you home, and the loop's class-parities
form a fixed pattern. Quotienting out by all such loop patterns — the *cycle
space* of the graph, expressed through a parity matrix $A$ over
$\mathbb{Z}/2\mathbb{Z}$ — makes the label well defined. The result lives in a
space of dimension $t - \mathrm{rank}(A)$, and crucially, each road moves the
label by exactly *one* of a fixed family of directions (one per class), or by
nothing at all when its direction has been collapsed by the cycle space. One
step, one direction.

This is exactly the local gentleness we need. The honest target is the graph
whose vertices are the labels and whose edges connect labels differing by a
single one of those allowed directions. For the most natural partitions — in
particular the classical relation that groups edges lying directly opposite one
another, which recognizes the celebrated class of *partial cubes* (graphs that
embed isometrically into a hypercube) — the allowed directions are independent
coordinate axes and that target is the literal hypercube, with distance equal to
the Hamming count. In general the directions may overlap, and the target is a
slightly richer cube-like graph; the no-stretching conclusion holds all the same,
because its only ingredient is that each road advances the label by a single
step.

## The theorem, in three movements

The No-Stretching Theorem is proved in three clean steps.

### Movement 1: In the hypercube, distance *is* Hamming distance

The first fact is a satisfying identity: in the hypercube $Q_k$, the shortest-path
distance between two strings equals their Hamming distance,
$$d_{Q_k}(x,y) = \mathrm{H}(x,y).$$

Both inequalities are easy to feel. On one hand, *any* walk in the cube can only
fix one disagreeing bit per step, and the Hamming distance satisfies the triangle
inequality, so a walk of length $L$ cannot connect strings more than $L$ bits
apart — giving $d_{Q_k} \ge \mathrm{H}$. On the other hand, to travel from $x$ to
$y$ you can simply flip the disagreeing bits one at a time; each flip is a legal
cube edge, and after $\mathrm{H}(x,y)$ flips you arrive — giving
$d_{Q_k} \le \mathrm{H}$. Together these pin the distance exactly.

This is the bedrock. It converts a geometric quantity (shortest path) into an
algebraic one (counting bit differences) that we can manipulate freely.

### Movement 2: Walks map to walks without growing

Next, take any walk in $G$ — a sequence of towns connected by roads, from $u$ to
$v$. Apply the labeling to every town along the way. Because each road either
leaves the label unchanged or flips exactly one bit, the image sequence is a
legal walk in the hypercube (we simply skip the steps that don't move), and its
length is *no greater* than the length of the original walk:
$$\text{there is a cube walk } \ell(u) \to \ell(v) \text{ of length} \le (\text{length of the } G\text{-walk}).$$

The proof is a clean induction on the walk. The "same label" steps are free; they
shorten the image. The "one-bit" steps each contribute exactly one cube edge.
Nothing can ever lengthen the image. This is the precise sense in which the
labeling *contracts*.

### Movement 3: No stretching

Now the payoff. Take any two towns $u$ and $v$. Because $G$ is connected, there is
a shortest path between them, of length exactly $d_G(u,v)$. By Movement 2, its
image is a cube walk from $\ell(u)$ to $\ell(v)$ of length at most $d_G(u,v)$.
And the cube distance is the length of the *shortest* such walk, so
$$d_{Q_k}\big(\ell(u), \ell(v)\big) \;\le\; d_G(u,v) \qquad \text{for all } u,v.$$

That is the whole story. **The labeled distance never exceeds the original
distance.** Combined with Movement 1, this says the Hamming distance between
labels is bounded by the graph distance: counting how many bits two towns'
labels disagree on can only *undercount*, never *overcount*, how far apart the
towns truly are.

## Why one-sidedness matters

It would be easy to dismiss a one-sided inequality as half a result. In fact the
asymmetry is the point.

A labeling that is *isometric* — that preserves distances exactly — is a rare and
precious thing; graphs admitting one are exactly the partial cubes. Most graphs
are not partial cubes, so most labelings must distort. The No-Stretching Theorem
tells us *how* they are allowed to distort: only by collapsing. Every failure of
isometry is a shortcut, a pair of towns whose labels agree more than their
geography warrants, because some loop in the network folded two coordinates onto
each other.

This turns the gap between $d_G(u,v)$ and $d_{Q_k}(\ell(u),\ell(v))$ into a
well-behaved, always-nonnegative *defect* — a measurement of exactly how far a
given edge partition is from witnessing a perfect cube embedding. Because the
defect can never go negative, it behaves like an energy: it can be summed,
compared across partitions, and minimized. A partition with zero total defect is
exactly an isometric embedding; a partition with large defect has collapsed many
cycles.

## A bridge between fields

The construction quietly connects several worlds.

In **coding theory**, binary strings and Hamming distance are the native
language. A labeling that never stretches is a guarantee that a code built from a
graph's structure cannot accidentally separate codewords more than the graph
intends — useful when graph adjacency models permissible transitions.

In **metric geometry**, non-expansive maps into the hypercube are the workhorses
behind low-distortion embeddings, the tools used to approximate hard distance
computations by easy bitwise ones. The theorem certifies one half of the
distortion bound for free, leaving only the contraction side to control.

In **graph theory proper**, the result is the unconditional half of the theory of
partial cubes. The classical Djoković–Winkler relation sorts edges into classes
exactly as our partition does; the question of whether the resulting labeling is
isometric is the question of whether the graph is a partial cube. No-stretching
says: whatever else happens, you are never worse than the truth in the expanding
direction.

## The horizon

The cleanest open questions all concern the defect — the slack the theorem leaves
behind. Is the total defect of a partition computable from the cycle space alone,
counting exactly which loops the partition collapses? Is a graph a partial cube
precisely when some partition drives the defect to zero, and is there a unique
coarsest such partition? And if we color a graph's edges into a few classes *at
random*, does the resulting defect concentrate sharply around a value dictated
only by the degrees and the number of colors?

Each of these grows from the same seed: once you know distortion can only go one
way, the amount of distortion becomes a single clean number worth chasing. The
No-Stretching Theorem does not end the story of cube labelings — it gives that
story a direction.
