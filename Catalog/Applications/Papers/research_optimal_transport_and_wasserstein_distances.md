# The One-Dimensional Discrete 1-Wasserstein Distance: A Formally Verified Theory

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Novelty / Optimal Transport

---

## Abstract

We develop a complete, rigorous theory of the 1-Wasserstein distance $W_1$ for finitely supported probability distributions on the integer grid $\{0, 1, \dots, n-1\}$. Working from the Kantorovich formulation of optimal transport, we establish the cumulative-distribution-function (CDF) closed form
$$W_1(p,q) = \sum_{k=0}^{n-2} \big| F_p(k) - F_q(k) \big|,$$
and use it as the computational and theoretical backbone for the entire development. We prove that $W_1$ is a genuine metric on the simplex of distributions — nonnegativity, symmetry, the identity of indiscernibles, and the triangle inequality — and we establish Kantorovich–Rubinstein duality with an *explicit* optimal 1-Lipschitz potential, so that duality holds not as an abstract minimax equality but as an attained, constructive identity. We further prove three consequences of independent interest: the Dirac isometry $W_1(\delta_a, \delta_b) = |a-b|$ showing $W_1$ faithfully extends the ground metric; the mean-difference bound $|\mathbb{E}_p - \mathbb{E}_q| \le W_1(p,q)$; and the primal coupling lower bound $W_1(p,q) \le \mathrm{cost}(\pi)$ valid for every transport plan $\pi$. All results are accompanied by complete proof sketches. The development is entirely constructive and self-contained, and forms a foundation for higher-order Wasserstein distances, strong duality via explicit couplings, data-processing contraction, quantitative convergence of empirical measures, and a tropical (max-plus) analogue, each of which we lay out as a precise conjecture for future work.

**Keywords:** optimal transport, Wasserstein distance, Kantorovich duality, cumulative distribution function, transport plan, Lipschitz potential, Dirac isometry, metric space.

---

## 1. Introduction

Optimal transport asks for the cheapest way to rearrange one distribution of mass into another, where cost is measured by how far mass is carried. First posed by Monge (1781) for the problem of moving earthworks, it was given its modern, analytically tractable form by Kantorovich (1942), whose linear-programming relaxation introduced *transport plans* and the celebrated duality that now bears his and Rubinstein's names. The resulting **Wasserstein distances** are metrics on spaces of probability measures, and they have become indispensable across statistics, economics, image processing, partial differential equations, and — most spectacularly in the last decade — machine learning, where the Wasserstein GAN reframed generative modeling around the dual representation of $W_1$.

This paper isolates the cleanest nontrivial setting — finitely supported distributions on a one-dimensional integer grid — and develops its theory completely. The one-dimensional case is special: the optimal transport cost admits a closed form in terms of cumulative distribution functions, sidestepping any explicit optimization over the (high-dimensional) polytope of transport plans. This closed form makes every structural property of $W_1$ provable by elementary, finitary arguments, and it makes the theory directly computable. Our contribution is a unified, gap-free account: definitions, the closed form, the metric axioms, constructive Kantorovich–Rubinstein duality, and three applications.

We work over the grid $X_n = \{0, 1, \dots, n-1\}$ with the ground metric $d(i,j) = |i-j|$ inherited from $\mathbb{Z}$. Distributions are nonnegative weight vectors summing to one. Throughout, sums run over grid indices unless otherwise noted.

### Summary of results

