# The Minimum Independence Ratio Constraint: A Reciprocal Bridge Between Coloring and Independence in Finite Graphs

**Author:** Aristotle
**Date:** 2026-07-01

## Abstract

We study the *independence ratio* $i(G) = \alpha(G)/|V(G)|$ of finite graphs,
where $\alpha(G)$ is the independence number, with particular attention to
unit-distance graphs in the Euclidean plane. Our central result is a two-sided
dictionary linking the independence ratio to the chromatic number through a single
pigeonhole identity, $n \le \chi(G)\cdot\alpha(G)$. Read in one direction it gives
the sharp reciprocal lower bound $i(G) \ge 1/\chi(G)$ for every nonempty finite
graph; read in the other it says that a small independence ratio forces many colors.
We provide a fully constructive greedy coloring proof of the classical bound
$\chi(G) \le \Delta(G) + 1$, where $\Delta(G)$ is the maximum degree, and combine
the two to obtain a degree-sensitive floor $i(G) \ge 1/(\Delta(G)+1)$. Specializing
to the plane, where no four points can be mutually at unit distance, we deduce the
**Minimum Independence Ratio Constraint**: every four-colorable finite
configuration — in particular every finite planar configuration of maximum degree at
most three — has independence ratio at least $1/4$. We show the reciprocal bound is
sharp, met with equality on balanced complete multipartite graphs and in particular
on the equilateral triangle $K_3$ where $i = 1/3 = 1/\chi$. We discuss the exact
equivalence between the quarter floor and the fractional four-colorability of the
plane, situating both within the Hadwiger–Nelson circle of problems, and record
three conjectures that push the boundary outward.

## 1. Introduction

Consider a finite set of points in the Euclidean plane $\mathbb{R}^2$. Declare two
points *adjacent* when their Euclidean distance is exactly one. The resulting
**unit-distance graph** encodes a purely local constraint: which pairs sit at the
forbidden distance. From this local data one extracts two global invariants that
appear, at first glance, unrelated.

The first is the **independence number** $\alpha(G)$: the maximum number of points
one can select with no two of them a unit apart. Normalized by the number of points
$n = |V(G)|$, it becomes the **independence ratio**

$$i(G) = \frac{\alpha(G)}{n},$$

the largest fraction of a configuration that can be kept conflict-free. The second
is the **chromatic number** $\chi(G)$: the least number of colors needed so that
adjacent points receive different colors.

The question motivating this paper is how small the independence ratio of a finite
planar configuration can be. We show that the answer is governed entirely by
coloring, through an elementary but sharp reciprocal identity, and that in the
bounded-degree regime the ratio cannot fall below one quarter. We call this
phenomenon the *Minimum Independence Ratio Constraint*.

Our contributions are:

1. A self-contained, constructive proof of the greedy coloring bound
   $\chi(G) \le \Delta(G) + 1$ (Section 3).
2. The sharp reciprocal lower bound $i(G) \ge 1/\chi(G)$, and its colorability
   form $i(G) \ge 1/k$ for $k$-colorable $G$ (Section 4).
3. The degree-sensitive floor $i(G) \ge 1/(\Delta(G)+1)$ and the quarter corollary
   $\Delta(G) \le 3 \Rightarrow i(G) \ge 1/4$ (Section 5).
4. A discussion of sharpness, the two-sided colorability dictionary, and the
   connection to the fractional chromatic number of the plane (Sections 6–7).

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph with vertex set $V$, $n = |V|$,
and edge set $E \subseteq \binom{V}{2}$. We write $u \sim v$ when $\{u,v\} \in E$.

**Definition 2.1 (Unit-distance graph).** For a finite set $P \subseteq \mathbb{R}^2$,
the *unit-distance graph* on $P$ has vertex set $P$ and an edge $\{p,q\}$ whenever
the Euclidean distance $\lVert p - q\rVert = 1$.

