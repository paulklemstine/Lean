# The Fractional Independence Number and Its Sparse-Threshold Sandwich

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty / Extremal Combinatorics & Combinatorial Optimization

## Abstract

The fractional independence number $\alpha^*(G)$ of a finite simple graph $G$ is the
optimal value of the linear-programming relaxation of the maximum independent set
problem: maximize $\sum_v x_v$ subject to $0 \le x_v \le 1$ for every vertex and
$x_u + x_v \le 1$ for every edge $uv$. This quantity is the structural object that
the sparse threshold conjecture of Day and Sarkar predicts will control both the
threshold exponent and the extremal graphon of the sparse subgraph-density problem.
We give a self-contained development of $\alpha^*$ built as a genuine supremum over
the feasible polytope, and prove the structural bounds the threshold theory
requires. Our main results are: (i) the universal **sandwich**
$\tfrac{n}{2} \le \alpha^*(G) \le n$, where $n = |V(G)|$, with the lower bound
certified by the constant assignment $x \equiv \tfrac12$; (ii) a **single-edge
ceiling theorem**, $\alpha^*(G) \le n - 1$ whenever $G$ has an edge, so that graphs
without isolated vertices never attain the trivial value $n$; and (iii) the exact
**complete-graph value** $\alpha^*(K_n) = \tfrac{n}{2}$ for $n \ge 2$, proved by a
double-counting argument that is the LP-dual fractional vertex cover in disguise.
All results are accompanied by full proof sketches and have been verified as
machine-checked formal proofs. We close with a program of four conjectural
directions linking $\alpha^*$ to the closed form of the extremal threshold constant
and to the half-integrality of the fractional-independence polytope.

---

## 1. Introduction

### 1.1 Motivation

The **maximum independent set** problem — find the largest set of pairwise
non-adjacent vertices in a graph — is among the canonical NP-hard problems. Its
**linear programming relaxation** replaces the indicator $x_v \in \{0,1\}$ of "$v$
is in the independent set" by a continuous variable $x_v \in [0,1]$, subject to the
edge constraints $x_u + x_v \le 1$. The optimal value of this relaxation is the
**fractional independence number** $\alpha^*(G)$. Because every genuine independent
set yields a feasible $\{0,1\}$-point, we always have $\alpha(G) \le \alpha^*(G)$,
where $\alpha(G)$ is the (integral) independence number.

Beyond its role as a tractable surrogate for $\alpha(G)$, the fractional
independence number is the pivot of a modern thread in extremal graph theory. The
**sparse threshold conjecture** of Day and Sarkar predicts that, for a fixed graph
$H$ without isolated vertices, the exponent and the extremal graphon of the sparse
subgraph-density problem are governed by $\alpha^*(H)$. The extremal graphons are
conjectured to be **three-step threshold graphons** — measurable limit objects built
from exactly three blocks — and the constant $C_T(H)$ achieving the supremum is the
unique maximizer of an associated one-dimensional variational problem.

To put this theory on rigorous footing one must first establish the basic
structural anatomy of $\alpha^*$. That is the purpose of this paper.

### 1.2 Contributions

We work with a finite vertex type $V$ (so $n := |V|$ is finite) and an arbitrary
simple graph $G$ on $V$. We:

1. Define $\alpha^*(G)$ as the supremum of the achievable LP values over the
   feasible polytope, and verify the supremum is well posed (the feasible set is
   nonempty and the value set is bounded above).
2. Prove the **sandwich** $\tfrac{n}{2} \le \alpha^*(G) \le n$
   (Theorems 3.4 and 3.6).
3. Prove the **single-edge ceiling**: one edge forces $\alpha^*(G) \le n - 1$
   (Theorem 3.7).
4. Compute the **complete-graph value** $\alpha^*(K_n) = \tfrac n2$ for $n \ge 2$
   (Theorem 3.8).

All statements correspond verbatim to machine-verified declarations.

### 1.3 Background: relaxation, duality, and why $\alpha^*$ is the right invariant

