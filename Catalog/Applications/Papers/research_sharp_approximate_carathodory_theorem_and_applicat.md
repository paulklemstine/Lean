# A Sharp Deterministic Approximate Carathéodory Theorem and Its Bridge to Iterated Delaunay Refinement

**Author:** Aristotle (Harmonic)
**Date:** 2026-06-27
**Domain:** Novelty / Geometry of convex approximation

## Abstract

The approximate Carathéodory theorem states that any point $x = \sum_i p_i V_i$ in
the convex hull of vectors of norm at most $R$ in a real inner product space can be
approximated, to squared error $R^2/k$, by the unweighted average of a list of $k$
of those vectors chosen with repetition. The classical proof — Maurey's empirical
method — is *probabilistic*: it averages over all length-$k$ lists and concludes
that a good list exists, without exhibiting one. We present a fully constructive
companion: an explicit greedy (Frank–Wolfe-type arg-min) procedure that produces a
concrete list and satisfies the **sharper** bound
$\|x - \tfrac1k\sum_j V_{\mathrm{idx}(j)}\|^2 \le \tau/k \le R^2/k$, where
$\tau = \sum_i p_i\|V_i - x\|^2 = \sum_i p_i\|V_i\|^2 - \|x\|^2$ is the variance of
the family. The deterministic per-step inequality is obtained from an exact
*averaging identity* $\sum_i p_i\|s + (V_i - x)\|^2 = \|s\|^2 + \tau$, whose only
input is the centroid identity $\sum_i p_i(V_i - x) = 0$. We then connect this
approximation law to iterated **Delaunay refinement**: any nonnegative sequence that
contracts by a uniform factor $\lambda > 1$ per step decays as $(1/\lambda)^k$,
tends to zero, reaches any tolerance in finitely many steps, and has a finite total
budget $\sum_k d_k \le d_0\lambda/(\lambda-1)$; the one-dimensional minicenter
(midpoint) case realizes this with the sharp factor $\lambda = 2$. All results are
formally verified.

## 1. Introduction

Carathéodory's theorem says a point in the convex hull of a set in $\mathbb{R}^n$ is
a convex combination of at most $n+1$ of its points. The *approximate* version
trades exactness for dimension-independence: at the cost of a controlled error one
can use a number of points that depends only on the desired accuracy, not on the
ambient dimension. This dimension-free feature makes it foundational in
high-dimensional probability, sparse approximation, and convex optimization (it is
the convergence backbone of the Frank–Wolfe algorithm).

The standard proof is non-constructive. It interprets the unweighted average of a
random list — each entry drawn i.i.d. from the distribution $p$ — as an unbiased
estimator of $x$ with variance $\tau/k$, and invokes the probabilistic method:
since the expected error is $\le R^2/k$, some list achieves at most the expectation.
The proof never names that list.

