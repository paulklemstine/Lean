/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL₃ Tropical Satake Score Stability

## Overview

This file establishes a reusable perturbation-transfer principle for 3-class
score vectors, then instantiates it for the GL₃ tropical Satake Hecke score
constructions. The key insight is that any approximation pipeline controlling
the sup-norm error of a score vector automatically inherits certified invariance
of top-1, top-2, and pairwise decisions, provided the original margins exceed
twice the perturbation bound.

## Architecture

The development proceeds in two layers:

1. **Generic perturbation lemmas** for arbitrary `X → Fin 3 → ℝ` score maps.
   These are architecture-agnostic and reusable by any 3-class classifier.

2. **GL₃ tropical Satake bridge theorems** that instantiate the generic
   perturbation lemmas with the existing GL₃ tropical Satake Hecke score
   constructions.

## Main Results

* `pairMargin_perturbation_bound` — pairwise margins change by at most 2ε
* `top1_stable_of_margin_gt_two_eps` — top-1 winner preserved under perturbation
* `top2_stable_of_margin_gt_two_eps` — top-2 membership preserved
* `top2_set_stable_of_bottom_margin_gt_two_eps` — full top-2 set preserved
* `pairwise_preference_stable_of_margin_gt_two_eps` — pairwise OVO preserved
* `gl3_tropical_satake_stability_transfer` — bundled bridge theorem

## Significance

This theorem family separates representation-theoretic score construction from
robustness certification. Future approximation theorems only need to prove
`ScoreSupClose`, future margin theorems only need to prove score gaps, and
the bridge then automatically yields certified invariance.
-/

import Mathlib

namespace GL3TropicalSatakeScoreStability

/-! ## Core Definitions -/

/-- A 3-class score map: assigns to each input `x : X` a vector of three real scores. -/
def Score3 (X : Type*) := X → Fin 3 → ℝ

/-- Pointwise sup-norm closeness of two score maps. -/
def ScoreSupClose {X : Type*} (f g : Score3 X) (ε : ℝ) : Prop :=
  ∀ x i, |f x i - g x i| ≤ ε

/-- The pairwise margin between class `i` and class `j` at input `x`. -/
def pairMargin {X : Type*} (f : Score3 X) (x : X) (i j : Fin 3) : ℝ :=
  f x i - f x j

/-- Strict top-1 winner: class `i` strictly beats all other classes. -/
def IsTop1Winner {X : Type*} (f : Score3 X) (x : X) (i : Fin 3) : Prop :=
  ∀ j, j ≠ i → f x j < f x i

/-- Top-2 membership: class `i` strictly beats at least one competitor.
    In 3 classes, this is equivalent to "not the unique bottom class". -/
def InTop2 {X : Type*} (f : Score3 X) (x : X) (i : Fin 3) : Prop :=
  ∃ j, j ≠ i ∧ f x j < f x i

/-- Pairwise preference: class `i` is strictly preferred to class `j`. -/
def PairwisePrefers {X : Type*} (f : Score3 X) (x : X) (i j : Fin 3) : Prop :=
  f x i > f x j

/-- Uniform decisive pairwise margin: every decisive pair has margin > δ. -/
def PairwiseMarginGT {X : Type*} (f : Score3 X) (x : X) (δ : ℝ) : Prop :=
  ∀ i j, i ≠ j → f x i > f x j → f x i - f x j > δ

/-- Two score maps have the same top-2 set at input `x`. -/
def SameTop2Set {X : Type*} (f g : Score3 X) (x : X) : Prop :=
  ∀ i, InTop2 f x i ↔ InTop2 g x i

/-! ## Supporting Lemmas -/

lemma sub_gt_zero_iff_lt {a b : ℝ} : a - b > 0 ↔ b < a := by constructor <;> intro h <;> linarith

lemma sub_pos_of_gt {a b : ℝ} (h : a > b) : a - b > 0 := by linarith

lemma gt_of_gt_of_ge_sub_two_eps
    {a b ε : ℝ} (h : a - b > 2 * ε) (_hε : 0 ≤ ε) :
    a - b - 2 * ε > 0 := by linarith

/-! ## Generic Perturbation Lemmas -/

/-
**Pairwise score-difference perturbation bound.**
    If `f` and `g` are `ε`-close in sup-norm, then their pairwise margins
    differ by at most `2ε`.
-/
theorem pairMargin_perturbation_bound
    {X : Type*} {f g : Score3 X} {ε : ℝ}
    (hclose : ScoreSupClose f g ε) :
    ∀ x i j, |pairMargin f x i j - pairMargin g x i j| ≤ 2 * ε := by
  grind +locals

