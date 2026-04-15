/-! # CatalogBuild.EML.FundamentalTheory

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 27
-/

import Mathlib

noncomputable section

/-- The real EML operator: eml(x, y) = exp(x) - ln(y). -/
def eml_fun (x y : ℝ) : ℝ := Real.exp x - Real.log y


/-- The diagonal map: d(z) = exp(z) - ln(z). -/
def eml_diag (z : ℝ) : ℝ := Real.exp z - Real.log z


/-- eml(0, exp(x)) = 1 - x for all x. -/
theorem eml_one_minus (x : ℝ) : eml_fun 0 (Real.exp x) = 1 - x := by
  unfold eml_fun; simp


/-- For positive a: eml(ln a, exp b) = a - b. -/
theorem eml_sub (a b : ℝ) (ha : 0 < a) :
    eml_fun (Real.log a) (Real.exp b) = a - b := by
  unfold eml_fun; rw [Real.exp_log ha, Real.log_exp]


/-- For positive a: eml(ln a, exp(-b)) = a + b. -/
theorem eml_add (a b : ℝ) (ha : 0 < a) :
    eml_fun (Real.log a) (Real.exp (-b)) = a + b := by
  unfold eml_fun; rw [Real.exp_log ha]; simp


/-- EML is not commutative. -/
theorem eml_not_comm : ∃ x y : ℝ, eml_fun x y ≠ eml_fun y x := by
  use 0, 1
  unfold eml_fun
  simp [Real.log_one, Real.exp_zero]
  intro h
  have : (1 : ℝ) = Real.exp 1 := by linarith
  linarith [Real.one_lt_exp_iff.mpr (by linarith : (0:ℝ) < 1)]


/-- [Section: ## Section 2: EML Magma Structure] -/
theorem eml_not_assoc : ∃ a b c : ℝ,
    eml_fun (eml_fun a b) c ≠ eml_fun a (eml_fun b c) := by
  -- Let's choose $a = 0$, $b = 1$, and $c = 1$.
  use 0, 1, 1;
  unfold eml_fun; norm_num;


theorem eml_no_left_identity : ¬ ∃ e_L : ℝ, ∀ y : ℝ, eml_fun e_L y = y := by
  simp +zetaDelta at *;
  intro x
  by_contra h_contra
  push_neg at h_contra;
  have := h_contra 0; have := h_contra 1; have := h_contra ( -1 ) ; norm_num [ eml_fun ] at *;


theorem eml_no_right_identity : ¬ ∃ e_R : ℝ, ∀ x : ℝ, eml_fun x e_R = x := by
  unfold eml_fun;
  rintro ⟨ e_R, h ⟩;
  have := h 0;
  exact absurd ( h 1 ) ( by have := h ( -1 ) ; norm_num at * ; linarith [ Real.add_one_le_exp 1, Real.exp_pos ( -1 ) ] )


/-- Partial derivative of eml w.r.t. x is exp(x). -/
theorem eml_gradient_fst (x y : ℝ) :
    HasDerivAt (fun x' => eml_fun x' y) (Real.exp x) x := by
  exact (Real.hasDerivAt_exp x).sub_const _


/-- Partial derivative of eml w.r.t. y is -1/y for y ≠ 0. -/
theorem eml_gradient_snd (x y : ℝ) (hy : y ≠ 0) :
    HasDerivAt (fun y' => eml_fun x y') (-(y⁻¹)) y := by
  have : HasDerivAt (fun y' => eml_fun x y') (0 - y⁻¹) y := by
    exact (hasDerivAt_const y (Real.exp x)).sub (Real.hasDerivAt_log hy)
  simpa using this


/-- EML is continuous in x (for fixed y). -/
theorem eml_continuous_x (y : ℝ) : Continuous (fun x => eml_fun x y) :=
  Real.continuous_exp.sub continuous_const


/-- EML is continuous in y for y > 0. -/
theorem eml_continuousOn_y (x : ℝ) : ContinuousOn (fun y => eml_fun x y) (Ioi 0) := by
  apply ContinuousOn.sub continuousOn_const
  exact Real.continuousOn_log.mono (fun y hy => ne_of_gt hy)


/-- [Section: ## Section 4: EML Diagonal Map — Deeper Analysis] -/
theorem eml_diag_gt (z : ℝ) : eml_diag z > z := by
  unfold eml_diag;
  by_cases hz : z ≤ 0;
  · by_cases h : z = 0 <;> simp_all +decide [ Real.log_le_iff_le_exp ];
    linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos ( neg_pos.mpr ( lt_of_le_of_ne hz h ) ), Real.log_neg_eq_log z ];
  · have := Real.log_le_sub_one_of_pos ( show 0 < Real.exp z / 2 by positivity );
    rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_exp ] at this;
    linarith [ Real.log_le_sub_one_of_pos zero_lt_two, Real.log_le_sub_one_of_pos ( show 0 < z by linarith ) ]


