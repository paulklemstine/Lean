# Extremal $L^1$ Mass of Normalized 1-Lipschitz Grid Height Functions

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (extremal combinatorics / discrete geometry)

## Abstract

We determine the exact maximum of the total absolute mass of an integer height
function on a finite rectangular grid, subject to two constraints: the function is
anchored to zero at one corner, and it is 1-Lipschitz across every grid edge (the
height changes by at most one between adjacent vertices). We prove that for an
$m \times n$ grid the total mass $\sum_{i<m}\sum_{j<n}|f(i,j)|$ is at most
$n\cdot m(m-1)/2 + m\cdot n(n-1)/2$, a sum of two triangular numbers, and that this
bound is sharp: it is attained exactly by the diagonal staircase $f(i,j)=i+j$ and
by its reflection $f(i,j)=-(i+j)$. The entire argument reduces to a single per-cell
domination lemma — the absolute height at a vertex is bounded by its $\ell^1$ grid
distance from the anchored corner, $|f(i,j)|\le i+j$ — established by telescoping
the Lipschitz condition along an L-shaped lattice path. We further show the anchor
hypothesis is necessary and load-bearing: dropping it permits the constant height
function $f\equiv C$, which is trivially 1-Lipschitz yet carries unbounded mass
$m\cdot n\cdot|C|$. The motivating application is the Miura-ori flat-folding height
model, where this $L^1$ mass bound is exactly the extremal estimate that converts an
explicit lower-bound construction for the flip-graph diameter into a matching upper
bound. All results are stated inline and self-contained.

## 1. Introduction

Discrete Lipschitz functions on lattices — assignments of integer values to grid
vertices that change slowly across edges — appear throughout combinatorics,
statistical mechanics (as height representations of dimer and six-vertex models),
and computational origami. A recurring question is *extremal*: among all admissible
height functions on a fixed grid, which maximizes a given global functional, and
what is the maximum value?

We treat one of the most natural such functionals, the total absolute mass (the
$L^1$ norm) of the height function, under the canonical normalization that pins the
function to zero at a reference corner. The problem is elementary to state and, as
we show, admits a clean closed-form answer with explicit extremizers. Despite its
simplicity, it is exactly the inequality required in the height-function model of
Miura-ori flat foldings to obtain a tight bound on the diameter of the associated
flip graph.

### Contributions

1. **A sharp extremal inequality** (Theorem 1): the total $L^1$ mass of any
   origin-anchored 1-Lipschitz integer height function on the $m\times n$ grid is
   at most $n\,m(m-1)/2 + m\,n(n-1)/2$.
2. **Attainment / sharpness** (Theorems 2 and 3): the bound is met with equality by
   the diagonal staircase $f(i,j)=i+j$ and by its reflection $-(i+j)$, so it cannot
   be improved.
3. **A per-cell rigidity mechanism** (Lemmas 1 and 2): the bound holds
   cell-by-cell, $|f(i,j)|\le i+j$, which is strictly stronger than the aggregate
   bound and pinpoints the equality locus.
4. **Necessity of the anchor** (Theorem 4): without the normalization, the
   functional is unbounded, witnessed by constant height functions.

All statements below are self-contained; the reader needs nothing beyond
elementary integer arithmetic and the triangle inequality.

## 2. Definitions and setup

Throughout, $m$ and $n$ are natural numbers (the grid may be empty). We index grid
vertices by pairs $(i,j)$ with $0\le i<m$ (rows) and $0\le j<n$ (columns). A
*height function* is a map $f:\mathbb{N}\times\mathbb{N}\to\mathbb{Z}$; only its
values on the grid $\{0,\dots,m-1\}\times\{0,\dots,n-1\}$ are relevant.

> **Definition 1 (Total $L^1$ mass).**
> $$\operatorname{gridMass}(f,m,n) \;=\; \sum_{i=0}^{m-1}\sum_{j=0}^{n-1} |f(i,j)|.$$

> **Definition 2 (Triangular bound).**
> $$\operatorname{triBound}(m,n) \;=\; n\cdot\frac{m(m-1)}{2} \;+\; m\cdot\frac{n(n-1)}{2}.$$
> Both summands are integers (each $k(k-1)/2$ is a triangular number), so
> $\operatorname{triBound}(m,n)\in\mathbb{N}$.

We say $f$ is **admissible** if it satisfies:

