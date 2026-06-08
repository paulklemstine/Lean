/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL₃ Tropical Satake Abstain Robustness

This file formalizes a selective multiclass classifier with reject option for three
tropical Satake/Hecke scores and proves stability theorems for both the accept and
reject decisions under perturbation, given pairwise-difference Lipschitz bounds on
the score functions.

## Main results

* `abstain_classifier_some_of_margin_ball` — robust preservation of a non-abstaining
  class decision from a strict top-2 margin bound.
* `abstain_classifier_none_of_topMargin_ball` — robust preservation of abstention
  from a strict top margin bound.
* `abstain_classifier_eq_some_preserved` — classifier-level preservation of `some i`.
* `abstain_classifier_none_preserved_half_radius` — half-radius corollary for
  abstention preservation matching the existing robustness library style.

## Design notes

The uniqueness lemma `classMargin_gt_tau_unique` and the classifier-level iff
`abstainClassifier_some_iff` require `0 ≤ τ`. This is because for negative `τ`,
multiple classes can simultaneously have margin above `τ` (e.g., when two classes
are tied for the top score). With `0 ≤ τ`, the margin condition forces a strict
argmax, which is unique.

The core robustness results (`abstain_classifier_some_of_margin_ball` and
`abstain_classifier_none_of_topMargin_ball`) do NOT require `0 ≤ τ` — they work
purely at the scalar margin level.
-/

import Mathlib

open Finset

noncomputable section

/-! ## Definitions -/

/-- Score vector: three real-valued score functions on a type `X`. -/
def ScoreVec (X : Type*) := Fin 3 → X → ℝ

private lemma erase_nonempty (i : Fin 3) :
    ((Finset.univ : Finset (Fin 3)).erase i).Nonempty := by
  fin_cases i
  · exact ⟨(1 : Fin 3), Finset.mem_erase.mpr ⟨by decide, Finset.mem_univ _⟩⟩
  · exact ⟨(0 : Fin 3), Finset.mem_erase.mpr ⟨by decide, Finset.mem_univ _⟩⟩
  · exact ⟨(0 : Fin 3), Finset.mem_erase.mpr ⟨by decide, Finset.mem_univ _⟩⟩

/-- The maximum score among competitors of class `i`. -/
def otherMax {X : Type*} (s : Fin 3 → X → ℝ) (i : Fin 3) (x : X) : ℝ :=
  ((Finset.univ.erase i).sup' (erase_nonempty i) (fun j => s j x))

/-- The margin of class `i`: score of `i` minus the maximum competing score. -/
def classMargin {X : Type*} (s : Fin 3 → X → ℝ) (i : Fin 3) (x : X) : ℝ :=
  s i x - otherMax s i x

/-- Selective classifier with abstention. Returns `some i` if class `i` has
    margin strictly above `τ`, and `none` (abstain) otherwise. -/
def abstainClassifier {X : Type*}
    (s : Fin 3 → X → ℝ) (τ : ℝ) (x : X) : Option (Fin 3) :=
  if h : ∃ i : Fin 3, τ < classMargin s i x then
    some (Classical.choose h)
  else
    none

/-- The top margin across all classes. -/
def topMargin {X : Type*} (s : Fin 3 → X → ℝ) (x : X) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => classMargin s i x)

/-- Pairwise score differences are `Kd`-Lipschitz. -/
def PairwiseDiffLipschitz {X : Type*} [PseudoMetricSpace X]
    (s : Fin 3 → X → ℝ) (Kd : ℝ) : Prop :=
  ∀ i j : Fin 3, ∀ x y : X,
    |(s i x - s j x) - (s i y - s j y)| ≤ Kd * dist x y

/-! ## Uniqueness of the winning class -/

/-
If two classes both have margin strictly above a nonneg threshold `τ`,
    they must be the same class. With `0 ≤ τ`, the margin condition forces
    `s i x` to be strictly larger than all other scores, giving uniqueness.
-/
lemma classMargin_gt_tau_unique
    {X : Type*}
    (s : Fin 3 → X → ℝ) {τ : ℝ} {x : X} {i j : Fin 3}
    (hτ : 0 ≤ τ)
    (hi : τ < classMargin s i x) (hj : τ < classMargin s j x) :
    i = j := by
  unfold classMargin at hi hj;
  exact Classical.not_not.1 fun h => by linarith [ show otherMax s i x ≥ s j x from Finset.le_sup' ( fun k ↦ s k x ) ( by aesop ), show otherMax s j x ≥ s i x from Finset.le_sup' ( fun k ↦ s k x ) ( by aesop ) ] ;

/-! ## Characterization lemmas -/

