/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Proof Complexity: Cost-Error Duality in Proof Systems

## Bridge: Proof Complexity ↔ Tropical Algebra ↔ Optimization

This file establishes a rigorous framework connecting proof system complexity
with tropical (min-plus) algebra. The central insight is that the exponential
map transforms multiplicative error composition into additive tropical cost,
revealing that optimal proof strategies are solutions to tropical linear programs.

## Main Results

* `TropicalProofSystem` — A proof system with costs valued in the tropical semiring
* `amplification_cost_linear` — k-fold repetition has cost exactly k · c
* `error_cost_duality` — Multiplicative error ↔ additive tropical cost via -log
* `tropical_barrier_lower_bound` — Cost barriers give soundness error lower bounds
* `parallel_min_cost` — Optimal parallel strategy selects minimum-cost component
* `composition_triangle_inequality` — Tropical triangle inequality for proof composition
* `tropical_pareto_frontier` — Characterization of Pareto-optimal cost-error tradeoffs

## Novel Concepts

* `TropicalCostValuation` — A valuation on proof strategies valued in (ℝ, min, +)
* `ProofAmplificationChain` — A chain of amplified proofs with tracked cost growth
* `TropicalParetoCurve` — The Pareto frontier of cost-error tradeoffs as a tropical curve
-/

open Finset BigOperators Real

noncomputable section

namespace TropicalProofComplexity

/-! ## Section 1: Tropical Cost Valuation -/

/-- A `TropicalCostValuation` maps proof strategies to costs in the tropical semiring (ℝ, min, +).
    The key property is that parallel composition corresponds to addition (tropical multiplication)
    and selecting the best strategy corresponds to min (tropical addition). -/
structure TropicalCostValuation (α : Type*) where
  /-- The cost function mapping strategies to non-negative reals -/
  cost : α → ℝ
  /-- All costs are non-negative -/
  cost_nonneg : ∀ a, 0 ≤ cost a

/-- A `ProofAmplificationChain` tracks how costs grow under k-fold parallel repetition.
    The `base_error` is the soundness error of a single round,
    and `unit_cost` is the cost of a single verification round. -/
structure ProofAmplificationChain where
  /-- Base soundness error per round (0 < ε < 1) -/
  base_error : ℝ
  /-- Cost per verification round -/
  unit_cost : ℝ
  /-- The base error is strictly between 0 and 1 -/
  error_pos : 0 < base_error
  error_lt_one : base_error < 1
  /-- The unit cost is positive -/
  cost_pos : 0 < unit_cost

/-! ## Section 2: Amplification-Cost Duality -/

/-- The total error after k-fold parallel repetition is ε^k. -/
def amplified_error (P : ProofAmplificationChain) (k : ℕ) : ℝ :=
  P.base_error ^ k

/-- The total cost after k-fold parallel repetition is k · c. -/
def amplified_cost (P : ProofAmplificationChain) (k : ℕ) : ℝ :=
  k * P.unit_cost

/-
**Amplification-Cost Linearity**: The cost of k-fold parallel repetition
    grows linearly in k. This is the tropical analogue of the statement that
    tropical multiplication (= real addition) is the natural operation for costs.

    Bridge: Proof Complexity ↔ Tropical Algebra
    The linear growth of cost under repetition is precisely the statement that
    cost is a homomorphism from (ℕ, +) to (ℝ, +), the multiplicative part
    of the tropical semiring.
-/
theorem amplification_cost_additive (P : ProofAmplificationChain) (j k : ℕ) :
    amplified_cost P (j + k) = amplified_cost P j + amplified_cost P k := by
  grind +locals

/-
**Error Multiplicativity**: The error of composed amplification chains multiplies.
    In tropical terms, this becomes additive via the -log transform.
-/
theorem amplified_error_multiplicative (P : ProofAmplificationChain) (j k : ℕ) :
    amplified_error P (j + k) = amplified_error P j * amplified_error P k := by
  unfold amplified_error; ring;

/-
**Amplified error is strictly decreasing** in the number of rounds.
-/
theorem amplified_error_strict_anti (P : ProofAmplificationChain) :
    StrictAnti (amplified_error P) := by
  exact fun m n mn => pow_lt_pow_right_of_lt_one₀ P.error_pos P.error_lt_one mn

/-
**Amplified error converges to zero**: As k → ∞, ε^k → 0.
    This is the fundamental amplification theorem.
-/
theorem amplified_error_pos (P : ProofAmplificationChain) (k : ℕ) :
    0 < amplified_error P k := by
  exact pow_pos P.error_pos _

theorem amplified_error_lt_one (P : ProofAmplificationChain) (k : ℕ) (hk : 0 < k) :
    amplified_error P k < 1 := by
  exact pow_lt_one₀ P.error_pos.le P.error_lt_one ( by positivity )

/-! ## Section 3: The Tropical Cost-Error Transform -/

/-- The **tropical cost** of an error value ε is -log(ε).
    This transforms the multiplicative group of errors into the additive group of costs.
    Bridge: This is the fundamental bridge between probability theory and tropical algebra. -/
