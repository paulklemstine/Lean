# Extremal Graph Theory: From Turán's Edge Bound to Roth's Theorem via Shadows and Removal

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Novelty (Extremal Combinatorics)

---

## Abstract

We present a unified, fully formalized development of four cornerstone results
in extremal graph theory and additive combinatorics, together with two
cross-domain bridges. We establish Turán's theorem on the maximum edge count of
a $K_{r+1}$-free graph in both an integer rearrangement and the textbook real
density form, and specialize it to Mantel's theorem. We connect the
set-theoretic Kruskal–Katona shadow inequality to graph theory, proving the
clique-counting principle that *a graph with $\binom{k}{3}$ triangles has at
least $\binom{k}{2}$ edges* via the structural fact that the shadow of the
triangle family is contained in the edge family. We package Szemerédi's
regularity-driven triangle removal lemma in textbook, contrapositive
(counting), and dichotomy forms. Finally we deploy the resulting machinery to
state Roth's theorem on $3$-term arithmetic progressions in both a density-limit
form and a qualitative "positive frequent density implies a $3$-AP" form. We
also exhibit a bridge linking Mantel's bound to the Ramsey number $R(3,3) = 6$.
All results have been verified in a proof assistant; this paper presents the
mathematics, definitions, statements, and proof sketches.

---

## 1. Introduction

Extremal graph theory studies the maximum or minimum value of a graph parameter
subject to a structural constraint. Its prototypical question is: *how many edges
can a graph on $n$ vertices have if it forbids a fixed subgraph $H$?* The answer,
the **extremal number** $\mathrm{ex}(n, H)$, encodes a fundamental tension
between abundance and structure: enough edges force the appearance of $H$.

This paper assembles four pillars of the theory into a single coherent
development:

1. **Turán's theorem** ($\mathrm{ex}(n, K_{r+1}) = (1 - 1/r)\,n^2/2$) and its
   special case **Mantel's theorem** ($\mathrm{ex}(n, K_3) = n^2/4$);
2. the **Kruskal–Katona theorem** on shadows of uniform set families, recast as
   a graph-theoretic clique-to-edge counting principle;
3. the **triangle removal lemma**, the combinatorial engine built on
   Szemerédi's regularity lemma;
4. **Roth's theorem** on $3$-term arithmetic progressions, the additive payoff
   of the removal lemma.

We additionally develop two **cross-domain bridges**: one linking Mantel's
extremal bound to Ramsey theory via $R(3,3)=6$, and one linking Kruskal–Katona
set-family combinatorics to clique and edge counting in graphs.

### Notation

Throughout, $G$ is a finite simple graph on a vertex set of size $n$. We write
$e(G)$ for its number of edges, $V(G)$ for its vertex set, and $G^c$ for its
complement. For an integer $r$, $K_{r+1}$ denotes the complete graph on $r+1$
vertices, and $G$ is **$K_{r+1}$-free** (equivalently `CliqueFree (r+1)`) if it
contains no $r+1$ mutually adjacent vertices. We write $\binom{k}{r}$ for the
binomial coefficient. For a family $\mathcal{A}$ of finite sets, $\partial
\mathcal{A}$ is its shadow (Definition 3.1), and $\partial^{[i]}$ is the $i$-fold
shadow. We write $\#S$ for the cardinality of a finite set $S$.

---

## 2. Turán's and Mantel's Theorems

### 2.1 The edge bound

**Definition 2.1 (Turán graph).** The *Turán graph* $T(n, r)$ is the complete
$r$-partite graph on $n$ vertices whose parts differ in size by at most one. It
is $K_{r+1}$-free, since any clique uses at most one vertex per part, and among
all $K_{r+1}$-free graphs it has the maximum number of edges.

**Theorem 2.2 (Turán, integer form — `turan_edge_bound_nat`).**
*Let $G$ be a $K_{r+1}$-free graph on $n$ vertices. Then*
$$ 2r \cdot e(G) \le (r-1)\, n^2. $$

