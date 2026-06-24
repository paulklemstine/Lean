# Foundations of Chip-Firing Divisor Theory on Finite Graphs: Degree Invariance and the Canonical Genus Formula

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Combinatorics (Tropical Curves & Chip-Firing)

## Abstract

We develop, from first principles and with non-circular proofs, the elementary
combinatorial foundations of chip-firing divisor theory on finite simple
graphs — the discrete (tropical) analogue of divisor theory on algebraic
curves. A *divisor* is an integer-valued function on the vertex set, a *firing
pattern* acts through the graph Laplacian, and two structural invariants govern
the whole theory. First, we prove that the Laplacian has total degree zero:
for every integer vertex labelling $f$, $\sum_v \operatorname{lap} f(v) = 0$.
Consequently linear equivalence of divisors preserves degree, so degree is a
well-defined invariant of a divisor class. Second, we prove the discrete
canonical genus formula $\sum_v K(v) = 2g - 2$, where $K(v) = \deg(v) - 2$ is
the canonical divisor and $g = |E| - |V| + 1$ is the combinatorial genus. The
first result rests on a single source/target relabeling identity that uses
only the symmetry of adjacency; the second is a short consequence of the
handshake lemma. Together these two facts are exactly the structural pillars
on which the tropical Riemann–Roch theorem of Baker–Norine is built. All
results have been formally verified; here we give the mathematical statements
and proof sketches. We close with the precise statement of the Riemann–Roch
target and a program of open conjectures.

## 1. Introduction

### 1.1 Motivation: graphs as tropical curves

Tropical geometry studies piecewise-linear shadows of algebraic varieties.
When a smooth algebraic curve degenerates — its complex structure pinching and
its handles collapsing — the limiting object is a *metric graph*: a finite
graph with positive real lengths on its edges. The edge lengths record the
rate of degeneration, and the combinatorial genus of the graph equals the
geometric genus of the curve. This degeneration dictionary turns hard analytic
questions about curves into finite, combinatorial questions about graphs.

The central such question concerns *divisors*. On an algebraic curve a divisor
is a finite formal sum of points with integer multiplicities; the
Riemann–Roch theorem controls the dimension of the space of meromorphic
functions with poles bounded by that divisor. Baker and Norine (2007)
discovered a perfect combinatorial analogue on finite graphs, in which divisors
are integer vertex labellings, "functions" are integer labellings acted on by
the graph Laplacian, and an exact Riemann–Roch identity holds. The
mechanical heart of their theory is the *chip-firing game*: a vertex fires by
sending one chip along each incident edge.

### 1.2 Scope and contribution

This paper isolates and rigorously establishes the two foundational invariants
that any development of graph divisor theory must have in place *before*
Riemann–Roch can even be stated:

1. **Degree invariance under firing** (Theorem 3.2): the graph Laplacian
   sends every divisor to one of equal degree, so degree descends to a
   well-defined function on linear-equivalence classes.
2. **The canonical genus formula** (Theorem 3.3): the canonical divisor has
   degree $2g - 2$, exactly matching the degree of the canonical class of a
   genus-$g$ curve.

Both proofs are deliberately *non-circular*: they invoke neither linear
equivalence, the rank function, nor Riemann–Roch. The degree-invariance proof
uses only the symmetry of the adjacency relation, and the genus formula uses
only the handshake lemma. This makes them a sound, reusable base layer. The
full Riemann–Roch equality and the explicit Baker–Norine theory on complete
graphs are stated as targets (Section 6) but are not claimed here.

### 1.3 Conventions

Throughout, $G = (V, E)$ is a finite simple graph: $V$ is a finite vertex set
and adjacency $\sim$ is a symmetric, irreflexive relation. We write $w \sim v$
for "$w$ is adjacent to $v$", $N(v) = \{ w : w \sim v\}$ for the neighborhood,
and $\deg(v) = |N(v)|$ for the vertex degree. We write $|V|$ and $|E|$ for the
number of vertices and edges. All divisor and labelling values are integers.

## 2. Definitions

**Definition 2.1 (Divisor and degree).**
A *divisor* on $G$ is a function $D : V \to \mathbb{Z}$, assigning an integer
(a signed chip count) to each vertex. Its *degree* is the total
$$\deg D \;=\; \sum_{v \in V} D(v) \;\in\; \mathbb{Z}.$$
(In the formalization this is `divisorDegree`.)

**Definition 2.2 (Graph Laplacian, flow form).**
For an integer labelling $f : V \to \mathbb{Z}$, the *Laplacian* of $f$ is the
divisor
$$\operatorname{lap} f(v) \;=\; \sum_{w \sim v} \big( f(v) - f(w) \big),
\qquad v \in V.$$
Interpreted as a chip-firing operation, $f(v)$ is the (signed) number of times
vertex $v$ fires: firing $v$ once removes one chip from $v$ per incident edge
and deposits one chip on each neighbor. Divisors $D$ and $D'$ are *linearly
equivalent*, $D \sim D'$, iff $D' - D = \operatorname{lap} f$ for some integer
labelling $f$. (In the formalization this is `lap`.)

