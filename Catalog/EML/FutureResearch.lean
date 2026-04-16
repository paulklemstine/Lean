/-! # CatalogBuild.EML.FutureResearch

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 37
-/

import Mathlib

noncomputable section

/-- The real EML operator: eml(x, y) = exp(x) - ln(y). -/
def emlF (x y : ℝ) : ℝ := Real.exp x - Real.log y



/-- The one-minus-log map: g(x) = 1 - ln(x). -/
def oml (x : ℝ) : ℝ := 1 - Real.log x



/-- The right-action map: T_c(x) = EML(x, c) = exp(x) - ln(c). -/
def emlT (c : ℝ) (x : ℝ) : ℝ := Real.exp x - Real.log c



/-- The diagonal map has derivative exp(z) - 1/z. -/
theorem emlDiag_deriv (z : ℝ) (hz : z ≠ 0) :
    HasDerivAt emlDiag (Real.exp z - z⁻¹) z := by
  unfold emlDiag
  exact (Real.hasDerivAt_exp z).sub (Real.hasDerivAt_log hz)



/-- The second derivative of the diagonal map is exp(z) + 1/z². -/
theorem emlDiag_second_deriv_pos (z : ℝ) (hz : 0 < z) :
    Real.exp z + z⁻¹ ^ 2 > 0 := by
  positivity