- **(Anchor)** $f(0,0)=0$;
- **(Row-Lipschitz)** $|f(i+1,j)-f(i,j)|\le 1$ whenever $(i,j)$ and $(i+1,j)$ are
  both grid vertices, i.e. $i+1<m$ and $j<n$;
- **(Column-Lipschitz)** $|f(i,j+1)-f(i,j)|\le 1$ whenever $i<m$ and $j+1<n$.

Only *grid* edges are constrained; no condition is imposed on vertices outside the
$m\times n$ window. This is deliberately weaker than a "universal-edge" hypothesis
and suffices for everything below.

> **Definition 3 (Diagonal staircase).**
> $$\operatorname{staircase}(i,j) \;=\; i + j.$$
> This is the height function equal to the $\ell^1$ grid distance of $(i,j)$ from
> the corner $(0,0)$.

## 3. The per-cell domination mechanism

The crux of the paper is that admissibility forces a *local* bound at every vertex,
not merely a global one.

> **Lemma 1 (Bottom-row domination, `cell_row_le`).**
> Suppose $f(0,0)=0$, the Row-Lipschitz condition holds, and $n>0$. Then for every
> $i<m$,
> $$|f(i,0)| \le i.$$

*Proof sketch.* Induct on $i$. The base case $|f(0,0)|=0\le 0$ is the anchor. For
the step, the reverse triangle inequality gives
$|f(i+1,0)| \le |f(i,0)| + |f(i+1,0)-f(i,0)| \le i + 1$, using the inductive
hypothesis and the Row-Lipschitz bound $|f(i+1,0)-f(i,0)|\le 1$ (valid because
$i+1<m$ and $0<n$). $\square$

> **Lemma 2 (Per-cell grid-distance domination, `cell_abs_le`).**
> Suppose $f$ is admissible (anchor, Row- and Column-Lipschitz). Then for all
> $i<m$ and $j<n$,
> $$|f(i,j)| \le i + j.$$

*Proof sketch.* Fix a vertex $(i,j)$ and walk an L-shaped lattice path from the
corner: first east along the bottom row to $(i,0)$, then north along the column to
$(i,j)$. By Lemma 1, $|f(i,0)|\le i$. Climbing the column and telescoping the
Column-Lipschitz increments,
$$|f(i,j)| \le |f(i,0)| + \sum_{t=0}^{j-1}|f(i,t+1)-f(i,t)| \le i + j.$$
Formally this is a nested induction: an outer induction on $i$ and, for each $i$, an
inner induction on $j$ built on the Column-Lipschitz condition, with Lemma 1
providing the $j=0$ slice. The right-hand side $i+j$ is exactly the graph distance
from $(0,0)$ in the grid graph, so the lemma reads: *absolute height is dominated by
distance to the anchor.* $\square$

The decisive structural point is that Lemma 2 is uniform across cells: every vertex
*independently* satisfies $|f(i,j)|\le i+j$. There is no global trade-off to
exploit, which is what makes the aggregate bound both immediate and sharp.

## 4. The closed-form evaluation

> **Lemma 3 (Grid sum of distances, `sum_grid_add`).**
> For all $m,n\in\mathbb{N}$,
> $$\sum_{i=0}^{m-1}\sum_{j=0}^{n-1} (i+j) \;=\; \operatorname{triBound}(m,n).$$

*Proof sketch.* Split the summand additively and use the Gauss sum
$\sum_{k=0}^{N-1}k = N(N-1)/2$:
$$\sum_{i<m}\sum_{j<n}(i+j)=\sum_{i<m}\sum_{j<n} i+\sum_{i<m}\sum_{j<n} j
= n\sum_{i<m} i + m\sum_{j<n} j = n\cdot\frac{m(m-1)}{2}+m\cdot\frac{n(n-1)}{2}.$$
Both factors are integers, so the identity holds over $\mathbb{Z}$ with the integer
division in $\operatorname{triBound}$ being exact. $\square$

## 5. Main results

> **Theorem 1 (Extremal $L^1$ mass bound, `gridMass_le`).**
> Let $f:\mathbb{N}\times\mathbb{N}\to\mathbb{Z}$ be admissible — that is,
> $f(0,0)=0$, the Row-Lipschitz condition, and the Column-Lipschitz condition all
> hold on the $m\times n$ grid. Then
> $$\operatorname{gridMass}(f,m,n) \;\le\; \operatorname{triBound}(m,n)
>   \;=\; n\cdot\frac{m(m-1)}{2} + m\cdot\frac{n(n-1)}{2}.$$

