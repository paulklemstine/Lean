/-! # CatalogBuild.EML.V12.IntegralTheory

Auto-generated from theorem catalog database.
Domain: EML/V12
Declarations: 10
-/

import Mathlib

noncomputable section

/-- [Section: ## Section 1: Integral of σ on [0,1]] -/
theorem integral_id_01 : ∫ t in (0:ℝ)..1, t = 1 / 2 := by
  norm_num +zetaDelta at *



/-- [Section: # CatalogBuild.EML.V12.IntegralTheory
Auto-generated from theorem catalog database.
Domain: EML/V12
Declarations: 11] -/
theorem integral_selfPair_01 :
    ∫ t in (0:ℝ)..1, emlSelfPair t = Real.exp 1 - 3 / 2 := by
      unfold emlSelfPair;
      norm_num;
      ring



/-- σ is integrable on any interval. -/
theorem emlSelfPair_intervalIntegrable (a b : ℝ) :
    IntervalIntegrable emlSelfPair MeasureTheory.volume a b := by
  exact (Real.continuous_exp.sub continuous_id).intervalIntegrable a b



/-- [Section: ## Section 3: Antiderivative of σ] -/
theorem emlSelfPair_antideriv (x : ℝ) :
    HasDerivAt (fun t => Real.exp t - t ^ 2 / 2) (emlSelfPair x) x := by
      simpa using HasDerivAt.sub ( Real.hasDerivAt_exp x ) ( HasDerivAt.div_const ( hasDerivAt_pow 2 x ) 2 )



theorem integral_selfPair_exact (a : ℝ) :
    ∫ t in (0:ℝ)..a, emlSelfPair t = Real.exp a - a ^ 2 / 2 - 1 := by
      convert intervalIntegral.integral_eq_sub_of_hasDerivAt _ _ using 1;
      rotate_left;
      exacts [ by infer_instance, fun x => Real.exp x - x ^ 2 / 2, fun x hx => emlSelfPair_antideriv x, emlSelfPair_intervalIntegrable 0 a, by norm_num ]



/-- [Section: ## Section 4: Integral Bounds] -/
theorem integral_selfPair_ge_length (a : ℝ) (ha : 0 ≤ a) :
    ∫ t in (0:ℝ)..a, emlSelfPair t ≥ a := by
      -- Since σ(t) ≥ 1 for all t (from exp(t) ≥ 1 + t), the integral ∫₀ᵃ σ(t) dt ≥ ∫₀ᵃ 1 dt = a.
      have h_int_ge_a : ∫ t in (0:ℝ)..a, emlSelfPair t ≥ ∫ t in (0:ℝ)..a, 1 := by
        apply_rules [ intervalIntegral.integral_mono_on ];
        · norm_num;
        · exact?;
        · exact fun x hx => by unfold emlSelfPair; linarith [ Real.add_one_le_exp x ] ;
      aesop



/-- σ² is integrable on any interval. -/
theorem emlSelfPair_sq_integrable (a b : ℝ) :
    IntervalIntegrable (fun t => emlSelfPair t ^ 2) MeasureTheory.volume a b :=
  (Real.continuous_exp.sub continuous_id).pow 2 |>.intervalIntegrable a b



theorem integral_selfPair_sq_ge (a : ℝ) (ha : 0 ≤ a) :
    ∫ t in (0:ℝ)..a, emlSelfPair t ^ 2 ≥ a := by
      rw [ intervalIntegral.integral_of_le ha ];
      refine' le_trans _ ( MeasureTheory.setIntegral_mono_on _ _ measurableSet_Ioc fun x hx => one_le_pow₀ <| show 1 ≤ emlSelfPair x from _ ) <;> norm_num [ ha ];
      · exact Continuous.integrableOn_Ioc ( by exact Continuous.pow ( by exact Continuous.sub ( Real.continuous_exp ) continuous_id' ) _ );
      · exact le_tsub_of_add_le_left ( by linarith [ Real.add_one_le_exp x, hx.1 ] )



/-- exp(x) − 1 − x ≥ 0 for all x. -/
theorem exp_remainder_nonneg (x : ℝ) : Real.exp x - 1 - x ≥ 0 := by
  linarith [Real.add_one_le_exp x]



/-- [Section: ## Section 5: Exponential remainder integral] -/
theorem integral_exp_remainder_01 :
    ∫ t in (0:ℝ)..1, (Real.exp t - 1 - t) = Real.exp 1 - 5 / 2 := by
      rw [ intervalIntegral.integral_sub, intervalIntegral.integral_sub ] <;> norm_num ; ring



end