*Proof sketch.* The extremal property of the Turán graph gives $e(G) \le
e(T(n,r))$. The exact edge count of the Turán graph, together with the integer
inequality $2r \cdot e(T(n,r)) \le (r-1)n^2$, yields the claim by transitivity.
Working with the cleared-denominator integer inequality avoids all rounding
issues at this stage. $\qquad\blacksquare$

**Theorem 2.3 (Turán, real density form — `turan_edge_bound_real`).**
*Let $G$ be a $K_{r+1}$-free graph on $n$ vertices with $r \ge 1$. Then*
$$ e(G) \le \left(1 - \frac{1}{r}\right)\frac{n^2}{2}. $$

*Proof sketch.* Substitute $r = m + 1$ (valid since $r \ge 1$), which eliminates
the truncated natural-number subtraction $r - 1$ that would otherwise misbehave.
Cast Theorem 2.2 to the reals, obtaining $2(m+1)\,e(G) \le m\, n^2$. The identity
$$ \left(1 - \frac{1}{m+1}\right)\frac{n^2}{2} = \frac{m\, n^2}{2(m+1)} $$
rewrites the goal into the form $e(G) \le \dfrac{m\, n^2}{2(m+1)}$, which is
exactly the cast inequality after clearing the positive denominator. $\qquad\blacksquare$

The hypothesis $r \ge 1$ is necessary and faithful: for $r = 0$, "$K_1$-free"
means the graph has no vertices, and the density expression $1 - 1/r$ is
undefined.

### 2.2 Mantel's theorem

**Theorem 2.4 (Mantel — `mantel_nat`, `mantel_real`).**
*Let $G$ be a triangle-free ($K_3$-free) graph on $n$ vertices. Then*
$$ 4\, e(G) \le n^2, \qquad\text{equivalently}\qquad e(G) \le \frac{n^2}{4}. $$

*Proof sketch.* Apply Theorems 2.2 and 2.3 with $r = 2$. The integer form gives
$4\,e(G) \le n^2$ directly; the real form gives $e(G) \le (1 - 1/2)\,n^2/2 =
n^2/4$. $\qquad\blacksquare$

The bound is sharp, attained by the balanced complete bipartite graph
$K_{\lfloor n/2\rfloor, \lceil n/2 \rceil}$.

### 2.3 A bridge to Ramsey theory

The Ramsey number $R(3,3) = 6$ asserts that every $2$-coloring of the edges of
$K_6$ contains a monochromatic triangle. We combine this unavoidability
statement with the extremal edge cap.

**Theorem 2.5 (Extremal–Ramsey bridge — `mantel_ramsey_bridge`).**
*Let $G$ be a triangle-free graph on $n \ge 6$ vertices. Then simultaneously*
$$ 4\,e(G) \le n^2 \qquad\text{and}\qquad G^c \text{ contains a triangle.} $$

*Proof sketch.* The first conclusion is Mantel's theorem. For the second, view
$G$ as the "red" graph in a $2$-coloring of the complete graph on the vertex set.
Since $n \ge 6$, $R(3,3)=6$ forces a monochromatic triangle. As $G$ is
triangle-free, no red triangle exists, so the monochromatic triangle is blue,
i.e., it lies in $G^c$. $\qquad\blacksquare$

This bridge illustrates a complementary duality: extremal theory caps the red
edges while Ramsey theory forces a blue triangle.

---

## 3. The Kruskal–Katona Theorem and a Graph Bridge

### 3.1 Shadows of uniform families

**Definition 3.1 (Shadow).** Let $\mathcal{A}$ be a family of finite sets. Its
*shadow* is
$$ \partial \mathcal{A} = \{\, t : \exists\, s \in \mathcal{A},\ \exists\, a \in s,\ t = s \setminus \{a\}\,\}, $$
the family of all sets obtained by deleting a single element from a member of
$\mathcal{A}$. The $i$-fold iterated shadow is $\partial^{[i]}\mathcal{A}$. A
family is **$r$-uniform** (`Sized r`) if every member has exactly $r$ elements.

