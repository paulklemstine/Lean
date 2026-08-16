/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.DeepestRungGapConcavity

/-!
# Where the selection gap peaks, and how it transfers to accuracy (cycle 6)

Cycle 5 (`DeepestRungGapConcavity.lean`) proved that the selection gap
`selectionGap a k = bestMass a k − k/n` — the mass advantage of top-`k` selection over the
repaired random-`k` control of NET-43 Part B2, whose expected mass is exactly `k/n` — is a
*concave* sequence, hence unimodal.  Two sub-conjectures were left open in
`FUTURE_DIRECTIONS.md`:

* **Sub-conjecture 2 (locate the peak).**  Concavity says the gap rises and then falls, but
  says nothing about *where* it turns.
* **Sub-conjecture 3 (concavity transfer).**  The measured Part-B2 quantity is an *accuracy*
  gap, not a mass gap; the bridge from mass to accuracy was assumed, not proved.

This file closes both, and in doing so identifies the peak value with a classical statistical
quantity.

## 1. The peak is at the above-average keys, and its height is a total-variation distance

Write `aboveAvg a = {i : pᵢ > 1/n}` for the set of keys carrying more than uniform mass, and
`excessMass a = ∑ᵢ max(pᵢ − 1/n, 0)` for the total excess over uniform.  Then

* `selectionGap_le_excessMass` : every width `k` has `selectionGap a k ≤ excessMass a`;
* `selectionGap_aboveAvg` : the bound is *attained* at `k = |aboveAvg a|`;
* `excessMass_eq_tv` : `excessMass a = ½ ∑ᵢ |pᵢ − 1/n|`, the total-variation distance from the
  attention row to the uniform row.

So the maximum possible selection advantage over the random control, across *all* widths, is
exactly the total-variation distance between the attention row and uniform attention, and it
is achieved at exactly the number of above-average keys (`selectionGap_peak_at_aboveAvg`).
This is the sharp, width-free ceiling that the concavity of cycle 5 could only bracket.

Two structural corollaries: the peak width is strictly below `n` whenever the row is not
uniform-dominated (`aboveAvg_card_lt`), and the NET-43 numbers (`n = 512`, top-`256` mass
`0.922`) force a total-variation distance of at least `0.422`
(`net43_tv_distance_ge`) — a purely mathematical consequence of the reported concentration.

## 2. Concavity transfer: from captured mass to accuracy

If accuracy is a concave nondecreasing function `g` of captured mass — the standard
diminishing-returns assumption behind reading a knee off an accuracy curve — then

* `ConcaveSeq.comp_concave` : `k ↦ g (f k)` is concave whenever `f` is a concave sequence;
* `accuracyCurve_concave`, `accuracyCurve_unimodal` : the accuracy curve
  `k ↦ g (bestMass a k)` is concave, so its increments are antitone and it is unimodal — the
  shape assumption that the sweep `{96, …, 512}` implicitly makes is now a theorem;
* `accuracyGap_le_of_lipschitz` : if `g` is in addition `L`-Lipschitz, the *accuracy* gap
  `g(bestMass a k) − g(k/n)` is at most `L · excessMass a`.

The last item is the missing bridge of sub-conjecture 3 in quantitative form: the measured
accuracy gaps `+2.6 (k = 256)` and `+1.7 (k = 384)` are capped, uniformly in `k`, by the
Lipschitz constant times the total-variation distance to uniform.

## Main results

* `selectionGap_le_excessMass`, `selectionGap_aboveAvg`, `selectionGap_peak_at_aboveAvg`
* `knee_ge_of_excessMass` — a total-variation floor on the knee
* `excessMass_eq_tv`, `aboveAvg_card_lt`, `net43_tv_distance_ge`
* `ConcaveSeq.comp_concave`, `accuracyCurve_concave`, `accuracyCurve_unimodal`
* `accuracyGap_le_of_lipschitz`
-/

namespace Bridges.DeepestRungTwoSeed256

open Finset

variable {n : ℕ}

/-! ## 1. Above-average keys and the excess mass -/

open Classical in
/-- The **above-average keys**: those carrying strictly more than the uniform share `1/n`. -/
noncomputable def aboveAvg (a : AttnDist n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => 1 / (n : ℝ) < a.p i)

/-- The **excess mass** over uniform, `∑ᵢ (pᵢ − 1/n)⁺`.  By `excessMass_eq_tv` this is the
total-variation distance from the attention row to the uniform row. -/
noncomputable def excessMass (a : AttnDist n) : ℝ := ∑ i, max (a.p i - 1 / (n : ℝ)) 0