/-
`classMargin` equals the infimum of pairwise differences over competitors.
-/
lemma classMargin_eq_inf_pairwise
    {X : Type*}
    (s : Fin 3 → X → ℝ) (i : Fin 3) (x : X) :
    classMargin s i x =
      ((Finset.univ.erase i).inf' (erase_nonempty i)
        (fun j => s i x - s j x)) := by
  fin_cases i <;> simp +decide [ Fin.univ_succ ] at *;
  · unfold classMargin otherMax; simp +decide [ Fin.univ_succ ] ;
    rw [ max_def, min_def ] ; split_ifs <;> linarith;
  · unfold classMargin otherMax;
    simp +decide [ Finset.inf'_eq_csInf_image, Finset.sup'_eq_csSup_image ];
    rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
    · simp +decide [ Set.Nonempty ];
    · simp +decide [ Set.diff_eq ];
      exact fun a => ⟨ fun h => by linarith [ show s 0 x ≤ sSup ( ( fun j => s j x ) '' { 1 } ᶜ ) from le_csSup ⟨ Max.max ( s 0 x ) ( s 2 x ), Set.forall_mem_image.2 fun j hj => by fin_cases j <;> aesop ⟩ ⟨ 0, by simp +decide, rfl ⟩ ], fun h => by linarith [ show s 2 x ≤ sSup ( ( fun j => s j x ) '' { 1 } ᶜ ) from le_csSup ⟨ Max.max ( s 0 x ) ( s 2 x ), Set.forall_mem_image.2 fun j hj => by fin_cases j <;> aesop ⟩ ⟨ 2, by simp +decide, rfl ⟩ ] ⟩;
    · intro w hw;
      contrapose! hw;
      refine' le_sub_comm.mp ( csSup_le _ _ );
      · exact ⟨ _, ⟨ 0, by simp +decide, rfl ⟩ ⟩;
      · simp +zetaDelta at *;
        exact fun a ha => by fin_cases a <;> simp +decide at ha ⊢ <;> linarith! [ hw _ |>.1 rfl, hw _ |>.2 rfl ] ;
  · simp +decide [ Finset.inf'_eq_csInf_image, Finset.sup'_eq_csSup_image, classMargin, otherMax ];
    simp +decide [ Set.image, Set.diff_eq ];
    rw [ show { x_1 : ℝ | ∃ a : Fin 3, ¬a = 2 ∧ s a x = x_1 } = { s 0 x, s 1 x } by ext; simp +decide [ Fin.exists_fin_succ ] ; tauto ] ; rw [ show { x_1 : ℝ | ∃ a : Fin 3, ( ( a = 0 ∨ a = 1 ∨ a = 2 ) ∧ ¬a = 2 ) ∧ s 2 x - s a x = x_1 } = { s 2 x - s 0 x, s 2 x - s 1 x } by ext; simp +decide [ Fin.exists_fin_succ ] ; tauto ] ; simp +decide [ Finset.sup'_eq_csSup_image ] ;
    rw [ max_def, min_def ] ; split_ifs <;> linarith

/-
Threshold is below class margin iff it is below all pairwise differences
    with competitors.
-/
lemma lt_classMargin_iff
    {X : Type*}
    (s : Fin 3 → X → ℝ) (i : Fin 3) (x : X) (τ : ℝ) :
    τ < classMargin s i x ↔
      ∀ j ∈ Finset.univ.erase i, τ < s i x - s j x := by
  rw [ classMargin_eq_inf_pairwise ];
  aesop

/-
The abstain classifier returns `some i` iff class `i` has margin above `τ`.
    Requires `0 ≤ τ` for uniqueness of the winning class.
-/
lemma abstainClassifier_some_iff
    {X : Type*}
    (s : Fin 3 → X → ℝ) {τ : ℝ} (hτ : 0 ≤ τ) (x : X) (i : Fin 3) :
    abstainClassifier s τ x = some i ↔ τ < classMargin s i x := by
  constructor <;> intro h;
  · unfold abstainClassifier at h;
    split_ifs at h ; have := Classical.choose_spec ( by aesop : ∃ i, τ < classMargin s i x ) ; aesop;
  · -- Applying the definition of `abstainClassifier` from the hypothesis `h`.
    unfold abstainClassifier;
    split_ifs with h';
    · exact congr_arg _ ( classMargin_gt_tau_unique s hτ ( Classical.choose_spec h' ) h );
    · exact h' ⟨ i, h ⟩

/-
The abstain classifier returns `none` iff all class margins are at most `τ`.
-/
lemma abstainClassifier_none_iff
    {X : Type*}
    (s : Fin 3 → X → ℝ) (τ : ℝ) (x : X) :
    abstainClassifier s τ x = none ↔ ∀ i, classMargin s i x ≤ τ := by
  unfold abstainClassifier;
  split_ifs <;> simp_all +decide [ Classical.not_not ]

/-! ## Lipschitz bounds -/

/-
Class margin is `Kd`-Lipschitz under pairwise-difference Lipschitz scores.
-/
lemma classMargin_lipschitz
    {X : Type*} [PseudoMetricSpace X]
    {s : Fin 3 → X → ℝ} {Kd : ℝ}
    (hLip : PairwiseDiffLipschitz s Kd) :
    ∀ i : Fin 3, ∀ x y : X,
      |classMargin s i x - classMargin s i y| ≤ Kd * dist x y := by
  intro i x y;
  -- By definition of classMargin, we have that classMargin s i x is the infimum of s i x - s j x over all j ≠ i.
  have h_inf : ∀ x, classMargin s i x = s i x - (Finset.univ.erase i).sup' (erase_nonempty i) (fun j => s j x) := by
    intro; rfl;
  -- By definition of classMargin, we have that classMargin s i x is the infimum of s i x - s j x over all j ≠ i. Therefore, we can write:
  have h_inf_le : ∀ x y, classMargin s i x - classMargin s i y ≤ Kd * dist x y := by
    intro x y
    obtain ⟨j, hj⟩ : ∃ j ∈ Finset.univ.erase i, s j y = (Finset.univ.erase i).sup' (erase_nonempty i) (fun j => s j y) := by
      have := Finset.exists_max_image ( Finset.univ.erase i ) ( fun j => s j y ) ( erase_nonempty i );
      exact ⟨ this.choose, this.choose_spec.1, le_antisymm ( Finset.le_sup' ( fun j => s j y ) this.choose_spec.1 ) ( Finset.sup'_le _ _ fun j hj => this.choose_spec.2 j hj ) ⟩;
    have := hLip i j x y;
    linarith [ abs_le.mp this, h_inf x, h_inf y, show s j x ≤ ( Finset.univ.erase i ).sup' ( erase_nonempty i ) ( fun j => s j x ) from Finset.le_sup' ( fun j => s j x ) hj.1 ];
  exact abs_sub_le_iff.mpr ⟨ h_inf_le x y, by simpa [ dist_comm ] using h_inf_le y x ⟩

/-
Top margin is `Kd`-Lipschitz under pairwise-difference Lipschitz scores.
-/
lemma topMargin_lipschitz
    {X : Type*} [PseudoMetricSpace X]
    {s : Fin 3 → X → ℝ} {Kd : ℝ}
    (hLip : PairwiseDiffLipschitz s Kd) :
    ∀ x y : X, |topMargin s x - topMargin s y| ≤ Kd * dist x y := by
  intro x y; rw [ topMargin, topMargin ] ; simp +decide [ *, Fin.univ_succ ] ;
  -- Apply the Lipschitz property to each term in the maximum.
  have h_max_lip : ∀ i : Fin 3, |classMargin s i x - classMargin s i y| ≤ Kd * dist x y := by
    exact fun i => classMargin_lipschitz hLip i x y;
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩ <;> cases max_cases ( classMargin s 0 x ) ( max ( classMargin s 1 x ) ( classMargin s 2 x ) ) <;> cases max_cases ( classMargin s 0 y ) ( max ( classMargin s 1 y ) ( classMargin s 2 y ) ) <;> cases max_cases ( classMargin s 1 x ) ( classMargin s 2 x ) <;> cases max_cases ( classMargin s 1 y ) ( classMargin s 2 y ) <;> linarith [ abs_le.mp ( h_max_lip 0 ), abs_le.mp ( h_max_lip 1 ), abs_le.mp ( h_max_lip 2 ) ]

/-! ## Core scalar threshold robustness -/

/-- A Lipschitz function that is above a threshold at `x` stays above at `y`
    if `y` is close enough. -/
lemma scalar_threshold_above
    {X : Type*} [PseudoMetricSpace X]
    {f : X → ℝ} {K τ : ℝ} {x y : X}
    (hLip : ∀ x y : X, |f x - f y| ≤ K * dist x y)
    (hK : 0 ≤ K)
    (_ : τ < f x)
    (hradius : dist x y < (f x - τ) / K) :
    τ < f y := by
  contrapose! hradius
  exact div_le_of_le_mul₀ (by positivity) (by positivity)
    (by linarith [abs_le.mp (hLip x y)])

/-- A Lipschitz function that is below a threshold at `x` stays below at `y`
    if `y` is close enough. -/
lemma scalar_threshold_below
    {X : Type*} [PseudoMetricSpace X]
    {f : X → ℝ} {K τ : ℝ} {x y : X}
    (hLip : ∀ x y : X, |f x - f y| ≤ K * dist x y)
    (hK : 0 ≤ K)
    (_ : f x < τ)
    (hradius : dist x y < (τ - f x) / K) :
    f y < τ := by
  contrapose! hradius
  exact div_le_of_le_mul₀ (by positivity) (by positivity)
    (by linarith [abs_le.mp (hLip x y)])

/-! ## Main robustness theorems -/

/-- **Sharp non-abstention robustness**: if class `i` has margin above `τ` at `x`,
    then it has margin above `τ` at any `y` within the certified radius. -/
theorem abstain_classifier_some_of_margin_ball
    {X : Type*} [PseudoMetricSpace X]
    {s : Fin 3 → X → ℝ} {Kd τ : ℝ} {x y : X} {i : Fin 3}
    (hLip : PairwiseDiffLipschitz s Kd)
    (hKd : 0 ≤ Kd)
    (hmargin : τ < classMargin s i x)
    (hradius : dist x y < (classMargin s i x - τ) / Kd) :
    τ < classMargin s i y :=
  scalar_threshold_above (classMargin_lipschitz hLip i) hKd hmargin hradius

/-- **Classifier-level preservation of `some i`**: the abstain classifier returns the
    same class at a nearby point. Requires `0 ≤ τ` for uniqueness. -/
theorem abstain_classifier_eq_some_preserved
    {X : Type*} [PseudoMetricSpace X]
    {s : Fin 3 → X → ℝ} {Kd τ : ℝ} {x y : X} {i : Fin 3}
    (hLip : PairwiseDiffLipschitz s Kd)
    (hKd : 0 < Kd)
    (hτ : 0 ≤ τ)
    (hx : abstainClassifier s τ x = some i)
    (hradius : dist x y < (classMargin s i x - τ) / Kd) :
    abstainClassifier s τ y = some i := by
  rw [abstainClassifier_some_iff _ hτ] at hx ⊢
  exact abstain_classifier_some_of_margin_ball hLip (le_of_lt hKd) hx hradius

/-
**Half-radius corollary for non-abstention preservation**.
-/
theorem abstain_classifier_eq_some_preserved_half_radius
    {X : Type*} [PseudoMetricSpace X]
    {s : Fin 3 → X → ℝ} {Kd τ : ℝ} {x y : X} {i : Fin 3}
    (hLip : PairwiseDiffLipschitz s Kd)
    (hKd : 0 < Kd)
    (hτ : 0 ≤ τ)
    (hmargin : τ < classMargin s i x)
    (hradius : dist x y < (classMargin s i x - τ) / (2 * Kd)) :
    abstainClassifier s τ y = some i := by
  exact abstain_classifier_eq_some_preserved hLip hKd hτ ( by simpa using abstainClassifier_some_iff s hτ x i |>.2 hmargin ) ( by rw [ lt_div_iff₀ ( by positivity ) ] at *; linarith )

/-
**Sharp abstention robustness**: if top margin is below `τ` at `x`,
    then the classifier abstains at any `y` within the certified radius.
-/
theorem abstain_classifier_none_of_topMargin_ball
    {X : Type*} [PseudoMetricSpace X]
    {s : Fin 3 → X → ℝ} {Kd τ : ℝ} {x y : X}
    (hLip : PairwiseDiffLipschitz s Kd)
    (hKd : 0 ≤ Kd)
    (hmargin : topMargin s x < τ)
    (hradius : dist x y < (τ - topMargin s x) / Kd) :
    abstainClassifier s τ y = none := by
  -- By the scalar_threshold_below lemma, since topMargin s x < τ and dist x y < (τ - topMargin s x) / Kd, we have topMargin s y < τ.
  have h_topMargin_y : topMargin s y < τ := by
    have := topMargin_lipschitz hLip x y;
    cases eq_or_lt_of_le hKd <;> simp_all +decide [ lt_div_iff₀ ];
    · subst_vars; linarith [ abs_le.mp this ] ;
    · linarith [ abs_le.mp this ];
  exact abstainClassifier_none_iff s τ y |>.2 fun i => le_trans ( Finset.le_sup' ( fun i => classMargin s i y ) ( Finset.mem_univ i ) ) h_topMargin_y.le

/-
**Half-radius corollary for abstention preservation**.
-/
theorem abstain_classifier_none_preserved_half_radius
    {X : Type*} [PseudoMetricSpace X]
    {s : Fin 3 → X → ℝ} {Kd τ : ℝ} {x y : X}
    (hLip : PairwiseDiffLipschitz s Kd)
    (hKd : 0 < Kd)
    (hmargin : topMargin s x < τ)
    (hradius : dist x y < (τ - topMargin s x) / (2 * Kd)) :
    abstainClassifier s τ y = none := by
  apply abstain_classifier_none_of_topMargin_ball;
  exact hLip;
  exact le_of_lt hKd;
  exacts [ hmargin, hradius.trans_le ( by rw [ div_le_div_iff₀ ] <;> nlinarith ) ]

end