import Probability.TailTransplantGeometry

/-!
# The sharing ceiling for multi-fine-tune serving

NET-54's practical claim is a *sharing boundary*: when several fine-tunes of one
base model are served from one set of weights on small VRAM, share everything
except the last two layers.  This file turns that claim into a theorem about how
much agreement any single shared model can possibly retain, and then measures
how close the two NET-54 arms come to that ceiling.

Setting.  `k ≥ 2` fine-tunes `A 0, …, A (k-1)` are given, pairwise agreeing on at
most a fraction `β` of the held-out positions (for the measured pair,
`β = 0.8327`).  A single served model `H` is asked to imitate all of them.

* `sharing_ceiling` — the total agreement of `H` with the family is at most
  `k (1 + β) / 2`; equivalently (`sharing_ceiling_mean`) the *mean* agreement of
  a single shared model with `k` distinct fine-tunes never exceeds `(1 + β)/2`,
  no matter how the sharing is done and no matter how large `k` is.  The bound
  comes from the Hamming triangle inequality applied to every pair, so it is a
  hard geometric obstruction, not a property of transformers.
* `net54_bulk_swap_near_sharing_ceiling` — the measured bulk (L10/11) arm sits
  within `0.0307` (summed over the two parents) of that ceiling: sharing the
  bulk is *almost optimal* sharing.
* `net54_tail_swap_far_from_ceiling` — the tail (L22/23) arm leaves at least
  `0.7039` of the budget unused.
* `net54_tail_at_least_22x_less_shareable` — combining the two: the tail arm
  wastes at least `22 ×` as much of the sharing budget as the bulk arm.  This is
  the quantitative form of "share everything except the last two layers".
-/

namespace Catalog.Probability.SharedTailServingCeiling

open Finset
open Catalog.Probability.TailTransplantGeometry

variable {Ω Y : Type*} [Fintype Ω] [DecidableEq Ω] [DecidableEq Y]

/-! ### 1. The ceiling -/

/-- Pairwise form of the ceiling: a shared model cannot agree strongly with two
fine-tunes that agree with each other only to `β`. -/
lemma pair_agreement_le (H A B : Ω → Y) (beta : ℝ) (hAB : agreeFrac A B ≤ beta) :
    agreeFrac H A + agreeFrac H B ≤ 1 + beta := by
  have h1 := agreeFrac_triangle A H B
  rw [agreeFrac_comm A H] at h1
  linarith

/-- **The sharing ceiling.**  For `k ≥ 2` fine-tunes that pairwise agree at most
`β` of the time, no single shared model can accumulate more than
`k (1 + β) / 2` total prediction agreement. -/
theorem sharing_ceiling {k : ℕ} (hk : 2 ≤ k) (H : Ω → Y) (A : Fin k → (Ω → Y))
    (beta : ℝ) (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta) :
    ∑ i, agreeFrac H (A i) ≤ (k : ℝ) * (1 + beta) / 2 := by
  classical
  set a : Fin k → ℝ := fun i => agreeFrac H (A i) with ha
  set S : ℝ := ∑ i, a i with hS
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) - 1 := by linarith
  have hcard : ∀ i : Fin k, ((Finset.univ.erase i).card : ℝ) = (k : ℝ) - 1 := by
    intro i
    have h1 : (Finset.univ.erase i).card = k - 1 := by
      rw [Finset.card_erase_of_mem (Finset.mem_univ i)]
      simp
    rw [h1]
    have h1k : 1 ≤ k := le_trans (by norm_num) hk
    push_cast [Nat.cast_sub h1k]
    ring
  have hinner : ∀ i : Fin k,
      ∑ j ∈ Finset.univ.erase i, (a i + a j) = ((k : ℝ) - 2) * a i + S := by
    intro i
    rw [Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul, hcard i,
      Finset.sum_erase_eq_sub (Finset.mem_univ i), ← hS]
    ring
  have hle : ∀ i : Fin k,
      ∑ j ∈ Finset.univ.erase i, (a i + a j)
        ≤ ∑ _j ∈ Finset.univ.erase i, (1 + beta) := by
    intro i
    refine Finset.sum_le_sum ?_
    intro j hj
    have hne : i ≠ j := fun h => (Finset.ne_of_mem_erase hj) h.symm
    exact pair_agreement_le H (A i) (A j) beta (hpair i j hne)
  have hsum : ∑ i : Fin k, (((k : ℝ) - 2) * a i + S)
      ≤ ∑ _i : Fin k, ((k : ℝ) - 1) * (1 + beta) := by
    refine Finset.sum_le_sum ?_
    intro i _
    have h1 := hle i
    rw [hinner i, Finset.sum_const, nsmul_eq_mul, hcard i] at h1
    exact h1
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, Finset.sum_const,
    nsmul_eq_mul, nsmul_eq_mul, Finset.card_univ, Fintype.card_fin, ← hS] at hsum
  have hfinal : 2 * ((k : ℝ) - 1) * S ≤ (k : ℝ) * (((k : ℝ) - 1) * (1 + beta)) := by
    nlinarith [hsum]
  have h2k : (0 : ℝ) < 2 * ((k : ℝ) - 1) := by linarith
  rw [le_div_iff₀ (by norm_num : (0:ℝ) < 2)]
  nlinarith [hfinal]