lemma excessMass_nonneg (a : AttnDist n) : 0 ≤ excessMass a :=
  Finset.sum_nonneg fun _ _ => le_max_right _ _

/-- The excess mass equals half the `ℓ¹` distance to the uniform row: since the signed
deviations sum to zero, the positive part carries exactly half the absolute mass. -/
theorem excessMass_eq_tv (a : AttnDist n) :
    excessMass a = (∑ i, |a.p i - 1 / (n : ℝ)|) / 2 := by
  have hpt : ∀ i : Fin n,
      max (a.p i - 1 / (n : ℝ)) 0
        = ((a.p i - 1 / (n : ℝ)) + |a.p i - 1 / (n : ℝ)|) / 2 := by
    intro i
    rcases le_total (0 : ℝ) (a.p i - 1 / (n : ℝ)) with h | h
    · rw [max_eq_left h, abs_of_nonneg h]; ring
    · rw [max_eq_right h, abs_of_nonpos h]; ring
  have hsum0 : ∑ i, (a.p i - 1 / (n : ℝ)) = 0 := by
    rcases Nat.eq_zero_or_pos n with hn | hn
    · subst hn; simp
    · have hne : ((n : ℝ)) ≠ 0 := by positivity
      rw [Finset.sum_sub_distrib, a.sum_one, Finset.sum_const, nsmul_eq_mul,
        Finset.card_univ, Fintype.card_fin, mul_one_div, div_self hne, sub_self]
  calc excessMass a = ∑ i, ((a.p i - 1 / (n : ℝ)) + |a.p i - 1 / (n : ℝ)|) / 2 := by
        simp only [excessMass, hpt]
    _ = ((∑ i, (a.p i - 1 / (n : ℝ))) + ∑ i, |a.p i - 1 / (n : ℝ)|) / 2 := by
        rw [← Finset.sum_add_distrib, ← Finset.sum_div]
    _ = (∑ i, |a.p i - 1 / (n : ℝ)|) / 2 := by rw [hsum0]; ring

/-- Any selection's mass, discounted by the uniform baseline of its own size, is at most the
excess mass. -/
lemma sum_sub_card_div_le_excessMass (a : AttnDist n) (S : Finset (Fin n)) :
    (∑ i ∈ S, a.p i) - (S.card : ℝ) / n ≤ excessMass a := by
  have hS : (∑ i ∈ S, a.p i) - (S.card : ℝ) / n = ∑ i ∈ S, (a.p i - 1 / (n : ℝ)) := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul]
    ring
  rw [hS]
  calc ∑ i ∈ S, (a.p i - 1 / (n : ℝ)) ≤ ∑ i ∈ S, max (a.p i - 1 / (n : ℝ)) 0 :=
        Finset.sum_le_sum fun _ _ => le_max_left _ _
    _ ≤ excessMass a :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
          (fun _ _ _ => le_max_right _ _)

/-- **The width-free ceiling on the selection gap.**  No width `k` can beat the random-`k`
control by more than the total excess over uniform. -/
theorem selectionGap_le_excessMass (a : AttnDist n) (hn : 0 < n) (k : ℕ) :
    selectionGap a k ≤ excessMass a := by
  rw [selectionGap, bestMass]
  rw [sub_le_iff_le_add]
  refine Finset.sup'_le _ _ (fun S hS => ?_)
  have hcard : (S.card : ℝ) ≤ (k : ℝ) := by exact_mod_cast mem_Kset.1 hS
  have hdiv : (S.card : ℝ) / n ≤ (k : ℝ) / n := by gcongr
  have := sum_sub_card_div_le_excessMass a S
  linarith

/-- Off the above-average set, the positive part of the deviation vanishes; hence the excess
mass is carried entirely by `aboveAvg a`. -/
lemma excessMass_eq_sum_aboveAvg (a : AttnDist n) :
    excessMass a = ∑ i ∈ aboveAvg a, (a.p i - 1 / (n : ℝ)) := by
  classical
  rw [excessMass, ← Finset.sum_filter_add_sum_filter_not Finset.univ
      (fun i => 1 / (n : ℝ) < a.p i) (fun i => max (a.p i - 1 / (n : ℝ)) 0)]
  have h1 : ∑ i ∈ Finset.univ.filter (fun i => 1 / (n : ℝ) < a.p i),
      max (a.p i - 1 / (n : ℝ)) 0
      = ∑ i ∈ aboveAvg a, (a.p i - 1 / (n : ℝ)) := by
    refine Finset.sum_congr rfl (fun i hi => ?_)
    have : 1 / (n : ℝ) < a.p i := (Finset.mem_filter.1 hi).2
    exact max_eq_left (by linarith)
  have h2 : ∑ i ∈ Finset.univ.filter (fun i => ¬ 1 / (n : ℝ) < a.p i),
      max (a.p i - 1 / (n : ℝ)) 0 = 0 := by
    refine Finset.sum_eq_zero (fun i hi => ?_)
    have : ¬ 1 / (n : ℝ) < a.p i := (Finset.mem_filter.1 hi).2
    exact max_eq_right (by linarith [not_lt.1 this])
  rw [h1, h2, add_zero]