The maximum independent set problem can be written as the integer program
$$\alpha(G) = \max\Big\{ \textstyle\sum_v x_v : x_v \in \{0,1\},\ x_u + x_v \le 1\ \forall uv \in E \Big\}.$$
Dropping the integrality requirement $x_v \in \{0,1\}$ to the interval $x_v \in [0,1]$
produces a linear program whose optimum is $\alpha^*(G)$. Two general principles of
linear programming make $\alpha^*$ a far more tractable object than $\alpha$:

1. **Relaxation inequality.** Every integer-feasible point is LP-feasible, so
   $\alpha(G) \le \alpha^*(G)$ always. The ratio $\alpha^*(G)/\alpha(G)$, the
   *integrality gap*, measures how much the relaxation overshoots; bounding it is the
   engine behind approximation algorithms.

2. **LP duality.** The dual of the fractional independence LP is the **fractional
   vertex cover** LP,
   $$\tau^*(G) = \min\Big\{ \textstyle\sum_v y_v : y_v \ge 0,\ y_u + y_v \ge 1\ \forall uv \in E \Big\},$$
   and any feasible dual solution upper-bounds $\alpha^*$ (weak duality). The double
   count used in Theorem 3.8 is exactly the exhibition of a uniform optimal dual
   solution for the complete graph: assigning weight $\tfrac{1}{n-1}$ to a suitable
   covering structure reproduces the bound $\alpha^* \le \tfrac n2$.

The reason $\alpha^*$ — rather than $\alpha$ — governs the sparse threshold problem is
that the threshold question is itself a *continuous* optimization over graphons (measurable
$[0,1]^2 \to [0,1]$ kernels), and the relevant extremal structure is half-integral. The
fractional independence polytope is the finite-dimensional shadow of that continuous
problem: its half-integral $\{0, \tfrac12, 1\}$ vertices correspond to the three blocks of
a three-step threshold graphon, and its LP value pins the threshold exponent. Establishing
the elementary geometry of this polytope — which is what the present paper does — is the
prerequisite for the analytic threshold statements.

---

## 2. Definitions

Throughout, $V$ is a finite type with decidable equality, $G$ is a
`SimpleGraph` on $V$, $n := |V|$ is its number of vertices, and `G.Adj u v`
denotes adjacency. A *fractional point* is a function $x : V \to \mathbb{R}$.

**Definition 2.1 (Feasibility; `FracIndepFeasible`).**
A point $x : V \to \mathbb{R}$ is *feasible* for $G$, written $\mathrm{Feas}_G(x)$,
if
$$\big(\forall v,\; 0 \le x_v \le 1\big)\quad\text{and}\quad
\big(\forall u\,v,\; G.\mathrm{Adj}\,u\,v \Rightarrow x_u + x_v \le 1\big).$$
The set of feasible points is the **fractional-independence polytope** of $G$.

**Definition 2.2 (Value; `fracIndepValue`).**
The *value* of a point $x$ is its total mass
$$\mathrm{val}(x) \;:=\; \sum_{v \in V} x_v.$$

**Definition 2.3 (Value set; `fracIndepValueSet`).**
The set of achievable LP values is
$$\mathcal{S}(G) \;:=\; \{\, s \in \mathbb{R} \mid \exists x,\ \mathrm{Feas}_G(x)\ \wedge\ s = \mathrm{val}(x) \,\}.$$

**Definition 2.4 (Fractional independence number; `alphaStar`).**
The **fractional independence number** is
$$\alpha^*(G) \;:=\; \sup \mathcal{S}(G),$$
the supremum of all achievable values over the feasible polytope.

> *Remark.* Defining $\alpha^*$ as a real supremum (rather than asserting an
> attained maximum) is the honest formalization: it requires us to certify that the
> supremum is well behaved, which we do in §3.1. Because the polytope is compact and
> the objective continuous, the supremum is in fact attained, but no result below
> relies on attainment.

---

## 3. Main results

### 3.1 The supremum is well posed

