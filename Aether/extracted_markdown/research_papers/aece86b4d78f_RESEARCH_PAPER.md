# Mathematical Foundations for Quantum EML Activation Functions

## Abstract

We establish rigorous mathematical foundations connecting the EML (Exponential-Minus-Logarithm) activation function eml(x,y) = exp(x) − log(y) to quantum phase operations and tropical semiring algebra. Our main results include: (1) the **quantum-classical gap bound** 2(1 − cos θ) ≤ θ², connecting classical EML values to quantum gate fidelity; (2) **logarithmic factoring and cancellation laws** for EML composition; (3) **surjectivity** of the quantum EML phase map onto all rotation angles with an explicit compilation formula; (4) a **tropical quantum n-bound** 2(1 − cos(Σθᵢ)) ≤ n·Σθᵢ² via Cauchy-Schwarz; (5) **sub-additivity** of quantum infidelity: 1 − cos(a+b) ≤ 2(1−cos a) + 2(1−cos b); and (6) **linear divergence** of EML diagonal orbits with the bound dⁿ(z) ≥ z + n. All results are formalized and verified in Lean 4 with the Mathlib library. We identify the tropical semiring as the natural algebraic framework for quantum error composition, with the max-plus structure governing how individual gate errors combine into circuit-level bounds.

**Keywords**: EML activation function, quantum phase, tropical semiring, gap bound, Lean 4

---

## 1. Introduction

The EML (Exponential-Minus-Logarithm) function eml(x,y) = exp(x) − log(y) arises naturally in neural network architectures that combine exponential and logarithmic nonlinearities. Previous work established basic algebraic properties of EML, including strict convexity of the self-pair σ(x) = exp(x) − x and the divergence of diagonal orbits.

This paper investigates a new direction: the connection between EML values and quantum computing operations. We show that EML values naturally parameterize quantum phase rotations, and that the algebraic properties of EML translate directly into quantitative bounds on quantum gate errors.

### 1.1 Main Contributions

1. **Quantum-Classical Gap Bound (Theorem 2.1)**: For all θ ∈ ℝ, 2(1 − cos θ) ≤ θ², connecting classical EML magnitudes to quantum infidelity. This follows from the classical inequality cos θ ≥ 1 − θ²/2.

