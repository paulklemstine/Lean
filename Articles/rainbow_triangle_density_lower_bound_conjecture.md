# Chasing Rainbows in a Graph

## A puzzle about color, connection, and the unavoidable triangle

Imagine a vast network — friendships in a city, flights between airports, atoms
bonded in a crystal. Now imagine that every connection in this network is painted
with a color. Maybe the colors record *types* of relationship: a green edge for
"co-workers," a red edge for "family," a blue edge for "neighbors." The picture
that emerges is what mathematicians call an **edge-colored graph**: a collection
of points (the *vertices*) joined by lines (the *edges*), each line carrying a
color.

Within this colorful tangle, one shape is especially prized. Pick three points
that are all joined to one another — a triangle. If the three sides of that
triangle happen to wear three *different* colors, we call it a **rainbow
triangle**. Rainbow structures are the heart of a beautiful branch of
combinatorics, because they capture the idea of *diversity locally*: a little
pocket of the network where no two relationships are alike.

The natural question is almost childlike in its simplicity:

> **If a network is colorful enough, how many rainbow triangles must it contain?**

Not *can* it contain — *must* it. We want a guarantee, a floor below which the
count cannot fall, no matter how an adversary arranges the edges and chooses the
colors. This article is about a precise and surprisingly elegant answer to that
question, recently conjectured by Li, Ning, Shi, and Zhang (2024), and about the
clean mathematical scaffolding that has been built to make it rigorous.

---

## The right notion of "colorful": color degree

Before we can say a graph is "colorful enough," we need to measure colorfulness.
The naive measure is the ordinary **degree** of a vertex — how many edges touch
it. But degree is blind to color. A vertex could touch a hundred edges that are
*all painted the same color*; locally, that is a monochrome world, not a colorful
one.

The honest measure is the **color degree**. For a vertex $v$, its color degree
$d_c(v)$ counts the number of *distinct colors* appearing on the edges incident to
$v$. Two edges of the same color at $v$ count only once.

$$
d_c(v) = \#\{\, \text{colors that appear on edges touching } v \,\}.
$$

This single change of viewpoint is the conceptual pivot of the whole subject.
Color degree, not ordinary degree, is the invariant that controls rainbow
structure. It always satisfies

$$
d_c(v) \le \deg(v) \le n - 1,
$$

where $n$ is the total number of vertices: you cannot have more colors at $v$ than
you have edges at $v$, and you cannot have more edges at $v$ than there are other
vertices to connect to. The first inequality is usually *strict* — and that gap is
exactly why color degree, rather than degree, is the "right" lens.

The **minimum color degree** of the whole graph, written $\delta_c(G)$, is the
smallest color degree over all its vertices. It is the bottleneck: the least
colorful vertex sets the global level of colorfulness.

---

## The conjecture

Here, in plain words, is the statement at the center of this story.

> **Rainbow Triangle Density Conjecture (Li–Ning–Shi–Zhang, 2024).**
> Let $G$ be an edge-colored graph on $n \ge 3$ vertices whose minimum color
> degree satisfies
> $$\delta_c(G) \ge \frac{n+1}{2}.$$
> Then the number of rainbow triangles in $G$, written $\mathrm{rt}(G)$, obeys
> $$\mathrm{rt}(G) \ \ge\ \left\lceil \frac{(n-1)(n-3)}{8} \right\rceil.$$
> Moreover, equality can occur only for one very special construction: the one
> built from a *proper* edge-coloring of the complete graph $K_n$ when $n$ is odd.

Let us unpack what this is saying, because each piece is doing real work.

The hypothesis $\delta_c(G) \ge (n+1)/2$ says that *every* vertex sees at least
about half of all possible colors. This is a "richness" threshold — once a network
crosses it, colorfulness is no longer optional or sporadic; it is pervasive.

The conclusion is a *lower bound* that grows quadratically in $n$. For large
networks the floor is roughly $n^2/8$ rainbow triangles. Crossing the color
threshold does not merely produce *a* rainbow triangle; it produces a quadratic
flood of them.

And the final clause is a **rigidity** statement. The bound is not just true — it
is *sharp*, and the only way to sit exactly on the floor is to use the most
symmetric, most rigid coloring imaginable. We will meet that coloring next.