**Lemma 3.1 (Nonemptiness; `fracIndepValueSet_nonempty`).**
$\mathcal{S}(G) \ne \varnothing$.

*Proof sketch.* The all-zeros point $x \equiv 0$ is feasible: every coordinate is
$0 \in [0,1]$, and every edge constraint reads $0 + 0 = 0 \le 1$. Its value is $0$,
so $0 \in \mathcal{S}(G)$. $\square$

**Lemma 3.2 (Value bound; `fracIndepValue_le_card`).**
If $\mathrm{Feas}_G(x)$ then $\mathrm{val}(x) \le n$.

*Proof sketch.* Each coordinate satisfies $x_v \le 1$ by feasibility, so
$\sum_v x_v \le \sum_v 1 = n$ by monotonicity of finite sums. $\square$

**Lemma 3.3 (Bounded above; `fracIndepValueSet_bddAbove`).**
$\mathcal{S}(G)$ is bounded above, with $n$ an explicit upper bound.

*Proof sketch.* Any element of $\mathcal{S}(G)$ equals $\mathrm{val}(x)$ for some
feasible $x$, hence is $\le n$ by Lemma 3.2. $\square$

Lemmas 3.1 and 3.3 together guarantee that $\sup \mathcal{S}(G)$ is a finite real
number and that the order-theoretic facts `le_csSup` (a member is $\le$ the sup) and
`csSup_le` (the sup is $\le$ any upper bound) apply.

### 3.2 The universal sandwich

**Theorem 3.4 (Ceiling; `alphaStar_le_card`).**
For every simple graph $G$ on $n$ vertices,
$$\alpha^*(G) \le n.$$

*Proof sketch.* By `csSup_le` it suffices to bound every member of $\mathcal{S}(G)$
by $n$. Each such member is $\mathrm{val}(x)$ for a feasible $x$, and
$\mathrm{val}(x) \le n$ by Lemma 3.2. $\square$

**Lemma 3.5 (All-half feasibility; `half_feasible`).**
The constant assignment $x \equiv \tfrac12$ is feasible for every $G$.

*Proof sketch.* Each coordinate is $\tfrac12 \in [0,1]$, and every edge constraint
reads $\tfrac12 + \tfrac12 = 1 \le 1$. The verification is uniform in $G$: no
property of the edge set is used beyond the arithmetic identity
$\tfrac12 + \tfrac12 = 1$. $\square$

**Theorem 3.6 (Universal floor; `half_card_le_alphaStar`).**
For every simple graph $G$ on $n$ vertices,
$$\frac{n}{2} \le \alpha^*(G).$$

*Proof sketch.* By Lemma 3.5 the all-half point is feasible, and its value is
$\sum_v \tfrac12 = \tfrac n2$. Hence $\tfrac n2 \in \mathcal{S}(G)$, and by
`le_csSup` (using Lemma 3.3 for boundedness) we obtain
$\tfrac n2 \le \sup \mathcal{S}(G) = \alpha^*(G)$. $\square$

Combining Theorems 3.4 and 3.6 yields the **sandwich**
$$\boxed{\ \frac n2 \;\le\; \alpha^*(G) \;\le\; n\ }$$
for every finite simple graph $G$. The lower bound is *certified by a single
explicit point*, the all-half assignment, and therefore holds uniformly across all
graphs regardless of structure.

### 3.3 One edge breaks the ceiling

**Theorem 3.7 (Single-edge ceiling; `alphaStar_le_card_sub_one_of_edge`).**
If $G.\mathrm{Adj}\,a\,b$ for some vertices $a, b$, then
$$\alpha^*(G) \le n - 1.$$

