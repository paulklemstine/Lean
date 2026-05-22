/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL3 Kemeny–Young Certified Robustness

This file formalizes certified robustness for a 3-class decision rule obtained via
Kemeny–Young aggregation. For 3 candidates, the Kemeny score of each of the 6 possible
rankings is an explicit affine-linear form in three pairwise margins. This allows us to
transfer Lipschitz control on individual class scores to a certified robustness radius for
the Kemeny winner.

## Main results

* `margin_perturbation_bound` — pairwise margins perturb by at most `2 * Kd * ε`
* `kemenyScore_perturbation_bound` — each Kemeny score perturbs by at most `6 * Kd * ε`
* `unique_kemeny_winner_stable` — if the gap exceeds `12 * Kd * ε`, the winner is preserved
* `kemeny_winner_certified_radius` — certified radius `Δ / (12 * Kd)` for winner preservation
* `kemeny_winner_label_stable` — the top-class label is preserved within the certified radius
-/

import Mathlib

open scoped BigOperators

namespace GL3Kemeny

/-! ## Margins -/

/-- Pairwise margin: difference between score of class `i` and class `j`. -/
def margin (h : α → Fin 3 → ℝ) (x : α) (i j : Fin 3) : ℝ := h x i - h x j

@[simp] lemma margin_self (h : α → Fin 3 → ℝ) (x : α) (i : Fin 3) :
    margin h x i i = 0 := by unfold margin; ring

@[simp] lemma margin_antisymm (h : α → Fin 3 → ℝ) (x : α) (i j : Fin 3) :
    margin h x i j = -margin h x j i := by unfold margin; ring

/-! ## The six rankings of Fin 3 -/

/-- The six possible rankings (permutations) of three candidates. Named by the order
    of preference: `r012` means `0 ≻ 1 ≻ 2`. -/
inductive KemenyRanking : Type
  | r012 | r021 | r102 | r120 | r201 | r210
  deriving DecidableEq, Fintype, Repr

namespace KemenyRanking

instance : Inhabited KemenyRanking := ⟨r012⟩

/-- The top-ranked class of a ranking. -/
def topClass : KemenyRanking → Fin 3
  | r012 => 0
  | r021 => 0
  | r102 => 1
  | r120 => 1
  | r201 => 2
  | r210 => 2

end KemenyRanking

/-! ## Kemeny scores

The Kemeny score of a ranking `σ` is the sum of `margin h x (σ i) (σ j)` over pairs `i < j`
in the ranking order. For three candidates this is a sum of three signed margins. -/

/-- The Kemeny score of a ranking at point `x` under score map `h`.
    Each score is expressed as a sum of three signed margins. -/
def kemenyScore (h : α → Fin 3 → ℝ) (x : α) : KemenyRanking → ℝ
  | .r012 =>  (margin h x 0 1) + (margin h x 0 2) + (margin h x 1 2)
  | .r021 =>  (margin h x 0 1) + (margin h x 0 2) - (margin h x 1 2)
  | .r102 => -(margin h x 0 1) + (margin h x 0 2) + (margin h x 1 2)
  | .r120 => -(margin h x 0 1) - (margin h x 0 2) + (margin h x 1 2)
  | .r201 =>  (margin h x 0 1) - (margin h x 0 2) - (margin h x 1 2)
  | .r210 => -(margin h x 0 1) - (margin h x 0 2) - (margin h x 1 2)

/-! ## Perturbation bounds -/

/-
The pairwise margin perturbs by at most `2 * Kd * ε` when each score perturbs by `Kd * ε`.
-/
theorem margin_perturbation_bound
    (h : α → Fin 3 → ℝ) (x y : α) (Kd ε : ℝ)
    (hLip : ∀ i : Fin 3, |h y i - h x i| ≤ Kd * ε)
    (i j : Fin 3) :
    |margin h y i j - margin h x i j| ≤ 2 * Kd * ε := by
  exact abs_le.mpr ⟨ by unfold margin; linarith [ abs_le.mp ( hLip i ), abs_le.mp ( hLip j ) ], by unfold margin; linarith [ abs_le.mp ( hLip i ), abs_le.mp ( hLip j ) ] ⟩

/-
Each Kemeny score perturbs by at most `6 * Kd * ε`, since each score is a sum of three
    signed margins, each perturbing by at most `2 * Kd * ε`.
-/
theorem kemenyScore_perturbation_bound
    (h : α → Fin 3 → ℝ) (x y : α) (Kd ε : ℝ)
    (_hKd : 0 ≤ Kd) (_hε : 0 ≤ ε)
    (hLip : ∀ i : Fin 3, |h y i - h x i| ≤ Kd * ε)
    (s : KemenyRanking) :
    |kemenyScore h y s - kemenyScore h x s| ≤ 6 * Kd * ε := by
  unfold kemenyScore;
  unfold margin;
  rcases s with ( _ | _ | _ | _ | _ | _ | s );
  all_goals rw [ abs_le ] ; constructor <;> linarith! [ abs_le.mp ( hLip 0 ), abs_le.mp ( hLip 1 ), abs_le.mp ( hLip 2 ) ] ;

/-! ## Unique winner and gap -/

/-- A ranking `s` is the unique Kemeny winner at `x` if it strictly dominates all others. -/
def isUniqueKemenyWinner (h : α → Fin 3 → ℝ) (x : α) (s : KemenyRanking) : Prop :=
  ∀ t, t ≠ s → kemenyScore h x t < kemenyScore h x s

/-! ## Score gap perturbation -/

