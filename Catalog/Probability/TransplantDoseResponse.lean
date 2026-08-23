import Probability.TailTransplantGeometry

/-!
# Dose–response: how fast can the transplant statistics move?

The follow-up experiment proposed by NET-54 is a *dose–response* curve: one-layer,
two-layer, three-layer swaps.  Before running it, one wants to know which shapes of
curve are geometrically possible.  This file supplies the answer: every statistic used
in the NET-54 analysis is `1`-Lipschitz with respect to the Hamming distance between
hybrids, so the dose–response curve of agreements and of novelty can only move as fast
as the hybrids themselves move.

* `disFrac` — normalised Hamming distance between two prediction functions.
* `agreeFrac_lipschitz`, `novelFrac_lipschitz` — agreement with a fixed parent, and
  novelty against a fixed parent pair, are `1`-Lipschitz in the hybrid.
* `net54_bulk_and_tail_hybrids_far_apart` — run backwards on the measured data, this
  is a *causal separation* of the two swap sites: the bulk hybrid and the tail hybrid,
  built from the same host and the same donor, must differ on at least `37.90 %` of
  the held-out positions.  Two transplants of the same pair of models are further
  apart from each other than the two parents are (`0.3790 > 1 - 0.8327 = 0.1673`,
  `net54_hybrids_further_than_parents`).
-/

namespace Catalog.Probability.TransplantDoseResponse

open Finset
open Catalog.Probability.TailTransplantGeometry

variable {Ω Y : Type*} [Fintype Ω] [DecidableEq Ω] [DecidableEq Y]

/-- Normalised Hamming distance between two prediction functions. -/
noncomputable def disFrac (f g : Ω → Y) : ℝ :=
  ((disagreeSet f g).card : ℝ) / (Fintype.card Ω : ℝ)

