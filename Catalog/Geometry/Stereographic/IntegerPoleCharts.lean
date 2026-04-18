import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.IntegerPoleCharts

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 26
-/


noncomputable section

/-- The integer-pole chart map T_{n,m}(z) = (nz + m)/(z + 1).
Maps ∞ → n (North Pole) and 0 → m (South Pole). -/
def intPoleChart (n m z : ℝ) : ℝ := (n * z + m) / (z + 1)



/-- The inverse chart map T_{n,m}⁻¹(w) = (w - m)/(n - w).
Maps n → ∞ and m → 0. -/
def intPoleChartInv (n m w : ℝ) : ℝ := (w - m) / (n - w)



/-- The transition map from (n₁,m₁)-chart to (n₂,m₂)-chart. -/
def chartTransition (n₁ m₁ n₂ m₂ w : ℝ) : ℝ :=
  ((n₂ - m₂) * w + (m₂ * n₁ - n₂ * m₁)) / (n₁ - m₁)



/-- T_{n,m}(0) = m: South Pole maps to m. -/
theorem intPoleChart_south (n m : ℝ) : intPoleChart n m 0 = m := by
  simp [intPoleChart]



/-- T_{n,m}(1) = (n+m)/2: the equatorial point maps to the arithmetic mean. -/
theorem intPoleChart_equator (n m : ℝ) : intPoleChart n m 1 = (n + m) / 2 := by
  unfold intPoleChart; ring



/-- The determinant n - m of the chart matrix is nonzero when n ≠ m. -/
theorem intPoleChart_det_ne_zero {n m : ℝ} (h : n ≠ m) : n - m ≠ 0 := by
  intro h'; exact h (by linarith)



/-- [Section: # CatalogBuild.Geometry.Stereographic.IntegerPoleCharts
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 26] -/
theorem intPoleChart_inv_left (n m z : ℝ) (hz : z ≠ -1) (hnm : n ≠ m) :
    intPoleChartInv n m (intPoleChart n m z) = z := by
  unfold intPoleChartInv intPoleChart;
  grind



theorem intPoleChart_inv_right (n m w : ℝ) (hw : w ≠ n) (hnm : n ≠ m) :
    intPoleChart n m (intPoleChartInv n m w) = w := by
  unfold intPoleChart intPoleChartInv;
  grind



theorem transition_is_affine (n₁ m₁ n₂ m₂ w : ℝ)
    (hw : w ≠ n₁) (h₁ : n₁ ≠ m₁) (h₂ : n₂ ≠ m₂) :
    intPoleChart n₂ m₂ (intPoleChartInv n₁ m₁ w) = chartTransition n₁ m₁ n₂ m₂ w := by
  unfold intPoleChart intPoleChartInv chartTransition ; ring;
  grind



theorem pole_swap_involution (t : ℝ) (ht : t ≠ 0) : 1 / (1 / t) = t := by
  norm_num [ ht ]



theorem dual_is_reflection (n m w : ℝ) (hnm : n ≠ m) :
    chartTransition n m m n w = -w + (n + m) := by
  rw [ chartTransition ] ; rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne hnm <;> nlinarith;



theorem self_dual_point (n m : ℝ) (hnm : n ≠ m) :
    chartTransition n m m n ((n + m) / 2) = (n + m) / 2 := by
  rw [ chartTransition ] ; rw [ div_eq_iff ( sub_ne_zero_of_ne hnm ) ] ; ring;



/-- The change-of-pole map M_a(t) = (at + 1)/(t - a). -/
def poleChangeMap (a t : ℝ) : ℝ := (a * t + 1) / (t - a)



/-- M_0(t) = 1/t: at a = 0, the pole change is classical inversion. -/
theorem poleChangeMap_zero (t : ℝ) (ht : t ≠ 0) :
    poleChangeMap 0 t = 1 / t := by
  simp [poleChangeMap]



/-- The denominator 1 + a² is always positive. -/
theorem one_add_sq_pos (a : ℝ) : (0 : ℝ) < 1 + a ^ 2 := by positivity



/-- The k-th crystal point in the (n,m)-chart is (nk + m)/(k + 1). -/
def crystalPoint (n m : ℤ) (k : ℤ) : ℚ := (n * k + m : ℤ) / (k + 1 : ℤ)



/-- At k = 0, the crystal point equals m. -/
theorem crystalPoint_zero (n m : ℤ) : crystalPoint n m 0 = m := by
  simp [crystalPoint]



/-- At k = 1, the crystal point equals (n + m)/2. -/
theorem crystalPoint_one (n m : ℤ) : crystalPoint n m 1 = (n + m : ℤ) / 2 := by
  simp [crystalPoint]



/-- The effective denominator in the (n,m)-chart: D_{n,m}(w) = (n-m)² + (w-m)². -/
def effectiveDenom (n m w : ℝ) : ℝ := (n - m) ^ 2 + (w - m) ^ 2



/-- The effective denominator is always nonneg. -/
theorem effectiveDenom_nonneg (n m w : ℝ) : 0 ≤ effectiveDenom n m w := by
  unfold effectiveDenom; positivity



theorem effectiveDenom_pos (n m w : ℝ) (hnm : n ≠ m) : 0 < effectiveDenom n m w := by
  exact add_pos_of_pos_of_nonneg ( sq_pos_of_ne_zero ( sub_ne_zero.mpr hnm ) ) ( sq_nonneg _ )



/-- The scale factor of the transition from (n₁,m₁) to (n₂,m₂). -/
def transitionScale (n₁ m₁ n₂ m₂ : ℝ) : ℝ := (n₂ - m₂) / (n₁ - m₁)



/-- The translation of the transition from (n₁,m₁) to (n₂,m₂). -/
def transitionShift (n₁ m₁ n₂ m₂ : ℝ) : ℝ := (m₂ * n₁ - n₂ * m₁) / (n₁ - m₁)



/-- The identity transition: (n,m) → (n,m) has scale 1 and shift 0. -/
theorem transition_identity_scale (n m : ℝ) (hnm : n ≠ m) :
    transitionScale n m n m = 1 := by
  unfold transitionScale
  have : n - m ≠ 0 := sub_ne_zero.mpr hnm
  field_simp



theorem transition_identity (n m w : ℝ) (hnm : n ≠ m) :
    chartTransition n m n m w = w := by
  grind +locals



theorem dual_scale (n m : ℝ) (hnm : n ≠ m) :
    transitionScale n m m n = -1 := by
  unfold transitionScale; rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne hnm <;> nlinarith;



end
