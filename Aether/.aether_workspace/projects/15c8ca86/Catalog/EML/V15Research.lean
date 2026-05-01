import Mathlib

/-! # CatalogBuild.EML.V15Research

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 37
-/

noncomputable section

/-- The EML operator: eml(x, y) = exp(x) − ln(y). -/
def eml15 (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal map: d(z) = exp(z) − ln(z). -/
def diag15 (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- The off-diagonal g-map: g(z) = e − ln(z). -/
def gmap15 (z : ℝ) : ℝ := Real.exp 1 - Real.log z

/-- The σ-EML activation function: σ_eml(x) = exp(x) - ln(1 + exp(-x)). -/
def sigma_eml15 (x : ℝ) : ℝ := Real.exp x - Real.log (1 + Real.exp (-x))

/-- [Section: ========================================================================
Part I: Convexity and Concavity
========================================================================] -/
theorem eml15_convex_fst (x₁ x₂ y : ℝ) :
    eml15 ((x₁ + x₂) / 2) y ≤ (eml15 x₁ y + eml15 x₂ y) / 2 := by
  unfold eml15;
  -- By the properties of the exponential function, we know that $\exp((x₁ + x₂) / 2) \leq (\exp(x₁) + \exp(x₂)) / 2$.
  have h_exp : Real.exp ((x₁ + x₂) / 2) ≤ (Real.exp x₁ + Real.exp x₂) / 2 := by
    rw [ show ( x₁ + x₂ ) / 2 = ( x₁ + x₂ ) / 2 by ring, Real.exp_half ];
    rw [ Real.sqrt_le_left ] <;> nlinarith [ sq_nonneg ( Real.exp x₁ - Real.exp x₂ ), Real.exp_pos x₁, Real.exp_pos x₂, Real.exp_add x₁ x₂ ];
  linarith

/-- [Section: # CatalogBuild.EML.V15Research
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 37] -/
theorem eml15_concave_snd (x y₁ y₂ : ℝ) (hy₁ : 0 < y₁) (hy₂ : 0 < y₂) :
    eml15 x ((y₁ + y₂) / 2) ≤ (eml15 x y₁ + eml15 x y₂) / 2 := by
  unfold eml15;
  linarith [ Real.log_le_log ( by positivity ) ( show ( y₁ + y₂ ) / 2 ≥ Real.sqrt ( y₁ * y₂ ) by nlinarith [ sq_nonneg ( y₁ - y₂ ), Real.mul_self_sqrt ( mul_nonneg hy₁.le hy₂.le ) ] ), Real.log_sqrt ( mul_nonneg hy₁.le hy₂.le ), Real.log_mul hy₁.ne' hy₂.ne' ]

/-- [Section: ========================================================================
Part II: g-Map Fixed Point Uniqueness
========================================================================] -/
theorem gmap15_strictAnti : StrictAntiOn gmap15 (Set.Ioi 0) := by
  exact fun x hx y hy hxy => sub_lt_sub_left ( Real.log_lt_log hx hxy ) _

theorem gmap15_fixed_point_unique (z₁ z₂ : ℝ) (hz₁ : 0 < z₁) (hz₂ : 0 < z₂)
    (hfp₁ : gmap15 z₁ = z₁) (hfp₂ : gmap15 z₂ = z₂) : z₁ = z₂ := by
  exact le_antisymm ( le_of_not_gt fun h => by linarith [ gmap15_strictAnti hz₂ hz₁ h ] ) ( le_of_not_gt fun h => by linarith [ gmap15_strictAnti hz₁ hz₂ h ] )

theorem h_strictMono : StrictMonoOn (fun z => z + Real.log z) (Set.Ioi 0) := by
  exact fun x hx y hy hxy => add_lt_add_of_lt_of_le hxy ( Real.log_le_log hx hxy.le )

theorem fixed_point_eq_unique (z₁ z₂ : ℝ) (hz₁ : 0 < z₁) (hz₂ : 0 < z₂)
    (heq₁ : z₁ + Real.log z₁ = Real.exp 1) (heq₂ : z₂ + Real.log z₂ = Real.exp 1) :
    z₁ = z₂ := by
  exact StrictMonoOn.injOn ( show StrictMonoOn ( fun z => z + Real.log z ) ( Set.Ioi 0 ) from by exact fun x hx y hy hxy => add_lt_add_of_lt_of_le hxy <| Real.log_le_log hx hxy.le ) hz₁ hz₂ <| by linarith;

/-- [Section: ========================================================================
Part III: EML Algebraic Identities
========================================================================] -/
theorem eml15_sum (x y z : ℝ) :
    eml15 x y + eml15 x z = 2 * Real.exp x - Real.log y - Real.log z := by
  unfold eml15; ring;

theorem eml15_prod_snd (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml15 x (y * z) = eml15 x y + eml15 x z - Real.exp x := by
  unfold eml15; rw [ Real.log_mul hy.ne' hz.ne' ] ; ring;

theorem eml15_reciprocal (x y : ℝ) (hy : 0 < y) :
    eml15 x (1/y) = eml15 x y + 2 * Real.log y := by
  unfold eml15; simp +decide [ Real.log_div, hy.ne' ] ; ring;

theorem eml15_zero_one : eml15 0 1 = 1 := by
  unfold eml15; norm_num;

theorem eml15_neg_fst (x y : ℝ) :
    eml15 (-x) y = 1 / Real.exp x - Real.log y := by
  unfold eml15;
  rw [ one_div, Real.exp_neg ]

theorem eml15_symmetrized_formula (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    eml15 (Real.log x) y + eml15 (Real.log y) x = (x - Real.log y) + (y - Real.log x) := by
  unfold eml15; rw [ Real.exp_log hx, Real.exp_log hy ] ;

/-- [Section: ========================================================================
Part IV: Bregman Divergence Connection
========================================================================] -/
theorem eml15_bregman_form (p : ℝ) (_hp : 0 < p) :
    p - Real.log p = (p - 1) - (Real.log p - Real.log 1) + 1 := by
  norm_num;
  ring

theorem eml15_bregman_nonneg (p : ℝ) (hp : 0 < p) :
    p - Real.log p - 1 ≥ 0 := by
  linarith [ Real.log_le_sub_one_of_pos hp ]

/-- [Section: ========================================================================
Part V: g-Map Dynamics
========================================================================] -/
theorem gmap15_at_two_gt_two : gmap15 2 > 2 := by
  exact lt_tsub_iff_left.mpr <| Real.exp_one_gt_d9.trans_le' <| by have := Real.log_two_lt_d9; norm_num at *; linarith;

theorem gmap15_at_e_lt_e : gmap15 (Real.exp 1) < Real.exp 1 := by
  unfold gmap15; norm_num

theorem gmap15_maps_interval (z : ℝ) (hz_lo : 2 ≤ z) (hz_hi : z ≤ Real.exp 1) :
    gmap15 z ≥ Real.exp 1 - 1 ∧ gmap15 z ≤ Real.exp 1 - Real.log 2 := by
  constructor;
  · unfold gmap15;
    linarith [ Real.log_le_iff_le_exp ( by linarith ) |>.2 hz_hi ];
  · exact sub_le_sub_left ( Real.log_le_log ( by linarith ) ( by linarith ) ) _

theorem gmap15_orbit_bounded (z : ℝ) (hz : 2 ≤ z) :
    gmap15 z ≤ Real.exp 1 - Real.log 2 := by
  exact sub_le_sub_left ( Real.log_le_log ( by positivity ) hz ) _

/-- [Section: ========================================================================
Part VI: EML Derivative Properties (stated as inequalities)
========================================================================] -/
theorem eml15_lipschitz_x (x₁ x₂ y : ℝ) :
    |eml15 x₁ y - eml15 x₂ y| ≤ Real.exp (max x₁ x₂) * |x₁ - x₂| := by
  unfold eml15;
  cases' max_cases x₁ x₂ with h h <;> simp_all +decide [ abs_sub_comm ];
  · rw [ abs_of_nonneg ( sub_nonneg.mpr <| Real.exp_le_exp.mpr h ), abs_of_nonneg ( sub_nonneg.mpr h ) ];
    have := Real.exp_sub x₂ x₁;
    nlinarith [ Real.exp_pos x₁, Real.exp_pos x₂, Real.exp_le_exp.2 h, mul_div_cancel₀ ( Real.exp x₂ ) ( ne_of_gt ( Real.exp_pos x₁ ) ), Real.add_one_le_exp ( x₂ - x₁ ) ];
  · rw [ abs_of_nonpos, abs_of_nonpos ] <;> nlinarith [ Real.exp_pos x₁, Real.exp_pos x₂, Real.exp_le_exp.2 h.1, Real.add_one_le_exp ( x₁ - x₂ ), Real.add_one_le_exp ( x₂ - x₁ ), Real.exp_sub x₁ x₂, Real.exp_sub x₂ x₁, mul_div_cancel₀ ( Real.exp x₁ ) ( ne_of_gt ( Real.exp_pos x₂ ) ), mul_div_cancel₀ ( Real.exp x₂ ) ( ne_of_gt ( Real.exp_pos x₁ ) ) ]

theorem eml15_lipschitz_y (x y₁ y₂ a : ℝ) (ha : 0 < a) (hy₁ : a ≤ y₁) (hy₂ : a ≤ y₂) :
    |eml15 x y₁ - eml15 x y₂| ≤ (1/a) * |y₁ - y₂| := by
  -- By the mean value theorem, there exists some $c$ between $y₁$ and $y₂$ such that $\log(y₂) - \log(y₁) = \frac{1}{c} (y₂ - y₁)$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Icc (min y₁ y₂) (max y₁ y₂), Real.log y₂ - Real.log y₁ = (1 / c) * (y₂ - y₁) := by
    cases eq_or_ne y₁ y₂ <;> simp_all +decide [ mul_comm ];
    cases' lt_or_gt_of_ne ‹_› with h h;
    · have := exists_deriv_eq_slope ( Real.log ) h;
      exact this ( continuousOn_of_forall_continuousAt fun x hx => Real.continuousAt_log ( by linarith [ hx.1 ] ) ) ( fun x hx => DifferentiableAt.differentiableWithinAt ( Real.differentiableAt_log ( by linarith [ hx.1 ] ) ) ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, ⟨ Or.inl hc₁.1.le, Or.inr hc₁.2.le ⟩, by rw [ eq_div_iff ] at hc₂ <;> norm_num at * <;> linarith ⟩;
    · have := exists_deriv_eq_slope ( Real.log ) h;
      exact this ( continuousOn_of_forall_continuousAt fun x hx => Real.continuousAt_log ( by linarith [ hx.1 ] ) ) ( fun x hx => DifferentiableAt.differentiableWithinAt ( Real.differentiableAt_log ( by linarith [ hx.1 ] ) ) ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, ⟨ Or.inr hc₁.1.le, Or.inl hc₁.2.le ⟩, by rw [ eq_div_iff ] at hc₂ <;> norm_num at * <;> linarith ⟩;
  unfold eml15;
  simp_all +decide [ abs_sub_comm, mul_comm ];
  exact mul_le_mul_of_nonneg_left ( inv_anti₀ ( by linarith ) ( by cases abs_cases c <;> cases hc.1.1 <;> cases hc.1.2 <;> linarith ) ) ( abs_nonneg _ )

/-- [Section: ========================================================================
Part VII: New Inequalities
========================================================================] -/
theorem eml15_neutral_point : eml15 0 (Real.exp 1) = 0 := by
  exact sub_eq_zero.mpr <| by norm_num

theorem eml15_symmetrized_ge_two (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    (a - Real.log b) + (b - Real.log a) ≥ 2 := by
  linarith [ Real.log_le_sub_one_of_pos ha, Real.log_le_sub_one_of_pos hb ]

theorem diag15_ge_two (z : ℝ) (hz : 0 < z) : diag15 z ≥ 2 := by
  unfold diag15;
  linarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ]

theorem eml15_power_scale (x y : ℝ) (n : ℕ) (_hy : 0 < y) :
    eml15 (n * x) (y ^ n) = Real.exp (n * x) - n * Real.log y := by
  unfold eml15; aesop;

/-- [Section: ========================================================================
Part VIII: σ-EML Extended Properties
========================================================================] -/
theorem sigma_eml15_ge_exp_minus_ln2 (x : ℝ) :
    sigma_eml15 x ≥ Real.exp x - Real.log 2 - max (-x) 0 := by
  -- We'll use the fact that $Real.log (1 + Real.exp (-x)) \leq Real.log 2 + max (-x) 0$.
  have hlog : Real.log (1 + Real.exp (-x)) ≤ Real.log 2 + max (-x) 0 := by
    cases max_cases ( -x ) 0 <;> rw [ Real.log_le_iff_le_exp ( by positivity ) ];
    · norm_num [ Real.exp_add, Real.exp_log, ‹_› ];
      linarith [ Real.add_one_le_exp ( -x ) ];
    · norm_num [ Real.exp_add, Real.exp_log, ‹_› ];
      linarith [ Real.exp_le_one_iff.2 ( show -x ≤ 0 by linarith ) ];
  unfold sigma_eml15; ring_nf at *; linarith;

theorem sigma_eml15_softplus (x : ℝ) :
    sigma_eml15 x = Real.exp x - Real.log (1 + Real.exp (-x)) := by
  rfl

theorem sigma_eml15_strictMono : StrictMono sigma_eml15 := by
  refine' fun x y hxy => sub_lt_sub _ _;
  · exact Real.exp_lt_exp.2 hxy;
  · gcongr

theorem sigma_eml15_large_x (x : ℝ) (hx : 0 ≤ x) :
    sigma_eml15 x ≥ Real.exp x - Real.log 2 := by
  exact sub_le_sub_left ( Real.log_le_log ( by positivity ) ( by linarith [ Real.exp_le_one_iff.mpr ( neg_nonpos.mpr hx ) ] ) ) _

/-- [Section: ========================================================================
Part IX: EML and the Lambert W Connection
========================================================================] -/
theorem gmap15_lambert_connection (z : ℝ) (hz : 0 < z) :
    z + Real.log z = Real.exp 1 ↔ z * Real.exp z = Real.exp (Real.exp 1) := by
  apply Iff.intro;
  · intro h;
    rw [ ← h, Real.exp_add, mul_comm, Real.exp_log hz ];
  · intro h;
    have := congr_arg Real.log h ; norm_num [ Real.log_mul, Real.exp_ne_zero, hz.ne' ] at this;
    grind

theorem eml15_at_fixed_point (z : ℝ) (_hz : 0 < z) (hfp : gmap15 z = z) :
    eml15 1 z = z := by
  unfold eml15 gmap15 at * ; linarith

/-- [Section: ========================================================================
Part X: EML Integral Estimates
========================================================================] -/
theorem eml15_at_exp (t : ℝ) : eml15 0 (Real.exp t) = 1 - t := by
  unfold eml15; norm_num

theorem diag15_at_one : diag15 1 = Real.exp 1 := by
  unfold diag15; norm_num

theorem diag15_at_e : diag15 (Real.exp 1) = Real.exp (Real.exp 1) - 1 := by
  unfold diag15; norm_num

end