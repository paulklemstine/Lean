# Finite Optimal Transport and Wasserstein Distances: Existence, Brenier Rearrangement, and the Metric Axioms

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Optimal Transport)

## Abstract

We develop a fully rigorous, self-contained theory of *finite* optimal
transport: the Kantorovich problem of moving one discrete probability
distribution onto another at minimum cost. Working over finite index sets, we
define transport plans as the elements of the transportation polytope, define
the transport cost as a linear functional, and establish the foundational
results of the theory. First, we prove that the transportation polytope is
compact and that an **optimal transport plan always exists** (existence of a
minimizer of a continuous linear functional over a nonempty compact convex set).
Second, restricting to uniform marginals, we identify permutation couplings with
the assignment problem, proving that **permutation plans are feasible** and that
their cost is the average edge cost. Third, we prove a **discrete Brenier
theorem** for quadratic cost: when source and target data covary, the monotone
(sorted) matching is optimal among all matchings, and we restate this inside the
Kantorovich polytope. Finally, we define the **Wasserstein value** as the
optimal transport cost and verify three of the four metric axioms —
nonnegativity, vanishing self-distance, and symmetry. We discuss the remaining
triangle inequality, the Birkhoff–von Neumann extension from permutations to the
full polytope, and Kantorovich–Rubinstein duality as natural next steps. All
results are stated with full mathematical content and proof sketches.

---

## 1. Introduction

Optimal transport asks for the most economical way to rearrange one distribution
of mass into another. Introduced by Monge in 1781 as a problem about moving
earthworks and recast by Kantorovich in 1942 as a linear program, the subject
has become a central tool across pure and applied mathematics: it furnishes a
geometry-aware metric on probability distributions (the Wasserstein distance),
underpins the analysis of gradient flows and PDEs, and drives modern generative
modeling through the Wasserstein GAN.

This paper treats the **finite** case in complete rigor. The finite setting is
not merely a toy: it is the regime in which optimal transport is actually
computed, it is the discrete shadow of the continuous theory, and it already
exhibits the structural phenomena — existence of optimizers, the matching/sorting
correspondence, and the metric structure — that make the subject powerful. By
restricting to finite index sets we replace measure-theoretic subtleties with
clean linear algebra and combinatorics, allowing every claim to be proved from
first principles.

Our contributions are organized as four pillars:

1. **Existence** (Section 4): the transportation polytope is compact and the
   transport cost attains its minimum.
2. **Matchings** (Section 5): permutation couplings of uniform marginals are
   feasible and realize the assignment-problem cost.
3. **Brenier rearrangement** (Section 6): for quadratic cost, the monotone
   matching is optimal.
4. **Wasserstein metric axioms** (Section 7): nonnegativity, self-distance zero,
   and symmetry of the optimal cost.

---

## 2. Preliminaries and Notation

Let $S$ and $T$ be finite index sets (the *sources* and *targets*). We write
$|S| = n$ and $|T| = m$, and frequently take $S = T = \{1, \dots, n\}$.

A **probability vector** on a finite set $X$ is a function $a : X \to \mathbb{R}$
with $a_x \ge 0$ for all $x$ and $\sum_{x} a_x = 1$. We write $\Delta(X)$ for the
set of probability vectors on $X$ (the standard simplex).

A **cost matrix** (or **ground cost**) is a function $d : S \times T \to
\mathbb{R}$ with $d_{ij} \ge 0$. When $S = T$ and $d$ models a distance we will
additionally assume $d_{ii} = 0$ (self-cost zero), $d_{ij} = d_{ji}$ (symmetry),
and, where stated, the triangle inequality $d_{ik} \le d_{ij} + d_{jk}$.

---

## 3. The Kantorovich Problem

**Definition 3.1 (Transport plan / coupling).**
Given marginals $a \in \Delta(S)$ and $b \in \Delta(T)$, a **transport plan** is
a function $\pi : S \times T \to \mathbb{R}$ satisfying

$$\pi_{ij} \ge 0 \ \ \forall (i,j), \qquad
\sum_{j \in T} \pi_{ij} = a_i \ \ \forall i \in S, \qquad
\sum_{i \in S} \pi_{ij} = b_j \ \ \forall j \in T.$$

We call the predicate "$\pi$ satisfies these constraints for marginals $a, b$"
the property `IsTransportPlan`. The set of all such $\pi$ is the
**transportation polytope** (the **feasible set**), denoted $\Pi(a,b)$.