**Definition 2.3 (Canonical divisor).**
The *canonical divisor* of $G$ is
$$K(v) \;=\; \deg(v) - 2, \qquad v \in V.$$
It is the graph-theoretic counterpart of the canonical class of an algebraic
curve. (In the formalization this is `canonicalDivisor`.)

**Definition 2.4 (Genus).**
The *(combinatorial) genus* of $G$ is
$$g \;=\; |E| - |V| + 1.$$
For a connected graph this is the first Betti number — the number of
independent cycles (equivalently the cyclomatic number); it equals the
geometric genus of the curve whose skeleton is $G$. (In the formalization this
is `genus`.) A tree has $g = 0$; a single cycle has $g = 1$.

## 3. Main results

### 3.1 The source/target relabeling identity

**Lemma 3.1 (Source equals target).**
For every $f : V \to \mathbb{Z}$,
$$\sum_{v \in V}\ \sum_{w \sim v} f(v) \;=\; \sum_{v \in V}\ \sum_{w \sim v} f(w).$$
(In the formalization this is `sum_source_eq_sum_target`.)

*Proof sketch.* Both sides are sums over the set of *ordered* adjacent pairs
$\{(v, w) : w \sim v\}$. On the left each ordered pair contributes the value of
$f$ at its first coordinate (the *source*); on the right, at its second
coordinate (the *target*). Because adjacency is symmetric, the map
$(v, w) \mapsto (w, v)$ is an involution of the set of ordered adjacent pairs.
Re-indexing the left-hand sum along this involution turns every source term
$f(v)$ into a target term, yielding the right-hand sum. Formally one rewrites
each neighbor-sum as a sum over $V$ filtered by adjacency, exchanges the two
outer/inner summations (`Finset.sum_comm`), and applies the symmetry of
adjacency (`SimpleGraph.adj_comm`). $\square$

### 3.2 Degree invariance of the Laplacian

**Theorem 3.2 (The Laplacian has degree zero).**
For every $f : V \to \mathbb{Z}$,
$$\sum_{v \in V} \operatorname{lap} f(v) \;=\; 0.$$
(In the formalization this is `deg_lap_eq_zero`.)

*Proof sketch.* Expand the definition and split the double sum using
distributivity of subtraction over a finite sum:
$$\sum_{v} \operatorname{lap} f(v)
= \sum_{v} \sum_{w \sim v} \big(f(v) - f(w)\big)
= \underbrace{\sum_{v}\sum_{w \sim v} f(v)}_{\text{source}}
- \underbrace{\sum_{v}\sum_{w \sim v} f(w)}_{\text{target}}.$$
By Lemma 3.1 the two terms are equal, so their difference is $0$. $\square$

**Corollary 3.2.1 (Degree is a linear-equivalence invariant).**
If $D \sim D'$ then $\deg D = \deg D'$. Indeed
$\deg D' - \deg D = \sum_v (D' - D)(v) = \sum_v \operatorname{lap} f(v) = 0$
for the labelling $f$ witnessing the equivalence. Hence degree descends to a
well-defined map on the divisor class group $\operatorname{Pic}(G) = \mathbb{Z}^V / \operatorname{im}(\operatorname{lap})$.

This corollary is the reason degree appears on the right-hand side of
Riemann–Roch: the entire theory is stated up to linear equivalence, and only a
degree that is *invariant* under firing can serve as a class function.

### 3.3 The canonical genus formula

**Theorem 3.3 ($\deg K = 2g - 2$).**
For every finite simple graph $G$,
$$\sum_{v \in V} K(v) \;=\; 2g - 2.$$
(In the formalization this is `deg_canonicalDivisor_eq_two_genus_sub_two`.)

*Proof sketch.* Expand the canonical divisor and separate the constant term:
$$\sum_{v} K(v) = \sum_{v}\big(\deg(v) - 2\big)
= \Big(\sum_{v} \deg(v)\Big) - 2|V|.$$
The handshake lemma (`SimpleGraph.sum_degrees_eq_twice_card_edges`) gives
$\sum_v \deg(v) = 2|E|$, because summing vertex degrees counts each edge once
at each endpoint. Therefore
$$\sum_{v} K(v) = 2|E| - 2|V| = 2\big(|E| - |V| + 1\big) - 2 = 2g - 2,$$
using $g = |E| - |V| + 1$. $\square$

## 4. Worked examples

We verify both theorems on small graphs (these computations are reproduced
numerically in the accompanying demo).

**Triangle $C_3$.** Vertices $\{1,2,3\}$, all pairwise adjacent.
Each $\deg(v) = 2$, so $K(v) = 0$ and $\sum_v K(v) = 0$. With $|E| = 3$,
$|V| = 3$, the genus is $g = 1$ and $2g - 2 = 0$: Theorem 3.3 holds. Firing
vertex $1$ once gives $\operatorname{lap} f$ with $f = (1,0,0)$:
$\operatorname{lap} f(1) = (1-0) + (1-0) = 2$,
$\operatorname{lap} f(2) = (0-1) = -1$,
$\operatorname{lap} f(3) = (0-1) = -1$, total $0$: Theorem 3.2 holds.

