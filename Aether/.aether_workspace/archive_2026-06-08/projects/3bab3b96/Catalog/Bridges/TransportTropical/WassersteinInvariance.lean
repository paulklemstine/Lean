/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Wasserstein Distance Invariance Under Cost-Preserving Bijections

This file formalizes a discrete Wasserstein-1 distance on finite probability vectors
over `Fin n`, and proves that it is invariant under cost-preserving bijections
(permutations). This is the foundational theorem establishing that Wasserstein
geometry is intrinsic to the cost structure, not to labels.

## Main results

- `IsProbVec`: Predicate for probability vectors (nonneg, sum to 1)
- `transportPlans`: Set of admissible transport plans with marginal constraints
- `transportCost`: Linear cost of a transport plan
- `wasserstein1`: Discrete Wasserstein-1 distance as infimum over transport costs
- `pushforwardEquiv`: Pushforward of a distribution by a bijection
- `reindexPlan`: Reindexing a transport plan by an equivalence
- `reindexPlan_mem_transportPlans`: Reindexed plans remain admissible
- `reindexPlan_cost_eq`: Reindexed plans have equal cost under cost-preserving bijections
- `wasserstein1_invariant_under_equiv`: **The flagship theorem** — Wasserstein distance
  is invariant under cost-preserving bijections

## Mathematical significance

This theorem shows that the Wasserstein metric depends only on the cost geometry,
not on the labeling of points. It is the seed for equivariant optimal transport,
orbit reduction, and transport on quotient spaces.
-/
import Mathlib

open Finset BigOperators

namespace DiscreteTransport

variable {n : ℕ}

/-- A probability vector: nonnegative entries summing to 1. -/
def IsProbVec (μ : Fin n → ℝ) : Prop :=
  (∀ i, 0 ≤ μ i) ∧ (∑ i, μ i = 1)

/-- The set of transport plans between two marginals μ and ν.
    A transport plan π is a nonneg matrix whose row sums equal μ and column sums equal ν. -/
def transportPlans (μ ν : Fin n → ℝ) : Set (Fin n → Fin n → ℝ) :=
  {π | (∀ i j, 0 ≤ π i j) ∧
       (∀ i, ∑ j, π i j = μ i) ∧
       (∀ j, ∑ i, π i j = ν j)}

