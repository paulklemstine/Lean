import Mathlib

/-! # CatalogBuild.Speculative.Other.OptimalPlanning

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20
-/

noncomputable section

/-- A deterministic Markov Decision Process with finite state and action spaces. -/
structure MDP where
  /-- The state space (finite) -/
  State : Type
  /-- The action space (finite) -/
  Action : Type
  /-- State space is finite -/
  [state_fin : Fintype State]
  [state_dec : DecidableEq State]
  [state_nonempty : Nonempty State]
  /-- Action space is finite and nonempty -/
  [action_fin : Fintype Action]
  [action_nonempty : Nonempty Action]
  /-- Deterministic transition function -/
  transition : State → Action → State
  /-- Reward function, bounded -/
  reward : State → Action → ℝ
  /-- Discount factor -/
  gamma : ℝ
  /-- Discount factor is in [0, 1) -/
  gamma_nonneg : 0 ≤ gamma
  gamma_lt_one : gamma < 1

attribute [instance] MDP.state_fin MDP.state_dec MDP.state_nonempty MDP.action_fin MDP.action_nonempty

/-- A value function assigns a real number to each state. -/
def ValueFn (M : MDP) := M.State → ℝ

/-- A policy maps states to actions. -/
def Policy (M : MDP) := M.State → M.Action

/-- The Bellman optimality operator: (BV)(s) = max_a [R(s,a) + γ · V(T(s,a))].
For each state, it picks the action that maximizes immediate reward plus
discounted future value. -/
def bellmanOp (M : MDP) (V : ValueFn M) : ValueFn M := fun s =>
  Finset.sup' Finset.univ Finset.univ_nonempty
    (fun a => M.reward s a + M.gamma * V (M.transition s a))

/-- The greedy policy with respect to a value function:
π(s) = argmax_a [R(s,a) + γ · V(T(s,a))]. -/
def greedyPolicy (M : MDP) (V : ValueFn M) : Policy M := fun s =>
  (Finite.exists_max (fun a : M.Action => M.reward s a + M.gamma * V (M.transition s a))).choose

/-- Value iteration: apply the Bellman operator n times starting from zero. -/
def valueIteration (M : MDP) : ℕ → ValueFn M
  | 0 => fun _ => 0
  | n + 1 => bellmanOp M (valueIteration M n)

/-- The sup-norm distance between two value functions. -/
def supDist (M : MDP) (V₁ V₂ : ValueFn M) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun s => |V₁ s - V₂ s|)

/-- [Section: # CatalogBuild.Speculative.Other.OptimalPlanning
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20] -/
theorem supDist_nonneg (M : MDP) (V₁ V₂ : ValueFn M) : 0 ≤ supDist M V₁ V₂ := by
  exact Finset.le_sup' ( fun s => |V₁ s - V₂ s| ) ( Finset.mem_univ ( Classical.arbitrary M.State ) ) |> le_trans ( abs_nonneg _ )

/-- [Section: # CatalogBuild.Speculative.Other.OptimalPlanning
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20] -/
theorem pointwise_le_supDist (M : MDP) (V₁ V₂ : ValueFn M) (s : M.State) :
    |V₁ s - V₂ s| ≤ supDist M V₁ V₂ := by
  exact Finset.le_sup' ( fun s => |V₁ s - V₂ s| ) ( Finset.mem_univ s )

theorem bellman_monotone (M : MDP) (V₁ V₂ : ValueFn M) (h : ∀ s, V₁ s ≤ V₂ s) :
    ∀ s, bellmanOp M V₁ s ≤ bellmanOp M V₂ s := by
  intro s
  unfold bellmanOp
  apply Finset.sup'_le
  intro a ha
  simp [h];
  exact ⟨ a, by nlinarith [ h ( M.transition s a ), M.gamma_nonneg ] ⟩