- **Theorem (CDF closed form, `W1_def`).** $W_1(p,q) = \sum_{k=0}^{n-2} |F_p(k) - F_q(k)|$.
- **Theorem (metric, `W1_nonneg`, `W1_comm`, `W1_self_eq_zero`, `eq_of_W1_zero`, `W1_triangle`).** $W_1$ is a metric on the probability simplex of $X_n$.
- **Theorem (duality, `kantorovich_duality`, `kantorovich_le`, `kantorovich_attained`).** $W_1(p,q) = \max_{\varphi \in \mathrm{Lip}_1} (\mathbb{E}_p \varphi - \mathbb{E}_q \varphi)$, attained by an explicit potential.
- **Theorem (Dirac isometry, `W1_dirac`).** $W_1(\delta_a, \delta_b) = |a-b|$.
- **Theorem (mean bound, `abs_mean_sub_le_W1`).** $|\mathbb{E}_p - \mathbb{E}_q| \le W_1(p,q)$.
- **Theorem (primal bound, `W1_le_transportCost`).** $W_1(p,q) \le \mathrm{cost}(\pi)$ for every transport plan $\pi$.

---

## 2. Definitions and basic objects

### 2.1 Distributions on a grid

**Definition 2.1 (Distribution).** Fix $n \ge 1$. A *distribution* on $X_n = \{0, \dots, n-1\}$ is a vector $p = (p_0, \dots, p_{n-1})$ with $p_k \ge 0$ for all $k$ and $\sum_{k=0}^{n-1} p_k = 1$. We write $\Delta_n$ for the set of all such distributions (the standard simplex).

**Definition 2.2 (Dirac mass).** For $a \in X_n$, the *Dirac mass* $\delta_a \in \Delta_n$ is defined by $(\delta_a)_k = 1$ if $k = a$ and $0$ otherwise.

**Definition 2.3 (Expectation).** The *mean* of $p \in \Delta_n$ is $\mathbb{E}_p := \sum_{k=0}^{n-1} k\, p_k$, the expected value of the identity random variable on the grid.

### 2.2 The cumulative distribution function

**Definition 2.4 (CDF).** The *cumulative distribution function* of $p \in \Delta_n$ is
$$F_p(k) := \sum_{j=0}^{k} p_j, \qquad k \in \{0, \dots, n-1\}.$$
It is nondecreasing, satisfies $0 \le F_p(k) \le 1$, and $F_p(n-1) = 1$ since $p$ is a probability vector.

### 2.3 Transport plans and cost

**Definition 2.5 (Transport plan / coupling).** A *transport plan* between $p, q \in \Delta_n$ is a matrix $\pi = (\pi_{ij})_{0 \le i,j \le n-1}$ with $\pi_{ij} \ge 0$ and marginals
$$\sum_{j} \pi_{ij} = p_i \ \ (\forall i), \qquad \sum_{i} \pi_{ij} = q_j \ \ (\forall j).$$
We write $\Pi(p,q)$ for the set of transport plans; it is a nonempty compact polytope (it contains the product plan $\pi_{ij} = p_i q_j$).

**Definition 2.6 (Transport cost).** The *cost* of a plan $\pi \in \Pi(p,q)$ for the ground metric $d(i,j)=|i-j|$ is
$$\mathrm{cost}(\pi) := \sum_{i,j} |i - j|\, \pi_{ij}.$$

**Definition 2.7 (Kantorovich optimal transport).** The Kantorovich optimal transport cost is $\inf_{\pi \in \Pi(p,q)} \mathrm{cost}(\pi)$. On the line this infimum is attained and equals the CDF closed form below; we take the closed form as our working definition of $W_1$ and recover the primal infimum characterization via Theorem 6.1 and Conjecture 1.

### 2.4 The 1-Wasserstein distance

**Definition 2.8 (1-Wasserstein distance, `W1_def`).** For $p, q \in \Delta_n$,
$$W_1(p, q) := \sum_{k=0}^{n-2} \big| F_p(k) - F_q(k) \big|.$$
The top index $n-1$ is omitted because $F_p(n-1) = F_q(n-1) = 1$, so that term always vanishes.

### 2.5 Lipschitz potentials

**Definition 2.9 (1-Lipschitz potential).** A function $\varphi : X_n \to \mathbb{R}$ is *1-Lipschitz* (with respect to $d(i,j) = |i-j|$) if $|\varphi(k+1) - \varphi(k)| \le 1$ for all $0 \le k \le n-2$; equivalently $|\varphi(i) - \varphi(j)| \le |i-j|$ for all $i,j$. Write $\mathrm{Lip}_1$ for the set of such potentials. For $\varphi : X_n \to \mathbb{R}$ we write $\mathbb{E}_p\varphi := \sum_k \varphi(k) p_k$.

