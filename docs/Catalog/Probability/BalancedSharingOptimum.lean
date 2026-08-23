import Probability.SharedTailServingCeiling

/-!
# The sharing ceiling is attained, and attained in a balanced way

`Probability.SharedTailServingCeiling` proved a ceiling: a single served model can
accumulate at most `1 + β` total agreement with two fine-tunes that agree with each
other only on a fraction `β` of positions, i.e. mean agreement at most `(1+β)/2`.

A ceiling is only interesting if it is attained, and attained by something one would
actually want to serve.  Serving the host itself attains it trivially and uselessly
(mean agreement `(1+β)/2` but the donor is abandoned).  This file proves the useful
version: **the ceiling is attained by an explicitly balanced compromise model**, which
splits the parents' disagreement set in half and is therefore equidistant from the two
fine-tunes up to a single position.

* `balanced_sharing_attained` — there is a shared model `H` with
  `agr H A + agr H B = 1 + agr A B` (the ceiling, exactly) and
  `|agr H A − agr H B| ≤ 1/N`.
* `balanced_sharing_min_optimal` — consequently the best achievable *worst-case*
  agreement over the two parents is `(1 + β)/2` up to `1/(2N)`, and this is optimal
  by the ceiling.  Perfect sharing of a fine-tune pair is possible only to the extent
  that the pair itself agrees.
* `net54_balanced_serving_value` — at the measured baseline `β = 0.8327`, a balanced
  shared model can hold `0.9163` agreement with *both* fine-tunes simultaneously
  (up to `1/(2N)`); the measured tail-swap hybrid holds only `0.5443` with its donor,
  i.e. it forfeits more than `0.37` of what balanced sharing would have given.
-/

namespace Catalog.Probability.BalancedSharingOptimum

open Finset
open Catalog.Probability.TailTransplantGeometry
open Catalog.Probability.SharedTailServingCeiling

variable {Ω Y : Type*} [Fintype Ω] [DecidableEq Ω] [DecidableEq Y]