The Kruskal–Katona theorem governs how small a shadow can be relative to the
family size. We use the Lovász form: if every member of an $r$-uniform family
has size $r$ and $\binom{k}{r} \le \#\mathcal{A}$, then $\binom{k}{r-i} \le
\#(\partial^{[i]}\mathcal{A})$ for all $i$.

**Theorem 3.2 (Kruskal–Katona, single shadow — `kk_shadow_lower`).**
*Let $\mathcal{A}$ be a family of $r$-element subsets of an $n$-element ground
set with $1 \le r \le k \le n$ and $\binom{k}{r} \le \#\mathcal{A}$. Then*
$$ \binom{k}{r-1} \le \#(\partial \mathcal{A}). $$

*Proof sketch.* Instantiate the Lovász form at $i = 1$ and simplify
$\partial^{[1]} = \partial$. $\qquad\blacksquare$

**Theorem 3.3 (Iterated shadows are nonempty — `kk_iterated_shadow_nonempty`).**
*Under the hypotheses of Theorem 3.2 with $i \le r \le k \le n$, the iterated
shadow $\partial^{[i]}\mathcal{A}$ is nonempty for every $i \le r$. In particular
($i = r$) the shadow chain descends to the empty set.*

*Proof sketch.* The Lovász form yields $\binom{k}{r-i} \le
\#(\partial^{[i]}\mathcal{A})$. Since $r - i \le r \le k$, the binomial
coefficient $\binom{k}{r-i}$ is strictly positive, so the cardinality is
positive and the family is nonempty. $\qquad\blacksquare$

### 3.2 The bridge: triangles, shadows, and edges

The decisive structural observation is that, in a graph, triangles are
$3$-element cliques, edges are $2$-element cliques, and deleting one vertex from a
triangle produces an edge.

**Lemma 3.4 (Triangles are $3$-uniform — `triangles_sized`).** *The family of
triangles (the $3$-cliques) of a graph $G$ is a $3$-uniform set family.*

**Lemma 3.5 (Shadow of triangles ⊆ edges — `shadow_triangles_subset_edges`).**
*For any graph $G$,*
$$ \partial\,(\text{triangles of } G) \subseteq (\text{edges of } G). $$

*Proof sketch.* A member of the shadow has the form $s \setminus \{a\}$ where $s$
is a triangle and $a \in s$. Since $s$ induces a clique, every subset of $s$
induces a clique, so $s \setminus \{a\}$ is a clique; and it has cardinality
$3 - 1 = 2$. Hence $s \setminus \{a\}$ is a $2$-clique, i.e., an edge. $\qquad\blacksquare$

**Theorem 3.6 (Kruskal–Katona for graphs, clique form —
`card_cliqueFinset_two_ge_of_triangles`).**
*Let $G$ be a graph on $n$ vertices and $3 \le k \le n$. If $G$ has at least
$\binom{k}{3}$ triangles, then it has at least $\binom{k}{2}$ edges (counted as
$2$-cliques):*
$$ \binom{k}{3} \le \#\{\text{triangles}\} \;\Longrightarrow\; \binom{k}{2} \le \#\{2\text{-cliques}\}. $$

*Proof sketch.* Apply the Lovász form of Kruskal–Katona to the $3$-uniform
triangle family (Lemma 3.4) with $i = 1$ to obtain $\binom{k}{2} =
\binom{k}{3-1} \le \#(\partial\,\text{triangles})$. By Lemma 3.5 the shadow is
contained in the edges, so $\#(\partial\,\text{triangles}) \le \#\{2\text{-cliques}\}$.
Chain the two inequalities. $\qquad\blacksquare$

**Lemma 3.7 ($2$-cliques are edges — `card_cliqueFinset_two_eq_edgeFinset`).*
*For any finite graph $H$, the number of $2$-cliques equals the number of edges:*
$$ \#\{2\text{-cliques of } H\} = e(H). $$

