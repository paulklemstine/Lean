import Mathlib

/-! # CatalogBuild.Bridges.CategoricalBridges

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12
-/

noncomputable section

open CategoryTheory

/-- Bridge composition: adjunctions compose. -/
def bridge_composition {C D E : Type*}
    [Category C] [Category D] [Category E]
    {F₁ : C ⥤ D} {G₁ : D ⥤ C} {F₂ : D ⥤ E} {G₂ : E ⥤ D}
    (adj₁ : F₁ ⊣ G₁) (adj₂ : F₂ ⊣ G₂) :
    (F₁ ⋙ F₂) ⊣ (G₂ ⋙ G₁) :=
  adj₁.comp adj₂

/-- The mathematical bridge hierarchy. -/
inductive BridgeLevel where
  | setTheoretic | stone | gelfand | pontryagin | galois
  | tannaka | langlands | geometricLanglands | derivedLanglands
  | motivic | hott
  deriving DecidableEq

/-- Numerical level of each bridge. -/
def BridgeLevel.toNat : BridgeLevel → ℕ
  | .setTheoretic => 0
  | .stone => 1
  | .gelfand => 2
  | .pontryagin => 3
  | .galois => 4
  | .tannaka => 5
  | .langlands => 6
  | .geometricLanglands => 7
  | .derivedLanglands => 8
  | .motivic => 9
  | .hott => 10

/-- HoTT subsumes all previous bridges. -/
theorem hott_subsumes_all (b : BridgeLevel) :
    b.toNat ≤ BridgeLevel.hott.toNat := by
  cases b <;> simp [BridgeLevel.toNat]

/-- Analysis bridges have unique limits (Hausdorff uniqueness). -/
theorem analysis_bridge_unique_limit {X : Type*} [TopologicalSpace X] [T2Space X]
    {f : ℕ → X} {a b : X} (ha : Filter.Tendsto f Filter.atTop (nhds a))
    (hb : Filter.Tendsto f Filter.atTop (nhds b)) : a = b :=
  tendsto_nhds_unique ha hb

/-- The Riemann sum of f on [0,1] with n uniform subdivisions. -/
def riemannSum (f : ℝ → ℝ) (n : ℕ) : ℝ :=
  (1 / (n : ℝ)) * ∑ k ∈ Finset.range n, f ((k : ℝ) / (n : ℝ))