/-
The gap between any two Kemeny scores perturbs by at most `12 * Kd * ε`.
-/
theorem kemenyScore_gap_perturbation
    (h : α → Fin 3 → ℝ) (x y : α) (Kd ε : ℝ)
    (hKd : 0 ≤ Kd) (hε : 0 ≤ ε)
    (hLip : ∀ i : Fin 3, |h y i - h x i| ≤ Kd * ε)
    (s t : KemenyRanking) :
    |(kemenyScore h y s - kemenyScore h y t) -
     (kemenyScore h x s - kemenyScore h x t)| ≤ 12 * Kd * ε := by
  exact abs_sub_le_iff.mpr ⟨ by linarith [ abs_le.mp ( kemenyScore_perturbation_bound h x y Kd ε hKd hε hLip s ), abs_le.mp ( kemenyScore_perturbation_bound h x y Kd ε hKd hε hLip t ) ], by linarith [ abs_le.mp ( kemenyScore_perturbation_bound h x y Kd ε hKd hε hLip s ), abs_le.mp ( kemenyScore_perturbation_bound h x y Kd ε hKd hε hLip t ) ] ⟩

/-! ## Main stability theorem -/

/-
**Kemeny winner stability**: If the unique Kemeny winner at `x` has a score gap `Δ` over
    all competitors, and each class score perturbs by at most `Kd * ε` with
    `12 * Kd * ε < Δ`, then the same ranking remains the unique winner at `y`.
-/
theorem unique_kemeny_winner_stable
    (h : α → Fin 3 → ℝ) (x y : α) (Kd ε Δ : ℝ)
    (hKd : 0 ≤ Kd) (hε : 0 ≤ ε)
    (hLip : ∀ i : Fin 3, |h y i - h x i| ≤ Kd * ε)
    (sStar : KemenyRanking)
    (hgap : ∀ t, t ≠ sStar → kemenyScore h x sStar - kemenyScore h x t ≥ Δ)
    (_hΔ : 0 < Δ)
    (hrad : 12 * Kd * ε < Δ) :
    isUniqueKemenyWinner h y sStar := by
  intro t ht; linarith [ hgap t ht, kemenyScore_gap_perturbation h x y Kd ε hKd hε hLip sStar t, abs_le.mp ( kemenyScore_gap_perturbation h x y Kd ε hKd hε hLip sStar t ) ] ;

/-! ## Certified radius corollary -/

/-
**Certified radius**: If `ε < Δ / (12 * Kd)`, the unique Kemeny winner is preserved.
-/
theorem kemeny_winner_certified_radius
    (h : α → Fin 3 → ℝ) (x y : α) (Kd Δ ε : ℝ)
    (hKd : 0 < Kd) (hΔ : 0 < Δ) (hε : 0 ≤ ε)
    (hLip : ∀ i : Fin 3, |h y i - h x i| ≤ Kd * ε)
    (sStar : KemenyRanking)
    (hgap : ∀ t, t ≠ sStar → kemenyScore h x sStar - kemenyScore h x t ≥ Δ)
    (hrad : ε < Δ / (12 * Kd)) :
    isUniqueKemenyWinner h y sStar := by
  convert unique_kemeny_winner_stable h x y Kd ε Δ hKd.le hε hLip sStar ( fun t ht => ?_ ) hΔ ?_ using 1;
  · exact hgap t ht;
  · rwa [ lt_div_iff₀' ( by positivity ) ] at hrad

/-! ## Winner label -/

/-- The Kemeny winner class: class `c` is the Kemeny winner if there exists a unique
    optimal ranking whose top element is `c`. -/
def kemenyWinner (h : α → Fin 3 → ℝ) (x : α) (c : Fin 3) : Prop :=
  ∃ s, KemenyRanking.topClass s = c ∧ isUniqueKemenyWinner h x s

/-
**Label stability**: Under the certified radius, the Kemeny winner label is preserved.
-/
theorem kemeny_winner_label_stable
    (h : α → Fin 3 → ℝ) (x y : α) (Kd Δ ε : ℝ) (c : Fin 3)
    (sStar : KemenyRanking)
    (htop : sStar.topClass = c)
    (hKd : 0 < Kd) (hΔ : 0 < Δ) (hε : 0 ≤ ε)
    (hLip : ∀ i : Fin 3, |h y i - h x i| ≤ Kd * ε)
    (hgap : ∀ t, t ≠ sStar → kemenyScore h x sStar - kemenyScore h x t ≥ Δ)
    (hrad : ε < Δ / (12 * Kd)) :
    kemenyWinner h y c := by
  exact ⟨ sStar, htop, kemeny_winner_certified_radius h x y Kd Δ ε hKd hΔ hε hLip sStar hgap hrad ⟩

/-! ## Winner region characterization

For each ranking, we can characterize when it has the highest Kemeny score
in terms of explicit linear inequalities on the margins. -/

/-
Ranking `0 ≻ 1 ≻ 2` is the unique Kemeny winner iff all three basic margins are positive.
-/
theorem r012_dominates_iff (h : α → Fin 3 → ℝ) (x : α) :
    isUniqueKemenyWinner h x .r012 ↔
      0 < margin h x 0 1 ∧ 0 < margin h x 0 2 ∧ 0 < margin h x 1 2 := by
  unfold isUniqueKemenyWinner;
  unfold kemenyScore margin;
  constructor <;> intro h;
  · refine' ⟨ _, _, _ ⟩ <;> linarith! [ h KemenyRanking.r021 ( by decide ), h KemenyRanking.r102 ( by decide ), h KemenyRanking.r120 ( by decide ), h KemenyRanking.r201 ( by decide ), h KemenyRanking.r210 ( by decide ) ];
  · intro t ht; rcases t with ( _ | _ | _ | _ | _ | _ | t ) <;> norm_num at * <;> linarith!;

end GL3Kemeny