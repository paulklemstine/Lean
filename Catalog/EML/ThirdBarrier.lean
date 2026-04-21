/-! # CatalogBuild.EML.ThirdBarrier

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 13
-/

import EML.Lean.AdvancedTheorems
import EML.Lean.ExtendedTheorems
import EML.Lean.OpenQuestions
import EML.Lean.ShefferAlgebra
import EML.Lean.SoftplusBasic
import Mathlib

noncomputable section

/-- A periodic, non-constant, continuous function has no finite limit at +∞. -/
theorem periodic_no_finite_limit {f : ℝ → ℝ} {T : ℝ} (hT : T > 0)
    (hperiodic : Function.Periodic f T)
    (hcont : Continuous f)
    (hnonconst : ∃ a b, f a ≠ f b) :
    ¬ (∃ L : ℝ, Tendsto f atTop (nhds L)) := by
  contrapose! hnonconst
  have h_periodic_seq : ∀ a : ℝ, ∀ n : ℕ, f (a + n * T) = f a := by
    exact fun x n => by simpa [add_mul] using Function.Periodic.int_mul hperiodic n x
  have h_unique_limit : ∀ a : ℝ, Filter.Tendsto (fun n : ℕ => f (a + n * T)) Filter.atTop
      (nhds (hnonconst.choose)) := by
    exact fun a => hnonconst.choose_spec.comp <|
      Filter.tendsto_atTop_add_const_left _ _ <|
      tendsto_natCast_atTop_atTop.atTop_mul_const hT
  aesop




/-- cos does not converge at +∞. -/
theorem cos_no_limit_atTop :
    ¬ (∃ L : ℝ, Tendsto (fun x : ℝ => Real.cos x) atTop (nhds L)) := by
  convert periodic_no_finite_limit (by positivity) Real.cos_periodic
    Real.continuous_cos (by exact ⟨0, Real.pi, by norm_num⟩) using 1




/-- sin does not converge at +∞. -/
theorem sin_no_limit_atTop :
    ¬ (∃ L : ℝ, Tendsto (fun x : ℝ => Real.sin x) atTop (nhds L)) := by
  rintro ⟨L, hL⟩
  have h2 := hL.eventually (Metric.ball_mem_nhds L zero_lt_one)
  simp_all +decide [abs_lt]
  obtain ⟨M, hM⟩ := h2
  have h3 := hM (Real.pi / 2 + 2 * Real.pi * Nat.ceil M)
    (by nlinarith [Nat.le_ceil M, Real.pi_gt_three])
  have h4 := hM (Real.pi / 2 + Real.pi + 2 * Real.pi * Nat.ceil M)
    (by nlinarith [Nat.le_ceil M, Real.pi_gt_three])
  norm_num [mul_comm (2 * Real.pi)] at h3 h4
  linarith [abs_lt.mp h3, abs_lt.mp h4]




