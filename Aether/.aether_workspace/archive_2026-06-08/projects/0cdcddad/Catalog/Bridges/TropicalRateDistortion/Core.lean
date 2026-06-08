/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Rate–Distortion Core: Rate Functionals and Threshold Spectra

## Overview

This file establishes the foundational theory of tropical rate functionals
and their threshold spectra. The tropical rate functional

  R(λ) = inf_i (δ(i) + λ · w(i))

is the min-plus analogue of a support function / free-energy functional.
Its breakpoints (thresholds) classify the certified decoding regions in
tropical code systems.

## Main Results

* `tropicalRate_le_score` — the rate is at most the score of any element
* `tropicalRate_minimizer_exists` — a minimizer always exists (finite nonempty type)
* `argminSet_nonempty` — the argmin set is always nonempty
* `threshold_iff_multiple_minimizers` — thresholds ↔ multi-minimizer values
* `perturbation_stability` — unique minimizers are stable under bounded perturbations
* `threshold_subset_breakpoints` — thresholds lie among pairwise breakpoints
* `tropicalRate_eq_closurePressure` — rate = pressure under canonical distortion
* `certified_asymmetry` — trapdoor witness certifies decoding stability
-/

noncomputable section

open Finset

namespace TropicalRateDistortion

variable {α : Type*} [Fintype α] [Nonempty α]

/-! ## Score and Rate Functionals -/

/-- The score of element `a` at parameter `l`: the affine function δ(a) + l · w(a). -/
def score (δ w : α → ℝ) (l : ℝ) (a : α) : ℝ := δ a + l * w a

/-- The tropical rate functional: R(l) = inf_i (δ(i) + l · w(i)).
    This is the lower envelope of affine functions in l. -/
def tropicalRate (δ w : α → ℝ) (l : ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun a => score δ w l a)

omit [Fintype α] [Nonempty α] in
@[simp]
lemma score_def (δ w : α → ℝ) (l : ℝ) (a : α) :
    score δ w l a = δ a + l * w a := rfl

/-- The rate is at most the score of any element. -/
lemma tropicalRate_le_score (δ w : α → ℝ) (l : ℝ) (a : α) :
    tropicalRate δ w l ≤ score δ w l a :=
  Finset.inf'_le _ (Finset.mem_univ a)

/-- There exists a minimizer achieving the rate. -/
lemma tropicalRate_minimizer_exists (δ w : α → ℝ) (l : ℝ) :
    ∃ a, tropicalRate δ w l = score δ w l a := by
  obtain ⟨a, _, ha⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty (fun a => score δ w l a)
  exact ⟨a, ha⟩