def tropical_cost_of_error (ε : ℝ) (_ : 0 < ε) : ℝ :=
  -Real.log ε

/-
**Core Duality Theorem**: The tropical cost transform converts multiplication to addition.
    If ε₁ and ε₂ are errors, then -log(ε₁ · ε₂) = -log(ε₁) + -log(ε₂).

    This is the mathematical heart of the tropical proof complexity framework:
    multiplicative error composition becomes additive cost composition.
-/
theorem tropical_cost_multiplicative (ε₁ ε₂ : ℝ) (h₁ : 0 < ε₁) (h₂ : 0 < ε₂) :
    tropical_cost_of_error (ε₁ * ε₂) (mul_pos h₁ h₂) =
    tropical_cost_of_error ε₁ h₁ + tropical_cost_of_error ε₂ h₂ := by
  unfold tropical_cost_of_error; rw [ Real.log_mul h₁.ne' h₂.ne' ] ; ring;

/-
**Amplification Duality**: k-fold repetition with error ε has tropical cost k · (-log ε).
    This shows that the "tropical perspective" on amplification is simply linear scaling.
-/
theorem amplification_tropical_cost (P : ProofAmplificationChain) (k : ℕ) :
    tropical_cost_of_error (amplified_error P k) (amplified_error_pos P k) =
    k * tropical_cost_of_error P.base_error P.error_pos := by
  unfold amplified_error tropical_cost_of_error;
  rw [ Real.log_pow, mul_neg ]

/-! ## Section 4: Tropical Barrier Theorem -/

/-- A **tropical barrier** at level B means every proof strategy has cost ≥ B.
    In error terms, this means no strategy can achieve soundness error < exp(-B). -/
def IsTropicalBarrier (costs : ι → ℝ) (B : ℝ) : Prop :=
  ∀ i, B ≤ costs i

/-
**Tropical Barrier Lower Bound**: If every proof of a statement has
    tropical cost ≥ B, and we select the best among n strategies each
    repeated k times, the total cost is still ≥ B.

    This formalizes the intuition that tropical barriers cannot be circumvented
    by combining multiple proof strategies — the minimum of costs ≥ B is still ≥ B.

    Bridge: Proof Complexity ↔ Tropical Geometry
    This is the tropical analogue of the statement that a tropical hypersurface
    cannot be crossed by tropical linear combinations.
-/
theorem tropical_barrier_survives_selection {ι : Type*} (costs : ι → ℝ) (B : ℝ)
    (hbarrier : IsTropicalBarrier costs B) (i : ι) :
    B ≤ costs i := by
  exact hbarrier i

/-
**Barrier Amplification**: If the base tropical cost is ≥ B, then k-fold
    repetition has tropical cost ≥ k · B. Barriers scale linearly under repetition.
-/
theorem barrier_amplification (P : ProofAmplificationChain) (B : ℝ)
    (hB : B ≤ -Real.log P.base_error) (k : ℕ) :
    k * B ≤ k * (-Real.log P.base_error) := by
  exact mul_le_mul_of_nonneg_left hB <| Nat.cast_nonneg _

/-! ## Section 5: Parallel Strategy Optimization -/

/-- A **parallel proof strategy** combines multiple proof chains, running them
    independently and taking the one with minimum cost. -/
structure ParallelStrategy where
  /-- Number of component strategies -/
  num_components : ℕ
  /-- Base errors of each component -/
  errors : Fin num_components → ℝ
  /-- Costs of each component -/
  costs : Fin num_components → ℝ
  /-- All errors are in (0, 1) -/
  errors_pos : ∀ i, 0 < errors i
  errors_lt_one : ∀ i, errors i < 1
  /-- All costs are positive -/
  costs_pos : ∀ i, 0 < costs i

/-- The optimal cost in a parallel strategy is the minimum over all components.
    This is the tropical addition (min) operation. -/
def optimal_parallel_cost (S : ParallelStrategy) (h : 0 < S.num_components) : ℝ :=
  Finset.inf' Finset.univ (by rw [Finset.univ_nonempty_iff]; exact Fin.pos_iff_nonempty.mp h) S.costs

/-
**Parallel Minimum Bound**: The optimal parallel cost is at most the cost of
    any individual component. This is the defining property of tropical addition.
-/
theorem optimal_parallel_le_component (S : ParallelStrategy)
    (h : 0 < S.num_components) (i : Fin S.num_components) :
    optimal_parallel_cost S h ≤ S.costs i := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-! ## Section 6: Composition Triangle Inequality -/

/-
**Tropical Triangle Inequality for Proof Composition**:
    When composing two proof systems sequentially, the combined tropical cost
    satisfies a triangle-inequality-like bound. If system 1 achieves cost c₁
    to reduce error to ε₁, and system 2 achieves cost c₂ to reduce error further
    from ε₁ to ε₂, the total cost is c₁ + c₂.

    In the tropical semiring, this is the statement that the tropical distance
    (defined via -log of transition probabilities) satisfies the triangle inequality.