*Proof sketch.* The map sending an edge $\{u, v\}$ (as an unordered pair) to the
two-element set $\{u, v\}$ is a bijection between the edge set and the family of
$2$-cliques; both directions are checked by unpacking the definitions of an edge
and of a $2$-element clique. $\qquad\blacksquare$

**Theorem 3.8 (Kruskal–Katona for graphs, edge form —
`card_edgeFinset_ge_of_triangles`).**
*Let $G$ be a graph on $n$ vertices and $3 \le k \le n$. If $G$ has at least
$\binom{k}{3}$ triangles, then $e(G) \ge \binom{k}{2}$.*

*Proof sketch.* Combine Theorem 3.6 with the identification $\#\{2\text{-cliques}\}
= e(G)$ of Lemma 3.7. $\qquad\blacksquare$

The slogan is **"many triangles force many edges":** a graph rich in triangles
cannot remain globally sparse.

---

## 4. The Triangle Removal Lemma

The triangle removal lemma is the combinatorial heart of Roth's theorem. It is a
consequence of **Szemerédi's regularity lemma**, which states that the vertex set
of any large graph admits a partition into a bounded number of parts such that
the bipartite graph between almost every pair of parts is $\varepsilon$-regular
(pseudorandom). We denote by $\mathrm{triangleRemovalBound}(\varepsilon)$ the
explicit (tower-type) constant $\delta$ produced by the standard proof.

**Definition 4.1 ($\varepsilon$-far from triangle-free).** A graph $G$ on $n$
vertices is *$\varepsilon$-far from triangle-free* (`FarFromTriangleFree`) if
making $G$ triangle-free requires deleting at least $\varepsilon n^2$ edges;
equivalently, every triangle-free subgraph $G' \le G$ satisfies $e(G) - e(G') \ge
\varepsilon n^2$.

