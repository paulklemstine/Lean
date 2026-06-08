import EML.EMLv17Core
import Mathlib

/-! # CatalogBuild.EML.EMLv17Advanced

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 29
-/

noncomputable section

/-- [Section: ## V17.A1: g-Map Uniqueness and Exact Unique Existence] -/
theorem emlGmap_at_most_one_fixed_point (a b : ℝ) (ha : 0 < a) (hb : 0 < b)
    (hfa : emlGmap a = a) (hfb : emlGmap b = b) : a = b := by
      exact le_antisymm ( le_of_not_gt fun h => by linarith [ emlGmap_strictAnti hb ha h ] ) ( le_of_not_gt fun h => by linarith [ emlGmap_strictAnti ha hb h ] )

theorem emlGmap_unique_fixed_point :
    ∃! z, z ∈ Ioo 2 (exp 1) ∧ emlGmap z = z := by
      apply_rules [ existsUnique_of_exists_of_unique ];
      · exact?;
      · exact fun y₁ y₂ h₁ h₂ => emlGmap_at_most_one_fixed_point y₁ y₂ ( by linarith [ h₁.1.1 ] ) ( by linarith [ h₂.1.1 ] ) h₁.2 h₂.2

/-- [Section: ## V17.A2: g-Map Lipschitz on [2, ∞)] -/
theorem emlGmap_lipschitz (x y : ℝ) (hx : 2 ≤ x) (hy : 2 ≤ y) :
    |emlGmap x - emlGmap y| ≤ (1/2) * |x - y| := by
      unfold emlGmap;
      cases abs_cases ( x - y ) <;> cases abs_cases ( Real.exp 1 - Real.log x - ( Real.exp 1 - Real.log y ) ) <;> ( push_cast [ * ] at * );
      · by_cases hxy : x = y;
        · aesop;
        · cases lt_or_gt_of_ne hxy <;> linarith [ Real.log_lt_log ( by linarith ) ( by linarith : x > y ) ];
      · by_contra h_contra;
        have := exists_deriv_eq_slope ( Real.log ) ( show x > y by exact lt_of_le_of_ne ( by linarith ) ( by rintro rfl; linarith ) );
        exact absurd ( this ( continuousOn_of_forall_continuousAt fun z hz => Real.continuousAt_log ( by linarith [ hz.1 ] ) ) ( fun z hz => DifferentiableAt.differentiableWithinAt ( Real.differentiableAt_log ( by linarith [ hz.1 ] ) ) ) ) ( by rintro ⟨ c, ⟨ h₁, h₂ ⟩, h₃ ⟩ ; rw [ eq_div_iff ] at h₃ <;> norm_num at * <;> nlinarith [ inv_mul_cancel₀ ( by linarith : c ≠ 0 ) ] );
      · -- Apply the mean value theorem to the interval $[x, y]$.
        obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo x y, deriv Real.log c = (Real.log y - Real.log x) / (y - x) := by
          apply_rules [ exists_deriv_eq_slope ] ; linarith;
          · exact continuousOn_of_forall_continuousAt fun z hz => Real.continuousAt_log ( by linarith [ hz.1 ] );
          · exact DifferentiableOn.log differentiableOn_id fun z hz => by linarith [ hz.1 ];
        norm_num at *;
        rw [ inv_eq_one_div, div_eq_div_iff ] at hc <;> nlinarith [ mul_inv_cancel₀ ( by linarith : c ≠ 0 ) ];
      · linarith [ Real.log_lt_log ( by linarith ) ( by linarith : x < y ) ]

/-- [Section: ## V17.A3: σ-EML Strict Monotonicity] -/
theorem sigmaEml_strictMono : StrictMono sigmaEml := by
  refine' fun x y hxy => _;
  unfold sigmaEml;
  gcongr

theorem sigmaEml_tendsto_atTop :
    Tendsto sigmaEml atTop atTop := by
      refine' Filter.tendsto_atTop_atTop.mpr fun b => _;
      use Max.max b 1; intro a ha; simp [sigmaEml];
      cases max_cases b 1 <;> linarith [ Real.add_one_le_exp a, Real.log_le_sub_one_of_pos ( by positivity : 0 < 1 + Real.exp ( -a ) ), Real.exp_pos ( -a ), Real.exp_le_one_iff.mpr ( show -a ≤ 0 by linarith ) ]

theorem sigmaEml_pos_of_ge_one (x : ℝ) (hx : 1 ≤ x) : sigmaEml x > 0 := by
  refine' sub_pos_of_lt ( _ );
  exact lt_of_lt_of_le ( Real.log_lt_sub_one_of_pos ( by positivity ) ( by linarith [ Real.exp_pos ( -x ) ] ) ) ( by linarith [ Real.add_one_le_exp x, Real.exp_pos ( -x ), Real.exp_le_one_iff.2 ( neg_nonpos.2 <| by linarith : -x ≤ 0 ) ] )

theorem sigmaEml_lower_bound (x : ℝ) (hx : 0 ≤ x) :
    sigmaEml x ≥ exp x - log 2 := by
      unfold sigmaEml;
      gcongr;
      linarith [ Real.exp_le_one_iff.2 ( neg_nonpos.2 hx ) ]

/-- For p > 0: (p - ln(p)) - 1 = (p - 1) - ln(p) = D_KL(1 || p)
(the reverse KL divergence from 1 to p). -/
theorem eml_kl_divergence (p : ℝ) (hp : 0 < p) :
    (p - log p) - 1 = (p - 1) - log p := by ring

/-- The reverse KL divergence D_KL(1 || p) = p - 1 - ln(p) ≥ 0. -/
theorem reverse_kl_nonneg (p : ℝ) (hp : 0 < p) :
    p - 1 - log p ≥ 0 := by
  linarith [log_le_sub_one_of_pos hp]

/-- D_KL(1 || p) = 0 iff p = 1. -/
theorem reverse_kl_eq_zero_iff (p : ℝ) (hp : 0 < p) :
    p - 1 - log p = 0 ↔ p = 1 := by
  constructor
  · intro h
    have h1 : p - log p = 1 := by linarith
    exact (sub_log_eq_one_iff p hp).mp h1
  · intro h; rw [h, log_one]; ring

/-- d(1) = e. -/
theorem emlDiag_at_one : emlDiag 1 = exp 1 := by simp [emlDiag, log_one]

/-- d(e) = e^e - 1. -/
theorem emlDiag_at_e : emlDiag (exp 1) = exp (exp 1) - 1 := by simp [emlDiag, log_exp]

/-- For z ≥ 1: d(z) ≥ exp(z) - z. -/
theorem emlDiag_ge_exp_sub (z : ℝ) (hz : 1 ≤ z) :
    emlDiag z ≥ exp z - z := by
  unfold emlDiag
  have : log z ≤ z - 1 := log_le_sub_one_of_pos (by linarith)
  linarith

/-- The diagonal orbit is strictly increasing: d(z) > z for z > 0. -/
theorem emlDiag_orbit_increasing (z : ℝ) (hz : 0 < z) :
    emlDiag z > z := emlDiag_gt_z z hz

/-- Scaling: eml(x + ln(a), y) = a * exp(x) - ln(y) for a > 0. -/
theorem eml_scale_fst (x y : ℝ) (a : ℝ) (ha : 0 < a) :
    eml (x + log a) y = a * exp x - log y := by
  unfold eml; rw [exp_add, exp_log ha]; ring

/-- Scaling: eml(x, a*y) = eml(x, y) - ln(a) for a, y > 0. -/
theorem eml_scale_snd (x y a : ℝ) (ha : 0 < a) (hy : 0 < y) :
    eml x (a * y) = eml x y - log a := by
  unfold eml; rw [log_mul ha.ne' hy.ne']; ring

/-- [Section: ## V17.A7: EML Integral Identity] -/
theorem eml_zero_at_integral_value :
    ∫ y in (1 : ℝ)..exp 1, eml 0 y = exp 1 - 2 := by
      unfold eml; norm_num;
      ring

/-- For x ≥ 0, y ≥ 1: eml(x,y) ≥ eml(0,1) = 1 is FALSE in general.
Instead: eml(x, y) ≥ 1 + x - ln(y). -/
theorem eml_linear_lower (x y : ℝ) :
    eml x y ≥ 1 + x - log y := eml_lower_bound x y

/-- For x ≤ 0, y ≥ 1: eml(x,y) ≤ 1. -/
theorem eml_upper_bound_neg (x y : ℝ) (hx : x ≤ 0) (hy : 1 ≤ y) :
    eml x y ≤ 1 := by
  unfold eml
  have h1 : exp x ≤ 1 := exp_le_one_iff.mpr hx
  have h2 : 0 ≤ log y := log_nonneg hy
  linarith

/-- [Section: ## V17.A9: EML Midpoint Inequality (Convexity Consequence)] -/
theorem eml_midpoint_fst (x₁ x₂ y : ℝ) :
    eml ((x₁ + x₂) / 2) y ≤ (eml x₁ y + eml x₂ y) / 2 := by
      -- By definition of eml, we have:
      unfold eml;
      rw [ show ( x₁ + x₂ ) / 2 = ( x₁ + x₂ ) / 2 by ring, show x₁ = ( x₁ + x₂ ) / 2 + ( x₁ - x₂ ) / 2 by ring, show x₂ = ( x₁ + x₂ ) / 2 - ( x₁ - x₂ ) / 2 by ring, Real.exp_add, Real.exp_sub ];
      norm_num [ Real.exp_add, Real.exp_sub, Real.exp_neg ] ; ring_nf ; norm_num;
      nlinarith [ Real.exp_pos ( x₁ * ( 1 / 2 ) + x₂ * ( 1 / 2 ) ), Real.exp_pos ( x₁ * ( 1 / 2 ) + - ( x₂ * ( 1 / 2 ) ) ), sq_nonneg ( Real.exp ( x₁ * ( 1 / 2 ) + - ( x₂ * ( 1 / 2 ) ) ) - 1 ), Real.exp_neg ( x₁ * ( 1 / 2 ) + - ( x₂ * ( 1 / 2 ) ) ), mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos ( x₁ * ( 1 / 2 ) + - ( x₂ * ( 1 / 2 ) ) ) ) ) ]

/-- The equation exp(z) * z = 1 characterizes the omega constant Ω ≈ 0.5671.
At z = Ω, the diagonal d(Ω) achieves its minimum.
We prove the weaker statement: if exp(z) * z = 1 and z > 0 then d'(z) = 0,
i.e., exp(z) = 1/z. -/
theorem emlDiag_critical_point (z : ℝ) (hz : 0 < z) (heq : exp z * z = 1) :
    exp z = z⁻¹ := by
  field_simp at heq ⊢
  linarith

/-- [Section: ## V17.A11: More Evaluation Points] -/
theorem eml_eval_ln2_2 : eml (log 2) 2 = 2 - log 2 := by
  simp [eml, exp_log (by norm_num : (0:ℝ) < 2)]

theorem eml_eval_2_1 : eml 2 1 = exp 2 := by simp [eml, log_one]

/-- eml(ln(a), a) = a - ln(a) for a > 0. The diagonal in log coordinates. -/
theorem eml_log_diag (a : ℝ) (ha : 0 < a) : eml (log a) a = a - log a := by
  simp [eml, exp_log ha]

/-- [Section: ## V17.A12: EML Difference Quotients] -/
theorem eml_mvt_fst_bound (x₁ x₂ y : ℝ) :
    |eml x₁ y - eml x₂ y| ≤ max (exp x₁) (exp x₂) * |x₁ - x₂| := by
      rw [ eml, eml ];
      cases le_total x₁ x₂ <;> simp_all +decide [ Real.exp_sub, abs_mul, abs_sub_comm ];
      · rw [ abs_of_nonpos, abs_of_nonpos ] <;> norm_num;
        · have := Real.exp_sub x₁ x₂;
          nlinarith [ Real.exp_pos x₁, Real.exp_pos x₂, Real.add_one_le_exp ( x₁ - x₂ ), mul_div_cancel₀ ( Real.exp x₁ ) ( ne_of_gt ( Real.exp_pos x₂ ) ) ];
        · linarith;
        · lia;
      · rw [ abs_of_nonneg ( sub_nonneg_of_le <| Real.exp_le_exp.mpr ‹_› ), mul_comm ];
        rw [ abs_of_nonneg ( sub_nonneg.mpr ‹_› ) ];
        have := Real.exp_sub x₂ x₁;
        nlinarith [ Real.exp_pos x₁, Real.exp_pos x₂, Real.exp_pos ( x₂ - x₁ ), mul_div_cancel₀ ( Real.exp x₂ ) ( ne_of_gt ( Real.exp_pos x₁ ) ), Real.add_one_le_exp ( x₂ - x₁ ) ]

/-- The Shannon entropy of a two-outcome distribution (p, 1-p) is
H(p) = -p*ln(p) - (1-p)*ln(1-p). The EML diagonal evaluated at p gives
d(p) = exp(p) - ln(p). The relationship: for p ∈ (0,1),
d(p) + d(1-p) = exp(p) + exp(1-p) + H(p)/(p*(1-p)) is FALSE in general.
Instead we just note: d(p) ≥ 2 while H(p) ≤ ln(2). -/
theorem eml_entropy_bound (p : ℝ) (hp : 0 < p) :
    emlDiag p ≥ 2 := emlDiag_ge_two p hp

/-- eml(eml(x, exp(y)), 1) = exp(exp(x) - y). -/
theorem eml_compose_exp (x y : ℝ) :
    eml (eml x (exp y)) 1 = exp (exp x - y) := by
  simp [eml, log_one, log_exp]

/-- eml(0, exp(eml(0, y))) = log(y) for y > 0. -/
theorem eml_compose_inv (y : ℝ) (hy : 0 < y) :
    eml 0 (exp (eml 0 y)) = log y := by
  simp [eml, log_exp]

/-- The sublevel set {y > 0 : eml(x, y) ≤ c} = {y > 0 : ln(y) ≥ exp(x) - c}
= {y : y ≥ exp(exp(x) - c)} when exp(x) - c ≥ 0. -/
theorem eml_sublevel_snd (x c y : ℝ) (hy : 0 < y) :
    eml x y ≤ c ↔ log y ≥ exp x - c := by
  simp [eml]; constructor <;> intro h <;> linarith

end