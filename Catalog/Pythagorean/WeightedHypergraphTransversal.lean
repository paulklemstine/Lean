/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Weighted and Multi-Objective Hypergraph Transversals

This file extends the fractional transversal theory from `HypergraphTransversal.lean`
to the **weighted** and **multi-objective** settings, establishing that threshold
rounding is a cost-agnostic approximation principle.

## Main Definitions

* `weighted_obj` — the weighted objective value of a fractional assignment
* `is_fractional_transversal` — feasibility of a fractional covering assignment
* `threshold_set` — the threshold rounding operator
* `pareto_dominates` — strict Pareto domination for bi-objective optimization
* `pareto_optimal_pair` — Pareto optimality in a bi-objective image set

## Main Results

* `weighted_threshold_cost_bound` — threshold rounding at `1/d` yields a transversal
  with weighted cost at most `d` times the fractional weighted cost
* `threshold_cost_mono` — monotonicity of rounded-set cost under pointwise cost domination
* `scalarized_minimizer_is_pareto` — any minimizer of a nonneg scalarization is Pareto optimal
* `threshold_simultaneous_multiobjective_bound` — one rounded set simultaneously
  `d`-approximates every nonneg linear objective

## Cross-Domain Connections

These results formalize certified approximation guarantees relevant to:
- **Operations Research**: weighted set cover, facility location, sensor placement
- **Welfare Economics**: Pareto-supported allocations, social welfare scalarization
- **Algorithmic Game Theory**: cost-sharing, multi-criteria mechanism design
- **Polyhedral Combinatorics**: LP rounding, integrality gap geometry

## References

* Lovász, "On the ratio of optimal integral and fractional covers" (1975)
* Vazirani, "Approximation Algorithms" (2001), Chapter 14
* Ehrgott, "Multicriteria Optimization" (2005)

## Application Keywords

weighted set cover, hypergraph covering, LP rounding, Pareto frontier,
multi-objective optimization, welfare economics, cost-sharing,
facility location, polyhedral combinatorics, certified approximation,
scalarization, robust decision-making
-/

open Finset BigOperators

/-! ### Definitions -/

/-- The weighted objective value of a fractional assignment `x` with respect to
    cost function `c`. This computes `∑ v, c v * x v`. -/
noncomputable def weighted_obj
    {α : Type*} [Fintype α] (c : α → ℝ) (x : α → ℝ) : ℝ :=
  ∑ v, c v * x v

/-- A function `x : α → ℝ` is a fractional transversal of a hypergraph `H`
    if it is nonnegative and the sum over every edge is at least 1. -/
def is_fractional_transversal
    {α : Type*} [Fintype α] [DecidableEq α]
    (H : Finset (Finset α)) (x : α → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ e ∈ H, 1 ≤ ∑ v ∈ e, x v

/-- The threshold rounding operator: given a fractional assignment `x` and
    threshold `θ`, produce the finset `{v | θ ≤ x v}`. -/
noncomputable def threshold_set
    {α : Type*} [Fintype α] [DecidableEq α]
    (x : α → ℝ) (θ : ℝ) : Finset α :=
  Finset.univ.filter (fun v => θ ≤ x v)

/-- Pareto domination: `q` dominates `p` if `q` is weakly better in both coordinates
    and strictly better in at least one. -/
def pareto_dominates (q p : ℝ × ℝ) : Prop :=
  q.1 ≤ p.1 ∧ q.2 ≤ p.2 ∧ (q.1 < p.1 ∨ q.2 < p.2)

/-- A point `p` is Pareto optimal in `A` if `p ∈ A` and no point in `A` dominates it. -/
def pareto_optimal_pair (A : Set (ℝ × ℝ)) (p : ℝ × ℝ) : Prop :=
  p ∈ A ∧ ¬∃ q ∈ A, pareto_dominates q p

/-! ### Theorem 1: Weighted Threshold Rounding Bound -/

/-
**Weighted threshold rounding bound.** Let `H` be a hypergraph with maximum edge
    size at most `d`. For any nonneg fractional transversal `x` and nonneg cost `w`,
    threshold rounding at `1/d` yields a transversal `S` with
    `∑ v ∈ S, w v ≤ d * ∑ v, w v * x v`.

    This is the fundamental cost-agnostic rounding principle: the classical `d_max`
    integrality gap bound extends from cardinality to arbitrary nonneg linear objectives.
-/
theorem weighted_threshold_cost_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (H : Finset (Finset α))
    (d : ℕ)
    (hd : ∀ e ∈ H, e.card ≤ d)
    (hd_pos : 0 < d)
    (x : α → ℝ)
    (hx_nonneg : ∀ v, 0 ≤ x v)
    (hx_cover : ∀ e ∈ H, 1 ≤ ∑ v ∈ e, x v)
    (w : α → ℝ)
    (hw_nonneg : ∀ v, 0 ≤ w v) :
    let S := threshold_set x ((1 : ℝ) / d)
    (∀ e ∈ H, (e ∩ S).Nonempty) ∧
    (∑ v ∈ S, w v ≤ ↑d * ∑ v, w v * x v) := by
  refine' ⟨ _, _ ⟩;
  · intro e he;
    refine' Finset.nonempty_of_ne_empty _;
    intro h_empty
    have h_sum_zero : ∑ v ∈ e, x v < 1 := by
      have h_sum_zero : ∀ v ∈ e, x v < 1 / d := by
        simp_all +decide [ Finset.ext_iff, threshold_set ];
      refine' lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ( Finset.nonempty_of_ne_empty ( by rintro rfl; exact absurd ( hx_cover _ he ) ( by norm_num ) ) ) h_sum_zero ) _ ; simp +decide [ hd _ he, hd_pos.ne' ];
      exact div_le_one_of_le₀ ( mod_cast hd e he ) ( Nat.cast_nonneg _ );
    linarith [ hx_cover e he ];
  · have h_sum_le : ∑ v ∈ threshold_set x (1 / d), w v ≤ ∑ v, w v * (x v) * d := by
      have h_sum_le : ∀ v ∈ threshold_set x (1 / d), w v ≤ w v * (x v) * d := by
        intro v hv
        have h_xv_ge_inv_d : x v ≥ 1 / d := by
          exact Finset.mem_filter.mp hv |>.2;
        rw [ ge_iff_le, div_le_iff₀ ] at h_xv_ge_inv_d <;> nlinarith [ hw_nonneg v, show ( d : ℝ ) ≥ 1 by norm_cast ];
      exact le_trans ( Finset.sum_le_sum h_sum_le ) ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => mul_nonneg ( mul_nonneg ( hw_nonneg _ ) ( hx_nonneg _ ) ) ( Nat.cast_nonneg _ ) );
    simpa only [ mul_comm, Finset.mul_sum _ _ _ ] using h_sum_le