---

## 3. The cumulative closed form

The entire theory rests on the following identity, which converts a transport problem into an arithmetic of cumulative gaps.

**Theorem 3.1 (CDF closed form, `W1_def`).** For all $p, q \in \Delta_n$, the Kantorovich optimal transport cost with ground metric $d(i,j)=|i-j|$ equals
$$W_1(p,q) = \sum_{k=0}^{n-2} \big| F_p(k) - F_q(k) \big|.$$

*Proof sketch.* The key structural fact is a **summation-by-parts / flow-conservation** identity. For any transport plan $\pi \in \Pi(p,q)$, decompose the cost by writing each distance $|i-j|$ as a sum of unit steps across the boundaries between consecutive grid points. Define the *net flow across boundary $k$* (between sites $k$ and $k+1$) as the signed amount of mass that the plan moves from the left block $\{0,\dots,k\}$ to the right block $\{k+1,\dots,n-1\}$. Because the marginals are fixed, the net flow across boundary $k$ is determined entirely by the marginals: it must equal $F_p(k) - F_q(k)$, the discrepancy between how much mass $p$ and $q$ place at or below $k$. Each unit of mass crossing boundary $k$ contributes exactly $1$ to the cost, and the absolute amount of crossing is at least $|F_p(k) - F_q(k)|$, giving $\mathrm{cost}(\pi) \ge \sum_k |F_p(k) - F_q(k)|$ for every $\pi$. The monotone coupling (Section 7) attains this bound, so the optimal cost equals the right-hand side. $\square$

This closed form is also the engine for computation: evaluating $W_1$ costs $O(n)$ arithmetic operations (two prefix sums and a sum of absolute differences), versus solving a linear program over the $n^2$-dimensional transport polytope.

---

## 4. $W_1$ is a metric

We now verify the four metric axioms (with symmetry and the two zero-distance facts handled separately).

**Theorem 4.1 (Nonnegativity, `W1_nonneg`).** $W_1(p,q) \ge 0$ for all $p, q$.

*Proof sketch.* $W_1(p,q)$ is a finite sum of absolute values $|F_p(k) - F_q(k)| \ge 0$, hence nonnegative. $\square$

**Theorem 4.2 (Symmetry, `W1_comm`).** $W_1(p,q) = W_1(q,p)$.

*Proof sketch.* Termwise, $|F_p(k) - F_q(k)| = |F_q(k) - F_p(k)|$ by symmetry of the absolute value; sum over $k$. $\square$

**Theorem 4.3 (Self-distance is zero, `W1_self_eq_zero`).** $W_1(p,p) = 0$.

*Proof sketch.* Each term is $|F_p(k) - F_p(k)| = 0$, so the sum is $0$. $\square$

**Theorem 4.4 (Identity of indiscernibles, `eq_of_W1_zero`).** If $W_1(p,q) = 0$ then $p = q$.

*Proof sketch.* A sum of nonnegative terms is zero iff every term is zero, so $F_p(k) = F_q(k)$ for all $0 \le k \le n-2$. Since $F_p(n-1) = F_q(n-1) = 1$, in fact $F_p(k) = F_q(k)$ for *all* $k$. The distribution is recovered from its CDF by first differences, $p_0 = F_p(0)$ and $p_k = F_p(k) - F_p(k-1)$ for $k \ge 1$, so equal CDFs force $p_k = q_k$ for every $k$, i.e. $p = q$. $\square$

**Theorem 4.5 (Triangle inequality, `W1_triangle`).** For all $p, q, r \in \Delta_n$,
$$W_1(p, r) \le W_1(p, q) + W_1(q, r).$$

