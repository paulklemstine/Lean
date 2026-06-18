# Orbit Shadowing Foundations: Structural Stability, Amplification Factors, and Trajectory Interpolation

## Abstract

We develop a comprehensive formal theory of orbit shadowing for contractive dynamical systems on metric spaces, extending the classical contractive shadowing lemma in three directions. First, we prove a **structural stability theorem** showing that shadowing persists under uniform perturbation of the dynamics, with the model error and numerical error contributing additively to the shadowing radius: (δ+ε)/(1−L). Second, we introduce the **shadowing amplification factor** A(L,n) = Σᵢ₌₀ⁿ⁻¹ Lⁱ and prove its monotonicity, convergence to 1/(1−L), and connection to the **shadowing gap** — the exponentially decaying difference between finite-time and asymptotic error bounds. Third, we prove an **orbit interpolation lemma** showing that convex combinations of pseudo-orbits in normed spaces remain pseudo-orbits with controlled error inflation δ + L·D, enabling certified trajectory blending. All results are formalized in Lean 4 with complete machine-checked proofs using the Mathlib library.

**Keywords**: orbit shadowing, pseudo-orbit, contraction mapping, structural stability, dynamical systems, formal verification, amplification factor

## 1. Introduction

### 1.1 Background

Orbit shadowing is a fundamental concept in the theory of dynamical systems, providing a rigorous bridge between approximate (numerical) and exact trajectories. The shadowing lemma, in its various forms, asserts that pseudo-orbits — sequences where each point is approximately mapped to the next — can be tracked by genuine orbits within controllable error bounds.

The classical result for contractive maps states: if f : α → α is L-Lipschitz with L < 1 (a contraction), then every δ-pseudo-orbit is shadowed by a true orbit within distance δ/(1−L). This geometric series bound captures the essential interaction between per-step error (δ) and error amplification (1/(1−L)).

### 1.2 Contributions

This work makes three contributions:

1. **Structural stability of shadowing** (Theorem 3.1): We prove that if g is ε-close to a contraction f uniformly, then δ-pseudo-orbits of g are shadowed by true orbits of f with radius (δ+ε)/(1−L). This factorizes the total error into additive components from model perturbation and numerical approximation.

2. **Shadowing amplification theory** (Section 5): We formalize the amplification factor A(L,n) = (1−Lⁿ)/(1−L), prove its monotone convergence to 1/(1−L), establish the recurrence A(n+1) = 1 + L·A(n), and show the shadowing gap δ·Lⁿ/(1−L) decays exponentially to zero.

3. **Orbit interpolation** (Theorem 6.1): In normed spaces, the convex combination of two δ-pseudo-orbits with separation D is a (δ+L·D)-pseudo-orbit. This enables certified blending of ensemble trajectories with explicit error bounds.

### 1.3 Formalization

All theorems are formalized in Lean 4 using the Mathlib library, providing the highest level of mathematical certainty. The formalization uses Mathlib's `PseudoMetricSpace`, `LipschitzWith`, `NNReal`, and `NormedSpace` infrastructure.

## 2. Definitions

### 2.1 Pseudo-orbits

**Definition 2.1** (Pseudo-orbit). Let (α, d) be a pseudo-metric space and f : α → α. A sequence x : ℕ → α is a **δ-pseudo-orbit** of f if

  ∀ n ∈ ℕ, d(f(xₙ), xₙ₊₁) ≤ δ.

### 2.2 Shadowing

**Definition 2.2** (Shadows). A sequence y : ℕ → α **ε-shadows** a sequence x : ℕ → α with respect to f if:
- y is a true orbit: y(n+1) = f(y(n)) for all n, and
- y stays ε-close: d(y(n), x(n)) ≤ ε for all n.

### 2.3 Uniform closeness

**Definition 2.3** (Uniformly close). Two maps f, g : α → α are **ε-close uniformly** if

  ∀ x ∈ α, d(f(x), g(x)) ≤ ε.

### 2.4 Amplification factor

**Definition 2.4** (Amplification factor). The **amplification factor** of rate L ∈ ℝ at step n ∈ ℕ is

  A(L, n) = Σᵢ₌₀ⁿ⁻¹ Lⁱ.

### 2.5 Shadowing gap

**Definition 2.5** (Shadowing gap). The **shadowing gap** at step n with per-step error δ and contraction rate L is

  G(δ, L, n) = δ/(1−L) − δ·(1−Lⁿ)/(1−L) = δ·Lⁿ/(1−L).

### 2.6 Sequence interpolation

**Definition 2.6** (Convex interpolation). For sequences x, y : ℕ → E in a module over ℝ, the **t-interpolation** (t ∈ [0,1]) is

  z(n) = (1−t)·x(n) + t·y(n).