/-- The diagonal map is NOT globally strictly monotone.
d'(z) = exp(z) - 1/z is negative for small positive z (e.g., z = 0.1).
However, d is eventually strictly increasing for z > W(1) ≈ 0.567. -/
theorem eml_diag_tendsto_top : Tendsto eml_diag atTop atTop := by
  refine' Filter.tendsto_atTop_mono' _ _ _;
  exact fun x => Real.exp x / 2;
  · filter_upwards [ Filter.eventually_gt_atTop 1 ] with x hx;
    unfold eml_diag;
    have := Real.log_le_sub_one_of_pos ( by positivity : 0 < x / 2 );
    rw [ Real.log_div ] at this <;> linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos zero_lt_two ];
  · exact Filter.Tendsto.atTop_div_const ( by norm_num ) ( Real.tendsto_exp_atTop )


/-- For z > 0, d(z) ≥ 1. -/
theorem eml_diag_ge_one_pos (z : ℝ) (hz : 0 < z) : eml_diag z ≥ 1 := by
  unfold eml_diag
  linarith [Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz]


/-- The tropical EML operator: trop_eml(x,y) = max(x, -y). -/
def tropEml (x y : ℝ) : ℝ := max x (-y)


/-- Tropical EML recovers max when y is negated. -/
theorem tropEml_is_max (x y : ℝ) : tropEml x (-y) = max x y := by
  unfold tropEml; simp


/-- Tropical EML is idempotent: trop_eml(z,-z) = z for z ≥ 0. -/
theorem tropEml_idem_nonneg (z : ℝ) (hz : 0 ≤ z) : tropEml z (-z) = z := by
  unfold tropEml; simp [max_eq_left hz]


/-- eml(x, exp(x)) = exp(x) - x ≥ 1. -/
theorem eml_exp_lower_bound (x : ℝ) : eml_fun x (Real.exp x) ≥ 1 := by
  unfold eml_fun
  simp [Real.log_exp]
  linarith [Real.add_one_le_exp x]


/-- eml(x, 1) = exp(x) ≥ 1 + x. -/
theorem eml_one_ge (x : ℝ) : eml_fun x 1 ≥ 1 + x := by
  unfold eml_fun
  simp [Real.log_one]
  linarith [Real.add_one_le_exp x]


/-- For y > 0: eml(0, y) = 1 - ln(y) ≥ 2 - y. -/
theorem eml_zero_bound (y : ℝ) (hy : 0 < y) : eml_fun 0 y ≥ 2 - y := by
  unfold eml_fun; simp
  linarith [Real.log_le_sub_one_of_pos hy]


/-- For a > 0: a^b = exp(b · ln a). -/
theorem power_via_eml (a b : ℝ) (ha : 0 < a) :
    a ^ b = Real.exp (b * Real.log a) := by
  rw [Real.rpow_def_of_pos ha, mul_comm]


/-- At the fixed point of g(z) = e - ln(z): z + ln(z) = e. -/
theorem lambert_connection (z : ℝ) (hz : 0 < z)
    (hfp : Real.exp 1 - Real.log z = z) :
    z + Real.log z = Real.exp 1 := by
  linarith


/-- At the fixed point: z · exp(z) = exp(exp(1)). -/
theorem lambert_product (z : ℝ) (hz : 0 < z)
    (hsum : z + Real.log z = Real.exp 1) :
    z * Real.exp z = Real.exp (Real.exp 1) := by
  rw [← hsum, Real.exp_add, Real.exp_log hz]; ring


/-- Derivative of the fixed-point iteration g(z) = e - ln(z). -/
theorem lambert_g_deriv (z : ℝ) (hz : 0 < z) :
    HasDerivAt (fun z' => Real.exp 1 - Real.log z') (0 - z⁻¹) z := by
  exact (hasDerivAt_const z (Real.exp 1)).sub (Real.hasDerivAt_log (ne_of_gt hz))


/-- |g'(z*)| < 1 when z* > 1, so the iteration is a contraction near z*. -/
theorem lambert_contraction (z : ℝ) (hz : z > 1) : |-(z⁻¹)| < 1 := by
  rw [abs_neg, abs_of_pos (inv_pos.mpr (by linarith))]
  exact inv_lt_one_of_one_lt₀ hz


end
