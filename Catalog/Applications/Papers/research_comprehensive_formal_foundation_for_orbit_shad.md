# Tropical Orbit Shadowing: Non-Autonomous Contraction Dynamics and Max-Plus Certificate Theory

## Abstract

We develop a comprehensive theory of orbit shadowing for non-autonomous dynamical systems with time-varying contraction rates, and connect it to tropical (max-plus) dynamics. Our main contributions are: (1) a **variable-rate inductive bound** for non-autonomous systems where the n-th map has Lipschitz constant L_n, yielding the tracking error bound e_n ≤ δ · Σ_{k=0}^{n-1} Π_{j=k+1}^{n-1} L_j; (2) a **uniform contractive shadowing theorem** recovering the classical δ/(1−L) bound as a corollary; (3) a **defect triangle inequality** enabling compositional certified computation; (4) a proof that **tropical max-plus matrix-vector multiplication is non-expansive** (1-Lipschitz) in the supremum metric; and (5) a **certificate composition principle** for tropical shadowing certificates. All results are formally verified in Lean 4 with Mathlib. We also state a falsifiable conjecture on the Birkhoff contraction coefficient for scrambling tropical matrices.

**Keywords**: orbit shadowing, non-autonomous dynamical systems, tropical algebra, max-plus linear systems, contraction mappings, certified computation, Birkhoff contraction

---

## 1. Introduction

Orbit shadowing is a fundamental concept in dynamical systems theory, originating in the work of Anosov [1] and Bowen [2] on hyperbolic systems. The shadowing lemma asserts that every pseudo-orbit (a sequence where each step approximately follows the dynamics) is uniformly close to a genuine orbit. In the contractive setting, the shadowing radius admits the explicit bound δ/(1−L), where δ is the per-step error and L < 1 is the Lipschitz constant.

Classical shadowing theory assumes **autonomous** dynamics: the same map f governs every time step. This assumption is violated in numerous applications:
- **Stochastic gradient descent** with learning rate schedules
- **Model predictive control** with time-varying plant dynamics  
- **Tropical matrix iteration** where the effective contraction rate depends on state
- **Numerical integration** with adaptive step sizes

In this paper, we extend the theory to **non-autonomous** dynamical systems f₀, f₁, f₂, ..., where each map fₙ may have a different Lipschitz constant Lₙ. Our variable-rate inductive bound captures exactly how errors interact through the accumulated products of contraction rates.

We then connect this framework to **tropical (max-plus) dynamics**. The tropical matrix-vector product (A ⊗ x)ᵢ = max_j(Aᵢⱼ + xⱼ) defines a dynamical system on ℝⁿ that is always 1-Lipschitz (non-expansive) in the supremum metric. Under additional spectral conditions (the Birkhoff contraction property), the oscillation of orbits contracts strictly, enabling shadowing guarantees. We formalize the non-expansiveness result and state a precise conjecture on the Birkhoff contraction coefficient.

All theorems in this paper are formally verified in Lean 4 using the Mathlib library, providing machine-checked guarantees of correctness.

---

## 2. Preliminaries

### 2.1 Notation and Conventions

Let (α, d) be a pseudo-metric space. For a map f : α → α, we say f is L-Lipschitz if d(f(x), f(y)) ≤ L · d(x, y) for all x, y ∈ α. The n-th iterate of f is denoted f^[n].

### 2.2 Autonomous Shadowing (Review)

**Definition 2.1** (Pseudo-orbit). A sequence x : ℕ → α is a δ-pseudo-orbit of f if d(f(xₙ), xₙ₊₁) ≤ δ for all n.

**Definition 2.2** (Shadowing). A sequence y : ℕ → α ε-shadows x if y is a true orbit (yₙ₊₁ = f(yₙ)) and d(yₙ, xₙ) ≤ ε for all n.

**Theorem 2.3** (Contractive Shadowing Lemma). If f is L-Lipschitz with L < 1, δ ≥ 0, and x is a δ-pseudo-orbit of f, then the true orbit starting at x(0) shadows x with radius δ/(1−L).

