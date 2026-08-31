/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# From rank correlation to yield: a discordance budget for the skip-flip

Second cycle on experiment 559.  `Probability.AdaptiveQSSkipFlip` proves that a
*concordant* dial (one that never orders two targets backwards) always wins when it
is deployed as a skip rule.  The measured dial is **not** concordant: its Spearman
correlation against the realised yield is `0.739` (oracle dial `0.778`,
`FB100 0.835`), i.e. a positive but bounded number of ranking inversions.  The
question this file settles is the one the measurement actually poses:

> how much yield can a *bounded number of inversions* cost the skip rule?

The answer is a linear discordance budget.  Writing `Disc` for the set of ordered
pairs the dial gets backwards and `M` for the largest rate,

`|K| · (total yield) ≤ |s| · (kept yield) + M · |Disc|`,

so the retention deficit is at most `M |Disc| / (|s| · |K|)` per unit of work
(`throughput_le_of_discordance`).  With `Disc = ∅` this is exactly the concordant
theorem of the previous cycle (`retention_ge_work_fraction`), and the bound
degrades *linearly*, not catastrophically, in the number of inversions — which is
why a dial with Spearman well below `1` still retained `89.5%` of the relations
while skipping `28.3%` of the work.

Main results.

* `discordantPairs` — the inversion set of a dial against the true rate.
* `sum_le_of_bounded_exceptions` — the general engine: separation with an
  exceptional set of pairs, each of which can cost at most `M`.
* `retention_of_discordance` — the discordance budget for threshold skipping.
* `throughput_le_of_discordance` — the same bound in throughput (yield per unit of
  work) form.
* `retention_of_discordance_eq_concordant` — the bound collapses to the exact
  concordant statement when the inversion set is empty (consistency check).
* Lab notes: `labnote_invRate_loses`, `labnote_skip_gain`,
  `labnote_concentrator_gain` — a fully explicit three-target instance with the
  qualitative shape of the measured run (inverse-rate allocation loses ~34%,
  skipping the worst target retains `87.5%` of the yield for `66.7%` of the work,
  the concentrator gains).
-/
import Mathlib
import Probability.AdaptiveQSAllocation
import Probability.AdaptiveQSSkipFlip

namespace Probability.AdaptiveQS

open Finset

variable {ι : Type*} [DecidableEq ι]

/-! ## Separation with a bounded set of exceptions -/

/-- If every pair `(j, i) ∈ D ×ˢ K` outside an exceptional set `E` satisfies `r j ≤ r i`,
and all rates lie in `[0, M]`, then the retention beats the work fraction up to the
linear penalty `M |E|`. -/
theorem sum_le_of_bounded_exceptions {s K D : Finset ι} {r : ι → ℝ} {M : ℝ}
    (hunion : K ∪ D = s) (hdisj : Disjoint K D) (hM : 0 ≤ M)
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) (hle : ∀ i ∈ s, r i ≤ M)
    (E : Finset (ι × ι))
    (hE : ∀ p ∈ D ×ˢ K, p ∉ E → r p.1 ≤ r p.2) :
    (K.card : ℝ) * (∑ i ∈ s, r i) ≤ (s.card : ℝ) * (∑ i ∈ K, r i) + M * E.card := by
  have hKs : K ⊆ s := hunion ▸ Finset.subset_union_left
  have hDs : D ⊆ s := hunion ▸ Finset.subset_union_right
  have hsplit : ∑ i ∈ s, r i = (∑ i ∈ K, r i) + ∑ j ∈ D, r j := by
    rw [← hunion, Finset.sum_union hdisj]
  have hcard : (s.card : ℝ) = (K.card : ℝ) + (D.card : ℝ) := by
    rw [← hunion, Finset.card_union_of_disjoint hdisj]
    push_cast
    ring
  -- pairwise bound with an indicator penalty
  have hterm : ∀ p ∈ D ×ˢ K, r p.1 - r p.2 ≤ if p ∈ E then M else 0 := by
    intro p hp
    rw [Finset.mem_product] at hp
    by_cases hpE : p ∈ E
    · simp only [hpE, if_true]
      have h1 : r p.1 ≤ M := hle _ (hDs hp.1)
      have h2 : 0 ≤ r p.2 := hnonneg _ (hKs hp.2)
      linarith
    · simp only [hpE, if_false]
      linarith [hE p (Finset.mem_product.mpr hp) hpE]
  have hsum : ∑ p ∈ D ×ˢ K, (r p.1 - r p.2) ≤ ∑ p ∈ D ×ˢ K, (if p ∈ E then M else 0) :=
    Finset.sum_le_sum hterm
  -- the penalty sum is at most `M |E|`
  have hpen : ∑ p ∈ D ×ˢ K, (if p ∈ E then M else 0) ≤ M * E.card := by
    have hMnn : 0 ≤ M := hM
    calc ∑ p ∈ D ×ˢ K, (if p ∈ E then M else 0)
        = ∑ p ∈ (D ×ˢ K).filter (fun p => p ∈ E), M := by
          rw [Finset.sum_filter]
      _ ≤ ∑ _p ∈ E, M := by
          refine Finset.sum_le_sum_of_subset_of_nonneg ?_ (fun _ _ _ => hMnn)
          intro p hp
          rw [Finset.mem_filter] at hp
          exact hp.2
      _ = M * E.card := by rw [Finset.sum_const, nsmul_eq_mul]; ring
  -- unfold the double sum
  have hL : ∑ p ∈ D ×ˢ K, (r p.1 - r p.2)
      = (K.card : ℝ) * (∑ j ∈ D, r j) - (D.card : ℝ) * ∑ i ∈ K, r i := by
    simp only [Finset.sum_product, Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul]
    rw [← Finset.mul_sum]
  rw [hL] at hsum
  rw [hsplit, hcard]
  nlinarith [hsum, hpen]

