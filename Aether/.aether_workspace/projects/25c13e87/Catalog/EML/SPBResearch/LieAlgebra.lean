import Mathlib

/-! # CatalogBuild.EML.SPBResearch.LieAlgebra

Auto-generated from theorem catalog database.
Domain: EML/SPBResearch
Declarations: 18
-/

noncomputable section

/-- The symmetric SPB matrix: M(a) = [[1, a], [a, 1]]. -/
def spbSymMat (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![1, a; a, 1]

/-- The boost generator J = [[0, 1], [1, 0]]. -/
def boostGen : Matrix (Fin 2) (Fin 2) ℝ := !![0, 1; 1, 0]

/-- The hyperbolic SPB. -/
def spbHL (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- M(a) = I + a·J -/
theorem spbSymMat_eq_id_add_aJ (a : ℝ) :
    spbSymMat a = 1 + a • boostGen := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbSymMat, boostGen, one_apply, smul_apply] <;> ring

/-- det(M(a)) = 1 - a² -/
theorem spbSymMat_det (a : ℝ) : (spbSymMat a).det = 1 - a ^ 2 := by
  simp [spbSymMat, det_fin_two]; ring

/-- tr(M(a)) = 2 -/
theorem spbSymMat_trace (a : ℝ) : (spbSymMat a).trace = 2 := by
  simp [spbSymMat, Matrix.trace, Fin.sum_univ_two]; ring

/-- M(a) is symmetric: M(a)ᵀ = M(a) -/
theorem spbSymMat_transpose (a : ℝ) : (spbSymMat a)ᵀ = spbSymMat a := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbSymMat, transpose_apply]

/-- M(0) = I -/
theorem spbSymMat_zero : spbSymMat 0 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbSymMat, one_apply]

/-- J² = I (the boost generator is an involution) -/
theorem boostGen_sq : boostGen * boostGen = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [boostGen, mul_apply, Fin.sum_univ_two, one_apply]

/-- The product M(a)·M(b) has explicit entries [[1+ab, a+b], [a+b, 1+ab]] -/
theorem spbSymMat_mul (a b : ℝ) :
    spbSymMat a * spbSymMat b =
    !![1 + a * b, a + b; a + b, 1 + a * b] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbSymMat, mul_apply, Fin.sum_univ_two] <;> ring

/-- M(a)·M(b) = (1+ab)·M(spbH(a,b)) when 1+ab ≠ 0.
This is the KEY result: the product involves the HYPERBOLIC SPB, not the circular one. -/
theorem spbSymMat_mul_eq_scaled_spbH (a b : ℝ) (h : 1 + a * b ≠ 0) :
    spbSymMat a * spbSymMat b = (1 + a * b) • spbSymMat (spbHL a b) := by
  have h' : 1 + b * a ≠ 0 := by rwa [mul_comm] at h
  unfold spbSymMat spbHL
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [mul_apply, Fin.sum_univ_two, smul_apply, smul_eq_mul] <;>
    field_simp <;> ring

/-- det(M(a)·M(b)) = det(M(a))·det(M(b)) -/
theorem spbSymMat_det_mul (a b : ℝ) :
    (spbSymMat a * spbSymMat b).det = (spbSymMat a).det * (spbSymMat b).det :=
  det_mul _ _

/-- The determinant identity: (1-a²)(1-b²) = (1+ab)² - (a+b)² -/
theorem det_factorization (a b : ℝ) :
    (1 - a ^ 2) * (1 - b ^ 2) = (1 + a * b) ^ 2 - (a + b) ^ 2 := by ring

/-- M(a)·M(-a) = (1-a²)·I -/
theorem spbSymMat_mul_neg (a : ℝ) :
    spbSymMat a * spbSymMat (-a) = (1 - a ^ 2) • (1 : Matrix (Fin 2) (Fin 2) ℝ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbSymMat, mul_apply, Fin.sum_univ_two, smul_apply, one_apply] <;> ring

/-- M(a)² has explicit form [[1+a², 2a], [2a, 1+a²]] -/
theorem spbSymMat_sq (a : ℝ) :
    spbSymMat a * spbSymMat a =
    !![1 + a ^ 2, 2 * a; 2 * a, 1 + a ^ 2] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbSymMat, mul_apply, Fin.sum_univ_two] <;> ring

/-- The Cayley-Hamilton theorem for M(a): M(a)² - 2·M(a) + (1-a²)·I = 0 -/
theorem spbSymMat_cayley_hamilton (a : ℝ) :
    spbSymMat a * spbSymMat a - 2 • spbSymMat a + (1 - a ^ 2) • (1 : Matrix (Fin 2) (Fin 2) ℝ) = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbSymMat, mul_apply, Fin.sum_univ_two, smul_apply, sub_apply, one_apply] <;> ring

/-- The hyperbolic half-angle formula: spbH(t,t) = 2t/(1+t²) -/
theorem spbHL_double (t : ℝ) : spbHL t t = 2 * t / (1 + t ^ 2) := by
  unfold spbHL; ring

/-- The boost composition is bounded: |u|,|v| < 1 ⟹ |spbH(u,v)| < 1 -/
theorem spbHL_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbHL u v| < 1 := by
  rw [abs_lt] at *
  constructor
  · rw [spbHL, lt_div_iff₀] <;> nlinarith
  · rw [spbHL, div_lt_iff₀] <;> nlinarith

end
