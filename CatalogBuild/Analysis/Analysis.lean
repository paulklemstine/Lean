/-! # CatalogBuild.Analysis.Analysis

Auto-generated from theorem catalog database.
Domain: Analysis
Declarations: 7
-/

import Mathlib

theorem convergent_is_cauchy {X : Type*} [MetricSpace X] {f : ℕ → X}
    (hf : ∃ x, Filter.Tendsto f Filter.atTop (nhds x)) :
    CauchySeq f := by
      exact Filter.Tendsto.cauchySeq hf.choose_spec


theorem contraction_has_fixed_point {X : Type*} [MetricSpace X] [CompleteSpace X]
    [Nonempty X] (f : X → X) (k : ℝ) (hk : 0 ≤ k) (hk1 : k < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ k * dist x y) :
    ∃ x, f x = x := by
      -- By the properties of the contraction mapping, there exists a unique fixed point.
      have h_fixed_point : ∃ x₀ : X, Filter.Tendsto (fun n => f^[n] (Classical.arbitrary X)) Filter.atTop (nhds x₀) := by
        refine' cauchySeq_tendsto_of_complete _;
        -- We'll use induction to show that the distance between consecutive terms of the sequence is bounded by $k^n$ times the distance between the initial terms.
        have h_dist : ∀ n, dist (f^[n] (Classical.arbitrary X)) (f^[n+1] (Classical.arbitrary X)) ≤ k^n * dist (Classical.arbitrary X) (f (Classical.arbitrary X)) := by
          intro n; induction' n with n ih <;> simp_all +decide [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] ; exact le_trans ( hf _ _ ) ( mul_le_mul_of_nonneg_left ih hk ) ;
        fapply cauchySeq_of_le_geometric;
        exacts [ k, dist ( Classical.arbitrary X ) ( f ( Classical.arbitrary X ) ), hk1, fun n => by simpa only [ mul_comm ] using h_dist n ];
      obtain ⟨ x₀, hx₀ ⟩ := h_fixed_point;
      use x₀, tendsto_nhds_unique ( by erw [ ← Filter.tendsto_add_atTop_iff_nat 1 ] ; simpa only [ Function.iterate_succ_apply' ] using Filter.Tendsto.comp ( show Filter.Tendsto f _ _ from Metric.tendsto_nhds_nhds.2 fun ε εpos => ⟨ ε, εpos, by intros y hy; exact lt_of_le_of_lt ( hf _ _ ) <| by nlinarith ⟩ ) hx₀ ) hx₀;


theorem mean_value_theorem (f f' : ℝ → ℝ) {a b : ℝ} (hab : a < b)
    (hf : ContinuousOn f (Set.Icc a b))
    (hf' : ∀ x ∈ Set.Ioo a b, HasDerivAt f (f' x) x) :
    ∃ c ∈ Set.Ioo a b, f b - f a = f' c * (b - a) := by
      have := exists_deriv_eq_slope f hab;
      exact this hf ( fun x hx => ( hf' x hx |> HasDerivAt.differentiableAt |> DifferentiableAt.differentiableWithinAt ) ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, hc₁, by rw [ ← div_eq_iff ( sub_ne_zero_of_ne hab.ne' ), ← hc₂, hf' c hc₁ |> HasDerivAt.deriv ] ⟩


theorem ftc_eval {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ∀ x ∈ Set.Icc a b, HasDerivAt f (deriv f x) x)
    (hf' : ContinuousOn (deriv f) (Set.Icc a b)) :
    ∫ x in a..b, deriv f x = f b - f a := by
      rw [ intervalIntegral.integral_eq_sub_of_hasDerivAt ];
      · aesop;
      · exact hf'.intervalIntegrable_of_Icc hab


theorem exponential_decay_tendsto (C α : ℝ) (hα : 0 < α) :
    Filter.Tendsto (fun t => C * Real.exp (-α * t)) Filter.atTop (nhds 0) := by
      simpa using tendsto_const_nhds.mul ( Real.tendsto_exp_atBot.comp <| Filter.tendsto_neg_atTop_atBot.comp <| Filter.tendsto_id.const_mul_atTop hα )


theorem geometric_series_sum (r : ℝ) (hr : |r| < 1) :
    HasSum (fun n => r ^ n) (1 - r)⁻¹ := by
      exact hasSum_geometric_of_abs_lt_one hr


theorem cauchy_schwarz_finset {n : ℕ} (a b : Fin n → ℝ) :
    (∑ i, a i * b i) ^ 2 ≤ (∑ i, a i ^ 2) * (∑ i, b i ^ 2) := by
      exact?