### 2.7 Eventually contractive maps

**Definition 2.7**. A map f is **eventually contractive** if there exist N ∈ ℕ₊ and Λ ∈ [0,1) such that f^N is Λ-Lipschitz.

## 3. Structural Stability

### 3.1 Perturbation transfer lemma

**Lemma 3.1** (Pseudo-orbit transfer). If g is ε-close to f uniformly and x is a δ-pseudo-orbit of g, then x is a (δ+ε)-pseudo-orbit of f.

*Proof sketch.* By the triangle inequality:

  d(f(xₙ), xₙ₊₁) ≤ d(f(xₙ), g(xₙ)) + d(g(xₙ), xₙ₊₁) ≤ ε + δ. □

**Theorem 3.1** (Structural stability of shadowing). Let f be L-Lipschitz with L < 1, and let g be ε-close to f uniformly. Then every δ-pseudo-orbit of g is shadowed by a true orbit of f with radius (δ+ε)/(1−L).

*Proof sketch.* By Lemma 3.1, a δ-pseudo-orbit of g is a (δ+ε)-pseudo-orbit of f. The shadowing true orbit y is defined by y(0) = x(0), y(n+1) = f(y(n)). By induction, using the Lipschitz bound and pseudo-orbit property:

  d(y(n+1), x(n+1)) ≤ L·d(y(n), x(n)) + (δ+ε)

which gives d(y(n), x(n)) ≤ (δ+ε)/(1−L) by the standard contraction accumulation argument. □

### 3.2 Significance

This theorem quantifies the degradation of shadowing under model perturbation. In applications:
- **Scientific computing**: ε represents model error (simplified equations), δ represents solver error
- **Machine learning**: ε represents distribution shift, δ represents stochastic gradient noise
- **Control theory**: ε represents plant-model mismatch, δ represents sensor noise

## 4. Finite-Time Shadowing Bounds

**Theorem 4.1** (Finite-time bound). Under the conditions of the contractive shadowing lemma,

  d(orbit(n), x(n)) ≤ δ·(1−Lⁿ)/(1−L).

**Theorem 4.2** (Bound comparison). For all n ∈ ℕ,

  δ·(1−Lⁿ)/(1−L) ≤ δ/(1−L).

*Proof sketch.* The difference is δ·Lⁿ/(1−L) ≥ 0 since L ∈ [0,1) and δ ≥ 0. □

The finite-time bound is strictly tighter for all finite n, converging to the asymptotic bound as n → ∞. For practical computation with finite horizon T, using the finite-time bound can reduce the certified error by a factor of 1 − L^T, which for L = 0.9 and T = 100 is a reduction of 1 − 0.9¹⁰⁰ ≈ 0.99997.

## 5. Amplification Factor Theory

### 5.1 Basic properties

**Theorem 5.1** (Monotonicity). A(L, ·) is monotonically non-decreasing for L ≥ 0.

**Theorem 5.2** (Recurrence). A(L, n+1) = 1 + L·A(L, n).

*Proof.* Direct from the definition:

  A(L, n+1) = 1 + L + L² + ··· + Lⁿ = 1 + L·(1 + L + ··· + Lⁿ⁻¹) = 1 + L·A(L, n). □

**Theorem 5.3** (Closed form). For L ≠ 1, A(L, n) = (1 − Lⁿ)/(1 − L).

### 5.2 Convergence

**Theorem 5.4** (Convergence). For L ∈ [0,1), A(L, n) → 1/(1−L) as n → ∞.

**Theorem 5.5** (Uniform bound). For L ∈ [0,1) and all n, A(L, n) ≤ 1/(1−L).

### 5.3 Shadowing gap dynamics

**Theorem 5.6** (Gap formula). G(δ, L, n) = δ·Lⁿ/(1−L).

**Theorem 5.7** (Gap non-negativity). G(δ, L, n) ≥ 0 for δ ≥ 0 and L ∈ [0,1).

**Theorem 5.8** (Gap convergence). G(δ, L, n) → 0 as n → ∞.

The shadowing gap has a clear dynamical interpretation: it represents the "unused error budget" at step n. As computation proceeds, the system's contraction progressively absorbs accumulated errors, and the remaining budget decays at rate L per step.

## 6. Orbit Interpolation

**Theorem 6.1** (Orbit interpolation). Let E be a normed space, f : E → E be L-Lipschitz, and x, y be δ-pseudo-orbits of f with d(x(n), y(n)) ≤ D for all n. Then for any t ∈ [0,1], the interpolation z(n) = (1−t)·x(n) + t·y(n) is a (δ + L·D)-pseudo-orbit.

