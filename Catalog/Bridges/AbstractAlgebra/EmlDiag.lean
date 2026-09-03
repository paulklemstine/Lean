import Mathlib

/-! # CatalogBuild.Shared.EmlDiag

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3
-/

noncomputable section

open Set

/-- The diagonal of `eml`: `emlDiag z = exp z - log z`.  (Supplied here.) -/
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- [Section: # CatalogBuild.Shared.EmlDiag
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 4] -/
theorem emlDiag_strictly_convex :
    StrictConvexOn ℝ (Ioi 0) (fun z => emlDiag z) := by
  apply strictConvexOn_of_deriv2_pos ( convex_Ioi 0 );
  · exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log hx.out.ne' );
  · -- Let's calculate the second derivative of $d(z) = \exp(z) - \log(z)$.
    have h_second_deriv : ∀ z > 0, deriv^[2] (fun z => Real.exp z - Real.log z) z = Real.exp z + 1 / z^2 := by
      have h_second_deriv : ∀ z > 0, deriv^[2] (fun z => Real.exp z - Real.log z) z = deriv (fun z => Real.exp z - 1 / z) z := by
        exact fun z hz => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds hz ] with x hx using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hx.ne' ] );
      exact fun z hz => h_second_deriv z hz ▸ by norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hz.ne' ] ;
    exact fun x hx => h_second_deriv x ( interior_subset hx ) ▸ add_pos_of_pos_of_nonneg ( Real.exp_pos x ) ( by positivity )

theorem emlDiag_has_minimum :
    ∃ z₀ ∈ Ioi (0 : ℝ), ∀ z ∈ Ioi (0 : ℝ), emlDiag z₀ ≤ emlDiag z := by
  -- To find the critical points, we solve $d'(z) = 0$, which gives $z e^z = 1$.
  have h_critical : ∃ z₀ ∈ Set.Ioi 0, z₀ * Real.exp z₀ = 1 := by
    -- Apply the intermediate value theorem to the continuous function $f(z) = z e^z$ on the interval $(0, 1)$.
    have h_ivt : ∃ c ∈ Set.Ioo 0 1, c * Real.exp c = 1 := by
      apply_rules [ intermediate_value_Ioo ] <;> norm_num;
      exact continuousOn_id.mul Real.continuousOn_exp;
    exact ⟨ h_ivt.choose, h_ivt.choose_spec.1.1, h_ivt.choose_spec.2 ⟩;
  cases' h_critical with z₀ hz₀;
  refine' ⟨ z₀, hz₀.1, fun z hz => _ ⟩ ; unfold emlDiag;
  have := Real.log_le_sub_one_of_pos ( div_pos ( Real.exp_pos z ) ( Real.exp_pos z₀ ) );
  norm_num [ Real.log_div ( ne_of_gt ( Real.exp_pos z ) ) ( ne_of_gt ( Real.exp_pos z₀ ) ) ] at *;
  have := Real.log_le_sub_one_of_pos ( div_pos hz hz₀.1 );
  rw [ Real.log_div ] at this <;> nlinarith [ Real.exp_pos z, Real.exp_pos z₀, mul_div_cancel₀ ( Real.exp z ) ( ne_of_gt ( Real.exp_pos z₀ ) ), mul_div_cancel₀ ( z ) ( ne_of_gt hz₀.1 ) ]

theorem emlDiag_gt (z : ℝ) : emlDiag z > z := by
  by_cases hz : z ≤ 0;
  · unfold emlDiag;
    by_cases h : z < 0;
    · linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos ( neg_pos.mpr h ), Real.log_neg_eq_log z ];
    · norm_num [ show z = 0 by linarith ];
  · unfold emlDiag;
    have := Real.add_one_le_exp ( z - 1 );
    rw [ show z = 1 + ( z - 1 ) by ring, Real.exp_add ];
    nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( z - 1 ) ) ]

end