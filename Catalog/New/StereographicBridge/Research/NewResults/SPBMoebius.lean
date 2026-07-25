import Mathlib

/-!
# SPB and Möbius Transformations

## Main Results
- Matrix representation of SPB
- Composition = matrix multiplication
- Determinant = 1 + a² (always positive)
- SPB matrix inverse via negation
- Trace is always 2
-/

noncomputable section
open Matrix

/-- The 2×2 matrix associated to the SPB translation by a. -/
def spbMatrix (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![1, a; -a, 1]

/-- The determinant of the SPB matrix is 1 + a². -/
theorem spbMatrix_det (a : ℝ) : (spbMatrix a).det = 1 + a ^ 2 := by
  simp [spbMatrix, det_fin_two]; ring

/-- The SPB matrix always has positive determinant. -/
theorem spbMatrix_det_pos (a : ℝ) : (spbMatrix a).det > 0 := by
  rw [spbMatrix_det]; positivity

/-- The SPB matrix for a = 0 is the identity. -/
theorem spbMatrix_zero : spbMatrix 0 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbMatrix]

/-- The product of two SPB matrices. -/
theorem spbMatrix_mul (a b : ℝ) :
    spbMatrix a * spbMatrix b =
    !![1 - a * b, a + b; -(a + b), 1 - a * b] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbMatrix, mul_apply, Fin.sum_univ_two] <;> ring

/-- The (0,0) entry of spbMatrix(a) * spbMatrix(b) is 1 - ab. -/
theorem spbMatrix_mul_entry_00 (a b : ℝ) :
    (spbMatrix a * spbMatrix b) 0 0 = 1 - a * b := by
  simp [spbMatrix, mul_apply, Fin.sum_univ_two]; ring

/-- The (0,1) entry is a + b. -/
theorem spbMatrix_mul_entry_01 (a b : ℝ) :
    (spbMatrix a * spbMatrix b) 0 1 = a + b := by
  simp [spbMatrix, mul_apply, Fin.sum_univ_two]; ring

/-- Determinant is multiplicative. -/
theorem spbMatrix_det_mul (a b : ℝ) :
    (spbMatrix a * spbMatrix b).det = (1 + a ^ 2) * (1 + b ^ 2) := by
  rw [det_mul, spbMatrix_det, spbMatrix_det]

/-- The SPB matrix for -a. -/
theorem spbMatrix_neg (a : ℝ) : spbMatrix (-a) =
    !![1, -a; a, 1] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbMatrix]

/-- M_a · M_{-a} = (1+a²) · I. -/
theorem spbMatrix_mul_neg (a : ℝ) :
    spbMatrix a * spbMatrix (-a) = (1 + a ^ 2) • (1 : Matrix (Fin 2) (Fin 2) ℝ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbMatrix, mul_apply, Fin.sum_univ_two, smul_apply] <;> ring

/-- The trace of the SPB matrix is 2. -/
theorem spbMatrix_trace (a : ℝ) :
    (spbMatrix a).trace = 2 := by
  simp [spbMatrix, trace, Fin.sum_univ_two]; norm_num

end