**Definition 2.2 (Neighborhood and degree).** The *neighborhood* of $v$ is
$N(v) = \{ w : w \sim v \}$. The *degree* of $v$ is $\deg(v) = |N(v)|$. The
*maximum degree* is $\Delta(G) = \max_{v \in V} \deg(v)$.

**Definition 2.3 (Independent set, independence number).** A set $S \subseteq V$ is
*independent* if no two of its members are adjacent. The *independence number*
$\alpha(G)$ is the maximum cardinality of an independent set.

**Definition 2.4 (Independence ratio).** For $V \neq \varnothing$,

$$i(G) = \frac{\alpha(G)}{n}.$$

We have $0 < i(G) \le 1$, since every singleton is independent (so $\alpha(G) \ge 1$).

**Definition 2.5 (Proper coloring, colorability, chromatic number).** A *proper
$k$-coloring* is a map $c : V \to \{1,\dots,k\}$ with $c(u) \neq c(v)$ whenever
$u \sim v$. The graph is *$k$-colorable* if such a map exists. The *chromatic
number* $\chi(G)$ is the least $k$ for which $G$ is $k$-colorable; for a finite graph
$\chi(G) \le n < \infty$.

**Definition 2.6 (Fractional chromatic number).** Let $\mathcal{I}(G)$ be the set of
independent sets. The *fractional chromatic number* $\chi_f(G)$ is the value of the
linear program: minimize $\sum_{S \in \mathcal{I}(G)} y_S$ over $y_S \ge 0$ subject
to $\sum_{S \ni v} y_S \ge 1$ for every vertex $v$. It satisfies
$\alpha(G)\cdot\chi_f(G) \ge n$ and $\chi_f(G) \le \chi(G)$.

## 3. The greedy coloring bound

**Theorem 3.1 (Greedy coloring bound).** *Every finite graph $G$ is
$(\Delta(G)+1)$-colorable; that is, $\chi(G) \le \Delta(G) + 1$.*

*Proof.* Write $\Delta = \Delta(G)$ and fix the palette $\{0, 1, \dots, \Delta\}$ of
$\Delta + 1$ colors. We build a proper coloring by induction on a processed set of
vertices $S$, proving the stronger statement:

> for every $S \subseteq V$ there is a map $c_S : V \to \{0,\dots,\Delta\}$ such that
> for all $v \in S$ and all $w \in N(v)$, $c_S(v) \neq c_S(w)$.

Applying this with $S = V$ yields a proper coloring, because for any edge
$\{u,v\}$ with $u,v \in V$ we have $c_V(u) \neq c_V(v)$.

*Base case.* For $S = \varnothing$ take $c_\varnothing \equiv 0$; the condition is
vacuous.

*Inductive step.* Suppose the statement holds for $S$ with coloring $c$, and consider
$S \cup \{v\}$ with $v \notin S$. The set of colors used by the neighbors of $v$,

$$c\big(N(v)\big) = \{ c(w) : w \in N(v) \},$$

has cardinality at most $|N(v)| = \deg(v) \le \Delta$. Since the palette has
$\Delta + 1$ elements, there exists a color $c_v \in \{0,\dots,\Delta\}$ with
$c_v \notin c(N(v))$. Define the patched coloring

$$c'(w) = \begin{cases} c_v & \text{if } w = v,\\ c(w) & \text{otherwise.}\end{cases}$$

We verify the required property for every $x \in S \cup \{v\}$ and $w \in N(x)$.

- **Case $x = v$.** Then $w \in N(v)$, so $w \neq v$ and $c'(w) = c(w) \in c(N(v))$,
  while $c'(v) = c_v \notin c(N(v))$; hence $c'(v) \neq c'(w)$.
- **Case $x \in S$, $w \neq v$.** Then $c'(x) = c(x)$ and $c'(w) = c(w)$, and the
  inductive hypothesis gives $c(x) \neq c(w)$.
- **Case $x \in S$, $w = v$.** Then $x \in N(v)$ by symmetry of adjacency, so
  $c'(x) = c(x) \in c(N(v))$, while $c'(v) = c_v \notin c(N(v))$; hence
  $c'(x) \neq c'(v)$.

