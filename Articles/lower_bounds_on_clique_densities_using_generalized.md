# The Overlap Rule: How Counting Handshakes Forces Triangles

Imagine a party. Everyone who arrives shakes hands with some of the other guests,
and no one keeps track of the whole guest list — each person only remembers who
*they* met. Now a simple question: can we guarantee that somewhere in the room
three people all shook hands with each other, forming a little triangle of mutual
acquaintance?

Astonishingly, you can answer this question without ever seeing the party. You only
need two numbers for a single pair of guests, and a piece of arithmetic so
elementary that a child could do it. That arithmetic — an inverted version of the
famous *inclusion–exclusion principle* — turns out to be the hidden engine behind
some of the most celebrated results in the mathematics of networks. This article is
the story of that one small inequality and the surprisingly tall tower of theorems
it holds up.

## The cast of characters

Let us fix our language. A **graph** is just a set of $n$ points, called
**vertices**, some pairs of which are joined by an **edge**. In the party picture,
vertices are guests and edges are handshakes. The **degree** of a vertex $u$,
written $\deg(u)$, is simply how many edges touch it — how many hands $u$ shook. The
**neighborhood** $N(u)$ is the set of everyone $u$ shook hands with, so
$\deg(u) = |N(u)|$.

A **triangle** is three vertices, each pair joined by an edge — three guests who all
know each other. Triangles are the atoms of social structure: they are the smallest
"cliques," the smallest islands of mutual familiarity, and counting them tells you
how clustered or how sparse a network is.

The quiet hero of our story is a less famous quantity. For an ordered pair of
vertices $(u,v)$, define the **codegree**
$$\operatorname{codeg}(u,v) = |N(u) \cap N(v)|,$$
the number of vertices adjacent to *both* $u$ and $v$ — the number of common
friends. The codegree is exactly the number of triangles sitting on the edge $uv$,
because every common friend $w$ of $u$ and $v$ completes a triangle $u,v,w$. Codegrees
are, quite literally, where triangles live.

## The overlap rule

Here is the single idea from which everything flows. Take any two vertices $u$ and
$v$. Their two neighborhoods $N(u)$ and $N(v)$ are sets of vertices, and there is an
iron law about how sets combine, the inclusion–exclusion principle:
$$|N(u) \cup N(v)| + |N(u) \cap N(v)| = |N(u)| + |N(v)|.$$
In words: if you add up the sizes of two sets, you have counted their overlap twice,
so the sum equals the size of the union plus the size of the intersection. Now comes
the twist. The union $N(u) \cup N(v)$ is a set of vertices, and there are only $n$
vertices in the whole graph, so it cannot contain more than $n$ elements:
$$|N(u) \cup N(v)| \le n.$$
Substitute this ceiling into the identity and rearrange. The union term is at most
$n$, so the two neighborhood sizes together cannot exceed $n$ plus the overlap:

$$\boxed{\ \deg(u) + \deg(v) \ \le\ n + \operatorname{codeg}(u,v). \ }$$

That is the **overlap rule** — the inclusion–exclusion *inverse*. Read from left to
right it is a statement about degrees; read from right to left it is a lower bound on
the codegree:
$$\operatorname{codeg}(u,v) \ \ge\ \deg(u) + \deg(v) - n.$$
The number of common friends of $u$ and $v$ is at least the amount by which their
combined popularity *overshoots* the size of the room.

Why phrase it additively, as $\deg(u)+\deg(v) \le n + \operatorname{codeg}$, rather
than as the subtraction $\operatorname{codeg} \ge \deg(u)+\deg(v)-n$? Because when
the two vertices are not very popular, $\deg(u)+\deg(v)-n$ is negative, and the
subtractive form collapses into the useless statement "the codegree is at least a
negative number." The additive form never degenerates: it carries real information at
every degree, and it is exactly the shape that the rest of the theory needs.

## A triangle you cannot avoid

The overlap rule immediately delivers a guarantee. Suppose an edge $uv$ is
**over-heavy**: its endpoints together shook more than $n$ hands,
$$\deg(u) + \deg(v) > n.$$
Then the overlap rule forces $\operatorname{codeg}(u,v) > 0$, so $u$ and $v$ have at
least one common friend $w$. But then $u$, $v$, $w$ form a triangle. We have proved,
from nothing but counting:

> **Forced-Triangle Theorem.** If some edge $uv$ satisfies
> $\deg(u) + \deg(v) > n$, then the graph contains a triangle.

