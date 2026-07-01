# The Coloring–Independence Bound and the Independence Ratio of Unit-Distance Graphs

**Author:** Aristotle
**Date:** 2026-07-01

## Abstract

We study the *independence ratio* $\alpha(G)/|V(G)|$ of finite graphs, with
particular attention to unit-distance graphs in the Euclidean plane. We prove a
sharp, elementary bound linking colorability to independence: every finite graph
that admits a proper $k$-coloring contains an independent set $S$ with
$|V(G)| \leq k\,|S|$, so its independence ratio is at least $1/k$. Specializing
to $k = 4$ yields a rigorous *quarter bound* for every four-colorable graph,
including every four-colorable planar unit-distance graph. We show the bound is
best possible by exhibiting the complete graph $K_k$, whose independence ratio is
exactly $1/k$, and we anchor the theory in geometry with an explicit planar
witness: the unit equilateral triangle, whose unit-distance graph is $K_3$ and
whose independence ratio is exactly $1/3 > 1/4$. Crucially, we delineate the
precise boundary between theorem and conjecture: the *unconditional* claim that
all planar unit-distance graphs have independence ratio at least $1/4$ does **not**
follow from colorability, because the plane contains five-chromatic unit-distance
configurations (de Grey, 2018), and the best known lower bounds for the plane's
independence ratio lie below $1/4$. We close with a program of conjectures on the
true planar infimum, on when the coloring bound is sharp under geometric
realizability, and on an edge-count phase transition governing the ratio.

## 1. Introduction

A *unit-distance graph* in the plane is a graph whose vertices are points of
$\mathbb{R}^2$ and whose edges join precisely those pairs at Euclidean distance
exactly $1$. These graphs are the natural habitat of the Hadwiger–Nelson problem
on the chromatic number of the plane, and they interlace geometry, extremal
combinatorics, and the theory of computation.

A recurring question about any graph $G = (V, E)$ concerns its *independence
number* $\alpha(G)$, the size of the largest set of pairwise non-adjacent
vertices, and the associated *independence ratio*
$$
\rho(G) := \frac{\alpha(G)}{|V(G)|} \in (0, 1].
$$
A folklore assertion — the "minimum independence ratio constraint" — holds that
$\rho(G) \geq 1/4$ for every finite planar unit-distance graph. The purpose of
this paper is twofold. First, we isolate and prove in full the rigorous core that
underlies this intuition: a sharp bound $\rho(G) \geq 1/k$ for every
$k$-colorable graph. Second, we identify exactly where the unconditional planar
claim ceases to be a theorem and becomes a conjecture, and we support the theory
with an explicit, non-vacuous geometric example.

### Contributions

1. **A pigeonhole engine (Section 3).** A proper $k$-coloring of a finite graph
   always has a color class of real size at least $n/k$.
2. **The Coloring–Independence Bound (Section 3).** Every $k$-colorable finite
   graph has an independent set $S$ with $n \leq k\,|S|$, hence $\rho(G) \geq 1/k$.
3. **The quarter bound (Section 4).** For $k = 4$: every four-colorable graph,
   including every four-colorable planar unit-distance graph, satisfies
   $\rho(G) \geq 1/4$.
4. **Sharpness (Section 5).** $K_k$ is $k$-colorable with $\rho(K_k) = 1/k$
   exactly; the bound cannot be improved.
5. **An explicit planar witness (Section 6).** The unit equilateral triangle's
   unit-distance graph is $K_3$, with independence ratio exactly $1/3$.
6. **Theorem versus conjecture (Section 7).** A careful account of why
   colorability cannot deliver the unconditional planar quarter bound.

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph with $|V| = n$.

**Definition 2.1 (Independent set).** A set $S \subseteq V$ is *independent* if no
two distinct vertices of $S$ are adjacent: for all $u, v \in S$ with $u \neq v$,
$\{u, v\} \notin E$.

**Definition 2.2 (Independence number and ratio).** The *independence number* is
$\alpha(G) = \max\{|S| : S \text{ independent}\}$, and the *independence ratio* is
$\rho(G) = \alpha(G)/n$.