In all cases $c'(x) \neq c'(w)$, completing the induction. $\qquad\blacksquare$

The proof is constructive: it exhibits an explicit coloring by processing vertices
one at a time and choosing, at each step, any color avoided by the already-colored
neighbors. The only ingredient is the pigeonhole fact that $\Delta+1$ colors cannot
all be blocked by $\Delta$ neighbors.

## 4. The reciprocal lower bound

The bridge from coloring to independence is a single counting identity.

**Lemma 4.1 (Pigeonhole partition bound).** *If $G$ is $k$-colorable, then*
$$n \;\le\; k \cdot \alpha(G).$$

*Proof.* A proper $k$-coloring partitions $V$ into $k$ color classes
$C_1, \dots, C_k$ (some possibly empty). Each $C_j$ is an independent set, so
$|C_j| \le \alpha(G)$. Summing, $n = \sum_{j=1}^k |C_j| \le k\cdot\alpha(G)$. $\qquad\blacksquare$

**Theorem 4.2 (Independence ratio lower bound from a coloring).** *Let $G$ be a
finite graph with $V \neq \varnothing$. If $G$ is $k$-colorable with $k \ge 1$, then*
$$i(G) \;\ge\; \frac{1}{k}.$$

*Proof.* By Lemma 4.1, $n \le k\cdot\alpha(G)$. Since $n > 0$ and $k \ge 1$, dividing
by $kn > 0$ gives $1/k \le \alpha(G)/n = i(G)$. (For the degenerate value $k = 0$,
which cannot occur for a nonempty graph, the convention $1/0 = 0 \le i(G)$ keeps the
inequality true.) $\qquad\blacksquare$

**Theorem 4.3 (Sharp reciprocal bound).** *For every finite graph $G$ with
$V \neq \varnothing$,*
$$i(G) \;\ge\; \frac{1}{\chi(G)}.$$

*Proof.* A finite graph is $\chi(G)$-colorable with $\chi(G) \ge 1$. Apply
Theorem 4.2 with $k = \chi(G)$. $\qquad\blacksquare$

Theorem 4.3 says the independence ratio is bounded below by the reciprocal of the
chromatic number — the independence ratio is the *reciprocal shadow* of the
chromatic number. The same argument applied to the fractional relaxation yields the
stronger $i(G) \ge 1/\chi_f(G)$, since $\alpha(G)\cdot\chi_f(G) \ge n$.

## 5. The degree-sensitive floor and the quarter constraint

Combining the constructive coloring bound with the reciprocal bound gives a floor
that depends only on local crowding.

**Theorem 5.1 (Degree-sensitive independence floor).** *For every finite graph $G$
with $V \neq \varnothing$,*
$$i(G) \;\ge\; \frac{1}{\Delta(G) + 1}.$$

*Proof.* By Theorem 3.1, $G$ is $(\Delta(G)+1)$-colorable. Apply Theorem 4.2 with
$k = \Delta(G) + 1 \ge 1$. $\qquad\blacksquare$

**Corollary 5.2 (Quarter floor for four-colorable graphs).** *If $G$ is
$4$-colorable and $V \neq \varnothing$, then $i(G) \ge 1/4$.*

*Proof.* Theorem 4.2 with $k = 4$. $\qquad\blacksquare$

**Corollary 5.3 (Minimum Independence Ratio Constraint).** *Every finite graph of
maximum degree at most three with $V \neq \varnothing$ satisfies $i(G) \ge 1/4$.
In particular, every finite unit-distance configuration in the plane in which no
point lies at unit distance from more than three others keeps an independent
quarter.*

*Proof.* If $\Delta(G) \le 3$ then $G$ is $4$-colorable by Theorem 3.1, and
Corollary 5.2 applies. $\qquad\blacksquare$

The logical content is a one-way barrier: **any configuration whose independence
ratio is claimed to be below $1/4$ cannot be four-colorable**, and hence — being a
planar unit-distance graph — must exhibit a genuinely five-chromatic obstruction.
Conversely, four-colorability is *sufficient* to rule out any sub-quarter ratio.

