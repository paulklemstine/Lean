import Mathlib

/-! # CatalogBuild.EML.SPBMoebius

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6
-/

noncomputable section

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