There is no cleverness here, no case analysis, no picture — just the pigeonhole fact
that two large sets in a small universe must overlap. And yet this is the exact
threshold at which triangles become unavoidable. It is the base case of a whole
recursive scheme for finding larger cliques: over-heavy edges force triangles, and
the same overlap logic, applied inside the common neighborhood, forces four-cliques,
five-cliques, and beyond.

## Turning it around: what a triangle-free party must look like

Every implication has a mirror image. If an over-heavy edge forces a triangle, then a
graph with *no* triangle can afford no over-heavy edges. Flip the Forced-Triangle
Theorem and you get its contrapositive:

> **Mantel's Local Condition.** In a triangle-free graph, every edge $uv$ is
> degree-light: $\deg(u) + \deg(v) \le n$.

This little sentence is the beating heart of one of the oldest results in graph
theory, **Mantel's theorem** (1907), which says a triangle-free graph on $n$ vertices
has at most $n^2/4$ edges — a maximum achieved by splitting the vertices into two
equal teams and joining every cross-team pair. You can see the whole extremal
structure hiding in the local condition: to keep every edge degree-light while
packing in as many edges as possible, you route all your handshakes across a single
divide, and the most efficient divide is the balanced one. From one counting
inequality we recover both the ban on dense triangle-free graphs and the blueprint of
the graphs that saturate it.

## From one edge to the whole graph: counting all the triangles

So far the overlap rule has spoken about a single edge. Its real power appears when we
sum it over the entire graph. First, an exact bookkeeping identity. If we walk over
every vertex $u$, then over every neighbor $v$ of $u$, and add up the codegrees, we
count something very concrete: ordered triples of mutually adjacent vertices. Each
unordered triangle gets counted once for each of its $3! = 6$ orderings, giving the
clean identity

$$\sum_{u}\ \sum_{v \in N(u)} \operatorname{codeg}(u,v) \ =\ 6 \cdot (\text{number of triangles}).$$

Every triangle is thus accounted for exactly six times by the codegree sum — a
precise conversion between local overlap data and the global triangle count.

Now feed the overlap rule into this machine. Summing
$\deg(u)+\deg(v) \le n + \operatorname{codeg}(u,v)$ over all ordered adjacent pairs
$(u,v)$ turns the codegree sum into six times the triangle count and leaves a lower
bound expressed purely through the degree sequence:

$$\sum_{u}\ \sum_{v \in N(u)} \bigl(\deg(u) + \deg(v)\bigr) \ \le\ \Bigl(\sum_{u}\ \sum_{v \in N(u)} n\Bigr) + 6 \cdot (\text{number of triangles}).$$

This is a **Goodman-type lower bound**: it says the number of triangles cannot dip
below a quantity determined entirely by how the degrees are distributed. Rearranged,
it is essentially the classical 1959 result of Goodman, who showed that a graph with
many edges is *forced* to contain many triangles — you simply cannot have a dense
network without clustering. The remarkable thing is the provenance: the global,
quantitative Goodman bound and the local, qualitative Forced-Triangle Theorem are the
same fact, viewed at two different scales.

## Why one inequality does so much

Step back and admire the unity. Three landmark phenomena in the theory of networks —

- **existence** (an over-heavy edge *must* sit in a triangle),
- **extremal structure** (a triangle-free graph must be everywhere degree-light, forcing it toward a balanced bipartite shape), and
- **global counting** (edge density forces a guaranteed number of triangles),

— are three readings of a single line of arithmetic: $\deg(u)+\deg(v) \le n +
\operatorname{codeg}(u,v)$. The existence result reads it forward at one edge; the
extremal result reads its contrapositive; the counting result reads it summed. What
looked like three separate theorems from three separate eras of combinatorics turns
out to be one principle wearing three costumes.

## Where the trail leads

The story does not end at triangles. The overlap rule is the $r=3$ slice of a taller
tower. For four-cliques and beyond, one expects a **codegree tensor inverse**: the
number of common neighbors of an $(r-1)$-clique should be bounded below by an
alternating sum of the degrees of its sub-cliques, with the signs dictated by the
Möbius function of the lattice of intersecting neighborhoods — inclusion–exclusion,
one level up. There are questions of **stability**, too: if a triangle-free graph
lives right on the equality boundary $\deg(u)+\deg(v)=n$, how close must it be to the
perfect balanced bipartite graph? And there is the tantalizing prospect of
**threshold cascades**, in which a single large degree overshoot, propagated through
nested common neighborhoods, forces not just a triangle but a large clique whose size
grows with the overshoot.

But the moral is already clear from the base case. Deep structure in a complicated
object often rests on a shallow, almost embarrassingly simple observation — here, that
two big sets in a small world are bound to overlap. Learn to read that overlap
correctly, forward, backward, and summed, and the triangles reveal themselves.