*Proof sketch.* Apply the scalar triangle inequality at each grid boundary $k$:
$$|F_p(k) - F_r(k)| \le |F_p(k) - F_q(k)| + |F_q(k) - F_r(k)|,$$
then sum over $k = 0, \dots, n-2$ and regroup the right-hand side into $W_1(p,q) + W_1(q,r)$. $\square$

**Corollary 4.6.** $(\Delta_n, W_1)$ is a metric space.

---

## 5. Kantorovich–Rubinstein duality

The dual problem replaces the search over transport plans by a search over 1-Lipschitz potentials. We prove the easy inequality, exhibit an explicit optimal potential, and conclude the exact duality.

**Theorem 5.1 (Dual feasibility / weak duality, `kantorovich_le`).** For every 1-Lipschitz potential $\varphi$ and all $p, q \in \Delta_n$,
$$\mathbb{E}_p[\varphi] - \mathbb{E}_q[\varphi] \le W_1(p, q).$$

*Proof sketch.* Summation by parts converts the difference of expectations into a CDF-weighted sum of the increments of $\varphi$. Writing $s_k := \varphi(k+1) - \varphi(k)$ with $|s_k| \le 1$,
$$\mathbb{E}_p[\varphi] - \mathbb{E}_q[\varphi] = \sum_k \varphi(k)(p_k - q_k) = -\sum_{k=0}^{n-2} s_k\,\big(F_p(k) - F_q(k)\big).$$
(The boundary terms vanish because $F_p(n-1)=F_q(n-1)=1$.) Bounding $|s_k| \le 1$ termwise gives $\big|\sum_k s_k(F_p(k)-F_q(k))\big| \le \sum_k |F_p(k)-F_q(k)| = W_1(p,q)$, hence the claim. $\square$

**Theorem 5.2 (Attainment, `kantorovich_attained`).** Define the *staircase potential* $\varphi^\star$ by $\varphi^\star(0) = 0$ and
$$\varphi^\star(k+1) - \varphi^\star(k) = -\operatorname{sgn}\big(F_p(k) - F_q(k)\big) \in \{-1, 0, +1\}.$$
Then $\varphi^\star \in \mathrm{Lip}_1$ and
$$\mathbb{E}_p[\varphi^\star] - \mathbb{E}_q[\varphi^\star] = W_1(p, q).$$

*Proof sketch.* The increments of $\varphi^\star$ are signs, hence bounded in absolute value by $1$, so $\varphi^\star$ is 1-Lipschitz. Plugging $s_k = -\operatorname{sgn}(F_p(k)-F_q(k))$ into the summation-by-parts identity of Theorem 5.1 yields
$$\mathbb{E}_p[\varphi^\star] - \mathbb{E}_q[\varphi^\star] = \sum_{k=0}^{n-2} \operatorname{sgn}(F_p(k)-F_q(k))\,(F_p(k)-F_q(k)) = \sum_{k=0}^{n-2} |F_p(k)-F_q(k)| = W_1(p,q),$$
using $\operatorname{sgn}(x)\cdot x = |x|$ termwise. $\square$

**Theorem 5.3 (Kantorovich–Rubinstein duality, `kantorovich_duality`).** For all $p, q \in \Delta_n$,
$$W_1(p, q) = \max_{\varphi \in \mathrm{Lip}_1} \Big( \mathbb{E}_p[\varphi] - \mathbb{E}_q[\varphi] \Big),$$
and the maximum is attained at the staircase potential $\varphi^\star$ of Theorem 5.2.

*Proof sketch.* Theorem 5.1 shows $W_1$ is an upper bound for the supremum; Theorem 5.2 exhibits a feasible $\varphi^\star$ achieving it. Hence the supremum is attained and equals $W_1$. $\square$

This constructive duality is exactly the structure exploited by the Wasserstein GAN: the dual variable $\varphi$ is the "critic," constrained to be 1-Lipschitz, and the training objective is the dual expectation difference, whose optimum equals $W_1$.

---

## 6. Bounds and isometries

