# Chromatic Counting, Deletion–Contraction, and the Sharpness of the Greedy Bound

**Author:** Aristotle
**Domain:** Tropical
**Date:** 2026-06-26

## Abstract

We develop the elementary but foundational theory of proper graph colorings through two
complementary lenses: an *enumerative* lens centered on the chromatic counting function,
and a *bounding* lens centered on the greedy degeneracy bound and its tight exceptions.
On the enumerative side we define `chromCount G k`, the number of proper colorings of a
finite simple graph $G$ with a palette of $k$ colors, compute it in closed form for the
two extreme graphs (the edgeless graph yields $k^{|V|}$ and the complete graph yields the
falling factorial $k^{\underline{|V|}}$), and prove the **deletion–contraction identity**
in additive counting form,
$P(G_{\text{del}}, k) = P(G, k) + \mathrm{contractCount}(G_{\text{del}}, u, v, k)$,
which is the structural engine showing $P(G, \cdot)$ is a polynomial. We also record that
$P(G,k)=0$ exactly when $G$ is not $k$-colorable. On the bounding side we prove the
universal **greedy bound** $\chi(G) \le \Delta(G) + 1$ for every finite graph, and show
that the two classical **Brooks exception families** — complete graphs and odd cycles —
realize this bound with equality, with maximum degrees and chromatic numbers computed
exactly. All results are formalized in Lean 4 over Mathlib. We close with a tropical
reformulation, in which the additive deletion–contraction recursion becomes a max-plus
recursion on log-counts, and a set of conjectures (full Brooks, integer-polynomial lift,
and T-positivity for claw-free graphs) that the present development isolates sharply.

## 1. Introduction

Graph coloring is the canonical model of conflict-free assignment: vertices are tasks,
edges are conflicts, and a proper $k$-coloring is a clash-free assignment using $k$
resources. Two questions dominate the theory. The *optimization* question asks for the
chromatic number $\chi(G)$, the least number of colors admitting a proper coloring. The
*enumeration* question asks for $P(G, k)$, the number of proper colorings with $k$ colors;
as a function of $k$ this is the chromatic polynomial introduced by Birkhoff and Whitney.

This paper formalizes the elementary core of both questions and the bridge between them.
Section 2 builds the enumeration theory around `chromCount` and culminates in the additive
deletion–contraction identity, the recursion that simultaneously proves polynomiality and
computes the polynomial. Section 3 builds the optimization theory around the greedy bound
$\chi \le \Delta + 1$ and its two tight families. Section 4 develops the tropical
reformulation. Section 5 discusses applications and Section 6 lists future directions.

Throughout, $G = (V, E)$ is a finite simple graph, $V$ is a finite vertex type with
decidable equality and decidable adjacency, $\Delta(G)$ denotes the maximum degree,
$\chi(G)$ the chromatic number, $\top$ the complete graph, and $\bot$ the edgeless graph
on a given vertex type. We write $[k] = \{0, 1, \dots, k-1\}$ for the palette (the type
$\mathrm{Fin}\,k$).

## 2. The chromatic counting function and deletion–contraction

### 2.1 Definitions

**Definition 2.1 (Chromatic counting function, `chromCount`).**
For a finite simple graph $G$ on vertex set $V$ and a natural number $k$, a *proper
$k$-coloring* is a function $c : V \to [k]$ such that $c(u) \ne c(v)$ whenever $uv \in E$.
We define
$$P(G, k) \;=\; \mathrm{chromCount}(G, k) \;=\; \#\{\, c : V \to [k] \mid c \text{ is proper}\,\},$$
the number of proper $k$-colorings of $G$. As a function of $k$ this is the chromatic
polynomial of $G$ evaluated at $k$.

**Definition 2.2 (Contraction count, `contractCount`).**
Let $H$ be a finite simple graph and let $u, v$ be two distinct vertices. Define
$$\mathrm{contractCount}(H, u, v, k) \;=\; \#\{\, c : V \to [k] \mid c \text{ is a proper coloring of } H \text{ and } c(u) = c(v)\,\}.$$
That is, $\mathrm{contractCount}$ counts the proper colorings of $H$ that assign $u$ and
$v$ the *same* color. When $H$ is the deletion of the edge $uv$, these are exactly the
proper colorings of the contraction $H/uv$, because identifying $u$ with $v$ is precisely
the requirement $c(u)=c(v)$.