omit [DecidableEq Ω] in
lemma disFrac_eq_one_sub_agreeFrac [Nonempty Ω] (f g : Ω → Y) :
    disFrac f g = 1 - agreeFrac f g := by
  have hN : 0 < Fintype.card Ω := Fintype.card_pos
  have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  have hpart := card_agree_add_card_disagree f g
  have hR : ((agreeSet f g).card : ℝ) + ((disagreeSet f g).card : ℝ)
      = (Fintype.card Ω : ℝ) := by exact_mod_cast hpart
  have hsum : ((disagreeSet f g).card : ℝ) + ((agreeSet f g).card : ℝ)
      = (Fintype.card Ω : ℝ) := by linarith
  rw [disFrac, agreeFrac, eq_sub_iff_add_eq, ← add_div, hsum, div_self hNR.ne']

omit [DecidableEq Ω] in
lemma disFrac_comm (f g : Ω → Y) : disFrac f g = disFrac g f := by
  have hset : disagreeSet f g = disagreeSet g f := by
    ext x; simp [mem_disagreeSet, ne_comm]
  rw [disFrac, disFrac, hset]

/-! ### Agreement moves no faster than the hybrid -/

lemma agreeSet_subset_union_disagree (h₁ h₂ a : Ω → Y) :
    agreeSet h₂ a ⊆ agreeSet h₁ a ∪ disagreeSet h₁ h₂ := by
  intro x hx
  rw [mem_agreeSet] at hx
  by_cases hEq : h₁ x = h₂ x
  · exact Finset.mem_union_left _ (mem_agreeSet.2 (by rw [hEq]; exact hx))
  · exact Finset.mem_union_right _ (mem_disagreeSet.2 hEq)

/-- Auxiliary one-sided bound behind the Lipschitz statements. -/
lemma frac_le_of_subset_union {s t u : Finset Ω}
    (hsub : s ⊆ t ∪ u) :
    ((s.card : ℝ)) / (Fintype.card Ω : ℝ)
      ≤ ((t.card : ℝ)) / (Fintype.card Ω : ℝ)
        + ((u.card : ℝ)) / (Fintype.card Ω : ℝ) := by
  have hcard : s.card ≤ t.card + u.card :=
    le_trans (Finset.card_le_card hsub) (Finset.card_union_le _ _)
  have hR : (s.card : ℝ) ≤ (t.card : ℝ) + (u.card : ℝ) := by exact_mod_cast hcard
  rw [← add_div]
  gcongr

/-- **Agreement is `1`-Lipschitz in the hybrid.**  Two hybrids that differ on a
fraction `δ` of positions cannot differ by more than `δ` in their agreement with any
fixed parent. -/
theorem agreeFrac_lipschitz (h₁ h₂ a : Ω → Y) :
    |agreeFrac h₁ a - agreeFrac h₂ a| ≤ disFrac h₁ h₂ := by
  have h12 : agreeFrac h₂ a ≤ agreeFrac h₁ a + disFrac h₁ h₂ := by
    have := frac_le_of_subset_union (agreeSet_subset_union_disagree h₁ h₂ a)
    rw [agreeFrac, agreeFrac, disFrac]
    exact this
  have h21 : agreeFrac h₁ a ≤ agreeFrac h₂ a + disFrac h₁ h₂ := by
    have hsub := agreeSet_subset_union_disagree h₂ h₁ a
    have := frac_le_of_subset_union hsub
    rw [agreeFrac, agreeFrac, disFrac_comm h₁ h₂, disFrac]
    exact this
  rw [abs_le]
  constructor <;> linarith

lemma novelSet_subset_union_disagree (h₁ h₂ a b : Ω → Y) :
    novelSet h₂ a b ⊆ novelSet h₁ a b ∪ disagreeSet h₁ h₂ := by
  intro x hx
  rcases mem_novelSet.1 hx with ⟨hxa, hxb⟩
  by_cases hEq : h₁ x = h₂ x
  · refine Finset.mem_union_left _ (mem_novelSet.2 ⟨?_, ?_⟩)
    · rw [hEq]; exact hxa
    · rw [hEq]; exact hxb
  · exact Finset.mem_union_right _ (mem_disagreeSet.2 hEq)

/-- **Novelty is `1`-Lipschitz in the hybrid.**  A dose–response curve of novelty can
only jump as fast as the hybrids themselves separate. -/
theorem novelFrac_lipschitz (h₁ h₂ a b : Ω → Y) :
    |novelFrac h₁ a b - novelFrac h₂ a b| ≤ disFrac h₁ h₂ := by
  have h12 : novelFrac h₂ a b ≤ novelFrac h₁ a b + disFrac h₁ h₂ := by
    have := frac_le_of_subset_union (novelSet_subset_union_disagree h₁ h₂ a b)
    rw [novelFrac, novelFrac, disFrac]
    exact this
  have h21 : novelFrac h₁ a b ≤ novelFrac h₂ a b + disFrac h₁ h₂ := by
    have := frac_le_of_subset_union (novelSet_subset_union_disagree h₂ h₁ a b)
    rw [novelFrac, novelFrac, disFrac_comm h₁ h₂, disFrac]
    exact this
  rw [abs_le]
  constructor <;> linarith

/-! ### The measured separation of the two swap sites -/

section NET54

variable (A : Ω → Y)

/-- **The two swap sites produce genuinely different models.**  Read backwards, the
Lipschitz bound converts the measured host-side agreements of the bulk arm (`0.9635`)
and the tail arm (`0.5845`) into a causal separation: the two hybrids, built from the
same host and the same donor, differ on at least `37.90 %` of the held-out positions.
No appeal to weights is needed — only the two agreement numbers. -/
theorem net54_bulk_and_tail_hybrids_far_apart (Hbulk Htail : Ω → Y)
    (hbulk : (0.9635 : ℝ) ≤ agreeFrac Hbulk A) (htail : agreeFrac Htail A ≤ 0.5845) :
    (0.3790 : ℝ) ≤ disFrac Hbulk Htail := by
  have h := agreeFrac_lipschitz Hbulk Htail A
  have hle : agreeFrac Hbulk A - agreeFrac Htail A ≤ |agreeFrac Hbulk A - agreeFrac Htail A| :=
    le_abs_self _
  linarith

/-- The separation exceeds the distance between the two parents themselves
(`1 - 0.8327 = 0.1673`): transplantation moves a model further than fine-tuning did. -/
theorem net54_hybrids_further_than_parents [Nonempty Ω] (B Hbulk Htail : Ω → Y)
    (hbase : (0.8327 : ℝ) ≤ agreeFrac A B)
    (hbulk : (0.9635 : ℝ) ≤ agreeFrac Hbulk A) (htail : agreeFrac Htail A ≤ 0.5845) :
    disFrac A B < disFrac Hbulk Htail := by
  have h1 := net54_bulk_and_tail_hybrids_far_apart A Hbulk Htail hbulk htail
  have h2 : disFrac A B = 1 - agreeFrac A B := disFrac_eq_one_sub_agreeFrac A B
  linarith

end NET54

end Catalog.Probability.TransplantDoseResponse