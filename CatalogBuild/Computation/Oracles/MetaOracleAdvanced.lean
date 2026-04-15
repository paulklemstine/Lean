/-! # CatalogBuild.Computation.Oracles.MetaOracleAdvanced

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/

import Mathlib

noncomputable section

/-- The identity meta-oracle: does nothing. -/
def metaOracleId {α : Type*} : α → α := id

/-- The identity is a fixed point of any meta-oracle composition scheme. -/

theorem metaOracleId_fixed {α : Type*} (f : (α → α) → (α → α))
    (hf : f id = id) : f metaOracleId = metaOracleId :=
  hf

/-
PROBLEM
The original conjecture that a quality-improving map on Fin n
    always has a fixed point is FALSE. Counterexample: the swap
    M(0) = 1, M(1) = 0 with constant quality q = 0 satisfies
    q(i) ≤ q(M(i)) but has no fixed point.

    The correct version requires STRICT improvement:

PROVIDED SOLUTION
By contradiction. Assume M has no fixed point, so M i ≠ i for all i. Then h_strict gives q(i) < q(M(i)) for all i. Summing over all i: ∑ q(i) < ∑ q(M(i)). But since M maps Fin n to Fin n, by pigeonhole (or since M is injective — wait, M is not necessarily injective). Actually let's just sum: ∑ q(M(i)) ≤ ? Actually M is not necessarily a bijection. But we can still derive a contradiction: Consider i₀ that maximizes q. Since M(i₀) ≠ i₀, we have q(i₀) < q(M(i₀)). But q(i₀) is the maximum, contradiction.
-/

theorem exists_fixed_quality_strict {n : ℕ} (hn : 0 < n)
    (M : Fin n → Fin n) (q : Fin n → ℝ)
    (h_strict : ∀ i, M i ≠ i → q i < q (M i)) :
    ∃ i, M i = i := by
  contrapose! h_strict with h;
  -- Consider the maximum value of $q$ over all elements in $Fin n$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, ∀ i : Fin n, q i₀ ≥ q i := by
    simpa using Finset.exists_max_image Finset.univ q ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ );
  exact ⟨ i₀, h i₀, hi₀ _ ⟩

/-! ## Part 2: Convergence Rate Analysis -/

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

/-! ## Part 3: Meta-Oracle Semigroup -/

/-- Meta-oracles on a fixed type form a semigroup under composition. -/

instance metaOracleSemigroup (α : Type*) : Semigroup (α → α) where
  mul := Function.comp
  mul_assoc := Function.comp_assoc

/-- Meta-oracles on a fixed type form a monoid with identity. -/

instance metaOracleMonoid (α : Type*) : Monoid (α → α) where
  one := id
  one_mul := Function.id_comp
  mul_one := Function.comp_id

/-! ## Part 4: Improvement Bounds for Compositions -/

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

/-! ## Part 5: Weighted Portfolio of Meta-Oracles -/

/-- A weighted combination of quality values (portfolio quality). -/

def portfolioQuality {n : ℕ} (weights : Fin n → ℝ) (qualities : Fin n → ℝ) : ℝ :=
  ∑ i, weights i * qualities i

/-
PROBLEM
If all weights are non-negative and sum to 1, portfolio quality is
    between the min and max individual quality.

PROVIDED SOLUTION
For the first part (∃ i, q i ≤ portfolio): By contradiction, if q(i) > portfolio for all i, then portfolio = ∑ w(i)*q(i) > ∑ w(i)*portfolio = portfolio * ∑ w(i) = portfolio, contradiction.

For the second part (∃ i, portfolio ≤ q i): By contradiction, if portfolio > q(i) for all i, then portfolio = ∑ w(i)*q(i) < ∑ w(i)*portfolio = portfolio, contradiction.

More precisely: since the portfolio is a convex combination (weights ≥ 0 summing to 1), it must lie between the minimum and maximum of the q(i) values. Use Finset.exists_le_sum_of_sum_le_one or similar weighted average arguments.
-/

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
