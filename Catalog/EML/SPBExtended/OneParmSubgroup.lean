import Mathlib

/-! # CatalogBuild.EML.SPBExtended.OneParmSubgroup

Auto-generated from theorem catalog database.
Domain: EML/SPBExtended
Declarations: 26
-/

noncomputable section

/-- The boost generator: J = [[0, 1], [1, 0]] -/
def boostJ : Matrix (Fin 2) (Fin 2) ℝ := !![0, 1; 1, 0]

/-- The hyperbolic SPB matrix: H(t) = cosh(t)·I + sinh(t)·J -/
def hypMat (t : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![Real.cosh t, Real.sinh t; Real.sinh t, Real.cosh t]

/-- J² = I -/
theorem boostJ_sq : boostJ * boostJ = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [boostJ, mul_apply, Fin.sum_univ_two, one_apply]

/-- J³ = J -/
theorem boostJ_cube : boostJ * (boostJ * boostJ) = boostJ := by
  rw [boostJ_sq, mul_one]

/-- J⁴ = I -/
theorem boostJ_fourth : boostJ * (boostJ * (boostJ * boostJ)) = 1 := by
  rw [boostJ_sq, mul_one, boostJ_sq]

/-- tr(J) = 0 -/
theorem boostJ_trace : boostJ.trace = 0 := by
  simp [boostJ, Matrix.trace, Fin.sum_univ_two]

/-- det(J) = -1 -/
theorem boostJ_det : boostJ.det = -1 := by
  simp [boostJ, det_fin_two]

/-- H(t) can be decomposed as cosh(t)·I + sinh(t)·J -/
theorem hypMat_eq_cosh_plus_sinh_J (t : ℝ) :
    hypMat t = Real.cosh t • (1 : Matrix (Fin 2) (Fin 2) ℝ) + Real.sinh t • boostJ := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [hypMat, boostJ, smul_apply, add_apply, one_apply] <;> ring

/-- H(0) = I -/
theorem hypMat_zero : hypMat 0 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [hypMat, one_apply]

/-- det(H(t)) = cosh²(t) - sinh²(t) = 1 -/
theorem hypMat_det (t : ℝ) : (hypMat t).det = 1 := by
  simp [hypMat, det_fin_two]
  have := Real.cosh_sq_sub_sinh_sq t
  linarith

/-- tr(H(t)) = 2·cosh(t) -/
theorem hypMat_trace (t : ℝ) : (hypMat t).trace = 2 * Real.cosh t := by
  simp [hypMat, Matrix.trace, Fin.sum_univ_two]; ring

/-- H(t) is symmetric -/
theorem hypMat_symmetric (t : ℝ) : (hypMat t)ᵀ = hypMat t := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [hypMat, transpose_apply]

/-- The one-parameter subgroup property: H(s+t) = H(s)·H(t) -/
theorem hypMat_add (s t : ℝ) : hypMat (s + t) = hypMat s * hypMat t := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [hypMat, mul_apply, Fin.sum_univ_two] <;>
    [rw [Real.cosh_add]; rw [Real.sinh_add]; rw [Real.sinh_add]; rw [Real.cosh_add]] <;>
    ring

/-- H(-t) = H(t)⁻¹ (inverse via negation) — stated as H(t)·H(-t) = I -/
theorem hypMat_mul_neg (t : ℝ) : hypMat t * hypMat (-t) = 1 := by
  rw [← hypMat_add]; simp [hypMat_zero]

/-- H(t) = cosh(t) · M(tanh(t)) when cosh(t) ≠ 0 -/
theorem hypMat_eq_cosh_spbM (t : ℝ) (hc : Real.cosh t ≠ 0) :
    hypMat t = Real.cosh t • spbM (Real.tanh t) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [hypMat, spbM, smul_apply, Real.tanh_eq_sinh_div_cosh] <;>
    field_simp

/-- cosh is always positive, so the hypothesis cosh(t) ≠ 0 is always satisfied -/
theorem cosh_pos' (t : ℝ) : Real.cosh t > 0 := Real.cosh_pos t

/-- The velocity-rapidity correspondence:
if v = tanh(ρ), then M(v) = (1/cosh(ρ)) · H(ρ) -/
theorem velocity_rapidity (ρ : ℝ) :
    spbM (Real.tanh ρ) = (1 / Real.cosh ρ) • hypMat ρ := by
  have hc : Real.cosh ρ ≠ 0 := ne_of_gt (Real.cosh_pos ρ)
  rw [hypMat_eq_cosh_spbM ρ hc]
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [smul_apply] <;> field_simp

/-- det(M(v)) = 1 - v² = 1/cosh²(ρ) when v = tanh(ρ) -/
theorem spbM_det_tanh (ρ : ℝ) :
    (spbM (Real.tanh ρ)).det = 1 / Real.cosh ρ ^ 2 := by
  simp [spbM, det_fin_two, Real.tanh_eq_sinh_div_cosh]
  have hc : Real.cosh ρ ≠ 0 := ne_of_gt (Real.cosh_pos ρ)
  field_simp
  have := Real.cosh_sq_sub_sinh_sq ρ
  linarith

/-- H(t)² has explicit form [[cosh(2t), sinh(2t)], [sinh(2t), cosh(2t)]] = H(2t) -/
theorem hypMat_sq (t : ℝ) : hypMat t * hypMat t = hypMat (2 * t) := by
  rw [← hypMat_add]; ring_nf

/-- The Lorentz boost preserves the Minkowski inner product:
x² - y² is preserved under (x,y) ↦ (cosh(t)·x + sinh(t)·y, sinh(t)·x + cosh(t)·y) -/
theorem lorentz_minkowski_invariance (x y t : ℝ) :
    (Real.cosh t * x + Real.sinh t * y) ^ 2 - (Real.sinh t * x + Real.cosh t * y) ^ 2 =
    x ^ 2 - y ^ 2 := by
  have h1 := Real.cosh_sq_sub_sinh_sq t
  nlinarith [sq_nonneg (Real.cosh t * x - Real.sinh t * y),
             sq_nonneg (Real.sinh t * x - Real.cosh t * y),
             sq_nonneg (Real.cosh t * x + Real.sinh t * y),
             sq_nonneg (Real.sinh t * x + Real.cosh t * y),
             sq_nonneg x, sq_nonneg y,
             sq_nonneg (Real.cosh t), sq_nonneg (Real.sinh t)]

/-- The Lorentz boost sends (1, 0) to (cosh t, sinh t) on the hyperboloid -/
theorem lorentz_hyperboloid (t : ℝ) :
    Real.cosh t ^ 2 - Real.sinh t ^ 2 = 1 := by
  have := Real.cosh_sq_sub_sinh_sq t; linarith

/-- tanh is bounded: |tanh(t)| < 1 for all t -/
theorem tanh_bounded (t : ℝ) : |Real.tanh t| < 1 := Real.abs_tanh_lt_one t

/-- The gamma factor from rapidity: 1/(1 - tanh²(t)) = cosh²(t) -/
theorem gamma_from_rapidity (t : ℝ) :
    1 - Real.tanh t ^ 2 = 1 / Real.cosh t ^ 2 := by
  rw [Real.tanh_eq_sinh_div_cosh]
  have hc : Real.cosh t ≠ 0 := ne_of_gt (Real.cosh_pos t)
  field_simp
  have := Real.cosh_sq_sub_sinh_sq t
  linarith

/-- Hyperbolic double angle: cosh(2t) = 2·cosh²(t) - 1 -/
theorem cosh_double (t : ℝ) : Real.cosh (2 * t) = 2 * Real.cosh t ^ 2 - 1 := by
  have : 2 * t = t + t := by ring
  rw [this, Real.cosh_add]
  have := Real.cosh_sq_sub_sinh_sq t
  nlinarith

/-- Hyperbolic double angle: sinh(2t) = 2·sinh(t)·cosh(t) -/
theorem sinh_double (t : ℝ) : Real.sinh (2 * t) = 2 * Real.sinh t * Real.cosh t := by
  have : 2 * t = t + t := by ring
  rw [this, Real.sinh_add]; ring

/-- The velocity addition in terms of rapidity parameters:
H(ρ₁)·H(ρ₂) = H(ρ₁+ρ₂), so velocities compose as tanh values add as rapidities -/
theorem velocity_composition_rapidity (ρ₁ ρ₂ : ℝ) :
    hypMat ρ₁ * hypMat ρ₂ = hypMat (ρ₁ + ρ₂) :=
  (hypMat_add ρ₁ ρ₂).symm

end