/-- [Section: # CatalogBuild.EML.ThirdBarrier
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 13] -/
theorem logisticSigmoid_tendsto_one :
    Tendsto logisticSigmoid atTop (nhds 1) := by
  refine' ( Metric.tendsto_nhds.mpr _ );
  norm_num [ dist_eq_norm, logisticSigmoid ];
  exact fun ε hε => ⟨ ε⁻¹, fun x hx => by rw [ abs_lt ] ; constructor <;> nlinarith [ Real.exp_pos x, mul_inv_cancel₀ hε.ne', Real.add_one_le_exp x, mul_div_cancel₀ ( Real.exp x ) ( by positivity : ( 1 + Real.exp x ) ≠ 0 ) ] ⟩




/-- [Section: # CatalogBuild.EML.ThirdBarrier
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 13] -/
theorem logisticSigmoid_tendsto_zero :
    Tendsto logisticSigmoid atBot (nhds 0) := by
  refine' squeeze_zero_norm' _ _;
  exact fun x => Real.exp x;
  · filter_upwards [ Filter.eventually_lt_atBot 0 ] with x hx using by rw [ Real.norm_of_nonneg ( by exact div_nonneg ( Real.exp_nonneg x ) ( add_nonneg zero_le_one ( Real.exp_nonneg x ) ) ) ] ; exact div_le_self ( Real.exp_nonneg x ) ( by linarith [ Real.exp_pos x ] ) ;
  · exact Real.tendsto_exp_atBot




theorem deriv_comp_tendsto_zero {f g : ℝ → ℝ}
    (hf_diff : Differentiable ℝ f) (hg_diff : Differentiable ℝ g)
    (hf_lip : ∃ C : ℝ, ∀ x, |deriv f x| ≤ C)
    (hg_zero : Tendsto (deriv g) atTop (nhds 0)) :
    Tendsto (fun x => deriv f (g x) * deriv g x) atTop (nhds 0) := by
  exact squeeze_zero_norm ( fun x => by simpa [ abs_mul ] using mul_le_mul_of_nonneg_right ( hf_lip.choose_spec ( g x ) ) ( abs_nonneg ( deriv g x ) ) ) ( by simpa using hg_zero.abs.const_mul _ )




theorem tendsto_atTop_of_deriv_pos_limit {f : ℝ → ℝ}
    (hf : Differentiable ℝ f)
    {L : ℝ} (hL : L > 0) (hf' : Tendsto (deriv f) atTop (nhds L)) :
    Tendsto f atTop atTop := by
  -- Since $f'(x) \to L > 0$, there exists some $M$ such that for all $x \ge M$, $f'(x) > \frac{L}{2}$.
  obtain ⟨M, hM⟩ : ∃ M, ∀ x ≥ M, deriv f x > L / 2 := by
    exact Filter.eventually_atTop.mp ( hf'.eventually ( lt_mem_nhds ( half_lt_self hL ) ) );
  -- By the Mean Value Theorem, for any $x > M$, there exists $c \in (M, x)$ such that $f(x) - f(M) = f'(c)(x - M)$.
  have h_mvt : ∀ x > M, ∃ c ∈ Set.Ioo M x, f x - f M = deriv f c * (x - M) := by
    intro x hx;
    have := exists_deriv_eq_slope f hx;
    exact this ( hf.continuous.continuousOn ) ( hf.differentiableOn ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, hc₁, by rw [ hc₂, div_mul_cancel₀ _ ( sub_ne_zero_of_ne hx.ne' ) ] ⟩;
  rw [ Filter.tendsto_atTop_atTop ];
  exact fun b => ⟨ M + ⌈ ( b - f M ) / ( L / 2 ) ⌉₊ + 1, fun x hx => by obtain ⟨ c, ⟨ hc₁, hc₂ ⟩, hc ⟩ := h_mvt x ( by linarith ) ; nlinarith [ Nat.le_ceil ( ( b - f M ) / ( L / 2 ) ), hM c hc₁.le, mul_div_cancel₀ ( b - f M ) ( by linarith : ( L / 2 ) ≠ 0 ) ] ⟩




theorem tendsto_atBot_of_deriv_neg_limit {f : ℝ → ℝ}
    (hf : Differentiable ℝ f)
    {L : ℝ} (hL : L < 0) (hf' : Tendsto (deriv f) atTop (nhds L)) :
    Tendsto f atTop atBot := by
  -- By the Mean Value Theorem, for any $x > x₀$, there exists $c \in (x₀, x)$ such that $f(x) - f(x₀) = f'(c)(x - x₀)$.
  have h_mvt : ∀ x₀ x, x₀ < x → ∃ c ∈ Set.Ioo x₀ x, f x - f x₀ = deriv f c * (x - x₀) := by
    intro x₀ x hx₀x;
    have := exists_deriv_eq_slope f hx₀x;
    exact this ( hf.continuous.continuousOn ) ( hf.differentiableOn ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, hc₁, by rw [ hc₂, div_mul_cancel₀ _ ( sub_ne_zero_of_ne hx₀x.ne' ) ] ⟩;
  -- Since $f'(x) \to L < 0$, there exists $x₀$ such that for all $x > x₀$, $f'(x) < L/2$.
  obtain ⟨x₀, hx₀⟩ : ∃ x₀, ∀ x > x₀, deriv f x < L / 2 := by
    exact Filter.eventually_atTop.mp ( hf'.eventually ( gt_mem_nhds <| by linarith ) ) |> fun ⟨ x₀, hx₀ ⟩ => ⟨ x₀, fun x hx => hx₀ x hx.le ⟩;
  have h_lim_neg_inf : ∀ x > x₀, f x ≤ f x₀ + (L / 2) * (x - x₀) := by
    intro x hx; obtain ⟨ c, hc₁, hc₂ ⟩ := h_mvt x₀ x hx; nlinarith [ hx₀ c hc₁.1 ] ;
  exact Filter.tendsto_atTop_atBot.mpr fun b => ⟨ x₀ + ⌈ ( b - f x₀ ) / ( L / 2 ) ⌉₊ + 1, fun x hx => by nlinarith [ Nat.le_ceil ( ( b - f x₀ ) / ( L / 2 ) ), h_lim_neg_inf x ( by linarith ), mul_div_cancel₀ ( b - f x₀ ) ( by linarith : ( L / 2 ) ≠ 0 ) ] ⟩




theorem sheffer_expr_deriv_tendsto_both (e : ShefferExpr) :
    (∃ L : ℝ, Tendsto (deriv e.eval) atTop (nhds L)) ∧
    (∃ L : ℝ, Tendsto (deriv e.eval) atBot (nhds L)) := by
  -- We prove BOTH: (1) deriv e.eval converges at +∞, and (2) deriv e.eval converges at -∞.
  induction' e with e ih1 ih2;
  · constructor;
    · use 1;
      rw [ show deriv ShefferExpr.base.eval = fun x => logisticSigmoid x from funext fun x => softplus_deriv x ] ; exact logisticSigmoid_tendsto_one;
    · use 0;
      rw [ show deriv ShefferExpr.base.eval = fun x => logisticSigmoid x from funext fun x => softplus_deriv x ];
      exact?;
  · -- By definition of affine_pre, we have that the derivative is a * (deriv ih2.eval)(a*x+b).
    have h_deriv_affine_pre : deriv (ShefferExpr.affine_pre e ih1 ih2).eval = fun x => e * deriv ih2.eval (e * x + ih1) := by
      funext x;
      convert HasDerivAt.deriv ( HasDerivAt.comp x ( show HasDerivAt ih2.eval _ _ from hasDerivAt_deriv_iff.mpr <| sheffer_expr_differentiable ih2 |> Differentiable.differentiableAt ) <| HasDerivAt.add ( HasDerivAt.const_mul e <| hasDerivAt_id x ) <| hasDerivAt_const _ _ ) using 1 ; ring!;
    by_cases he : e = 0 <;> simp_all +decide [ MulZeroClass.mul_zero ];
    cases lt_or_gt_of_ne he <;> simp_all +decide [ mul_comm e ];
    · constructor;
      · obtain ⟨ L, hL ⟩ := ‹ ( ∃ L, Tendsto ( deriv ih2.eval ) atTop ( nhds L ) ) ∧ ∃ L, Tendsto ( deriv ih2.eval ) atBot ( nhds L ) ›.2;
        exact ⟨ L * e, by simpa using Filter.Tendsto.mul ( hL.comp <| Filter.tendsto_atTop_atBot.mpr fun x => ⟨ ( x - ih1 ) / e, fun y hy => by nlinarith [ mul_div_cancel₀ ( x - ih1 ) he ] ⟩ ) tendsto_const_nhds ⟩;
      · obtain ⟨ L, hL ⟩ := ‹ ( ∃ L, Tendsto ( deriv ih2.eval ) atTop ( nhds L ) ) ∧ ∃ L, Tendsto ( deriv ih2.eval ) atBot ( nhds L ) ›.1;
        exact ⟨ L * e, by simpa using Filter.Tendsto.mul ( hL.comp <| Filter.tendsto_atBot_atTop.mpr fun x => ⟨ ( x - ih1 ) / e, fun y hy => by nlinarith [ mul_div_cancel₀ ( x - ih1 ) he ] ⟩ ) tendsto_const_nhds ⟩;
    · exact ⟨ by rcases ‹ ( ∃ L, Tendsto ( deriv ih2.eval ) atTop ( nhds L ) ) ∧ ∃ L, Tendsto ( deriv ih2.eval ) atBot ( nhds L ) ›.1 with ⟨ L, hL ⟩ ; exact ⟨ L * e, by simpa using hL.comp ( show Filter.Tendsto ( fun x : ℝ => x * e + ih1 ) atTop atTop from Filter.tendsto_atTop_add_const_right _ _ <| Filter.tendsto_id.atTop_mul_const <| by positivity ) |> Filter.Tendsto.mul_const _ ⟩, by rcases ‹ ( ∃ L, Tendsto ( deriv ih2.eval ) atTop ( nhds L ) ) ∧ ∃ L, Tendsto ( deriv ih2.eval ) atBot ( nhds L ) ›.2 with ⟨ L, hL ⟩ ; exact ⟨ L * e, by simpa using hL.comp ( show Filter.Tendsto ( fun x : ℝ => x * e + ih1 ) atBot atBot from Filter.tendsto_atBot_add_const_right _ _ <| Filter.tendsto_id.atBot_mul_const <| by positivity ) |> Filter.Tendsto.mul_const _ ⟩ ⟩;
  · rename_i α β γ e₁ e₂ ih₁ ih₂;
    -- By definition of affine combination, we have:
    have h_affine_comb : deriv (ShefferExpr.affine_comb α β γ e₁ e₂).eval = fun x => α * deriv e₁.eval x + β * deriv e₂.eval x := by
      ext x; erw [ show ( ShefferExpr.affine_comb α β γ e₁ e₂ ).eval = fun x => α * e₁.eval x + β * e₂.eval x + γ from rfl ] ; norm_num [ mul_comm α, mul_comm β ] ;
      exact HasDerivAt.deriv ( by simpa using HasDerivAt.add ( HasDerivAt.mul ( hasDerivAt_deriv_iff.mpr ( show DifferentiableAt ℝ e₁.eval x from by exact ( sheffer_expr_differentiable e₁ ) |> Differentiable.differentiableAt ) ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.mul ( hasDerivAt_deriv_iff.mpr ( show DifferentiableAt ℝ e₂.eval x from by exact ( sheffer_expr_differentiable e₂ ) |> Differentiable.differentiableAt ) ) ( hasDerivAt_const _ _ ) ) );
    exact ⟨ by obtain ⟨ L₁, hL₁ ⟩ := ih₁.1; obtain ⟨ L₂, hL₂ ⟩ := ih₂.1; exact ⟨ α * L₁ + β * L₂, by simpa only [ h_affine_comb ] using Filter.Tendsto.add ( tendsto_const_nhds.mul hL₁ ) ( tendsto_const_nhds.mul hL₂ ) ⟩, by obtain ⟨ L₁, hL₁ ⟩ := ih₁.2; obtain ⟨ L₂, hL₂ ⟩ := ih₂.2; exact ⟨ α * L₁ + β * L₂, by simpa only [ h_affine_comb ] using Filter.Tendsto.add ( tendsto_const_nhds.mul hL₁ ) ( tendsto_const_nhds.mul hL₂ ) ⟩ ⟩;
  · constructor <;> norm_num [ ShefferExpr.eval ];
    · rename_i e₁ e₂ ih₁ ih₂;
      obtain ⟨ ⟨ L₁, hL₁ ⟩, ⟨ L₂, hL₂ ⟩ ⟩ := ih₁
      obtain ⟨ ⟨ L₃, hL₃ ⟩, ⟨ L₄, hL₄ ⟩ ⟩ := ih₂;
      by_cases hL₃_pos : 0 < L₃;
      · have h_e2_top : Filter.Tendsto e₂.eval Filter.atTop Filter.atTop := by
          apply_rules [ tendsto_atTop_of_deriv_pos_limit ];
          exact?;
        use L₁ * L₃;
        have h_deriv_comp : ∀ x, deriv (fun x => e₁.eval (e₂.eval x)) x = deriv e₁.eval (e₂.eval x) * deriv e₂.eval x := by
          intro x; exact (by
          exact deriv_comp x ( sheffer_expr_differentiable _ |> Differentiable.differentiableAt ) ( sheffer_expr_differentiable _ |> Differentiable.differentiableAt ));
        simpa only [ funext h_deriv_comp ] using Filter.Tendsto.mul ( hL₁.comp h_e2_top ) hL₃;
      · by_cases hL₃_neg : L₃ < 0;
        · have h_e2_neg_inf : Filter.Tendsto e₂.eval Filter.atTop Filter.atBot := by
            apply_rules [ tendsto_atBot_of_deriv_neg_limit ];
            exact?;
          have h_deriv_comp : Filter.Tendsto (fun x => deriv e₁.eval (e₂.eval x) * deriv e₂.eval x) Filter.atTop (nhds (L₂ * L₃)) := by
            exact Filter.Tendsto.mul ( hL₂.comp h_e2_neg_inf ) hL₃;
          use L₂ * L₃;
          refine' h_deriv_comp.congr' _;
          filter_upwards [ Filter.eventually_gt_atTop 0 ] with x hx;
          exact Eq.symm ( deriv_comp x ( show DifferentiableAt ℝ e₁.eval _ from by exact ( sheffer_expr_differentiable e₁ |> Differentiable.differentiableAt ) ) ( show DifferentiableAt ℝ e₂.eval _ from by exact ( sheffer_expr_differentiable e₂ |> Differentiable.differentiableAt ) ) );
        · norm_num [ show L₃ = 0 by linarith ] at *;
          use 0;
          convert deriv_comp_tendsto_zero ( sheffer_expr_differentiable e₁ ) ( sheffer_expr_differentiable e₂ ) _ hL₃ using 1;
          · ext x; exact (by
            exact deriv_comp x ( sheffer_expr_differentiable e₁ |> Differentiable.differentiableAt ) ( sheffer_expr_differentiable e₂ |> Differentiable.differentiableAt ));
          · have := sheffer_expr_lipschitz e₁;
            obtain ⟨ C, hC₀, hC ⟩ := this;
            use C;
            intro x;
            have h_deriv_bound : ∀ x, |deriv e₁.eval x| ≤ C := by
              intro x
              have h_lim : Filter.Tendsto (fun h => |(e₁.eval (x + h) - e₁.eval x) / h|) (nhdsWithin 0 {0}ᶜ) (nhds |deriv e₁.eval x|) := by
                have h_lim : HasDerivAt e₁.eval (deriv e₁.eval x) x := by
                  exact hasDerivAt_deriv_iff.mpr ( show DifferentiableAt ℝ e₁.eval x from by exact ( sheffer_expr_differentiable e₁ ) |> Differentiable.differentiableAt );
                simpa [ div_eq_inv_mul ] using h_lim.tendsto_slope_zero.abs
              refine' le_of_tendsto h_lim _;
              filter_upwards [ self_mem_nhdsWithin ] with y hy using by rw [ abs_div ] ; exact div_le_of_le_mul₀ ( abs_nonneg _ ) ( by positivity ) ( by simpa [ abs_mul ] using hC ( x + y ) x ) ;
            exact h_deriv_bound x;
    · rename_i e₁ e₂ ih₁ ih₂;
      -- By the chain rule, we have $\frac{d}{dx} e₁(e₂(x)) = e₁'(e₂(x)) e₂'(x)$.
      have h_chain : ∀ x, deriv (fun x => e₁.eval (e₂.eval x)) x = deriv e₁.eval (e₂.eval x) * deriv e₂.eval x := by
        intro x;
        exact deriv_comp x ( sheffer_expr_differentiable e₁ |> Differentiable.differentiableAt ) ( sheffer_expr_differentiable e₂ |> Differentiable.differentiableAt );
      -- By the induction hypothesis, we know that $deriv e₁.eval$ and $deriv e₂.eval$ converge at $-\infty$.
      obtain ⟨L₁, hL₁⟩ := ih₁.right
      obtain ⟨L₂, hL₂⟩ := ih₂.right;
      by_cases hL₂_zero : L₂ = 0;
      · -- Since $deriv e₁.eval$ is bounded, we can apply the fact that the product of a bounded function and a function tending to zero tends to zero.
        have h_bounded : ∃ C : ℝ, ∀ x, |deriv e₁.eval x| ≤ C := by
          have := sheffer_expr_lipschitz e₁;
          obtain ⟨ C, hC₀, hC ⟩ := this;
          use C;
          intro x;
          by_contra h_contra;
          have h_deriv_bound : Filter.Tendsto (fun h => (e₁.eval (x + h) - e₁.eval x) / h) (nhdsWithin 0 (Set.Ioi 0)) (nhds (deriv e₁.eval x)) := by
            simpa [ div_eq_inv_mul ] using HasDerivAt.tendsto_slope_zero_right ( hasDerivAt_deriv_iff.mpr ( show DifferentiableAt ℝ e₁.eval x from differentiableAt_of_deriv_ne_zero ( show deriv e₁.eval x ≠ 0 from fun h => h_contra <| by simp +decide [ h ] ; linarith ) ) );
          have h_deriv_bound : ∀ᶠ h in nhdsWithin 0 (Set.Ioi 0), |(e₁.eval (x + h) - e₁.eval x) / h| ≤ C := by
            filter_upwards [ self_mem_nhdsWithin ] with h hh using by rw [ abs_div, abs_of_nonneg hh.out.le ] ; exact div_le_of_le_mul₀ ( by linarith [ hh.out ] ) ( by linarith [ hh.out ] ) ( by simpa [ abs_of_nonneg hh.out.le ] using hC ( x + h ) x ) ;
          exact h_contra <| le_of_tendsto_of_tendsto ( Filter.Tendsto.abs <| by assumption ) tendsto_const_nhds h_deriv_bound;
        use 0;
        rw [ show deriv ( fun x => e₁.eval ( e₂.eval x ) ) = fun x => deriv e₁.eval ( e₂.eval x ) * deriv e₂.eval x from funext h_chain ];
        exact squeeze_zero_norm ( fun x => by simpa [ abs_mul ] using mul_le_mul_of_nonneg_right ( h_bounded.choose_spec _ ) ( abs_nonneg _ ) ) ( by simpa [ hL₂_zero ] using hL₂.norm.const_mul _ );
      · by_cases hL₂_pos : L₂ > 0;
        · have h_e2_neg_inf : Filter.Tendsto (fun x => e₂.eval x) Filter.atBot Filter.atBot := by
            have h_e2_neg_inf : ∀ᶠ x in Filter.atBot, deriv e₂.eval x > L₂ / 2 := by
              exact hL₂.eventually ( lt_mem_nhds ( half_lt_self hL₂_pos ) );
            have h_e2_neg_inf : ∀ᶠ x in Filter.atBot, ∀ y ≤ x, e₂.eval y ≤ e₂.eval x - (x - y) * (L₂ / 2) := by
              obtain ⟨ x₀, hx₀ ⟩ := Filter.eventually_atBot.mp h_e2_neg_inf;
              filter_upwards [ Filter.eventually_lt_atBot x₀ ] with x hx;
              intro y hy; by_contra h_contra; push_neg at h_contra;
              have := exists_deriv_eq_slope e₂.eval ( show y < x from hy.lt_of_ne ( by rintro rfl; linarith ) );
              exact absurd ( this ( by exact continuousOn_of_forall_continuousAt fun z hz => DifferentiableAt.continuousAt ( by exact sheffer_expr_differentiable e₂ |> Differentiable.differentiableAt ) ) ( by exact fun z hz => DifferentiableAt.differentiableWithinAt ( by exact sheffer_expr_differentiable e₂ |> Differentiable.differentiableAt ) ) ) ( by rintro ⟨ c, ⟨ hyc, hcx ⟩, hcd ⟩ ; rw [ eq_div_iff ] at hcd <;> nlinarith [ hx₀ c ( by linarith ) ] );
            rw [ Filter.tendsto_atBot_atBot ];
            obtain ⟨ x, hx ⟩ := Filter.eventually_atBot.mp h_e2_neg_inf;
            exact fun b => ⟨ x - ⌈ ( e₂.eval x - b ) / ( L₂ / 2 ) ⌉₊ * 2, fun y hy => by nlinarith [ Nat.le_ceil ( ( e₂.eval x - b ) / ( L₂ / 2 ) ), hx x le_rfl y ( by linarith ), mul_div_cancel₀ ( e₂.eval x - b ) ( by linarith : ( L₂ / 2 ) ≠ 0 ) ] ⟩;
          exact ⟨ L₁ * L₂, by simpa only [ funext h_chain ] using hL₁.comp h_e2_neg_inf |> Filter.Tendsto.mul <| hL₂ ⟩;
        · -- Since $L₂ < 0$, we have $e₂(x) \to -\infty$ as $x \to -\infty$.
          have h_e2_neg_inf : Filter.Tendsto e₂.eval Filter.atBot Filter.atTop := by
            have h_e2_neg_inf : Filter.Tendsto (deriv e₂.eval) Filter.atBot (nhds L₂) ∧ L₂ < 0 := by
              exact ⟨ hL₂, lt_of_le_of_ne ( le_of_not_gt hL₂_pos ) hL₂_zero ⟩;
            have h_e2_neg_inf : ∃ M : ℝ, ∀ x < M, deriv e₂.eval x < L₂ / 2 := by
              exact Filter.eventually_atBot.mp ( h_e2_neg_inf.1.eventually ( gt_mem_nhds <| by linarith ) ) |> fun ⟨ M, hM ⟩ => ⟨ M, fun x hx => hM x hx.le ⟩;
            obtain ⟨ M, hM ⟩ := h_e2_neg_inf;
            have h_e2_neg_inf : ∀ x < M, e₂.eval x ≥ e₂.eval M + (x - M) * (L₂ / 2) := by
              intros x hx
              have h_mean_val : ∃ c ∈ Set.Ioo x M, deriv e₂.eval c = (e₂.eval M - e₂.eval x) / (M - x) := by
                have := exists_deriv_eq_slope e₂.eval hx;
                exact this ( Continuous.continuousOn <| by exact? ) ( Differentiable.differentiableOn <| by exact? );
              obtain ⟨ c, hc₁, hc₂ ⟩ := h_mean_val; have := hM c hc₁.2; rw [ eq_div_iff ] at hc₂ <;> nlinarith;
            rw [ Filter.tendsto_atTop ];
            intro b; filter_upwards [ Filter.eventually_lt_atBot M, Filter.eventually_lt_atBot ( ( b - e₂.eval M ) / ( L₂ / 2 ) + M ) ] with x hx₁ hx₂ using by nlinarith [ h_e2_neg_inf x hx₁, mul_div_cancel₀ ( b - e₂.eval M ) ( by linarith : ( L₂ / 2 ) ≠ 0 ) ] ;
          have h_e1_neg_inf : Filter.Tendsto (fun x => deriv e₁.eval (e₂.eval x)) Filter.atBot (nhds (ih₁.left.choose)) := by
            exact ih₁.1.choose_spec.comp h_e2_neg_inf;
          exact ⟨ _, by simpa only [ funext h_chain ] using h_e1_neg_inf.mul hL₂ ⟩




/-- Every Sheffer expression's derivative converges at +∞. -/
theorem sheffer_expr_deriv_tendsto (e : ShefferExpr) :
    ∃ L : ℝ, Tendsto (deriv e.eval) atTop (nhds L) :=
  (sheffer_expr_deriv_tendsto_both e).1




/-- sin is NOT in the Sheffer algebra. -/
theorem sin_not_mem_sheffer : (fun x : ℝ => Real.sin x) ∉ ShefferAlgebra := by
  rintro ⟨e, he⟩
  obtain ⟨L, hL⟩ := sheffer_expr_deriv_tendsto e
  have h_cos : deriv e.eval = fun x => Real.cos x := by rw [← he]; norm_num
  exact cos_no_limit_atTop ⟨L, by rwa [h_cos] at hL⟩




/-- cos is NOT in the Sheffer algebra. -/
theorem cos_not_mem_sheffer : (fun x : ℝ => Real.cos x) ∉ ShefferAlgebra := by
  rintro ⟨e, he⟩
  obtain ⟨L, hL⟩ := sheffer_expr_deriv_tendsto e
  have h_neg_sin : deriv e.eval = fun x => -Real.sin x := by rw [← he]; norm_num
  exact sin_no_limit_atTop ⟨-L, by simpa [h_neg_sin] using hL.neg⟩




/-- No non-constant periodic function is in the Sheffer algebra. -/
theorem periodic_not_mem_sheffer {f : ℝ → ℝ} {T : ℝ} (hT : T > 0)
    (hperiodic : Function.Periodic f T)
    (hcont : Continuous f)
    (hnonconst : ∃ a b, f a ≠ f b) :
    f ∉ ShefferAlgebra := by
  intro hf
  obtain ⟨e, he⟩ := hf
  have h_deriv := (sheffer_expr_deriv_tendsto e)
  have h_deriv_periodic : Function.Periodic (deriv e.eval) T := by
    intro x
    have h_chain : deriv (fun x => f (x + T)) x = deriv f (x + T) := by exact?
    generalize_proofs at *
    aesop
  have h_deriv_nonconst : ∃ a b, deriv e.eval a ≠ deriv e.eval b := by
    by_contra h_contra
    have h_linear : ∃ m c : ℝ, e.eval = fun x => m * x + c := by
      have h_linear : ∀ x y : ℝ, e.eval y - e.eval x = ∫ t in x..y, deriv e.eval t := by
        intros x y; rw [intervalIntegral.integral_deriv_eq_sub]
        · exact fun _ _ => sheffer_expr_differentiable e _
        · rw [show deriv e.eval = fun _ => deriv e.eval 0 from
            funext fun _ => Classical.not_not.1 fun h => h_contra ⟨_, _, h⟩]; norm_num
      simp_all +decide [Function.Periodic]
      exact ⟨deriv e.eval 0, e.eval 0, funext fun x => by
        have := h_linear 0 x
        rw [show deriv e.eval = fun _ => deriv e.eval 0 from
          funext fun _ => h_contra _ _] at this
        norm_num at *; linarith⟩
    obtain ⟨m, c, hm⟩ := h_linear
    simp_all +decide [Function.Periodic]
  have h_deriv_cont : Continuous (deriv e.eval) := by
    have hcd := sheffer_expr_contDiff e
    exact hcd.continuous_deriv le_top
  exact periodic_no_finite_limit hT h_deriv_periodic h_deriv_cont h_deriv_nonconst h_deriv




end