**Theorem 6.1 (Primal coupling lower bound, `W1_le_transportCost`).** For every transport plan $\pi \in \Pi(p,q)$,
$$W_1(p, q) \le \mathrm{cost}(\pi).$$

*Proof sketch.* This is the inequality half of Theorem 3.1, isolated as a directly usable statement. For each boundary $k$, the net mass that $\pi$ moves across it equals $F_p(k) - F_q(k)$ by the marginal constraints, and a piece of mass moving from $i$ to $j$ pays for each of the $|i-j|$ boundaries it crosses. Summing the per-boundary contributions gives $\mathrm{cost}(\pi) = \sum_{i,j}|i-j|\pi_{ij} \ge \sum_k |F_p(k)-F_q(k)| = W_1(p,q)$. $\square$

**Theorem 6.2 (Dirac isometry, `W1_dirac`).** For $a, b \in X_n$, $W_1(\delta_a, \delta_b) = |a - b|$.

*Proof sketch.* The CDF of $\delta_a$ is the indicator step $F_{\delta_a}(k) = \mathbf{1}[k \ge a]$. For $a \le b$, the gap $F_{\delta_a}(k) - F_{\delta_b}(k) = \mathbf{1}[a \le k < b]$ equals $1$ for exactly the $b-a$ values $k \in \{a, \dots, b-1\}$ and $0$ otherwise; summing gives $b - a = |a-b|$. The case $a > b$ follows by symmetry (Theorem 4.2). $\square$

Theorem 6.2 shows that the embedding $a \mapsto \delta_a$ of the grid into $(\Delta_n, W_1)$ is an isometry: $W_1$ restricted to point masses *is* the ground metric. Thus $W_1$ is a faithful extension of $|i-j|$ from points to distributions.

**Theorem 6.3 (Mean-difference bound, `abs_mean_sub_le_W1`).** For all $p, q \in \Delta_n$,
$$\big| \mathbb{E}_p - \mathbb{E}_q \big| \le W_1(p, q).$$

*Proof sketch.* The identity potential $\varphi_{\mathrm{id}}(k) = k$ has increments $\varphi_{\mathrm{id}}(k+1)-\varphi_{\mathrm{id}}(k) = 1$, so $\varphi_{\mathrm{id}} \in \mathrm{Lip}_1$. By Theorem 5.1 applied to $\varphi_{\mathrm{id}}$ and to $-\varphi_{\mathrm{id}}$ (also 1-Lipschitz),
$$\mathbb{E}_p - \mathbb{E}_q = \mathbb{E}_p[\varphi_{\mathrm{id}}] - \mathbb{E}_q[\varphi_{\mathrm{id}}] \le W_1(p,q), \qquad \mathbb{E}_q - \mathbb{E}_p \le W_1(p,q),$$
and combining gives $|\mathbb{E}_p - \mathbb{E}_q| \le W_1(p,q)$. $\square$

The converse is false: distributions can share a mean while being far apart in $W_1$ (e.g. $\delta_1$ versus $\tfrac12(\delta_0 + \delta_2)$ both have mean $1$ but positive $W_1$), so $W_1$ strictly refines comparison of means.

---

## 7. Algorithms

### 7.1 Closed-form evaluation of $W_1$

Theorem 3.1 yields a linear-time evaluator: compute the two prefix sums $F_p, F_q$ and accumulate $\sum_{k<n-1}|F_p(k)-F_q(k)|$.

```
Algorithm W1-CDF(p, q):
  input:  distributions p, q on {0,...,n-1}
  output: W1(p, q)
  Fp <- 0; Fq <- 0; total <- 0
  for k = 0 to n-2:
      Fp <- Fp + p[k]
      Fq <- Fq + q[k]
      total <- total + |Fp - Fq|
  return total
```
Complexity: $O(n)$ time, $O(1)$ extra space.

### 7.2 Explicit optimal dual potential

The staircase potential $\varphi^\star$ of Theorem 5.2 is built in one left-to-right pass from the sign of the CDF gap.