theorem bellman_contraction (M : MDP) (V₁ V₂ : ValueFn M) :
    supDist M (bellmanOp M V₁) (bellmanOp M V₂) ≤ M.gamma * supDist M V₁ V₂ := by
  -- For any state/controller pair (s, a), we have |R(s,a) + γ*V₁(T(s,a)) - (R(s,a) + γ*V₂(T(s,a)))| ≤ γ * supDist M V₁ V₂.
  have h_diff : ∀ s a, |M.reward s a + M.gamma * V₁ (M.transition s a) - (M.reward s a + M.gamma * V₂ (M.transition s a))| ≤ M.gamma * supDist M V₁ V₂ := by
    intro s a; rw [ abs_le ] ; constructor <;> nlinarith [ abs_le.mp ( show |V₁ ( M.transition s a ) - V₂ ( M.transition s a )| ≤ supDist M V₁ V₂ from pointwise_le_supDist M V₁ V₂ _ ), show 0 ≤ M.gamma by linarith [ M.gamma_nonneg ] ] ;
  -- For any state/controller pair (s, a), we have |sup' over actions of (R(s,a) + γ*V₁(T(s,a))) - sup' over actions of (R(s,a) + γ*V₂(T(s,a)))| ≤ γ * supDist M V₁ V₂.
  have h_sup_diff : ∀ s, |Finset.sup' Finset.univ Finset.univ_nonempty (fun a => M.reward s a + M.gamma * V₁ (M.transition s a)) - Finset.sup' Finset.univ Finset.univ_nonempty (fun a => M.reward s a + M.gamma * V₂ (M.transition s a))| ≤ M.gamma * supDist M V₁ V₂ := by
    intros s
    have h_sup_diff : ∀ a, M.reward s a + M.gamma * V₁ (M.transition s a) ≤ M.reward s a + M.gamma * V₂ (M.transition s a) + M.gamma * supDist M V₁ V₂ := by
      exact fun a => by linarith [ abs_le.mp ( h_diff s a ) ] ;
    have h_sup_diff' : ∀ a, M.reward s a + M.gamma * V₂ (M.transition s a) ≤ M.reward s a + M.gamma * V₁ (M.transition s a) + M.gamma * supDist M V₁ V₂ := by
      exact fun a => by linarith [ abs_le.mp ( h_diff s a ) ] ;
    refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
    · simp +zetaDelta at *;
      exact fun a => le_trans ( h_sup_diff a ) ( by linarith [ Finset.le_sup' ( fun a => M.reward s a + M.gamma * V₂ ( M.transition s a ) ) ( Finset.mem_univ a ) ] );
    · simp_all +decide [ Finset.sup'_add ];
      exact fun a => le_trans ( h_sup_diff' a ) ( by linarith [ Finset.le_sup' ( fun a => M.reward s a + M.gamma * V₁ ( M.transition s a ) ) ( Finset.mem_univ a ) ] );
  exact Finset.sup'_le _ _ fun s _ => h_sup_diff s

/-- A value function is a fixed point of the Bellman operator. -/
def isBellmanFixedPoint (M : MDP) (V : ValueFn M) : Prop :=
  bellmanOp M V = V

theorem bellman_fixedPoint_unique (M : MDP) (V₁ V₂ : ValueFn M)
    (h₁ : isBellmanFixedPoint M V₁) (h₂ : isBellmanFixedPoint M V₂) :
    V₁ = V₂ := by
  -- Apply the contraction property to get that the distance between the Bellman operators is less than or equal to γ times the distance between the original functions.
  have h_contra : supDist M (bellmanOp M V₁) (bellmanOp M V₂) ≤ M.gamma * supDist M V₁ V₂ := by
    exact bellman_contraction M V₁ V₂
  apply funext; intro s; exact (by
  contrapose! h_contra;
  have h_contra : supDist M V₁ V₂ > 0 := by
    exact lt_of_lt_of_le ( abs_pos.mpr ( sub_ne_zero.mpr h_contra ) ) ( pointwise_le_supDist M V₁ V₂ s );
  exact absurd ( bellman_contraction M V₁ V₂ ) ( by rw [ h₁, h₂ ] ; nlinarith [ M.gamma_nonneg, M.gamma_lt_one ] ))

theorem bellman_idempotent_at_fixedPoint (M : MDP) (V : ValueFn M)
    (hV : isBellmanFixedPoint M V) :
    bellmanOp M (bellmanOp M V) = bellmanOp M V := by
  unfold isBellmanFixedPoint at hV; aesop;

theorem gamma_pow_tendsto_zero (M : MDP) :
    Tendsto (fun n => M.gamma ^ n) atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one M.gamma_nonneg M.gamma_lt_one

/-- **Bellman's Principle of Optimality** (recursive structure):
Value iteration at step n+1 equals the Bellman operator applied to step n. -/
theorem principle_of_optimality (M : MDP) (n : ℕ) :
    valueIteration M (n + 1) = bellmanOp M (valueIteration M n) := by
  rfl

theorem valueIteration_error_bound (M : MDP) (V_star : ValueFn M)
    (hV : isBellmanFixedPoint M V_star) (n : ℕ) :
    supDist M (valueIteration M n) V_star ≤
      M.gamma ^ n * supDist M (valueIteration M 0) V_star := by
  induction' n with n ih;
  · norm_num;
  · -- By the properties of the sup norm and the contraction property of the Bellman operator, we have:
    have h_step : supDist M (bellmanOp M (valueIteration M n)) (bellmanOp M V_star) ≤ M.gamma * supDist M (valueIteration M n) V_star := by
      exact bellman_contraction M (valueIteration M n) V_star
    convert h_step.trans ( mul_le_mul_of_nonneg_left ih M.gamma_nonneg ) using 1 ; ring;
    · rw [ add_comm, principle_of_optimality, hV ];
    · ring

/-- A planning problem is an MDP with an initial state and horizon. -/
structure PlanningProblem where
  mdp : MDP
  initialState : mdp.State
  horizon : ℕ

/-- The meta-planning value: how good each problem is to solve. -/
def metaPlanningValue {n : ℕ} (problems : Fin n → PlanningProblem)
    (values : (i : Fin n) → ValueFn (problems i).mdp) : Fin n → ℝ :=
  fun i => values i (problems i).initialState

/-- The meta-oracle selects the most valuable planning problem. -/
def metaOracleSelect {n : ℕ} [NeZero n]
    (problems : Fin n → PlanningProblem)
    (values : (i : Fin n) → ValueFn (problems i).mdp) : Fin n :=
  (Finite.exists_max (metaPlanningValue problems values)).choose

end
