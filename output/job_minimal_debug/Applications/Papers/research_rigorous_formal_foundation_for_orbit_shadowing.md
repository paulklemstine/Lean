# Deep Orbit Shadowing: Composition, Structural Stability, and Applications to Gradient Descent

## Abstract

We develop a rigorous formal theory of orbit shadowing for discrete dynamical systems over pseudo-metric spaces, extending the classical contractive shadowing lemma in three directions. First, we prove a **structural stability theorem** showing that shadowing survives uniform perturbations of the dynamics: if a map g is ρ-close to an L-contraction f, then δ-pseudo-orbits of g are (δ+ρ)/(1−L)-shadowed by true orbits of f. Second, we introduce **composable shadowing certificates** — computational witness structures that bundle pseudo-orbits with their verified shadows and compose along orbit segments with bounded error accumulation. Third, we establish a **gradient descent shadowing theorem** showing that stochastic gradient descent on strongly convex losses is precisely a pseudo-orbit of exact gradient descent, immediately certifying convergence within σ/(1−L). We prove tightness of the δ/(1−L) bound by constructing a family of pseudo-orbits achieving the optimal shadowing radius in the limit. All results are formalized in Lean 4 with machine-verified proofs.

**Keywords**: orbit shadowing, pseudo-orbit, contraction mapping, structural stability, gradient descent, shadowing certificate, dynamical systems

---

## 1. Introduction

The shadowing lemma is a cornerstone of the theory of dynamical systems, asserting that approximate orbits (pseudo-orbits) of well-behaved maps are tracked by genuine orbits within quantified bounds. First established for hyperbolic diffeomorphisms by Anosov (1967) and Bowen (1975), the shadowing property has found applications in numerical dynamics, ergodic theory, and computational topology.

In this paper we focus on the contractive case — maps with Lipschitz constant L < 1 — where the shadowing analysis is both clean and directly applicable to iterative algorithms in optimization and machine learning. Our contributions are:

1. **Contractive Shadowing Lemma** (Theorem 3.1): A self-contained proof that every δ-pseudo-orbit of an L-contraction is δ/(1−L)-shadowed, with an explicit inductive bound via geometric partial sums.

2. **Structural Stability** (Theorem 4.1): If g is uniformly ρ-close to an L-contraction f, then pseudo-orbits of g are (δ+ρ)/(1−L)-shadowed by true orbits of f. This addresses the practically important case where the implemented dynamics approximates the theoretical map.

3. **Gradient Descent Shadowing** (Theorem 5.1): Noisy gradient descent (including SGD) on strongly convex losses is σ/(1−L)-shadowed by exact gradient descent, providing a new perspective on SGD convergence.

4. **Certificate Composition** (Section 6): Shadowing certificates compose along orbit boundaries with bounded mismatch, enabling modular certification of long computations.

5. **Tightness** (Theorem 7.1): The bound δ/(1−L) is tight — we construct pseudo-orbits achieving arbitrarily close to this optimal radius.

6. **Defect Shift Stability** (Theorem 8.1): The shadowing defect over a finite window changes by at most L·D + δ under a one-step time shift.

---

## 2. Definitions

**Definition 2.1** (Pseudo-orbit). Let (α, d) be a pseudo-metric space and f : α → α. A sequence x : ℕ → α is a *δ-pseudo-orbit* of f if for all n ∈ ℕ,
$$d(f(x_n), x_{n+1}) \leq \delta.$$

**Definition 2.2** (Shadowing). A sequence y : ℕ → α *ε-shadows* a sequence x if y is a true orbit of f (i.e., y_{n+1} = f(y_n) for all n) and d(y_n, x_n) ≤ ε for all n.

**Definition 2.3** (True orbit). The true orbit of f starting at a is defined recursively:
$$\text{orbit}(0) = a, \quad \text{orbit}(n+1) = f(\text{orbit}(n)).$$

**Definition 2.4** (Expansive map). A map f is c-expansive if for all x₁, x₂ ∈ α,
$$(\forall n \in \mathbb{N},\; d(f^n(x_1), f^n(x_2)) \leq c) \implies x_1 = x_2.$$

**Definition 2.5** (Gradient System). A gradient system is a tuple (α, step, L) where step : α → α is an L-Lipschitz map with L < 1, modeling gradient descent on a strongly convex function.

**Definition 2.6** (Shadowing Defect). The shadowing defect of y relative to x over window [0, N] is:
$$D_N(y, x) = \max_{0 \leq n \leq N} d(y_n, x_n).$$