/-! ### Theorem 2: Cost Monotonicity -/

/-
**Cost monotonicity for threshold rounding.** If `w₁ v ≤ w₂ v` pointwise,
    then the rounded-set cost under `w₁` is at most that under `w₂`.
-/
theorem threshold_cost_mono
    {α : Type*} [Fintype α] [DecidableEq α]
    (x : α → ℝ) (θ : ℝ)
    (w₁ w₂ : α → ℝ)
    (hmono : ∀ v, w₁ v ≤ w₂ v) :
    ∑ v ∈ threshold_set x θ, w₁ v ≤ ∑ v ∈ threshold_set x θ, w₂ v := by
  exact Finset.sum_le_sum fun v hv => hmono v

/-! ### Theorem 3: Scalarized Minimizer is Pareto Optimal -/

/-
**Scalarization implies Pareto optimality.** If `x` minimizes the scalarized
    objective `λ c₁ + (1 - λ) c₂` over all feasible fractional transversals,
    then `(cost₁(x), cost₂(x))` is Pareto optimal in the objective image set.

    This bridges hypergraph transversal theory to multi-criteria optimization
    and welfare economics.
-/
theorem scalarized_minimizer_is_pareto
    {α : Type*} [Fintype α] [DecidableEq α]
    (H : Finset (Finset α))
    (c₁ c₂ : α → ℝ)
    (_hc₁ : ∀ v, 0 ≤ c₁ v)
    (_hc₂ : ∀ v, 0 ≤ c₂ v)
    (l : ℝ)
    (hl0 : 0 < l)
    (hl1 : l < 1)
    (x : α → ℝ)
    (hx_feas : is_fractional_transversal H x)
    (hx_min : ∀ y, is_fractional_transversal H y →
      l * weighted_obj c₁ x + (1 - l) * weighted_obj c₂ x
        ≤ l * weighted_obj c₁ y + (1 - l) * weighted_obj c₂ y) :
    pareto_optimal_pair
      {p | ∃ y, is_fractional_transversal H y ∧
          p = (weighted_obj c₁ y, weighted_obj c₂ y)}
      (weighted_obj c₁ x, weighted_obj c₂ x) := by
  unfold pareto_optimal_pair;
  simp +zetaDelta at *;
  exact ⟨ ⟨ x, hx_feas, rfl, rfl ⟩, fun y hy h => by cases h.2.2 <;> nlinarith [ hx_min y hy, h.1, h.2.1 ] ⟩

/-! ### Theorem 4: Simultaneous Multi-Objective Bound -/

