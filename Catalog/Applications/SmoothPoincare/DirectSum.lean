/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Orthogonal (connected-sum) direct sums of intersection forms

This file extends `IntersectionForms.lean` with the **orthogonal direct sum**
`Q ⊕ R` of intersection forms, the algebraic model of the connected sum `M # N`
of 4-manifolds (whose intersection form is the orthogonal sum of the summands').

We prove that the three structural predicates of the theory are *closed* under `⊕`:

* `directSum_unimodular` — unimodularity (Poincaré duality) is additive;
* `directSum_isEven`     — evenness (spin) is additive;
* `directSum_stdDiagonalizable` — the standard form `⟨1⟩ⁿ` is closed under `⊕`.

The headline application is the rank-`16` form `E8form ⊕ E8form`: it is even,
unimodular, and **not** standard-diagonalizable (`E8E8_not_stdDiagonalizable`).
This is the smallest even unimodular form of signature `16`; it clears Rokhlin's
`ℤ/16` signature hurdle yet still fails Donaldson's diagonalization, pinpointing
where the analytic and characteristic-class obstructions diverge.

Builds on: `SmoothPoincare.IntersectionForm` and `even_not_stdDiagonalizable`,
`isEven_of_even_diag`, `E8form`, `E8_even`, `E8_unimodular` from `IntersectionForms`.

-- !-- Lab Notebook -- !--
Hypothesis: the predicates `Unimodular`, `IsEven`, `StdDiagonalizable` should be
  monoidal under the orthogonal block-diagonal sum, so the `E8` obstruction is
  *stable* under connected sum with itself.
Result: all three closure theorems proved `sorry`-free, plus the sharp corollary
  `E8E8_not_stdDiagonalizable` for the rank-16 signature-16 form.
Insight: evenness is governed entirely by the *diagonal* (`isEven_of_even_diag`
  and its converse `even_diag_of_isEven`), so it is transparently additive; the
  obstruction `even_not_stdDiagonalizable` then transfers verbatim to any sum of
  even forms, giving the stable comparison E8 (fails Donaldson) vs E8⊕E8 (passes
  Rokhlin, still fails Donaldson).
Failure analysis: the `Fin (m+n)` vs `Fin m ⊕ Fin n` indexing requires reindexing
  through `finSumFinEquiv`; the clean route is `submatrix_mul_equiv` /
  `transpose_submatrix` / `submatrix_one_equiv`, avoiding any explicit index
  arithmetic.
-/

import Mathlib
import Applications.SmoothPoincare.IntersectionForms

open Matrix
open scoped BigOperators

noncomputable section

namespace SmoothPoincare

namespace IntersectionForm

variable {m n : ℕ}

/-- The reindexing equivalence `Fin m ⊕ Fin n ≃ Fin (m + n)`. -/
abbrev sumEquiv (m n : ℕ) : Fin m ⊕ Fin n ≃ Fin (m + n) := finSumFinEquiv

-- !-- The diagonal computes the quadratic value on a basis vector,
-- `Q.value (single i 1) = Q.gram i i`, so evenness forces each diagonal entry even. -- !--
/-- The converse of `isEven_of_even_diag`: an even form has even diagonal entries. -/
theorem even_diag_of_isEven {Q : IntersectionForm n} (hQ : Q.IsEven) (i : Fin n) :
    Even (Q.gram i i) := by
  have := hQ (fun j => if j = i then 1 else 0)
  simp_all +decide [IntersectionForm.value]
  simp_all +decide [Matrix.mulVec, dotProduct]

-- !-- `fromBlocks` of two symmetric blocks with zero off-diagonal is symmetric
-- (`fromBlocks_transpose`), and `reindex e e` preserves symmetry. -- !--
/-- The reindexed block-diagonal of two symmetric matrices is symmetric. -/
theorem reindex_fromBlocks_diag_isSymm {Q : IntersectionForm m} {R : IntersectionForm n} :
    (reindex (sumEquiv m n) (sumEquiv m n) (fromBlocks Q.gram 0 0 R.gram)).IsSymm := by
  simp_all +decide [Matrix.IsSymm, Matrix.reindex_apply]
  ext i j
  simp +decide [Matrix.fromBlocks_transpose]
  simp +decide [Q.isSymm.eq, R.isSymm.eq, sumEquiv]

/-- **Orthogonal direct sum** of intersection forms, the algebraic connected sum.
Its Gram matrix is the block-diagonal `diag(G_Q, G_R)` reindexed to `Fin (m+n)`. -/
def directSum (Q : IntersectionForm m) (R : IntersectionForm n) :
    IntersectionForm (m + n) where
  gram := reindex (sumEquiv m n) (sumEquiv m n) (fromBlocks Q.gram 0 0 R.gram)
  isSymm := reindex_fromBlocks_diag_isSymm

@[inherit_doc] infixl:65 " ⊕ᵢ " => directSum

-- !-- `det (reindex e e (fromBlocks G 0 0 H)) = det G · det H` by `det_reindex_self`
-- and `det_fromBlocks_zero₁₂`; a product of units is a unit. -- !--
/-- **Unimodularity is additive.** `Q ⊕ R` is unimodular when its blocks are. -/
theorem directSum_unimodular {Q : IntersectionForm m} {R : IntersectionForm n}
    (hQ : Q.Unimodular) (hR : R.Unimodular) : (Q ⊕ᵢ R).Unimodular := by
  unfold IntersectionForm.Unimodular at *
  unfold IntersectionForm.directSum
  rw [Matrix.det_reindex_self]
  aesop

-- !-- The diagonal of the block-diagonal sum consists of the diagonals of `Q` and
-- `R`, each even by `even_diag_of_isEven`; apply `isEven_of_even_diag`. -- !--
/-- **Evenness is additive.** The orthogonal sum of two even forms is even. -/
theorem directSum_isEven {Q : IntersectionForm m} {R : IntersectionForm n}
    (hQ : Q.IsEven) (hR : R.IsEven) : (Q ⊕ᵢ R).IsEven := by
  apply isEven_of_even_diag
  intro i
  simp [IntersectionForm.directSum]
  cases h : (sumEquiv m n).symm i <;> simp_all +decide [even_diag_of_isEven]

-- !-- With `T₁ᵀG_QT₁ = 1` and `T₂ᵀG_RT₂ = 1`, the block-diagonal `T = diag(T₁,T₂)`
-- gives `TᵀG T = reindex (fromBlocks 1 0 0 1) = 1` via `fromBlocks_multiply`,
-- `fromBlocks_transpose`, and `submatrix`/`reindex` lemmas. -- !--
/-- **The standard form is closed under `⊕`.** A sum of standard-diagonalizable
forms is standard-diagonalizable. -/
theorem directSum_stdDiagonalizable {Q : IntersectionForm m} {R : IntersectionForm n}
    (hQ : Q.StdDiagonalizable) (hR : R.StdDiagonalizable) :
    (Q ⊕ᵢ R).StdDiagonalizable := by
  obtain ⟨T₁, hT₁⟩ := hQ
  obtain ⟨T₂, hT₂⟩ := hR
  refine ⟨Matrix.reindex (sumEquiv m n) (sumEquiv m n) (Matrix.fromBlocks T₁ 0 0 T₂), ?_, ?_⟩
  · simp_all +decide [Matrix.reindex_apply]
  · unfold IntersectionForm.directSum
    simp +decide [Matrix.fromBlocks_transpose, Matrix.fromBlocks_multiply, hT₁.2, hT₂.2]

/-! ## The rank-16 form `E8 ⊕ E8` -/

/-- The orthogonal sum `E8 ⊕ E8`: even, unimodular, rank `16`, signature `16`. -/
def E8E8form : IntersectionForm (8 + 8) := E8form ⊕ᵢ E8form

/-- `E8 ⊕ E8` is even. -/
theorem E8E8_even : E8E8form.IsEven := directSum_isEven E8_even E8_even

/-- `E8 ⊕ E8` is unimodular. -/
theorem E8E8_unimodular : E8E8form.Unimodular :=
  directSum_unimodular E8_unimodular E8_unimodular

-- !-- `E8 ⊕ E8` is even of positive rank, so `even_not_stdDiagonalizable` applies:
-- adding an `E8` summand (to clear Rokhlin's signature-16 hurdle) does not remove
-- Donaldson's evenness obstruction. -- !--
/-- **Stable obstruction.** `E8 ⊕ E8` — the smallest even unimodular form clearing
Rokhlin's signature-`16` hurdle — is still not standard-diagonalizable, so it is not
the intersection form of any smooth closed simply-connected 4-manifold. -/
theorem E8E8_not_stdDiagonalizable : ¬ E8E8form.StdDiagonalizable :=
  even_not_stdDiagonalizable E8E8form (by norm_num) E8E8_even

end IntersectionForm

end SmoothPoincare