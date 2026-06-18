# Summary of changes for run dcaadf29-cda8-4832-b4e4-fe10fbc7669a
# Tropical Linear Algebra: Eigenvalues and Determinants — Research Cycle Complete

## Summary

This research cycle developed a rigorous, formally verified theory of tropical (max-plus) determinants, introduced a novel algebraic structure (the **signed tropical determinant**), and established connections to tropical eigenvalues through the **tropical spectral polytope**.

## Lean 4 Proofs (27 theorems, 0 sorries, 481 lines across 3 files)

### `Tropical/EigenDet/Defs.lean` — Core Definitions and Properties (13 theorems)
- **`tropDet`**: Tropical determinant as max-weight perfect matching
- **`tropSDet`** (novel): Max weight over even permutations only
- **`tropAntiDet`** (novel): Max weight over odd permutations only
- **`tropSignGap`** (novel): Parity bias of optimal assignment
- **`tropDet_transpose`**: tropDet(Aᵀ) = tropDet(A)
- **`tropDet_add_const`**: Adding constant c shifts tropDet by n·c
- **`tropCauchyBinet`**: tropDet(A⊗B) ≥ tropDet(A) + tropDet(B) — the fundamental inequality
- **`tropDet_eq_max_sdet_adet`**: tropDet = max(tropSDet, tropAntiDet) — signed decomposition
- **`tropDet_diag_dominant`**: Diagonal-dominant matrices have tropDet = trace
- **`tropSignGap_diag_dominant`**: Sign gap ≥ 0 for diagonal-dominant matrices

### `Tropical/EigenDet/CauchyBinet.lean` — Iterated Bounds (7 theorems)
- **`tropDet_pow_ge`**: tropDet(A^k) ≥ (k+1)·tropDet(A) — linear growth
- **`tropDet_le_row_max_sum`**: tropDet ≤ sum of row maxima
- **`tropDet_mono`**: Entrywise monotonicity
- **`tropSDet_le_tropDet`**, **`tropAntiDet_le_tropDet`**: Subset bounds
- **`tropDet_sandwich`**: Trace ≤ tropDet ≤ sum of row maxima

### `Tropical/EigenDet/Spectral.lean` — Spectral Theory (7 theorems)
- **`tropMul_assoc`**: Associativity of tropical multiplication
- **`tropDet_pow_superadd`**: Superadditivity of power determinants
- **`TropSpectralPolytope`** (novel): {v : A_{ij} + v_j ≤ v_i + λ} — the tropical eigenspace
- **`spectralPolytope_isClosed`**: The polytope is topologically closed
- **`spectralPolytope_mono`**: Monotone in λ
- **`tropDet_le_of_spectralPolytope_nonempty`**: P(A,λ) nonempty ⟹ tropDet(A) ≤ nλ — the key spectral bound

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

## Novel Mathematical Structures
1. **Signed Tropical Determinant (tropSDet)**: Restricts the assignment problem to even permutations, creating a parity-sensitive tropical invariant
2. **Tropical Sign Gap**: Measures whether optimal matchings are even or odd — exhibits phase transitions under perturbation
3. **Tropical Spectral Polytope**: Polyhedron characterizing tropical sub-eigenvectors, bridging determinants to eigenvalues

## Deliverables
- **`ARTICLE.md`**: 1500+ word popular science article on tropical algebra (no mention of formal verification)
- **`RESEARCH_PAPER.md`**: 3000+ word research paper with definitions, theorems, proof sketches
- **`FUTURE_DIRECTIONS.md`**: 5 research directions with conjectures, tests, and proof strategies
- **`demo.py`**: 7 interactive demonstrations of tropical algebra
- **`algorithms.py`**: Type-hinted implementations including Hungarian algorithm and Karp's maximum cycle mean
- **`viz_sign_gap.py`**: Phase diagram visualization of sign gap
- **`PACKAGE.json`**: Complete package with 3 interactive HTML demos (Tropical Matrix Calculator, Perron-Frobenius Convergence, Sign Gap Explorer)