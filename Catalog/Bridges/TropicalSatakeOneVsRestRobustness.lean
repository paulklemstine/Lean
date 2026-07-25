/-
Copyright (c) 2026 Harmonic. All rights reserved.

# GL₃ Tropical Satake One-vs-Rest Certified Robustness

## Overview

This file formalizes a multiclass certified robustness theorem for GL3 tropical
Satake / Hecke-score classifiers under the one-vs-rest decision rule. The key
result shows that the quantitative constant `2 * K * d` from binary score-difference
Lipschitz bounds governs the multiclass certified radius through the one-vs-rest
margin.

## Main Results

* `ovrMargin_le_pair` — the OVR margin is at most each pairwise margin
* `lt_ovrMargin_iff` — characterization of `t < ovrMargin`
* `predicts_of_margin_nonneg` — prediction from nonneg pairwise margins
* `pairwise_nonneg_of_lip_margin` — binary certificate for each class pair
* `gl3_ovr_certified_radius` — main multiclass certified robustness theorem
* `gl3_satake_pairwise_diff_lipschitz` — bridge from per-class Lipschitz to pairwise

## Mathematical Content

The proof reduces multiclass robustness to pairwise margin preservation.
For each competing class `c ≠ y`, the score difference `S y x - S c x` is
bounded by the OVR margin, and the pairwise Lipschitz constant `2 * K * d`
controls the perturbation. The certified radius is `ovrMargin S y x / (2 * K * d)`.
-/

import Mathlib

open Finset

noncomputable section

set_option maxHeartbeats 800000

/-! ## Core Definitions -/

/-- The prediction relation: `y` is a maximizer of the score function `S` at `x`. -/
def predicts {C : Type*} {n : ℕ} (S : C → (Fin n → ℝ) → ℝ) (y : C) (x : Fin n → ℝ) : Prop :=
  ∀ c, S c x ≤ S y x

/-- Nonemptiness of `Finset.univ.erase y` for a Nontrivial Fintype. -/
lemma erase_univ_nonempty {C : Type*} [Fintype C] [DecidableEq C] [Nontrivial C] (y : C) :
    (Finset.univ.erase y).Nonempty := by
  obtain ⟨a, b, hab⟩ := exists_pair_ne C
  by_cases hay : a = y
  · exact ⟨b, Finset.mem_erase.mpr ⟨fun h => hab (hay ▸ h.symm), Finset.mem_univ _⟩⟩
  · exact ⟨a, Finset.mem_erase.mpr ⟨hay, Finset.mem_univ _⟩⟩

/-- The one-vs-rest margin at `x` for predicted class `y`:
    the minimum over all competitors `c ≠ y` of `S y x - S c x`. -/
def ovrMargin {C : Type*} [Fintype C] [DecidableEq C] [Nontrivial C]
    {n : ℕ} (S : C → (Fin n → ℝ) → ℝ) (y : C) (x : Fin n → ℝ) : ℝ :=
  (Finset.univ.erase y).inf' (erase_univ_nonempty y) (fun c => S y x - S c x)

/-! ## Margin Lemmas -/

/-- The OVR margin is at most each pairwise margin for `c ≠ y`. -/
theorem ovrMargin_le_pair {C : Type*} [Fintype C] [DecidableEq C] [Nontrivial C]
    {n : ℕ} (S : C → (Fin n → ℝ) → ℝ) (y : C) (x : Fin n → ℝ) (c : C) (hc : c ≠ y) :
    ovrMargin S y x ≤ S y x - S c x :=
  Finset.inf'_le _ (Finset.mem_erase.mpr ⟨hc, Finset.mem_univ _⟩)

