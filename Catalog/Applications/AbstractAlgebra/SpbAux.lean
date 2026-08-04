import Mathlib

/-! # Auxiliary notions for the SPB (speed-addition) law

This module supplies the vocabulary used by the SPB catalog files: the
cross-ratio of four reals and the `2 × 2` matrix representing the Möbius
transformation `x ↦ (x + a)/(1 - a·x)` associated with the SPB law.
-/

noncomputable section

open Matrix

/-- The cross-ratio of four real numbers. -/
def crossRatio (a b c d : ℝ) : ℝ := ((a - c) * (b - d)) / ((a - d) * (b - c))

/-- The matrix `!![1, a; -a, 1]` of the Möbius transformation `x ↦ (x + a)/(1 - a x)`
underlying the SPB law. -/
def spbMat (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![1, a; -a, 1]

/-- The trace of `spbMat a` is `2`. -/
@[simp] theorem spbMat_trace (a : ℝ) : (spbMat a).trace = 2 := by
  simp [spbMat, Matrix.trace_fin_two]
  norm_num

/-- The determinant of `spbMat a` is `1 + a²`. -/
@[simp] theorem spbMat_det (a : ℝ) : (spbMat a).det = 1 + a ^ 2 := by
  simp [spbMat, Matrix.det_fin_two]
  ring

end