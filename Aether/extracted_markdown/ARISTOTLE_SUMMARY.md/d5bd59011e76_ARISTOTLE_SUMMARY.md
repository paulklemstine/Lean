# Summary of changes for run 031835bf-6853-4e2b-acb4-ffc11a982bbc
## Hadamard Matrix Spectral Theory — New Lean 4 Proofs

Created `Catalog/Algebra/Hadamard/Spectral.lean` containing **7 fully proved theorems** (zero `sorry`) extending the existing Hadamard matrix formalization with spectral and algebraic properties:

### Theorems Proved

1. **`isHadamardS_neg`** — Negation preserves the Hadamard property: if H is Hadamard, then -H is Hadamard.

2. **`isHadamardS_det_sq`** — **Determinant identity**: det(H)² = n^n for any n×n Hadamard matrix H. This is the equality case of Hadamard's maximal determinant bound — the central spectral result.

3. **`isHadamardS_transpose_mul`** — **Column orthogonality**: HᵀH = nI. This is proved via an invertibility argument over ℚ, lifting the row orthogonality HHᵀ = nI to column orthogonality by showing H is invertible when n > 0 (with the n = 0 case handled trivially).

4. **`isHadamardS_inverse_formula`** — **Inverse formula**: H · ((1/n) · Hᵀ) = I for Hadamard matrices over ℚ, giving the explicit inverse.

5. **`isHadamardS_det_ne_zero`** — Hadamard matrices are invertible when n > 0, via det(H)² = n^n > 0.

6. **`isHadamardS_trace`** — The trace of the Gram matrix: tr(HHᵀ) = n².

7. **`isHadamardS_gram_idempotent`** — The Gram matrix G = HHᵀ satisfies G² = n·G (scaled idempotence), characterizing the spectral structure.

### Key Mathematical Insights

- The determinant identity det(H)² = n^n is the algebraic heart: it connects Hadamard matrices to the extremal case of Hadamard's determinant bound and immediately implies invertibility.
- Column orthogonality (HᵀH = nI) requires going through ℚ to use matrix inverses, since ℤ-matrices aren't generally invertible. The proof lifts the ℤ-orthogonality to ℚ, applies invertibility, and casts back.

### Files

- `Catalog/Algebra/Hadamard/Spectral.lean` — 7 theorems, 0 sorry, all axioms clean (propext, Classical.choice, Quot.sound only)
- `FUTURE_DIRECTIONS.md` — 5 research directions: Paley construction, maximal determinant bound converse, equivalence classification, BIBD bridge completion, and Williamson construction