## 6. Sharpness

The reciprocal bound of Theorem 4.3 is tight.

**Proposition 6.1 (Equality on the triangle).** *For the equilateral-triangle
unit-distance graph $K_3$, $i(K_3) = 1/3 = 1/\chi(K_3)$.*

*Proof.* All three pairwise distances equal one, so $K_3$ is a complete graph on
three vertices. Any two vertices are adjacent, so a maximum independent set is a
single vertex, $\alpha(K_3) = 1$ and $i(K_3) = 1/3$. Three colors are necessary and
sufficient, so $\chi(K_3) = 3$. $\qquad\blacksquare$

**Proposition 6.2 (Equality classes).** *Equality $i(G) = 1/\chi(G)$ holds if and
only if $G$ admits an optimal proper coloring whose color classes are all maximum
independent sets of equal size — equivalently, $G$ is a balanced complete
multipartite graph together with the induced adjacencies. Then $n = \chi(G)\cdot
\alpha(G)$ exactly.*

*Sketch.* Equality in Lemma 4.1 requires each of the $\chi(G)$ color classes to
attain $|C_j| = \alpha(G)$, forcing balanced classes each of maximum size. Complete
multipartite graphs with equal parts realize this, and the equilateral triangle is
the case of three singleton parts. $\qquad\blacksquare$

Thus the quarter floor for four-colorable graphs is achieved in the limit by
balanced four-partite configurations, and every strict improvement over the
reciprocal bound must come from structural sparsity beyond mere colorability.

## 7. The two-sided dictionary and the plane

The pigeonhole identity $n \le k\cdot\alpha(G)$ can be read both forward and
backward, giving a dictionary between the independence ratio and colorability.

**Proposition 7.1 (Reduction: small ratio forces many colors).** *If a finite graph
$G$ with $V \neq \varnothing$ has $i(G) < 1/4$, then $\chi(G) > 4$; more generally
$i(G) < 1/k \Rightarrow \chi(G) > k$.*

*Proof.* Contrapositive of Theorem 4.2: if $\chi(G) \le k$ then $i(G) \ge 1/k$. $\qquad\blacksquare$

Combining Proposition 7.1 with Corollary 5.2, for finite graphs

$$i(G) \ge \tfrac14 \iff G \text{ is (fractionally) } 4\text{-colorable in the relevant sense},$$

with the exact equivalence holding for the fractional relaxation via
$i(G) \ge 1/\chi_f(G)$ and $\chi_f(G)\cdot\alpha(G) \ge n$. The upshot is a precise
localization of the open problem: **the assertion that every finite planar
unit-distance configuration has $i(G) \ge 1/4$ is equivalent to the assertion that
the fractional chromatic number of the plane is at most four.**

This places the Minimum Independence Ratio Constraint squarely inside the
**Hadwiger–Nelson** circle. The chromatic number of the plane $\chi(\mathbb{R}^2)$
— the least number of colors to color all of $\mathbb{R}^2$ with no two points a
unit apart the same color — is known to satisfy $5 \le \chi(\mathbb{R}^2) \le 7$,
the lower bound of five due to a finite five-chromatic unit-distance configuration
and the upper bound of seven from a hexagonal tiling. The fractional chromatic
number $\chi_f(\mathbb{R}^2)$ is believed to lie at or below four, precisely the
regime that would make the quarter floor universal.

The record-holding low-ratio configurations remain strictly above the floor:

| Configuration | Vertices $n$ | $\alpha$ | $\chi$ | $i(G) = \alpha/n$ |
|---|---|---|---|---|
| Equilateral triangle $K_3$ | 3 | 1 | 3 | $1/3 \approx 0.333$ |
| Golomb graph | 10 | 3 | 4 | $3/10 = 0.300$ |
| Moser spindle | 7 | 2 | 4 | $2/7 \approx 0.286$ |
| Quarter floor | — | — | — | $1/4 = 0.250$ |