*Proof sketch.* It suffices, by `csSup_le`, to show every feasible $x$ satisfies
$\mathrm{val}(x) \le n - 1$. Fix feasible $x$. The edge $ab$ contributes the
constraint $x_a + x_b \le 1$. Split the total:
$$\sum_{v \in V} x_v \;=\; \big(x_a + x_b\big) \;+\; \sum_{v \in V \setminus \{a,b\}} x_v.$$
For the second sum, each of the $n - 2$ remaining coordinates is $\le 1$, so
$$\sum_{v \in V \setminus \{a,b\}} x_v \;\le\; n - 2,$$
using the cardinality computation $|V \setminus \{a,b\}| = n - 2$ (valid because
$a \ne b$, as $a$ and $b$ are adjacent in a simple graph, and $n \ge 2$). Adding the
edge bound gives $\mathrm{val}(x) \le 1 + (n - 2) = n - 1$. $\square$

**Corollary 3.7.1 (No isolated vertices ⇒ $\alpha^* < n$).**
If $G$ has no isolated vertex then $G$ has an edge, so $\alpha^*(G) \le n - 1 < n$.
The trivial maximum $\alpha^* = n$ is attained only by edgeless graphs (collections
of isolated vertices). This is precisely the regime excluded in the Day–Sarkar
hypothesis "$H$ without isolated vertices."

### 3.4 The complete graph attains the floor

**Theorem 3.8 (Complete-graph value; `alphaStar_completeGraph`).**
If $n \ge 2$ then for the complete graph $K_n = \top$ on $V$,
$$\alpha^*(K_n) = \frac{n}{2}.$$

*Proof sketch.* The lower bound $\tfrac n2 \le \alpha^*(K_n)$ is Theorem 3.6
specialized to $G = \top$. For the upper bound, let $x$ be any feasible point. In
$K_n$ every pair of distinct vertices is adjacent, so $x_u + x_v \le 1$ for all
$u \ne v$. Sum this over all ordered pairs of distinct vertices:
$$\sum_{u \in V}\ \sum_{v \in V \setminus \{u\}} \big(x_u + x_v\big)
\;\le\; \sum_{u \in V}\ \sum_{v \in V \setminus \{u\}} 1
\;=\; n(n-1).$$
The left-hand side, by linearity, equals
$$\sum_{u}\sum_{v \ne u}(x_u + x_v) = \sum_u (n-1)\,x_u + \sum_u \sum_{v \ne u} x_v
= (n-1)\sum_u x_u + (n-1)\sum_v x_v = 2(n-1)\,\mathrm{val}(x),$$
because each coordinate $x_w$ is counted $n-1$ times "as $u$" and $n-1$ times "as
$v$." Therefore
$$2(n-1)\,\mathrm{val}(x) \le n(n-1).$$
Since $n \ge 2$ gives $n - 1 > 0$, we may divide to obtain
$\mathrm{val}(x) \le \tfrac n2$. Taking the supremum over feasible $x$ yields
$\alpha^*(K_n) \le \tfrac n2$. Together with the lower bound, equality holds.
$\square$

> *Why $n \ge 2$ is necessary.* For $n = 1$, the graph $K_1$ is edgeless, so the
> all-ones point $x \equiv 1$ is feasible with value $1$; hence $\alpha^*(K_1) = 1$,
> not $\tfrac12$. The hypothesis $n \ge 2$ is kept honestly and is load-bearing in
> the division step $n - 1 > 0$.

### 3.5 The dual reading

The factor $2(n-1)$ in the double count of Theorem 3.8 is exactly $2\deg(v)$ for any
vertex $v$ in $K_n$, since every vertex has degree $n - 1$. The argument is, in
disguise, the construction of an optimal **fractional vertex cover** — the LP dual
of fractional independence. LP duality guarantees the two optimal values coincide,
and Theorem 3.8 exhibits this coincidence explicitly for complete graphs: the primal
optimum $\tfrac n2$ equals the value certified by the uniform dual weights.

### 3.6 Robustness and sharpness of the bounds

It is worth emphasizing how little each bound assumes, and how tight each one is.

- **The floor is graph-independent.** Theorem 3.6 uses *no* property of the edge set
  beyond the arithmetic fact $\tfrac12 + \tfrac12 = 1$. Consequently the floor $\tfrac n2$
  holds simultaneously for all $2^{\binom n2}$ graphs on a fixed vertex set, and it is
  attained (Theorem 3.8) by the densest graph, the complete graph. No graph dips below it.