**Theorem 4.2 (Triangle removal lemma — `triangle_removal_lemma`).**
*For every $\varepsilon > 0$ there exists $\delta > 0$ (namely
$\delta = \mathrm{triangleRemovalBound}(\varepsilon)$) such that every finite
graph $H$ on $n$ vertices with fewer than $\delta n^3$ triangles admits a
triangle-free subgraph $H' \le H$ with*
$$ e(H) - e(H') < \varepsilon\, n^2. $$
*That is, $H$ can be made triangle-free by deleting fewer than $\varepsilon n^2$
edges.*

*Proof sketch.* Apply the regularity lemma to obtain an $\varepsilon$-regular
partition. Delete edges inside parts, between irregular pairs, and between
low-density pairs; this costs $O(\varepsilon n^2)$ edges. By the triangle
counting lemma, any remaining triangle would force a triple of high-density
regular pairs, which would in turn contain $\ge \delta n^3$ triangles. Since $H$
has fewer than $\delta n^3$ triangles, no triangle survives, so the reduced graph
is triangle-free. $\qquad\blacksquare$

The counting (contrapositive) form is often more directly usable.

**Theorem 4.3 (Counting form — `not_farFromTriangleFree_of_few_triangles`).**
*If a graph $G$ on $n$ vertices has fewer than
$\mathrm{triangleRemovalBound}(\varepsilon)\cdot n^3$ triangles, then $G$ is not
$\varepsilon$-far from triangle-free.*

*Proof sketch.* Suppose for contradiction that $G$ is $\varepsilon$-far from
triangle-free. By Theorem 4.2 there is a triangle-free subgraph $G' \le G$ with
$e(G) - e(G') < \varepsilon n^2$. But $\varepsilon$-farness forces $e(G) - e(G')
\ge \varepsilon n^2$, a contradiction. $\qquad\blacksquare$

Combined with the fact that an $\varepsilon$-far graph contains many triangle
copies, one obtains a dichotomy.

**Theorem 4.4 (Triangle-count dichotomy — `triangle_count_dichotomy`).**
*For every $\varepsilon > 0$, every graph $G$ either contains at least
$\mathrm{triangleRemovalBound}(\varepsilon)\cdot n^3$ triangles, or is not
$\varepsilon$-far from triangle-free.*

*Proof sketch.* This is the disjunctive restatement of Theorem 4.3: if the
triangle count falls below the cubic threshold, the counting form places $G$ on
the "not far" side. $\qquad\blacksquare$

The qualitative content: a graph is either *triangle-rich* (cubically many
triangles) or *edge-close to triangle-free*; there is no quantitative middle
ground beyond the removal threshold.

---

## 5. Roth's Theorem on Arithmetic Progressions

### 5.1 Setup

**Definition 5.1 ($3$-term arithmetic progression).** A *nontrivial $3$-term
arithmetic progression* (3-AP) is a triple $(a, b, c)$ with $a + c = 2b$ and
$a \ne b$. A set $A$ of naturals is *3AP-free* (`ThreeAPFree`) if it contains no
such triple.

**Definition 5.2 (Roth number).** The *Roth number* $r_3(N)$ (`rothNumberNat N`)
is the maximum size of a 3AP-free subset of $\{0, 1, \dots, N-1\}$.

Roth's theorem, in the form proved via the corners theorem and the triangle
removal lemma, states $r_3(N) = o(N)$.

### 5.2 Density form

**Theorem 5.3 (Roth, density form — `rothNumberNat_density_tendsto_zero`).**
$$ \frac{r_3(N)}{N} \longrightarrow 0 \qquad (N \to \infty). $$

*Proof sketch.* Immediate from $r_3(N) = o(N)$: an asymptotically little-o
quantity divided by $N$ tends to zero. $\qquad\blacksquare$

### 5.3 Qualitative form

The most useful form replaces the asymptotic statement by a concrete existence
conclusion under a positive-density hypothesis.

**Theorem 5.4 (Roth, qualitative form — `exists_threeAP_of_freq_dense`).**
*Let $A \subseteq \mathbb{N}$, and suppose there is a constant $c > 0$ such that,
for infinitely many $N$,*
$$ c \cdot N \le \#\{\, n \in \{0,\dots,N-1\} : n \in A \,\}. $$
*Then $A$ is not 3AP-free; that is, $A$ contains a nontrivial $3$-term
arithmetic progression.*

*Proof sketch.* Suppose $A$ is 3AP-free. By Roth's $o(N)$ bound applied with
$\varepsilon = c/2$, eventually $r_3(N) \le (c/2)\,N$. The frequent-density
hypothesis provides infinitely many $N$ with $c\,N \le \#(A \cap \{0,\dots,N-1\})$.
Choose a single large $N \ge 1$ satisfying both. The window $B = A \cap
\{0,\dots,N-1\}$ is 3AP-free (a subset of a 3AP-free set), so $\#B \le r_3(N)$.
Chaining,
$$ c\,N \le \#B \le r_3(N) \le \tfrac{c}{2}\,N, $$
which forces $c\,N \le \tfrac{c}{2}\,N$, impossible for $c > 0$ and $N \ge 1$.
$\qquad\blacksquare$

The frequent-density hypothesis is strictly weaker than positive upper density,
so Theorem 5.4 is stated at its natural level of generality; it is the form used
in density-increment arguments and in the inductive step of Szemerédi's theorem.

---

## 6. Algorithms

The development supports several explicit computations that illustrate and
numerically verify the theorems.

**Algorithm 6.1 (Turán/Mantel bound checker).** Given $n$, $r$, and an edge
count $e$, decide whether the integer Turán inequality $2re \le (r-1)n^2$ is
satisfied, and compare with the real density bound $(1-1/r)n^2/2$. Complexity
$O(1)$ arithmetic.

**Algorithm 6.2 (Shadow lower bound predictor).** Given a triangle count $T$ in
a graph on $n$ vertices, compute the largest $k \le n$ with $\binom{k}{3} \le T$,
and output the guaranteed edge lower bound $\binom{k}{2}$. Complexity $O(n)$ by
scanning $k$, or $O(\log n)$ by binary search.

**Algorithm 6.3 (3-AP ↔ triangle correspondence).** Given a finite set $A
\subseteq \{0,\dots,N-1\}$, construct the tripartite "corner/AP graph" whose
triangles are in bijection with the $3$-APs of $A$, and count them, verifying the
mechanism underlying Roth's theorem. Complexity $O(N^2)$ for the construction and
triangle enumeration.

---

## 7. Applications and Discussion

The four results assembled here are not isolated; each feeds the next.

- **Turán → Kruskal–Katona.** The Turán edge *upper* bound
  $(1-1/r)n^2/2$ and the Kruskal–Katona edge *lower* bound $\binom{k}{2}$ are two
  inequalities on the *same* quantity $e(G)$. A strong triangle count can
  therefore collide with the Turán ceiling, forcing the appearance of a clique.

- **Removal → Roth.** The triangle removal lemma converts the geometric/graph
  statement "few triangles" into the arithmetic statement "no dense 3AP-free
  set," via the 3-AP ↔ triangle correspondence (Algorithm 6.3). Roth's theorem
  is the additive shadow of the removal dichotomy.

- **Bridges.** The Mantel–Ramsey bridge (Theorem 2.5) shows extremal and Ramsey
  bounds are complementary. The Kruskal–Katona graph bridge (Section 3.2) shows
  that clique counting is shadow counting in disguise.

A recurring technical theme is the careful management of natural-number versus
real arithmetic: truncated subtraction $r - 1$ is the main friction in casting
Turán to the reals (resolved by the substitution $r = m+1$), and the contrast
between *frequent* lower bounds and *eventual* upper bounds is the precise
combinatorial mechanism behind the Roth contradiction.

---

## 8. Future Directions

**Conjecture 1 (Sharp clique–edge profile).** For every $K_{r+1}$-free graph on
$n$ vertices, the iterated shadow inequalities $\#(\partial^{[i]}(\text{cliques}_r))
\ge \binom{k}{r-i}$ are *simultaneously* tight across all $i$ **iff** the graph is
a disjoint union of a clique $K_k$ and isolated vertices. The colex-extremal
family for Kruskal–Katona is exactly the clique structure of a single clique, so
simultaneous tightness should rigidify the graph. The single-step transfer
(Theorem 3.8) and the iterated Lovász form are available; the chain version and
its equality case are within reach.

**Conjecture 2 (Triangle count forces super-Turán density).** If a graph on $n$
vertices has $\ge \binom{k}{3}$ triangles with $k \ge (1 - 1/r)n$, then it cannot
be $K_{r+1}$-free for any $r < k$; quantitatively, its edge count $\binom{k}{2}$
already exceeds the Turán threshold $(1-1/r)n^2/2$. Both bounds now exist in
compatible $e(G)$ form; only the arithmetic comparison remains.

**Conjecture 3 (No intermediate triangle regime).** There is no graph family with
triangle count $\Theta(n^{3-c})$ for $0 < c < 3$ that is also $\varepsilon$-far
from triangle-free for fixed $\varepsilon > 0$; the dichotomy of Theorem 4.4
admits no quantitative middle ground beyond the $\mathrm{triangleRemovalBound}$
threshold. Sharpening the (currently tower-type) constant
$\mathrm{triangleRemovalBound}(\varepsilon)$ is the central open quantitative
problem.

---

## 9. Conclusion

We have presented a unified development of Turán's theorem, the Kruskal–Katona
theorem, the triangle removal lemma, and Roth's theorem, together with bridges to
Ramsey theory and set-family combinatorics. The common thread is the extremal
principle that *largeness forces structure*: enough edges force cliques, enough
triangles force edges, and enough density forces arithmetic progressions. Each
result is stated precisely and proved (in a verified development) from standard
combinatorial machinery, and the bridges demonstrate that these classical pillars
are facets of a single edifice.
