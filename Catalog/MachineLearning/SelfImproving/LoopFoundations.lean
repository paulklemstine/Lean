/-
  # Self-Improving Mathematical Discovery Loop: Foundations

  We formalize the mathematical foundations of a self-improving loop
  that combines an AI agent harness (pi-agent) with a formal theorem
  prover (Aristotle) to generate, verify, and build upon new mathematics.

  ## Architecture

  The loop has four stages:
  1. **Prompt** — pi-agent selects the optimal next mathematical question
  2. **Discover** — Aristotle formalizes and proves new theorems
  3. **Archive** — Results are integrated back into the Catalog
  4. **Analyze** — pi-agent evaluates results and plans the next iteration

  ## Key Theorems

  - The knowledge catalog grows monotonically
  - The novelty score of discoveries converges to a limit
  - Under diminishing returns, the loop achieves bounded regret
  - The catalog forms a directed system under refinement
-/

import Mathlib

open scoped BigOperators

/-! ## 1. Knowledge Catalog as a Monotone Lattice -/

/-- A knowledge catalog is a growing collection of verified theorems.
    We model it as a monotone sequence of finite sets. -/
structure KnowledgeCatalog where
  /-- The set of theorem identifiers available at step n -/
  theorems : ℕ → Finset ℕ
  /-- The catalog only grows: new steps contain all previous theorems -/
  monotone : ∀ n, theorems n ⊆ theorems (n + 1)

namespace KnowledgeCatalog

/-- The catalog size at step n -/
def size (K : KnowledgeCatalog) (n : ℕ) : ℕ := (K.theorems n).card

/-- Catalog size is monotone non-decreasing -/
theorem size_mono (K : KnowledgeCatalog) : Monotone K.size := by
  intro a b hab
  unfold size
  apply Finset.card_le_card
  induction hab with
  | refl => exact Finset.Subset.refl _
  | step h ih => exact Finset.Subset.trans ih (K.monotone _)

/-- The number of new theorems discovered at step n -/
def newTheorems (K : KnowledgeCatalog) (n : ℕ) : ℕ :=
  (K.theorems (n + 1) \ K.theorems n).card

/-
After N steps, catalog size equals initial size plus total discoveries
-/
theorem size_sum (K : KnowledgeCatalog) (N : ℕ) :
    K.size N = K.size 0 + ∑ i ∈ Finset.range N, K.newTheorems i := by
  induction N <;> simp_all +decide [ Finset.sum_range_succ ];
  rw [ ← add_assoc, ← ‹K.size _ = K.size 0 + ∑ i ∈ Finset.range _, K.newTheorems i› ];
  unfold KnowledgeCatalog.size KnowledgeCatalog.newTheorems;
  rw [ ← Finset.card_union_of_disjoint ];
  · rw [ Finset.union_sdiff_of_subset ( K.monotone _ ) ];
  · exact Finset.disjoint_sdiff

end KnowledgeCatalog

/-! ## 2. Prompt Quality and Optimal Selection -/

/-- A prompt strategy assigns a quality score to each prompt given catalog state -/
structure PromptStrategy where
  /-- Quality score: how much new math a prompt yields given catalog size -/
  quality : ℕ → ℕ → ℝ
  /-- Quality is non-negative -/
  quality_nonneg : ∀ n k, 0 ≤ quality n k

/-- The greedy strategy always picks the prompt with highest expected yield -/
noncomputable def greedyYield (P : PromptStrategy) (catalogSize : ℕ) : ℝ :=
  ⨆ k, P.quality catalogSize k

/-- A discovery reward function models diminishing returns -/
structure DiminishingReturns where
  /-- Reward at step n -/
  reward : ℕ → ℝ
  /-- Rewards are non-negative -/
  reward_nonneg : ∀ n, 0 ≤ reward n
  /-- Rewards are decreasing -/
  reward_anti : Antitone reward

/-- Under diminishing returns, total reward is bounded by N times the first reward -/
theorem diminishing_total_bound (D : DiminishingReturns) (N : ℕ) :
    ∑ i ∈ Finset.range N, D.reward i ≤ N * D.reward 0 := by
  calc ∑ i ∈ Finset.range N, D.reward i
      ≤ ∑ _ ∈ Finset.range N, D.reward 0 := by
        apply Finset.sum_le_sum
        intro i _
        exact D.reward_anti (Nat.zero_le i)
    _ = N * D.reward 0 := by
        rw [Finset.sum_const, nsmul_eq_mul, Finset.card_range]

/-! ## 3. Convergence of the Discovery Process -/

/-- A bounded monotone sequence converges. We state this for the discovery rate. -/
theorem discovery_rate_converges
    (rate : ℕ → ℝ) (h_mono : Antitone rate)
    (h_bound : ∀ n, 0 ≤ rate n) :
    ∃ L, Filter.Tendsto rate Filter.atTop (nhds L) := by
  obtain (h | ⟨l, hl⟩) := tendsto_atTop_of_antitone h_mono
  · exfalso
    have h0 := h_bound 0
    obtain ⟨n, hn⟩ := (Filter.tendsto_atBot.mp h (-1)).exists
    have := h_bound n
    linarith
  · exact ⟨l, hl⟩

/-
The cumulative discovery function is subadditive under diminishing returns
-/
theorem cumulative_subadditive
    (f : ℕ → ℝ) (h_conc : ∀ n, f (n + 1) - f n ≤ f n - f (n - 1))
    (h0 : f 0 = 0) (h_mono : Monotone f) (n m : ℕ) :
    f (n + m) ≤ f n + f m := by
  -- By induction on $m$, we can show that $f(n+m) - f(n) \leq f(m) - f(0)$.
  have h_ind : ∀ n m, f (n + m) - f n ≤ f m - f 0 := by
    intro n m;
    induction' m with m ih;
    · norm_num;
    · have h_step : ∀ k ≤ n, f (k + m + 1) - f (k + m) ≤ f (m + 1) - f m := by
        intro k hk; induction' k with k ih <;> norm_num at *;
        grind;
      have := h_step n le_rfl; ring_nf at *; linarith;
  linarith [ h_ind n m ]