This theorem was previously formalized by the authors in [OrbitShadowingDeep.lean].

---

## 3. Non-Autonomous Shadowing Theory

### 3.1 Definitions

**Definition 3.1** (Non-autonomous pseudo-orbit). Given a sequence of maps f : ℕ → α → α, a sequence x : ℕ → α is a δ-pseudo-orbit if d(fₙ(xₙ), xₙ₊₁) ≤ δ for all n.

**Definition 3.2** (Non-autonomous true orbit). The true orbit starting at a ∈ α is defined recursively:
- trueOrbit(f, a, 0) = a
- trueOrbit(f, a, n+1) = fₙ(trueOrbit(f, a, n))

**Definition 3.3** (Accumulated product). For a sequence L : ℕ → ℝ, the accumulated product from step k+1 to n−1 is:
$$\text{accumProduct}(L, k, n) = \prod_{j=k+1}^{n-1} L_j$$

**Definition 3.4** (Accumulated error sum). The accumulated error sum is:
$$\text{accumErrorSum}(L, n) = \sum_{k=0}^{n-1} \text{accumProduct}(L, k, n) = \sum_{k=0}^{n-1} \prod_{j=k+1}^{n-1} L_j$$

### 3.2 Variable-Rate Inductive Bound

**Theorem 3.5** (Variable-Rate Inductive Bound). Let f : ℕ → α → α be a sequence of maps with fₙ being Lₙ-Lipschitz. If x is a δ-pseudo-orbit with δ ≥ 0, then:
$$d(\text{trueOrbit}(f, x_0, n), x_n) \leq \delta \cdot \text{accumErrorSum}(L, n)$$

*Proof sketch.* By induction on n.

**Base case** (n = 0): d(x₀, x₀) = 0 ≤ δ · 0.

**Inductive step** (n → n+1): By the triangle inequality and Lipschitz property:
$$d(\text{trueOrbit}(n+1), x_{n+1}) \leq L_n \cdot d(\text{trueOrbit}(n), x_n) + \delta$$

Applying the inductive hypothesis:
$$\leq L_n \cdot \delta \cdot \text{accumErrorSum}(L, n) + \delta = \delta \cdot (L_n \cdot \text{accumErrorSum}(L, n) + 1)$$

The key algebraic identity is:
$$\text{accumErrorSum}(L, n+1) = L_n \cdot \text{accumErrorSum}(L, n) + 1$$

This follows because:
$$\text{accumErrorSum}(L, n+1) = \sum_{k=0}^{n} \prod_{j=k+1}^{n} L_j = \prod_{j=1}^{n} L_j + \sum_{k=1}^{n} \prod_{j=k+1}^{n} L_j$$

Factoring $L_n$ from the first n terms and noting the last term is the empty product (= 1) gives the identity. ∎

### 3.3 Uniform Contractive Shadowing

**Theorem 3.6** (Uniform Contractive Shadowing). If all Lipschitz constants satisfy Lₙ ≤ L_b < 1, then:
$$d(\text{trueOrbit}(f, x_0, n), x_n) \leq \frac{\delta}{1 - L_b}$$

*Proof sketch.* By Theorem 3.5, it suffices to show accumErrorSum(L, n) ≤ 1/(1−L_b). Each accumulated product satisfies:
$$\text{accumProduct}(L, k, n) = \prod_{j=k+1}^{n-1} L_j \leq \prod_{j=k+1}^{n-1} L_b = L_b^{n-k-1}$$

Therefore:
$$\text{accumErrorSum}(L, n) \leq \sum_{k=0}^{n-1} L_b^{n-k-1} = \sum_{i=0}^{n-1} L_b^i \leq \frac{1}{1 - L_b}$$

The last inequality uses the geometric series bound. ∎

**Remark 3.7.** Theorem 3.6 recovers the autonomous contractive shadowing lemma (Theorem 2.3) as a special case when fₙ = f for all n.

---