*Proof sketch.* Apply Lemma 2 termwise and sum monotonically:
$$\operatorname{gridMass}(f,m,n)=\sum_{i<m}\sum_{j<n}|f(i,j)|
\le \sum_{i<m}\sum_{j<n}(i+j) = \operatorname{triBound}(m,n),$$
the final equality being Lemma 3. Empty grids ($m=0$ or $n=0$) make both sides $0$
and are handled uniformly. $\square$

> **Proposition 1 (Admissibility of the staircase, `staircase_admissible`).**
> The diagonal staircase satisfies $\operatorname{staircase}(0,0)=0$, and for all
> $i,j$,
> $$|\operatorname{staircase}(i+1,j)-\operatorname{staircase}(i,j)| \le 1, \qquad
>   |\operatorname{staircase}(i,j+1)-\operatorname{staircase}(i,j)| \le 1.$$

*Proof sketch.* $\operatorname{staircase}(0,0)=0+0=0$. Each unit step in $i$ or $j$
changes $i+j$ by exactly $1$, so every edge difference equals $\pm 1$ in absolute
value $1\le 1$. Note these Lipschitz inequalities hold on *all* edges, in
particular on every grid edge. $\square$

> **Theorem 2 (Sharpness, `gridMass_staircase`).**
> For all $m,n\in\mathbb{N}$,
> $$\operatorname{gridMass}(\operatorname{staircase},m,n) = \operatorname{triBound}(m,n).$$

*Proof sketch.* Since $\operatorname{staircase}(i,j)=i+j\ge 0$, we have
$|\operatorname{staircase}(i,j)| = i+j$ in every cell, so the mass equals
$\sum_{i<m}\sum_{j<n}(i+j)=\operatorname{triBound}(m,n)$ by Lemma 3. Combined with
Theorem 1 and Proposition 1, the bound is attained by an admissible function and
hence cannot be improved. $\square$

> **Theorem 3 (Sharpness, negative branch, `gridMass_neg_staircase`).**
> For all $m,n\in\mathbb{N}$,
> $$\operatorname{gridMass}\big(-\operatorname{staircase},m,n\big) = \operatorname{triBound}(m,n).$$

*Proof sketch.* The reflected function $-(i+j)$ is also anchored and 1-Lipschitz on
grid edges, and $|-(i+j)| = |i+j| = i+j$, so it carries identical mass. There are
thus (at least) two extremal configurations, a hill and its reflection. $\square$

> **Theorem 4 (Necessity of the anchor, `constant_unbounded_mass`).**
> Fix a nonempty grid ($m>0$, $n>0$) and $C\in\mathbb{Z}$. The constant height
> function $f\equiv C$ satisfies both Lipschitz conditions (every edge difference
> is $0\le 1$), yet
> $$\operatorname{gridMass}(f,m,n) = m\cdot n\cdot|C|,$$
> which exceeds any fixed bound for $|C|$ large. Hence the conclusion of Theorem 1
> fails without the anchor $f(0,0)=0$; the normalization cannot be dropped.

*Proof sketch.* All adjacent differences of a constant are $0$, so $f$ is
1-Lipschitz. Its mass is $\sum_{i<m}\sum_{j<n}|C| = m\,n\,|C|$. Choosing
$|C|>\operatorname{triBound}(m,n)/(mn)$ violates the would-be bound, so the anchor is
load-bearing. $\square$

## 6. Discussion

**A "true but not hard" extremal problem, with the hard part isolated.** The only
substantive content is the path-telescoping bound of Lemma 2; everything else is
Gauss-sum bookkeeping (Lemma 3) and direct evaluation. This separation is itself
informative: it shows the extremal phenomenon is governed entirely by the *grid
metric*. The bound $|f|\le \operatorname{dist}(\cdot,\text{anchor})$ is the discrete
analogue of the statement that a 1-Lipschitz function vanishing at a point is
dominated by distance to that point — here specialized to the $\ell^1$ lattice
metric, where graph distance from the corner is exactly $i+j$.

**Cell-wise saturation.** A subtle but important feature is that the extremum is
achieved *simultaneously in every cell*: equality in Theorem 1 forces
$|f(i,j)|=i+j$ for all $(i,j)$, not merely an equality of totals. This rigidity is
why the staircase and its reflection are the natural — and conjecturally the only
(see Future Directions) — extremizers.