/-! ## The discordance budget -/

/-- The **inversion set** of a dial `d` against the true rate `r` on `s`: the ordered
pairs `(j, i)` on which the dial says `j` is worse but the rate says `j` is better.
Its cardinality is the unnormalised Kendall discordance count. -/
noncomputable def discordantPairs (s : Finset ι) (d r : ι → ℝ) : Finset (ι × ι) :=
  (s ×ˢ s).filter (fun p => d p.1 < d p.2 ∧ r p.2 < r p.1)

/-- **The discordance budget for the skip-flip.**  Whatever the dial does, the yield
retained by a threshold skip falls short of the work-proportional amount by at most
`M` times the number of ranking inversions. -/
theorem retention_of_discordance {s : Finset ι} {d r : ι → ℝ} {M : ℝ} (hM : 0 ≤ M)
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) (hle : ∀ i ∈ s, r i ≤ M) (θ : ℝ) :
    ((keepSet s d θ).card : ℝ) * (∑ i ∈ s, r i)
      ≤ (s.card : ℝ) * (∑ i ∈ keepSet s d θ, r i)
        + M * (discordantPairs s d r).card := by
  refine sum_le_of_bounded_exceptions (keepSet_union_skipSet s d θ)
    (keepSet_disjoint_skipSet s d θ) hM hnonneg hle (discordantPairs s d r) ?_
  intro p hp hpE
  rw [Finset.mem_product] at hp
  obtain ⟨hp1, hp2⟩ := hp
  rw [skipSet, Finset.mem_filter] at hp1
  rw [keepSet, Finset.mem_filter] at hp2
  have hd : d p.1 < d p.2 := lt_of_lt_of_le (not_le.mp hp1.2) hp2.2
  by_contra hcon
  exact hpE (Finset.mem_filter.mpr ⟨Finset.mem_product.mpr ⟨hp1.1, hp2.1⟩,
    ⟨hd, not_le.mp hcon⟩⟩)

/-- Consistency: with no inversions the budget collapses to the exact concordant
statement of the previous cycle. -/
theorem retention_of_discordance_eq_concordant {s : Finset ι} {d r : ι → ℝ} {M : ℝ}
    (hM : 0 ≤ M) (hnonneg : ∀ i ∈ s, 0 ≤ r i) (hle : ∀ i ∈ s, r i ≤ M) (θ : ℝ)
    (hdisc : discordantPairs s d r = ∅) :
    ((keepSet s d θ).card : ℝ) * (∑ i ∈ s, r i)
      ≤ (s.card : ℝ) * ∑ i ∈ keepSet s d θ, r i := by
  have h := retention_of_discordance hM hnonneg hle (d := d) (r := r) (M := M) θ
  rw [hdisc] at h
  simpa using h

