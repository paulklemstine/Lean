/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Hypergraph Transversals

This file develops a **tropical-geometric perspective** on hypergraph threshold rounding,
establishing that the classical threshold rounding map for fractional transversals is
monotone, retractive on integral points, and witness-driven.

## Main Definitions

* `thresholdSet` — the threshold rounding operator mapping fractional assignments to vertex sets
* `indicatorWeight` — the indicator function of a vertex set as a rational-valued weight
* `Support` — the support of a fractional assignment
* `edgeSlack` — the slack of a covering constraint
* `IsActiveOn` — predicate for an active (tight) covering constraint
* `HasUniqueActiveWitness` — each support vertex has an active edge isolating it

## Main Results

### Theorem 1: Tropical feasibility implies threshold transversal
`threshold_one_div_rank_is_transversal` — For rank-d hypergraphs, thresholding a feasible
fractional transversal at 1/d yields a combinatorial transversal.

### Theorem 2: Threshold monotonicity and retraction
`threshold_monotone` — Coordinatewise order is preserved by threshold sets.
`threshold_indicator_retract` — Thresholding the indicator of S at τ ∈ (0,1] returns S.

### Theorem 3: Active-edge witness forces integrality
`unique_active_witness_forces_integral` — If each support vertex has an active edge
isolating it, then all support values equal 1.

### Cross-domain theorem: Upward closure
`threshold_family_upward_closed` — The family of threshold sets is upward closed
under set inclusion, connecting to discrete convex analysis.

## References

* Lovász, "On the ratio of optimal integral and fractional covers" (1975)
* Develin–Sturmfels, "Tropical convexity" (2004)
* Murota, "Discrete Convex Analysis" (2003)

## Application Keywords

tropical geometry, hypergraph transversals, covering LP, threshold rounding,
min-plus algebra, discrete convex analysis, LP extremality
-/

open Finset BigOperators

/-! ### Core Definitions -/

/-- The threshold rounding operator: given threshold `τ` and fractional assignment `x`,
    produce the finset of vertices whose value meets the threshold. -/
def thresholdSet {V : Type*} [Fintype V] [DecidableEq V]
    (τ : ℚ) (x : V → ℚ) : Finset V :=
  Finset.univ.filter (fun v => τ ≤ x v)

/-- The indicator weight function of a vertex set: 1 on members, 0 elsewhere. -/
def indicatorWeight {V : Type*} [DecidableEq V] (S : Finset V) : V → ℚ :=
  fun v => if v ∈ S then 1 else 0

/-- The support of a fractional assignment: the set of vertices with nonzero value. -/
def Support {V : Type*} [Fintype V] [DecidableEq V] (x : V → ℚ) : Finset V :=
  Finset.univ.filter (fun v => x v ≠ 0)

/-- The slack of a covering constraint on edge `e`: how much the sum exceeds 1. -/
def edgeSlack {V E : Type*} [Fintype V] [DecidableEq V]
    (edgeVerts : E → Finset V) (x : V → ℚ) (e : E) : ℚ :=
  (∑ v ∈ edgeVerts e, x v) - 1

/-- A covering constraint on edge `e` is active (tight) at `x` when the sum equals 1. -/
def IsActiveOn {V E : Type*} [Fintype V] [DecidableEq V]
    (edgeVerts : E → Finset V) (x : V → ℚ) (e : E) : Prop :=
  ∑ v ∈ edgeVerts e, x v = 1

/-- Each support vertex has a unique active witness: an active edge containing it
    but no other support vertex. This is a tropical extremality certificate. -/