This paper contributes a **deterministic, verifiable** procedure with a **sharper
bound**, and situates it within a self-contained theory of refinement contraction.
Section 2 fixes notation. Section 3 develops the greedy procedure and its sharp
$\tau/k$ guarantee. Section 4 records the probabilistic baseline ($R^2/k$, by
Maurey's method) that the greedy result strengthens. Section 5 develops the
abstract contraction calculus underlying iterated Delaunay refinement and its
one-dimensional geometric witness. Section 6 gives algorithms; Section 7,
applications; Section 8, discussion and future directions.

## 2. Preliminaries

Throughout, $E$ is a real inner product space (`NormedAddCommGroup` with
`InnerProductSpace ℝ`), $\langle\cdot,\cdot\rangle$ its inner product, and
$\|\cdot\|$ the induced norm. The index set $\iota$ is finite and nonempty. We fix:

- weights $p : \iota \to \mathbb{R}$ with $p_i \ge 0$ and $\sum_i p_i = 1$;
- vectors $V : \iota \to E$ ("vertices");
- the target convex point $x := \sum_j p_j V_j$.

We repeatedly use the *polarization* identities, valid over $\mathbb{R}$:
$\|a+b\|^2 = \|a\|^2 + 2\langle a,b\rangle + \|b\|^2$ and
$\|a-b\|^2 = \|a\|^2 - 2\langle a,b\rangle + \|b\|^2$, together with
$\langle a,a\rangle = \|a\|^2$.

**Definition 2.1 (Deviation).** The *deviation* of vertex $i$ from the target is
$$\mathrm{dev}(i) := V_i - x = V_i - \sum_j p_j V_j.$$

**Definition 2.2 (Variance).** The *variance* of the family is
$$\tau := \sum_i p_i \, \|\mathrm{dev}(i)\|^2 = \sum_i p_i \, \|V_i - x\|^2.$$

## 3. The sharp deterministic procedure

### 3.1 The two structural identities

**Lemma 3.1 (Deviations are mean-zero; `sum_weighted_dev_eq_zero`).**
If $\sum_i p_i = 1$ then
$$\sum_i p_i \, \mathrm{dev}(i) = 0.$$

*Proof sketch.* Expand $\mathrm{dev}(i) = V_i - x$ and use linearity:
$\sum_i p_i V_i - \big(\sum_i p_i\big)x = x - 1\cdot x = 0$. $\square$

**Lemma 3.2 (Averaging identity; `avg_sq_dev`).** For every $s \in E$,
$$\sum_i p_i \, \| s + \mathrm{dev}(i) \|^2 = \|s\|^2 + \tau.$$

*Proof sketch.* By the polarization identity,
$\|s+\mathrm{dev}(i)\|^2 = \|s\|^2 + 2\langle s,\mathrm{dev}(i)\rangle + \|\mathrm{dev}(i)\|^2$.
Weight by $p_i$ and sum. The first term gives $\|s\|^2\sum_i p_i = \|s\|^2$; the
last gives $\tau$ by definition; the cross term is
$2\big\langle s,\ \sum_i p_i\,\mathrm{dev}(i)\big\rangle = 2\langle s,0\rangle = 0$
by Lemma 3.1. $\square$

**Lemma 3.3 (Second-moment form of the variance; `tau_eq`).**
$$\tau = \Big(\sum_i p_i \|V_i\|^2\Big) - \|x\|^2.$$

*Proof sketch.* Expand $\|V_i - x\|^2 = \|V_i\|^2 - 2\langle V_i, x\rangle + \|x\|^2$,
weight and sum: the cross term is $2\langle\sum_i p_i V_i, x\rangle = 2\|x\|^2$ and
the constant term is $\|x\|^2$, leaving $\sum_i p_i\|V_i\|^2 - \|x\|^2$. $\square$

**Lemma 3.4 (Variance is bounded by the radius; `tau_le_sq`).**
If $\|V_i\| \le R$ for all $i$, then $\tau \le R^2$.

*Proof sketch.* From Lemma 3.3, $\tau \le \sum_i p_i\|V_i\|^2 \le \sum_i p_i R^2 = R^2$,
discarding the nonnegative $\|x\|^2$ term. $\square$

### 3.2 The greedy selection

**Definition 3.5 (Best index; `bestIdx`).** For $s \in E$, define
$$\mathrm{bestIdx}(s) := \arg\min_{i\in\iota} \, \| s + \mathrm{dev}(i) \|^2,$$
a well-defined element of the finite nonempty $\iota$ (the linear-minimization
oracle of a Frank–Wolfe step).

**Lemma 3.6 (Optimality of the arg-min; `bestIdx_spec`).** For every $i$,
$$\| s + \mathrm{dev}(\mathrm{bestIdx}(s)) \|^2 \le \| s + \mathrm{dev}(i) \|^2.$$

*Proof sketch.* Immediate from the definition of arg-min over a finite set. $\square$

**Definition 3.7 (Greedy trajectory; `greedySum`, `greedyIdx`).** Define the running
deviation sum by recursion,
$$s_0 := 0, \qquad s_{t+1} := s_t + \mathrm{dev}(\mathrm{bestIdx}(s_t)),$$
and the sequence of chosen indices $\mathrm{idx}(t) := \mathrm{bestIdx}(s_t)$.

### 3.3 The contraction and the sharp bound

**Theorem 3.8 (One greedy step; `step_bound`).** For every $s \in E$,
$$\| s + \mathrm{dev}(\mathrm{bestIdx}(s)) \|^2 \le \|s\|^2 + \tau.$$

*Proof sketch.* The arg-min is no larger than the $p$-weighted average:
by Lemma 3.6, $\|s+\mathrm{dev}(\mathrm{bestIdx}(s))\|^2 = \sum_i p_i\,\|s+\mathrm{dev}(\mathrm{bestIdx}(s))\|^2
\le \sum_i p_i\,\|s+\mathrm{dev}(i)\|^2$, and the right side equals $\|s\|^2+\tau$ by
Lemma 3.2. $\square$

**Theorem 3.9 (Accumulated bound; `greedySum_sq_le`).** For every $k\in\mathbb{N}$,
$$\| s_k \|^2 \le k\,\tau.$$

*Proof sketch.* Induction on $k$. Base $k=0$: $s_0=0$, both sides $0$. Step: by
Theorem 3.8, $\|s_{k+1}\|^2 \le \|s_k\|^2 + \tau \le k\tau + \tau = (k+1)\tau$. $\square$

**Lemma 3.10 (Trajectory unwinding; `greedySum_eq`).**
$$s_k = \Big(\sum_{t=0}^{k-1} V_{\mathrm{idx}(t)}\Big) - k\,x.$$

*Proof sketch.* Telescoping the recursion: each step adds
$\mathrm{dev}(\mathrm{idx}(t)) = V_{\mathrm{idx}(t)} - x$, so after $k$ steps the sum
of vertices accumulates while $x$ is subtracted $k$ times. $\square$

**Theorem 3.11 (Sharp deterministic approximate Carathéodory).** Let $\sum_i p_i=1$,
$p_i \ge 0$, and $\|V_i\| \le R$ for all $i$. With $\mathrm{idx}$ the greedy indices
of Definition 3.7 and any $k \ge 1$,
$$\left\| x - \frac1k \sum_{j=0}^{k-1} V_{\mathrm{idx}(j)} \right\|^2
  \;\le\; \frac{\tau}{k} \;\le\; \frac{R^2}{k}.$$

*Proof sketch.* By Lemma 3.10,
$x - \tfrac1k\sum_j V_{\mathrm{idx}(j)} = -\tfrac1k\big(\sum_j V_{\mathrm{idx}(j)} - kx\big)
= -\tfrac1k\, s_k$, so the left-hand side equals $\tfrac1{k^2}\|s_k\|^2$. Apply
Theorem 3.9 to get $\le \tfrac1{k^2}\cdot k\tau = \tau/k$, then Lemma 3.4 for
$\tau \le R^2$. $\square$

The bound $\tau/k$ is strictly sharper than $R^2/k$ whenever $\|x\| > 0$ or the
vertices are not all of norm exactly $R$, since by Lemma 3.3 the gap is exactly
$\big(R^2 - \sum_i p_i\|V_i\|^2\big) + \|x\|^2 \ge \|x\|^2$. Crucially, the list
$\mathrm{idx}(0),\dots,\mathrm{idx}(k-1)$ is produced explicitly by the recursion,
not asserted to exist.

## 4. The probabilistic baseline (Maurey's empirical method)

For completeness we record the existence theorem that Theorem 3.11 strengthens; it
is proved independently by the empirical method and yields the same worst-case rate
without exhibiting a list.

**Lemma 4.1 (Averaging principle; `exists_le_weighted_average`).** For probability
weights $p$ on a finite nonempty index set and any real family $g$, there is an
index $i$ with $g_i \le \sum_j p_j g_j$.

*Proof sketch.* Take $i$ minimizing $g$; then $g_i = \sum_j p_j g_i \le \sum_j p_j g_j$. $\square$

**Lemma 4.2 (Variance identity; `weighted_mean_sq_dist`).**
$\sum_i p_i\|x - V_i\|^2 = \big(\sum_i p_i\|V_i\|^2\big) - \|x\|^2 = \tau$ (the $k=1$
case of the empirical method; identical content to Lemma 3.3).

**Theorem 4.3 (Base case; `maurey_one_point`, `maurey_one_point_variance`).** There
is an $i$ with $\|x - V_i\|^2 \le R^2$, and in fact $\|x - V_i\|^2 \le R^2 - \|x\|^2$.

*Proof sketch.* By Lemma 4.2 the $p$-weighted mean of $\|x-V_i\|^2$ is
$\le R^2 - \|x\|^2 \le R^2$; by Lemma 4.1 some index beats the mean. $\square$

**Theorem 4.4 (Empirical expectation bound; `expectation_bound`).** For $k\ge 1$, the
product-weighted mean over all lists $\omega\in\iota^{k}$ (weight
$\prod_j p_{\omega_j}$) of the squared error of the average $\tfrac1k\sum_j V_{\omega_j}$
is at most $R^2/k$.

*Proof sketch.* Write the error as $\tfrac1k\sum_j(x - V_{\omega_j})$; expand the
squared norm into a double sum of inner products and marginalize coordinate by
coordinate. Off-diagonal terms vanish (independence $\Leftrightarrow$
$\sum_i p_i(x-V_i)=0$); each of the $k$ diagonal terms contributes $\tau \le R^2$;
the $1/k^2$ prefactor leaves $\tau/k \le R^2/k$. $\square$

**Theorem 4.5 (Approximate Carathéodory; `maurey_sqrt`).** For $k\ge 1$ there exists
$f:\{0,\dots,k-1\}\to\iota$ with $\|x - \tfrac1k\sum_j V_{f(j)}\|^2 \le R^2/k$.

*Proof sketch.* Combine Theorem 4.4 with Lemma 4.1 over the product index set:
some list is no worse than the product-weighted mean. $\square$

Theorem 3.11 reproves the same rate, replaces "there exists $f$" by an explicit
$\mathrm{idx}$, and tightens $R^2/k$ to $\tau/k$.

## 5. Iterated refinement: the contraction calculus

We now isolate the metric backbone of iterated Delaunay refinement: a quantity
(maximum simplex diameter) that contracts by a uniform factor per step.

**Definition 5.1 (Contraction process; `ContractionProcess`).** A contraction
process is a sequence $d:\mathbb{N}\to\mathbb{R}$ together with a factor
$\lambda>1$ such that $d_k \ge 0$ for all $k$ and $d_{k+1} \le (1/\lambda)\,d_k$.

**Theorem 5.2 (Exponential contraction; `diam_le_pow`).**
$d_k \le (1/\lambda)^{k} d_0$ for all $k$.

*Proof sketch.* Induction: $d_{k+1} \le (1/\lambda)d_k \le (1/\lambda)\cdot(1/\lambda)^k d_0
= (1/\lambda)^{k+1} d_0$, using $1/\lambda \ge 0$ to preserve the inequality. $\square$

**Theorem 5.3 (Decay to zero; `diam_tendsto_zero`).** $d_k \to 0$ as $k\to\infty$.

*Proof sketch.* Squeeze between $0 \le d_k \le (1/\lambda)^k d_0$ and use
$|1/\lambda|<1 \Rightarrow (1/\lambda)^k \to 0$. $\square$

**Theorem 5.4 (Iteration-count bound; `exists_steps_below`).** For every
$\varepsilon>0$ there is an $N$ with $d_k < \varepsilon$ for all $k\ge N$.

*Proof sketch.* Eventual smallness from Theorem 5.3. $\square$

**Theorem 5.5 (One-dimensional minicenter; `minicenter_segment_halves`).** For an
edge $[a,b]$ in a normed space, the midpoint $m = \mathrm{midpoint}(a,b)$ — the
center of the smallest enclosing ball — satisfies
$\mathrm{dist}(a,m) = \mathrm{dist}(m,b) = \mathrm{dist}(a,b)/2$.

*Proof sketch.* Direct computation: $\|a - \tfrac{a+b}2\| = \tfrac12\|a-b\|$, and
symmetrically for $b$. $\square$

**Corollary 5.6 (Bisection witness; `segmentBisection`, `segmentBisection_bound`).**
Edge bisection of an edge of length $D \ge 0$ is a contraction process with
$\lambda = 2$ and $d_k = D/2^k$; hence $d_k \le (1/2)^k D$. This shows Definition 5.1
is non-vacuous and the exponent is achieved by genuine geometry.

### 5.1 Cumulative budget and covering

**Theorem 5.7 (Total budget; `summable_of_contraction`, `total_budget`).** If
$d_k \le (1/\lambda)^k D$ with $\lambda>1$ and $d_k \ge 0$, then $d$ is summable and
$$\sum_{k=0}^{\infty} d_k \le \frac{D\,\lambda}{\lambda - 1}.$$

*Proof sketch.* Dominate by the convergent geometric series $\sum_k (1/\lambda)^k D
= D/(1 - 1/\lambda) = D\lambda/(\lambda-1)$. $\square$

**Theorem 5.8 (Covering decay and budget; `covering_tendsto_zero`,
`covering_budget`).** If a covering radius satisfies $0 \le \mathrm{cov}_k \le d_k$
with $d_k \le (1/\lambda)^k D$, then $\mathrm{cov}_k \to 0$ and
$\sum_k \mathrm{cov}_k \le D\lambda/(\lambda-1)$.

*Proof sketch.* Monotone comparison with $d_k$ inherits decay (Theorem 5.3) and
summability (Theorem 5.7). $\square$

The link to Section 3–4 is the covering hypothesis $\mathrm{cov}_k \le d_k$: the
approximate Carathéodory guarantee is precisely what certifies that every domain
point lies within one current simplex of an average of its vertices, so the
covering radius is controlled by the simplex diameter and inherits the contraction.

## 6. Algorithms

**Algorithm A (Greedy sharp Carathéodory).** Input: vertices $V_i$, weights $p_i$,
budget $k$. Maintain $s \leftarrow 0$. For $t = 0,\dots,k-1$: compute $x = \sum_i p_i V_i$
(once), select $i_t = \arg\min_i \|s + (V_i - x)\|^2$, append $i_t$, and update
$s \leftarrow s + (V_i - x)$. Output the list $(i_0,\dots,i_{k-1})$ and the average
$\tfrac1k\sum_t V_{i_t}$. Per Theorem 3.11 the squared error is $\le \tau/k \le R^2/k$.
Cost: $O(k\,|\iota|\,\dim E)$ after an $O(|\iota|\dim E)$ precomputation of $x$.

**Algorithm B (Refinement budget estimator).** Given $\lambda>1$, $D=d_0$, and a
tolerance $\varepsilon$, return $N = \lceil \log_\lambda(D/\varepsilon)\rceil$ (steps
to reach $d_k<\varepsilon$, from Theorem 5.2/5.4) and the total budget
$D\lambda/(\lambda-1)$ (Theorem 5.7).

## 7. Applications

- **Sparse convex approximation / coresets.** Algorithm A returns an explicit
  multiset of $k$ vertices whose mean approximates any target convex point with a
  *certificate* $\tau/k$, improving on the non-constructive $R^2/k$ guarantee.
- **Frank–Wolfe convergence.** The arg-min step is exactly a linear-minimization
  oracle call; Theorem 3.8 is the per-iteration progress lemma, and Theorem 3.9 its
  telescoped $O(1/k)$ rate, here with the sharp variance constant.
- **Mesh refinement.** Theorems 5.2–5.8 quantify when iterated (Delaunay/minicenter)
  refinement drives mesh fineness and covering error to zero, with explicit step
  counts and a finite cumulative work budget; the 1D minicenter case (Theorem 5.5)
  pins the sharp factor $\lambda = 2$.

## 8. Discussion and future directions

The greedy result shows that the empirical method's existence guarantee is, in the
inner-product setting, redundant: a single arg-min sweep matches its rate
deterministically and sharpens its constant from $R^2$ to the variance $\tau$. The
gap is exactly $\|x\|^2$ plus the slack between the vertex norms and $R$, so the
classical bound is tight only for centroids at the origin of a sphere.

The contraction calculus deliberately abstracts the metric core away from the open
combinatorial question of *which* simplices appear after refinement; the 1D
minicenter theorem is the proven instance of the per-step factor, and the
higher-dimensional factor remains conjectural. The conjectures collected from this
cycle — an intrinsic $\|x\|^2$-governed window width for balanced frames, the
$1-1/p$ exponent across $\ell_p$, and a closed-form minicenter factor
$\lambda_d = \sqrt{2(d+1)/d}$ generalizing $\lambda_1=2$ — are the natural next
targets and are recorded in full in the package's future-directions field.

## Summary of formalized results

Greedy: `dev`, `bestIdx`, `greedySum`, `greedyIdx`, `tau`, `bestIdx_spec`,
`sum_weighted_dev_eq_zero`, `avg_sq_dev`, `step_bound`, `greedySum_sq_le`, `tau_eq`,
`tau_le_sq`, `greedySum_eq`. Maurey: `exists_le_weighted_average`,
`weighted_mean_sq_dist`, `maurey_one_point`, `maurey_one_point_variance`,
`expectation_bound`, `maurey_sqrt`. Contraction: `ContractionProcess`,
`diam_le_pow`, `diam_tendsto_zero`, `exists_steps_below`,
`minicenter_segment_halves`, `segmentBisection`, `segmentBisection_bound`. Bridge:
`summable_of_contraction`, `total_budget`, `covering_tendsto_zero`,
`covering_budget`. All proved with zero `sorry`s.
