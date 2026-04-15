/-! # CatalogBuild.EML.V11.MetricGeometry

Auto-generated from theorem catalog database.
Domain: EML/V11
Declarations: 22
-/

import Mathlib

noncomputable section

/-- The (1,1) component of the EML Hessian metric: g₁₁(x,y) = exp(x). -/
def emlMetric11 (x : ℝ) : ℝ := Real.exp x


/-- The (2,2) component: g₂₂(x,y) = 1/y² for y > 0. -/
def emlMetric22 (y : ℝ) : ℝ := 1 / y ^ 2


/-- Metric determinant: det(g) = exp(x)/y². -/
theorem emlMetric_det (x y : ℝ) (hy : 0 < y) :
    emlMetric11 x * emlMetric22 y = Real.exp x / y ^ 2 := by
  unfold emlMetric11 emlMetric22; field_simp


/-- Metric determinant is positive for y > 0. -/
theorem emlMetric_det_pos (x y : ℝ) (hy : 0 < y) :
    emlMetric11 x * emlMetric22 y > 0 := by
  rw [emlMetric_det x y hy]; positivity


/-- Flat coordinate u = 2·exp(x/2). -/
def flatCoordU (x : ℝ) : ℝ := 2 * Real.exp (x / 2)


/-- Flat coordinate v = ln(y) for y > 0. -/
def flatCoordV (y : ℝ) : ℝ := Real.log y


/-- The u-coordinate is always positive. -/
theorem flatCoordU_pos (x : ℝ) : flatCoordU x > 0 := by
  unfold flatCoordU; positivity


/-- The u-coordinate is strictly monotone in x. -/
theorem flatCoordU_strictMono : StrictMono flatCoordU := by
  intro a b hab
  unfold flatCoordU
  have : Real.exp (a / 2) < Real.exp (b / 2) :=
    Real.exp_strictMono (by linarith)
  linarith


/-- The v-coordinate is strictly monotone in y on (0,∞). -/
theorem flatCoordV_strictMono : StrictMonoOn flatCoordV (Set.Ioi 0) := by
  intro a ha b _ hab
  unfold flatCoordV
  exact Real.log_lt_log ha hab


/-- u-coordinate derivative: du/dx = exp(x/2). -/
theorem flatCoordU_deriv (x : ℝ) :
    HasDerivAt flatCoordU (Real.exp (x / 2)) x := by
  unfold flatCoordU
  have h := (Real.hasDerivAt_exp (x / 2)).comp x (hasDerivAt_id x |>.div_const 2)
  convert h.const_mul 2 using 1
  ring


/-- (du/dx)² = exp(x) = g₁₁, confirming the flat coordinate transformation. -/
theorem flatCoordU_deriv_sq (x : ℝ) :
    Real.exp (x / 2) ^ 2 = Real.exp x := by
  rw [sq, ← Real.exp_add]; congr 1; ring


/-- v-coordinate derivative: dv/dy = 1/y for y ≠ 0. -/
theorem flatCoordV_deriv (y : ℝ) (hy : y ≠ 0) :
    HasDerivAt flatCoordV (y⁻¹) y := by
  unfold flatCoordV
  exact Real.hasDerivAt_log hy


/-- (dv/dy)² = 1/y² = g₂₂. -/
theorem flatCoordV_deriv_sq (y : ℝ) :
    (y⁻¹) ^ 2 = 1 / y ^ 2 := by
  rw [inv_pow]; ring


/-- The geodesic distance squared in the EML metric, via flat coordinates. -/
def emlDistSq (x₁ y₁ x₂ y₂ : ℝ) : ℝ :=
  (flatCoordU x₁ - flatCoordU x₂) ^ 2 + (flatCoordV y₁ - flatCoordV y₂) ^ 2


/-- Distance squared is nonneg. -/
theorem emlDistSq_nonneg (x₁ y₁ x₂ y₂ : ℝ) : emlDistSq x₁ y₁ x₂ y₂ ≥ 0 := by
  unfold emlDistSq; positivity


/-- [Section: ## Section 3: Distance in Flat Coordinates] -/
theorem emlDistSq_eq_zero_iff (x₁ y₁ x₂ y₂ : ℝ) (hy₁ : 0 < y₁) (hy₂ : 0 < y₂) :
    emlDistSq x₁ y₁ x₂ y₂ = 0 ↔ x₁ = x₂ ∧ y₁ = y₂ := by
  constructor <;> intro h <;> simp_all +decide [ sub_eq_iff_eq_add, emlDistSq ];
  -- Since the sum of squares is zero, each square must be zero.
  have h_u : flatCoordU x₁ = flatCoordU x₂ := by
    nlinarith
  have h_v : flatCoordV y₁ = flatCoordV y₂ := by
    grind +splitIndPred;
  exact ⟨ flatCoordU_strictMono.injective h_u, Real.log_injOn_pos hy₁ hy₂ h_v ⟩


/-- Distance is symmetric. -/
theorem emlDistSq_symm (x₁ y₁ x₂ y₂ : ℝ) :
    emlDistSq x₁ y₁ x₂ y₂ = emlDistSq x₂ y₂ x₁ y₁ := by
  unfold emlDistSq; ring


/-- Distance from a point to itself is zero. -/
theorem emlDistSq_self (x y : ℝ) : emlDistSq x y x y = 0 := by
  unfold emlDistSq; ring


/-- The y-geodesic is geometric interpolation: y(t) = y₁^(1-t) · y₂^t for y₁,y₂ > 0.
In flat coords this is linear: v(t) = (1-t)·ln(y₁) + t·ln(y₂). -/
theorem geodesic_y_geometric (y₁ y₂ t : ℝ) (hy₁ : 0 < y₁) (hy₂ : 0 < y₂) :
    flatCoordV (y₁ ^ (1 - t) * y₂ ^ t) = (1 - t) * flatCoordV y₁ + t * flatCoordV y₂ := by
  unfold flatCoordV
  rw [Real.log_mul (by positivity) (by positivity),
      Real.log_rpow hy₁, Real.log_rpow hy₂]


/-- Translation in v (= scaling in y): v ↦ v + ln(c). -/
theorem isometry_y_scaling (c y : ℝ) (hc : 0 < c) (hy : 0 < y) :
    flatCoordV (c * y) = flatCoordV y + Real.log c := by
  unfold flatCoordV
  rw [Real.log_mul (ne_of_gt hc) (ne_of_gt hy), add_comm]


/-- At x = 0, the EML metric g₁₁ = 1, giving the Euclidean metric locally. -/
theorem emlMetric11_at_zero : emlMetric11 0 = 1 := by
  unfold emlMetric11; exact Real.exp_zero


/-- The y-part of EML metric matches the Poincaré half-plane metric. -/
theorem eml_poincare_y_match (y : ℝ) :
    emlMetric22 y = 1 / y ^ 2 := by
  simp [emlMetric22]


end