/-- **The peak height.**  At the width equal to the number of above-average keys the
selection gap *equals* the excess mass. -/
theorem selectionGap_aboveAvg (a : AttnDist n) (hn : 0 < n) :
    selectionGap a (aboveAvg a).card = excessMass a := by
  classical
  refine le_antisymm (selectionGap_le_excessMass a hn _) ?_
  have hle : ∑ i ∈ aboveAvg a, a.p i ≤ bestMass a (aboveAvg a).card :=
    mass_le_bestMass a le_rfl
  have hsplit : ∑ i ∈ aboveAvg a, (a.p i - 1 / (n : ℝ))
      = (∑ i ∈ aboveAvg a, a.p i) - ((aboveAvg a).card : ℝ) / n := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul]
    ring
  rw [excessMass_eq_sum_aboveAvg, hsplit, selectionGap]
  linarith

/-- **Sub-conjecture 2, closed: the peak is located.**  The selection gap attains its maximum
at `k = |aboveAvg a|`, the number of keys carrying more than the uniform share. -/
theorem selectionGap_peak_at_aboveAvg (a : AttnDist n) (hn : 0 < n) (k : ℕ) :
    selectionGap a k ≤ selectionGap a (aboveAvg a).card := by
  rw [selectionGap_aboveAvg a hn]
  exact selectionGap_le_excessMass a hn k

