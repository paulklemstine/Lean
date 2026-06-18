# Future Directions: Decomposable Verification Theory

## Overview

This document outlines breakthrough research opportunities opened by the formal theory of decomposable matrix verification. Each direction builds on the verified theorems in this project and targets concrete, provable extensions.

---

## Direction 1: Formal Sum-Check Protocol over Multilinear Polynomials

### Theorem Statement (Target)
```lean
theorem sum_check_soundness
  {F : Type*} [Field F] [Fintype F] [DecidableEq F]
  {n : ℕ}
  (p : MvPolynomial (Fin n) F)
  (hp_deg : ∀ i, p.degreeOf i ≤ 1)  -- multilinear
  (claimed_sum : F)
  (hne : ∑ x : Fin n → Fin 2, MvPolynomial.eval (fun i => (x i : F)) p ≠ claimed_sum) :
  -- The verifier detects the lie with probability ≥ 1 - n/|F|
  True := by trivial
```

### Why It Matters
The sum-check protocol (Lund et al., 1992) is the foundation of interactive proof systems, probabilistically checkable proofs (PCPs), and modern zero-knowledge systems. Our `nonzero_linear_form_zero_set_card` provides the base case (single variable, degree 1). Extending to multilinear polynomials would give the first formally verified sum-check.

### Required Mathlib Infrastructure
- `MvPolynomial` evaluation and degree API (exists)
- Schwartz-Zippel lemma for multilinear polynomials (partially exists in `Catalog/EML/PolynomialMethod/SchwartzZippel.lean`)
- Finite field counting for polynomial zero sets

### Estimated Difficulty
**High.** The inductive argument (reducing *n*-variable to (*n*−1)-variable via partial evaluation) requires careful handling of polynomial restriction and variable elimination. Estimated 2–3 weeks of focused effort.

### Builds On
- `nonzero_linear_form_zero_set_card` (this project)
- `freivalds_soundness_bound` (this project)

---

## Direction 2: Spectral Norm Witnesses and Tight Robustness Bounds

### Theorem Statement (Target)
```lean
theorem spectral_norm_witness
  {n : ℕ}
  (D : Matrix (Fin n) (Fin n) ℝ)
  (hD : D ≠ 0) :
  ∃ r : Fin n → ℝ, (∑ i, r i ^ 2 ≤ 1) ∧
    Real.sqrt n * ‖D.mulVec r‖ ≥ ‖D‖ := by
  sorry
```

### Why It Matters
Our current witness theorem uses ℓ^∞ bounds (|r_i| ≤ 1), which loses a factor of √n compared to the optimal ℓ² bound. A spectral norm witness would give tight bounds, connecting to singular value decomposition and enabling sharper certificates for neural network robustness.

### Required Mathlib Infrastructure
- Matrix operator norm (`Matrix.opNorm` or equivalent) — partially available
- Singular value decomposition — not yet in Mathlib
- Spectral theorem for symmetric matrices — partially available

### Estimated Difficulty
**Very high** without SVD infrastructure. **Medium** if spectral bounds can be obtained through operator norm API without explicit SVD. Could start with symmetric positive definite case where eigenvalue decomposition suffices.

### Builds On
- `operator_norm_witness_of_matrix_neq_zero` (this project)
- `tropical_mulVec_entrywise_bound` (this project)

---

## Direction 3: Tropical Polynomial Identity Testing

### Theorem Statement (Target)
```lean
theorem tropical_identity_test
  {n : ℕ}
  (f g : (Fin n → ℝ) → ℝ)
  (hf : TropicalPolynomial f) (hg : TropicalPolynomial g)
  (hne : f ≠ g) :
  ∃ x : Fin n → ℝ, (∀ i, |x i| ≤ 1) ∧ f x ≠ g x := by
  sorry
```

### Why It Matters
Tropical polynomials (max-plus expressions) are the piecewise-linear functions that arise in ReLU neural networks. Testing whether two tropical polynomials are identical is equivalent to testing whether two neural network layers compute the same function. A formal tropical identity testing theorem would directly support certified neural network equivalence checking.

### Required Mathlib Infrastructure
- Tropical polynomial formalization (basic definitions exist in project)
- Piecewise-linear function theory
- Tropical Nullstellensatz (deep; may need to be built from scratch)

### Estimated Difficulty
**High.** The structure of tropical zero sets is fundamentally different from classical polynomial zero sets — they are polyhedral complexes rather than algebraic varieties. However, the witness construction (standard basis probing) may still work via the max-plus structure.

### Builds On
- `tropical_mirror` (this project)
- `tropical_mulVec_entrywise_bound` (this project)
- `tropical_fundamental_theorem_of_arithmetic` (existing catalog)

---

## Direction 4: Sheaf Semantics for Matrix Verification

