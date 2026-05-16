/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Permutation Couplings: Bridge between Transport and Tropical Optimization

This file connects optimal transport with tropical/combinatorial optimization
by studying permutation couplings — transport plans induced by permutations
between uniform distributions.

## Main definitions
- `uniformProb n`: the uniform probability vector on `Fin n`
- `permPlan σ`: the transport plan induced by a permutation σ

## Main results
- `permPlan_is_transportPlan`: permutation plans are valid transport plans
    between uniform distributions
- `permPlan_transportCost`: the transport cost of a permutation plan equals
    the assignment cost `(1/n) ∑ᵢ c(i, σ(i))`
- `permPlan_cost_conjugation_invariant`: simultaneous relabeling by a bijection
    preserves the assignment cost, connecting group-theoretic symmetry
    to tropical optimization invariance
-/
import Mathlib

open Finset BigOperators

variable {n : ℕ}

/-- The uniform probability vector on `Fin n`. -/
noncomputable def uniformProb (n : ℕ) : Fin n → ℝ := fun _ => (n : ℝ)⁻¹

/-- The transport plan induced by a permutation σ: mass (1/n) is placed at (i, σ(i)). -/
noncomputable def permPlan (σ : Fin n ≃ Fin n) : Fin n → Fin n → ℝ :=
  fun i j => if σ i = j then (n : ℝ)⁻¹ else 0

/-- The set of transport plans from μ to ν (reproduced for self-containment). -/
def transportPlans' (μ ν : Fin n → ℝ) : Set (Fin n → Fin n → ℝ) :=
  {π | (∀ i j, 0 ≤ π i j) ∧
       (∀ i, ∑ j, π i j = μ i) ∧
       (∀ j, ∑ i, π i j = ν j)}

/-- The transport cost of plan π under cost c. -/
def transportCost' (c : Fin n → Fin n → ℝ) (π : Fin n → Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, π i j * c i j

/-! ## Permutation plans are valid transport plans -/

/-
Permutation plans have nonneg entries.
-/
theorem permPlan_nonneg (σ : Fin n ≃ Fin n) (hn : 0 < n) :
    ∀ i j, 0 ≤ permPlan σ i j := by
  exact fun i j => by unfold permPlan; positivity; ;

/-
Permutation plans have correct row sums (each equals 1/n).
-/
theorem permPlan_row_sum (σ : Fin n ≃ Fin n) :
    ∀ i, ∑ j, permPlan σ i j = uniformProb n i := by
  intro i
  unfold permPlan uniformProb
  simp

/-
Permutation plans have correct column sums (each equals 1/n).
-/
theorem permPlan_col_sum (σ : Fin n ≃ Fin n) :
    ∀ j, ∑ i, permPlan σ i j = uniformProb n j := by
  intro j
  have h_col_sum : ∑ i, permPlan σ i j = (n : ℝ)⁻¹ := by
    convert permPlan_row_sum σ.symm j using 1;
    unfold permPlan;
    grind +extAll
  exact h_col_sum.symm ▸ rfl

/-
**A permutation plan is a valid transport plan between uniform distributions.**
-/
theorem permPlan_is_transportPlan (hn : 0 < n) (σ : Fin n ≃ Fin n) :
    permPlan σ ∈ transportPlans' (uniformProb n) (uniformProb n) := by
  exact ⟨ fun _ _ => by unfold permPlan; positivity, permPlan_row_sum σ, permPlan_col_sum σ ⟩

/-! ## Transport cost of permutation plans -/

/-
The transport cost of a permutation plan equals the scaled assignment cost.
-/
theorem permPlan_transportCost (σ : Fin n ≃ Fin n) (c : Fin n → Fin n → ℝ) :
    transportCost' c (permPlan σ) = (n : ℝ)⁻¹ * ∑ i, c i (σ i) := by
  unfold transportCost';
  unfold permPlan; simp +decide [ Finset.mul_sum _ _ _ ] ;

/-! ## Conjugation invariance of assignment cost -/

/-
**Assignment cost is invariant under conjugation by a cost-preserving bijection.**

    If `e` preserves the cost function (`c (e i) (e j) = c i j`), then
    conjugating a permutation σ by e (i.e., replacing σ with e ∘ σ ∘ e⁻¹)
    does not change the assignment cost.

    This is the bridge theorem: it connects the group-theoretic notion
    of conjugation to the transport-theoretic notion of relabeling invariance,
    and to the tropical-algebraic notion that min-plus optimization
    over assignments is invariant under simultaneous reindexing.
-/
theorem assignment_cost_conjugation_invariant
    (c : Fin n → Fin n → ℝ) (σ e : Fin n ≃ Fin n)
    (hc : ∀ i j, c (e i) (e j) = c i j) :
    ∑ i, c i ((e.symm.trans (σ.trans e)) i) = ∑ i, c i (σ i) := by
  conv_rhs => rw [ ← Equiv.sum_comp e.symm ] ;
  grind +extAll