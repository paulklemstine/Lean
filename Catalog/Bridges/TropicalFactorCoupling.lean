/-
# Tropical Factor-Wise Coupling and Bellman Min-Plus Dynamics

This module formalizes a **tensorization principle for tropical dynamics**:
if a composite system decomposes into `k` independent factors and each factor's
"gap" improves by at least some amount per round, then the total gap improves
by the sum of those amounts per round.

## Main results

* `total_gap_growth_of_factorwise_growth_weighted` — Heterogeneous factor gains:
  if factor `i` gains at least `βi i`, the total gains at least `∑ βi`.
* `total_gap_growth_of_factorwise_growth` — Uniform factor gains:
  if each factor gains at least `β / k`, the total gains at least `β`.
* `total_gap_growth_iterate` — Iterated version: `t` rounds give gain `t * β`.
* `total_gap_monotone_of_nonneg_factorwise_growth` — Monotonicity from nonneg gains.
* `sum_residual_growth_of_factorwise_bellman_growth` — Bellman-style abstract corollary.

## Cross-domain significance

* **Graphical models / belief propagation**: Local message improvement ⟹ global energy descent.
* **Reinforcement learning / dynamic programming**: Factor-wise Bellman residual reduction
  ⟹ whole-system residual reduction.
* **Tropical geometry / information theory**: Local tropical margins combine additively.
* **Proof engineering**: Reusable "local progress ⟹ global progress" schema.
-/

import Mathlib

open Finset BigOperators

/-! ## Weighted (heterogeneous) factor growth -/

/-
**Weighted coupling theorem**: If each factor `i` satisfies
`gap (step x) ≥ gap x + βi i` for all states `x`, then applying `step`
coordinatewise to a product state `s : Fin k → α` yields total gap improvement
of at least `∑ i, βi i`.
-/
theorem total_gap_growth_of_factorwise_growth_weighted
    {α : Type*} {k : ℕ}
    (gap : α → ℝ) (step : α → α) (βi : Fin k → ℝ)
    (hfactor : ∀ (i : Fin k) (x : α), gap (step x) ≥ gap x + βi i) :
    ∀ s : Fin k → α,
      (∑ i : Fin k, gap (step (s i))) ≥
        (∑ i : Fin k, gap (s i)) + ∑ i : Fin k, βi i := by
  exact fun s => by simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => hfactor i ( s i ) ;

/-! ## Uniform factor growth -/

/-
**Uniform coupling theorem**: If each factor gains at least `β / k`,
the total gap improves by at least `β`.
-/
theorem total_gap_growth_of_factorwise_growth
    {α : Type*} (k : ℕ) (hk : 0 < k)
    (gap : α → ℝ) (step : α → α) (β : ℝ)
    (hfactor : ∀ x : α, gap (step x) ≥ gap x + β / k) :
    ∀ s : Fin k → α,
      (∑ i : Fin k, gap (step (s i))) ≥
        (∑ i : Fin k, gap (s i)) + β := by
  exact fun s => le_trans ( by simp +decide [ Finset.sum_add_distrib, mul_div_cancel₀ _ ( by positivity : ( k : ℝ ) ≠ 0 ) ] ) ( Finset.sum_le_sum fun i _ => hfactor _ )

/-! ## Iterated growth -/

/-
**Iterated coupling theorem**: If one round gives gain `β`, then
`t` rounds give gain `t * β`. This is the convergence engine.
-/
theorem total_gap_growth_iterate
    {α : Type*} (k t : ℕ) (hk : 0 < k)
    (gap : α → ℝ) (step : α → α) (β : ℝ)
    (hfactor : ∀ x : α, gap (step x) ≥ gap x + β / k) :
    ∀ s : Fin k → α,
      (∑ i : Fin k, gap ((step^[t]) (s i))) ≥
        (∑ i : Fin k, gap (s i)) + t * β := by
  induction' t with t ih;
  · simp +decide;
  · intro s
    have := ih (step ∘ s)
    simp_all +decide [ Function.iterate_succ_apply' ];
    have := Finset.sum_le_sum fun i ( _ : i ∈ Finset.univ ) => hfactor ( step^[t] ( s i ) ) ; simp_all +decide [ Finset.sum_add_distrib, add_mul ] ;
    rw [ mul_div_cancel₀ ] at this <;> linarith [ ih s, show ( k : ℝ ) > 0 by positivity ]

/-! ## Monotonicity corollary -/

/-
Nonnegative factor gains imply monotonicity of the total gap.
-/
theorem total_gap_monotone_of_nonneg_factorwise_growth
    {α : Type*} {k : ℕ}
    (gap : α → ℝ) (step : α → α)
    (hfactor : ∀ x : α, gap (step x) ≥ gap x) :
    ∀ s : Fin k → α,
      (∑ i : Fin k, gap (step (s i))) ≥ ∑ i : Fin k, gap (s i) := by
  exact fun s => Finset.sum_le_sum fun i _ => hfactor _

/-! ## Bellman / min-plus abstract corollary -/

/-
**Bellman-style abstract coupling**: Let `gap` measure progress of a
value function, and let `T i` be a coordinatewise update operator.
If each `T i` improves `gap` by at least `βi i`, then applying all
updates yields total improvement of at least `∑ βi`.
-/
theorem sum_residual_growth_of_factorwise_bellman_growth
    {σ : Type*} {k : ℕ}
    (gap : (σ → ℝ) → ℝ)
    (T : Fin k → (σ → ℝ) → (σ → ℝ))
    (βi : Fin k → ℝ)
    (hmono : ∀ i f, gap (T i f) ≥ gap f + βi i) :
    ∀ V : Fin k → σ → ℝ,
      (∑ i : Fin k, gap (T i (V i))) ≥
        (∑ i : Fin k, gap (V i)) + ∑ i : Fin k, βi i := by
  exact fun V => by simpa only [ Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => hmono i _;