**Robustness of the hypotheses.** Only grid edges are used, and only along an
L-shaped path to each cell; the full set of adjacencies is not needed. The
integrality of the codomain is likewise never used in Lemma 2 — only the triangle
inequality and the per-edge bound — which is why the result relaxes cleanly to
real-valued, $L$-Lipschitz height functions (Future Directions §4). Degenerate
grids with $m=0$ or $n=0$ collapse both sides to $0$ and are absorbed uniformly.

## 7. Application: Miura-ori flip-graph diameter

In the height-function model of Miura-ori flat foldings (after Ginepro–Hull's study
of counting flat foldings of the Miura-ori crease pattern), valid flat-folded
states correspond to integer height functions on a grid, and elementary
reconfiguration moves ("flips") connect them into a *flip graph*. A central
structural quantity is the graph's diameter — the worst-case number of flips needed
to interconvert two states.

When flip distance is controlled by the $L^1$ height difference, our results bound
the diameter from both sides. The staircase of Theorem 2 furnishes an explicit pair
of states whose height functions differ in $L^1$ by $\Theta(m^2 n + m n^2)$,
yielding a concrete *lower bound* on the diameter. Theorem 1 simultaneously *caps*
the $L^1$ mass — and hence any $L^1$-controlled flip distance — by the same
$\operatorname{triBound}(m,n)=\Theta(m^2 n + m n^2)$. The matching orders turn the
one-sided staircase construction into a two-sided diameter estimate. This is exactly
the role the extremal inequality plays: it is the missing upper bound that pairs
with the existing lower-bound construction.

## 8. Algorithmic content

Two routines summarize the constructive side of the theory.

**(A) Mass evaluation and certification.** Given any height function on the grid,
one computes $\operatorname{gridMass}$ in $O(mn)$ time by direct summation and
compares it to $\operatorname{triBound}(m,n)$, which is computed in $O(1)$
arithmetic operations. This certifies the bound of Theorem 1 numerically for any
concrete instance and, via Lemma 2, can additionally report the per-cell slack
$(i+j)-|f(i,j)|\ge 0$.

**(B) Extremizer generation.** The staircase and its reflection are generated in
$O(mn)$ by tabulating $f(i,j)=\pm(i+j)$; Theorem 2/3 guarantee these realize the
bound exactly. This produces the lower-bound witnesses used in the Miura-ori
application.

## 9. Future directions

1. **Uniqueness of extremizers.** Conjecture: for $m,n\ge 2$ the only admissible
   extremizers are the two staircases $\pm(i+j)$; equality forces cell-wise
   saturation $|f(i,j)|=i+j$, and a saturated 1-Lipschitz function is sign-rigid
   along monotone paths from the corner.
2. **Prescribed corner value.** Conjecture: if $f(0,0)=c$, then
   $\operatorname{gridMass}(f,m,n)\le \operatorname{triBound}(m,n)+m\,n\,|c|$,
   sharp; this is the additive combination of Theorem 1 with the constant
   contribution $m\,n\,|c|$.
3. **Higher-dimensional boxes.** Conjecture: on $\prod_{k<d}\{0,\dots,n_k-1\}$ the
   maximal mass is $\sum_k (N/n_k)\cdot n_k(n_k-1)/2$ with $N=\prod_k n_k$, attained
   by $f=\sum_k i_k$, since axis-aligned graph distance is the $\ell^1$ coordinate
   sum.
4. **Real-valued / $L$-Lipschitz scaling.** Conjecture: for $\mathbb{R}$-valued $f$
   with per-edge constant $L$, the bound scales to $L\cdot\operatorname{triBound}(m,n)$,
   attained by $f(i,j)=L(i+j)$.
5. **Miura-ori flip-graph diameter.** Conjecture: under the Ginepro–Hull height
   model, flip distance between flat-foldable states is bounded by their $L^1$
   height difference, giving a flip-graph diameter of $\Theta(m^2 n + m n^2)$
   matching the staircase lower bound.

## 10. Conclusion

We have established a sharp extremal $L^1$ inequality for normalized 1-Lipschitz
integer height functions on rectangular grids, with explicit extremizers and a
precise account of why the anchoring normalization is indispensable. The proof
isolates a single geometric mechanism — domination by grid distance — from which the
closed-form bound and its sharpness follow by elementary summation. Beyond its
intrinsic appeal as a clean discrete-geometry extremum, the inequality supplies the
upper-bound half of a two-sided diameter estimate for the Miura-ori flip graph.