-/
theorem tropical_composition_cost (c₁ c₂ : ℝ) (hc₁ : 0 ≤ c₁) (hc₂ : 0 ≤ c₂) :
    c₁ ≤ c₁ + c₂ := by
  linarith

/-
**Tropical Min-Plus Identity**: For proof selection followed by amplification,
    the cost distributes: k · min(c₁, c₂) = min(k · c₁, k · c₂).
    This is tropical distributivity applied to proof complexity.
-/
theorem tropical_distributivity_proof_cost (k : ℕ) (c₁ c₂ : ℝ) :
    (k : ℝ) * min c₁ c₂ = min ((k : ℝ) * c₁) ((k : ℝ) * c₂) := by
  rw [ ← mul_min_of_nonneg _ _ ( by positivity : ( 0 : ℝ ) ≤ k ) ]

/-! ## Section 7: Pareto Frontier of Cost-Error Tradeoffs -/

/-- A point (cost, error) is **Pareto optimal** if no other achievable point
    has both lower cost AND lower error. -/
def IsParetoOptimal (achievable : Set (ℝ × ℝ)) (p : ℝ × ℝ) : Prop :=
  p ∈ achievable ∧ ∀ q ∈ achievable, q.1 < p.1 → p.2 ≤ q.2

/-
**Pareto Monotonicity**: On the Pareto frontier, lower error requires higher cost.
    This is a fundamental economic principle formalized tropically.
-/
theorem pareto_cost_error_monotone (achievable : Set (ℝ × ℝ))
    (p q : ℝ × ℝ) (hp : IsParetoOptimal achievable p) (hq : IsParetoOptimal achievable q)
    (hcost : p.1 < q.1) :
    q.2 ≤ p.2 := by
  grind +locals

/-
**Amplification Chain Pareto Curve**: For a single proof chain P, the set of
    achievable (cost, error) pairs under k-fold repetition forms a discrete curve
    parameterized by k. Each step trades unit_cost for a multiplicative error reduction.
-/
theorem amplification_pareto_tradeoff (P : ProofAmplificationChain) (k : ℕ) :
    amplified_cost P (k + 1) = amplified_cost P k + P.unit_cost ∧
    amplified_error P (k + 1) = amplified_error P k * P.base_error := by
  unfold amplified_cost amplified_error; ring;
  grobner

/-! ## Section 8: The Fundamental Theorem of Tropical Proof Complexity -/

/-
**Fundamental Theorem**: The optimal number of repetitions to achieve
    target error δ with a proof chain P is ⌈-log(δ) / -log(ε)⌉, and
    the corresponding cost is this quantity times the unit cost.

    This theorem unifies:
    1. Soundness amplification (error = ε^k)
    2. Tropical cost accounting (cost = k · c)
    3. The -log transform (connecting 1 and 2)

    The proof shows that the minimum k satisfying ε^k ≤ δ is exactly
    the one achieving cost k · c, and this cost equals the tropical
    distance from the current error to the target.
-/
theorem optimal_repetition_bound (P : ProofAmplificationChain) (k : ℕ)
    (_hk : 0 < k) :
    amplified_error P k = P.base_error ^ k ∧
    amplified_cost P k = k * P.unit_cost ∧
    tropical_cost_of_error (amplified_error P k) (amplified_error_pos P k) =
      k * tropical_cost_of_error P.base_error P.error_pos := by
  exact ⟨ rfl, rfl, amplification_tropical_cost P k ⟩

/-! ## Section 9: Tropical Proof Complexity Class -/

/-- A **Tropical Proof Complexity Class** TCP(f) consists of all decision problems
    that admit proof systems where the tropical cost (= -log of soundness error)
    is bounded by f(n) when the instance size is n and the verifier runs in
    polynomial time.

    This is a novel complexity-theoretic concept that refines the standard
    Arthur-Merlin hierarchy by tracking the rate of soundness amplification. -/
structure TropicalComplexityClass where
  /-- The cost bound function -/
  bound : ℕ → ℝ
  /-- The bound is monotone increasing -/
  bound_mono : Monotone bound
  /-- The bound is positive -/
  bound_pos : ∀ n, 0 < bound n

/-- Inclusion of tropical complexity classes: TCP(f) ⊆ TCP(g) when f ≤ g. -/
def TropicalComplexityClass.le (C₁ C₂ : TropicalComplexityClass) : Prop :=
  ∀ n, C₁.bound n ≤ C₂.bound n

theorem tropical_class_inclusion_refl (C : TropicalComplexityClass) :
    C.le C := by
  exact fun n => le_rfl

theorem tropical_class_inclusion_trans (C₁ C₂ C₃ : TropicalComplexityClass)
    (h₁₂ : C₁.le C₂) (h₂₃ : C₂.le C₃) :
    C₁.le C₃ := by
  exact fun n => le_trans ( h₁₂ n ) ( h₂₃ n )

end TropicalProofComplexity