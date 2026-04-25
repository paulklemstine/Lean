/-! # CatalogBuild.EML.SPBResearch.SpectralTheory

Auto-generated from theorem catalog database.
Domain: EML/SPBResearch
Declarations: 22
-/

import Mathlib

noncomputable section

/-- The symmetric SPB matrix -/
def spbSMat (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![1, a; a, 1]


/-- The "plus" projector: P₊ = (1/2)[[1,1],[1,1]] -/
def projPlus : Matrix (Fin 2) (Fin 2) ℝ := !![1/2, 1/2; 1/2, 1/2]


/-- The "minus" projector: P₋ = (1/2)[[1,-1],[-1,1]] -/
def projMinus : Matrix (Fin 2) (Fin 2) ℝ := !![1/2, -1/2; -1/2, 1/2]


/-- P₊ is idempotent: P₊² = P₊ -/
theorem projPlus_idem : projPlus * projPlus = projPlus := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [projPlus, mul_apply, Fin.sum_univ_two] <;> ring


/-- P₋ is idempotent: P₋² = P₋ -/
theorem projMinus_idem : projMinus * projMinus = projMinus := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [projMinus, mul_apply, Fin.sum_univ_two] <;> ring


/-- P₊ · P₋ = 0 (orthogonality) -/
theorem projPlus_mul_projMinus : projPlus * projMinus = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [projPlus, projMinus, mul_apply, Fin.sum_univ_two] <;> ring


/-- P₋ · P₊ = 0 (orthogonality) -/
theorem projMinus_mul_projPlus : projMinus * projPlus = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [projPlus, projMinus, mul_apply, Fin.sum_univ_two] <;> ring


/-- P₊ + P₋ = I (completeness) -/
theorem proj_completeness : projPlus + projMinus = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [projPlus, projMinus, add_apply, one_apply] <;> ring


/-- Spectral decomposition: M(a) = (1+a)·P₊ + (1-a)·P₋ -/
theorem spbSMat_spectral (a : ℝ) :
    spbSMat a = (1 + a) • projPlus + (1 - a) • projMinus := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbSMat, projPlus, projMinus, smul_apply, add_apply] <;> ring


/-- P₊ is symmetric -/
theorem projPlus_symmetric : projPlusᵀ = projPlus := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [projPlus, transpose_apply]


/-- P₋ is symmetric -/
theorem projMinus_symmetric : projMinusᵀ = projMinus := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [projMinus, transpose_apply]


/-- tr(P₊) = 1 -/
theorem projPlus_trace : projPlus.trace = 1 := by
  simp [projPlus, trace, Fin.sum_univ_two]; ring


/-- tr(P₋) = 1 -/
theorem projMinus_trace : projMinus.trace = 1 := by
  simp [projMinus, trace, Fin.sum_univ_two]; ring


/-- det(P₊) = 0 (projector to 1-dim subspace) -/
theorem projPlus_det : projPlus.det = 0 := by
  simp [projPlus, det_fin_two]


/-- det(P₋) = 0 -/
theorem projMinus_det : projMinus.det = 0 := by
  simp [projMinus, det_fin_two]; norm_num


/-- M(a)² via spectral decomposition:
M(a)² = (1+a)²·P₊ + (1-a)²·P₋ = [[1+a², 2a], [2a, 1+a²]] -/
theorem spbSMat_sq_spectral (a : ℝ) :
    spbSMat a * spbSMat a =
    (1 + a) ^ 2 • projPlus + (1 - a) ^ 2 • projMinus := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbSMat, projPlus, projMinus, mul_apply, Fin.sum_univ_two, smul_apply, add_apply] <;> ring


/-- The explicit form of M(a)² -/
theorem spbSMat_sq_explicit (a : ℝ) :
    spbSMat a * spbSMat a = !![1 + a ^ 2, 2 * a; 2 * a, 1 + a ^ 2] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbSMat, mul_apply, Fin.sum_univ_two] <;> ring


/-- The trace of M(a)² = 2(1+a²) -/
theorem spbSMat_sq_trace (a : ℝ) :
    (spbSMat a * spbSMat a).trace = 2 * (1 + a ^ 2) := by
  simp [spbSMat, trace, mul_apply, Fin.sum_univ_two]; ring


/-- The Frobenius norm squared: ‖M(a)‖²_F = 2(1+a²) = tr(M(a)²) -/
theorem spbSMat_frobenius_sq (a : ℝ) :
    (1 : ℝ) ^ 2 + a ^ 2 + a ^ 2 + (1 : ℝ) ^ 2 = 2 * (1 + a ^ 2) := by ring


/-- M(a)³ explicit form -/
theorem spbSMat_cube (a : ℝ) :
    spbSMat a * (spbSMat a * spbSMat a) =
    !![1 + 3 * a ^ 2, 3 * a + a ^ 3; 3 * a + a ^ 3, 1 + 3 * a ^ 2] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbSMat, mul_apply, Fin.sum_univ_two] <;> ring


/-- The characteristic polynomial discriminant is -(2a)² ≤ 0,
so eigenvalues are always real (as expected for a symmetric matrix). -/
theorem spbSMat_discriminant_nonneg (a : ℝ) :
    (spbSMat a).trace ^ 2 - 4 * (spbSMat a).det ≥ 0 := by
  simp [spbSMat, trace, det_fin_two, Fin.sum_univ_two]; nlinarith [sq_nonneg a]


/-- The discriminant equals 4a² -/
theorem spbSMat_discriminant (a : ℝ) :
    (spbSMat a).trace ^ 2 - 4 * (spbSMat a).det = 4 * a ^ 2 := by
  simp [spbSMat, trace, det_fin_two, Fin.sum_univ_two]; ring


end