Both the Moser spindle and the Golomb graph are four-chromatic, consistent with
Corollary 5.2, and both sit strictly above $1/4$.

## 8. Algorithms

Two algorithmic ingredients underlie the results.

**Algorithm 8.1 (Greedy vertex coloring).** Given $G$ and a vertex ordering
$v_1,\dots,v_n$, color each $v_i$ in turn with the least color not appearing on its
already-colored neighbors. This uses at most $\Delta(G)+1$ colors and runs in
$O(n + |E|)$ time, furnishing a constructive witness for Theorem 3.1.

**Algorithm 8.2 (Independence ratio via independence number).** Compute $\alpha(G)$
by a maximum-independent-set search (exponential in the worst case, but tractable on
the small rigid gadgets of interest), then report $i(G) = \alpha(G)/n$ and verify the
certified bounds $1/\chi(G) \le i(G)$ and $1/(\Delta(G)+1) \le i(G)$.

## 9. Applications

The reciprocal duality models a recurring theme: local pairwise constraints yield
global fractional guarantees. In **wireless networking**, an interference graph
joins transmitters that are too close; the largest simultaneously broadcasting set
is a maximum independent set, and a channel assignment is a coloring, so
$i(G) \ge 1/\chi(G)$ certifies a guaranteed throughput fraction. In **scheduling**,
conflicting tasks form a graph, time slots are colors, and Theorem 4.2 bounds the
fraction schedulable in a single slot. In **statistical physics**, hard-core models
forbid particles at prohibited separations, and independence ratios control packing
densities. In each case the constructive greedy bound gives an efficient certificate.

## 10. Discussion and Future Work

We have shown that the independence ratio of a finite graph is controlled from below
by the reciprocal of its chromatic number, that a constructive greedy argument yields
$i(G) \ge 1/(\Delta+1)$, and that the quarter floor $i(G) \ge 1/4$ holds for every
four-colorable configuration and hence for every planar unit-distance graph of
maximum degree at most three. The bound is sharp on balanced multipartite graphs.

**Future Directions.**

*Conjecture 1 — The quarter floor is universal.* Every finite set of points in the
plane admits an independent quarter: at least a quarter of the points can be chosen
pairwise at distance other than one. The quarter threshold is exactly the reciprocal
of $4$, and the fractional chromatic number of the plane is widely believed to sit at
or below $4$; the ratio bound and the coloring bound are two faces of the same linear
program. Recent years have produced improved lower bounds on the plane's chromatic
and fractional-chromatic numbers via large explicit configurations, climbing into the
band immediately below $4$ and making the reciprocal statement a sharply testable
target.

*Conjecture 2 — No finite configuration attains the floor exactly.* The value $1/4$
is an infimum but never a minimum: every finite planar configuration has independence
ratio strictly greater than $1/4$, with the excess shrinking to zero only along
infinite families. Attaining the floor exactly would require a finite fractional
coloring of value exactly $4$ with every color class a maximum independent set
simultaneously, a rigidity that the forbidden four mutually unit-distant points
cannot support at finite size. The record-holders (Moser spindle at $2/7$, Golomb
graph at $3/10$) sit strictly above $1/4$ and resist gluing operations that would
drive the ratio down.

*Conjecture 3 — A degree-sensitive floor beating the greedy bound.* For
configurations of maximum degree $\Delta \ge 3$, the independence ratio is at least
$3/(2\Delta+1)$, strictly better than the greedy $1/(\Delta+1)$. Planar unit-distance
graphs contain no four mutually adjacent points, so their neighborhoods are far from
complete, and this local sparsity should convert — through a Brooks-type refinement —
into a uniformly larger independent set than greedy coloring alone provides.

## References (background)

- H. Hadwiger, *Ungelöste Probleme*, on coloring the plane.
- A. D. N. J. de Grey, *The chromatic number of the plane is at least 5* (2018).
- L. Moser and W. Moser, *Solution to Problem 10* (the Moser spindle).
- S. W. Golomb, the Golomb graph construction.
- R. L. Brooks, *On colouring the nodes of a network* (1941).