## 4. Compositional Certificate Theory

### 4.1 Defect Triangle Inequality

**Theorem 4.1** (Defect Triangle Inequality). If y is within ε₁ of x and z is within ε₂ of y over [0, N], then z is within ε₁ + ε₂ of x over [0, N].

*Proof.* Direct application of the metric triangle inequality: d(zₙ, xₙ) ≤ d(zₙ, yₙ) + d(yₙ, xₙ) ≤ ε₂ + ε₁. ∎

### 4.2 Iterated Contraction Bound

**Theorem 4.2** (Iterated Contraction Fixed-Point Distance). If f is L-Lipschitz with fixed point p (f(p) = p), then:
$$d(f^{[n]}(x), p) \leq L^n \cdot d(x, p)$$

*Proof.* Induction on n, using f(p) = p and the Lipschitz property at each step. ∎

### 4.3 Tropical Shadowing Certificates

**Definition 4.3.** A Tropical Shadowing Certificate bundles:
- A dynamical map f : α → α
- A Lipschitz constant L < 1 with proof
- A per-step deviation bound δ ≥ 0

The certified shadowing radius is R = δ/(1−L).

**Theorem 4.4** (Certificate Composition Bound). For two certificates with parameters (δ₁, L₁) and (δ₂, L₂), if max(L₁, L₂) < 1:
$$\max\left(\frac{\delta_1}{1 - L_1}, \frac{\delta_2}{1 - L_2}\right) \leq \frac{\max(\delta_1, \delta_2)}{1 - \max(L_1, L_2)}$$

*Proof.* For each i, δᵢ ≤ max(δ₁, δ₂) and 1 − max(L₁, L₂) ≤ 1 − Lᵢ, so δᵢ/(1−Lᵢ) ≤ max(δ₁, δ₂)/(1−max(L₁, L₂)). ∎

---

## 5. Tropical Max-Plus Non-Expansiveness

### 5.1 Max-Plus Matrix-Vector Product

**Definition 5.1.** The tropical (max-plus) matrix-vector product for A : Fin n → Fin n → ℝ and x : Fin n → ℝ is:
$$(A \otimes x)_i = \max_j (A_{ij} + x_j)$$

### 5.2 Non-Expansiveness

**Theorem 5.2** (Tropical Component-wise Non-Expansiveness). For all i:
$$|(A \otimes x)_i - (A \otimes y)_i| \leq \sup_j |x_j - y_j|$$

*Proof sketch.* For the forward direction, let j* achieve the maximum for x in row i:
$$(A \otimes x)_i = A_{ij^*} + x_{j^*} \leq A_{ij^*} + y_{j^*} + |x_{j^*} - y_{j^*}| \leq (A \otimes y)_i + \sup_j |x_j - y_j|$$

By symmetry (swapping x and y), the reverse inequality also holds. ∎

**Corollary 5.3.** The map x ↦ A ⊗ x is 1-Lipschitz in the ℓ∞ metric on ℝⁿ.

### 5.3 Implications for Shadowing

Since tropical linear maps are 1-Lipschitz but not strictly contractive, the basic contractive shadowing lemma (which requires L < 1) does not directly apply. Errors accumulate linearly: after m steps with per-step perturbation δ, the worst-case error is mδ.

To achieve strict contraction (and hence bounded shadowing radius), additional structure is needed. The **Birkhoff contraction theorem** provides this: when a tropical matrix is "scrambling" (every pair of rows couples through some common column), the oscillation osc(x) = max(x) − min(x) contracts strictly under tropical multiplication.

---

## 6. Falsifiable Conjecture

**Conjecture 6.1** (Birkhoff Contraction for Scrambling Tropical Matrices). For every n ≥ 1 and every n × n tropical matrix A such that for all row pairs (i₁, i₂), there exists a column j with A_{i₁,j} > −B and A_{i₂,j} > −B (where B is a fixed bound), there exists τ ∈ [0, 1) such that:
$$\text{osc}(A \otimes x) \leq \tau \cdot \text{osc}(x) \quad \text{for all } x \in \mathbb{R}^n$$

