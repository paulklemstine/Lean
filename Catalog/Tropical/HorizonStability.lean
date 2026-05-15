/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Horizon Stability on Weighted Graphs

## Overview

This file formalizes a quantitative stability theorem for "tropical horizons"
on finite weighted graphs. The horizon value is defined as the minimum cut
weight among all subsets separating two distinguished terminals `s` and `t`.

The main results are:

1. **Lipschitz stability of horizon values**: if edge weights are perturbed by
   at most `ε` in sup norm, then the horizon value changes by at most
   `(Fintype.card V)² * ε`.

2. **Combinatorial stability of minimizers**: under a strict gap hypothesis,
   the set of minimizing cuts is preserved under small perturbations.

3. **Einstein–Maxwell extension**: joint Lipschitz stability for coupled
   gravitational-gauge horizon functionals.

4. **Entropy bound**: the number of horizon microstates (separating cuts)
   is at most `2 ^ Fintype.card V`.

## Mathematical Context

These results provide a discrete backbone for:
- Black-hole-style entropy stability under metric perturbations
- Robustness of min-cut based security thresholds
- Perturbative control of holographic entanglement proxies on finite networks
- Tropical Einstein–Maxwell existence/uniqueness theories

## References

The horizon = min-cut analogy connects to the Ryu–Takayanagi formula in
holographic entanglement entropy, where minimal surfaces in AdS correspond
to entanglement entropy of boundary regions.
-/
import Mathlib

open Finset BigOperators

namespace TropicalHorizon

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Definitions -/

/-- A subset `S` of vertices separates `s` from `t` if `s ∈ S` and `t ∉ S`. -/
def IsSeparating (s t : V) (S : Finset V) : Prop :=
  s ∈ S ∧ t ∉ S

instance (s t : V) (S : Finset V) : Decidable (IsSeparating s t S) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-- The cut weight of a subset `S` with respect to edge weights `w`.
    This sums `w i j` over all pairs `(i, j)` with `i ∈ S` and `j ∉ S`. -/
noncomputable def cutWeight (w : V → V → ℝ) (S : Finset V) : ℝ :=
  ∑ i ∈ S, ∑ j ∈ Sᶜ, w i j

/-- The set of all separating cuts for terminals `s` and `t`. -/
def separatingCuts (s t : V) : Finset (Finset V) :=
  Finset.univ.filter (fun S => IsSeparating s t S)

/-- The horizon value: the minimum cut weight among all separating cuts.
    When no separating cut exists (i.e., s = t), we define it as 0. -/
noncomputable def horizonValue (s t : V) (w : V → V → ℝ) : ℝ :=
  if h : (separatingCuts s t).Nonempty then
    (separatingCuts s t).inf' h (cutWeight w)
  else 0

/-- A subset is a horizon minimizer if it is a separating cut achieving the
    minimum cut weight. -/
def IsHorizonMinimizer (s t : V) (w : V → V → ℝ) (S : Finset V) : Prop :=
  IsSeparating s t S ∧ cutWeight w S = horizonValue s t w

/-- The set of all horizon minimizers. -/
noncomputable def horizonMinimizers (s t : V) (w : V → V → ℝ) : Set (Finset V) :=
  {S | IsHorizonMinimizer s t w S}

/-- The horizon gap: the difference between the second-best and best cut weights.
    This measures how isolated the minimum is. -/
noncomputable def horizonGap (s t : V) (w : V → V → ℝ) : ℝ :=
  if h : (separatingCuts s t).Nonempty then
    (separatingCuts s t).sup' h (cutWeight w) - horizonValue s t w
  else 0

/-! ## Key Lemmas -/

/-- The number of crossing pairs for any cut is at most `(Fintype.card V)²`. -/
lemma crossing_pairs_bound (S : Finset V) :
    (S.card * Sᶜ.card : ℤ) ≤ (Fintype.card V : ℤ) ^ 2 := by
  have h1 : S.card ≤ Fintype.card V := Finset.card_le_univ S
  have h2 : Sᶜ.card ≤ Fintype.card V := Finset.card_le_univ Sᶜ
  calc (S.card * Sᶜ.card : ℤ) ≤ (Fintype.card V : ℤ) * Fintype.card V := by
        exact_mod_cast Nat.mul_le_mul h1 h2
    _ = (Fintype.card V : ℤ) ^ 2 := by ring

/-
The cut weight difference between two weight functions is bounded by the
    number of crossing edges times the maximum weight difference.
