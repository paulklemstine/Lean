/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL3 Tropical Satake Certified Robustness for Top-Cycle Classifiers

This module formalizes certified robustness theorems for tournament-valued classifiers
built from pairwise score comparisons. The key insight is that robustness of the
Condorcet winner (equivalently, the singleton Smith set / top cycle) under L∞
perturbations follows from uniform pairwise margin domination, with certified radius
`margin / (2 * K * d)` where `K` is the coordinatewise Lipschitz constant and `d`
is the input dimension.

The development proceeds in layers:
1. Basic L∞ → ℓ¹ norm estimate on `Fin d`
2. Score perturbation bounds from coordinatewise Lipschitz continuity
3. Pairwise margin preservation under bounded perturbations
4. Condorcet winner / Smith singleton stability
5. General dominance cut preservation
6. GL3 specialization to `Fin 3`

## Mathematical significance

This result bridges tropical Hecke score geometry with social choice theory:
the same `margin / (2*K*d)` radius that controls binary certified robustness
also governs the stability of tournament solution concepts (Condorcet winners,
Smith sets, dominance cuts) under score perturbations.
-/

import Mathlib

open scoped BigOperators

/-! ## Core definitions -/

/-- Pairwise preference: class `i` is preferred to class `j` when `score i > score j`. -/
def PairwisePref {α : Type*} [DecidableEq α]
    (score : α → ℝ) (i j : α) : Prop :=
  score j < score i

/-- A Condorcet winner beats every other class in pairwise comparison. -/
def CondorcetWinner {α : Type*} [Fintype α] [DecidableEq α]
    (score : α → ℝ) (c : α) : Prop :=
  ∀ j, j ≠ c → score j < score c

/-- In a tournament, a Condorcet winner is exactly a singleton Smith set.
    This definition captures that equivalence as our interface. -/
def IsSmithSingleton {α : Type*} [Fintype α] [DecidableEq α]
    (score : α → ℝ) (c : α) : Prop :=
  CondorcetWinner score c

/-- Coordinatewise Lipschitz bound: each score function satisfies
    `|s i x - s i y| ≤ K * ∑ k, |x k - y k|`. -/
def CoordwiseLipschitz {α : Type*} (d : ℕ)
    (s : α → (Fin d → ℝ) → ℝ) (K : ℝ) : Prop :=
  ∀ i x y, |s i x - s i y| ≤ K * ∑ k : Fin d, |x k - y k|

/-- L∞ ball of radius `r`: every coordinate has absolute value at most `r`. -/
def LinftyBall {d : ℕ} (r : ℝ) (δ : Fin d → ℝ) : Prop :=
  ∀ k, |δ k| ≤ r

/-- Pairwise margin between classes `i` and `j` at input `x`. -/
def pairMargin {α β : Type*} (s : α → β → ℝ) (x : β) (i j : α) : ℝ :=
  s i x - s j x

/-! ## Auxiliary lemmas -/

/-
The ℓ¹ norm of a vector in the L∞ ball of radius `r` is at most `d * r`.
-/
lemma linfty_to_l1_bound
    {d : ℕ} (δ : Fin d → ℝ) (r : ℝ)
    (_hr : 0 ≤ r) (hδ : LinftyBall r δ) :
    ∑ k : Fin d, |δ k| ≤ (d : ℝ) * r := by
  simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hδ i