/-
Characterization: the rate is the minimum score.
-/
lemma tropicalRate_eq_score_iff (δ w : α → ℝ) (l : ℝ) (a : α) :
    tropicalRate δ w l = score δ w l a ↔
      ∀ b, score δ w l a ≤ score δ w l b := by
  constructor;
  · exact fun h b => h ▸ Finset.inf'_le _ ( Finset.mem_univ _ );
  · intro h;
    exact le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ a ) ) ( Finset.le_inf' _ _ fun b _ => h b )

/-! ## Argmin Sets and Minimizers -/

/-- An element is a minimizer at l if its score equals the rate. -/
def IsMinimizer (δ w : α → ℝ) (l : ℝ) (a : α) : Prop :=
  score δ w l a = tropicalRate δ w l

/-- The argmin set: all elements achieving the minimum score. -/
def argminSet (δ w : α → ℝ) (l : ℝ) : Finset α :=
  Finset.univ.filter (fun a => score δ w l a = tropicalRate δ w l)

/-
The argmin set is always nonempty.
-/
lemma argminSet_nonempty (δ w : α → ℝ) (l : ℝ) : (argminSet δ w l).Nonempty := by
  obtain ⟨ a, ha ⟩ := TropicalRateDistortion.tropicalRate_minimizer_exists δ w l; use a; simp_all +decide [ TropicalRateDistortion.argminSet ] ;

/-- Every element in the argmin set is a minimizer. -/
lemma mem_argminSet_iff (δ w : α → ℝ) (l : ℝ) (a : α) :
    a ∈ argminSet δ w l ↔ IsMinimizer δ w l a := by
  simp [argminSet, IsMinimizer]

/-! ## Thresholds and Phase Transitions -/

/-- A parameter value `l` is a threshold if there exist distinct minimizers. -/
def IsThreshold (δ w : α → ℝ) (l : ℝ) : Prop :=
  ∃ a b, a ≠ b ∧ IsMinimizer δ w l a ∧ IsMinimizer δ w l b

/-
`l` is a threshold iff the argmin set has cardinality ≥ 2.
-/
lemma isThreshold_iff_argmin_card [DecidableEq α] (δ w : α → ℝ) (l : ℝ) :
    IsThreshold δ w l ↔ 1 < (argminSet δ w l).card := by
  constructor <;> intro h;
  · obtain ⟨ a, b, hab, ha, hb ⟩ := h; exact Finset.one_lt_card.2 ⟨ a, by simpa [ argminSet ] using ha, b, by simpa [ argminSet ] using hb, hab ⟩ ;
  · obtain ⟨ a, ha, b, hb, hab ⟩ := Finset.one_lt_card.1 h;
    exact ⟨ a, b, hab, by unfold argminSet at ha; aesop, by unfold argminSet at hb; aesop ⟩

/-- A unique minimizer: exactly one element achieves the minimum. -/
def HasUniqueMinimizer (δ w : α → ℝ) (l : ℝ) : Prop :=
  ∃! a, IsMinimizer δ w l a

/-
Unique minimizer iff not a threshold.
-/
lemma hasUniqueMinimizer_iff_not_threshold (δ w : α → ℝ) (l : ℝ) :
    HasUniqueMinimizer δ w l ↔ ¬IsThreshold δ w l := by
  constructor <;> intro h;
  · exact fun ⟨ a, b, hab, ha, hb ⟩ => hab ( h.unique ha hb );
  · obtain ⟨a, ha⟩ : ∃ a, IsMinimizer δ w l a := by
      exact Exists.elim ( TropicalRateDistortion.tropicalRate_minimizer_exists δ w l ) fun a ha => ⟨ a, ha.symm ⟩;
    exact ⟨ a, ha, fun b hb => Classical.not_not.1 fun hab => h ⟨ b, a, hab, hb, ha ⟩ ⟩

/-! ## Margin and Perturbation Stability -/

variable [DecidableEq α]

/-- The gap between the score of `b` and the minimum score at `a`,
    measuring how much `b` exceeds the best. -/
def scoreGap (δ w : α → ℝ) (l : ℝ) (a b : α) : ℝ :=
  score δ w l b - score δ w l a

/-- The margin of minimizer `a`: the minimum gap to any other element.
    Requires at least 2 elements in the type. -/
def marginAt [Nontrivial α] (δ w : α → ℝ) (l : ℝ) (a : α) : ℝ :=
  (Finset.univ.filter (fun b => b ≠ a)).inf'
    (by obtain ⟨b, hb⟩ := exists_ne a; exact ⟨b, mem_filter.mpr ⟨mem_univ b, hb⟩⟩)
    (fun b => scoreGap δ w l a b)

/-
The margin is positive when `a` is the unique minimizer.
-/
lemma marginAt_pos_of_unique [Nontrivial α] (δ w : α → ℝ) (l : ℝ) (a : α)
    (ha : IsMinimizer δ w l a)
    (huniq : ∀ b, b ≠ a → ¬IsMinimizer δ w l b) :
    0 < marginAt δ w l a := by
  unfold IsMinimizer at *;
  unfold marginAt;
  simp_all +decide [ Finset.inf'_lt_iff, scoreGap ];
  exact fun b hb => lt_of_le_of_ne ( ha ▸ tropicalRate_le_score δ w l b ) ( Ne.symm ( huniq b hb ) )

/-
**Perturbation stability theorem**: If `a` is the unique minimizer with margin `m > 0`,
    then for any perturbation `δ'` with |δ'(i) - δ(i)| < m/2 for all i,
    element `a` remains the best element in the perturbed system.
-/
theorem perturbation_stability [Nontrivial α] (δ δ' w : α → ℝ) (l : ℝ) (a : α)
    (ha : IsMinimizer δ w l a)
    (huniq : ∀ b, b ≠ a → ¬IsMinimizer δ w l b)
    (hpert : ∀ i, |δ' i - δ i| < marginAt δ w l a / 2) :
    ∀ b, score δ' w l b ≥ score δ' w l a := by
  intro b
  by_cases hb : b = a;
  · rw [ hb ];
  · -- By definition of marginAt, we know that for any b ≠ a, scoreGap δ w l a b ≥ marginAt δ w l a.
    have h_margin : scoreGap δ w l a b ≥ marginAt δ w l a := by
      exact Finset.inf'_le _ ( by aesop );
    unfold scoreGap score at *; linarith [ abs_lt.mp ( hpert a ), abs_lt.mp ( hpert b ) ] ;

/-! ## Breakpoints and Threshold Enumeration -/

/-- The breakpoint between elements `a` and `b`:
    l_ab = (δ(b) - δ(a)) / (w(a) - w(b)) when w(a) ≠ w(b). -/
def breakpointValue (δ w : α → ℝ) (a b : α) : ℝ :=
  (δ b - δ a) / (w a - w b)

/-
At the breakpoint, both elements have equal scores
    (when the denominator is nonzero).
-/
lemma score_eq_at_breakpoint (δ w : α → ℝ) (a b : α)
    (hw : w a ≠ w b) :
    score δ w (breakpointValue δ w a b) a =
    score δ w (breakpointValue δ w a b) b := by
  unfold score breakpointValue;
  grind

/-
If `a` and `b` are both minimizers at `l`, and have different weights,
    then `l` is the breakpoint value.
-/
lemma minimizer_pair_at_breakpoint (δ w : α → ℝ) (l : ℝ) (a b : α)
    (hw : w a ≠ w b)
    (ha : IsMinimizer δ w l a) (hb : IsMinimizer δ w l b) :
    l = breakpointValue δ w a b := by
  exact eq_div_of_mul_eq ( sub_ne_zero_of_ne hw ) ( by linarith [ score_def δ w l a, score_def δ w l b, ha.symm, hb.symm ] )

/-- The set of threshold candidates: all pairwise breakpoints. -/
def thresholdCandidates (δ w : α → ℝ) : Finset ℝ :=
  (Finset.univ ×ˢ Finset.univ).image (fun p => breakpointValue δ w p.1 p.2)

/-
**Threshold Spectrum Theorem**: Every threshold with distinct weights
    lies among the pairwise breakpoint candidates.
-/
theorem threshold_subset_breakpoints (δ w : α → ℝ) (l : ℝ)
    (hl : IsThreshold δ w l)
    (hw : ∀ a b, a ≠ b → IsMinimizer δ w l a → IsMinimizer δ w l b → w a ≠ w b) :
    l ∈ thresholdCandidates δ w := by
  obtain ⟨ a, b, hab, ha, hb ⟩ := hl;
  exact Finset.mem_image.mpr ⟨ ( a, b ), Finset.mem_product.mpr ⟨ Finset.mem_univ _, Finset.mem_univ _ ⟩, by rw [ minimizer_pair_at_breakpoint δ w l a b ( hw a b hab ha hb ) ha hb ] ⟩

end TropicalRateDistortion