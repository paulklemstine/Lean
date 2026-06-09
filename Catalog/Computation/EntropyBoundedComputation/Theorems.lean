/-
# Entropy-Bounded Computation: Main Theorems

This file contains the core theorems of the EBC framework, each with full PEGB:
Proof, Example, Generalization, Boundary.

## Main Results

1. `landauer_cost_additive` — Cost of a step sequence = sum of individual costs
2. `reversible_is_involution` — Reversible computations preserve information
3. `step_count_bounded_by_budget` — Steps ≤ budget / cost-per-step
4. `entropy_gap_unbounded` — The gap between exponential and polynomial cost
   grows without bound
-/

import Mathlib
import Computation.EntropyBoundedComputation.Defs

open Real Finset BigOperators EBC

namespace EBC

/-! ## Theorem 1: Landauer Cost Additivity -/

/-
!-- Unfold totalCost and cost, then factor out tempFactor using Finset.sum_mul_distrib. -- !--

The total cost of a step sequence equals the sum of individual bitsErased
times the temperature factor. Entropy production is additive.
-/
theorem landauer_cost_additive (params : LandauerParams)
    (seq : StepSequence params) :
    seq.totalCost params =
      (∑ i : Fin seq.numSteps, (seq.steps i).bitsErased) * params.tempFactor := by
  unfold StepSequence.totalCost;
  unfold IrreversibleStep.cost; rw [ Finset.sum_mul ] ;

/-
**Example**: Two single-bit erasures have total cost 2 * tempFactor
-/
example (params : LandauerParams) :
    let s1 : IrreversibleStep params := ⟨1, by positivity⟩
    let s2 : IrreversibleStep params := ⟨1, by positivity⟩
    let seq : StepSequence params := ⟨2, ![s1, s2]⟩
    seq.totalCost params = 2 * params.tempFactor := by
  convert landauer_cost_additive params _ ; ring;
  erw [ Fin.sum_univ_two ] ; norm_num

/-
**Generalization**: Cost additivity with per-step weights
-/
theorem landauer_cost_additive_weighted (params : LandauerParams)
    (n : ℕ) (bits : Fin n → ℝ) (_bits_nn : ∀ i, 0 ≤ bits i)
    (weights : Fin n → ℝ) (_weights_nn : ∀ i, 0 ≤ weights i) :
    (∑ i : Fin n, weights i * bits i) * params.tempFactor =
      ∑ i : Fin n, weights i * (bits i * params.tempFactor) := by
  simp +decide only [sum_mul, ← mul_assoc]

/-
**Boundary**: A step sequence with 0 steps has 0 cost
-/
theorem landauer_cost_empty (params : LandauerParams)
    (seq : StepSequence params) (h : seq.numSteps = 0) :
    seq.totalCost params = 0 := by
  cases seq ; aesop

/-! ## Theorem 2: Reversible Computation Preserves Information -/

/-
!-- A reversible computation is backward ∘ forward = id, proved by funext
and the left_inv axiom. -- !--

A reversible computation is an involution: backward ∘ forward = id
-/
theorem reversible_is_involution (α : Type*) (rc : ReversibleComputation α) :
    rc.backward ∘ rc.forward = id := by
  exact funext rc.left_inv

/-
The composition of two reversible computations is reversible
-/
def reversible_compose (α : Type*) (rc1 rc2 : ReversibleComputation α) :
    ReversibleComputation α where
  forward := rc2.forward ∘ rc1.forward
  backward := rc1.backward ∘ rc2.backward
  left_inv x := by
    simp +decide [ rc1.left_inv, rc2.left_inv ]
  right_inv x := by
    simp [Function.comp, rc1.right_inv, rc2.right_inv]

/-
**Example**: NOT gate on Bool is reversible
-/
def notGate : ReversibleComputation Bool where
  forward := (!·)
  backward := (!·)
  left_inv x := by
    cases x <;> rfl
  right_inv x := by cases x <;> rfl

/-
**Generalization**: Any Equiv gives a reversible computation
-/
def reversibleOfEquiv {α : Type*} (e : Equiv α α) : ReversibleComputation α where
  forward := e.toFun
  backward := e.invFun
  left_inv x := by
    exact e.left_inv x
  right_inv x := by exact e.right_inv x

/-
**Boundary**: A non-injective function cannot be reversed
-/
theorem non_injective_not_reversible {α : Type*}
    (f : α → α) (h : ¬Function.Injective f) :
    ¬∃ g : α → α, (∀ x, g (f x) = x) := by
  exact fun ⟨ g, hg ⟩ => h fun x y hxy => by have := hg x; have := hg y; aesop;

/-! ## Theorem 3: Step Count Bounded by Budget -/

/-
!-- Each step costs at least minBits * tempFactor. Summing over n steps gives
n * minBits * tempFactor ≤ totalCost ≤ budget. Divide by the positive
denominator. -- !--

