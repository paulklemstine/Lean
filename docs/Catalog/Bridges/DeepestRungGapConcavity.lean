/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.DeepestRungPowerTail

/-!
# Concavity and unimodality of the selection gap (cycle 5)

`FUTURE_DIRECTIONS.md`, Conjecture 3, asserted that the *selection gap* of the repaired
random-`k` control — the advantage `bestMass a k − k/n` of top-`k` selection over a uniformly
random width-`k` set, whose expected mass is exactly `k/n` (`expected_random_mass`) — is
**unimodal in `k`**, vanishing at full width, and that the measured accuracy gaps
`+2.6 (k = 256) → +1.7 (k = 384)` should extrapolate downward.  Sub-conjecture 2 of the same
document asked for the shape half: concavity of `k ↦ bestMass a k − k/n`.

This file proves both halves.

**The combinatorial input** is a one-step exchange argument (`bestMass_midpoint_concave`):
if `S` is an optimal width-`(k+2)` set and `T` an optimal width-`k` set, then either `S`
already fits in width `k+1`, or `|S| > |T|` and some `x ∈ S \ T` can be moved from `S` to
`T`, producing two width-`(k+1)` sets of the same total mass.  Hence
`bestMass (k+2) + bestMass k ≤ 2·bestMass (k+1)`, i.e. the top-`k` mass curve is a *concave
sequence*, and subtracting the linear function `k/n` preserves this.

**The order-theoretic output** is that a concave sequence is unimodal
(`ConcaveSeq.min_le_of_between`): once it starts to fall it never rises again, because its
increment sequence is antitone.  Applied to the gap — which is `0` at `k = 0` and at
`k = n` — unimodality re-derives nonnegativity of the selection gap structurally, and
supplies a falsifiable chord extrapolation for the measured accuracy gaps
(`net43_gap_chord_extrapolation`: concavity alone caps the `k = 512` gap at `+0.8`).

## Main results

* `bestMass_midpoint_concave` — exchange argument: the top-`k` mass curve is concave
* `ConcaveSeq.diff_antitone`, `ConcaveSeq.chord` — increments are antitone
* `ConcaveSeq.min_le_of_between` — a concave sequence is unimodal
* `selectionGap_concave`, `selectionGap_unimodal`, `selectionGap_nonneg`
* `net43_gap_chord_extrapolation` — the falsifiable prediction at `k = 512`
-/

namespace Bridges.DeepestRungTwoSeed256

open Finset

variable {n : ℕ}

/-! ## 1. The exchange argument -/

/-- **Concavity of the top-`k` mass curve.**  `bestMass a (k+2) + bestMass a k ≤
2 · bestMass a (k+1)`.  The proof is a single exchange: an optimal width-`(k+2)` set that is
strictly larger than an optimal width-`k` set can donate one of its keys to the latter,
producing two admissible width-`(k+1)` sets carrying the same total mass. -/
theorem bestMass_midpoint_concave (a : AttnDist n) (k : ℕ) :
    bestMass a (k + 2) + bestMass a k ≤ 2 * bestMass a (k + 1) := by
  classical
  obtain ⟨S, hS, hSeq⟩ :=
    Finset.exists_mem_eq_sup' (Kset_nonempty n (k + 2)) (fun S => ∑ i ∈ S, a.p i)
  obtain ⟨T, hT, hTeq⟩ :=
    Finset.exists_mem_eq_sup' (Kset_nonempty n k) (fun S => ∑ i ∈ S, a.p i)
  have hScard : S.card ≤ k + 2 := mem_Kset.1 hS
  have hTcard : T.card ≤ k := mem_Kset.1 hT
  rw [show bestMass a (k + 2) = ∑ i ∈ S, a.p i from hSeq,
    show bestMass a k = ∑ i ∈ T, a.p i from hTeq]
  by_cases hsmall : S.card ≤ k + 1
  · have h1 : ∑ i ∈ S, a.p i ≤ bestMass a (k + 1) := mass_le_bestMass a hsmall
    have h2 : ∑ i ∈ T, a.p i ≤ bestMass a (k + 1) :=
      mass_le_bestMass a (le_trans hTcard (Nat.le_succ k))
    linarith
  · push_neg at hsmall
    -- `S` is strictly bigger than `T`, so it contains a key outside `T`
    have hlt : T.card < S.card := lt_of_le_of_lt hTcard (by omega)
    have hnsub : ¬ S ⊆ T := fun h => absurd (Finset.card_le_card h) (by omega)
    obtain ⟨x, hxS, hxT⟩ := Finset.not_subset.1 hnsub
    have hA : (S.erase x).card ≤ k + 1 := by
      have : (S.erase x).card = S.card - 1 := Finset.card_erase_of_mem hxS
      omega
    have hB : (insert x T).card ≤ k + 1 := by
      have : (insert x T).card = T.card + 1 := Finset.card_insert_of_notMem hxT
      omega
    have hsumA : ∑ i ∈ S.erase x, a.p i = (∑ i ∈ S, a.p i) - a.p x := by
      have := Finset.add_sum_erase _ (fun i => a.p i) hxS
      linarith [this]
    have hsumB : ∑ i ∈ insert x T, a.p i = a.p x + ∑ i ∈ T, a.p i :=
      Finset.sum_insert hxT
    have h1 : ∑ i ∈ S.erase x, a.p i ≤ bestMass a (k + 1) := mass_le_bestMass a hA
    have h2 : ∑ i ∈ insert x T, a.p i ≤ bestMass a (k + 1) := mass_le_bestMass a hB
    rw [hsumA] at h1
    rw [hsumB] at h2
    linarith