---

## The extremal object: a perfectly painted complete graph

To understand any sharp inequality, look at the object that achieves equality. Here
it is a **properly edge-colored complete graph**.

A *complete graph* $K_n$ is the most connected network possible: every one of the
$n$ vertices is joined to every other. It has $\binom{n}{2}$ edges and exactly
$\binom{n}{3}$ triangles, since every choice of three vertices forms one.

A coloring is *proper* if any two edges that share a vertex receive different
colors. Think of it as a scheduling constraint: edges meeting at a point are like
events competing for the same person's calendar, so they must be given different
time-slots (colors). When $n$ is odd, $K_n$ admits a proper edge-coloring using
exactly $n-1$ colors — a classical fact, equivalent to scheduling a round-robin
tournament among $n$ players in $n-1$ rounds.

Two facts about this object are the crux of why it is extremal, and both have been
made completely rigorous.

**First: in a properly colored graph, *every* triangle is automatically a
rainbow.** This is the most satisfying little gem in the theory. Take any
triangle with vertices $a, b, c$. Its three edges are $ab$, $bc$, and $ca$. Now
notice: edges $ab$ and $bc$ share the vertex $b$, so by properness they must have
different colors. Edges $bc$ and $ca$ share $c$, so they differ. And $ab$, $ca$
share $a$, so they differ too. The three edges are pairwise different in color —
the triangle is a rainbow. The proper-coloring hypothesis *collapses* the rainbow
condition into the mere fact that the three vertices are distinct. No counting, no
case-chasing about which colors appear: properness does all the work.

**Second: a properly colored complete graph lands exactly in the conjecture's
regime.** Under a proper coloring, the color degree of every vertex equals its
ordinary degree (no two of its edges repeat a color), and in $K_n$ every vertex
has degree $n-1$. So
$$\delta_c(K_n) = n - 1.$$
For $n \ge 3$ this comfortably exceeds the threshold $(n+1)/2$. The extremal object
is therefore not some exotic edge case — it is a clean, natural graph sitting well
inside the hypothesis.

Putting the two facts together: a properly colored $K_n$ has *all* $\binom{n}{3}$
of its triangles rainbow. So its rainbow count is the largest conceivable. How,
then, can it be the *minimizer* in an inequality? The resolution is subtle and is
exactly what the rigidity clause is about: among all graphs meeting the color-degree
threshold, the extremal *minimizers* of rainbow triangles are forced to be as
*sparse* (as far from complete) as the threshold permits, and the conjectured floor
$\lceil (n-1)(n-3)/8 \rceil$ is the value at the boundary of that trade-off, attained
only by the rigid odd-$n$ proper construction. The complete-graph computation
verifies the other half of the picture: that the regime is genuinely populated and
that the bound is *consistent* — indeed wildly exceeded — by the natural witness.

---

## The arithmetic of the floor

The bound $\lceil (n-1)(n-3)/8 \rceil$ looks fussy, but it has a clean
personality once you study it. To handle it rigorously over the whole numbers, it
is convenient to write it in a single closed form,

$$
\mathrm{rtBound}(n) = \left\lfloor \frac{(n-1)(n-3) + 7}{8} \right\rfloor,
$$

a standard trick: $\lceil a/b \rceil = \lfloor (a + b - 1)/b \rfloor$. This integer
expression equals the ceiling for every $n$, and using truncated subtraction (where
$n-3$ is read as $0$ when $n < 3$) it behaves correctly even for tiny $n$.

Several properties of this floor have been established with complete rigor, and
together they describe the bound's whole life story.

**It is a genuine ceiling.** The defining sandwich
$$
(n-1)(n-3) \ \le\ 8\cdot \mathrm{rtBound}(n) \ <\ (n-1)(n-3) + 8
$$
pins $\mathrm{rtBound}(n)$ to be exactly $\lceil (n-1)(n-3)/8 \rceil$ — not one more,
not one less.