The number of steps is bounded by budget / (minBits * tempFactor)
-/
theorem step_count_bounded_by_budget (ebs : EntropyBudgetSystem)
    (seq : StepSequence ebs.params)
    (minBits : ℝ) (hmin : 0 < minBits)
    (h_each : ∀ i, minBits ≤ (seq.steps i).bitsErased)
    (h_budget : seq.totalCost ebs.params ≤ ebs.budget) :
    (seq.numSteps : ℝ) ≤ ebs.budget / (minBits * ebs.params.tempFactor) := by
  rw [ le_div_iff₀ ];
  · refine' le_trans _ h_budget;
    convert Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right ( h_each i ) ebs.params.tempFactor_pos.le using 1 ; norm_num [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  · exact mul_pos hmin ebs.params.tempFactor_pos

/-
**Example**: Budget 10, cost-per-step = 2 implies at most 5 steps
-/
example : ∀ (n : ℕ), (n : ℝ) * 2 ≤ 10 → (n : ℝ) ≤ 5 := by
  exact fun n hn => by linarith;

/-
**Generalization**: Variable per-step costs, bounded below
-/
theorem budget_bound_with_variable_cost (budget : ℝ) (_hb : 0 ≤ budget)
    (n : ℕ) (costs : Fin n → ℝ) (_costs_pos : ∀ i, 0 < costs i)
    (h_total : ∑ i, costs i ≤ budget) (minCost : ℝ) (_hmc : 0 < minCost)
    (h_lb : ∀ i, minCost ≤ costs i) :
    (n : ℝ) * minCost ≤ budget := by
  exact le_trans ( by simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_lb i ) h_total

/-
**Boundary**: With zero minimum cost the bound is vacuous
-/
theorem budget_bound_trivial_at_zero (budget : ℝ) (_hb : 0 < budget)
    (tempFactor : ℝ) (_htf : 0 < tempFactor) :
    budget / (0 * tempFactor) = 0 := by
  norm_num

/-! ## Theorem 4: Entropy Gap Theorem -/

/-
!-- Use that 2^n eventually dominates n^k: for any C, find N s.t. n ≥ N implies
2^n > n^k + C. This is a standard exponential-vs-polynomial growth result. -- !--

2^n eventually exceeds any polynomial n^k plus any constant
-/
theorem exp_eventually_exceeds_poly (k : ℕ) :
    ∀ C : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n → n ^ k + C < 2 ^ n := by
  intro C;
  -- We'll use that exponential functions grow faster than polynomial functions.
  have h_exp_growth : Filter.Tendsto (fun n : ℕ => (n ^ k + C : ℝ) / 2 ^ n) Filter.atTop (nhds 0) := by
    -- We can use the fact that $2^n$ grows exponentially faster than any polynomial function $n^k$.
    have h_exp_growth : Filter.Tendsto (fun n : ℕ => (n ^ k : ℝ) / 2 ^ n) Filter.atTop (nhds 0) := by
      -- We can convert this limit into a form that is easier to handle by substituting $m = n \log 2$.
      suffices h_log : Filter.Tendsto (fun m : ℝ => m ^ k / Real.exp m) Filter.atTop (nhds 0) by
        have := h_log.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos one_lt_two ) );
        convert this.div_const ( Real.log 2 ^ k ) using 2 <;> norm_num [ div_eq_mul_inv, mul_pow, mul_assoc, mul_comm, mul_left_comm, Real.exp_nat_mul, Real.exp_log ];
      simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero k;
    simpa [ add_div ] using h_exp_growth.add ( tendsto_const_nhds.div_atTop ( tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) );
  exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N, hN ⟩ ↦ ⟨ N, fun n hn ↦ by have := hN n hn; rw [ div_lt_one ( by positivity ) ] at this; exact_mod_cast this ⟩

/-
The entropy cost gap between exponential and polynomial search is unbounded
-/
theorem entropy_gap_unbounded (params : LandauerParams) (k : ℕ) :
    ∀ G : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      (2 ^ n - n ^ k : ℤ) * (⌈params.tempFactor⌉₊ : ℤ) > (G : ℤ) := by
  intros G
  obtain ⟨N₀, hN₀⟩ : ∃ N₀ : ℕ, ∀ n : ℕ, N₀ ≤ n → n^k + (G + 1) < 2^n := by
    exact exp_eventually_exceeds_poly k (G + 1)
  exact ⟨ N₀, fun n hn => by nlinarith [ hN₀ n hn, Nat.le_ceil ( params.tempFactor ), show ( ⌈params.tempFactor⌉₊ : ℤ ) ≥ 1 from mod_cast Nat.ceil_pos.mpr params.tempFactor_pos ] ⟩

/-
**Example**: At n=20, k=3, the gap 2^20 - 20^3 is 1040576
-/
example : 2 ^ 20 - 20 ^ 3 = 1040576 := by
  grind

/-
**Generalization**: For any dominating pair f ≫ g, the gap is unbounded
-/
theorem entropy_gap_general (f g : ℕ → ℕ)
    (h_dom : ∀ C : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n → g n + C < f n) :
    ∀ C : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n → C < f n - g n := by
  exact fun C => by obtain ⟨ N, hN ⟩ := h_dom C; exact ⟨ N, fun n hn => lt_tsub_iff_left.mpr ( hN n hn ) ⟩ ;

/-- **Boundary**: For n=2, k=3, polynomial exceeds exponential: 2^3 = 8 > 4 = 2^2 -/
example : (2 : ℤ) ^ 3 > 2 ^ 2 := by norm_num

/-! ## Additional Results -/

/-
Composing two demons yields additive cost
-/
theorem demon_composition_cost (params : LandauerParams)
    (d1 d2 : MaxwellDemon params) :
    d1.entropyCost params + d2.entropyCost params =
      (d1.measurements + d2.measurements : ℕ) * params.tempFactor := by
  unfold MaxwellDemon.entropyCost; push_cast; ring;

/-
Larger budgets allow all computations feasible under smaller budgets
-/
theorem entropy_budget_monotone (params : LandauerParams)
    (b1 b2 : ℝ) (_hb1 : 0 ≤ b1) (_hb2 : 0 ≤ b2) (h : b1 ≤ b2)
    (seq : StepSequence params)
    (h_feasible : seq.totalCost params ≤ b1) :
    seq.totalCost params ≤ b2 := by
  linarith

end EBC