**Remark 3.2.** $\Pi(a,b)$ is nonempty: the *independent coupling*
$\pi_{ij} = a_i b_j$ is always feasible, since
$\sum_j a_i b_j = a_i \sum_j b_j = a_i$ and symmetrically for columns.

**Definition 3.3 (Transport cost).**
The cost of a plan $\pi$ under ground cost $d$ is the linear functional

$$\operatorname{transportCost}(d, \pi) \;=\; \sum_{i \in S} \sum_{j \in T}
\pi_{ij}\, d_{ij}.$$

**Definition 3.4 (Wasserstein value / Kantorovich optimum).**
The **Wasserstein value** is the optimal transport cost,

$$\operatorname{wValue}(d, a, b) \;=\; \inf_{\pi \in \Pi(a,b)}
\operatorname{transportCost}(d, \pi).$$

By Theorem 4.2 below the infimum is attained, so it is in fact a minimum.

---

## 4. Existence of Optimal Plans

The first pillar is that the Kantorovich problem is well posed: a cheapest plan
exists.

**Theorem 4.1 (`isCompact_feasibleSet`).**
The transportation polytope $\Pi(a,b)$ is compact.

*Proof sketch.* View a plan as a point in $\mathbb{R}^{S \times T}$, a finite
dimensional real vector space. The polytope is the intersection of:

- the closed half-spaces $\{\pi_{ij} \ge 0\}$, one for each coordinate;
- the closed affine subspaces $\{\sum_j \pi_{ij} = a_i\}$ and
  $\{\sum_i \pi_{ij} = b_j\}$, defined by continuous linear maps.

Each of these is closed, and a finite intersection of closed sets is closed.
For boundedness, every feasible $\pi$ has $0 \le \pi_{ij} \le a_i \le 1$ (since
$\pi_{ij} \le \sum_{j'} \pi_{ij'} = a_i$ by nonnegativity of the other entries),
so the polytope lies in the cube $[0,1]^{S \times T}$. A closed and bounded
subset of a finite-dimensional real vector space is compact by the
Heine–Borel theorem. $\qquad\blacksquare$

**Theorem 4.2 (`exists_optimal_plan`).**
There exists a plan $\pi^\star \in \Pi(a,b)$ such that
$\operatorname{transportCost}(d, \pi^\star) \le \operatorname{transportCost}(d,
\pi)$ for every $\pi \in \Pi(a,b)$.

*Proof sketch.* The map $\pi \mapsto \operatorname{transportCost}(d, \pi) =
\sum_{i,j} \pi_{ij} d_{ij}$ is linear, hence continuous on the finite
dimensional space $\mathbb{R}^{S \times T}$. By Theorem 4.1 the feasible set is
compact, and by Remark 3.2 it is nonempty. A continuous real-valued function on
a nonempty compact set attains its infimum (extreme value theorem); the
minimizer $\pi^\star$ is the desired optimal plan. $\qquad\blacksquare$

**Corollary 4.3.** $\operatorname{wValue}(d, a, b) =
\operatorname{transportCost}(d, \pi^\star)$ is attained, so the infimum in
Definition 3.4 is a minimum.

These two theorems are the load-bearing foundation: every subsequent statement
about *the* optimal cost is meaningful precisely because the optimum exists.

---

## 5. Permutation Plans and the Assignment Problem

We now specialize to **uniform marginals** on a common index set
$S = T = \{1, \dots, n\}$: $a_i = b_i = 1/n$ for all $i$. Here matchings enter.

**Definition 5.1 (Permutation plan).**
For a permutation $\sigma$ of $\{1, \dots, n\}$, the **permutation plan**
$\operatorname{permPlan}(\sigma)$ is

$$(\operatorname{permPlan}\sigma)_{ij} =
\begin{cases} \dfrac{1}{n}, & j = \sigma(i),\\[4pt] 0, & j \ne \sigma(i).
\end{cases}$$

**Theorem 5.2 (`permPlan_isTransportPlan`).**
For every permutation $\sigma$, $\operatorname{permPlan}(\sigma)$ is a transport
plan for the uniform marginals; i.e. it is feasible.

