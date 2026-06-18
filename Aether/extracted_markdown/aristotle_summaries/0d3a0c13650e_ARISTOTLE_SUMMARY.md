# Summary of changes for run e798982f-7910-40a8-824f-a53bc3cd03ce
# Tropical Linear Algebra: Eigenvalues and Determinants

## Summary

Developed a formally verified theory of tropical (max-plus) linear algebra, proving 14 theorems with zero `sorry` statements. All proofs use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## Lean 4 Proofs (`Tropical/TropicalLinearAlgebra.lean`)

**Core Definitions:**
- `tropMul'` — Tropical (max-plus) matrix multiplication
- `tropPow'` — Tropical matrix power
- `tropDet` — Tropical determinant (max weight permutation)
- `tropTr` — Tropical trace (max diagonal entry)

**Key Theorems (all sorry-free):**

1. **`tropDet_superadditive`** — The tropical determinant is superadditive under tropical multiplication: `tdet(A ⊗ B) ≥ tdet(A) + tdet(B)`. This is the tropical shadow of `det(AB) = det(A)·det(B)`, but only an inequality. The gap measures the composability defect of optimal assignments.

2. **`tropMul'_assoc`** — Associativity of tropical matrix multiplication.

3. **`tropDet_transpose`** — The tropical determinant is invariant under transpose.

4. **`tropDet_conj_perm`** — Conjugation invariance: `tdet(PσAPσ⁻¹) = tdet(A)`.

5. **`tropDet_tropPow_lower`** — Power growth: `tdet(A^(m+1)) ≥ (m+1) · tdet(A)`.

6. **`tropMul'_max_left`** — Distributivity: `A ⊗ max(B₁,B₂) = max(A⊗B₁, A⊗B₂)`.

7. **`tropDet_add_scalar`** — Scalar shift: `tdet(A + cJ) = tdet(A) + (n+1)c`.

8. **`tropPow'_add`** — Power splitting: `A^(m+k+2) = A^(m+1) ⊗ A^(k+1)`.

9. **`tropPow'_diag_superadd`** — Diagonal superadditivity of powers.

10. **`tropDet_eq_optimal_assignment`** — Bridge theorem: tropical determinant = optimal assignment weight (connects to Hungarian algorithm).

11. **`tropDet_2x2`** — Explicit 2×2 formula: `tdet([[a,b],[c,d]]) = max(a+d, b+c)`.

12. **`tropDet_le_mul_tropTr`** — Trace-determinant bound for dominated matrices.

Also proved: `tropDet_ge_trace_sum`, `tropDet_eq_tropPerm` (tropical det = tropical permanent).

**Discovery:** The conjecture `tropTr(A) ≤ tropDet(A)` is FALSE (counterexample: A = [[-1,-1],[-1,-1]] gives tropTr = -1 > tropDet = -2). This was formally disproved during the research.

## Deliverables

- **`Tropical/TropicalLinearAlgebra.lean`** — All Lean 4 proofs (0 sorry, builds cleanly)
- **`Tropical/ARTICLE.md`** — Popular science article (~2500 words)
- **`Tropical/RESEARCH_PAPER.md`** — Research paper with PEGB analysis for main theorems
- **`Tropical/FUTURE_DIRECTIONS.md`** — 5 research directions including Tropical Cayley-Hamilton (grand challenge) and superadditivity equality characterization
- **`Tropical/demo.py`** — 6 numerical demonstrations
- **`Tropical/algorithms.py`** — Type-hinted implementations including Hungarian algorithm
- **`Tropical/visualize_convergence.py`** — Matplotlib visualization
- **`Tropical/PACKAGE.json`** — Bundle with 2 interactive HTML demos (Tropical Matrix Calculator, Perron-Frobenius Convergence Explorer)

## Building on Catalog

This work deepens the tropical Perron-Frobenius theorem from `Catalog/Tropical/PerronFrobenius.lean` by connecting spectral convergence to determinant theory. The superadditivity theorem bridges tropical algebra with combinatorial optimization (optimal assignment problem).