2. **Algebraic Structure (Section 3)**: We prove logarithmic factoring (eml(x, y₁y₂) = eml(x,y₁) − log y₂) and exact cancellation (eml(x,y) − eml(x,y') = log y' − log y), revealing that the exponential component cancels in EML differences.

3. **Phase Surjectivity (Theorem 3.3)**: For any target angle α, eml(0, exp(1−α)) = α, providing an explicit quantum-to-classical compilation formula.

4. **Tropical-Quantum Bridge (Section 4)**: The tropical n-bound 2(1−cos(Σθᵢ)) ≤ n·Σθᵢ² via Cauchy-Schwarz, and the max-bound max(2(1−cos θ₁), 2(1−cos θ₂)) ≤ max(θ₁², θ₂²).

5. **Sub-Additivity (Theorem 5.1)**: 1−cos(a+b) ≤ 2(1−cos a) + 2(1−cos b), proved using trigonometric product-to-sum identities and the Pythagorean identity.

6. **Orbital Dynamics (Section 6)**: Linear divergence dⁿ(z) ≥ z+n for the EML diagonal iteration d(z) = exp(z) − log(z), with positivity d(z) > 0 for z > 0.

### 1.2 Catalog References

This work builds upon:
- `Catalog/EML/Core.lean`: Basic EML properties including `emlSelfPair_strictConvex`, `emlDiag_ge_add_one`, `emlDiag_orbit_diverge`
- `Catalog/Tropical/QuantumTropical.lean`: Tropical R-matrix and crystal character theory
- `Catalog/Tropical/QuantumTropicalComputation.lean`: Quantum-tropical computation framework

---

## 2. The Quantum-Classical Gap Bound

### 2.1 Setup

**Definition 2.1** (EML Function). For x, y ∈ ℝ, the EML function is:
$$\text{eml}(x, y) = e^x - \log y$$

**Definition 2.2** (Quantum Infidelity). For a rotation angle θ:
$$\mathcal{I}(\theta) = 1 - \cos\theta$$

This measures the squared Euclidean distance from exp(iθ) to 1 on the unit circle: |exp(iθ) − 1|² = 2(1 − cos θ).

### 2.2 Main Inequality

**Theorem 2.1** (Quantum-Classical Gap Bound). For all θ ∈ ℝ:
$$2(1 - \cos\theta) \leq \theta^2$$

*Proof Sketch*: From the classical Taylor remainder bound, cos θ ≥ 1 − θ²/2. Rearranging gives 1 − cos θ ≤ θ²/2, hence 2(1 − cos θ) ≤ θ². □

**Theorem 2.2** (Tightness). The bound is tight at θ = 0:
$$2(1 - \cos 0) = 0 = 0^2$$

**Theorem 2.3** (Infidelity Bound). 𝒥(θ) ≤ θ²/2 for all θ ∈ ℝ.

**Theorem 2.4** (Error Accumulation). For n gates each with angle ε:
$$2(1 - \cos(n\varepsilon)) \leq (n\varepsilon)^2$$

This is a direct corollary of Theorem 2.1.

---

## 3. Algebraic Structure of EML

### 3.1 Basic Properties

**Theorem 3.1** (EML Lower Bound). eml(x,y) ≥ 1 + x − log y, from exp(x) ≥ 1+x.

**Theorem 3.2** (Self-Pair Gap). eml(x, eˣ) ≥ 1 for all x ∈ ℝ.

### 3.2 Composition Laws

**Theorem 3.3** (Logarithmic Factoring). For y₁, y₂ > 0:
$$\text{eml}(x, y_1 \cdot y_2) = \text{eml}(x, y_1) - \log y_2$$

*Proof*: eml(x, y₁y₂) = eˣ − log(y₁y₂) = eˣ − log y₁ − log y₂ = eml(x,y₁) − log y₂. □

**Theorem 3.4** (Cancellation). For all x, y, y':
$$\text{eml}(x, y) - \text{eml}(x, y') = \log y' - \log y$$

*Proof*: (eˣ − log y) − (eˣ − log y') = log y' − log y. □

**Theorem 3.5** (Phase Negation). eml(0, exp(1+α)) = −α.

*Proof*: eml(0, exp(1+α)) = e⁰ − log(exp(1+α)) = 1 − (1+α) = −α. □

### 3.3 Surjectivity

**Theorem 3.6** (Phase Surjectivity). For every α ∈ ℝ, there exist x, y with y > 0 such that eml(x,y) = α.

*Construction*: Take x = 0, y = exp(1−α). Then eml(0, exp(1−α)) = 1 − (1−α) = α.

**Theorem 3.7** (Quantum Universality). Any finite sequence of angles (α₁,...,αₙ) can be realized by EML activations with positive y-inputs.

### 3.4 Monotonicity

**Theorem 3.8**. eml is strictly increasing in x (for fixed y).

**Theorem 3.9**. eml is strictly decreasing in y on (0,∞) (for fixed x).

---

## 4. Tropical-Quantum Bridge

### 4.1 Two-Angle Bridge

**Theorem 4.1** (Tropical Quantum Error Bridge). For all θ₁, θ₂ ∈ ℝ:
$$2(1 - \cos(\theta_1 + \theta_2)) \leq 2(\theta_1^2 + \theta_2^2)$$

*Proof*: By the gap bound, 2(1−cos(θ₁+θ₂)) ≤ (θ₁+θ₂)². By AM-GM, (θ₁+θ₂)² ≤ 2(θ₁²+θ₂²). □

**Theorem 4.2** (Tropical Max Bound).
$$\max(2(1-\cos\theta_1), 2(1-\cos\theta_2)) \leq \max(\theta_1^2, \theta_2^2)$$

### 4.2 Three-Angle Bridge

**Theorem 4.3** (Tropical Triangle).
$$2(1 - \cos(a+b+c)) \leq 3(a^2 + b^2 + c^2)$$

*Proof*: Gap bound gives ≤ (a+b+c)². Cauchy-Schwarz gives (a+b+c)² ≤ 3(a²+b²+c²). □

### 4.3 N-Angle Generalization

**Theorem 4.4** (N-Bound). For θ₁,...,θₙ ∈ ℝ:
$$2\left(1 - \cos\left(\sum_{i=1}^n \theta_i\right)\right) \leq n \sum_{i=1}^n \theta_i^2$$

*Proof*: Combine the gap bound 2(1−cos(Σθᵢ)) ≤ (Σθᵢ)² with the Cauchy-Schwarz inequality (Σθᵢ)² = (Σ1·θᵢ)² ≤ (Σ1²)(Σθᵢ²) = n·Σθᵢ². The Cauchy-Schwarz step uses `Finset.sum_mul_sq_le_sq_mul_sq` from Mathlib. □

### 4.4 Interpretation

The factor n in the n-bound is the *tropical dimension* of the error space. In the tropical semiring (ℝ, max, +), the max operation selects the dominant error term, while the additive structure governs composition. The Cauchy-Schwarz factor n measures the gap between the tropical norm (max) and the Euclidean norm (root-sum-squares).

---

## 5. Sub-Additivity of Quantum Infidelity

**Theorem 5.1** (Sub-Additivity). For all a, b ∈ ℝ:
$$1 - \cos(a+b) \leq 2(1 - \cos a) + 2(1 - \cos b)$$

*Proof*: Expand cos(a+b) = cos a cos b − sin a sin b. The inequality becomes:

1 − cos a cos b + sin a sin b ≤ 4 − 2cos a − 2cos b

Equivalently: 2cos a + 2cos b − cos a cos b + sin a sin b ≤ 3.

The proof uses the Pythagorean identity sin²a + cos²a = 1 and nlinarith with the auxiliary squares (cos a − cos b)², (sin a − sin b)², (cos a + cos b − 2)², (sin a + sin b)². □

**Significance**: This sub-additivity means quantum errors compose at most linearly (with constant factor 2) rather than exponentially. For a circuit of depth d with per-gate infidelity at most ε, the total infidelity is at most 2d·ε.

---

## 6. EML Diagonal Dynamics

### 6.1 The Diagonal Map

**Definition 6.1**. The EML diagonal map is d(z) = exp(z) − log(z).

Note: In our formalization, Real.log extends to all of ℝ with log(−x) = log(x), so d(z) can be negative for very negative z (e.g., z = −100 gives exp(−100) − log(100) < 0).

**Theorem 6.1** (Growth Bound). d(z) ≥ z + 1 for all z ∈ ℝ.

*Proof*: For z > 0: use exp(z) ≥ z+1 and log(z) ≤ z−1.
For z ≤ 0: use the extended log identity and exp(z) ≥ z+1. □

**Theorem 6.2** (Orbital Linear Growth). After n iterations: dⁿ(z) ≥ z + n.

*Proof*: By induction on n using Theorem 6.1. □

**Theorem 6.3** (Positivity for z > 0). d(z) > 0 for z > 0.

*Proof*: d(z) ≥ z + 1 > 1 > 0 for z > 0. □

### 6.2 Quantum Interpretation

The diagonal iteration produces a sequence of quantum rotation angles that grow at least linearly. The quantum error at iteration n satisfies:

2(1 − cos(dⁿ(z))) ≤ (dⁿ(z))²

while dⁿ(z) ≥ z + n. This means the absolute quantum error (bounded by 4) becomes increasingly negligible compared to the EML value (growing linearly), giving a "quantum advantage ratio" that improves with depth.

---

## 7. Lipschitz Bounds

**Theorem 7.1** (Linear Error Bound). 2(1 − cos θ) ≤ 2|θ| for all θ.

*Proof*: cos is 1-Lipschitz, so |cos θ − 1| = |cos θ − cos 0| ≤ |θ|. □

**Theorem 7.2** (Phase Separation). |cos α − cos β| ≤ |α − β| for all α, β.

*Proof*: By the 1-Lipschitz property of cosine (Mathlib: `abs_cos_sub_cos_le`). □

These bounds ensure that small changes in EML inputs produce proportionally small changes in quantum phases.

---

## 8. Algorithms

### 8.1 Quantum Phase Compilation

```
Input: Target angle α
Output: EML parameters (x, y) with eml(x, y) = α

Algorithm:
  x ← 0
  y ← exp(1 − α)
  return (x, y)

Correctness: eml(0, exp(1−α)) = 1 − (1−α) = α
Complexity: O(1) — one exponential evaluation
```

### 8.2 Circuit Error Estimation

```
Input: Angles θ₁, ..., θₙ
Output: Upper bound on total quantum error

Algorithm:
  total_sq ← Σᵢ θᵢ²
  bound ← n · total_sq
  return bound

Correctness: 2(1−cos(Σθᵢ)) ≤ n·Σθᵢ² (Theorem 4.4)
```

---

## 9. Discussion and Future Work

### 9.1 SU(2) Extension

The present results concern U(1) rotations (single-qubit phase gates). The natural next step is extending to SU(2), where the EML function would map to 2×2 unitary matrices via matrix exponentials. The logarithmic factoring law should generalize to the Baker-Campbell-Hausdorff formula.

### 9.2 Tropical Optimization

The n-bound suggests that tropical linear programming (optimizing max-plus expressions) could directly optimize quantum circuit errors. The tropical semiring structure provides natural relaxations of the non-convex quantum optimization landscape.

### 9.3 Multi-Qubit Systems

For k-qubit systems with tensor product structure, the EML function on ℝ^(2^k) would parameterize SU(2^k) rotations. The Cauchy-Schwarz-based bounds should extend with dimension-dependent constants.

---

## 10. References

1. EML Core Theory: `Catalog/EML/Core.lean` — Basic EML properties, strict convexity, orbital dynamics
2. Tropical Quantum: `Catalog/Tropical/QuantumTropical.lean` — Tropical R-matrix, crystal character theory
3. Tropical Structure: `Catalog/Tropical/TropicalStructure.lean` — Max-plus semiring foundations
4. Quantum EML Core: `Tropical/QuantumEML/Core.lean` — This paper's main theorems
5. Tropical Bridge: `Tropical/QuantumEML/TropicalBridge.lean` — Cross-domain bridge theorems

---

## Appendix: Theorem Summary

| Theorem | Statement | File |
|---------|-----------|------|
| Gap Bound | 2(1−cos θ) ≤ θ² | Core.lean |
| Infidelity Bound | 𝒥(θ) ≤ θ²/2 | Core.lean |
| Log Factor | eml(x,y₁y₂) = eml(x,y₁)−log y₂ | Core.lean |
| Cancellation | eml(x,y)−eml(x,y') = log y'−log y | Core.lean |
| Surjectivity | ∀α, ∃(x,y), eml(x,y) = α | Core.lean |
| Sub-Additivity | 1−cos(a+b) ≤ 2(1−cos a)+2(1−cos b) | Core.lean |
| Two-Bridge | 2(1−cos(θ₁+θ₂)) ≤ 2(θ₁²+θ₂²) | Core.lean |
| Max Bound | max errors ≤ max squares | Core.lean |
| Diag Growth | d(z) ≥ z+1 | Core.lean |
| Orbit Growth | dⁿ(z) ≥ z+n | Core.lean |
| N-Bound | 2(1−cos(Σθᵢ)) ≤ n·Σθᵢ² | TropicalBridge.lean |
| Cos Lipschitz | |cos α − cos β| ≤ |α−β| | TropicalBridge.lean |
| Linear Bound | 2(1−cos θ) ≤ 2|θ| | TropicalBridge.lean |
| Triangle | 2(1−cos(a+b+c)) ≤ 3(a²+b²+c²) | TropicalBridge.lean |
| Universality | Any finite angle sequence realizable | TropicalBridge.lean |