-/
lemma cutWeight_diff_le (w₁ w₂ : V → V → ℝ) (S : Finset V) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hclose : ∀ i j, |w₁ i j - w₂ i j| ≤ ε) :
    |cutWeight w₁ S - cutWeight w₂ S| ≤ ((Fintype.card V) ^ 2 : ℝ) * ε := by
  -- Apply the triangle inequality to the double sum.
  have h_triangle : abs (∑ i ∈ S, ∑ j ∈ Sᶜ, (w₁ i j - w₂ i j)) ≤ ∑ i ∈ S, ∑ j ∈ Sᶜ, abs (w₁ i j - w₂ i j) := by
    exact Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun i hi => Finset.abs_sum_le_sum_abs _ _;
  refine' le_trans _ ( h_triangle.trans _ );
  · simp +decide [ cutWeight, Finset.sum_sub_distrib ] ;
  · refine' le_trans ( Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => hclose i j ) _;
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq, mul_assoc, Finset.card_compl ];
    gcongr ; exact Nat.le_trans ( Nat.sub_le _ _ ) ( Nat.le_refl _ );
    exact Finset.card_le_univ _

/-- When separating cuts exist, `horizonValue` equals the inf' of cut weights. -/
lemma horizonValue_eq_inf' (s t : V) (w : V → V → ℝ)
    (h : (separatingCuts s t).Nonempty) :
    horizonValue s t w = (separatingCuts s t).inf' h (cutWeight w) := by
  simp [horizonValue, h]