*Proof sketch.* Decompose the error at step n using the intermediate point (1−t)·f(x(n)) + t·f(y(n)):

1. **Convexity defect**: d(f(z(n)), (1−t)f(x(n)) + tf(y(n))) ≤ L·D, using the Lipschitz property and the fact that z(n) is a convex combination of x(n) and y(n), so d(z(n), x(n)) = t·d(x(n), y(n)) and d(z(n), y(n)) = (1−t)·d(x(n), y(n)).

2. **Pseudo-orbit error**: d((1−t)f(x(n)) + tf(y(n)), z(n+1)) ≤ (1−t)·d(f(x(n)), x(n+1)) + t·d(f(y(n)), y(n+1)) ≤ δ, using the convex combination structure and the pseudo-orbit bounds.

Adding: d(f(z(n)), z(n+1)) ≤ L·D + δ. □

### 6.1 Applications

**Ensemble forecasting**: When multiple simulations produce different pseudo-orbits, their blend is a valid pseudo-orbit with controlled additional error L·D proportional to the ensemble spread.

**Sensitivity analysis**: The interpolation lemma enables continuous deformation between trajectories, useful for studying how solutions vary with parameters.

## 7. Eventually Contractive Maps

### 7.1 Definition and structure

An eventually contractive map f is one where f^N is a contraction for some N ≥ 1, even though f itself may expand. Such maps arise naturally in:
- Delay differential equations discretized at intervals shorter than the contraction timescale
- Markov chains with transient expansion phases
- Neural network training dynamics with periodic learning rate schedules

### 7.2 Conjectured shadowing bound

**Conjecture 7.1** (Sharp amplification for eventually contractive maps). If f has Lipschitz constant L and f^N has Lipschitz constant Λ < 1, then the optimal shadowing radius for δ-pseudo-orbits is:

  R* = δ · A(L, N) / (1 − Λ)

where A(L, N) = Σᵢ₌₀ᴺ⁻¹ Lⁱ is the per-block amplification.

**Testable prediction**: For L=2, N=3, Λ=0.5, δ=0.1: R* = 0.1 · 7 / 0.5 = 1.4. Constructing such maps numerically and computing the achieved shadowing distance would test this.

## 8. Discussion

### 8.1 Relation to prior work

The structural stability theorem extends the classical contractive shadowing lemma (Pilyugin, 1999) by incorporating model perturbation. While the idea that shadowing is stable under perturbation is well-known in the hyperbolic setting (Anosov, 1967; Bowen, 1975), our result provides explicit quantitative bounds in the contractive setting that are directly applicable to computation.

The amplification factor theory provides a unified framework for understanding both finite-time and asymptotic shadowing bounds. The shadowing gap concept, while elementary, does not appear to have been formalized previously.

The orbit interpolation lemma appears to be new in this generality. It extends results on convex combinations of fixed points to the orbit setting, using the normed space structure critically.

### 8.2 Limitations

Our results are restricted to contractive dynamics (L < 1). The much harder case of hyperbolic dynamics — where some directions expand and others contract — requires stable/unstable manifold theory and is the subject of the Anosov-Bowen shadowing lemma, which remains unformalized.

The interpolation lemma requires a normed space structure, precluding direct application to dynamics on manifolds or other curved spaces.

### 8.3 Connections to optimization

The structural stability theorem has direct implications for stochastic gradient descent (SGD). Viewing SGD as a pseudo-orbit of the gradient flow, and the noise as a perturbation of the dynamics, the theorem bounds the tracking error:

  tracking error ≤ (learning_rate · gradient_error + noise_amplitude) / (1 − contraction_rate)

This provides non-asymptotic, deterministic bounds complementing the probabilistic analyses common in optimization theory.

## 9. Conclusion

We have established a formal foundation for orbit shadowing in contractive dynamical systems, proving structural stability, finite-time bounds, amplification factor convergence, and orbit interpolation. All results are machine-verified in Lean 4. The eventually contractive conjecture provides a concrete target for future work.

## References

1. Anosov, D. V. (1967). Geodesic flows on closed Riemannian manifolds of negative curvature. *Trudy Mat. Inst. Steklov.*
2. Bowen, R. (1975). ω-limit sets for Axiom A diffeomorphisms. *J. Differential Equations.*
3. Pilyugin, S. Yu. (1999). *Shadowing in Dynamical Systems*. Lecture Notes in Mathematics 1706, Springer.
4. Palmer, K. (2000). *Shadowing in Dynamical Systems: Theory and Applications*. Kluwer.
5. The Mathlib Community (2024). Mathlib: the Lean 4 mathematics library. https://github.com/leanprover-community/mathlib4