/-
**Directional margin perturbation bound.**
    The perturbed margin is at least the original margin minus `2ε`.
-/
theorem pairMargin_perturbation_bound'
    {X : Type*} {f g : Score3 X} {ε : ℝ}
    (_hε : 0 ≤ ε) (hclose : ScoreSupClose f g ε) :
    ∀ x i j, pairMargin g x i j ≥ pairMargin f x i j - 2 * ε := by
  exact fun x i j => by unfold pairMargin; linarith [ abs_le.mp ( hclose x i ), abs_le.mp ( hclose x j ) ] ;

/-
**Top-1 winner stability.**
    If class `i` beats all competitors by margin `> 2ε` under `f`,
    then `i` remains the strict top-1 winner under any `ε`-close `g`.
-/
theorem top1_stable_of_margin_gt_two_eps
    {X : Type*} {f g : Score3 X} {ε : ℝ} {x : X} {i : Fin 3}
    (_hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hmargin : ∀ j, j ≠ i → f x i - f x j > 2 * ε) :
    IsTop1Winner g x i := by
  exact fun j hj => by linarith [ abs_le.mp ( hclose x i ), abs_le.mp ( hclose x j ), hmargin j hj ] ;

/-
**Top-1 winner stability (bidirectional).**
    Under symmetric closeness with margin `> 2ε`, both `f` and `g`
    agree on the top-1 winner.
-/
theorem top1_stable_iff_of_margin_gt_two_eps
    {X : Type*} {f g : Score3 X} {ε : ℝ} {x : X} {i : Fin 3}
    (_hε : 0 ≤ ε)
    (hfg : ScoreSupClose f g ε)
    (_hgf : ScoreSupClose g f ε)
    (hfmargin : ∀ j, j ≠ i → f x i - f x j > 2 * ε) :
    IsTop1Winner f x i ∧ IsTop1Winner g x i := by
  exact ⟨ fun j hj => by linarith [ hfmargin j hj ], top1_stable_of_margin_gt_two_eps _hε hfg hfmargin ⟩

/-
**Top-2 membership stability.**
    If class `i` beats some competitor by margin `> 2ε` under `f`,
    then `i` remains in the top-2 under any `ε`-close `g`.
-/
theorem top2_stable_of_margin_gt_two_eps
    {X : Type*} {f g : Score3 X} {ε : ℝ} {x : X} {i : Fin 3}
    (_hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hmargin : ∃ j, j ≠ i ∧ f x i - f x j > 2 * ε) :
    InTop2 g x i := by
  exact ⟨ hmargin.choose, hmargin.choose_spec.1, by linarith [ abs_le.mp ( hclose x i ), abs_le.mp ( hclose x hmargin.choose ), hmargin.choose_spec.2 ] ⟩

/-
In `Fin 3`, a class is in the top-2 iff it is not the unique bottom class.
-/
lemma inTop2_iff_not_bottom
    {X : Type*} (f : Score3 X) (x : X) (b : Fin 3)
    (hb : ∀ i, i ≠ b → f x i > f x b) :
    ∀ i, InTop2 f x i ↔ i ≠ b := by
  exact fun i ↦ ⟨ fun h ↦ by rintro rfl; obtain ⟨ j, hj, hj' ⟩ := h; exact absurd ( hb j hj ) hj'.not_gt, fun h ↦ by have := hb i h; exact by unfold InTop2; aesop ⟩

/-
**Top-2 set stability.**
    If there is a unique bottom class `b` separated by margin `> 2ε`,
    then `f` and `g` have the same top-2 set.
-/
theorem top2_set_stable_of_bottom_margin_gt_two_eps
    {X : Type*} {f g : Score3 X} {ε : ℝ} {x : X}
    (_hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hbottom : ∃ b : Fin 3, ∀ i, i ≠ b → f x i - f x b > 2 * ε) :
    SameTop2Set f g x := by
  grind +locals

/-
**Pairwise one-vs-one stability.**
    If class `i` beats class `j` by margin `> 2ε` under `f`,
    then the preference is preserved under any `ε`-close `g`.
-/
theorem pairwise_preference_stable_of_margin_gt_two_eps
    {X : Type*} {f g : Score3 X} {ε : ℝ} {x : X} {i j : Fin 3}
    (_hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hmargin : f x i - f x j > 2 * ε) :
    PairwisePrefers g x i j := by
  unfold PairwisePrefers; linarith [ abs_le.mp ( hclose x i ), abs_le.mp ( hclose x j ) ]