/-- **The throughput form.**  The yield per unit of work of the kept set is below the
global one by at most `M |Disc| / (|s| |K|)`: a dial with few inversions is a good skip
rule even if it is a poor regressor. -/
theorem throughput_le_of_discordance {s : Finset ι} {d r : ι → ℝ} {M : ℝ} (hM : 0 ≤ M)
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) (hle : ∀ i ∈ s, r i ≤ M) (θ : ℝ)
    (hK : (keepSet s d θ).Nonempty) (hs : s.Nonempty) :
    throughput s r
      ≤ throughput (keepSet s d θ) r
        + M * (discordantPairs s d r).card / ((s.card : ℝ) * (keepSet s d θ).card) := by
  have hkpos : (0:ℝ) < (keepSet s d θ).card := by
    exact_mod_cast Finset.card_pos.mpr hK
  have hspos : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  have h := retention_of_discordance hM hnonneg hle (d := d) (r := r) (M := M) θ
  rw [throughput, throughput, div_le_iff₀ hspos, add_mul, div_mul_eq_mul_div,
    div_mul_eq_mul_div, div_add_div _ _ (ne_of_gt hkpos) (by positivity),
    le_div_iff₀ (by positivity)]
  nlinarith [h, hkpos, hspos, mul_pos hspos hkpos]

/-! ## Lab notes: an explicit three-target instance

The rates `(1, 2, 5)` on three targets reproduce the qualitative shape of the measured
run: the inverse-rate policy loses about a third of the yield, the concentrator gains,
and skipping the single worst target retains `87.5%` of the relations for `66.7%` of the
work (measured: `89.5%` for `71.7%`).  All three are decided by `norm_num`, not asserted.
-/

/-- The lab-note rate vector: three targets with rates `1, 2, 5`. -/
def labRate : Fin 3 → ℝ := ![1, 2, 5]

/-- Lab note 1: with budget `3`, the uniform baseline yields `8` while the inverse-rate
policy yields `9 / 1.7 ≈ 5.29` — a loss of about `34%`, of the same sign as the
measured `-17.6%`. -/
theorem labnote_invRate_loses :
    yieldOf Finset.univ labRate (invRateAlloc Finset.univ labRate 3) < 6
      ∧ (6:ℝ) < yieldOf Finset.univ labRate (uniformAlloc Finset.univ 3) := by
  constructor
  · simp only [yieldOf, invRateAlloc, Fin.sum_univ_three]
    simp [labRate]
    norm_num
  · simp only [yieldOf, uniformAlloc, Fin.sum_univ_three]
    simp [labRate]
    norm_num

/-- Lab note 2: skipping the worst of the three targets retains `7/8` of the yield for
`2/3` of the work, so the throughput rises from `8/3` to `7/2`. -/
theorem labnote_skip_gain :
    throughput Finset.univ labRate < throughput ({1, 2} : Finset (Fin 3)) labRate := by
  have h1 : ∑ i ∈ (Finset.univ : Finset (Fin 3)), labRate i = 8 := by
    simp [Fin.sum_univ_three, labRate]
    norm_num
  have h2 : ∑ i ∈ ({1, 2} : Finset (Fin 3)), labRate i = 7 := by
    rw [Finset.sum_pair (by decide : (1 : Fin 3) ≠ 2)]
    simp [labRate]
    norm_num
  have hc1 : ((Finset.univ : Finset (Fin 3)).card : ℝ) = 3 := by simp
  have hc2n : (({1, 2} : Finset (Fin 3)).card) = 2 := by decide
  have hc2 : ((({1, 2} : Finset (Fin 3)).card : ℝ)) = 2 := by rw [hc2n]; norm_num
  rw [throughput, throughput, h1, h2, hc1, hc2]
  norm_num

/-- Lab note 3: the rate concentrator, with the same budget `3`, yields `15` — above the
uniform `8`, and equal to the oracle bound `B · max r`. -/
theorem labnote_concentrator_gain :
    yieldOf Finset.univ labRate (uniformAlloc Finset.univ 3)
      < yieldOf Finset.univ labRate (concAlloc (2 : Fin 3) 3) := by
  rw [conc_yield_eq (Finset.mem_univ _)]
  simp only [yieldOf, uniformAlloc, Fin.sum_univ_three]
  simp [labRate]
  norm_num

end Probability.AdaptiveQS