/-! ## 2. Concave sequences are unimodal -/

/-- A real sequence is *concave* if each term is at least the average of its neighbours. -/
def ConcaveSeq (f : ℕ → ℝ) : Prop := ∀ k : ℕ, f (k + 2) + f k ≤ 2 * f (k + 1)

/-- Telescoping: `f (m + t) = f m + ∑_{s < t} (f (m+s+1) − f (m+s))`. -/
lemma seq_telescope (f : ℕ → ℝ) (m t : ℕ) :
    f (m + t) = f m + ∑ s ∈ Finset.range t, (f (m + s + 1) - f (m + s)) := by
  induction t with
  | zero => simp
  | succ t ih =>
      rw [Finset.sum_range_succ, show m + (t + 1) = (m + t) + 1 from by omega]
      linarith [ih]

/-- The increment sequence of a concave sequence is antitone. -/
lemma ConcaveSeq.diff_antitone {f : ℕ → ℝ} (h : ConcaveSeq f) :
    Antitone (fun k => f (k + 1) - f k) := by
  refine antitone_nat_of_succ_le (fun k => ?_)
  have := h k
  show f (k + 1 + 1) - f (k + 1) ≤ f (k + 1) - f k
  linarith

/-- If all increments on `[m, m+t)` are nonnegative, the sequence does not decrease there. -/
lemma seq_le_of_diffs_nonneg {f : ℕ → ℝ} {m t : ℕ}
    (h : ∀ s < t, 0 ≤ f (m + s + 1) - f (m + s)) : f m ≤ f (m + t) := by
  rw [seq_telescope f m t]
  have : (0:ℝ) ≤ ∑ s ∈ Finset.range t, (f (m + s + 1) - f (m + s)) :=
    Finset.sum_nonneg (fun s hs => h s (Finset.mem_range.1 hs))
  linarith

/-- **Chord comparison.**  For a concave sequence, a step of length `t` taken later is never
better than the same step taken earlier. -/
lemma ConcaveSeq.chord {f : ℕ → ℝ} (h : ConcaveSeq f) {i j : ℕ} (hij : i ≤ j) (t : ℕ) :
    f (j + t) - f j ≤ f (i + t) - f i := by
  rw [seq_telescope f j t, seq_telescope f i t]
  have : ∑ s ∈ Finset.range t, (f (j + s + 1) - f (j + s))
      ≤ ∑ s ∈ Finset.range t, (f (i + s + 1) - f (i + s)) :=
    Finset.sum_le_sum (fun s _ => h.diff_antitone (by omega : i + s ≤ j + s))
  linarith

/-- **A concave sequence is unimodal.**  For `i ≤ j ≤ m`, the middle value is at least the
smaller of the two endpoint values: the sequence rises, then falls, and can never dip below
both ends. -/
theorem ConcaveSeq.min_le_of_between {f : ℕ → ℝ} (h : ConcaveSeq f) {i j m : ℕ}
    (hij : i ≤ j) (hjm : j ≤ m) : min (f i) (f m) ≤ f j := by
  by_cases hcase : f i ≤ f j
  · exact le_trans (min_le_left _ _) hcase
  · push_neg at hcase
    -- some increment in `[i, j)` is negative
    have hex : ∃ s, s < j - i ∧ f (i + s + 1) - f (i + s) < 0 := by
      by_contra hcon
      push_neg at hcon
      have hmono : f i ≤ f (i + (j - i)) :=
        seq_le_of_diffs_nonneg (fun s hs => by linarith [hcon s hs])
      rw [show i + (j - i) = j from by omega] at hmono
      linarith
    obtain ⟨s, _, hneg⟩ := hex
    -- from that point on the sequence strictly decreases, so `f m ≤ f j`
    have hdec : ∀ u, f (j + u + 1) - f (j + u) ≤ 0 := by
      intro u
      have := h.diff_antitone (by omega : i + s ≤ j + u)
      simp only at this
      linarith
    have hfall : f (j + (m - j)) ≤ f j := by
      rw [seq_telescope f j (m - j)]
      have : ∑ u ∈ Finset.range (m - j), (f (j + u + 1) - f (j + u)) ≤ 0 :=
        Finset.sum_nonpos (fun u _ => hdec u)
      linarith
    rw [show j + (m - j) = m from by omega] at hfall
    exact le_trans (min_le_right _ _) hfall