**Path $P_3$.** Vertices $1 - 2 - 3$. Degrees $1, 2, 1$ give
$K = (-1, 0, -1)$ with sum $-2$. Here $|E| = 2$, $|V| = 3$, $g = 0$,
$2g - 2 = -2$: Theorem 3.3 holds. The path is a tree, $g = 0$, as expected.

**Complete graph $K_4$.** Every vertex has degree $3$, so $K(v) = 1$ and
$\sum_v K(v) = 4$. With $|E| = 6$, $|V| = 4$, $g = 3$ and $2g - 2 = 4$:
Theorem 3.3 holds. For any firing pattern $f$ on $K_4$,
$\operatorname{lap} f(v) = \sum_{w \ne v}(f(v) - f(w)) = 4 f(v) - \sum_w f(w)$,
and $\sum_v \operatorname{lap} f(v) = 4\sum_v f(v) - 4\sum_w f(w) = 0$:
Theorem 3.2 holds.

## 5. Algorithms

The results are constructive and yield directly executable procedures.

**Algorithm A (Divisor degree under firing).** Given a graph and a firing
pattern $f$, compute $D' = D + \operatorname{lap} f$ and verify
$\deg D' = \deg D$. The Laplacian is evaluated as
$\operatorname{lap} f(v) = \sum_{w \sim v}(f(v) - f(w))$ in
$O(|V| + |E|)$ time; Theorem 3.2 guarantees the degree check always passes.

**Algorithm B (Canonical divisor and genus check).** Given a graph, build
$K(v) = \deg(v) - 2$ for each vertex, compute $g = |E| - |V| + 1$, and confirm
$\sum_v K(v) = 2g - 2$. Both sides are computed in $O(|V| + |E|)$ time, and
Theorem 3.3 guarantees equality.

## 6. The Riemann–Roch target

For completeness we record the theorem these foundations are designed to
support, *as a target, not a result of this paper*. Define a divisor $D$ to be
*effective* ($D \ge 0$) if $D(v) \ge 0$ for all $v$, and define the
Baker–Norine **rank** $r(D)$ to be $-1$ if no divisor linearly equivalent to
$D$ is effective, and otherwise the largest integer $r \ge 0$ such that for
every effective divisor $E$ of degree $r$ the difference $D - E$ is linearly
equivalent to an effective divisor. The **tropical Riemann–Roch theorem**
(Baker–Norine) asserts
$$r(D) - r(K - D) = \deg D - g + 1.$$
Here $\deg D$ is well defined on classes precisely because of Theorem 3.2, and
the self-dual point $D = K$, where $\deg K = 2g - 2$ by Theorem 3.3, makes the
involution $D \mapsto K - D$ balance the two ranks. Establishing the full
equality is future work (Section 7).

## 7. Discussion and future directions

The two theorems proved here are the non-negotiable base layer of graph
divisor theory: degree must be class-invariant for $\deg D$ to be meaningful,
and the canonical class must have degree $2g - 2$ for the Riemann–Roch
involution to be symmetric. Their proofs are intentionally minimal and
self-contained, depending only on adjacency symmetry and the handshake lemma,
which makes them safe to build upon without circularity.

The natural continuations, in increasing depth, are:

- **Riemann's inequality** $r(D) \ge \deg D - g$, via $q$-reduced divisors and
  Dhar's burning algorithm — a finite, terminating, decidable procedure that
  replaces the $\forall$-over-all-labellings definition of linear equivalence
  with a constructive normal form.
- **Full Riemann–Roch** $r(D) - r(K - D) = \deg D - g + 1$, obtained by
  combining Riemann's inequality with its dual through the involution
  $D \mapsto K - D$ and the fact that the maximal degree of a non-winnable
  divisor is exactly $g - 1$.
- **Canonical rank on complete graphs**: on $K_n$, the conjecture
  $r(K) = n - 2$ for $n \ge 2$, sitting at the self-dual point
  $\deg K / 2 = g - 1$.
- **Semicontinuity under edge contraction**: contracting an edge enlarges the
  image of the Laplacian, so it can only make divisors easier to win;
  consequently rank should not decrease under contraction.

These are stated precisely in the package's future-directions record. The
present paper supplies the verified groundwork on which each of them rests.

## 8. Conclusion

We have given clean, non-circular proofs of the two structural invariants of
chip-firing divisor theory on finite graphs: the Laplacian preserves degree
($\sum_v \operatorname{lap} f(v) = 0$), so degree is a linear-equivalence
invariant; and the canonical divisor satisfies $\sum_v K(v) = 2g - 2$, the
discrete shadow of the classical canonical degree formula. Elementary as their
proofs are, these results are exactly the foundation upon which the tropical
Riemann–Roch theorem stands, and they make the discrete theory a faithful,
fully computable mirror of the geometry of algebraic curves.

## References

The development is self-contained. For background, the combinatorial
Riemann–Roch theorem is due to M. Baker and S. Norine, *Riemann–Roch and
Abel–Jacobi theory on a finite graph* (Advances in Mathematics, 2007); the
metric-graph/tropical-curve perspective is developed by Baker, Mikhalkin, and
others. No external reference is required to follow the proofs above.