/-- Mean form: **a single shared model never exceeds mean agreement
`(1 + β)/2`** with a family of `k ≥ 2` pairwise-`β`-distinct fine-tunes. -/
theorem sharing_ceiling_mean {k : ℕ} (hk : 2 ≤ k) (H : Ω → Y) (A : Fin k → (Ω → Y))
    (beta : ℝ) (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta) :
    (∑ i, agreeFrac H (A i)) / (k : ℝ) ≤ (1 + beta) / 2 := by
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  have h := sharing_ceiling hk H A beta hpair
  rw [div_le_div_iff₀ hkpos (by norm_num : (0:ℝ) < 2)]
  nlinarith [h]

/-! ### 2. Where the two NET-54 arms sit relative to the ceiling -/

section NET54

variable (A B : Ω → Y)

/-- The unused part of the sharing budget of a hybrid `H` with respect to the
pair `(A, B)`: by the triangle inequality it is always nonnegative
(`sharing_gap_nonneg`), and it is `0` exactly when the hybrid saturates the
ceiling. -/
noncomputable def sharingGap (H A B : Ω → Y) : ℝ :=
  1 + agreeFrac A B - (agreeFrac H A + agreeFrac H B)

theorem sharing_gap_nonneg (H : Ω → Y) : 0 ≤ sharingGap H A B := by
  have h := pair_agreement_le H A B (agreeFrac A B) le_rfl
  unfold sharingGap
  linarith

/-- **The bulk transplant is near-optimal sharing.**  With the measured L10/11
numbers (`0.9635` with the host, `0.8385` with the donor) and the cross-parent
baseline `0.8327`, the bulk hybrid leaves at most `0.0307` of the sharing budget
unused — and, by `sharing_gap_nonneg`, at least `0`.  Sharing the bulk layers is
within three percentage points of the geometric optimum. -/
theorem net54_bulk_swap_near_sharing_ceiling (H : Ω → Y)
    (hbase : agreeFrac A B ≤ 0.8327)
    (hHA : (0.9635 : ℝ) ≤ agreeFrac H A) (hHB : (0.8385 : ℝ) ≤ agreeFrac H B) :
    0 ≤ sharingGap H A B ∧ sharingGap H A B ≤ 0.0307 := by
  refine ⟨sharing_gap_nonneg A B H, ?_⟩
  unfold sharingGap
  linarith

omit [DecidableEq Ω] in
/-- **The tail transplant is far from the ceiling.**  With the measured L22/23
numbers the tail hybrid wastes at least `0.7039` of the same budget. -/
theorem net54_tail_swap_far_from_ceiling (H : Ω → Y)
    (hbase : (0.8327 : ℝ) ≤ agreeFrac A B)
    (hHA : agreeFrac H A ≤ 0.5845) (hHB : agreeFrac H B ≤ 0.5443) :
    (0.7039 : ℝ) ≤ sharingGap H A B := by
  unfold sharingGap
  linarith

/-- **The sharing boundary, quantified.**  On the same held-out set and the same
parent pair, the tail (L22/23) transplant wastes at least `22 ×` as much of the
sharing budget as the bulk (L10/11) transplant.  This is the precise sense in
which the last two layers are the part that must not be shared. -/
theorem net54_tail_at_least_22x_less_shareable (Hbulk Htail : Ω → Y)
    (hbase : agreeFrac A B = 0.8327)
    (hbulkA : (0.9635 : ℝ) ≤ agreeFrac Hbulk A) (hbulkB : (0.8385 : ℝ) ≤ agreeFrac Hbulk B)
    (htailA : agreeFrac Htail A ≤ 0.5845) (htailB : agreeFrac Htail B ≤ 0.5443) :
    22 * sharingGap Hbulk A B ≤ sharingGap Htail A B := by
  have hb : sharingGap Hbulk A B ≤ 0.0307 :=
    (net54_bulk_swap_near_sharing_ceiling A B Hbulk hbase.le hbulkA hbulkB).2
  have ht : (0.7039 : ℝ) ≤ sharingGap Htail A B :=
    net54_tail_swap_far_from_ceiling A B Htail hbase.ge htailA htailB
  linarith

end NET54

end Catalog.Probability.SharedTailServingCeiling