/-- [Section: # CatalogBuild.EML.FutureResearch
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 37] -/
theorem emlDiag_convex : ConvexOn ℝ (Ioi 0) emlDiag := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_Ioi ];
  · exact ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx );
  · exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.log differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx );
  · refine' DifferentiableOn.congr _ _;
    exacts [ fun x => Real.exp x - x⁻¹, DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( differentiableOn_id.inv fun x hx => ne_of_gt <| interior_subset hx ), fun x hx => by simpa using HasDerivAt.deriv <| emlDiag_deriv x <| ne_of_gt <| interior_subset hx ];
  · -- The second derivative of $emlDiag$ is $exp(z) + 1/z^2$, which is positive for all $z > 0$.
    have h_second_deriv : ∀ z > 0, deriv^[2] emlDiag z = Real.exp z + 1 / z^2 := by
      have h_second_deriv : ∀ z > 0, deriv^[2] emlDiag z = deriv (fun z => Real.exp z - 1 / z) z := by
        exact fun z hz => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds hz ] with x hx using by simpa [ Real.differentiableAt_exp, hx.ne', Real.differentiableAt_log ] using HasDerivAt.deriv ( emlDiag_deriv x hx.ne' ) );
      intro z hz; rw [ h_second_deriv z hz ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hz.ne' ];
    exact fun x hx => h_second_deriv x ( interior_subset hx ) ▸ add_nonneg ( Real.exp_nonneg _ ) ( one_div_nonneg.mpr ( sq_nonneg _ ) )



theorem emlDiag_gt_id (z : ℝ) (hz : 0 < z) : emlDiag z > z := by
  unfold emlDiag;
  -- We'll use the fact that $e^z \geq 1 + z + \frac{z^2}{2}$ for all $z \geq 0$.
  have h_exp_ineq : ∀ z : ℝ, 0 ≤ z → Real.exp z ≥ 1 + z + z^2 / 2 := by
    exact fun z a => quadratic_le_exp_of_nonneg a;
  nlinarith [ h_exp_ineq z hz.le, Real.log_le_sub_one_of_pos hz ]



theorem emlDiag_ge_two (z : ℝ) (hz : 0 < z) : emlDiag z ≥ 2 := by
  exact le_tsub_of_add_le_left ( by have := Real.add_one_le_exp z; have := Real.log_le_sub_one_of_pos hz; linarith )



theorem emlDiag_tendsto_atTop : Tendsto emlDiag atTop atTop := by
  -- Since $exp(z)$ grows much faster than $ln(z)$, we can show that $exp(z) - ln(z)$ tends to infinity as $z$ tends to infinity.
  have h_exp_growth : Filter.Tendsto (fun z : ℝ => Real.exp z - z) Filter.atTop Filter.atTop := by
    -- We can use the fact that $e^z - z = e^z (1 - \frac{z}{e^z})$ and show that $\frac{z}{e^z}$ tends to $0$ as $z$ tends to infinity.
    have h_frac : Filter.Tendsto (fun z : ℝ => z / Real.exp z) Filter.atTop (nhds 0) := by
      simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1;
    have h_exp_growth : Filter.Tendsto (fun z : ℝ => Real.exp z * (1 - z / Real.exp z)) Filter.atTop Filter.atTop := by
      apply Filter.Tendsto.atTop_mul_pos;
      exacts [ zero_lt_one, Real.tendsto_exp_atTop, by simpa using h_frac.const_sub 1 ];
    simpa only [ mul_sub, mul_one, mul_div_cancel₀ _ ( ne_of_gt ( Real.exp_pos _ ) ) ] using h_exp_growth;
  refine' Filter.tendsto_atTop_atTop.mpr fun b => _;
  exact Filter.eventually_atTop.mp ( h_exp_growth.eventually_ge_atTop b ) |> fun ⟨ i, hi ⟩ ↦ ⟨ Max.max i 1, fun z hz ↦ by have := hi z ( le_trans ( le_max_left _ _ ) hz ) ; exact le_trans this ( sub_le_sub_left ( show Real.log z ≤ z by linarith [ Real.log_le_sub_one_of_pos ( by linarith [ le_max_right i 1 ] : 0 < z ), le_max_right i 1 ] ) _ ) ⟩



/-- g(1) = 1: the point x = 1 is a fixed point of g. -/
theorem oml_fixed_one : oml 1 = 1 := by
  simp [oml, Real.log_one]



/-- g'(x) = -1/x, so g'(1) = -1. -/
theorem oml_deriv (x : ℝ) (hx : x ≠ 0) :
    HasDerivAt oml (-x⁻¹) x := by
  unfold oml
  have h := (hasDerivAt_const x (1:ℝ)).sub (Real.hasDerivAt_log hx)
  simp at h
  exact h



/-- g(g(x)) = 1 - ln(1 - ln(x)) for x > 0 with 1 - ln(x) > 0. -/
theorem oml_compose (x : ℝ) :
    oml (oml x) = 1 - Real.log (1 - Real.log x) := by
  simp [oml]



/-- g(e) = 0. -/
theorem oml_at_e : oml (Real.exp 1) = 0 := by
  simp [oml, Real.log_exp]



/-- g(1/e) = 2. -/
theorem oml_at_inv_e : oml (Real.exp (-1)) = 2 := by
  simp [oml, Real.log_exp]; ring



theorem oml_unique_fixed_point (x : ℝ) (hx : 0 < x) (hfx : oml x = x) : x = 1 := by
  by_contra hx_ne_one;
  -- Since $x \neq 1$, we have $x > 1$ or $x < 1$.
  by_cases hx_gt_one : x > 1;
  · unfold oml at hfx;
    linarith [ Real.log_pos hx_gt_one ];
  · exact hx_ne_one ( by linarith [ Real.log_lt_sub_one_of_pos hx ( by aesop ), show oml x = 1 - Real.log x from rfl ] )



/-- T_1(x) = exp(x). -/
theorem emlT_one (x : ℝ) : emlT 1 x = Real.exp x := by
  simp [emlT, Real.log_one]



/-- T_{exp(c)}(x) = exp(x) - c. -/
theorem emlT_exp (c x : ℝ) : emlT (Real.exp c) x = Real.exp x - c := by
  simp [emlT, Real.log_exp]



theorem emlT_noncomm : ∃ x : ℝ, emlT 1 (emlT (Real.exp 1) x) ≠ emlT (Real.exp 1) (emlT 1 x) := by
  use 0; norm_num [ emlT ];
  exact ne_of_lt ( by have := Real.exp_one_gt_d9.le; norm_num1 at *; linarith )



/-- T_c is strictly monotone for any c > 0. -/
theorem emlT_strictMono (c : ℝ) (_hc : 0 < c) : StrictMono (emlT c) := by
  intro a b hab
  simp only [emlT]
  linarith [Real.exp_strictMono hab]



theorem emlT_one_no_fixed_point (x : ℝ) : emlT 1 x ≠ x := by
  exact fun hx => by have := Real.exp_pos x; unfold emlT at hx; norm_num at hx; linarith [ Real.add_one_le_exp x ] ;



theorem emlPhi_no_symmetric_fixed (x : ℝ) (hx : 0 < x) :
    emlPhi (x, x) ≠ (x, x) := by
      exact ne_of_apply_ne Prod.fst ( ne_of_gt <| by simpa [ emlF, emlDiag ] using emlDiag_gt_id x hx )



theorem emlPhi_fst_pos (x y : ℝ) (hx : 0 ≤ x) (hy : 0 < y) (hy1 : y ≤ 1) :
    (emlPhi (x, y)).1 > 0 := by
      exact sub_pos.mpr <| lt_of_le_of_lt ( Real.log_le_sub_one_of_pos hy ) <| by linarith [ Real.add_one_le_exp x ] ;



theorem triple_exp_not_depth2 :
    ∀ a b c d : ℝ,
    (fun x => Real.exp (a * Real.exp (b * x + c) + d)) ≠
    (fun x => Real.exp (Real.exp (Real.exp x))) := by
      intro a b c d;
      -- By contradiction, assume there exist constants $a, b, c, d$ such that $f(x) = \exp(a \exp(bx + c) + d)$ for all $x$.
      by_contra h_contra
      have h_eq : ∀ x, a * Real.exp (b * x + c) + d = Real.exp (Real.exp x) := by
        exact fun x => by simpa using congr_fun h_contra x;
      -- Consider the limit of the ratio $\frac{f(x)}{e^{e^x}}$ as $x \to \infty$.
      have h_limit : Filter.Tendsto (fun x => (a * Real.exp (b * x + c) + d) / Real.exp (Real.exp x)) Filter.atTop (nhds 0) := by
        -- We'll use the fact that $e^{bx + c}$ grows much slower than $e^{e^x}$.
        have h_exp_growth : Filter.Tendsto (fun x => Real.exp (b * x + c) / Real.exp (Real.exp x)) Filter.atTop (nhds 0) := by
          norm_num [ ← Real.exp_sub ];
          -- We can factor out $e^x$ and use the fact that $e^x$ grows faster than any linear function.
          have h_exp_growth : Filter.Tendsto (fun x => Real.exp x * (b * x / Real.exp x + c / Real.exp x - 1)) Filter.atTop Filter.atBot := by
            -- We'll use the fact that $b * x / \exp x$ and $c / \exp x$ tend to $0$ as $x \to \infty$.
            have h_zero : Filter.Tendsto (fun x => b * x / Real.exp x) Filter.atTop (nhds 0) ∧ Filter.Tendsto (fun x => c / Real.exp x) Filter.atTop (nhds 0) := by
              exact ⟨ by simpa [ Real.exp_neg, mul_div_assoc ] using tendsto_const_nhds.mul ( Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1 ), by simpa [ Real.exp_neg ] using tendsto_const_nhds.div_atTop ( Real.tendsto_exp_atTop ) ⟩;
            apply Filter.Tendsto.atTop_mul_neg;
            exacts [ show -1 < 0 by norm_num, Real.tendsto_exp_atTop, by simpa using Filter.Tendsto.sub ( h_zero.1.add h_zero.2 ) tendsto_const_nhds ];
          exact h_exp_growth.congr fun x => by rw [ mul_sub, mul_add, mul_div_cancel₀ _ ( ne_of_gt ( Real.exp_pos x ) ), mul_div_cancel₀ _ ( ne_of_gt ( Real.exp_pos x ) ) ] ; ring;
        simpa [ add_div, mul_div_assoc ] using Filter.Tendsto.add ( h_exp_growth.const_mul a ) ( tendsto_const_nhds.div_atTop ( Real.tendsto_exp_atTop.comp ( Real.tendsto_exp_atTop ) ) );
      aesop



/-- K_EML(e) = 1: eml(1, 1) = exp(1) - ln(1) = e. -/
theorem keml_e : emlF 1 1 = Real.exp 1 := by
  simp [emlF, Real.log_one]



/-- K_EML(0) = 3: eml(1, eml(eml(1,1), 1)) = 0. -/
theorem keml_zero : emlF 1 (emlF (emlF 1 1) 1) = 0 := by
  simp [emlF, Real.log_one, Real.log_exp]



/-- K_EML(e-1) = 2: eml(1, eml(1,1)) = e - (e - 1) ... wait.
Actually: eml(1, e) = exp(1) - ln(e) = e - 1. -/
theorem keml_e_minus_1 : emlF 1 (emlF 1 1) = Real.exp 1 - 1 := by
  simp [emlF, Real.log_one, Real.log_exp]



/-- K_EML(e^e) = 2: eml(eml(1,1), 1) = exp(e). -/
theorem keml_exp_e : emlF (emlF 1 1) 1 = Real.exp (Real.exp 1) := by
  simp [emlF, Real.log_one]



/-- K_EML(e^(e^e)) = 3: eml(eml(eml(1,1), 1), 1) = exp(exp(e)). -/
theorem keml_exp_exp_e : emlF (emlF (emlF 1 1) 1) 1 = Real.exp (Real.exp (Real.exp 1)) := by
  simp [emlF, Real.log_one]



/-- K_EML(e^e - e) = 3: eml(eml(1,1), eml(eml(1,1),1)) = e^e - e. -/
theorem keml_exp_e_minus_e :
    emlF (emlF 1 1) (emlF (emlF 1 1) 1) = Real.exp (Real.exp 1) - Real.exp 1 := by
  simp [emlF, Real.log_one, Real.log_exp]



/-- Scaling law: EML(x, y·z) = EML(x, y) - ln(z) for y, z > 0. -/
theorem emlF_scale (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    emlF x (y * z) = emlF x y - Real.log z := by
  simp only [emlF]
  rw [Real.log_mul (ne_of_gt hy) (ne_of_gt hz)]
  ring



/-- Translation: EML(x + c, y) = exp(c) · EML_shift, more precisely
EML(x + c, y) = exp(c) · exp(x) - ln(y). -/
theorem emlF_translate_first (x c y : ℝ) :
    emlF (x + c) y = Real.exp c * Real.exp x - Real.log y := by
  simp [emlF, Real.exp_add, mul_comm]



theorem emlF_zero_reciprocal (y : ℝ) (_hy : 0 < y) :
    emlF 0 y + emlF 0 (y⁻¹) = 2 := by
      unfold emlF
      simp
      norm_num



/-- EML(x, 1) ≥ 1 + x (exponential lower bound). -/
theorem emlF_one_ge (x : ℝ) : emlF x 1 ≥ 1 + x := by
  simp [emlF, Real.log_one]
  linarith [Real.add_one_le_exp x]



/-- EML(x, y) ≥ 1 + x - ln(y) for any y > 0. -/
theorem emlF_general_lower (x y : ℝ) (_hy : 0 < y) :
    emlF x y ≥ 1 + x - Real.log y := by
  simp only [emlF]
  linarith [Real.add_one_le_exp x]



/-- EML(x, exp(x)) ≥ 1 for all x (the "residual" is always ≥ 1). -/
theorem emlF_residual_ge_one (x : ℝ) : emlF x (Real.exp x) ≥ 1 := by
  simp [emlF, Real.log_exp]
  linarith [Real.add_one_le_exp x]



/-- EML is strictly increasing in its first argument. -/
theorem emlF_strictMono_fst (y : ℝ) : StrictMono (fun x => emlF x y) := by
  intro a b hab
  simp only [emlF]
  linarith [Real.exp_strictMono hab]



theorem emlF_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => emlF x y) (Ioi 0) := by
  exact fun y hy z hz hyz => sub_lt_sub_left ( Real.log_lt_log hy hyz ) _



end