/-- **The ceiling is attained by a balanced compromise.**  Split the positions where
the two fine-tunes disagree into two halves; follow the donor on one half and the host
on the other.  The resulting shared model saturates the sharing budget exactly and is
equidistant from the two parents up to one position. -/
theorem balanced_sharing_attained [Nonempty Ω] (A B : Ω → Y) :
    ∃ H : Ω → Y, agreeFrac H A + agreeFrac H B = 1 + agreeFrac A B ∧
      |agreeFrac H A - agreeFrac H B| ≤ 1 / (Fintype.card Ω : ℝ) := by
  classical
  have hN : 0 < Fintype.card Ω := Fintype.card_pos
  have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  set D := disagreeSet A B with hD
  obtain ⟨S, hSsub, hScard⟩ := Finset.exists_subset_card_eq (s := D) (n := D.card / 2)
    (Nat.div_le_self _ _)
  set H : Ω → Y := fun x => if x ∈ S then B x else A x with hH
  have hdisA : disagreeSet H A = S := by
    ext x
    rw [mem_disagreeSet]
    by_cases hx : x ∈ S
    · have hxD : x ∈ D := hSsub hx
      rw [hD, mem_disagreeSet] at hxD
      simp [hH, hx, Ne.symm hxD]
    · simp [hH, hx]
  have hdisB : disagreeSet H B = D \ S := by
    ext x
    rw [mem_disagreeSet, Finset.mem_sdiff]
    by_cases hx : x ∈ S
    · simp [hH, hx]
    · by_cases hxD : x ∈ D
      · have hxD' : A x ≠ B x := by rw [hD, mem_disagreeSet] at hxD; exact hxD
        simp [hH, hx, hxD, hxD']
      · have hxD' : A x = B x := by
          rw [hD, mem_disagreeSet, not_not] at hxD; exact hxD
        simp [hH, hx, hxD, hxD']
  have hpA := card_agree_add_card_disagree H A
  have hpB := card_agree_add_card_disagree H B
  have hpAB := card_agree_add_card_disagree A B
  rw [hdisA] at hpA
  rw [hdisB, Finset.card_sdiff_of_subset hSsub] at hpB
  rw [← hD] at hpAB
  have hSle : S.card ≤ D.card := Finset.card_le_card hSsub
  have hkey : (agreeSet H A).card + (agreeSet H B).card
      = Fintype.card Ω + (agreeSet A B).card := by omega
  have hdiff : (agreeSet H A).card = (agreeSet H B).card
      ∨ (agreeSet H A).card = (agreeSet H B).card + 1 := by omega
  refine ⟨H, ?_, ?_⟩
  · have hR : ((agreeSet H A).card : ℝ) + ((agreeSet H B).card : ℝ)
        = (Fintype.card Ω : ℝ) + ((agreeSet A B).card : ℝ) := by exact_mod_cast hkey
    rw [agreeFrac, agreeFrac, agreeFrac, ← add_div]
    rw [hR, add_div, div_self hNR.ne']
  · rcases hdiff with h | h
    · rw [agreeFrac, agreeFrac, h, sub_self, abs_zero]
      positivity
    · rw [agreeFrac, agreeFrac, h]
      push_cast
      rw [show (((agreeSet H B).card : ℝ) + 1) / (Fintype.card Ω : ℝ)
            - ((agreeSet H B).card : ℝ) / (Fintype.card Ω : ℝ)
          = 1 / (Fintype.card Ω : ℝ) by ring]
      rw [abs_of_nonneg (by positivity)]

/-- **Optimal balanced sharing.**  A single shared model can hold, with *both*
fine-tunes at once, an agreement of at least `(1 + β)/2 − 1/(2N)`; and by the ceiling
it can never hold more than `(1 + β)/2`.  So the worst-case sharing value of a
fine-tune pair is `(1 + β)/2`, to within one position. -/
theorem balanced_sharing_min_optimal [Nonempty Ω] (A B : Ω → Y) :
    ∃ H : Ω → Y,
      (1 + agreeFrac A B) / 2 - 1 / (2 * (Fintype.card Ω : ℝ))
        ≤ min (agreeFrac H A) (agreeFrac H B) ∧
      ∀ K : Ω → Y, min (agreeFrac K A) (agreeFrac K B) ≤ (1 + agreeFrac A B) / 2 := by
  obtain ⟨H, hsum, hbal⟩ := balanced_sharing_attained A B
  refine ⟨H, ?_, ?_⟩
  · have habs := abs_le.1 hbal
    rcases le_total (agreeFrac H A) (agreeFrac H B) with hle | hle
    · rw [min_eq_left hle]
      have h1 : agreeFrac H B - agreeFrac H A ≤ 1 / (Fintype.card Ω : ℝ) := by linarith [habs.2]
      have hrw : 1 / (2 * (Fintype.card Ω : ℝ)) = (1 / (Fintype.card Ω : ℝ)) / 2 := by
        ring
      rw [hrw]
      linarith
    · rw [min_eq_right hle]
      have h1 : agreeFrac H A - agreeFrac H B ≤ 1 / (Fintype.card Ω : ℝ) := by linarith [habs.1]
      have hrw : 1 / (2 * (Fintype.card Ω : ℝ)) = (1 / (Fintype.card Ω : ℝ)) / 2 := by
        ring
      rw [hrw]
      linarith
  · intro K
    have h := pair_agreement_le K A B (agreeFrac A B) le_rfl
    rcases le_total (agreeFrac K A) (agreeFrac K B) with hle | hle
    · rw [min_eq_left hle]; linarith
    · rw [min_eq_right hle]; linarith

/-- **What the tail swap forfeits.**  At the measured cross-parent baseline, balanced
sharing would have held `0.9163` with both fine-tunes at once (up to `1/(2N)`),
whereas the measured tail hybrid holds at most `0.5443` with its donor: the transplant
gives up more than `0.37` of achievable simultaneous agreement.  The bulk transplant,
by contrast, is within `0.0154` of the same optimum. -/
theorem net54_balanced_serving_value [Nonempty Ω] (A B Htail : Ω → Y)
    (hbase : (0.8327 : ℝ) ≤ agreeFrac A B)
    (htailB : agreeFrac Htail B ≤ 0.5443) :
    ∃ H : Ω → Y,
      min (agreeFrac H A) (agreeFrac H B) - min (agreeFrac Htail A) (agreeFrac Htail B)
        ≥ 0.372 - 1 / (2 * (Fintype.card Ω : ℝ)) := by
  obtain ⟨H, hbal, -⟩ := balanced_sharing_min_optimal A B
  refine ⟨H, ?_⟩
  have hmin : min (agreeFrac Htail A) (agreeFrac Htail B) ≤ 0.5443 :=
    le_trans (min_le_right _ _) htailB
  have hlow : (0.91635 : ℝ) - 1 / (2 * (Fintype.card Ω : ℝ))
      ≤ min (agreeFrac H A) (agreeFrac H B) := by
    have : (0.91635 : ℝ) ≤ (1 + agreeFrac A B) / 2 := by linarith
    linarith
  linarith

end Catalog.Probability.BalancedSharingOptimum