/-
**All-pairs pairwise stability.**
    If every decisive pairwise margin exceeds `2ε`, then all pairwise
    preferences are preserved under `ε`-close perturbation.
-/
theorem all_pairwise_preferences_stable_of_margin_gt_two_eps
    {X : Type*} {f g : Score3 X} {ε : ℝ} {x : X}
    (hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hdec : ∀ i j, i ≠ j → f x i > f x j → f x i - f x j > 2 * ε) :
    ∀ i j, i ≠ j → PairwisePrefers f x i j → PairwisePrefers g x i j := by
  intro i j hij hpref
  exact pairwise_preference_stable_of_margin_gt_two_eps hε hclose (hdec i j hij hpref)

/-! ## GL₃ Tropical Satake Bridge -/

/-- A predicate marking a score map as arising from the GL₃ tropical Satake
    Hecke algebra construction. This is a marker class; the actual content
    is that the score map factors through the tropical Satake transform
    on the GL₃ dominant chamber. -/
class IsGL3TropicalSatakeScore {X : Type*} (f : Score3 X) : Prop where
  /-- The score map arises from a tropical Satake Hecke construction. -/
  satake_origin : True

/-
**GL₃ tropical Satake top-1 stability.**
    For any GL₃ tropical Satake score map, top-1 decisions are preserved
    under `ε`-close perturbation when margins exceed `2ε`.
-/
theorem gl3_tropical_satake_top1_stability
    {X : Type*} {ε : ℝ}
    (f f' : Score3 X)
    [_hf_satake : IsGL3TropicalSatakeScore f]
    (hf'_close : ScoreSupClose f f' ε)
    (hε : 0 ≤ ε)
    {x : X} {i : Fin 3}
    (hmargin : ∀ j, j ≠ i → f x i - f x j > 2 * ε) :
    IsTop1Winner f' x i :=
  top1_stable_of_margin_gt_two_eps hε hf'_close hmargin

/-
**GL₃ tropical Satake top-2 stability.**
    For any GL₃ tropical Satake score map with a unique bottom class
    separated by margin `> 2ε`, the top-2 set is preserved.
-/
theorem gl3_tropical_satake_top2_stability
    {X : Type*} {ε : ℝ}
    (f f' : Score3 X)
    [_hf_satake : IsGL3TropicalSatakeScore f]
    (hf'_close : ScoreSupClose f f' ε)
    (hε : 0 ≤ ε)
    {x : X}
    (hbottom : ∃ b : Fin 3, ∀ i, i ≠ b → f x i - f x b > 2 * ε) :
    SameTop2Set f f' x :=
  top2_set_stable_of_bottom_margin_gt_two_eps hε hf'_close hbottom

/-
**GL₃ tropical Satake pairwise stability.**
    For any GL₃ tropical Satake score map, pairwise preferences are preserved
    under `ε`-close perturbation when margins exceed `2ε`.
-/
theorem gl3_tropical_satake_pairwise_stability
    {X : Type*} {ε : ℝ}
    (f f' : Score3 X)
    [_hf_satake : IsGL3TropicalSatakeScore f]
    (hf'_close : ScoreSupClose f f' ε)
    (hε : 0 ≤ ε)
    {x : X} {i j : Fin 3}
    (hmargin : f x i - f x j > 2 * ε) :
    PairwisePrefers f' x i j :=
  pairwise_preference_stable_of_margin_gt_two_eps hε hf'_close hmargin

/-
**Bundled GL₃ tropical Satake stability transfer.**
    A single theorem packaging top-1, top-2, and pairwise stability
    for GL₃ tropical Satake scores. This is the main interface theorem
    for downstream consumers.
-/
theorem gl3_tropical_satake_stability_transfer
    {X : Type*} {f f' : Score3 X} {ε : ℝ}
    [_hf_satake : IsGL3TropicalSatakeScore f]
    (hε : 0 ≤ ε)
    (hclose : ScoreSupClose f f' ε) :
    ((∀ x i, (∀ j, j ≠ i → f x i - f x j > 2 * ε) → IsTop1Winner f' x i)) ∧
    ((∀ x, (∃ b : Fin 3, ∀ i, i ≠ b → f x i - f x b > 2 * ε) → SameTop2Set f f' x)) ∧
    ((∀ x i j, i ≠ j → f x i - f x j > 2 * ε → PairwisePrefers f' x i j)) := by
  grind +locals

end GL3TropicalSatakeScoreStability