*Proof sketch.* Nonnegativity is immediate. For the row sums, fix $i$; exactly
one term $j = \sigma(i)$ is nonzero, giving $\sum_j (\operatorname{permPlan}
\sigma)_{ij} = 1/n = a_i$. For the column sums, fix $j$; since $\sigma$ is a
bijection there is a unique $i = \sigma^{-1}(j)$ with $\sigma(i) = j$, so
$\sum_i (\operatorname{permPlan}\sigma)_{ij} = 1/n = b_j$. $\qquad\blacksquare$

**Theorem 5.3 (`transportCost_permPlan`).**
The cost of a permutation plan is the average of its matched edge costs:

$$\operatorname{transportCost}(d, \operatorname{permPlan}\sigma) =
\frac{1}{n} \sum_{i=1}^{n} d_{i, \sigma(i)}.$$

*Proof sketch.* Substitute the definition: $\sum_{i,j}
(\operatorname{permPlan}\sigma)_{ij} d_{ij} = \sum_i \sum_j
(\operatorname{permPlan}\sigma)_{ij} d_{ij}$. The inner sum collapses to the
single term $j = \sigma(i)$, contributing $\tfrac{1}{n} d_{i,\sigma(i)}$.
$\qquad\blacksquare$

**Remark 5.4 (Reduction to the assignment problem).**
Minimizing $\operatorname{transportCost}$ over permutation plans is exactly the
classical **assignment problem**: choose $\sigma$ minimizing
$\sum_i d_{i,\sigma(i)}$. The Birkhoff–von Neumann theorem (Section 8) implies
that for uniform marginals this discrete minimum over permutations coincides
with the continuous minimum over the entire polytope, because the vertices of
the doubly stochastic (Birkhoff) polytope are exactly the permutation matrices
and a linear functional attains its extremum at a vertex.

---

## 6. The Discrete Brenier Theorem for Quadratic Cost

We come to the structural jewel of the theory: for *quadratic* cost the optimal
matching is monotone (sorted). This is the finite-dimensional incarnation of
Brenier's theorem.

Fix real data $x_1, \dots, x_n$ (source positions) and $y_1, \dots, y_n$ (target
positions). The **quadratic ground cost** is $d_{ij} = (x_i - y_j)^2$.

**Definition 6.1 (Monovary).**
The families $x$ and $y$ **monovary** (covary, written $\operatorname{Monovary}
x\,y$) if for all indices $i, k$, $x_i < x_k \implies y_i \le y_k$ — equivalently,
sorting $x$ in increasing order sorts $y$ in increasing order too. Any two
families become monovarying after sorting both increasingly.

**Lemma 6.2 (Rearrangement inequality).**
Among all permutations $\sigma$, the cross-correlation $\sum_i x_i\,
y_{\sigma(i)}$ is **maximized** when $x$ and $y \circ \sigma$ monovary and
**minimized** when they antivary. In particular, if $x$ and $y$ already
monovary, the identity permutation maximizes $\sum_i x_i y_{\sigma(i)}$.

*Proof sketch.* The exchange argument: if some pair is "out of order"
($x_i < x_k$ but $y_{\sigma(i)} > y_{\sigma(k)}$), swapping the images of $i$ and
$k$ changes the sum by $(x_i - x_k)(y_{\sigma(k)} - y_{\sigma(i)}) > 0$, strictly
increasing it. Hence no maximizer has an inversion, so a sorted (monovarying)
assignment is optimal. $\qquad\blacksquare$

**Theorem 6.3 (`brenier_monotone_optimal`).**
Suppose $x$ and $y$ monovary. Then the **identity matching** minimizes the
quadratic transport cost among all permutation matchings: for every permutation
$\sigma$,

$$\sum_{i} (x_i - y_i)^2 \;\le\; \sum_{i} (x_i - y_{\sigma(i)})^2.$$

*Proof sketch.* Expand the square:
$$\sum_i (x_i - y_{\sigma(i)})^2 = \sum_i x_i^2 - 2\sum_i x_i y_{\sigma(i)} +
\sum_i y_{\sigma(i)}^2.$$
The first sum is independent of $\sigma$, and the last sum equals
$\sum_j y_j^2$ for every permutation (a permutation only reindexes). Hence
minimizing the quadratic cost is equivalent to **maximizing** the cross term
$\sum_i x_i y_{\sigma(i)}$. By Lemma 6.2, since $x$ and $y$ monovary, this
maximum is attained at $\sigma = \mathrm{id}$. $\qquad\blacksquare$