**Definition 2.3 (Proper coloring).** For $k \in \mathbb{N}$, a *proper
$k$-coloring* is a map $C : V \to \{1, \dots, k\}$ with $C(u) \neq C(v)$ whenever
$\{u, v\} \in E$. The graph is *$k$-colorable* if such a $C$ exists. The
*chromatic number* $\chi(G)$ is the least such $k$.

**Definition 2.4 (Color class).** For a coloring $C$ and color $c$, the *color
class* is $V_c = \{v \in V : C(v) = c\}$. Each $V_c$ is independent, since a
proper coloring assigns distinct colors to adjacent vertices.

**Definition 2.5 (Unit-distance graph).** Given a finite family of points
$p : I \to \mathbb{R}^2$ (or, more generally, into any metric space), the
*unit-distance graph* $U(p)$ has vertex set $I$, with $i$ adjacent to $j$ iff
$i \neq j$ and $\mathrm{dist}(p_i, p_j) = 1$.

## 3. The Coloring–Independence Engine

The technical heart of the paper is a single pigeonhole estimate.

**Lemma 3.1 (Large color class).** Let $G$ be a finite graph on $n$ vertices and
let $C$ be a proper $k$-coloring with $k \geq 1$. Then some color $c$ satisfies
$$
n \leq k \cdot |V_c|, \qquad\text{equivalently}\qquad |V_c| \geq \frac{n}{k}.
$$

*Proof.* The color classes $V_1, \dots, V_k$ partition $V$, so
$\sum_{c=1}^{k} |V_c| = n$. If every class had $|V_c| < n/k$, then summing over
the $k$ classes would give $n = \sum_c |V_c| < k \cdot (n/k) = n$, a
contradiction. Hence some class satisfies $|V_c| \geq n/k$, i.e.
$n \leq k\,|V_c|$. $\blacksquare$

**Theorem 3.2 (Coloring–Independence Bound).** Let $G$ be a finite graph on $n$
vertices that is $k$-colorable with $k \geq 1$. Then $G$ contains an independent
set $S$ with
$$
n \leq k \cdot |S|, \qquad\text{hence}\qquad \rho(G) \geq \frac{1}{k}.
$$

*Proof.* Fix a proper $k$-coloring $C$. By Lemma 3.1 choose a color $c$ with
$|V_c| \geq n/k$. The class $S := V_c$ is independent (Definition 2.4), and
$n \leq k\,|S|$. Dividing by $n > 0$ (the empty graph is vacuous) gives
$\alpha(G)/n \geq |S|/n \geq 1/k$. $\blacksquare$

Theorem 3.2 says exactly this: *the reciprocal of the chromatic number is a lower
bound for the independence ratio*, $\rho(G) \geq 1/\chi(G)$. The mechanism is
purely combinatorial and requires no geometry.

## 4. The Quarter Bound for Four-Colorable Graphs

**Theorem 4.1 (Quarter bound).** Every four-colorable finite graph $G$ contains
an independent set $S$ with $|V(G)| \leq 4\,|S|$; equivalently, $\rho(G) \geq 1/4$.
In particular, this holds for every four-colorable unit-distance graph in the
plane.

*Proof.* Apply Theorem 3.2 with $k = 4$. $\blacksquare$

This is the rigorous form of the "minimum independence ratio constraint": within
the class of four-colorable graphs, a quarter of the vertices can always be
selected pairwise non-adjacently.

## 5. Sharpness

**Theorem 5.1 (Tightness).** For every $k \geq 1$, the complete graph $K_k$ is
$k$-colorable and satisfies $\rho(K_k) = 1/k$ exactly. Consequently, the bound
$\rho(G) \geq 1/k$ of Theorem 3.2 is best possible and cannot be replaced by any
strictly larger function of $k$.