/-- Characterization: `t < ovrMargin` iff `t` is less than every pairwise margin. -/
theorem lt_ovrMargin_iff {C : Type*} [Fintype C] [DecidableEq C] [Nontrivial C]
    {n : ℕ} (S : C → (Fin n → ℝ) → ℝ) (y : C) (x : Fin n → ℝ) (t : ℝ) :
    t < ovrMargin S y x ↔ ∀ c, c ≠ y → t < S y x - S c x := by
  unfold ovrMargin
  constructor
  · intro h c hc
    exact lt_of_lt_of_le h (Finset.inf'_le _ (Finset.mem_erase.mpr ⟨hc, Finset.mem_univ _⟩))
  · intro h
    apply (Finset.lt_inf'_iff (erase_univ_nonempty y)).mpr
    intro c hc
    exact h c (Finset.mem_erase.mp hc).1

/-! ## Prediction Lemmas -/

/-- Derive prediction from nonneg pairwise margins. -/
theorem predicts_of_margin_nonneg {C : Type*}
    {n : ℕ} (S : C → (Fin n → ℝ) → ℝ) (y : C) (x : Fin n → ℝ)
    (h : ∀ c, c ≠ y → 0 ≤ S y x - S c x) :
    predicts S y x := by
  intro c
  by_cases hc : c = y
  · rw [hc]
  · linarith [h c hc]

/-- Prediction at all `c ≠ y` gives prediction. -/
theorem predicts_of_all_pairwise_certified {C : Type*}
    {n : ℕ} (S : C → (Fin n → ℝ) → ℝ) (y : C) (z : Fin n → ℝ)
    (h : ∀ c, c ≠ y → 0 ≤ S y z - S c z) :
    predicts S y z :=
  predicts_of_margin_nonneg S y z h

/-! ## Binary Certificate Lemma -/

/-
For a single score difference function with Lipschitz bound,
    if the margin is positive and the perturbation is small enough,
    the margin remains nonneg.
-/
theorem pairwise_nonneg_of_lip_margin
    {n : ℕ} (f : (Fin n → ℝ) → ℝ)
    (L : ℝ) (hL : 0 < L)
    (hLip : ∀ x z : Fin n → ℝ, |f z - f x| ≤ L * ‖z - x‖)
    {x z : Fin n → ℝ}
    (_hfx : 0 < f x)
    (hz : ‖z - x‖ < f x / L) :
    0 ≤ f z := by
  nlinarith [ abs_le.mp ( hLip x z ), mul_div_cancel₀ ( f x ) hL.ne' ]

/-! ## GL3 Satake Pairwise Difference Lipschitz Bridge -/

/-- A family of score functions indexed by `C` is a GL3 tropical Satake family
    with constants `K` and `d` if each individual score function is `(K * d)`-Lipschitz. -/
structure IsGL3TropicalSatakeFamily {C : Type*} {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ) (K d : ℝ) : Prop where
  /-- Each score function `S c` is Lipschitz with constant `K * d`. -/
  lip : ∀ c : C, ∀ x z : Fin n → ℝ, |S c x - S c z| ≤ K * d * ‖x - z‖

/-
The pairwise score-difference Lipschitz bound: if each `S c` is `(K*d)`-Lipschitz,
    then the score differences `S a - S b` are `(2*K*d)`-Lipschitz.
    This is the quantitative bridge from the GL3 tropical Satake realization to
    the robustness API.
-/
theorem gl3_satake_pairwise_diff_lipschitz {C : Type*} {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ) (K d : ℝ)
    (hSatake : IsGL3TropicalSatakeFamily S K d) :
    ∀ a b : C, a ≠ b →
      ∀ x z : Fin n → ℝ,
        |((S a x - S b x) - (S a z - S b z))| ≤ (2 * K * d) * ‖x - z‖ := by
  rcases hSatake with ⟨ h ⟩;
  intro a b hab x z; rw [ abs_le ] ; constructor <;> linarith [ abs_le.mp ( h a x z ), abs_le.mp ( h b x z ) ] ;

/-! ## Main Certified Robustness Theorem -/

/-
**GL3 One-vs-Rest Certified Robustness (z-formulation).**

    If `y` is the predicted class at `x` with positive OVR margin,
    and each pairwise score difference `S y - S c` satisfies a
    `(2*K*d)`-Lipschitz bound, then any `z` within the certified radius
    `ovrMargin S y x / (2 * K * d)` preserves the prediction.
-/
theorem gl3_ovr_certified_radius'
    {C : Type*} [Fintype C] [DecidableEq C] [Nontrivial C]
    {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ)
    (K d : ℝ)
    (y : C) (x z : Fin n → ℝ)
    (hLip : ∀ c, c ≠ y →
      |((S y z - S c z) - (S y x - S c x))| ≤ (2 * K * d) * ‖z - x‖)
    (hmargin : 0 < ovrMargin S y x)
    (hz : ‖z - x‖ < ovrMargin S y x / (2 * K * d)) :
    predicts S y z := by
  apply predicts_of_all_pairwise_certified;
  intro c hc
  have hmargin_c : S y x - S c x ≥ ovrMargin S y x := by
    exact ovrMargin_le_pair S y x c hc
  have hmargin_c_z : S y z - S c z ≥ S y x - S c x - 2 * K * d * ‖z - x‖ := by
    linarith [ abs_le.mp ( hLip c hc ) ]
  have hmargin_c_z_nonneg : S y z - S c z ≥ 0 := by
    contrapose! hz;
    rw [ div_le_iff₀ ] <;> nlinarith [ norm_nonneg ( z - x ) ]
  exact hmargin_c_z_nonneg

/-
**GL3 One-vs-Rest Certified Robustness (δ-formulation).**

    Equivalent to `gl3_ovr_certified_radius'` but stated in terms of
    perturbation `δ` with `z = x + δ`.
-/
theorem gl3_ovr_certified_radius
    {C : Type*} [Fintype C] [DecidableEq C] [Nontrivial C]
    {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ)
    (K d : ℝ)
    (_hKd : 0 < 2 * K * d)
    (hLip : ∀ a b : C, a ≠ b →
      ∀ x z : Fin n → ℝ,
        |((S a x - S b x) - (S a z - S b z))| ≤ (2 * K * d) * ‖x - z‖)
    {y : C} {x : Fin n → ℝ}
    (_hpred : predicts S y x)
    (hmargin : 0 < ovrMargin S y x) :
    ∀ δ : Fin n → ℝ,
      ‖δ‖ < ovrMargin S y x / (2 * K * d) →
      predicts S y (x + δ) := by
  intro δ hδ;
  convert gl3_ovr_certified_radius' S K d y x ( x + δ ) _ hmargin _ using 1;
  · exact fun c hc => hLip y c ( Ne.symm hc ) _ _;
  · simpa using hδ

/-! ## Corollary: Full GL3 Satake Bridge -/

/-- **Full GL3 Satake certified robustness.**

    Combines `gl3_satake_pairwise_diff_lipschitz` with `gl3_ovr_certified_radius`
    to give a single-statement robustness theorem from the GL3 Satake family
    condition. -/
theorem gl3_satake_ovr_certified_robustness
    {C : Type*} [Fintype C] [DecidableEq C] [Nontrivial C]
    {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ)
    (K d : ℝ)
    (hKd : 0 < K * d)
    (hSatake : IsGL3TropicalSatakeFamily S K d)
    {y : C} {x : Fin n → ℝ}
    (hpred : predicts S y x)
    (hmargin : 0 < ovrMargin S y x) :
    ∀ δ : Fin n → ℝ,
      ‖δ‖ < ovrMargin S y x / (2 * K * d) →
      predicts S y (x + δ) := by
  have hKd2 : 0 < 2 * K * d := by linarith
  exact gl3_ovr_certified_radius S K d hKd2
    (fun a b hab x z => gl3_satake_pairwise_diff_lipschitz S K d hSatake a b hab x z)
    hpred hmargin

end