/-- The transport cost of a plan π under cost function c. -/
def transportCost (c : Fin n → Fin n → ℝ) (π : Fin n → Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, π i j * c i j

/-- The discrete Wasserstein-1 distance: infimum of transport costs over all plans. -/
noncomputable def wasserstein1 (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ) : ℝ :=
  sInf (transportCost c '' transportPlans μ ν)

/-- Pushforward of a distribution by an equivalence. -/
def pushforwardEquiv (e : Fin n ≃ Fin n) (μ : Fin n → ℝ) : Fin n → ℝ :=
  fun i => μ (e.symm i)

/-- Reindex a transport plan by an equivalence:
    π'(i,j) = π(e⁻¹(i), e⁻¹(j)). -/
def reindexPlan (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => π (e.symm i) (e.symm j)

/-- Reindexing preserves nonnegativity. -/
theorem reindexPlan_nonneg (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ)
    (hπ : ∀ i j, 0 ≤ π i j) :
    ∀ i j, 0 ≤ reindexPlan e π i j := by
  intro i j
  exact hπ _ _

/-
Reindexing preserves row marginals (they become the pushforward).
-/
theorem reindexPlan_row_sum (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ)
    (μ : Fin n → ℝ) (hrow : ∀ i, ∑ j, π i j = μ i) (i : Fin n) :
    ∑ j, reindexPlan e π i j = pushforwardEquiv e μ i := by
  -- By changing the variables of summation using the bijection $e.symm$, we can rewrite the sum.
  have h_sum_change : ∑ j, π (e.symm i) (e.symm j) = ∑ j', π (e.symm i) j' := by
    conv_rhs => rw [ ← Equiv.sum_comp e.symm ] ;
  exact h_sum_change.trans ( hrow _ )

/-
Reindexing preserves column marginals (they become the pushforward).
-/
theorem reindexPlan_col_sum (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ)
    (ν : Fin n → ℝ) (hcol : ∀ j, ∑ i, π i j = ν j) (j : Fin n) :
    ∑ i, reindexPlan e π i j = pushforwardEquiv e ν j := by
  unfold reindexPlan pushforwardEquiv;
  rw [ ← hcol, Equiv.sum_comp e.symm fun i => π i ( e.symm j ) ]

/-- Reindexed plans are admissible for pushforward marginals. -/
theorem reindexPlan_mem_transportPlans (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ)
    (μ ν : Fin n → ℝ) (hπ : π ∈ transportPlans μ ν) :
    reindexPlan e π ∈ transportPlans (pushforwardEquiv e μ) (pushforwardEquiv e ν) := by
  obtain ⟨hnn, hrow, hcol⟩ := hπ
  exact ⟨reindexPlan_nonneg e π hnn,
         fun i => reindexPlan_row_sum e π μ hrow i,
         fun j => reindexPlan_col_sum e π ν hcol j⟩

/-
The inverse reindexing recovers the original plan.
-/
theorem reindexPlan_symm (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ) :
    reindexPlan e.symm (reindexPlan e π) = π := by
  -- By definition of reindexPlan, we have that (reindexPlan e.symm (reindexPlan e π)) i j = π (e (e.symm i)) (e (e.symm j)).
  funext i j;
  simp [reindexPlan, Function.comp]

/-
Reindexing by equivalence is a bijection on transport plans.
-/
theorem reindexPlan_bijOn (e : Fin n ≃ Fin n) (μ ν : Fin n → ℝ) :
    Set.BijOn (reindexPlan e)
      (transportPlans μ ν)
      (transportPlans (pushforwardEquiv e μ) (pushforwardEquiv e ν)) := by
  refine ⟨ fun π hπ ↦ ?_, ?_, fun π hπ ↦ ?_ ⟩;
  · exact?;
  · intro π₁ h₁ π₂ h₂ h_eq_eq;
    exact funext fun i => funext fun j => by have := congr_fun ( congr_fun h_eq_eq ( e i ) ) ( e j ) ; unfold reindexPlan at this; aesop;
  · use reindexPlan e.symm π;
    refine' ⟨ _, reindexPlan_symm e.symm π ⟩;
    convert reindexPlan_mem_transportPlans e.symm π ( pushforwardEquiv e μ ) ( pushforwardEquiv e ν ) hπ using 1;
    unfold pushforwardEquiv; aesop;

/-
Transport cost is preserved under cost-preserving reindexing.
-/
theorem reindexPlan_cost_eq (e : Fin n ≃ Fin n) (c : Fin n → Fin n → ℝ)
    (π : Fin n → Fin n → ℝ) (hc : ∀ i j, c (e i) (e j) = c i j) :
    transportCost c (reindexPlan e π) = transportCost c π := by
  -- By definition of reindexPlan, we can rewrite the transport cost as:
  have h_reindex : ∑ i, ∑ j, reindexPlan e π i j * c i j = ∑ i, ∑ j, π i j * c (e i) (e j) := by
    simp +decide only [reindexPlan];
    conv_rhs => rw [ ← Equiv.sum_comp e.symm ] ;
    exact Finset.sum_congr rfl fun i hi => by rw [ ← Equiv.sum_comp e ] ; simp +decide [ hc ] ;
  unfold transportCost; aesop

/-
**Flagship theorem**: The Wasserstein-1 distance is invariant under
    cost-preserving bijections.

    If `e : Fin n ≃ Fin n` preserves costs (`c(e(x), e(y)) = c(x,y)`)
    then `W_c(e_*μ, e_*ν) = W_c(μ, ν)`.

    This establishes that Wasserstein geometry is intrinsic to the cost
    structure and independent of labeling.
-/
theorem wasserstein1_invariant_under_equiv
    (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ)
    (e : Fin n ≃ Fin n)
    (hc : ∀ i j, c (e i) (e j) = c i j) :
    wasserstein1 c (pushforwardEquiv e μ) (pushforwardEquiv e ν) =
    wasserstein1 c μ ν := by
  unfold pushforwardEquiv wasserstein1;
  congr! 1;
  ext;
  constructor <;> rintro ⟨ π, hπ, rfl ⟩;
  · refine' ⟨ reindexPlan e.symm π, _, _ ⟩;
    · convert reindexPlan_mem_transportPlans e.symm π _ _ hπ using 1;
      unfold pushforwardEquiv; aesop;
    · apply reindexPlan_cost_eq;
      exact fun i j => by rw [ ← hc, e.apply_symm_apply, e.apply_symm_apply ] ;
  · use reindexPlan e π;
    exact ⟨ reindexPlan_mem_transportPlans e π μ ν hπ, reindexPlan_cost_eq e c π hc ⟩

end DiscreteTransport