*Proof.* $K_k$ has $k$ vertices, all pairwise adjacent. Assigning each vertex a
distinct color gives a proper $k$-coloring, so $K_k$ is $k$-colorable. Because
every pair of distinct vertices is adjacent, no independent set contains two
vertices, so $\alpha(K_k) = 1$ and $\rho(K_k) = 1/k$. Thus equality holds in
Theorem 3.2 for $K_k$, ruling out any improvement in general. $\blacksquare$

## 6. An Explicit Planar Witness: The Unit Equilateral Triangle

To confirm that the abstract bound is non-vacuous on genuine plane geometry, we
instantiate it on the smallest non-trivial planar unit-distance graph.

**Construction 6.1.** Let $p : \{0,1,2\} \to \mathbb{R}^2$ be
$$
p_0 = (0,0), \qquad p_1 = (1, 0), \qquad p_2 = \left(\tfrac12, \tfrac{\sqrt3}{2}\right).
$$

**Lemma 6.2 (All pairwise distances are one).** For all distinct $i, j$,
$\mathrm{dist}(p_i, p_j) = 1$.

*Proof.* Directly: $\|p_0 - p_1\| = 1$; and
$\|p_0 - p_2\|^2 = \tfrac14 + \tfrac34 = 1$, using
$(\sqrt3/2)^2 = 3/4$; symmetrically $\|p_1 - p_2\|^2 = \tfrac14 + \tfrac34 = 1$.
Taking square roots gives distance $1$ in all three cases. $\blacksquare$

**Proposition 6.3 (The triangle is $K_3$).** The unit-distance graph $U(p)$ of
Construction 6.1 has vertices adjacent iff distinct; that is, $U(p) = K_3$.

*Proof.* By Definition 2.5, $i$ is adjacent to $j$ iff $i \neq j$ and
$\mathrm{dist}(p_i, p_j) = 1$. Lemma 6.2 makes the distance condition automatic
for distinct vertices, so adjacency reduces to $i \neq j$. $\blacksquare$

**Corollary 6.4 (Quarter bound applies).** $U(p)$ is $3$-colorable, hence
$4$-colorable, so by Theorem 4.1 it has an independent set of relative size at
least $1/4$.

*Proof.* Coloring the three distinct vertices with three distinct colors is
proper (and, embedding $\{1,2,3\} \hookrightarrow \{1,2,3,4\}$, a $4$-coloring).
Apply Theorem 4.1. $\blacksquare$

**Theorem 6.5 (Exact ratio of the triangle).** The independence ratio of $U(p)$
is exactly $1/3$. Precisely: every independent set has at most one vertex, and a
one-vertex independent set exists, so $\rho(U(p)) = 1/3 > 1/4$.

*Proof.* By Proposition 6.3 all pairs of distinct vertices are adjacent, so any
independent set has at most one vertex; hence $\alpha(U(p)) \leq 1$ and every
independent set $S$ satisfies $|S|/3 \leq 1/3$. Conversely $\{p_0\}$ is
independent with $|S|/3 = 1/3$. Therefore $\alpha(U(p)) = 1$ and $\rho(U(p)) =
1/3$. $\blacksquare$

The witness lies strictly inside the admissible region: it clears the quarter
threshold with room to spare, confirming the bound is met but not tight here.

## 7. Theorem versus Conjecture: The Ghost of a Fifth Color

The quarter bound (Theorem 4.1) is conditional on four-colorability. It is
tempting to remove the hypothesis and assert that *all* finite planar
unit-distance graphs satisfy $\rho(G) \geq 1/4$. We stress that this stronger,
unconditional claim does **not** follow from the coloring engine, and that the
engine provably cannot deliver it.

**Observation 7.1.** Theorem 3.2 gives $\rho(G) \geq 1/\chi(G)$. To conclude
$\rho(G) \geq 1/4$ for a class of graphs via this route, one needs
$\chi(G) \leq 4$ throughout the class. For planar unit-distance graphs this fails.

**Observation 7.2 (de Grey, 2018).** There exists an explicit finite set of
points in the plane whose unit-distance graph has chromatic number at least $5$.
Consequently the chromatic number of the plane is at least $5$, and no
four-coloring argument can cover all planar unit-distance graphs.