/-- **A total-variation floor on the knee.**  If width `k` already captures mass `τ`, then
`k ≥ n·(τ − TV(p, uniform))`: a row close to uniform cannot have a small knee.  This is the
complement of the concentration floor `k ≥ τ²·eff` of cycle 1, using distance to uniform
instead of the participation ratio. -/
theorem knee_ge_of_excessMass (a : AttnDist n) (hn : 0 < n) {k : ℕ} {τ : ℝ}
    (hk : τ ≤ bestMass a k) : (n : ℝ) * (τ - excessMass a) ≤ (k : ℝ) := by
  have h := selectionGap_le_excessMass a hn k
  rw [selectionGap] at h
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have h1 : τ - excessMass a ≤ (k : ℝ) / n := by linarith
  calc (n : ℝ) * (τ - excessMass a) ≤ (n : ℝ) * ((k : ℝ) / n) :=
        mul_le_mul_of_nonneg_left h1 (le_of_lt hn')
    _ = (k : ℝ) := by field_simp

/-- The peak width is strictly smaller than `n`: some key must carry at most the uniform
share, else the weights would sum to more than `1`. -/
theorem aboveAvg_card_lt (a : AttnDist n) (hn : 0 < n) : (aboveAvg a).card < n := by
  classical
  by_contra hcon
  push_neg at hcon
  have hfull : aboveAvg a = Finset.univ :=
    Finset.eq_univ_of_card _ (le_antisymm (by simpa using Finset.card_le_univ (aboveAvg a))
      (by simpa using hcon))
  have hstrict : ∀ i : Fin n, 1 / (n : ℝ) < a.p i := by
    intro i
    have : i ∈ aboveAvg a := by rw [hfull]; exact Finset.mem_univ i
    exact (Finset.mem_filter.1 this).2
  have hne : ((n : ℝ)) ≠ 0 := by positivity
  have hsum : ∑ _i : Fin n, 1 / (n : ℝ) < ∑ i, a.p i :=
    Finset.sum_lt_sum_of_nonempty (Finset.univ_nonempty_iff.2 (Fin.pos_iff_nonempty.1 hn))
      (fun i _ => hstrict i)
  rw [a.sum_one, Finset.sum_const, nsmul_eq_mul, Finset.card_univ, Fintype.card_fin,
    mul_one_div, div_self hne] at hsum
  exact lt_irrefl _ hsum

/-- **NET-43 instance.**  The round reports `n = 512` keys and a top-`256` attention mass of
`0.922`.  Then the attention row is at total-variation distance at least `0.422` from
uniform: the reported concentration is, quantitatively, a distance-to-uniform statement. -/
theorem net43_tv_distance_ge (a : AttnDist 512) (h : (0.922 : ℝ) ≤ bestMass a 256) :
    (0.422 : ℝ) ≤ (∑ i, |a.p i - 1 / (512 : ℝ)|) / 2 := by
  have hgap : (0.422 : ℝ) ≤ selectionGap a 256 := by
    rw [selectionGap]
    norm_num
    linarith
  have := selectionGap_le_excessMass a (by norm_num) 256
  rw [excessMass_eq_tv] at this
  linarith

/-! ## 2. Concavity transfer: from captured mass to accuracy -/

/-- **Concavity transfer.**  Post-composing a concave sequence with a concave nondecreasing
function again gives a concave sequence.  This is the formal content of "accuracy is a
concave increasing function of captured mass". -/
theorem ConcaveSeq.comp_concave {f : ℕ → ℝ} (hf : ConcaveSeq f) {g : ℝ → ℝ}
    (hg : ConcaveOn ℝ Set.univ g) (hmono : Monotone g) : ConcaveSeq (fun k => g (f k)) := by
  intro k
  have hmid : (1 / 2 : ℝ) * f (k + 2) + (1 / 2 : ℝ) * f k ≤ f (k + 1) := by
    have := hf k; linarith
  have h1 := hg.2 (Set.mem_univ (f (k + 2))) (Set.mem_univ (f k))
    (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num)
  simp only [smul_eq_mul] at h1
  have h2 : g ((1 / 2 : ℝ) * f (k + 2) + (1 / 2 : ℝ) * f k) ≤ g (f (k + 1)) := hmono hmid
  show g (f (k + 2)) + g (f k) ≤ 2 * g (f (k + 1))
  linarith

/-- **The accuracy curve is concave.**  With accuracy a concave nondecreasing function of
captured mass, the sweep's accuracy-versus-width curve is a concave sequence. -/
theorem accuracyCurve_concave (a : AttnDist n) {g : ℝ → ℝ}
    (hg : ConcaveOn ℝ Set.univ g) (hmono : Monotone g) :
    ConcaveSeq (fun k => g (bestMass a k)) :=
  ConcaveSeq.comp_concave (fun k => bestMass_midpoint_concave a k) hg hmono

/-- The accuracy curve is unimodal in the width — the shape the knee sweep presupposes. -/
theorem accuracyCurve_unimodal (a : AttnDist n) {g : ℝ → ℝ}
    (hg : ConcaveOn ℝ Set.univ g) (hmono : Monotone g) {i j m : ℕ}
    (hij : i ≤ j) (hjm : j ≤ m) :
    min (g (bestMass a i)) (g (bestMass a m)) ≤ g (bestMass a j) :=
  (accuracyCurve_concave a hg hmono).min_le_of_between hij hjm

/-- The accuracy curve has antitone increments: each extra unit of width buys no more than
the previous one did. -/
theorem accuracyCurve_diff_antitone (a : AttnDist n) {g : ℝ → ℝ}
    (hg : ConcaveOn ℝ Set.univ g) (hmono : Monotone g) :
    Antitone (fun k => g (bestMass a (k + 1)) - g (bestMass a k)) :=
  (accuracyCurve_concave a hg hmono).diff_antitone

/-- **Sub-conjecture 3, quantitative half.**  If accuracy is `L`-Lipschitz in captured mass,
the Part-B2 *accuracy* gap between top-`k` selection and the random-`k` control is at most
`L` times the total-variation distance to uniform — uniformly in the width `k`. -/
theorem accuracyGap_le_of_lipschitz (a : AttnDist n) (hn : 0 < n) {g : ℝ → ℝ} {L : ℝ}
    (hL : 0 ≤ L) (hlip : ∀ x y : ℝ, y ≤ x → g x - g y ≤ L * (x - y)) {k : ℕ} (hk : k ≤ n) :
    g (bestMass a k) - g ((k : ℝ) / n) ≤ L * excessMass a := by
  have hxy : ((k : ℝ)) / n ≤ bestMass a k := by
    have := selectionGap_nonneg a hn hk
    rw [selectionGap] at this
    linarith
  have hgap : bestMass a k - (k : ℝ) / n ≤ excessMass a := by
    have := selectionGap_le_excessMass a hn k
    rw [selectionGap] at this
    exact this
  calc g (bestMass a k) - g ((k : ℝ) / n) ≤ L * (bestMass a k - (k : ℝ) / n) :=
        hlip _ _ hxy
    _ ≤ L * excessMass a := mul_le_mul_of_nonneg_left hgap hL

end Bridges.DeepestRungTwoSeed256