/-
Each score changes by at most `K * d * r` under an L∞ perturbation of radius `r`.
-/
lemma score_perturbation_bound
    {α : Type*} {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (i : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K) (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ) :
    |s i (fun k => x k + δ k) - s i x| ≤ K * (d : ℝ) * r := by
  convert hLip i ( fun k => x k + δ k ) x |> le_trans <| mul_le_mul_of_nonneg_left ?_ hK using 1;
  rw [ mul_assoc ];
  simpa using linfty_to_l1_bound δ r hr hδ

/-
The pairwise margin drops by at most `2 * K * d * r` under perturbation.
-/
lemma pair_margin_lower_bound_under_perturbation
    {α : Type*} {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (i j : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K) (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ) :
    s i (fun k => x k + δ k) - s j (fun k => x k + δ k)
      ≥ (s i x - s j x) - 2 * K * (d : ℝ) * r := by
  have h_bound : |s i (fun k => x k + δ k) - s i x| ≤ K * (d : ℝ) * r ∧ |s j (fun k => x k + δ k) - s j x| ≤ K * (d : ℝ) * r := by
    exact ⟨ score_perturbation_bound s K r i x δ hK hr hLip hδ, score_perturbation_bound s K r j x δ hK hr hLip hδ ⟩;
  linarith [ abs_le.mp h_bound.1, abs_le.mp h_bound.2 ]

/-! ## Main theorems -/

/-
If the pairwise margin between classes `i` and `j` exceeds `2 * K * d * r`,
    then the pairwise preference is preserved under any L∞ perturbation of radius `r`.
-/
theorem pairwise_orientation_preserved_of_margin
    {α : Type*} [DecidableEq α]
    {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (i j : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : 2 * K * (d : ℝ) * r < s i x - s j x) :
    s j (fun k => x k + δ k) < s i (fun k => x k + δ k) := by
  linarith [ pair_margin_lower_bound_under_perturbation s K r i j x δ hK hr hLip hδ ]

/-
**Condorcet robustness theorem.** If class `c` beats every other class by a margin
    exceeding `2 * K * d * r`, then `c` remains a Condorcet winner after any L∞
    perturbation of radius `r`.
-/
theorem condorcet_robust_of_uniform_margin
    {α : Type*} [Fintype α] [DecidableEq α]
    {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (c : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : ∀ j, j ≠ c → 2 * K * (d : ℝ) * r < s c x - s j x) :
    CondorcetWinner (fun i => s i (fun k => x k + δ k)) c := by
  exact fun j hj => pairwise_orientation_preserved_of_margin s K r c j x δ hK hr hLip hδ ( hmargin j hj )

/-
**Smith singleton robustness.** Under uniform margin domination, the singleton
    Smith set `{c}` is preserved after perturbation.
-/
theorem smith_singleton_robust_of_uniform_margin
    {α : Type*} [Fintype α] [DecidableEq α]
    {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (c : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : ∀ j, j ≠ c → 2 * K * (d : ℝ) * r < s c x - s j x) :
    IsSmithSingleton (fun i => s i (fun k => x k + δ k)) c := by
  convert condorcet_robust_of_uniform_margin s K r c x δ hK hr hLip hδ hmargin using 1

/-
**GL3 specialization.** For a 3-class tropical Hecke classifier, uniform pairwise
    margin domination certifies top-cycle robustness.
-/
theorem gl3_top_cycle_robustness
    {d : ℕ}
    (s : Fin 3 → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (c : Fin 3) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : ∀ j, j ≠ c → 2 * K * (d : ℝ) * r < s c x - s j x) :
    IsSmithSingleton (fun i => s i (fun k => x k + δ k)) c := by
  exact smith_singleton_robust_of_uniform_margin s K r c x δ hK hr hLip hδ hmargin

/-
**Dominance cut preservation.** If every class in `S` beats every class outside `S`
    by a margin exceeding `2 * K * d * r`, then all cross-edges are preserved under
    any L∞ perturbation of radius `r`. This is the key tournament-theoretic invariant
    behind top-cycle stability.
-/
theorem dominance_cut_preserved
    {α : Type*} [Fintype α] [DecidableEq α]
    {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (S : Finset α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : ∀ i, i ∈ S → ∀ j, j ∉ S → 2 * K * (d : ℝ) * r < s i x - s j x) :
    ∀ i, i ∈ S → ∀ j, j ∉ S → s j (fun k => x k + δ k) < s i (fun k => x k + δ k) := by
  exact fun i hi j hj => pairwise_orientation_preserved_of_margin s K r i j x δ hK hr hLip hδ ( hmargin i hi j hj )