**Theorem 6.4 (`perm_quadratic_optimal`, Kantorovich-polytope restatement).**
For uniform marginals and quadratic cost with monovarying $x, y$, the identity
permutation plan $\operatorname{permPlan}(\mathrm{id})$ minimizes
$\operatorname{transportCost}$ among **all permutation plans**:

$$\operatorname{transportCost}(d, \operatorname{permPlan}(\mathrm{id})) \le
\operatorname{transportCost}(d, \operatorname{permPlan}(\sigma)) \quad
\forall \sigma.$$

*Proof sketch.* Apply Theorem 5.3 to both sides: each cost equals $\tfrac{1}{n}$
times the corresponding sum of matched squared distances. The inequality is then
exactly Theorem 6.3 divided by $n$. $\qquad\blacksquare$

**Interpretation.** Theorem 6.4 places the rearrangement result inside the
Kantorovich framework: the monotone coupling is the cheapest *coupling* (among
permutation couplings) for quadratic cost. Extending optimality from permutation
couplings to the full polytope is precisely where Birkhoff–von Neumann is needed
(Section 8), completing the discrete Brenier theorem.

---

## 7. Wasserstein Distances and the Metric Axioms

The optimal cost defines a candidate distance on probability vectors. We verify
three of the four metric axioms.

Throughout this section take $S = T$ and assume the ground cost $d$ is a genuine
**distance kernel**: $d_{ij} \ge 0$, $d_{ii} = 0$, and $d_{ij} = d_{ji}$.

**Theorem 7.1 (`wValue_nonneg`).**
$\operatorname{wValue}(d, a, b) \ge 0$.

*Proof sketch.* For any feasible $\pi$, every summand $\pi_{ij} d_{ij}$ is a
product of nonnegatives, so $\operatorname{transportCost}(d, \pi) \ge 0$. The
infimum of a set of nonnegative numbers is nonnegative. $\qquad\blacksquare$

**Theorem 7.2 (`wValue_self`).**
$\operatorname{wValue}(d, a, a) = 0$.

*Proof sketch.* Consider the **diagonal plan** $\pi_{ij} = a_i$ if $i = j$ and
$0$ otherwise. Its row sum at $i$ is $a_i$ and its column sum at $j$ is $a_j$, so
it is a feasible coupling of $a$ with itself. Its cost is
$\sum_i a_i\, d_{ii} = \sum_i a_i \cdot 0 = 0$. Combined with Theorem 7.1
($\operatorname{wValue} \ge 0$) and the fact that $0$ is achieved by a feasible
plan, the optimum is exactly $0$. $\qquad\blacksquare$

**Theorem 7.3 (`wValue_symm`).**
$\operatorname{wValue}(d, a, b) = \operatorname{wValue}(d, b, a)$.

*Proof sketch.* Define the **transpose** of a plan by
$\pi^{\top}_{ji} = \pi_{ij}$. If $\pi$ couples $a$ to $b$, then $\pi^{\top}$
couples $b$ to $a$: the row sums of $\pi^{\top}$ are the column sums of $\pi$
(equal to $b$) and vice versa. Because $d$ is symmetric,
$\operatorname{transportCost}(d, \pi^{\top}) = \sum_{j,i} \pi^{\top}_{ji} d_{ji}
= \sum_{i,j} \pi_{ij} d_{ij} = \operatorname{transportCost}(d, \pi)$.
Transposition is an involutive bijection $\Pi(a,b) \to \Pi(b,a)$ preserving cost,
so the two optimization problems have the same optimum. $\qquad\blacksquare$

**The fourth axiom (triangle inequality).** The remaining metric axiom,
$\operatorname{wValue}(d, a, c) \le \operatorname{wValue}(d, a, b) +
\operatorname{wValue}(d, b, c)$, requires the **gluing lemma** (Section 8) and is
not proved here; it is the single missing ingredient that would certify
$\operatorname{wValue}$ as a genuine metric on the simplex.

---

## 8. Discussion and Future Work

The four pillars above establish finite optimal transport on rigorous footing:
the problem is well posed (existence), it specializes to combinatorial matching
(permutation plans), it is solved by sorting for quadratic cost (Brenier), and
its optimum is a near-metric (three of four axioms). Three precise conjectures
mark the frontier.

### 8.1 The finite Wasserstein triangle inequality (gluing lemma)

