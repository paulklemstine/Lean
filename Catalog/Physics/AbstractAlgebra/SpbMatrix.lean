-- Repaired copy: this module was a stale, non-compiling duplicate of `Shared.AbstractAlgebra.SpbMatrix`.
-- Its content is synchronised with that (compiling) module.
import Mathlib

open Matrix

/-! # CatalogBuild.Shared.SpbMatrix

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8
-/

noncomputable section

/-- The SPB matrix: M(a) = [[1, a], [-a, 1]]. -/
def spbMatrix (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![1, a; -a, 1]

/-- The determinant of the SPB matrix is 1 + a². -/
theorem spbMatrix_det (a : ℝ) : (spbMatrix a).det = 1 + a ^ 2 := by
  simp [spbMatrix, det_fin_two]; ring

/-- The SPB matrix determinant is always positive. -/
theorem spbMatrix_det_pos (a : ℝ) : (spbMatrix a).det > 0 := by
  rw [spbMatrix_det]; positivity

/-- [Section: # CatalogBuild.Shared.SpbMatrix
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 8] -/
theorem spbMatrix_mul_eq_scaled (a b : ℝ) (h : 1 - a * b ≠ 0) :
    spbMatrix a * spbMatrix b = (1 - a * b) • spbMatrix ((a + b) / (1 - a * b)) := by
  unfold spbMatrix;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ div_eq_inv_mul, Matrix.mul_apply ] <;> ring_nf;
  · grind;
  · grind +revert

/-- The SPB matrix product, entry by entry:
M(a) * M(b) = [[1-ab, a+b], [-(a+b), 1-ab]]. -/
theorem spbMatrix_mul_entries (a b : ℝ) :
    spbMatrix a * spbMatrix b =
    !![1 - a * b, a + b; -(a + b), 1 - a * b] := by
  ext i j; simp [spbMatrix, mul_apply, Fin.sum_univ_two]
  fin_cases i <;> fin_cases j <;> simp <;> ring

/-- The SPB matrix is always invertible. -/
theorem spbMatrix_det_ne_zero (a : ℝ) : (spbMatrix a).det ≠ 0 := by
  linarith [spbMatrix_det_pos a]

/-- M(0) is the identity matrix. -/
theorem spbMatrix_zero : spbMatrix 0 = 1 := by
  simp [spbMatrix]; ext i j; fin_cases i <;> fin_cases j <;> simp

/-- det of the product = product of dets. -/
theorem spbMatrix_det_mul (a b : ℝ) :
    (spbMatrix a * spbMatrix b).det = (1 + a ^ 2) * (1 + b ^ 2) := by
  rw [det_mul, spbMatrix_det, spbMatrix_det]

end