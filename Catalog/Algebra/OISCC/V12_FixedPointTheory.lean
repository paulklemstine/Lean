import Mathlib

/-! # CatalogBuild.Speculative.OISCC.V12_FixedPointTheory

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 13
-/

noncomputable section

/-- The diagonal map d(x) = exp(x) - ln(x). -/
def d_fp (x : ℝ) : ℝ := Real.exp x - Real.log x

/-- The EML operation. -/
def EML_fp (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- [Section: # CatalogBuild.Speculative.OISCC.V12_FixedPointTheory
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 13] -/
theorem d_fp_gt_id (x : ℝ) (hx : 0 < x) : d_fp x > x := by
  unfold d_fp;
  rw [ show x = 1 + ( x - 1 ) by ring, Real.exp_add ] at *;
  nlinarith [ Real.add_one_le_exp 1, Real.add_one_le_exp ( x - 1 ), Real.log_le_sub_one_of_pos hx ]

theorem displacement_ge_one (x : ℝ) (hx : 0 < x) : displacement x ≥ 1 := by
  unfold displacement;
  have := Real.add_one_le_exp ( x - 1 );
  rw [ Real.exp_sub ] at this;
  rw [ le_div_iff₀ ] at this <;> nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos hx ]

theorem displacement_pos (x : ℝ) (hx : 0 < x) : displacement x > 0 := by
  exact lt_of_lt_of_le zero_lt_one ( displacement_ge_one x hx )

theorem displacement_tendsto_atTop :
    Filter.Tendsto displacement atTop atTop := by
  refine' Filter.tendsto_atTop_atTop.mpr fun b ↦ _;
  -- Choose $i$ such that for all $a \geq i$, $e^a > b + a + \ln a$.
  obtain ⟨i, hi⟩ : ∃ i, ∀ a ≥ i, Real.exp a > b + a + Real.log a := by
    -- We'll use the exponential property to find such an $i$. Note that $e^a$ grows faster than any linear function.
    have h_exp_growth : Filter.Tendsto (fun a : ℝ => Real.exp a / a) Filter.atTop Filter.atTop := by
      simpa using Real.tendsto_exp_div_pow_atTop 1;
    -- Since $e^a / a \to \infty$ as $a \to \infty$, there exists an $i$ such that for all $a \geq i$, $e^a / a > 2 + |b|$.
    obtain ⟨i, hi⟩ : ∃ i, ∀ a ≥ i, Real.exp a / a > 2 + |b| := by
      simpa using h_exp_growth.eventually_gt_atTop ( 2 + |b| );
    exact ⟨ Max.max i 2, fun a ha => by have := hi a ( le_trans ( le_max_left _ _ ) ha ) ; rw [ gt_iff_lt ] at this; rw [ lt_div_iff₀ ] at this <;> cases abs_cases b <;> nlinarith [ le_max_right i 2, Real.log_le_sub_one_of_pos ( by linarith [ le_max_right i 2 ] : 0 < a ) ] ⟩;
  exact ⟨ Max.max i 1, fun x hx => by unfold displacement; linarith [ hi x ( le_trans ( le_max_left _ _ ) hx ) ] ⟩

theorem displacement_tendsto_atTop_at_zero :
    Filter.Tendsto displacement (nhdsWithin 0 (Ioi 0)) atTop := by
  -- To prove the limit is infinity, it suffices to show that $-\ln(x) \to \infty$ as $x \to 0^+$.
  suffices h_ln : Filter.Tendsto (fun x : ℝ => -Real.log x) (nhdsWithin 0 (Set.Ioi 0)) Filter.atTop by
    have h_displacement : Filter.Tendsto (fun x : ℝ => Real.exp x - x) (nhdsWithin 0 (Set.Ioi 0)) (nhds 1) := by
      exact tendsto_nhdsWithin_of_tendsto_nhds ( Continuous.tendsto' ( by continuity ) _ _ ( by norm_num ) );
    convert h_displacement.add_atTop h_ln using 2 ; unfold displacement ; ring;
  have := Real.tendsto_log_nhdsGT_zero; aesop;

theorem displacement_convexOn : ConvexOn ℝ (Ioi 0) displacement := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_Ioi ];
  · exact continuousOn_of_forall_continuousAt fun x hx => by exact ContinuousAt.sub ( ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log hx.out.ne' ) ) continuousAt_id;
  · exact DifferentiableOn.sub ( DifferentiableOn.sub ( Real.differentiable_exp.differentiableOn ) ( Real.differentiableOn_log.mono <| by aesop ) ) differentiableOn_id;
  · unfold displacement;
    refine' DifferentiableOn.congr _ _;
    exacts [ fun x => Real.exp x - 1 / x - 1, DifferentiableOn.sub ( DifferentiableOn.sub ( Real.differentiable_exp.differentiableOn ) ( DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx ) ) ( differentiableOn_const _ ), fun x hx => by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, ne_of_gt <| interior_subset hx ] ];
  · -- Let's calculate the second derivative of $d(x)$.
    have h_second_deriv : ∀ x, (0 < x → (deriv^[2] (fun x => Real.exp x - Real.log x - x)) x = (Real.exp x + 1 / x^2)) := by
      have h_second_deriv : ∀ x, (0 < x → (deriv^[2] (fun x => Real.exp x - Real.log x - x)) x = deriv (fun x => Real.exp x - 1 / x - 1) x) := by
        exact fun x hx => Filter.EventuallyEq.deriv_eq <| by filter_upwards [ lt_mem_nhds hx ] with y hy using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hy.ne' ];
      intro x hx; rw [ h_second_deriv x hx ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hx.ne' ];
    exact fun x hx => h_second_deriv x ( interior_subset hx ) ▸ add_nonneg ( Real.exp_nonneg x ) ( one_div_nonneg.mpr ( sq_nonneg x ) )

theorem EML_fp_expansion (x y : ℝ) (hx : 0 < x) (hy : 0 < y) (hy1 : y < 1) :
    EML_fp x y > x := by
  exact lt_tsub_iff_left.mpr ( by linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hy ] )

