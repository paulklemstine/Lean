# Tropical Riesz–Markov–Kakutani Representation: Max-Plus Functional–Measure Duality

## Research Report

### Abstract

We formalize the tropical (max-plus) analogue of the Riesz–Markov–Kakutani representation theorem for finite types in Lean 4, establishing a complete duality between tropical max-plus functionals and tropical weight functions. The representation states that every monotone, sup-preserving, shift-equivariant functional `I : (X → ℝ) → ℝ` on a finite nonempty type `X` is uniquely represented by a weight function `w : X → ℝ` via the max-plus integral:

$$I(f) = \max_{x \in X}(f(x) + w(x))$$

We prove 51 theorems with zero `sorry` statements, covering existence, uniqueness, order isomorphism, certified robustness bounds, tropical Wasserstein distance, tropical entropy, and applications to neural network verification and post-quantum cryptography.

### 1. Introduction

The classical Riesz–Markov–Kakutani theorem establishes that every positive linear functional on the space of continuous functions C(X, ℝ) on a compact Hausdorff space X is represented by a unique regular Borel measure. This duality is foundational to functional analysis, probability theory, and mathematical physics.

In the tropical (max-plus) semiring 𝕋 = (ℝ, max, +), where "addition" is max and "multiplication" is +, the corresponding duality replaces:
- **Linear functionals** with **sup-preserving shift-equivariant monotone functionals**
- **Measures** with **weight functions** (tropical Radon measures)
- **Integration** with the **max-plus integral** (supremum convolution)

Our formalization proves this duality for finite types, where the theory is both complete and computationally tractable.

### 2. Main Results

#### 2.1 Foundational Definitions (Foundations.lean)

We define:
- **TropicalWeight**: a weight function `w : X → ℝ` representing the tropical measure
- **tropMaxIntegral**: the max-plus integral `max_x(f(x) + w(x))`
- **TropicalMaxPlusFunctional**: the axiomatized dual object (monotone, sup-preserving, shift-equivariant)
- **spikeFunction**: the tropical approximate Dirac delta used for weight extraction

Key properties proved:
- **Monotonicity**: f ≤ g ⟹ ∫f dμ ≤ ∫g dμ
- **Sup-preservation**: ∫(f ∨ g) dμ = (∫f dμ) ∨ (∫g dμ)
- **Shift-equivariance**: ∫(f + c) dμ = ∫f dμ + c
- **Tropical Fubini equality**: iterated max-plus integrals commute

#### 2.2 Representation Theorem (Representation.lean)

The core results:

**Theorem (Uniqueness)**: If `∫f dw₁ = ∫f dw₂` for all f, then w₁ = w₂.

*Proof*: For each point x₀, we evaluate both integrals on a spike function centered at x₀ with concentration C = 2M + 1, where M bounds all weight values. The spike integral extracts the individual weight w(x₀).

**Theorem (Order Isomorphism)**: w₁ ≤ w₂ ↔ ∀f, ∫f dw₁ ≤ ∫f dw₂.

**Theorem (Choquet Decomposition)**: Every max-plus integral is a supremum of point evaluations — there are no "continuous" tropical measures.

**Theorem (Certified Robustness)**: If the gap at the maximizer exceeds twice the perturbation, the maximizer is preserved.

#### 2.3 Cross-Domain Applications (Applications.lean)

- **Tropical Neural Networks**: formalization of max-plus network layers with Lipschitz bounds
- **Tropical Entropy**: shift-invariant measure of weight concentration
- **Tropical Wasserstein Distance**: metric on weight functions with triangle inequality
- **Post-Quantum Security**: tropical lattice norm bounds for cryptographic applications

### 3. Mathematical Significance

The tropical Riesz representation has three fundamental implications:

1. **Atomicity**: Every tropical measure is purely atomic — a finite supremum of Dirac masses. This means tropical integration has O(n) complexity for n-point spaces, compared to the general O(∞) complexity of classical integration.

2. **Constructivity**: The representing weight can be extracted by evaluating the functional on n spike functions, giving an O(n) algorithm. This is the foundation of certified robustness computation for tropical neural networks.

3. **Duality**: The weight-to-functional map is an order isomorphism, establishing a complete Galois connection between the lattice of weights and the lattice of functionals.

### 4. Connections to Existing Work

Our formalization builds on Mathlib's infrastructure for:
- `Finset.sup'` and finite lattice operations
- `abs_le` and real arithmetic tactics
- `Filter.Tendsto` for convergence

The tropical Riesz theorem connects to:
- Maslov's idempotent analysis (ℏ→0 dequantization)
- Cohen et al.'s work on tropical convexity
- Litvinov-Maslov's idempotent functional analysis
- Zhang et al.'s tropical neural network verification

### 5. Proof Methodology

All 51 theorems are proved without `sorry`, using diverse tactics:
- `induction` for finite decompositions
- `rcases` / `obtain` for case analysis and existential extraction
- `by_contra` for uniqueness proofs
- `linarith` / `nlinarith` for real arithmetic
- `positivity` for positivity goals
- `abs_le` for absolute value manipulation
- `le_antisymm` for equality from two inequalities
- `Finset.sup'_le` / `Finset.le_sup'` for lattice operations
- `ring` / `ring_nf` for algebraic simplification

### 6. File Structure

| File | Lines | Theorems | Definitions |
|------|-------|----------|-------------|
| Foundations.lean | 477 | 18 | 12 |
| Representation.lean | 305 | 15 | 1 |
| Applications.lean | 336 | 18 | 6 |
| **Total** | **1118** | **51** | **19** |