/-
Any separating cut has cut weight at least the horizon value.
-/
lemma horizonValue_le_cutWeight (s t : V) (w : V → V → ℝ) (S : Finset V)
    (hS : IsSeparating s t S) :
    horizonValue s t w ≤ cutWeight w S := by
  unfold horizonValue;
  split_ifs <;> simp_all +decide [ Finset.inf'_le ];
  · exact ⟨ S, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hS ⟩, le_rfl ⟩;
  · simp_all +decide [ Finset.ext_iff, IsSeparating ];
    rename_i h; specialize h S; simp_all +decide [ separatingCuts ] ;
    exact False.elim ( h ⟨ hS.1, hS.2 ⟩ )

/-
There exists a separating cut achieving the horizon value (when s ≠ t).
-/
lemma exists_minimizer_of_ne (s t : V) (w : V → V → ℝ) (hst : s ≠ t) :
    ∃ S, IsHorizonMinimizer s t w S := by
  have := Finset.exists_mem_eq_inf' ( show ( separatingCuts s t ).Nonempty from ?_ ) ( cutWeight w );
  obtain ⟨ S, hS₁, hS₂ ⟩ := this;
  exact ⟨ S, ⟨ Finset.mem_filter.mp hS₁ |>.2, hS₂ ▸ horizonValue_eq_inf' s t w ( Finset.nonempty_of_ne_empty ( by rintro h; simp_all +decide [ Finset.ext_iff ] ) ) |> Eq.symm ⟩ ⟩;
  exact ⟨ { s }, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simp +decide, by simpa [ hst.symm ] ⟩ ⟩

/-! ## Main Theorems -/

/-
**Horizon Value Lipschitz Stability**:
    If two edge-weight functions differ by at most `ε` pointwise,
    then the horizon values differ by at most `(card V)² * ε`.

    This is the key quantitative stability result for discrete horizons.
    It says that the "area" of the minimal cut surface is a Lipschitz
    function of the edge weights, with an explicit combinatorial constant.
-/
theorem horizon_value_lipschitz
    (s t : V)
    (w₁ w₂ : V → V → ℝ)
    (ε : ℝ)
    (hε : 0 ≤ ε)
    (hclose : ∀ i j, |w₁ i j - w₂ i j| ≤ ε) :
    |horizonValue s t w₁ - horizonValue s t w₂| ≤
      ((Fintype.card V) ^ 2 : ℝ) * ε := by
  by_cases h : ( separatingCuts s t ).Nonempty <;> simp +decide [ h, horizonValue ];
  · refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
    · obtain ⟨ S, hS ⟩ := Finset.exists_min_image ( separatingCuts s t ) ( fun S => cutWeight w₂ S ) h;
      refine' le_trans ( sub_le_sub ( Finset.inf'_le _ hS.1 ) ( Finset.le_inf' _ _ hS.2 ) ) _;
      exact le_of_abs_le ( cutWeight_diff_le w₁ w₂ S ε hε hclose );
    · obtain ⟨ S, hS ⟩ := Finset.exists_mem_eq_inf' h ( cutWeight w₁ );
      have := cutWeight_diff_le w₁ w₂ S ε hε hclose;
      linarith [ abs_le.mp this, show ( Finset.inf' ( separatingCuts s t ) h ( cutWeight w₂ ) ) ≤ cutWeight w₂ S from Finset.inf'_le _ hS.1 ];
  · positivity

/-
**Horizon Minimizer Membership Stability**:
    Under a strict gap hypothesis, any minimizer for the perturbed weights
    must also be a minimizer for the original weights.
-/
theorem horizon_minimizer_stable_of_gap
    (s t : V)
    (w₁ w₂ : V → V → ℝ)
    (S : Finset V)
    (ε δ : ℝ)
    (hε : 0 ≤ ε)
    (_hδ : 0 < δ)
    (hclose : ∀ i j, |w₁ i j - w₂ i j| ≤ ε)
    (hgap : ∀ T, IsSeparating s t T → ¬IsHorizonMinimizer s t w₁ T →
      cutWeight w₁ T ≥ horizonValue s t w₁ + δ)
    (hsmall : 2 * ((Fintype.card V) ^ 2 : ℝ) * ε < δ)
    (hS : IsHorizonMinimizer s t w₂ S) :
    IsHorizonMinimizer s t w₁ S := by
  refine' ⟨ hS.1, le_antisymm _ _ ⟩;
  · contrapose! hgap;
    refine' ⟨ S, hS.1, _, _ ⟩;
    · exact fun h => hgap.ne h.2.symm;
    · have h_diff : |cutWeight w₁ S - cutWeight w₂ S| ≤ ((Fintype.card V) ^ 2 : ℝ) * ε := by
        convert cutWeight_diff_le w₁ w₂ S ε hε hclose using 1;
      linarith [ abs_le.mp h_diff, hS.2, show horizonValue s t w₂ ≤ horizonValue s t w₁ + ( Fintype.card V : ℝ ) ^ 2 * ε from by linarith [ abs_le.mp ( show |horizonValue s t w₁ - horizonValue s t w₂| ≤ ( Fintype.card V : ℝ ) ^ 2 * ε from by simpa using horizon_value_lipschitz s t w₁ w₂ ε hε hclose ) ] ];
  · exact TropicalHorizon.horizonValue_le_cutWeight s t w₁ S hS.1

/-
**Einstein–Maxwell Horizon Lipschitz Stability**:
    Joint perturbation stability for coupled gravitational-gauge horizons.
    The effective weight is `w_eff i j = g i j + lam * |A i j|`.
-/
theorem einstein_maxwell_horizon_lipschitz
    (s t : V)
    (g₁ g₂ A₁ A₂ : V → V → ℝ)
    (lam εg εA : ℝ)
    (hlam : 0 ≤ lam)
    (hεg : 0 ≤ εg)
    (hεA : 0 ≤ εA)
    (hg : ∀ i j, |g₁ i j - g₂ i j| ≤ εg)
    (hA : ∀ i j, |A₁ i j - A₂ i j| ≤ εA) :
    |horizonValue s t (fun i j => g₁ i j + lam * |A₁ i j|)
      - horizonValue s t (fun i j => g₂ i j + lam * |A₂ i j|)| ≤
    ((Fintype.card V) ^ 2 : ℝ) * (εg + lam * εA) := by
  convert TropicalHorizon.horizon_value_lipschitz s t ( fun i j => g₁ i j + lam * |A₁ i j| ) ( fun i j => g₂ i j + lam * |A₂ i j| ) ( εg + lam * εA ) ( by positivity ) _ using 1;
  exact fun i j => abs_le.mpr ⟨ by cases abs_cases ( A₁ i j ) <;> cases abs_cases ( A₂ i j ) <;> nlinarith [ abs_le.mp ( hg i j ), abs_le.mp ( hA i j ) ], by cases abs_cases ( A₁ i j ) <;> cases abs_cases ( A₂ i j ) <;> nlinarith [ abs_le.mp ( hg i j ), abs_le.mp ( hA i j ) ] ⟩

/-
**Horizon Microstate Count Bound**:
    The number of separating cuts is at most `2 ^ Fintype.card V`.
    This provides the discrete analogue of the Bekenstein–Hawking
    area-entropy bound.
-/
theorem horizon_microstate_count_bound (s t : V) :
    (separatingCuts s t).card ≤ 2 ^ Fintype.card V := by
  exact le_trans ( Finset.card_le_univ _ ) ( by simp +decide )

end TropicalHorizon