theorem EML_fp_pos_small_y (x y : ℝ) (hx : 0 < x) (hy : 0 < y) (hy1 : y ≤ 1) :
    EML_fp x y > 0 := by
  exact sub_pos_of_lt ( lt_of_le_of_lt ( Real.log_nonpos hy.le hy1 ) ( by positivity ) )

theorem d_fp_ge_two (x : ℝ) (hx : 0 < x) : d_fp x ≥ 2 := by
  unfold d_fp;
  linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ]

theorem d_fp_strictMono_Ici : StrictMonoOn d_fp (Ici 1) := by
  -- The derivative of $d(x) = e^x - \ln(x)$ is $d'(x) = e^x - \frac{1}{x}$.
  have h_deriv : ∀ x > 0, deriv (fun x => Real.exp x - Real.log x) x = Real.exp x - 1 / x := by
    exact fun x x_pos => by simp +decide [ Real.differentiableAt_exp, Real.differentiableAt_log, x_pos.ne' ] ;
  -- For $x \geq 1$, $e^x \geq e > 1 \geq 1/x$, so the derivative is positive.
  have h_deriv_pos : ∀ x ≥ 1, 0 < deriv (fun x => Real.exp x - Real.log x) x := by
    exact fun x hx => h_deriv x ( by positivity ) ▸ sub_pos_of_lt ( by rw [ div_eq_mul_inv ] ; nlinarith [ Real.add_one_le_exp x, mul_inv_cancel₀ ( by positivity : x ≠ 0 ) ] );
  -- Use the mean value theorem approach as in the V11 files.
  have h_mvt : ∀ x y : ℝ, 1 ≤ x → x < y → ∃ c ∈ Set.Ioo x y, deriv (fun x => Real.exp x - Real.log x) c = (Real.exp y - Real.log y - (Real.exp x - Real.log x)) / (y - x) := by
    intros; apply_rules [ exists_deriv_eq_slope ];
    · exact continuousOn_of_forall_continuousAt fun x hx => by exact ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log ( by linarith [ hx.1 ] ) );
    · exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.log differentiableOn_id fun x hx => by linarith [ hx.1 ] );
  intro x hx y hy hxy; obtain ⟨ c, hc₁, hc₂ ⟩ := h_mvt x y hx hxy; have := h_deriv_pos c ( by linarith [ hc₁.1, hx.out ] ) ; rw [ hc₂, lt_div_iff₀ ] at this <;> aesop

theorem displacement_acceleration (x : ℝ) (hx : 1 ≤ x) :
    d_fp (d_fp x) - d_fp x ≥ d_fp x - x := by
  by_contra h_contra;
  -- Since $d(x) \geq 2 \geq 1$ for $x > 0$, we can apply the monotonicity of $\delta$ on $[1, \infty)$.
  have h_monotone : ∀ t1 t2 : ℝ, 1 ≤ t1 → t1 < t2 → displacement t1 < displacement t2 := by
    -- The derivative of δ(t) is δ'(t) = exp(t) - 1/t - 1, which is positive for t ≥ 1.
    have h_deriv_pos : ∀ t : ℝ, 1 ≤ t → deriv displacement t > 0 := by
      intro t ht; rw [ show displacement = fun t => Real.exp t - Real.log t - t by funext t; rfl ] ; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, show t ≠ 0 by linarith ];
      nlinarith [ inv_mul_cancel₀ ( by linarith : t ≠ 0 ), Real.add_one_lt_exp ( by linarith : t ≠ 0 ) ];
    intros t1 t2 ht1 ht2;
    have := exists_deriv_eq_slope displacement ht2;
    exact this ( continuousOn_of_forall_continuousAt fun t ht => by exact DifferentiableAt.continuousAt <| by exact differentiableAt_of_deriv_ne_zero <| ne_of_gt <| h_deriv_pos t <| by linarith [ ht.1 ] ) ( fun t ht => by exact DifferentiableAt.differentiableWithinAt <| by exact differentiableAt_of_deriv_ne_zero <| ne_of_gt <| h_deriv_pos t <| by linarith [ ht.1 ] ) |> fun ⟨ c, hc1, hc2 ⟩ => by nlinarith [ h_deriv_pos c <| by linarith [ hc1.1 ], mul_div_cancel₀ ( displacement t2 - displacement t1 ) ( sub_ne_zero_of_ne ht2.ne' ) ] ;
  exact h_contra <| le_of_lt <| h_monotone _ _ hx <| show d_fp x > x from d_fp_gt_id x <| lt_of_lt_of_le zero_lt_one hx;

end