**Conjecture.** For a nonnegative ground cost $d$ satisfying $d_{ik} \le d_{ij} +
d_{jk}$ and probability vectors $a, b, c$,
$\operatorname{wValue}(d, a, c) \le \operatorname{wValue}(d, a, b) +
\operatorname{wValue}(d, b, c)$.

The key idea is the **glued plan** $\gamma_{ik} = \sum_j \frac{\pi_{ij}
\sigma_{jk}}{b_j}$ (with the convention $0/0 = 0$, valid because $b_j = 0$ forces
the entire $j$-th slice of $\pi$ and $\sigma$ to vanish). One checks $\gamma$ is a
feasible coupling of $a$ and $c$, and its cost is bounded by
$\operatorname{cost}(\pi) + \operatorname{cost}(\sigma)$ termwise through
$d_{ik} \le d_{ij} + d_{jk}$. With existence of the optimal $\pi, \sigma$
(Theorem 4.2) and the polytope API already in hand, only the division-by-marginal
bookkeeping remains. This is the last metric axiom.

### 8.2 Birkhoff–von Neumann lifts Brenier to the full polytope

**Conjecture.** For quadratic cost with monovarying $x, y$, the identity coupling
$\operatorname{permPlan}(\mathrm{id})$ minimizes $\operatorname{transportCost}$
over the **entire** transportation polytope of uniform marginals, not merely over
permutation couplings.

The key idea is that the extreme points of the doubly stochastic (Birkhoff)
polytope are exactly the permutation matrices, so a linear functional attains its
minimum at a permutation; combined with Theorem 6.4 this yields global
optimality. We already have feasibility of permutation plans (Theorem 5.2), their
cost (Theorem 5.3), and compactness of the polytope (Theorem 4.1). A Lean proof of
Birkhoff–von Neumann (currently absent from Mathlib) is the only missing
ingredient.

### 8.3 Kantorovich–Rubinstein duality

**Conjecture.** $\operatorname{wValue}(d, a, b) = \sup \big\{ \sum_i a_i f_i -
\sum_j b_j g_j \big\}$ over potentials $f, g$ with $f_i - g_j \le d_{ij}$; i.e.
finite OT equals its linear-program dual.

The key idea is that the Kantorovich problem is a finite linear program over a
compact feasible set, so LP strong duality (no duality gap) applies and the dual
optimum is attained at a vertex of the potential polytope. We have already proved
the primal feasible set is compact and the objective linear/continuous — exactly
the hypotheses under which finite-dimensional LP duality holds.

### 8.4 Broader directions

Beyond these, natural extensions include: entropic regularization and the
Sinkhorn algorithm (adding $\varepsilon \sum \pi_{ij} \log \pi_{ij}$ to make the
problem strongly convex and solvable by alternating projections); the
$p$-Wasserstein family $W_p = (\operatorname{wValue}(d^p, \cdot, \cdot))^{1/p}$
and its metric structure; convergence of empirical measures (the statistical
rate at which sampled distributions approach their population in Wasserstein
distance); and the dynamic Benamou–Brenier formulation connecting OT to fluid
flow and gradient flows of entropy.

---

## 9. Conclusion

We have given a rigorous, self-contained account of finite optimal transport.
The transportation polytope is compact and an optimal plan always exists
(`isCompact_feasibleSet`, `exists_optimal_plan`); permutation plans realize the
assignment problem (`permPlan_isTransportPlan`, `transportCost_permPlan`);
quadratic cost is solved by the monotone matching (`brenier_monotone_optimal`,
`perm_quadratic_optimal`); and the optimal cost satisfies nonnegativity,
vanishing self-distance, and symmetry (`wValue_nonneg`, `wValue_self`,
`wValue_symm`). Together these results form the backbone of the Wasserstein
geometry that has reshaped probability, optimization, and machine learning, with
the triangle inequality, Birkhoff–von Neumann globalization, and LP duality
charted as the immediate next milestones.

## References (classical background, for context only)

- G. Monge, *Mémoire sur la théorie des déblais et des remblais*, 1781.
- L. V. Kantorovich, *On the translocation of masses*, 1942.
- Y. Brenier, *Polar factorization and monotone rearrangement of
  vector-valued functions*, Comm. Pure Appl. Math., 1991.
- C. Villani, *Optimal Transport: Old and New*, Springer, 2009.
- G. Peyré and M. Cuturi, *Computational Optimal Transport*, 2019.
- M. Arjovsky, S. Chintala, L. Bottou, *Wasserstein GAN*, 2017.