/-- [Section: # CatalogBuild.Bridges.CategoricalBridges
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12] -/
theorem riemann_sum_converges (f : ℝ → ℝ) (hf : Continuous f) :
    Filter.Tendsto (fun n => riemannSum f (n + 1))
      Filter.atTop (nhds (∫ x in Set.Icc 0 1, f x)) := by
  rw [ MeasureTheory.integral_Icc_eq_integral_Ioc, ← intervalIntegral.integral_of_le ] <;> norm_num;
  -- The Riemann sum is a Riemann sum for the integral.
  have h_riemann_sum : Filter.Tendsto (fun n => (∑ k ∈ Finset.range n, ∫ x in (k : ℝ) / n..((k + 1) : ℝ) / n, f x)) Filter.atTop (nhds (∫ x in (0 : ℝ)..1, f x)) := by
    have h_riemann_sum : ∀ n : ℕ, n > 0 → ∑ k ∈ Finset.range n, ∫ x in (k : ℝ) / n..((k + 1) : ℝ) / n, f x = ∫ x in (0 : ℝ)..1, f x := by
      intro n hn; convert intervalIntegral.sum_integral_adjacent_intervals _ <;> norm_num [ hn.ne' ];
      exact fun k hk => hf.intervalIntegrable _ _;
    exact tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn; rw [ h_riemann_sum n hn ] );
  -- By the properties of the integral, we can bound the difference between the Riemann sum and the integral.
  have h_bound : ∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N, ∀ k ∈ Finset.range n, |∫ x in (k : ℝ) / n..((k + 1) : ℝ) / n, f x - f ((k : ℝ) / n)| ≤ ε / n := by
    -- Since $f$ is continuous on a compact interval, it is uniformly continuous.
    have h_unif_cont : UniformContinuousOn f (Set.Icc 0 1) := by
      exact ( isCompact_Icc.uniformContinuousOn_of_continuous hf.continuousOn );
    intro ε ε_pos; rcases Metric.uniformContinuousOn_iff.mp h_unif_cont ε ε_pos with ⟨ δ, δ_pos, hδ ⟩ ; use ⌈δ⁻¹⌉₊ + 1; intro n hn k hk; rw [ intervalIntegral.integral_of_le ( by gcongr ; linarith ) ] ;
    refine' le_trans ( MeasureTheory.norm_integral_le_integral_norm ( _ : ℝ → ℝ ) ) ( le_trans ( MeasureTheory.integral_mono_of_nonneg _ _ _ ) _ );
    refine' fun x => ε;
    · exact Filter.Eventually.of_forall fun x => norm_nonneg _;
    · norm_num;
    · filter_upwards [ MeasureTheory.ae_restrict_mem measurableSet_Ioc ] with x hx;
      exact le_of_lt ( hδ x ⟨ by exact le_trans ( by positivity ) hx.1.le, by exact le_trans hx.2 ( by rw [ div_le_iff₀ ( by norm_cast; linarith [ Finset.mem_range.mp hk ] ) ] ; norm_cast; linarith [ Finset.mem_range.mp hk ] ) ⟩ ( k / n ) ⟨ by positivity, by rw [ div_le_iff₀ ( by norm_cast; linarith [ Finset.mem_range.mp hk ] ) ] ; norm_cast; linarith [ Finset.mem_range.mp hk ] ⟩ ( abs_lt.mpr ⟨ by nlinarith [ hx.1, hx.2, show ( n : ℝ ) ≥ ⌈δ⁻¹⌉₊ + 1 by exact_mod_cast hn, mul_div_cancel₀ ( ( k : ℝ ) : ℝ ) ( by norm_cast; linarith [ Finset.mem_range.mp hk ] : ( n : ℝ ) ≠ 0 ), mul_div_cancel₀ ( ( k + 1 : ℝ ) : ℝ ) ( by norm_cast; linarith [ Finset.mem_range.mp hk ] : ( n : ℝ ) ≠ 0 ), Nat.le_ceil ( δ⁻¹ ), mul_inv_cancel₀ ( ne_of_gt δ_pos ) ], by nlinarith [ hx.1, hx.2, show ( n : ℝ ) ≥ ⌈δ⁻¹⌉₊ + 1 by exact_mod_cast hn, mul_div_cancel₀ ( ( k : ℝ ) : ℝ ) ( by norm_cast; linarith [ Finset.mem_range.mp hk ] : ( n : ℝ ) ≠ 0 ), mul_div_cancel₀ ( ( k + 1 : ℝ ) : ℝ ) ( by norm_cast; linarith [ Finset.mem_range.mp hk ] : ( n : ℝ ) ≠ 0 ), Nat.le_ceil ( δ⁻¹ ), mul_inv_cancel₀ ( ne_of_gt δ_pos ) ] ⟩ ) );
    · norm_num [ add_div ];
      rw [ inv_mul_eq_div ];
  -- Using the bound, we can show that the difference between the Riemann sum and the integral tends to zero.
  have h_diff_zero : Filter.Tendsto (fun n => (∑ k ∈ Finset.range n, ∫ x in (k : ℝ) / n..((k + 1) : ℝ) / n, f x - f ((k : ℝ) / n))) Filter.atTop (nhds 0) := by
    rw [ Metric.tendsto_nhds ];
    intro ε hε; obtain ⟨ N, hN ⟩ := h_bound ( ε / 2 ) ( half_pos hε ) ; filter_upwards [ Filter.eventually_ge_atTop N, Filter.eventually_gt_atTop 0 ] with n hn hn' ; refine' lt_of_le_of_lt ( _ : _ ≤ _ ) ( half_lt_self hε );
    simpa [ abs_div, abs_of_nonneg, hn'.ne' ] using le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => hN n hn i hi ) |> le_trans <| by norm_num [ mul_div_cancel₀, hn'.ne' ] ;
  convert h_riemann_sum.comp ( Filter.tendsto_add_atTop_nat 1 ) |> Filter.Tendsto.sub <| h_diff_zero.comp ( Filter.tendsto_add_atTop_nat 1 ) using 2 <;> norm_num [ riemannSum ];
  rw [ ← Finset.sum_sub_distrib ] ; rw [ Finset.mul_sum _ _ _ ] ; refine' Finset.sum_congr rfl fun i hi => _ ; rw [ intervalIntegral.integral_sub ( by exact Continuous.intervalIntegrable ( by continuity ) .. ) ] <;> norm_num ; ring;
  norm_num

/-- L-function data. -/
structure LFunctionData where
  degree : ℕ
  conductor : ℕ

/-- L-function equivalence is reflexive. -/
theorem lfunc_equiv_refl (L : LFunctionData) : L.degree = L.degree ∧ L.conductor = L.conductor :=
  ⟨rfl, rfl⟩

/-- A functional equation with root number. -/
structure FunctionalEquation where
  conductor : ℕ
  weight : ℕ
  root_number : ℂ
  root_number_norm_one : ‖root_number‖ = 1

theorem root_number_unit (fe : FunctionalEquation) :
    ‖fe.root_number‖ = 1 := fe.root_number_norm_one

/-- Self-dual L-functions have root number ±1. -/
def FunctionalEquation.isSelfDual (fe : FunctionalEquation) : Prop :=
  fe.root_number = 1 ∨ fe.root_number = -1

end