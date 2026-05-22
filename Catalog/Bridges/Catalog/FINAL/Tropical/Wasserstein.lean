/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Discrete Wasserstein Distance and Invariance under Isometries

This file defines the discrete Wasserstein-1 distance on probability vectors
over `Fin n` and proves its invariance under cost-preserving bijections.

## Main definitions
- `IsProbVec μ`: `μ` is a probability vector (nonneg + sums to 1)
- `transportPlans μ ν`: the set of transport plans (couplings) from μ to ν
- `transportCost c π`: the total transport cost of plan π under cost c
- `wasserstein1 c μ ν`: the Wasserstein-1 distance = infimum of transport costs
- `pushforwardEquiv e μ`: pushforward of μ by a bijection e

## Main results
- `transportPlans_equiv_image`: reindexing by an equivalence bijects transport plans
- `transportCost_equiv_invariant`: transport cost is preserved under cost-invariant reindexing
- `wasserstein1_invariant_under_equiv`: the Wasserstein distance is invariant under
    cost-preserving bijections — the foundational theorem of equivariant transport
-/
import Mathlib

open Finset BigOperators

variable {n : ℕ}

/-- A probability vector: nonnegative entries summing to 1. -/
def IsProbVec (μ : Fin n → ℝ) : Prop :=
  (∀ i, 0 ≤ μ i) ∧ (∑ i, μ i = 1)

/-- The set of transport plans (couplings) from μ to ν:
    nonnegative matrices whose row sums equal μ and column sums equal ν. -/
def transportPlans (μ ν : Fin n → ℝ) : Set (Fin n → Fin n → ℝ) :=
  {π | (∀ i j, 0 ≤ π i j) ∧
       (∀ i, ∑ j, π i j = μ i) ∧
       (∀ j, ∑ i, π i j = ν j)}