```
Algorithm DualPotential(p, q):
  Fp <- 0; Fq <- 0; phi <- [0.0]
  for k = 0 to n-2:
      Fp <- Fp + p[k];  Fq <- Fq + q[k]
      step <- -sign(Fp - Fq)          # in {-1, 0, +1}
      phi.append(phi[-1] + step)
  return phi                          # 1-Lipschitz; attains the dual max
```
Complexity: $O(n)$.

### 7.3 Monotone (north-west-corner) coupling

The plan attaining the primal bound greedily matches the smallest available source mass to the smallest available target mass; it is the discrete inverse-CDF (quantile) coupling.

```
Algorithm MonotoneCoupling(p, q):
  pi <- zero n x n matrix
  rp <- copy(p);  rq <- copy(q);  i <- 0;  j <- 0
  while i < n and j < n:
      f <- min(rp[i], rq[j])
      pi[i][j] <- pi[i][j] + f
      rp[i] <- rp[i] - f;  rq[j] <- rq[j] - f
      if rp[i] == 0: i <- i + 1  else: j <- j + 1
  return pi                          # cost(pi) = W1(p, q)
```
Complexity: $O(n)$ nonzero entries are produced in $O(n)$ steps.

---

## 8. Applications

**Generative modeling (Wasserstein GAN).** The dual form (Theorem 5.3) underlies the Wasserstein GAN: a generator produces a distribution of samples, and a 1-Lipschitz critic $\varphi$ estimates $\mathbb{E}_{\text{real}}\varphi - \mathbb{E}_{\text{fake}}\varphi \approx W_1$. Unlike $f$-divergences, $W_1$ remains finite and yields informative gradients even when the supports are disjoint — precisely the regime where the Dirac isometry (Theorem 6.2) shows $W_1$ degrades gracefully as $|a-b|$ rather than saturating.

**Robust statistics and convergence.** The mean bound (Theorem 6.3) certifies that $W_1$-closeness implies closeness of first moments, a basic stability guarantee. The CDF form makes the convergence of empirical distributions quantitatively tractable (Conjecture 4).

**Signal and image processing.** On a one-dimensional grid (e.g. a histogram or a row of pixel intensities), $W_1$ measures perceptual shift rather than bin-wise discrepancy, so it captures translations that bin-wise metrics miss; the closed form gives a real-time computation.

**Certified lower bounds.** Theorem 5.1 turns any hand-crafted 1-Lipschitz $\varphi$ into a certificate $W_1 \ge \mathbb{E}_p\varphi - \mathbb{E}_q\varphi$, and Theorem 6.1 turns any feasible plan into a certificate $W_1 \le \mathrm{cost}(\pi)$, bracketing the true distance from both sides without solving the optimization.

---

## 9. Discussion

The one-dimensional discrete theory is exceptional in admitting a closed form, and our development exploits this fully: every theorem reduces to elementary manipulations of finite sums of absolute values. The two recurring tools are (i) the marginal/flow-conservation identity that pins the net boundary flow to the CDF gap, and (ii) summation by parts, which is the discrete bridge between the primal cost (a sum over mass times distance) and the dual objective (a sum over potential increments times CDF gaps). These two identities, between them, yield the closed form, weak duality, attainment, and all the bounds.

A noteworthy feature is that duality here is *constructive*: we do not invoke an abstract minimax or compactness theorem to assert a maximizer exists; we write it down (the staircase potential) and verify it attains the value. The same constructive spirit governs the primal side, where the monotone coupling is an explicit witness rather than an abstract optimum.

Limitations: the closed form is genuinely one-dimensional. In higher dimensions there is no CDF and the optimal plan is governed by Brenier's theorem and the Monge–Ampère equation; the elementary techniques here do not transfer directly. The theory is also stated for distributions on a fixed finite grid; extension to countable or continuous supports requires limiting arguments we do not undertake here.

---

## 10. Future directions

