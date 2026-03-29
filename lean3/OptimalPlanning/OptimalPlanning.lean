import Mathlib

/-!
# Oracle-Guided Optimal Planning: A Formal Theory

## The Bellman Oracle

This file formalizes the connection between **optimal planning** and **oracle theory**.
The key insight: the optimal value function of a Markov Decision Process is the unique
fixed point of the Bellman operator — making it an *oracle* in the algebraic sense
(an idempotent endomorphism whose outputs are self-consistent truths).

## Main Results

1. **Bellman Operator Monotonicity**: If V₁ ≤ V₂ pointwise, then B(V₁) ≤ B(V₂)
2. **Bellman Contraction**: The Bellman operator is a γ-contraction under sup-norm
3. **Optimal Value Uniqueness**: The fixed point of the Bellman operator is unique
4. **Oracle Connection**: The converged Bellman operator is idempotent (an oracle)
5. **Value Iteration**: Iterating the Bellman operator converges geometrically

## Mathematical Framework

We work with finite state and action spaces, a deterministic transition function,
a bounded reward function, and a discount factor γ ∈ [0, 1).

### References
- Bellman, R. (1957). Dynamic Programming. Princeton University Press.
- Puterman, M. L. (1994). Markov Decision Processes. Wiley.
-/

open Finset Function Set Filter

noncomputable section

/-! ═══════════════════════════════════════════════════════════════════════════
    §1: THE PLANNING PROBLEM — Markov Decision Process Structure
    ═══════════════════════════════════════════════════════════════════════════ -/

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

/-! ═══════════════════════════════════════════════════════════════════════════
    §2: THE BELLMAN OPERATOR
    ═══════════════════════════════════════════════════════════════════════════ -/

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

/-! ═══════════════════════════════════════════════════════════════════════════
    §3: THE SUP-NORM AND CONTRACTION
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- The sup-norm distance between two value functions. -/
def supDist (M : MDP) (V₁ V₂ : ValueFn M) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun s => |V₁ s - V₂ s|)

/-
PROBLEM
The sup-norm distance is nonneg.

PROVIDED SOLUTION
supDist is a Finset.sup' of absolute values which are nonneg. Use le_sup' to get that any single |V₁ s - V₂ s| ≤ supDist, and since |V₁ s - V₂ s| ≥ 0, we get 0 ≤ supDist. Alternatively, apply Finset.le_sup' then use abs_nonneg.
-/
theorem supDist_nonneg (M : MDP) (V₁ V₂ : ValueFn M) : 0 ≤ supDist M V₁ V₂ := by
  exact Finset.le_sup' ( fun s => |V₁ s - V₂ s| ) ( Finset.mem_univ ( Classical.arbitrary M.State ) ) |> le_trans ( abs_nonneg _ )

/-
PROBLEM
Each pointwise distance is bounded by the sup-norm.

PROVIDED SOLUTION
This is directly Finset.le_sup' applied to the function (fun s => |V₁ s - V₂ s|) at s with Finset.mem_univ.
-/
theorem pointwise_le_supDist (M : MDP) (V₁ V₂ : ValueFn M) (s : M.State) :
    |V₁ s - V₂ s| ≤ supDist M V₁ V₂ := by
  exact Finset.le_sup' ( fun s => |V₁ s - V₂ s| ) ( Finset.mem_univ s )

/-
PROBLEM
Monotonicity: if V₁ ≤ V₂ pointwise, then B(V₁) ≤ B(V₂).

PROVIDED SOLUTION
For each state s, bellmanOp M V₁ s = sup' over actions a of (R(s,a) + γ * V₁(T(s,a))). Since V₁ ≤ V₂ pointwise and γ ≥ 0, each term R(s,a) + γ * V₁(T(s,a)) ≤ R(s,a) + γ * V₂(T(s,a)). Then use Finset.sup'_le_sup' or similar to conclude the sup' is monotone.
-/
theorem bellman_monotone (M : MDP) (V₁ V₂ : ValueFn M) (h : ∀ s, V₁ s ≤ V₂ s) :
    ∀ s, bellmanOp M V₁ s ≤ bellmanOp M V₂ s := by
  intro s
  unfold bellmanOp
  apply Finset.sup'_le
  intro a ha
  simp [h];
  exact ⟨ a, by nlinarith [ h ( M.transition s a ), M.gamma_nonneg ] ⟩

/-
PROBLEM
**The Bellman Contraction Theorem**: The Bellman operator is a γ-contraction:
    ‖B(V₁) - B(V₂)‖_∞ ≤ γ · ‖V₁ - V₂‖_∞

PROVIDED SOLUTION
For each state s, we need |bellmanOp M V₁ s - bellmanOp M V₂ s| ≤ γ * supDist M V₁ V₂. The bellmanOp is a sup' over actions. For any two sup' over the same finite nonempty set with functions f and g, |sup' f - sup' g| ≤ sup' |f - g|. Each |f a - g a| = |γ*(V₁(T(s,a)) - V₂(T(s,a)))| = γ*|V₁(T(s,a)) - V₂(T(s,a))| ≤ γ * supDist. So the pointwise difference is ≤ γ * supDist, and taking sup' over states gives the result. Use Finset.sup'_le to show the overall sup' ≤ γ * supDist.
-/
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