### Theorem Statement (Target)
```lean
/-- The presheaf of verification certificates is a sheaf for block covers. -/
theorem verification_sheaf_condition
  {R : Type*} [CommRing R]
  {n : Type*} [Fintype n] [DecidableEq n]
  (𝒰 : Finset (Finset n))  -- cover by index subsets
  (h_cover : ∀ i : n, ∃ U ∈ 𝒰, i ∈ U)
  (A B C : Matrix n n R)
  (h_local : ∀ U ∈ 𝒰, A.submatrix (· ∈ U) (· ∈ U) * B.submatrix ... = C.submatrix ...)
  (h_compat : ∀ U V ∈ 𝒰, compatible_on_overlap U V A B C) :
  A * B = C := by
  sorry
```

### Why It Matters
This would formalize the "verification is a sheaf" principle: global matrix identities can be certified by compatible local certificates. This is the abstract mathematical foundation for distributed verification, and connects linear algebra to algebraic geometry (descent theory) and algebraic topology (Čech cohomology).

### Required Mathlib Infrastructure
- `Matrix.submatrix` API (exists)
- Compatibility/cocycle conditions for matrix restrictions
- Finset cover machinery

### Estimated Difficulty
**Very high** in full generality (requires non-trivial overlap handling). **Medium** for the block-diagonal special case (already done in this project). The intermediate case of block-triangular matrices would be an excellent stepping stone.

### Builds On
- `block_diagonal_mul_eq_iff` (this project)
- `block_diagonal_failure_detection` (this project)

---

## Direction 5: Certified Verification for Transformer Architectures

### Theorem Statement (Target)
```lean
/-- Attention head verification: if each head's QKV matrices match,
    the multi-head attention output matches. -/
theorem multi_head_attention_certificate
  {n_heads n_dim : ℕ}
  (Q K V Q' K' V' : Fin n_heads → Matrix (Fin n_dim) (Fin n_dim) ℝ)
  (h_match : ∀ h, Q h = Q' h ∧ K h = K' h ∧ V h = V' h) :
  multi_head_attention Q K V = multi_head_attention Q' K' V' := by
  sorry
```

### Why It Matters
Transformer architectures dominate modern AI. Their multi-head attention mechanism is naturally block-structured: each attention head operates independently. Our block-diagonal gluing theorems directly apply: verifying each head independently suffices for global verification. Formalizing this would create the first machine-verified certification infrastructure for transformer models.

### Required Mathlib Infrastructure
- Softmax function formalization
- Matrix exponential / entry-wise operations
- Composition of certified layers

### Estimated Difficulty
**Medium** for the linear components (direct application of existing theorems). **High** for including softmax and the full attention mechanism (requires analysis of smooth nonlinear functions).

### Builds On
- `block_network_certificate` (this project)
- `certified_layer_detection` (this project)
- `tropical_robustness_margin` (this project)

---

## Research Roadmap

### Phase 1 (Immediate, 1–2 months)
- Sum-check base case formalization (Direction 1, restricted to degree-1)
- Block-triangular gluing (stepping stone to Direction 4)
- Spectral norm witness for diagonal matrices (stepping stone to Direction 2)

### Phase 2 (Medium-term, 3–6 months)
- Full multilinear sum-check protocol (Direction 1)
- Tropical polynomial identity testing for simple cases (Direction 3)
- Multi-head attention certificate for linear components (Direction 5)

### Phase 3 (Long-term, 6–12 months)
- Sheaf semantics for general covers (Direction 4)
- Spectral norm witnesses via SVD (Direction 2, requires Mathlib SVD)
- Full transformer verification pipeline (Direction 5)
- Connection to formal complexity theory (PCP theorem infrastructure)

---

## Cross-Domain Synthesis Opportunities

The most impactful results will emerge from combining directions:

1. **Sum-check + Block Structure**: Compositional interactive proofs where each block has its own sum-check verifier. This would give formally verified *interactive* block verification.

2. **Tropical + Spectral**: Combining tropical ℓ^∞ bounds with spectral ℓ² bounds would give a two-sided certificate: tropical bounds handle worst-case, spectral bounds handle average-case.

3. **Sheaf + Transformer**: Viewing attention heads as sections of a verification sheaf would enable a categorical treatment of multi-head attention certification.

4. **Freivalds + Neural Verification**: Running Freivalds-style probes on neural network layers as a fast pre-check before expensive formal verification. The soundness bound provides formal guarantees on the probe's reliability.

---

## Team Directive

Each direction should be pursued by a team that:
1. States the target theorem precisely in Lean 4
2. Identifies required Mathlib infrastructure (and builds what's missing)
3. Proves helper lemmas bottom-up
4. Validates the approach computationally (Python experiments)
5. Documents results for the next research cycle

The goal is to make each cycle's output the foundation for the next, creating a self-reinforcing loop of formal mathematical discovery.
