import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities
open Matrix

/-- The SPB rotation-type matrix `M(a) = !![1, a; -a, 1]`.
(The definition was missing from the catalogue; it is reconstructed here from the
statements below — trace `2`, determinant `1 + a²`, transpose `M(-a)`, `M(0) = 1`.) -/
def spbM (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![1, a; -a, 1]

open SPBResearch

/-! # CatalogBuild.Bridges.SPBBridge.MatrixTheory

Auto-generated from theorem catalog database.
Domain: Bridges/SPBBridge
Declarations: 13
-/

noncomputable section

/-- Trace of M(a) is 2. -/
theorem spbM_trace (a : ℝ) : (spbM a).trace = 2 := by
  simp [spbM, Matrix.trace, Fin.sum_univ_two]; norm_num

/-- Determinant of M(a) is 1 + a². -/
theorem spbM_det (a : ℝ) : (spbM a).det = 1 + a ^ 2 := by
  simp [spbM, Matrix.det_fin_two]; ring

/-- Determinant of M(a) is positive. -/
theorem spbM_det_pos (a : ℝ) : 0 < (spbM a).det := by
  rw [spbM_det]; positivity

/-- M(a)ᵀ = M(-a). -/
theorem spbM_transpose (a : ℝ) : (spbM a)ᵀ = spbM (-a) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbM, Matrix.transpose_apply]

/-- M(0) is the identity matrix. -/
theorem spbM_zero : spbM 0 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbM, Matrix.one_apply]

/-- Product of SPB matrices. -/
theorem spbM_mul (a b : ℝ) :
    spbM a * spbM b = !![1 - a*b, a + b; -(a + b), 1 - a*b] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbM, Matrix.mul_apply, Fin.sum_univ_two] <;> ring

/-- Determinant of the product: det(M(a)·M(b)) = (1+a²)(1+b²). -/
theorem spbM_det_mul (a b : ℝ) : (spbM a * spbM b).det = (1 + a ^ 2) * (1 + b ^ 2) := by
  rw [Matrix.det_mul, spbM_det, spbM_det]

/-- Trace of the product: tr(M(a)·M(b)) = 2(1 - ab). -/
theorem spbM_mul_trace (a b : ℝ) : (spbM a * spbM b).trace = 2 * (1 - a * b) := by
  rw [spbM_mul]; simp [Matrix.trace, Fin.sum_univ_two]; ring

/-- The product matrix recovers SPB via entry ratio (0,1)/(0,0) when 1-ab ≠ 0. -/
theorem spbM_recovers_spb (a b : ℝ) (h : 1 - a * b ≠ 0) :
    (spbM a * spbM b) 0 1 / (spbM a * spbM b) 0 0 = spb a b := by
  rw [spbM_mul]; simp; unfold spb; rfl

/-- M(a)² has determinant (1+a²)². -/
theorem spbM_sq_det (a : ℝ) : (spbM a * spbM a).det = (1 + a ^ 2) ^ 2 := by
  rw [spbM_det_mul]; ring

/-- The (1,0) entry of M(a)·M(b) is -(a+b), which is the negative numerator of spb. -/
theorem spbM_mul_entry_10 (a b : ℝ) : (spbM a * spbM b) 1 0 = -(a + b) := by
  rw [spbM_mul]; simp

/-- The diagonal entries of M(a)·M(b) are equal (both 1 - ab). -/
theorem spbM_mul_diag_equal (a b : ℝ) :
    (spbM a * spbM b) 0 0 = (spbM a * spbM b) 1 1 := by
  rw [spbM_mul]; simp

/-- M(a) * M(-a) = (1 + a²) • I. -/
theorem spbM_mul_neg (a : ℝ) :
    spbM a * spbM (-a) = (1 + a ^ 2) • (1 : Matrix (Fin 2) (Fin 2) ℝ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbM, Matrix.mul_apply, Fin.sum_univ_two, Matrix.smul_apply] <;> ring

end