/-! ═══════════════════════════════════════════════════════════════════════════
    §4: FIXED POINT UNIQUENESS
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- A value function is a fixed point of the Bellman operator. -/
def isBellmanFixedPoint (M : MDP) (V : ValueFn M) : Prop :=
  bellmanOp M V = V

/-
PROBLEM
**Uniqueness of the Optimal Value Function**: If V₁ and V₂ are both fixed points
    of the Bellman operator, they are equal. Follows from γ-contraction with γ < 1.

PROVIDED SOLUTION
Since V₁ = B(V₁) and V₂ = B(V₂), we have supDist M V₁ V₂ = supDist M (B V₁) (B V₂) ≤ γ * supDist M V₁ V₂ by bellman_contraction. Since γ < 1, the only nonneg real d satisfying d ≤ γ*d is d = 0. So supDist M V₁ V₂ = 0. Then V₁ = V₂ by showing each component is equal (the sup of absolute values being 0 means all differences are 0). Use supDist_nonneg and the fact that d ≤ γ*d with γ<1 gives d ≤ 0, combined with 0 ≤ d gives d = 0. Then use funext and show each |V₁ s - V₂ s| ≤ 0 via pointwise_le_supDist.
-/
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

/-! ═══════════════════════════════════════════════════════════════════════════
    §5: THE ORACLE CONNECTION — Idempotency at the Fixed Point
    ═══════════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
**The Bellman Oracle Theorem**: At a fixed point, the Bellman operator is
    idempotent: B(B(V*)) = B(V*). This connects optimal planning to oracle
    theory — the optimal value function is a "truth" that the Bellman operator
    preserves.

PROVIDED SOLUTION
Since isBellmanFixedPoint M V means bellmanOp M V = V, we have bellmanOp M (bellmanOp M V) = bellmanOp M V by rewriting with hV.
-/
theorem bellman_idempotent_at_fixedPoint (M : MDP) (V : ValueFn M)
    (hV : isBellmanFixedPoint M V) :
    bellmanOp M (bellmanOp M V) = bellmanOp M V := by
  unfold isBellmanFixedPoint at hV; aesop;

/-! ═══════════════════════════════════════════════════════════════════════════
    §6: DISCOUNT FACTOR ANALYSIS
    ═══════════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
γⁿ → 0 as n → ∞ for γ ∈ [0, 1).

PROVIDED SOLUTION
Use tendsto_pow_atTop_nhds_zero_of_lt_one with M.gamma_nonneg and M.gamma_lt_one.
-/
theorem gamma_pow_tendsto_zero (M : MDP) :
    Tendsto (fun n => M.gamma ^ n) atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one M.gamma_nonneg M.gamma_lt_one

/-
PROBLEM
Geometric series convergence: ∑ γⁱ → 1/(1-γ).

PROVIDED SOLUTION
Use hasSum_geometric_of_lt_one M.gamma_nonneg M.gamma_lt_one and convert from HasSum to Tendsto of partial sums. The result gives 1/(1-γ) which equals 1/(1-M.gamma). Use HasSum.tendsto_sum_nat or similar.
-/
theorem geometric_sum_formula (M : MDP) :
    Tendsto (fun n => ∑ i ∈ Finset.range n, M.gamma ^ i)
      atTop (nhds (1 / (1 - M.gamma))) := by
  simpa using ( hasSum_geometric_of_lt_one ( M.gamma_nonneg ) ( M.gamma_lt_one ) ) |> HasSum.tendsto_sum_nat

/-! ═══════════════════════════════════════════════════════════════════════════
    §7: VALUE ITERATION
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- **Bellman's Principle of Optimality** (recursive structure):
    Value iteration at step n+1 equals the Bellman operator applied to step n. -/
theorem principle_of_optimality (M : MDP) (n : ℕ) :
    valueIteration M (n + 1) = bellmanOp M (valueIteration M n) := by
  rfl

/-
PROBLEM
Value iteration error bound: after n steps, the error contracts by γⁿ.

PROVIDED SOLUTION
By induction on n. Base case n=0: supDist M (valueIteration M 0) V_star ≤ γ^0 * supDist M (valueIteration M 0) V_star = 1 * d = d. Holds by le_refl. Inductive case: valueIteration M (n+1) = bellmanOp M (valueIteration M n), and V_star = bellmanOp M V_star (by hV). So supDist M (valueIteration M (n+1)) V_star = supDist M (bellmanOp M (valueIteration M n)) (bellmanOp M V_star) ≤ γ * supDist M (valueIteration M n) V_star ≤ γ * (γ^n * d) = γ^(n+1) * d. Use bellman_contraction and the inductive hypothesis.
-/
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

/-! ═══════════════════════════════════════════════════════════════════════════
    §8: META-ORACLE PLANNING
    ═══════════════════════════════════════════════════════════════════════════ -/

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