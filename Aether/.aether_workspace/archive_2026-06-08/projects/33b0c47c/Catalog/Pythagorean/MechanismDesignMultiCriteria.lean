/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Certified Multi-Criteria Truthful Approximation Mechanisms

This file formalizes a new theory connecting **mechanism design**, **multi-objective
optimization**, and **certified approximation algorithms** for covering problems.

The central result is that a threshold-rounded covering mechanism can be made
truthful (via critical-value payments) while its output remains simultaneously
approximately optimal for an entire cone of linear welfare objectives.

## Main Results

* `critical_payment_dominant_strategy` — critical-value payments make any
  threshold-characterized allocation rule dominant-strategy truthful
  (Myerson's single-parameter lemma for covering mechanisms)
* `multiapprox_implies_approx_pareto` — simultaneous d-approximation across
  a cone of objectives implies approximate Pareto optimality
* `threshold_set_bid_monotone` — threshold rounding is bid-monotone
  under monotone fractional solutions
* `truthful_mechanism_simultaneous_multiapprox` — combined truthfulness +
  multi-criteria approximation in one mechanism
* `threshold_char_implies_bid_monotone` — threshold characterization implies
  bid monotonicity

## Builds On

* `Catalog/Pythagorean/WeightedHypergraphTransversal.lean`:
  - `threshold_simultaneous_multiobjective_bound`
  - `scalarized_minimizer_is_pareto`

## Application Keywords

truthful approximation mechanism, multi-objective mechanism design,
Pareto-certified allocation, hypergraph covering games, critical-value payments,
bid monotonicity, LP rounding, combinatorial procurement, algorithmic fairness,
healthcare resource allocation, robust social choice, Pareto geometry
-/

open Finset BigOperators

/-! ### Core Definitions -/

/-- An objective cone has nonneg weights: every objective in the cone assigns
    nonneg weight to every vertex. -/
def InNonnegCone {V : Type*} (C : Set (V → ℝ)) : Prop :=
  ∀ w ∈ C, ∀ v, 0 ≤ w v

/-- The weighted social cost of a set S under objective w: ∑ v ∈ S, w v. -/
noncomputable def objectiveCost {V : Type*} [Fintype V] (w : V → ℝ) (S : Finset V) : ℝ :=
  ∑ v ∈ S, w v

/-- An allocation set S is an approximate Pareto point relative to cone C and factor d
    if no feasible set T achieves objectiveCost(w, T) < objectiveCost(w, S) / d for
    every w ∈ C simultaneously. -/
def ApproxParetoPoint {V : Type*} [Fintype V]
    (C : Set (V → ℝ))
    (d : ℝ)
    (S : Finset V)
    (feasible : Set (Finset V)) : Prop :=
  S ∈ feasible ∧
  ¬∃ T ∈ feasible, ∀ w ∈ C, objectiveCost w T < objectiveCost w S / d

/-- An allocation rule is bid-monotone: if agent v is selected at bid profile b,
    and v lowers its bid (others unchanged), then v remains selected. -/
def BidMonotone {V : Type*} [DecidableEq V]
    (A : (V → ℝ) → Finset V) : Prop :=
  ∀ (b : V → ℝ) (v : V) (t₁ t₂ : ℝ),
    t₂ ≤ t₁ →
    v ∈ A (Function.update b v t₁) →
    v ∈ A (Function.update b v t₂)

/-! ### Critical Payment Mechanism -/

/-- A threshold characterization of an allocation rule: there exists a threshold
    function (independent of v's own bid) such that v is selected iff bid ≤ threshold.
    This is the structural property from which Myerson-style payments can be derived. -/
structure ThresholdCharacterization {V : Type*} [DecidableEq V] [Fintype V]
    (A : (V → ℝ) → Finset V) where
  /-- The threshold value for agent v given others' bids -/
  threshold : (V → ℝ) → V → ℝ
  /-- The threshold does not depend on v's own bid -/
  threshold_indep : ∀ (b : V → ℝ) (v : V) (t : ℝ),
    threshold (Function.update b v t) v = threshold b v
  /-- v is selected iff bid ≤ threshold -/
  selected_iff : ∀ (b : V → ℝ) (v : V),
    v ∈ A b ↔ b v ≤ threshold b v

/-- The critical payment rule: pay the threshold value to selected agents, zero to others. -/
noncomputable def criticalPayment {V : Type*} [DecidableEq V] [Fintype V]
    (A : (V → ℝ) → Finset V)
    (tc : ThresholdCharacterization A)
    (b : V → ℝ) (v : V) : ℝ :=
  if v ∈ A b then tc.threshold b v else 0

/-- Agent utility: payment minus true cost if selected, zero otherwise. -/
noncomputable def agentUtility {V : Type*} [DecidableEq V]
    (S : Finset V) (payment : ℝ) (trueCost : ℝ) (v : V) : ℝ :=
  if v ∈ S then payment - trueCost else 0

/-! ### Theorem 1: Threshold Characterization Implies Bid Monotonicity -/

/-
A threshold-characterized allocation rule is automatically bid-monotone.
    If v is selected at bid t₁ (meaning t₁ ≤ threshold), then lowering to t₂ ≤ t₁
    preserves t₂ ≤ threshold since the threshold is independent of v's own bid.
-/
theorem threshold_char_implies_bid_monotone
    {V : Type*} [DecidableEq V] [Fintype V]
    (A : (V → ℝ) → Finset V)
    (tc : ThresholdCharacterization A) :
    BidMonotone A := by
  intro b v t₁ t₂ h_le h_mem
  have h₁ := tc.selected_iff (Function.update b v t₁) v
  have h₂ := tc.selected_iff (Function.update b v t₂) v
  simp_all +decide;
  linarith [ tc.threshold_indep b v t₁, tc.threshold_indep b v t₂ ]

/-! ### Theorem 2: Critical Payment Dominant Strategy Truthfulness -/

/-
**Myerson's Lemma for Covering Mechanisms.**
If an allocation rule A has a threshold characterization (v is selected iff bid ≤ threshold,
where the threshold is independent of v's own bid), then critical-value payments make
truthful reporting a dominant strategy for every agent.

The proof proceeds by exhaustive case analysis on whether v is selected under
truthful vs. deviant bidding:
1. Selected under both: payments equal (threshold-independent), utilities equal
2. Selected truthfully, not under deviation: truthful utility ≥ 0 = deviant utility
3. Not selected truthfully, selected under deviation: deviant utility < 0 ≤ truthful
4. Neither selected: both utilities are zero
-/
theorem critical_payment_dominant_strategy
    {V : Type*} [DecidableEq V] [Fintype V]
    (A : (V → ℝ) → Finset V)
    (tc : ThresholdCharacterization A)
    (c : V → ℝ)
    (v : V)
    (b_alt : ℝ) :
    agentUtility (A c) (criticalPayment A tc c v) (c v) v ≥
    agentUtility (A (Function.update c v b_alt))
      (criticalPayment A tc (Function.update c v b_alt) v) (c v) v := by
  -- Let τ be the threshold for v.
  set τ := tc.threshold c v;
  -- By definition of $A$, we know that $v \in A c$ if and only if $c v \leq τ$.
  have h_Ac : v ∈ A c ↔ c v ≤ τ := by
    exact tc.selected_iff c v;
  unfold agentUtility criticalPayment;
  have := tc.threshold_indep c v b_alt;
  grind

/-! ### Theorem 3: Simultaneous Approximation Implies Approximate Pareto Optimality -/

/-
**Pareto Certification from Cone Approximation.**
If a set S is simultaneously d-approximate for every objective w in a nonneg cone C
(meaning objectiveCost w S ≤ d * opt_cost(w) for each w), then S is an approximate
Pareto point: no feasible set T can simultaneously do better than S/d on every objective.

This bridges multi-criteria approximation to Pareto geometry.
-/
theorem multiapprox_implies_approx_pareto
    {V : Type*} [DecidableEq V] [Fintype V]
    (C : Set (V → ℝ))
    (hC : C.Nonempty)
    (S : Finset V)
    (d : ℝ)
    (hd : 0 < d)
    (feasible : Set (Finset V))
    (hS_feas : S ∈ feasible)
    (optCost : (V → ℝ) → ℝ)
    (hopt : ∀ w ∈ C, ∀ T ∈ feasible, optCost w ≤ objectiveCost w T)
    (happrox : ∀ w ∈ C, objectiveCost w S ≤ d * optCost w) :
    ApproxParetoPoint C d S feasible := by
  refine' ⟨ hS_feas, _ ⟩;
  exact fun ⟨ T, hT_feas, hT_better ⟩ ↦ by rcases hC with ⟨ w, hw ⟩ ; nlinarith [ hopt w hw T hT_feas, happrox w hw, hT_better w hw, mul_div_cancel₀ ( objectiveCost w S ) hd.ne' ] ;

/-! ### Theorem 4: Threshold Set Bid Monotonicity -/

/-
**Threshold Rounding is Bid-Monotone Under Monotone Fractional Solutions.**
Given a fractional solution mapping x that is pointwise non-decreasing when
an agent's bid decreases (i.e., lowering v's bid does not decrease x(v)),
the threshold rounding set {v | τ ≤ x(v)} is bid-monotone.

This is the strategic hinge connecting optimization to mechanism design.
-/
theorem threshold_set_bid_monotone
    {V : Type*} [DecidableEq V] [Fintype V]
    (x : (V → ℝ) → V → ℝ)
    (τ : ℝ)
    (hx_mono : ∀ (b : V → ℝ) (v : V) (t₁ t₂ : ℝ),
      t₂ ≤ t₁ → x (Function.update b v t₂) v ≥ x (Function.update b v t₁) v) :
    BidMonotone (fun b => Finset.univ.filter (fun v => τ ≤ x b v)) := by
  intro b v t₁ t₂ h_le hv;
  grind +suggestions

/-! ### Theorem 5: Combined Truthful Multi-Criteria Mechanism -/

/--
**One Mechanism, Many Objectives, No Strategic Regret.**
Given a threshold-characterized allocation rule with simultaneous d-approximation
for every objective in a nonneg cone C, we conclude both:
(1) Critical-value payments make truthful reporting dominant
(2) The allocation is an approximate Pareto point for the entire cone
-/
theorem truthful_mechanism_simultaneous_multiapprox
    {V : Type*} [DecidableEq V] [Fintype V]
    (A : (V → ℝ) → Finset V)
    (tc : ThresholdCharacterization A)
    (C : Set (V → ℝ))
    (hC : C.Nonempty)
    (d : ℝ)
    (hd : 0 < d)
    (feasible : Set (Finset V))
    (optCost : (V → ℝ) → ℝ)
    (hopt : ∀ w ∈ C, ∀ T ∈ feasible, optCost w ≤ objectiveCost w T)
    (b : V → ℝ)
    (hS_feas : A b ∈ feasible)
    (happrox : ∀ w ∈ C, objectiveCost w (A b) ≤ d * optCost w) :
    (∀ v : V, ∀ b_alt : ℝ,
      agentUtility (A b) (criticalPayment A tc b v) (b v) v ≥
      agentUtility (A (Function.update b v b_alt))
        (criticalPayment A tc (Function.update b v b_alt) v) (b v) v)
    ∧ ApproxParetoPoint C d (A b) feasible := by
  exact ⟨fun v b_alt => critical_payment_dominant_strategy A tc b v b_alt,
    multiapprox_implies_approx_pareto C hC (A b) d hd feasible hS_feas optCost hopt happrox⟩

/-! ### Conjecture: Universal Truthful Simultaneous Approximation for Bounded-Rank Hypergraphs

For every rank-r hypergraph covering instance, there exists a deterministic bid-monotone
threshold-rounded mechanism with critical payments achieving simultaneous approximation
factor r for every nonneg linear objective in the cone generated by agent cost vectors.

Computationally falsifiable prediction:
- Generate random rank-r hypergraphs
- Compute the LP-based fractional solution
- Apply threshold rounding
- Compute critical-value payments
- Test all single-agent deviations over a rational grid
- If any deviation strictly improves utility, the conjecture fails for that instance
-/