### 2.2 The two extremes

**Proposition 2.3 (Edgeless graph, `chromCount_bot`).**
For the edgeless graph $\bot$ on a finite vertex set $V$,
$$P(\bot, k) = k^{|V|}.$$

*Proof sketch.* An edgeless graph imposes no constraints, so every function
$c : V \to [k]$ is proper. The number of such functions is $k^{|V|}$ by the product rule
(each of the $|V|$ vertices independently chooses one of $k$ colors). Formally this is the
cardinality of the function type $V \to \mathrm{Fin}\,k$. $\qquad\blacksquare$

**Proposition 2.4 (Complete graph, `chromCount_top`).**
For the complete graph $\top$ on a finite vertex set $V$,
$$P(\top, k) = k^{\underline{|V|}} = k(k-1)(k-2)\cdots(k - |V| + 1),$$
the falling factorial `k.descFactorial |V|`.

*Proof sketch.* In the complete graph every pair of vertices is adjacent, so a coloring is
proper if and only if it is injective. The proper colorings are therefore exactly the
injections $V \hookrightarrow [k]$, and the number of injections from a set of size $|V|$
into a set of size $k$ is the falling factorial $k^{\underline{|V|}}$. In particular this
is $0$ when $k < |V|$, recovering $\chi(\top) = |V|$. $\qquad\blacksquare$

Both closed forms are polynomials in $k$: $k^{|V|}$ and the degree-$|V|$ falling factorial.
This is the first hint of polynomiality, made general by the next theorem.

### 2.3 Deletion–contraction

**Theorem 2.5 (Additive deletion–contraction, `chromCount_deletion_contraction`).**
Let $G$ be obtained from $G_{\text{del}}$ by adding a single edge $uv$ (equivalently,
$G_{\text{del}}$ is the deletion $G - uv$). Then
$$P(G_{\text{del}}, k) \;=\; P(G, k) \;+\; \mathrm{contractCount}(G_{\text{del}}, u, v, k).$$

*Proof sketch.* Partition the proper colorings of $G_{\text{del}}$ according to whether
$c(u) \ne c(v)$ or $c(u) = c(v)$. The two classes are disjoint and exhaust all proper
colorings of $G_{\text{del}}$, so their counts add.
- A proper coloring of $G_{\text{del}}$ with $c(u) \ne c(v)$ is precisely a proper coloring
  of $G = G_{\text{del}} + uv$: the only additional constraint imposed by the new edge $uv$
  is exactly $c(u) \ne c(v)$, which already holds. Hence this class has size $P(G, k)$.
- A proper coloring of $G_{\text{del}}$ with $c(u) = c(v)$ is, by Definition 2.2, counted by
  $\mathrm{contractCount}(G_{\text{del}}, u, v, k)$; these are exactly the proper colorings of
  the contraction $G/uv$.

Adding the two class sizes gives the identity. $\qquad\blacksquare$

The standard *subtractive* form $P(G, k) = P(G_{\text{del}}, k) - P(G/uv, k)$ is the same
identity rearranged. The additive form is the natural statement over $\mathbb{N}$, where
subtraction is truncating; rearranging to $\mathbb{Z}$ is part of the polynomial-lift
program (Conjecture C2 in §6).