**It switches on at exactly the right moment.** The bound vanishes precisely in the
trivial range:
$$
\mathrm{rtBound}(n) = 0 \iff n \le 3.
$$
For $n \le 3$ a graph is too small to demand rainbow triangles, and the bound
politely asks for nothing. From $n = 4$ onward it is strictly positive — it starts
*biting*.

**It only grows.** The bound is *monotone* in $n$: more vertices can only raise the
floor, never lower it.
$$
m \le n \implies \mathrm{rtBound}(m) \le \mathrm{rtBound}(n).
$$

**It never asks for the impossible.** The most important arithmetic fact is the
comparison with the *total* number of triangles available:
$$
\mathrm{rtBound}(n) \ \le\ \binom{n}{3}.
$$
A complete graph has exactly $\binom{n}{3}$ triangles, so the floor never exceeds
the entire supply. This is the bridge that lets the properly colored complete graph
serve as an honest witness: it has $\binom{n}{3}$ rainbow triangles, comfortably
above the floor of $\mathrm{rtBound}(n)$. The proof of this comparison rests on the
identity $6\binom{n}{3} = n(n-1)(n-2)$ and reduces, after clearing the awkward
truncated subtraction, to the transparent polynomial inequality
$$
6(m+2)m \ \le\ 8(m+3)(m+2)(m+1),
$$
which is true for every $m \ge 0$ by inspection.

To make this concrete, here are the first interesting values:

| $n$ | $(n-1)(n-3)$ | $\mathrm{rtBound}(n)$ | $\binom{n}{3}$ |
|----:|-------------:|----------------------:|---------------:|
| 3   | 0            | 0                     | 1              |
| 4   | 3            | 1                     | 4              |
| 7   | 24           | 3                     | 35             |
| 9   | 48           | 6                     | 84             |

The floor rises steadily, always staying safely beneath the total triangle count —
exactly as a sharp-but-achievable bound should.

---

## Why color degree is the hero

It is worth pausing on *why* this whole theory is phrased in terms of color degree
rather than ordinary degree. The answer reveals the soul of the subject.

A graph can be enormously well-connected — every vertex touching hundreds of edges —
and yet contain *no* rainbow triangles at all, if those edges repeat just a few
colors. Connection without diversity buys you nothing rainbow. Conversely, a sparser
graph with high color *diversity* at each vertex is forced into rainbow triangles.
The quantity that detects this is $d_c(v)$, and the inequality
$d_c(v) \le \deg(v)$ being generally strict is precisely the statement that "color
diversity" and "raw connectivity" are different resources. Rainbow density is
governed by the former. That is why the threshold in the conjecture is stated as
$\delta_c(G) \ge (n+1)/2$ — half of all colors at every vertex — and not as a
condition on ordinary degree.

---

## The road ahead

The full conjecture remains open in its hardest direction — establishing the
quadratic floor for *every* graph in the high-color-degree regime, not only for the
pristine complete graphs where every triangle is a rainbow. The strategy that the
rigorous groundwork suggests is *localization*: turn the global threshold into a
promise about a single vertex's colorful neighborhood, prove that this promise alone
forces a fixed quota of rainbow triangles through that vertex, and then sum the quota
over all $n$ vertices. The collapse of the rainbow condition under proper colorings
is the model for what such a local lemma should achieve in general.

Several companion questions branch off naturally. **Existence before density:** does
the same threshold $\delta_c(G) \ge (n+1)/2$ already force at least *one* rainbow
triangle, and is the threshold sharp — are there colorings just below it with none at
all? **Uniqueness of the extremal example:** can one prove that *only* the rigid
odd-$n$ proper construction sits exactly on the floor? And **the degree gap:** can one
exhibit graphs whose ordinary degree dwarfs their color degree, confirming once and
for all that rainbow density marches to the beat of color degree alone?

Each of these is a self-contained adventure. But they all orbit the same luminous
idea: that *diversity, measured correctly, is unavoidable*. Paint a network richly
enough, and rainbows will bloom whether you want them to or not — not one, not a
handful, but a whole quadratic garden of them. That is the quiet promise hidden in
the inequality $\mathrm{rt}(G) \ge \lceil (n-1)(n-3)/8 \rceil$, and chasing it down to
the last rainbow is one of the lovely open challenges of modern combinatorics.
