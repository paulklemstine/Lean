import Mathlib

/-! # CatalogBuild.Bridges.IdempotentTheory

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 10
-/

noncomputable section

/-- The complement of an idempotent is idempotent. -/
theorem idempotent_complement {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    (1 - e) * (1 - e) = 1 - e := by
  simp [sub_mul, mul_sub, he, sub_sub, sub_self]


/-- e·(1-e) = 0 for an idempotent. -/
theorem idempotent_orthogonal_right {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    e * (1 - e) = 0 := by
  rw [mul_sub, mul_one, he, sub_self]

/-- (1-e)·e = 0 for an idempotent. -/
theorem idempotent_orthogonal_left {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    (1 - e) * e = 0 := by
  rw [sub_mul, one_mul, he, sub_self]

/-- Complement is idempotent (using Mathlib's IsIdempotentElem). -/
theorem isIdempotentElem_complement {R : Type*} [Ring R] (e : R)
    (he : IsIdempotentElem e) : IsIdempotentElem (1 - e) := by
  rw [IsIdempotentElem] at he ⊢
  exact idempotent_complement e he

/-- A complete system of orthogonal idempotents. -/
structure OrthogonalIdempotentSystem (R : Type*) [Ring R] (k : ℕ) where
  idem : Fin k → R
  is_idempotent : ∀ i, idem i * idem i = idem i
  is_orthogonal : ∀ i j, i ≠ j → idem i * idem j = 0
  is_complete : ∑ i : Fin k, idem i = 1

/-- A diagonal matrix with {0,1} entries is idempotent. -/
theorem diagonal_01_idempotent {n : ℕ} (d : Fin n → ℝ) (hd : ∀ i, d i = 0 ∨ d i = 1) :
    (Matrix.diagonal d) * (Matrix.diagonal d) = Matrix.diagonal d := by
  rw [Matrix.diagonal_mul_diagonal]
  congr 1; ext i
  rcases hd i with h | h <;> simp [h]

/-- The trace of a {0,1}-diagonal matrix is non-negative. -/
theorem diagonal_01_trace_nonneg {n : ℕ} (d : Fin n → ℝ) (hd : ∀ i, d i = 0 ∨ d i = 1) :
    Matrix.trace (Matrix.diagonal d) ≥ 0 := by
  simp only [Matrix.trace, Matrix.diag_apply, Matrix.diagonal_apply_eq]
  apply Finset.sum_nonneg
  intro i _
  rcases hd i with h | h <;> simp [h]

/-- At δ=2, Temperley-Lieb generators become rescaled idempotents. -/
theorem temperley_lieb_at_delta2 (ei : ℝ) (h : ei * ei = 2 * ei) :
    (ei / 2) * (ei / 2) = ei / 2 := by
  field_simp; linarith

/-- [Section: # CatalogBuild.Bridges.IdempotentTheory
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 10] -/
theorem jones_wenzl_well_defined (n : ℕ) (hn : n > 0) :
    Real.cos (Real.pi / (↑n + 1)) > -1 := by
  rw [ gt_iff_lt, ← Real.cos_pi ];
  refine' Real.cos_lt_cos_of_nonneg_of_le_pi _ _ _ <;> nlinarith [ Real.pi_pos, show ( n : ℝ ) ≥ 1 by norm_cast, div_mul_cancel₀ Real.pi ( by positivity : ( n : ℝ ) + 1 ≠ 0 ) ]

/-- For any idempotent, tr(P²) = tr(P). -/
theorem idempotent_trace_eq {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) : Matrix.trace (P * P) = Matrix.trace P := by
  rw [hP]

/-- The sum of all idempotents acting on itself gives itself. -/
theorem complete_system_idempotent {R : Type*} [Ring R] {k : ℕ}
    (sys : OrthogonalIdempotentSystem R k) :
    (∑ i : Fin k, sys.idem i) * (∑ j : Fin k, sys.idem j) = ∑ i : Fin k, sys.idem i := by
  rw [sys.is_complete, one_mul]

end