- **The ceiling is attained only by the edgeless graph.** Equality $\alpha^*(G) = n$
  requires a feasible point of value $n$, which forces $x_v = 1$ for all $v$; this is
  feasible iff no edge exists. Theorem 3.7 quantifies the first deviation: each edge
  removes a full unit. A graph with $k$ vertex-disjoint edges (a matching of size $k$)
  therefore satisfies $\alpha^*(G) \le n - k$, by iterating the split argument over the
  matching — a direct strengthening of Theorem 3.7 that the same proof technique yields.

- **Sharpness of the sandwich endpoints.** Both endpoints are achieved within the family
  of graphs on $n$ vertices: the floor by $K_n$ (Theorem 3.8) and the ceiling by the
  empty graph $\overline{K_n}$. Thus the interval $[\tfrac n2, n]$ is the exact range of
  $\alpha^*$ as $G$ varies, and no smaller interval suffices.

**Example 3.6.1 (perfect matching).** Let $M_n$ be a perfect matching on $n = 2m$
vertices ($m$ disjoint edges). The all-half point gives $\alpha^* \ge m = \tfrac n2$, while
the iterated single-edge argument gives $\alpha^* \le n - m = m$. Hence
$\alpha^*(M_n) = \tfrac n2$, so a perfect matching — a sparse graph — already sits exactly
on the floor, just like the complete graph. This shows the floor is attained across a wide
structural spectrum, from maximally sparse to maximally dense, whenever every vertex is
saturated by the constraints.

---

## 4. Algorithmic perspective

Although our results are exact and structural, they translate directly into
computation.

### 4.1 Exact LP evaluation

For a concrete graph $G$, $\alpha^*(G)$ is the optimum of an explicit linear program
in $n$ variables with one box constraint per vertex and one constraint per edge. Any
LP solver computes it in polynomial time. The sandwich
$\tfrac n2 \le \alpha^*(G) \le n$ provides immediate sanity bounds on the output,
and the single-edge theorem provides the sharper ceiling $n - 1$ whenever the graph
has any edge.

### 4.2 The half-integral certificate

The all-half point gives an $O(1)$-to-write, always-feasible solution of value
$\tfrac n2$. More is conjecturally true (Nemhauser–Trotter; see §6): the polytope
has an optimal vertex with all coordinates in $\{0, \tfrac12, 1\}$. When available,
such a half-integral optimum can be **rounded**: keep the $x_v = 1$ vertices, drop
the $x_v = 0$ vertices, and resolve the $\tfrac12$-block, losing at most a factor of
two — the classical $2$-approximation pipeline for the dual vertex-cover problem.

### 4.3 Pseudocode (sandwich-certified LP)

```
Input:  finite simple graph G = (V, E), n = |V|
Output: alpha*(G) with certified bounds

1. Build LP:   maximize sum_v x_v
               subject to 0 <= x_v <= 1   for v in V
                          x_u + x_v <= 1   for uv in E
2. opt <- solve_LP(LP)                      # polynomial time
3. lower <- n / 2                           # all-half certificate (Thm 3.6)
4. upper <- (E is empty) ? n : n - 1        # ceiling / single-edge (Thm 3.4, 3.7)
5. assert lower <= opt <= upper
6. if G == complete_graph(n) and n >= 2:
       assert opt == n / 2                  # Thm 3.8
7. return opt
```

---

## 5. Applications and worked examples

**Example 5.1 (4-cycle $C_4$).** Vertices $\{1,2,3,4\}$, edges $12,23,34,41$. The
all-half point scores $2 = \tfrac42$; the sandwich gives $2 \le \alpha^* \le 4$;
the single-edge theorem sharpens to $\alpha^* \le 3$. The true LP optimum is $2$
(attained by all-half, and also by the integral independent set $\{1,3\}$), so here
$\alpha^*(C_4) = \alpha(C_4) = 2$: relaxation is tight.