/-! ## 3. The selection gap -/

/-- The **selection gap**: the mass advantage of the top-`k` selection over the random-`k`
control, whose expected mass is exactly `k/n` (`expected_random_mass`). -/
noncomputable def selectionGap (a : AttnDist n) (k : ℕ) : ℝ := bestMass a k - (k : ℝ) / n

/-- **Sub-conjecture 2, closed.**  The selection gap is a concave sequence in the width `k`:
subtracting the linear control baseline `k/n` from the concave top-`k` mass curve preserves
concavity. -/
theorem selectionGap_concave (a : AttnDist n) : ConcaveSeq (selectionGap a) := by
  intro k
  have hmass := bestMass_midpoint_concave a k
  have hlin : (((k + 2 : ℕ) : ℝ)) / n + ((k : ℕ) : ℝ) / n = 2 * (((k + 1 : ℕ) : ℝ) / n) := by
    push_cast
    ring
  simp only [selectionGap]
  push_cast at hlin ⊢
  linarith

/-- **Conjecture 3, shape half.**  The selection gap is unimodal in the width. -/
theorem selectionGap_unimodal (a : AttnDist n) {i j m : ℕ} (hij : i ≤ j) (hjm : j ≤ m) :
    min (selectionGap a i) (selectionGap a m) ≤ selectionGap a j :=
  (selectionGap_concave a).min_le_of_between hij hjm

lemma selectionGap_zero (a : AttnDist n) : selectionGap a 0 = 0 := by
  simp [selectionGap, bestMass]
  refine le_antisymm (Finset.sup'_le _ _ (fun S hS => ?_)) ?_
  · have : S = ∅ := Finset.card_eq_zero.1 (Nat.le_zero.1 (mem_Kset.1 hS))
    simp [this]
  · exact mass_le_bestMass (k := 0) a (S := (∅ : Finset (Fin n))) (by simp) |>.trans_eq rfl

/-- At full width the selection gap vanishes: everything is selected and the control is the
same set. -/
lemma selectionGap_full (a : AttnDist n) (hn : 0 < n) : selectionGap a n = 0 := by
  have h1 : bestMass a n = 1 := by
    refine le_antisymm (bestMass_le_one a) ?_
    have := mass_le_bestMass (k := n) a (S := (Finset.univ : Finset (Fin n)))
      (by simp)
    rw [a.sum_one] at this
    exact this
  have hnR : ((n : ℝ)) ≠ 0 := by positivity
  simp [selectionGap, h1, div_self hnR]

/-- **Selection-gap nonnegativity, derived from shape alone.**  For every width `k ≤ n` the
top-`k` selection beats the random-`k` control in expectation.  Unlike
`bestMass_ge_uniform_fraction`, which double-counts over all `k`-subsets, this proof uses
only concavity of the mass curve and the two endpoint values `selectionGap 0 = selectionGap n
= 0`. -/
theorem selectionGap_nonneg (a : AttnDist n) (hn : 0 < n) {k : ℕ} (hk : k ≤ n) :
    0 ≤ selectionGap a k := by
  have := selectionGap_unimodal a (i := 0) (j := k) (m := n) (Nat.zero_le k) hk
  rw [selectionGap_zero a, selectionGap_full a hn] at this
  simpa using this

/-- **Falsifiable chord extrapolation for the repaired Part-B2 control.**  Concavity of a
gap curve, together with the two measured NET-43 accuracy gaps `+2.6` at `k = 256` and
`+1.7` at `k = 384`, forces the `k = 512` gap to be at most `+0.8`: the decay cannot slow
down.  A measured gap above `0.8` at full width would refute concavity of the accuracy gap
(the mass gap is concave unconditionally, by `selectionGap_concave`). -/
theorem net43_gap_chord_extrapolation {f : ℕ → ℝ} (h : ConcaveSeq f)
    (h256 : f 256 = 2.6) (h384 : f 384 = 1.7) : f 512 ≤ 0.8 := by
  have := h.chord (i := 256) (j := 384) (by omega) 128
  norm_num [h256, h384] at this
  linarith

end Bridges.DeepestRungTwoSeed256