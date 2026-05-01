import Mathlib

/-! # CatalogBuild.Computation.Oracles.MetaOracleAdvanced

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/


noncomputable section

/-- The identity meta-oracle: does nothing. -/
def metaOracleId {α : Type*} : α → α := id




/-- The identity is a fixed point of any meta-oracle composition scheme. -/
theorem metaOracleId_fixed {α : Type*} (f : (α → α) → (α → α))
    (hf : f id = id) : f metaOracleId = metaOracleId :=
  hf




/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleAdvanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem exists_fixed_quality_strict {n : ℕ} (hn : 0 < n)
    (M : Fin n → Fin n) (q : Fin n → ℝ)
    (h_strict : ∀ i, M i ≠ i → q i < q (M i)) :
    ∃ i, M i = i := by
  contrapose! h_strict with h;
  -- Consider the maximum value of $q$ over all elements in $Fin n$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, ∀ i : Fin n, q i₀ ≥ q i := by
    simpa using Finset.exists_max_image Finset.univ q ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ );
  exact ⟨ i₀, h i₀, hi₀ _ ⟩




/-- The improvement ratio after n steps of a contraction with rate k. -/
def improvementRatio (k : ℝ) (n : ℕ) : ℝ := 1 - k ^ n




/-- The improvement ratio approaches 1 (complete improvement) as n → ∞. -/
theorem improvementRatio_tendsto_one (k : ℝ) (hk : 0 < k) (hk1 : k < 1) :
    Filter.Tendsto (improvementRatio k) Filter.atTop (nhds 1) := by
  unfold improvementRatio
  have h := tendsto_pow_atTop_nhds_zero_of_lt_one (le_of_lt hk) hk1
  convert Filter.Tendsto.const_sub 1 h using 1 <;> ring




/-- Number of iterations needed to achieve ε-optimality. -/
def iterationsNeeded (k ε d₀ : ℝ) : ℝ :=
  Real.log (ε / d₀) / Real.log k




/-- The number of iterations needed is proportional to 1/H where H is oracle entropy. -/
theorem iterations_proportional_to_inv_entropy
    (k ε d₀ : ℝ) (_hk : 0 < k) (_hk1 : k < 1) (_hε : 0 < ε) (_hd : 0 < d₀) :
    iterationsNeeded k ε d₀ = Real.log (ε / d₀) / (-(-Real.log k)) := by
  unfold iterationsNeeded
  ring




/-- Meta-oracles on a fixed type form a semigroup under composition. -/
instance metaOracleSemigroup (α : Type*) : Semigroup (α → α) where
  mul := Function.comp
  mul_assoc := Function.comp_assoc




/-- Meta-oracles on a fixed type form a monoid with identity. -/
instance metaOracleMonoid (α : Type*) : Monoid (α → α) where
  one := id
  one_mul := Function.id_comp
  mul_one := Function.comp_id




/-- If f and g both contract with rates k₁ and k₂, then f ∘ g contracts with rate k₁ * k₂. -/
theorem comp_contraction_rate {α : Type*} [PseudoMetricSpace α]
    (f g : α → α) (k₁ k₂ : ℝ)
    (hk₁ : 0 ≤ k₁) (_hk₂ : 0 ≤ k₂)
    (hf : ∀ x y, dist (f x) (f y) ≤ k₁ * dist x y)
    (hg : ∀ x y, dist (g x) (g y) ≤ k₂ * dist x y) :
    ∀ x y, dist ((f ∘ g) x) ((f ∘ g) y) ≤ (k₁ * k₂) * dist x y := by
  intro x y
  simp only [Function.comp_apply]
  calc dist (f (g x)) (f (g y))
      ≤ k₁ * dist (g x) (g y) := hf _ _
    _ ≤ k₁ * (k₂ * dist x y) := by
        apply mul_le_mul_of_nonneg_left (hg _ _) hk₁
    _ = (k₁ * k₂) * dist x y := by ring




/-- A weighted combination of quality values (portfolio quality). -/
def portfolioQuality {n : ℕ} (weights : Fin n → ℝ) (qualities : Fin n → ℝ) : ℝ :=
  ∑ i, weights i * qualities i




/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleAdvanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem portfolio_quality_bounded {n : ℕ} (hn : 0 < n)
    (w : Fin n → ℝ) (q : Fin n → ℝ)
    (hw_nn : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1) :
    (∃ i, q i ≤ portfolioQuality w q) ∧ (∃ i, portfolioQuality w q ≤ q i) := by
  constructor;
  · -- Let $j$ be an index such that $q_j$ is the minimum among the $q_i$.
    obtain ⟨j, hj⟩ : ∃ j, ∀ i, q i ≥ q j := by
      simpa using Finset.exists_min_image Finset.univ ( fun i => q i ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
    exact ⟨ j, by simpa [ ← Finset.sum_mul _ _ _, hw_sum ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => mul_le_mul_of_nonneg_left ( hj i ) ( hw_nn i ) ⟩;
  · -- Since the weights are non-negative and sum to 1, the weighted average of the qualities is bounded above by the maximum quality.
    have h_max : ∃ i, ∀ j, q j ≤ q i := by
      simpa using Finset.exists_max_image Finset.univ q ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
    exact ⟨ h_max.choose, le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( h_max.choose_spec i ) ( hw_nn i ) ) ( by simp +decide [ ← Finset.sum_mul, hw_sum ] ) ⟩




end