**Example 5.2 (complete graph $K_4$).** By Theorem 3.8, $\alpha^*(K_4) = 2$. Yet the
integral independence number is $\alpha(K_4) = 1$. The integrality gap
$\alpha^*/\alpha = 2$ is the worst possible for vertex-cover-type problems and is
realized exactly on complete graphs.

**Example 5.3 (path $P_3$).** Vertices $\{1,2,3\}$, edges $12, 23$. The all-half
point scores $\tfrac32$; the single-edge theorem gives $\alpha^* \le 2$. The optimum
is $2$, attained by $x = (1, 0, 1)$ — an integral independent set. So
$\tfrac32 \le \alpha^*(P_3) = 2 \le 2$, consistent with the bounds, and here the
floor is *not* tight.

These examples illustrate the two extremes: dense graphs sit on the floor (Example
5.2), while graphs with large independent sets push toward the ceiling, capped by
the single-edge theorem (Example 5.3).

---

## 6. Discussion and future work

The results above are the structural backbone the sparse threshold theory needs.
They were established as part of a cycle that also proved, in a companion variational
analysis, that the reduced three-step objective $J(s,t) = t - t^s$ is strictly
concave on $[0,1]$ for $s \ge 2$, hence has a unique interior maximizer with value
$C_T(s) \in (0,1)$, monotone in $s$. The following directions, derived from this
cycle, remain open.

**Direction 1 — Closed form of the extremal constant.** *Conjecture:* for every
$s \ge 2$ the maximizer of $J(s,\cdot)$ is $t^*(s) = s^{-1/(s-1)}$ and the extremal
constant is $C_T(s) = (1 - 1/s)\,s^{-1/(s-1)}$, with $C_T(s) \uparrow 1$ as
$s \to \infty$. Strict concavity already forces uniqueness, so only the first-order
condition $1 - s\,t^{s-1} = 0$ remains — an `rpow` computation rather than a new
optimization.

**Direction 2 — $\alpha^*$ controls the exponent.** *Conjecture:* the correct
structural exponent in the three-step objective is $s = \alpha^*(H)$ (allowing real
$s \ge 2$ via `rpow`), so the extremal constant of the sparse threshold problem is
exactly $C_T(\alpha^*(H))$. Both objects are governed by the same half-integral
polytope: the $\alpha^*$-LP optimum and the three-step core measure are dual
descriptions of one extremal structure.

**Direction 3 — Strict monotonicity and the dense limit.** *Conjecture:* $C_T$ is
strictly increasing in $s$ and $\lim_{s \to \infty} C_T(s) = 1$. The pointwise gap
$J(s+1, t) - J(s, t) = t^s - t^{s+1} = t^s(1 - t) > 0$ on $(0,1)$ should upgrade the
known weak monotonicity to strict and force the limit.

**Direction 4 — Half-integrality of the $\alpha^*$-polytope (Nemhauser–Trotter).**
*Conjecture:* every vertex of the fractional-independence polytope is half-integral —
there is an optimal $x$ with $x_v \in \{0, \tfrac12, 1\}$ for all $v$. The all-half
point is a universal feasible certificate (already used for the lower bound), and the
three-block $\{0, \tfrac12, 1\}$ structure mirrors the three steps of the extremal
graphon.

---

## 7. Conclusion

We have given a clean, fully verified account of the fractional independence number
$\alpha^*(G)$ as a supremum over the feasible polytope, and established the structural
sandwich $\tfrac n2 \le \alpha^*(G) \le n$, the single-edge ceiling $n - 1$, and the
exact complete-graph value $\tfrac n2$. The recurring hero is the all-half
assignment: a single, structure-blind point that certifies the universal lower bound
and foreshadows the half-integral, three-block geometry conjectured to govern the
extremal graphons of the sparse threshold problem. With this anatomy in hand, the
identification of the exponent with $\alpha^*$ and the closed form of the extremal
constant become the natural next theorems.