/-! ## 4. Regret Bounds for the Self-Improving Loop -/

/-- The regret of a strategy compared to an oracle that knows the optimal sequence -/
def regret (actual optimal : ℕ → ℝ) (N : ℕ) : ℝ :=
  ∑ i ∈ Finset.range N, (optimal i - actual i)

/-- Non-negative regret when optimal is at least as good as actual -/
theorem regret_nonneg (actual optimal : ℕ → ℝ) (N : ℕ)
    (h : ∀ i, actual i ≤ optimal i) :
    0 ≤ regret actual optimal N := by
  unfold regret
  apply Finset.sum_nonneg
  intro i _
  linarith [h i]

/-- Logarithmic regret bound for explore-exploit prompt selection -/
theorem log_regret_bound (actual optimal : ℕ → ℝ)
    (h_decay : ∀ i, optimal i - actual i ≤ 1 / (↑i + 1))
    (N : ℕ) :
    regret actual optimal N ≤ ∑ i ∈ Finset.range N, (1 / (↑i + 1) : ℝ) := by
  unfold regret
  apply Finset.sum_le_sum
  intro i _
  exact h_decay i

/-! ## 5. Fixed Point of the Self-Improving Loop -/

/-- A self-improving loop has a fixed point when the discovery rate reaches zero -/
structure SelfImprovingLoop where
  /-- State of the catalog at each step -/
  state : ℕ → ℝ
  /-- Transition function: maps current state to next state -/
  transition : ℝ → ℝ
  /-- The loop follows the transition function -/
  evolution : ∀ n, state (n + 1) = transition (state n)
  /-- The transition is contractive -/
  contractive : ∃ c : ℝ, 0 ≤ c ∧ c < 1 ∧
    ∀ x y, |transition x - transition y| ≤ c * |x - y|

/-
A contractive self-improving loop converges to a fixed point
-/
theorem loop_converges (L : SelfImprovingLoop) :
    ∃ fixedPt, Filter.Tendsto L.state Filter.atTop (nhds fixedPt) := by
  -- By definition of $L$, we know that its transition function is contractive.
  obtain ⟨c, hc₀, hc₁, hc₂⟩ := L.contractive;
  -- By induction, we can show that |state (n+1) - state n| ≤ c^n * |state 1 - state 0|.
  have h_induction : ∀ n, |L.state (n + 1) - L.state n| ≤ c^n * |L.state 1 - L.state 0| := by
    intro n; induction' n with n ih <;> simp_all +decide [ pow_succ', mul_assoc ] ;
    simpa only [ L.evolution ] using le_trans ( hc₂ _ _ ) ( mul_le_mul_of_nonneg_left ih hc₀ );
  -- The sequence is Cauchy, hence it converges.
  have h_cauchy : CauchySeq L.state := by
    fapply cauchySeq_of_le_geometric;
    exacts [ c, |L.state 1 - L.state 0|, hc₁, fun n => by simpa [ mul_comm, abs_sub_comm ] using h_induction n ];
  exact ⟨ _, h_cauchy.tendsto_limUnder ⟩

/-- At the fixed point, no new discoveries are made (steady state) -/
theorem fixed_point_steady_state (L : SelfImprovingLoop) (fp : ℝ)
    (h_conv : Filter.Tendsto L.state Filter.atTop (nhds fp)) :
    Filter.Tendsto (fun n => L.state (n + 1) - L.state n) Filter.atTop (nhds 0) := by
  have h1 : Filter.Tendsto (fun n => L.state (n + 1)) Filter.atTop (nhds fp) :=
    h_conv.comp (Filter.tendsto_atTop_atTop.mpr fun b => ⟨b, fun n hn => by omega⟩)
  have h2 := Filter.Tendsto.sub h1 h_conv
  simp at h2
  exact h2

/-! ## 6. Information-Theoretic Bounds on Discovery -/

/-- Shannon entropy of the catalog's theorem distribution -/
noncomputable def catalogEntropy {n : ℕ} (p : Fin n → ℝ) : ℝ :=
  -∑ i, p i * Real.log (p i)

/-- The mutual information between prompts and discoveries is bounded -/
theorem mutual_info_bound (H_prompt H_discovery H_joint : ℝ)
    (h_joint : H_joint ≤ H_prompt + H_discovery) :
    H_prompt + H_discovery - H_joint ≥ 0 := by
  linarith

/-! ## 7. Composition Theorem: Bridging All Domains -/

/-- Cross-pollination: total synergistic value exceeds isolated sum -/
theorem cross_pollination_superadditive
    (D : ℕ) (synergy : Fin D → Fin D → ℝ)
    (h_nonneg : ∀ i j, 0 ≤ synergy i j)
    (h_self : ∀ i, 1 ≤ synergy i i)
    (values : Fin D → ℝ) (hv : ∀ i, 0 ≤ values i) :
    ∑ i, values i ≤ ∑ i, ∑ j, synergy i j * values j := by
  apply Finset.sum_le_sum
  intro i _
  calc values i = 1 * values i := (one_mul _).symm
    _ ≤ synergy i i * values i :=
        mul_le_mul_of_nonneg_right (h_self i) (hv i)
    _ ≤ ∑ j, synergy i j * values j :=
        Finset.single_le_sum (fun j _ => mul_nonneg (h_nonneg i j) (hv j))
          (Finset.mem_univ i)