**Definition 2.7** (Composed Certificate). A composed certificate over two consecutive segments [0, len₁] and [len₁, len₁ + len₂] consists of two shadow orbits, each tracking the pseudo-orbit on their respective segment, with independent shadowing radii ε₁ and ε₂.

---

## 3. Contractive Shadowing Lemma

**Lemma 3.1** (Inductive Distance Bound). If f is L-Lipschitz and x is a δ-pseudo-orbit with δ ≥ 0, then
$$d(\text{orbit}_f(x_0, n), x_n) \leq \delta \sum_{i=0}^{n-1} L^i.$$

*Proof.* By induction on n. The base case n = 0 is trivial. For the inductive step:
$$d(\text{orbit}(n+1), x_{n+1}) \leq d(f(\text{orbit}(n)), f(x_n)) + d(f(x_n), x_{n+1})$$
$$\leq L \cdot d(\text{orbit}(n), x_n) + \delta \leq L \cdot \delta \sum_{i<n} L^i + \delta = \delta \sum_{i<n+1} L^i.$$

**Theorem 3.2** (Contractive Shadowing Lemma). If f is L-Lipschitz with L < 1 and x is a δ-pseudo-orbit with δ ≥ 0, then orbit_f(x_0) ε-shadows x with ε = δ/(1−L).

*Proof.* The orbit property holds by definition. For the distance bound, the partial geometric sum satisfies
$$\sum_{i=0}^{n-1} L^i \leq \sum_{i=0}^{\infty} L^i = \frac{1}{1-L},$$
so d(orbit(n), x_n) ≤ δ · 1/(1−L) = δ/(1−L). □

---

## 4. Structural Stability of Shadowing

**Lemma 4.1** (Perturbed Pseudo-orbit Transfer). If g is ρ-close to f (i.e., d(f(x), g(x)) ≤ ρ for all x) and x is a δ-pseudo-orbit of g, then x is a (δ+ρ)-pseudo-orbit of f.

*Proof.* d(f(x_n), x_{n+1}) ≤ d(f(x_n), g(x_n)) + d(g(x_n), x_{n+1}) ≤ ρ + δ. □

**Theorem 4.2** (Structural Stability). Under the hypotheses of Lemma 4.1 with f being an L-contraction (L < 1), the true orbit of f starting at x_0 shadows x within radius (δ+ρ)/(1−L).

*Proof.* Apply Lemma 4.1 to obtain a (δ+ρ)-pseudo-orbit of f, then apply Theorem 3.2. □

This result is crucial for applications: it says that shadowing is robust not just to computational errors (δ) but also to modeling errors (ρ). The two error sources combine additively in the numerator, reflecting the triangle inequality structure of the proof.

---

## 5. Gradient Descent as Contraction Dynamics

**Definition 5.1**. A gradient system models gradient descent on a strongly convex function. The step map x ↦ x − η∇f(x) is L-Lipschitz with L = 1 − 2ημ/(μ+M) < 1, where μ is the strong convexity parameter and M is the smoothness parameter.

**Theorem 5.2** (Gradient Descent Shadowing). If GS = (α, step, L) is a gradient system and x is a noisy orbit with per-step noise σ ≥ 0 (i.e., x is a σ-pseudo-orbit of step), then the exact gradient descent orbit starting at x_0 shadows x within radius σ/(1−L).

*Proof.* Direct application of Theorem 3.2 to step with δ = σ. □

**Interpretation**: Stochastic gradient descent with mini-batch noise bounded by σ produces a trajectory that is σ/(1−L)-close to the exact (full-batch) gradient descent trajectory at every step. For strongly convex losses with condition number κ = M/μ and optimal step size η = 2/(μ+M):
- L = (κ−1)/(κ+1)
- 1−L = 2/(κ+1)  
- Shadowing radius = σ(κ+1)/2

This provides a non-asymptotic, deterministic bound on SGD accuracy that complements probabilistic convergence analyses.

---

## 6. Certificate Composition

Shadowing certificates are computational witnesses that can be inspected, stored, and composed.

**Theorem 6.1** (Boundary Mismatch Bound). For a composed certificate with segments [0, len₁] and [len₁, len₁+len₂] with shadowing radii ε₁ and ε₂ respectively,
$$d(\text{shadow}_1(\text{len}_1), \text{shadow}_2(0)) \leq \varepsilon_1 + \varepsilon_2.$$

*Proof.* Triangle inequality: d(s₁(len₁), s₂(0)) ≤ d(s₁(len₁), x(len₁)) + d(x(len₁), s₂(0)) ≤ ε₁ + ε₂. □