**Computational Test**: For the matrix A = [[0, −1, −2], [−2, 0, −1], [−1, −2, 0]], compute τ(A) via:
$$\tau(A) = \sup_{x : \text{osc}(x) > 0} \frac{\text{osc}(A \otimes x)}{\text{osc}(x)}$$

and verify computationally that τ(A) < 1 using 10,000 random vectors. The theoretical prediction is τ(A) = tanh(diam(A)/4) where diam(A) = max_{i,j,k}(A_{ij} − A_{ik}).

---

## 7. Algorithms

### 7.1 Tropical Matrix-Vector Product

```
Input: A ∈ ℝ^{n×n}, x ∈ ℝ^n
Output: y = A ⊗ x ∈ ℝ^n
For i = 1 to n:
    y[i] = max_j(A[i][j] + x[j])
Return y
```

Complexity: O(n²) per step, O(n²m) for m iterations.

### 7.2 Shadowing Certificate Construction

```
Input: Map f, Lipschitz constant L < 1, per-step error bound δ
Output: Shadowing certificate with radius δ/(1-L)
1. Verify L < 1 (contraction)
2. Verify δ ≥ 0
3. Compute R = δ / (1 - L)
4. Return Certificate(f, L, δ, R)
```

### 7.3 Non-Autonomous Error Bound

```
Input: Lipschitz constants L[0], ..., L[n-1], per-step error δ
Output: Error bound at step n
1. Initialize error_sum = 0
2. For k = 0 to n-1:
     product = Π_{j=k+1}^{n-1} L[j]
     error_sum += product
3. Return δ * error_sum
```

---

## 8. Applications and Discussion

### 8.1 SGD with Learning Rate Schedules

For SGD with learning rate ηₜ on a μ-strongly convex, β-smooth function, the gradient step has Lipschitz constant Lₜ = |1 − ηₜμ| (assuming ηₜ ≤ 2/β). With a cosine annealing schedule ηₜ = η₀ · (1 + cos(πt/T))/2, the non-autonomous shadowing bound gives tighter tracking guarantees than the worst-case autonomous bound.

### 8.2 Tropical Dynamics in Neural Networks

ReLU neural network layers can be expressed as tropical polynomial evaluations. The compositional structure of shadowing certificates aligns with the layer-by-layer structure of deep networks, enabling modular robustness certification.

### 8.3 Certified Numerical Integration

Adaptive ODE solvers change step sizes (and hence the effective dynamics) at each step. The non-autonomous shadowing framework provides a priori error bounds that account for the varying step sizes, complementing traditional a posteriori error estimators.

---

## 9. Future Work

1. **Hyperbolic shadowing**: Extend to systems with both expanding and contracting directions (Anosov-Bowen theorem formalization).
2. **Stochastic shadowing**: Probabilistic bounds for random perturbations.
3. **Adaptive certificates**: Streaming certificate construction with online updates.
4. **Birkhoff contraction formalization**: Full proof of the Birkhoff contraction theorem for tropical matrices.

---

## References

[1] D. V. Anosov, "Geodesic flows on closed Riemannian manifolds of negative curvature," *Proceedings of the Steklov Institute of Mathematics*, vol. 90, 1967.

[2] R. Bowen, "ω-limit sets for Axiom A diffeomorphisms," *Journal of Differential Equations*, vol. 18, pp. 333–339, 1975.

[3] S. Gaubert and J. Gunawardena, "The Perron-Frobenius theorem for homogeneous, monotone functions," *Transactions of the AMS*, vol. 356, pp. 4931–4950, 2004.

[4] G. Birkhoff, "Extensions of Jentzsch's theorem," *Transactions of the AMS*, vol. 85, pp. 219–227, 1957.

[5] P. J. Bushell, "Hilbert's metric and positive contraction mappings in a Banach space," *Archive for Rational Mechanics and Analysis*, vol. 52, pp. 330–338, 1973.