def HasUniqueActiveWitness {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
    (edgeVerts : E → Finset V) (x : V → ℚ) : Prop :=
  ∀ v, v ∈ Support x → ∃ e, v ∈ edgeVerts e ∧ IsActiveOn edgeVerts x e
    ∧ ∀ u, u ∈ Support x → u ≠ v → u ∉ edgeVerts e

/-! ### Theorem 1: Tropical Feasibility Implies Threshold Transversal -/

/-
**Theorem 1 (Tropical feasibility implies threshold transversal).**
Let `H` be a finite hypergraph of rank at most `d`. If a fractional assignment `x`
satisfies all covering constraints (∑_{v∈e} x(v) ≥ 1 for all edges e), then
thresholding at `1/d` produces a transversal: every edge contains a vertex
whose value meets the threshold.

The proof proceeds by the **tropical witness principle**: if no vertex in edge `e`
crosses the threshold, then every coordinate is `< 1/d`, forcing the sum to be
`< |e|/d ≤ 1`, contradicting feasibility.
-/
theorem threshold_one_div_rank_is_transversal
    {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
    (H : Finset E)
    (edgeVerts : E → Finset V)
    (x : V → ℚ)
    (d : ℕ)
    (hd : 0 < d)
    (_h_nonneg : ∀ v, 0 ≤ x v)
    (h_rank : ∀ e, e ∈ H → (edgeVerts e).card ≤ d)
    (h_cover : ∀ e, e ∈ H → 1 ≤ ∑ v ∈ edgeVerts e, x v) :
    ∀ e, e ∈ H →
      ∃ v, v ∈ edgeVerts e ∧ (1 : ℚ) / d ≤ x v := by
  intro e he
  by_contra h_contra
  push_neg at h_contra
  have h_sum_lt : ∑ v ∈ edgeVerts e, x v < (edgeVerts e).card * (1 / (d : ℚ)) := by
    simpa using Finset.sum_lt_sum_of_nonempty ( Finset.nonempty_of_ne_empty ( by rintro h; specialize h_cover e he; norm_num [ h ] at h_cover ) ) h_contra;
  exact not_le_of_gt h_sum_lt ( le_trans ( by rw [ mul_one_div, div_le_iff₀ ] <;> norm_cast ; linarith [ h_rank e he ] ) ( h_cover e he ) )

/-! ### Theorem 2: Threshold Monotonicity and Retraction -/

/-
**Theorem 2a (Threshold monotonicity).**
If `x ≤ y` coordinatewise, then the threshold set of `x` is contained
in the threshold set of `y`. This is the order-preserving property that
makes threshold rounding a monotone operator.
-/
theorem threshold_monotone
    {V : Type*} [Fintype V] [DecidableEq V]
    {τ : ℚ} {x y : V → ℚ}
    (hxy : ∀ v, x v ≤ y v) :
    thresholdSet τ x ⊆ thresholdSet τ y := by
  exact fun v hv => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hv |>.1, le_trans ( Finset.mem_filter.mp hv |>.2 ) ( hxy v ) ⟩

/-
**Theorem 2b (Threshold-indicator retraction).**
If `τ ∈ (0, 1]` and `S` is a finset of vertices, then thresholding the
indicator function of `S` at `τ` recovers `S` exactly. Thus thresholding
is a retraction: it fixes all integral points.
-/
theorem threshold_indicator_retract
    {V : Type*} [Fintype V] [DecidableEq V]
    {τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ ≤ 1) (S : Finset V) :
    thresholdSet τ (indicatorWeight S) = S := by
  unfold thresholdSet indicatorWeight;
  grind

/-! ### Theorem 3: Active-Edge Witness Forces Integrality -/

/-
**Theorem 3 (Unique active witness forces integrality).**
If `x` is a nonneg fractional assignment with the unique active witness
property — each support vertex has an active edge isolating it from other support
vertices — then every support value equals 1. Hence `x` is integral on its support.

The proof: for support vertex `v` with witness edge `e_v`, activeness gives
`∑_{u ∈ e_v} x(u) = 1`. Since `v` is the only support vertex in `e_v`, all
other vertices in `e_v` have `x(u) = 0`, so `x(v) = 1`.
-/
theorem unique_active_witness_forces_integral
    {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
    (edgeVerts : E → Finset V)
    (x : V → ℚ)
    (_h_nonneg : ∀ v, 0 ≤ x v)
    (h_wit : HasUniqueActiveWitness edgeVerts x) :
    ∀ v, v ∈ Support x → x v = 1 := by
  intro v hv
  obtain ⟨e, hev, heact, heunique⟩ := h_wit v hv
  have hother : ∀ u, u ∈ edgeVerts e → u ≠ v → x u = 0 :=
    fun u hu huv => Classical.not_not.1 fun h =>
      heunique u (Finset.mem_filter.2 ⟨Finset.mem_univ _, h⟩) huv hu
  rw [← heact, Finset.sum_eq_single v] <;> aesop

/-! ### Cross-Domain Theorem: Upward Closure of Threshold Family -/

/-
**Theorem 4 (Threshold family is upward closed).**
For any threshold level and any finset `S` that arises as a threshold set of some
function, every superset `S'` also arises as a threshold set. This connects
hypergraph optimization to discrete convex analysis and monotone families.

The proof constructs `y` by raising coordinates on `S' \ S` to meet the threshold.
-/
theorem threshold_family_upward_closed
    {V : Type*} [Fintype V] [DecidableEq V]
    (τ : ℚ) :
    ∀ ⦃S S' : Finset V⦄,
      (∃ x : V → ℚ, S = thresholdSet τ x) →
      S ⊆ S' →
      ∃ y : V → ℚ, S' = thresholdSet τ y := by
  intro S S'S hS';
  intro hSS';
  use fun v => if v ∈ S'S then τ else τ - 1;
  grind +locals

/-! ### Auxiliary lemmas -/

/-
Indicator weight is nonneg.
-/
theorem indicatorWeight_nonneg {V : Type*} [DecidableEq V]
    (S : Finset V) (v : V) : 0 ≤ indicatorWeight S v := by
  unfold indicatorWeight; split_ifs <;> norm_num;

/-
Indicator weight of a member is 1.
-/
theorem indicatorWeight_mem {V : Type*} [DecidableEq V]
    (S : Finset V) {v : V} (hv : v ∈ S) : indicatorWeight S v = 1 := by
  exact if_pos hv

/-
Indicator weight of a nonmember is 0.
-/
theorem indicatorWeight_not_mem {V : Type*} [DecidableEq V]
    (S : Finset V) {v : V} (hv : v ∉ S) : indicatorWeight S v = 0 := by
  exact if_neg hv

/-
Edge slack is nonneg for feasible transversals.
-/
theorem edgeSlack_nonneg_of_cover {V E : Type*} [Fintype V] [DecidableEq V]
    (edgeVerts : E → Finset V) (x : V → ℚ) (e : E)
    (h : 1 ≤ ∑ v ∈ edgeVerts e, x v) : 0 ≤ edgeSlack edgeVerts x e := by
  exact sub_nonneg_of_le h

/-
Active edge has zero slack.
-/
theorem edgeSlack_eq_zero_of_active {V E : Type*} [Fintype V] [DecidableEq V]
    (edgeVerts : E → Finset V) (x : V → ℚ) (e : E)
    (h : IsActiveOn edgeVerts x e) : edgeSlack edgeVerts x e = 0 := by
  exact sub_eq_zero_of_eq h

/-
**Theorem 5 (Feasibility-preserving upward closure).**
If `S` arises as the threshold set of a feasible fractional transversal at level `1/d`,
and `S ⊆ S'`, then `S'` also arises from a feasible fractional transversal.
The constructed witness `y` agrees with `x` on `S` and equals `1/d` on `S' \ S`.
-/
theorem threshold_family_upward_closed_feasible
    {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
    (H : Finset E)
    (edgeVerts : E → Finset V)
    (d : ℕ) (hd : 0 < d) :
    ∀ ⦃S S' : Finset V⦄,
      (∃ x : V → ℚ,
        (∀ v, 0 ≤ x v) ∧
        (∀ e, e ∈ H → 1 ≤ ∑ v ∈ edgeVerts e, x v) ∧
        S = thresholdSet ((1 : ℚ) / d) x) →
      S ⊆ S' →
      ∃ y : V → ℚ,
        (∀ v, 0 ≤ y v) ∧
        (∀ e, e ∈ H → 1 ≤ ∑ v ∈ edgeVerts e, y v) ∧
        S' = thresholdSet ((1 : ℚ) / d) y := by
  intro S S'S hS';
  intro hS'_sub_S
  obtain ⟨x, hx_nonneg, hx_feasible, hx_eq⟩ := hS'
  use fun v => if v ∈ S'S then max (x v) (1 / (d : ℚ)) else x v;
  refine' ⟨ fun v => _, fun e he => _, _ ⟩ <;> simp_all +decide [ thresholdSet ];
  · grind +revert;
  · exact le_trans ( hx_feasible e he ) ( Finset.sum_le_sum fun v hv => by split_ifs <;> cases max_cases ( x v ) ( d : ℚ ) ⁻¹ <;> linarith [ hx_nonneg v ] );
  · grind

#check @threshold_one_div_rank_is_transversal
#check @threshold_monotone
#check @threshold_indicator_retract
#check @unique_active_witness_forces_integral
#check @threshold_family_upward_closed