/-
**Simultaneous multi-objective rounding bound.** Threshold rounding at `1/d`
    simultaneously `d`-approximates every nonneg linear objective.
    A single rounded set controls all cost criteria at once.

    This is the strongest form of the cost-agnostic rounding principle:
    one combinatorial decision certifies approximation for an entire family
    of linear budgets.
-/
theorem threshold_simultaneous_multiobjective_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (H : Finset (Finset α))
    (d : ℕ)
    (hd : ∀ e ∈ H, e.card ≤ d)
    (hd_pos : 0 < d)
    (x : α → ℝ)
    (hx_nonneg : ∀ v, 0 ≤ x v)
    (hx_cover : ∀ e ∈ H, 1 ≤ ∑ v ∈ e, x v)
    (k : ℕ)
    (costs : Fin k → α → ℝ)
    (hcosts : ∀ i v, 0 ≤ costs i v) :
    let S := threshold_set x ((1 : ℝ) / d)
    (∀ e ∈ H, (e ∩ S).Nonempty) ∧
    ∀ i : Fin k, ∑ v ∈ S, costs i v ≤ ↑d * ∑ v, costs i v * x v := by
  convert weighted_threshold_cost_bound H d hd hd_pos x hx_nonneg hx_cover using 1;
  constructor <;> intro h;
  · convert weighted_threshold_cost_bound H d hd hd_pos x hx_nonneg hx_cover using 1;
  · exact ⟨ h ( fun _ => 0 ) ( fun _ => by norm_num ) |>.1, fun i => h ( costs i ) ( hcosts i ) |>.2 ⟩

/-! ### Helper lemma: pointwise indicator domination -/

/-
The key local inequality: for `v ∈ S = {v | 1/d ≤ x v}`, we have
    `w v ≤ d * (w v * x v)` provided `w v ≥ 0`.
-/
theorem weighted_indicator_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (x : α → ℝ) (w : α → ℝ) (d : ℕ)
    (hd_pos : 0 < d)
    (hx_nonneg : ∀ v, 0 ≤ x v)
    (hw_nonneg : ∀ v, 0 ≤ w v) :
    let S := threshold_set x ((1 : ℝ) / d)
    ∀ v ∈ S, w v ≤ ↑d * (w v * x v) := by
  simp_all +decide [ threshold_set ];
  exact fun v hv => by rw [ inv_eq_one_div, div_le_iff₀ ( by positivity ) ] at hv; nlinarith [ hw_nonneg v ] ;

/-
Threshold rounding produces a transversal (edge-hitting property).
-/
theorem threshold_set_isTransversal
    {α : Type*} [Fintype α] [DecidableEq α]
    (H : Finset (Finset α))
    (d : ℕ)
    (hd : ∀ e ∈ H, e.card ≤ d)
    (hd_pos : 0 < d)
    (x : α → ℝ)
    (hx_nonneg : ∀ v, 0 ≤ x v)
    (hx_cover : ∀ e ∈ H, 1 ≤ ∑ v ∈ e, x v) :
    ∀ e ∈ H, (e ∩ threshold_set x ((1 : ℝ) / d)).Nonempty := by
  intro e he
  by_contra h_empty;
  simp_all +decide [ Finset.ext_iff, threshold_set ];
  exact absurd ( hx_cover e he ) ( by have := Finset.sum_lt_sum_of_nonempty ( Finset.nonempty_of_ne_empty ( by rintro rfl; exact absurd ( hx_cover _ he ) ( by norm_num ) ) ) h_empty; simpa [ mul_inv_cancel₀ ( by positivity : ( d : ℝ ) ≠ 0 ) ] using this.trans_le ( by simpa [ mul_inv_cancel₀ ( by positivity : ( d : ℝ ) ≠ 0 ) ] using mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr ( hd e he ) ) ( by positivity : ( 0 : ℝ ) ≤ ( d : ℝ ) ⁻¹ ) ) )

/-
Weighted sum over threshold set is bounded by `d` times the fractional cost.
-/
theorem threshold_weighted_sum_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (x : α → ℝ) (w : α → ℝ) (d : ℕ)
    (hd_pos : 0 < d)
    (hx_nonneg : ∀ v, 0 ≤ x v)
    (hw_nonneg : ∀ v, 0 ≤ w v) :
    ∑ v ∈ threshold_set x ((1 : ℝ) / d), w v ≤
      ↑d * ∑ v, w v * x v := by
  convert le_trans ( Finset.sum_le_sum fun v hv ↦ weighted_indicator_bound x w d hd_pos hx_nonneg hw_nonneg v hv ) _;
  rw [ ← Finset.mul_sum _ _ _ ];
  exact mul_le_mul_of_nonneg_left ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.filter_subset _ _ ) fun _ _ _ => mul_nonneg ( hw_nonneg _ ) ( hx_nonneg _ ) ) ( Nat.cast_nonneg _ )