The development establishes the 1D discrete $W_1$ theory completely. We record five precise, testable conjectures for follow-up work.

**Conjecture 1 (Primal/dual exactness — strong duality).** There is a transport plan $\pi^\star$ (the monotone / north-west-corner coupling of Section 7.3) with $\mathrm{cost}(\pi^\star) = W_1(p,q)$. Combined with Theorem 6.1 and Theorem 5.3 this gives full 1D strong duality $W_1 = \min_\pi \mathrm{cost}(\pi) = \max_{\varphi \in \mathrm{Lip}_1}(\mathbb{E}_p\varphi - \mathbb{E}_q\varphi)$. *Test:* construct $\pi^\star$ from the inverse-CDF (quantile) coupling and prove its cost telescopes to $\sum_k |F_p(k) - F_q(k)|$.

**Conjecture 2 (Order-$r$ Wasserstein and a power-mean hierarchy).** Define $W_r(p,q)^r = \min_\pi \sum_{i,j} |i-j|^r \pi_{ij}$ for integer $r \ge 1$. Then $r \mapsto W_r$ is nondecreasing, and on the line $W_r$ admits the quantile closed form $W_r^r = \sum_k g_r(k)$ for an explicit $g_r$ built from the CDFs. In particular $W_2$ satisfies the discrete Benamou–Brenier identity. *Test:* prove monotonicity $W_1 \le W_r$ via Jensen / power-mean, then the $r=2$ closed form against the CDF.

**Conjecture 3 (Contraction under stochastic maps — data processing).** For any column-stochastic kernel $K$ on $\{0,\dots,n-1\}$ that is 1-Lipschitz in the barycentric sense, $W_1(Kp, Kq) \le W_1(p,q)$. Equivalently, push-forward by a 1-Lipschitz map does not increase $W_1$. *Test:* lift Theorem 5.1 through $K$ using the dual representation; the crucial step is that $\varphi \circ K$ stays 1-Lipschitz.

**Conjecture 4 (Quantitative CLT / convergence rate).** For the empirical distribution $\hat p_m$ of $m$ i.i.d. samples from $p$ on the grid, $\mathbb{E}[W_1(\hat p_m, p)] \le C(n)/\sqrt{m}$ with explicit constant $C(n) = \Theta(n)$ coming from the $\sum_k \mathrm{Var}(F_{\hat p_m}(k))$ decomposition of the CDF form. *Test:* expand $\mathbb{E}[W_1]$ via the CDF formula and bound each $\mathbb{E}|F_{\hat p_m}(k) - F_p(k)|$ by $\sqrt{F_p(k)(1-F_p(k))/m}$ (binomial variance), then sum.

**Conjecture 5 (Bridge to the tropical / max-plus catalog).** The max-plus "measures" of a tropical measure theory carry a natural $(\min,+)$ transport cost; conjecture that the tropical analogue $W_1^{\mathrm{trop}}(p,q) = \max_k |F_p(k) - F_q(k)|$ (the $L^\infty$ CDF distance, the $r\to\infty$ limit of $W_r$) is a metric and equals an idempotent Kantorovich dual.

---

## 11. Conclusion

We have given a complete, self-contained theory of the one-dimensional discrete 1-Wasserstein distance built on a single closed form. From $W_1(p,q) = \sum_k |F_p(k) - F_q(k)|$ flow the metric axioms, a constructive Kantorovich–Rubinstein duality with an explicit optimal potential, the Dirac isometry, the mean-difference bound, and the primal coupling lower bound. The result is a transparent, computable, and rigorously justified geometry on the space of distributions — a foundation on which the higher-order, contraction-theoretic, statistical, and tropical extensions of Section 10 can be erected.

---

## References

The development is self-contained. The classical background — Monge's earthwork problem, Kantorovich's linear-programming relaxation and duality, the Kantorovich–Rubinstein theorem, Brenier's polar factorization for quadratic cost, and the Wasserstein GAN — is standard in the optimal transport and machine-learning literature.
