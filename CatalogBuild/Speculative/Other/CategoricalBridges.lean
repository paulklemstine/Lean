/-! # CatalogBuild.Speculative.Other.CategoricalBridges

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 10
-/

import Mathlib

noncomputable section

/-- The identity bridge on any category. -/
def identityBridge (C : Type*) [Category C] : MathBridge C C :=
  ⟨𝟭 C, 𝟭 C, Adjunction.id⟩


/-- A bridge invariant is a property preserved by both directions. -/
structure BridgeInvariant {C D : Type*} [Category C] [Category D]
    (bridge : MathBridge C D) where
  propC : C → Prop
  propD : D → Prop
  forward_preserves : ∀ X : C, propC X → propD (bridge.forward.obj X)
  backward_preserves : ∀ Y : D, propD Y → propC (bridge.backward.obj Y)


/-- A bridge is an equivalence if the forward functor is. -/
def isBridgeEquivalence {C D : Type*} [Category C] [Category D]
    (bridge : MathBridge C D) : Prop :=
  bridge.forward.IsEquivalence


/-- Each bridge level subsumes the previous. -/
def bridgeSubsumes : BridgeLevel → BridgeLevel → Prop
  | .stone, .classical => True
  | .gelfand, .stone => True
  | .gelfand, .classical => True
  | .pointfree, .gelfand => True
  | .pointfree, .stone => True
  | .pointfree, .classical => True
  | .hott, _ => True  -- HoTT subsumes all
  | _, _ => False


/-- An analysis bridge extends a discrete bridge to handle limits. -/
structure AnalysisBridge where
  discreteMap : ℕ → ℝ
  continuousLimit : ℝ
  hasLimit : Filter.Tendsto discreteMap Filter.atTop (nhds continuousLimit)


/-- The discrete-to-continuous bridge is unique: limits are unique. -/
theorem analysis_bridge_unique (b₁ b₂ : AnalysisBridge)
    (h : b₁.discreteMap = b₂.discreteMap) :
    b₁.continuousLimit = b₂.continuousLimit := by
  have h1 := b₁.hasLimit
  have h2 := b₂.hasLimit
  rw [h] at h1
  exact tendsto_nhds_unique h1 h2


