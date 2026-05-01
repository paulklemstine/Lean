/-! # CatalogBuild.MachineLearning.SelfImproving.ConvergenceTheory

Auto-generated from theorem catalog database.
Domain: MachineLearning/SelfImproving
Declarations: 9
-/

import Mathlib

noncomputable section

/-- [Section: ## 1. Banach Fixed Point for Loop Operators] -/
theorem geometric_improvement_bound
    (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1) (r : ℝ) (hr : 0 ≤ r) (N : ℕ) :
    ∑ i ∈ Finset.range N, c ^ i * r ≤ r / (1 - c) := by
  rw [ ← Finset.sum_mul _ _ _ ];
  exact le_trans ( mul_le_mul_of_nonneg_right ( show ∑ i ∈ Finset.range N, c ^ i ≤ ( 1 - c ) ⁻¹ from by rw [ ← tsum_geometric_of_lt_one hc0 hc1 ] ; exact Summable.sum_le_tsum ( Finset.range N ) ( fun i _ => by positivity ) ( by exact summable_geometric_of_lt_one hc0 hc1 ) ) hr ) ( by ring_nf; norm_num )


/-- A set function is submodular if it has diminishing marginal returns -/
def IsSubmodular (f : Finset ℕ → ℝ) : Prop :=
  ∀ A B : Finset ℕ, A ⊆ B →
    ∀ x, x ∉ B →
      f (A ∪ {x}) - f A ≥ f (B ∪ {x}) - f B


/-- [Section: ## 2. Submodular Optimization for Prompt Selection] -/
theorem submodular_equiv (f : Finset ℕ → ℝ) :
    IsSubmodular f ↔
    ∀ A B : Finset ℕ, f (A ∪ B) + f (A ∩ B) ≤ f A + f B := by
  constructor;
  · -- Let's choose any two sets $A$ and $B$ and apply the submodularity condition to them.
    intro h_submodular A B
    have h_inter : ∀ (A B : Finset ℕ), A ⊆ B → ∀ x, x ∉ B → f (A ∪ {x}) - f A ≥ f (B ∪ {x}) - f B := by
      exact h_submodular;
    -- Let's choose any two sets $A$ and $B$ and apply the submodularity condition to them by considering the elements in $B \setminus A$.
    have h_diff : ∀ (A B : Finset ℕ), A ⊆ B → ∀ (C : Finset ℕ), C ∩ B = ∅ → f (B ∪ C) - f B ≤ f (A ∪ C) - f A := by
      intros A B hAB C hC_disjoint
      induction' C using Finset.induction with x C hx ih generalizing A B;
      · norm_num;
      · specialize ih ( A ∪ { x } ) ( B ∪ { x } ) ; simp_all +decide [ Finset.union_comm, Finset.union_left_comm, Finset.union_assoc ];
        grind +splitImp;
    have := h_diff ( A ∩ B ) B ( Finset.inter_subset_right ) ( A \ B ) ?_ <;> simp_all +decide [ Finset.inter_comm, Finset.inter_left_comm, Finset.inter_assoc ];
    rw [ show A ∩ B ∪ A \ B = A by ext x; by_cases hx : x ∈ B <;> aesop ] at this ; rw [ Finset.union_comm ] at this ; linarith;
  · intro h A B hAB x hx;
    have := h ( A ∪ { x } ) B; simp_all +decide [ Finset.union_comm, Finset.inter_comm, Finset.union_assoc, Finset.inter_assoc, Finset.union_inter_cancel_left, Finset.union_inter_cancel_right ] ;
    rw [ Finset.union_eq_right.mpr hAB ] at this; simp_all +decide [ Finset.inter_eq_left.mpr hAB ] ; linarith;


/-- A knowledge graph tracks theorems and their dependencies -/
structure KnowledgeGraph where
  /-- Vertices = theorems -/
  vertices : Finset ℕ
  /-- Edges = logical dependencies -/
  edges : Finset (ℕ × ℕ)
  /-- Edges connect vertices -/
  edge_valid : ∀ e ∈ edges, e.1 ∈ vertices ∧ e.2 ∈ vertices


/-- Dense knowledge graphs have quadratic edge potential -/
theorem bridge_density (n e : ℕ) (he : 2 * e ≤ n * n) :
    e ≤ n * n := by omega


/-- Value function: expected total future discoveries from state s -/
noncomputable def valueFunction (gamma : ℝ) (reward : ℕ → ℝ) (N : ℕ) : ℝ :=
  ∑ i ∈ Finset.range N, gamma ^ i * reward i


/-- [Section: ## 4. Bellman Equation for Optimal Prompt Sequencing] -/
theorem bellman_recursion (gamma : ℝ) (reward : ℕ → ℝ) (N : ℕ) :
    valueFunction gamma reward (N + 1) =
    reward 0 + gamma * valueFunction gamma (fun n => reward (n + 1)) N := by
  unfold valueFunction; simp +decide [ Finset.sum_range_succ', pow_succ' ] ; ring;
  simp +decide only [mul_assoc, Finset.mul_sum _ _ _]


theorem discounted_reward_bound
    (gamma : ℝ) (hg0 : 0 ≤ gamma) (hg1 : gamma < 1)
    (reward : ℕ → ℝ) (R : ℝ) (hR : ∀ n, |reward n| ≤ R) (hR0 : 0 ≤ R)
    (N : ℕ) :
    |valueFunction gamma reward N| ≤ R / (1 - gamma) := by
  refine' le_trans _ ( geometric_improvement_bound _ ( by positivity ) hg1 _ hR0 _ );
  swap;
  exacts [ N, le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => by simpa [ abs_mul, abs_of_nonneg ( pow_nonneg hg0 _ ) ] using mul_le_mul_of_nonneg_left ( hR i ) ( pow_nonneg hg0 _ ) ) ]


/-- UCB-style upper confidence bound for prompt selection -/
noncomputable def ucb (mean : ℝ) (n_total n_prompt : ℕ) (c : ℝ) : ℝ :=
  mean + c * Real.sqrt (Real.log n_total / n_prompt)


end