/-- The total transport cost of a plan π under cost function c. -/
def transportCost (c : Fin n → Fin n → ℝ) (π : Fin n → Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, π i j * c i j

/-- The Wasserstein-1 distance: infimum of transport costs over all couplings. -/
noncomputable def wasserstein1 (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ) : ℝ :=
  sInf (transportCost c '' transportPlans μ ν)

/-- Pushforward of a probability vector by a bijection. -/
def pushforwardEquiv (e : Fin n ≃ Fin n) (μ : Fin n → ℝ) : Fin n → ℝ :=
  fun i => μ (e.symm i)

/-- Reindex a transport plan by a bijection: π ↦ π ∘ (e⁻¹ × e⁻¹). -/
def reindexPlan (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ) :
    Fin n → Fin n → ℝ :=
  fun i j => π (e.symm i) (e.symm j)

/-! ## Reindexing preserves transport plan structure -/

/-
The reindexed plan has nonnegative entries.
-/
theorem reindexPlan_nonneg (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ)
    (hπ : ∀ i j, 0 ≤ π i j) :
    ∀ i j, 0 ≤ reindexPlan e π i j := by
  -- By definition of reindexPlan, we have reindexPlan e π i j = π (e.symm i) (e.symm j).
  intros i j
  apply hπ

/-
The reindexed plan has correct row marginals.
-/
theorem reindexPlan_row_sum (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ)
    (μ : Fin n → ℝ) (hrow : ∀ i, ∑ j, π i j = μ i) :
    ∀ i, ∑ j, reindexPlan e π i j = pushforwardEquiv e μ i := by
  intro i;
  convert hrow ( e.symm i ) using 1;
  exact Equiv.sum_comp ( e.symm ) fun j => π ( e.symm i ) j

/-
The reindexed plan has correct column marginals.
-/
theorem reindexPlan_col_sum (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ)
    (ν : Fin n → ℝ) (hcol : ∀ j, ∑ i, π i j = ν j) :
    ∀ j, ∑ i, reindexPlan e π i j = pushforwardEquiv e ν j := by
  -- By definition of `pushforwardEquiv`, we have `pushforwardEquiv e ν j = ν (e.symm j)`.
  simp [pushforwardEquiv];
  exact fun j => hcol ( e.symm j ) ▸ Equiv.sum_comp e.symm fun i => π i ( e.symm j )

/-
Reindexing sends transport plans to transport plans.
-/
theorem reindexPlan_mem_transportPlans (e : Fin n ≃ Fin n)
    (μ ν : Fin n → ℝ) (π : Fin n → Fin n → ℝ)
    (hπ : π ∈ transportPlans μ ν) :
    reindexPlan e π ∈ transportPlans (pushforwardEquiv e μ) (pushforwardEquiv e ν) := by
  exact ⟨ fun i j => hπ.1 ( e.symm i ) ( e.symm j ), reindexPlan_row_sum e π μ hπ.2.1, reindexPlan_col_sum e π ν hπ.2.2 ⟩

/-
The inverse reindexing recovers the original plan.
-/
theorem reindexPlan_symm (e : Fin n ≃ Fin n) (π : Fin n → Fin n → ℝ) :
    reindexPlan e.symm (reindexPlan e π) = π := by
  exact funext fun i => funext fun j => by simp +decide [ reindexPlan, Equiv.symm_apply_apply ] ;

/-
Reindexing is a bijection on transport plans.
-/
theorem reindexPlan_bijOn (e : Fin n ≃ Fin n) (μ ν : Fin n → ℝ) :
    Set.BijOn (reindexPlan e)
      (transportPlans μ ν)
      (transportPlans (pushforwardEquiv e μ) (pushforwardEquiv e ν)) := by
  refine ⟨ ?_, ?_, ?_ ⟩;
  · exact fun x hx => reindexPlan_mem_transportPlans e μ ν x hx;
  · intro x hx y hy; have := reindexPlan_symm e x; have := reindexPlan_symm e y; aesop;
  · intro x hx
    use reindexPlan e.symm x;
    refine' ⟨ _, _ ⟩;
    · convert reindexPlan_mem_transportPlans e.symm ( pushforwardEquiv e μ ) ( pushforwardEquiv e ν ) x hx using 1;
      unfold pushforwardEquiv; aesop;
    · exact funext fun i => funext fun j => by simp +decide [ reindexPlan ] ;

/-! ## Cost preservation -/

/-
Under a cost-invariant bijection, the transport cost of the reindexed plan
    equals the original transport cost.
-/
theorem transportCost_reindex_eq (e : Fin n ≃ Fin n) (c : Fin n → Fin n → ℝ)
    (π : Fin n → Fin n → ℝ)
    (hc : ∀ i j, c (e i) (e j) = c i j) :
    transportCost c (reindexPlan e π) = transportCost c π := by
  -- By changing the variables in the sum using `e`, we can rewrite the left-hand side sum to match the right-hand side.
  have h_change_var : ∑ i, ∑ j, π (e.symm i) (e.symm j) * c i j = ∑ i, ∑ j, π i j * c (e i) (e j) := by
    rw [ ← Equiv.sum_comp e ];
    exact Finset.sum_congr rfl fun i hi => by rw [ ← Equiv.sum_comp e ] ; simp +decide [ hc ] ;
  convert h_change_var using 3 ; aesop

/-! ## Main invariance theorem -/

/-
**Wasserstein invariance under cost-preserving bijections.**

    If `e : Fin n ≃ Fin n` preserves the cost function in the sense that
    `c (e i) (e j) = c i j` for all i, j, then pushforward by `e` preserves
    the Wasserstein-1 distance:
    `W_c(e_* μ, e_* ν) = W_c(μ, ν)`.

    This is the foundational theorem of equivariant optimal transport:
    the Wasserstein distance is intrinsic to the cost/metric structure,
    not to the labeling of points.
-/
theorem wasserstein1_invariant_under_equiv
    (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ)
    (e : Fin n ≃ Fin n)
    (hc : ∀ i j, c (e i) (e j) = c i j) :
    wasserstein1 c (pushforwardEquiv e μ) (pushforwardEquiv e ν) =
    wasserstein1 c μ ν := by
  unfold wasserstein1;
  -- By definition of pushforward, we know that the set of transport plans for the pushforward measures is the image of the set of transport plans for the original measures under the reindexing map.
  have h_transportPlans : transportPlans (pushforwardEquiv e μ) (pushforwardEquiv e ν) = Set.image (reindexPlan e) (transportPlans μ ν) := by
    exact Set.ext fun x => ⟨ fun hx => by have := reindexPlan_bijOn e μ ν; exact this.surjOn hx, fun hx => by rcases hx with ⟨ y, hy, rfl ⟩ ; exact reindexPlan_mem_transportPlans e μ ν y hy ⟩;
  rw [ h_transportPlans, Set.image_image ];
  exact congr_arg _ ( Set.image_congr fun x hx => transportCost_reindex_eq e c x hc )