/-- [Section: ## Section 5: Analysis Bridges (Limits and Integrals)] -/
theorem riemann_sum_bridge (f : ℝ → ℝ) (hf : Continuous f) :
    Filter.Tendsto
      (fun n : ℕ => (∑ k ∈ Finset.range n, f ((k + 1 : ℝ) / n)) / n)
      Filter.atTop
      (nhds (∫ x in Set.Icc 0 1, f x)) := by
  have h_conv : Filter.Tendsto (fun n : ℕ => (∑ k ∈ Finset.range n, ∫ x in (k / n : ℝ)..((k + 1) / n : ℝ), f x)) Filter.atTop (nhds (∫ x in Set.Icc 0 1, f x)) := by
    have h_partition : ∀ n : ℕ, n ≠ 0 → ∑ k ∈ Finset.range n, ∫ x in (k / n : ℝ)..((k + 1) / n : ℝ), f x = ∫ x in (0 : ℝ)..1, f x := by
      intro n hn; convert intervalIntegral.sum_integral_adjacent_intervals _ <;> norm_num [ hn ] ;
      exact fun k hk => hf.intervalIntegrable _ _;
    exact tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with n hn; rw [ h_partition n hn, MeasureTheory.integral_Icc_eq_integral_Ioc, intervalIntegral.integral_of_le zero_le_one ] );
  -- By the properties of integrals, we can bound the difference between the Riemann sum and the integral.
  have h_bound : ∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N, ∀ k ∈ Finset.range n, |∫ x in (k / n : ℝ)..((k + 1) / n : ℝ), f x - f ((k + 1) / n)| ≤ ε * (1 / n : ℝ) := by
    -- Since $f$ is continuous on a compact interval, it is uniformly continuous.
    have h_unif_cont : UniformContinuousOn f (Set.Icc 0 1) := by
      exact ( isCompact_Icc.uniformContinuousOn_of_continuous hf.continuousOn );
    intro ε ε_pos; rcases Metric.uniformContinuousOn_iff.mp h_unif_cont ε ε_pos with ⟨ δ, δ_pos, hδ ⟩ ; use ⌈δ⁻¹⌉₊ + 1; intro n hn k hk; refine' le_trans ( intervalIntegral.abs_integral_le_integral_abs _ ) _ ; ring;
    · norm_num;
    · refine' le_trans ( intervalIntegral.integral_mono_on _ _ _ _ ) _;
      use fun x => ε;
      · bound;
      · exact Continuous.intervalIntegrable ( by continuity ) _ _;
      · norm_num;
      · intro x hx; refine' le_of_lt ( hδ x _ _ _ _ ) <;> norm_num at *;
        · exact ⟨ le_trans ( by positivity ) hx.1, hx.2.trans ( by rw [ div_le_iff₀ ( by norm_cast; linarith ) ] ; norm_cast; linarith ) ⟩;
        · exact ⟨ by positivity, by rw [ div_le_iff₀ ( by norm_cast; linarith ) ] ; norm_cast; linarith ⟩;
        · exact abs_lt.mpr ⟨ by nlinarith [ Nat.le_ceil ( δ⁻¹ ), mul_inv_cancel₀ ( ne_of_gt δ_pos ), show ( n : ℝ ) ≥ ⌈δ⁻¹⌉₊ + 1 by exact_mod_cast hn, div_mul_cancel₀ ( ( k : ℝ ) + 1 ) ( by norm_cast; linarith : ( n : ℝ ) ≠ 0 ), div_mul_cancel₀ ( ( k : ℝ ) ) ( by norm_cast; linarith : ( n : ℝ ) ≠ 0 ) ], by nlinarith [ Nat.le_ceil ( δ⁻¹ ), mul_inv_cancel₀ ( ne_of_gt δ_pos ), show ( n : ℝ ) ≥ ⌈δ⁻¹⌉₊ + 1 by exact_mod_cast hn, div_mul_cancel₀ ( ( k : ℝ ) + 1 ) ( by norm_cast; linarith : ( n : ℝ ) ≠ 0 ), div_mul_cancel₀ ( ( k : ℝ ) ) ( by norm_cast; linarith : ( n : ℝ ) ≠ 0 ) ] ⟩;
      · ring_nf; norm_num;
  -- Using the bound, we can show that the difference between the Riemann sum and the integral tends to zero.
  have h_diff_zero : Filter.Tendsto (fun n : ℕ => (∑ k ∈ Finset.range n, ∫ x in (k / n : ℝ)..((k + 1) / n : ℝ), f x - f ((k + 1) / n))) Filter.atTop (nhds 0) := by
    rw [ Metric.tendsto_nhds ];
    intro ε hε; obtain ⟨ N, hN ⟩ := h_bound ( ε / 2 ) ( half_pos hε ) ; filter_upwards [ Filter.eventually_gt_atTop N ] with n hn; rw [ dist_zero_right ] ; refine' lt_of_le_of_lt ( Finset.abs_sum_le_sum_abs _ _ ) _;
    refine' lt_of_le_of_lt ( Finset.sum_le_sum fun i hi => hN n hn.le i hi ) _ ; norm_num [ mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( by linarith : 0 < n ) ] ; nlinarith [ mul_inv_cancel₀ ( by norm_cast; linarith : ( n : ℝ ) ≠ 0 ) ];
  convert h_conv.sub h_diff_zero using 2 <;> norm_num [ div_eq_inv_mul, Finset.mul_sum _ _ _ ];
  rw [ ← Finset.sum_sub_distrib ] ; refine' Finset.sum_congr rfl fun i hi => _ ; rw [ intervalIntegral.integral_sub ( by exact Continuous.intervalIntegrable hf _ _ ) ] <;> norm_num;
  exact Or.inl <| by ring;


/-- An automorphic oracle maps Galois data to automorphic data.
This is the Langlands correspondence at the highest level. -/
structure AutomorphicOracle where
  galoisToAutomorphic : ℤ → ℂ
  galoisLFunction : ℂ → ℂ
  automorphicLFunction : ℂ → ℂ
  lfunction_match : galoisLFunction = automorphicLFunction


/-- The Langlands bridge preserves L-functions. -/
theorem langlands_bridge_preserves_L (oracle : AutomorphicOracle) (s : ℂ) :
    oracle.galoisLFunction s = oracle.automorphicLFunction s := by
  rw [oracle.lfunction_match]


/-- The bridge from types to propositions via Nonempty. -/
theorem type_prop_bridge (α : Type*) :
    Nonempty α ↔ ∃ _ : α, True := by
  constructor
  · intro ⟨a⟩; exact ⟨a, trivial⟩
  · intro ⟨a, _⟩; exact ⟨a⟩


end