**Consequence 7.3.** For a five-chromatic planar unit-distance graph the coloring
engine yields only $\rho(G) \geq 1/5$, not $1/4$. Moreover, the best known
rigorous lower bounds on the independence ratio of the plane sit *below* $1/4$
(fractional-chromatic and packing methods place the relevant constant near
$0.229$). Hence the unconditional planar quarter claim is, at present, a
conjecture, and if true must be proved by density or packing arguments rather
than by colorability.

The value of Section 7 is precisely this demarcation: it converts a vague slogan
into a precise landscape of a proven conditional theorem, a sharp tightness
result, an explicit geometric witness, and a clearly identified open problem.

## 8. Algorithms

The results above are constructive and yield simple certified procedures.

**Algorithm A (Color-class independent set).** Given a graph and a proper
$k$-coloring, return the largest color class. It is independent, of size
$\geq n/k$, and is found in $O(n)$ time after the coloring is known.

**Algorithm B (Exact small-graph ratio).** For a graph small enough to enumerate,
iterate over all $2^n$ vertex subsets, keep those that are independent, and record
the maximum size; divide by $n$ for the exact ratio. This certifies, for example,
$\rho(K_3) = 1/3$.

**Algorithm C (Unit-distance graph builder).** Given planar points and a
tolerance, form the graph by joining pairs whose Euclidean distance is within
tolerance of $1$. This realizes Definition 2.5 numerically.

## 9. Applications

Lower bounds on the independence ratio are guarantees of conflict-free capacity.
In **frequency assignment**, transmitters at mutual interference distance form a
unit-distance-like graph; an independent set is an interference-free reuse
pattern, and $\rho(G) \geq 1/k$ certifies that at least a $1/k$ fraction can share
a channel. In **scheduling and seating**, independent sets are simultaneously
satisfiable demands. In **sensor placement**, independent sets are mutually
non-jamming layouts. In each case a four-coloring — often easy to produce —
immediately certifies a quarter-capacity guarantee via Theorem 4.1.

## 10. Discussion and Future Work

Three directions extend this work.

**The true planar infimum.** We conjecture that the infimum, over all finite
planar unit-distance graphs, of the independence ratio is a single well-defined
constant strictly between $0.22$ and $0.26$, and in particular strictly below
$1/4$. The "one quarter" figure is an artifact of four-color intuition;
colorability provably cannot deliver it (Section 7), so the constant must be
argued by packing or density methods, and the best constructions already push the
ceiling toward $0.229$.

**Sharpness is a coloring phenomenon, not a geometric one.** We conjecture that
among finite planar unit-distance graphs the coloring bound $1/k$ is attained with
equality only by graphs whose largest complete subgraph is a triangle, and never
by a genuinely $k$-color-critical planar family for $k \geq 4$. The abstract bound
is tight exactly on complete graphs (Theorem 5.1), but $K_k$ for $k \geq 4$ is not
realizable by planar unit distances, forcing every larger planar witness strictly
into the interior of the admissible region — exactly as the triangle illustrates
at $1/3$.

**An edge-count phase transition.** We conjecture that for planar unit-distance
graphs on $n$ vertices with $m$ edges, the independence ratio is bounded below by
a quantity of order $n/(m+n)$, and that this Turán/Caro–Wei degree-averaging bound
overtakes any coloring bound precisely in the sparse regime
$m = o(n^{4/3})$ — the extremal edge count for planar unit distances. Two distinct
mechanisms then govern the ratio in different density regimes, with the crossover
at the extremal edge count.

## References

- A. D. N. J. de Grey, *The chromatic number of the plane is at least 5*,
  Geombinatorics **28** (2018), 18–31.
- D. W. Cranston and L. Rabern, *The fractional chromatic number of the plane*,
  Combinatorica **37** (2017), 837–861.
- P. Turán, *On an extremal problem in graph theory*, Mat. Fiz. Lapok **48**
  (1941), 436–452.
- Y. Caro and V. K. Wei, degree-based lower bounds for the independence number
  (folklore, 1979).