This enables modular verification: certify each segment of a long computation independently, then bound the accumulated error at composition boundaries.

---

## 7. Tightness of the Optimal Bound

**Theorem 7.1** (Optimal Radius Achievability). For f(x) = Lx on ℝ with 0 ≤ L < 1, the pseudo-orbit x_n = δ · ∑_{i<n} L^i is a δ-pseudo-orbit (with per-step deviation exactly δ), and
$$\inf_{y_0 \in \mathbb{R}} \sup_{n \in \mathbb{N}} |y_0 L^n - x_n| = \frac{\delta}{1-L}.$$

In particular, the true orbit starting at 0 achieves distance x_n = δ(1−L^n)/(1−L) → δ/(1−L) from the pseudo-orbit, showing the bound is tight.

*Proof.* The pseudo-orbit property is verified by direct computation: |L·x_n − x_{n+1}| = δ. The convergence of the distance to δ/(1−L) follows from the convergence of the geometric partial sum ∑_{i<n} L^i → 1/(1−L). □

---

## 8. Shadowing Defect Dynamics

**Theorem 8.1** (Orbit Shift Defect Bound). For an L-Lipschitz map f, if y is a true orbit and x is a δ-pseudo-orbit, then the shadowing defect satisfies:
$$D_N(\text{shift}(y), \text{shift}(x)) \leq L \cdot D_{N+1}(y, x) + \delta.$$

*Proof.* For each n ≤ N:
$$d(y_{n+1}, x_{n+1}) = d(f(y_n), x_{n+1}) \leq d(f(y_n), f(x_n)) + d(f(x_n), x_{n+1}) \leq L \cdot d(y_n, x_n) + \delta.$$
Since d(y_n, x_n) ≤ D_{N+1}(y, x) for n ≤ N ≤ N+1, we get d(y_{n+1}, x_{n+1}) ≤ L·D_{N+1} + δ for all n ≤ N. Taking the sup yields the result. □

**Corollary**: Under a contraction (L < 1), the defect sequence D_N, D_{N-1}, ... is itself contractive in the time-shift direction, converging to δ/(1−L).

---

## 9. Exponential Error Decay and Fixed-Point Convergence

**Theorem 9.1** (Contraction Error Decay). For an L-Lipschitz map, d(f^n(a), f^n(b)) ≤ L^n · d(a, b).

**Theorem 9.2** (Shadow Converges to Fixed Point). If f has a fixed point p and is an L-contraction, then for any δ-pseudo-orbit x:
$$d(\text{orbit}_f(x_0, n), p) \leq L^n \cdot d(x_0, p) + \frac{\delta}{1-L}.$$

The first term decays exponentially; the second is the noise floor. This quantifies the well-known principle that contractive iterations "forget" initial conditions while maintaining bounded sensitivity to noise.

---

## 10. Discussion and Future Work

### Connections to Machine Learning
The gradient descent shadowing theorem provides a deterministic, non-asymptotic bound on the tracking error between stochastic and exact gradient descent. Unlike probabilistic convergence bounds that hold "in expectation" or "with high probability," the shadowing bound is worst-case and holds at every step simultaneously.

### Connections to Numerical Analysis
The structural stability theorem addresses a fundamental concern in scientific computing: when both the algorithm and the model introduce errors, does the computation still approximate reality? Our result shows that model error and computational error combine additively in the shadowing radius, which is the best one could hope for.

### Grand Challenges

1. **Hyperbolic Shadowing**: Extending to the full Anosov-Bowen setting with simultaneous expansion and contraction requires formalizing stable/unstable manifold theory — a major undertaking.

2. **Stochastic Shadowing**: Replacing deterministic noise bounds with probabilistic guarantees would connect to MCMC certification and Langevin dynamics.

3. **Infinite-Dimensional Extensions**: Shadowing for PDE discretizations (method of lines, spectral methods) would require extending the theory to Banach spaces.

---

## References

1. D.V. Anosov, "Geodesic flows on closed Riemannian manifolds of negative curvature," *Proceedings of the Steklov Institute*, 1967.
2. R. Bowen, *Equilibrium States and the Ergodic Theory of Anosov Diffeomorphisms*, Springer LNM 470, 1975.
3. S.Yu. Pilyugin, *Shadowing in Dynamical Systems*, Springer LNM 1706, 1999.
4. K.J. Palmer, *Shadowing in Dynamical Systems: Theory and Applications*, Springer, 2000.
5. S. Bubeck, "Convex optimization: Algorithms and complexity," *Foundations and Trends in Machine Learning*, 2015.