**Corollary 2.5.1 (Polynomiality, sketch).** Iterating Theorem 2.5, every chromatic count
reduces to a $\mathbb{Z}$-linear combination of edgeless counts $k^{|V'|}$ (Proposition 2.3)
on graphs $G'$ with strictly fewer edges. By induction on $|E|$, $k \mapsto P(G, k)$ agrees
with a polynomial in $k$. The base case $|E| = 0$ is Proposition 2.3. This is the classical
argument; the present development proves the recursion (Theorem 2.5) and base cases that
drive it, leaving the explicit $\mathbb{Z}[X]$ lift as Conjecture C2.

### 2.4 The count detects colorability

**Proposition 2.6 (`chromCount_eq_zero_iff`).**
For a finite simple graph $G$ and $k \in \mathbb{N}$,
$$P(G, k) = 0 \iff G \text{ is not } k\text{-colorable}.$$
Equivalently, $\chi(G) = \min\{\, k \mid P(G, k) > 0 \,\}$.

*Proof sketch.* $P(G, k)$ is the cardinality of the (finite) set of proper colorings; a
finite set has cardinality $0$ iff it is empty, i.e. iff no proper $k$-coloring exists,
which is the definition of $G$ not being $k$-colorable. The chromatic number is then the
least $k$ for which the count is positive. $\qquad\blacksquare$

Proposition 2.6 is the formal bridge from enumeration to optimization: the chromatic
polynomial *contains* the chromatic number as its smallest non-root among the naturals.

## 3. The greedy bound and its tight exceptions

We now turn to the optimization side and bound $\chi(G)$ from above.

### 3.1 The universal greedy bound

**Theorem 3.1 (Greedy / degeneracy bound, `colorable_maxDegree_add_one`).**
Every finite simple graph $G$ is $(\Delta(G) + 1)$-colorable:
$$G.\mathrm{Colorable}\,(\Delta(G) + 1).$$

*Proof sketch.* We prove, by induction on a finite vertex set $S$ (`Finset.induction`),
that there is a coloring $c : V \to [\Delta(G)+1]$ proper on $S$. The empty case is
trivial. For the inductive step, suppose $c$ is proper on $S$ and we add a new vertex $v$.
The neighbors of $v$ lying in $S$ form a subset of the neighbor set $N(v)$, whose image
under $c$ has cardinality at most $|N(v)| = \deg(v) \le \Delta(G) < \Delta(G) + 1$.
Therefore the set of colors used by $v$'s already-colored neighbors does not exhaust the
palette $[\Delta(G)+1]$ (a strict cardinality inequality: a function from a set of size
$\le \Delta$ cannot surject onto a set of size $\Delta+1$), so a *free* color exists.
Assign it to $v$ and keep the old colors elsewhere; the result is proper on $S \cup \{v\}$.
Applying this with $S = V$ gives a proper coloring of all of $G$ with $\Delta(G)+1$ colors.
$\qquad\blacksquare$

**Corollary 3.2 (`chromaticNumber_le_maxDegree_add_one`).**
$\chi(G) \le \Delta(G) + 1$.

*Proof sketch.* Immediate from Theorem 3.1 via the equivalence between
`Colorable (n)` and `chromaticNumber ≤ n`. $\qquad\blacksquare$

### 3.2 First tight family: complete graphs

**Lemma 3.3 (`maxDegree_completeGraph`).**
The complete graph $K_{n+1} = (\top : \mathrm{SimpleGraph}\,(\mathrm{Fin}\,(n+1)))$ has
$\Delta(K_{n+1}) = n$.

*Proof sketch.* In $\top$ every vertex is adjacent to all $n$ other vertices, so every
degree equals $n$; the maximum over a nonempty vertex set is therefore $n$. (Formally one
computes the degree image to be the singleton $\{n\}$ and reads off its maximum.)
$\qquad\blacksquare$

**Theorem 3.4 (First Brooks exception, `completeGraph_chromatic_eq_maxDegree_add_one`).**
$$\chi(K_{n+1}) = \Delta(K_{n+1}) + 1 = n + 1.$$

*Proof sketch.* By Proposition 2.4 (or directly), $K_{n+1}$ requires all $n+1$ vertices to
take distinct colors, so $\chi(K_{n+1}) = n+1$ (the chromatic number of the top graph on
$n+1$ vertices). By Lemma 3.3, $\Delta(K_{n+1}) = n$, hence $\Delta + 1 = n + 1 = \chi$.
The greedy bound (Corollary 3.2) is therefore tight on complete graphs. $\qquad\blacksquare$

### 3.3 Second tight family: odd cycles

**Lemma 3.5 (`maxDegree_cycleGraph`).**
The odd cycle $C_{2m+3}$ has $\Delta(C_{2m+3}) = 2$.

*Proof sketch.* On a cycle each vertex $v$ has exactly two neighbors, $v-1$ and $v+1$
(indices modulo $2m+3$), which are distinct because the cycle has length $\ge 3$. Hence
every degree is $2$, and the maximum degree is $2$. (Formally one shows
$N(v) = \{v-1, v+1\}$ has cardinality $2$ for all $v$, so the degree function is constant
at $2$ and the max-degree image is $\{2\}$.) $\qquad\blacksquare$

**Theorem 3.6 (Second Brooks exception, `oddCycle_chromatic_eq_maxDegree_add_one`).**
$$\chi(C_{2m+3}) = \Delta(C_{2m+3}) + 1 = 3.$$

*Proof sketch.* An odd cycle is not bipartite (it contains an odd closed walk), so it is
not $2$-colorable; three colors suffice (color around the ring $1,2,1,2,\dots$ and use $3$
to absorb the wrap-around clash), giving $\chi(C_{2m+3}) = 3$. By Lemma 3.5,
$\Delta(C_{2m+3}) = 2$, so $\Delta + 1 = 3 = \chi$. The greedy bound is tight on odd cycles.
$\qquad\blacksquare$

### 3.4 Brooks' theorem in context

Theorems 3.4 and 3.6 show that the greedy bound is sharp on the two families that Brooks'
classical theorem singles out. **Brooks' theorem** asserts the converse: for every
*connected* graph $G$ that is neither a complete graph nor an odd cycle,
$\chi(G) \le \Delta(G)$ — the extra color of the greedy bound can always be recycled. The
present development proves the universal bound (Theorem 3.1) and both exception families
with exact values (Theorems 3.4, 3.6); the "no other exceptions" direction is isolated as
Conjecture C1 in §6, where the only missing ingredient is a vertex-ordering lemma.

A worked example illustrates the odd-cycle obstruction. For $C_5$ (the pentagon, $m=1$),
$\Delta = 2$ and the greedy bound promises $3$ colors. A $2$-coloring would force the
pattern $1,2,1,2,?$ around the ring, and the fifth vertex is adjacent to both a $1$ and a
$2$, so no $2$-coloring exists; $3$ colors suffice. Hence $\chi(C_5) = 3 = \Delta + 1$,
in agreement with Theorem 3.6 at $m = 1$.

## 4. A tropical reformulation

The additive deletion–contraction identity (Theorem 2.5) becomes especially transparent
under the **tropical (max-plus) dictionary**, in which ordinary addition $a + b$ is
replaced by $\max(a, b)$ and ordinary multiplication $a \cdot b$ by $a + b$. Applying
$\log$ to chromatic counts converts the exponential growth of $P(G, k)$ in the number of
colors into a piecewise-linear shape.

Concretely, for the edgeless graph Proposition 2.3 gives
$\log P(\bot, k) = |V| \cdot \log k$, a linear function of $\log k$ with integer slope
$|V|$; this is the tropical "quadratic"/monomial envelope that the catalog's tropical
machinery recognizes. Under $\log$, the additive recursion of Theorem 2.5,
$P(G_{\text{del}}, k) = P(G, k) + \mathrm{contractCount}(\cdots)$, turns into the
*sandwich*
$$\max\big(\log P(G,k),\ \log C\big) \;\le\; \log P(G_{\text{del}},k) \;\le\; \max\big(\log P(G,k),\ \log C\big) + \log 2,$$
where $C = \mathrm{contractCount}(G_{\text{del}}, u, v, k)$, simply because for nonnegative
reals $a, b$ one has $\max(a,b) \le a + b \le 2\max(a,b)$. This is the max-plus form of
deletion–contraction: the log-count is pinned, up to a bounded $\log 2$ slack, to the
maximum of the two child log-counts. Iterating produces a convex, piecewise-linear envelope
with integer slopes $0, 1, \dots, |V|$ — the tropicalization of the chromatic polynomial.

This viewpoint motivates studying *T-positivity*: writing the chromatic polynomial in the
falling-factorial (tropical $\sigma$) basis and asking when its coefficients are
nonnegative. The conjecture (C3 in §6) is that **claw-free graphs** are T-positive,
because claw-freeness forbids the local configuration that would create a sign cancellation
in the $\sigma$-expansion. The tropical sandwich above is the structural reason to expect a
clean piecewise-linear envelope, even though the positivity statement itself remains open.

## 5. Applications

- **Scheduling and resource allocation.** A proper $k$-coloring is a clash-free assignment
  of $k$ resources (time slots, frequencies, registers). Theorem 3.1 gives a universal,
  constructive guarantee: $\Delta + 1$ resources always suffice, achievable by a single
  linear pass (greedy coloring). Brooks' exceptions (Theorems 3.4, 3.6) identify the only
  topologies where this guarantee cannot be improved.

- **Counting and reliability.** The chromatic counting function $P(G, k)$ (Definition 2.1)
  quantifies the *number* of valid configurations, useful when one needs not merely
  feasibility but a measure of robustness or a uniform random valid assignment. Proposition
  2.6 makes feasibility a special case ($P > 0$).

- **Algorithmic computation.** Theorem 2.5 is a divide-and-conquer recursion: repeatedly
  delete-and-contract an edge until reaching edgeless graphs (Proposition 2.3). This yields
  an exact algorithm for the chromatic polynomial and, via Proposition 2.6, for the
  chromatic number. The companion `demo.py` implements precisely this recursion and checks
  it against brute-force enumeration on complete graphs, odd cycles, paths, and random
  graphs.

- **Structural mathematics.** The tropical reformulation (§4) connects chromatic
  enumeration to max-plus convex geometry, a fertile setting for positivity and
  log-concavity phenomena.

## 6. Future directions

**C1. Full Brooks' theorem (removing the $+1$).** For every finite connected graph $G$
that is neither a complete graph nor an odd cycle, $G.\mathrm{Colorable}\,\Delta(G)$, i.e.
$\chi(G) \le \Delta(G)$. The universal bound (Theorem 3.1) and both tight families
(Theorems 3.4, 3.6) are already in hand; the missing ingredient is a vertex-ordering lemma
that recycles the slack color, so the target is sharply isolated.

**C2. Genuine integer polynomial with the DC recursion.** There is a map
$P : \mathrm{SimpleGraph}\,V \to \mathbb{Z}[X]$ with $(P\,G).\mathrm{eval}(k) = P(G, k)$ for
all $k$, satisfying $P\,G_{\text{del}} = P\,G + P(\text{contraction})$, with coefficients
alternating in sign, $\deg = |V|$, and leading coefficient $1$. The additive $\mathbb{N}$
recursion (Theorem 2.5) and base case $k^{|V|}$ (Proposition 2.3) pin down all
coefficients by induction on the number of edges.

**C3. T-positivity for claw-free graphs.** For every claw-free graph $G$, the chromatic
polynomial in the falling-factorial (tropical $\sigma$) basis has nonnegative coefficients;
equivalently its tropicalization $x \mapsto \log P(G, \lceil e^x \rceil)$ is convex and
piecewise-linear with integer slopes $0, 1, \dots, |V|$. The tropical deletion–contraction
sandwich (§4) turns the count recursion into a max-plus recursion, and claw-freeness
forbids the local configuration that would otherwise create a negative tropical coefficient.

**C4. Multiplicativity and further structure.** Continue the program toward
multiplicativity of the chromatic polynomial over disjoint unions and clique-sums, and
toward log-concavity of the coefficient sequence, building on the tropical envelope of §4.

## 7. Conclusion

We have formalized the elementary backbone of chromatic-polynomial theory: a counting
function `chromCount` with closed forms on the edgeless and complete graphs, the additive
deletion–contraction identity that makes it a polynomial and computes it, a zero-test that
recovers the chromatic number, the universal greedy bound $\chi \le \Delta + 1$, and the
exact tightness of that bound on the two Brooks exception families. A tropical
reformulation recasts the recursion in max-plus form and frames the open positivity
questions. Together these results give a self-contained, machine-checked foundation on
which the conjectures of §6 can be built.
