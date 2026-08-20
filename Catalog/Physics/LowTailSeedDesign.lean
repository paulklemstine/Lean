/-
# How many seeds does the next round need?  (Cycle 4: the design laws)

Cycles 1–3 produced two robustness measures for the `16×` cell: the order-statistic
breakdown number of the centre (`Physics.LowTailOrderStatistics`) and the verdict breakdown
number of the tail bit (`Physics.LowTailVerdictRobustness`).  Both are now exact, so both can
be *inverted*: instead of asking how robust a given design is, we ask how large a design must
be to reach a prescribed robustness.  That is what an experiment plan actually needs.

## Main results

* `lowerMedianBreakdown_ge_iff`, `least_seeds_for_centre_robustness` — **the centre design
  law**: the least sample size whose median tolerates `r` corrupted seeds is `2r - 1`.  In
  particular `seeds_for_centre_robustness_two` (three seeds, already achieved) and
  `seeds_for_centre_robustness_three` (five seeds) — the fourth seed is provably wasted on
  the centre, and the fifth is provably enough.
* `verdict_robustness_iff` — **the tail design law**: a tail verdict with quota `m` tolerates
  `r` corrupted seeds exactly when the observed tail count is at least `m + r - 1`.
* `seeds_needed_for_tail_robustness` — the two laws combined with the *recorded* data: any
  ensemble that keeps the two recorded above-bar knees `256, 224` and whose tail verdict
  tolerates `r` corrupted seeds needs at least `m + r + 1` seeds.
* `net48_five_seeds_needed` — the concrete prediction for the next round: a majority tail
  verdict robust to one re-run seed requires at least **five** seeds, and five suffice
  (`fifth_seed_lifts_both`).  The fourth seed is diagnostic, the fifth is decisive.
-/
import Physics.LowTailFermatWeber

namespace Catalog.Physics.LowTail

open Finset

/-! ## 1.  The centre design law -/

/-- The centre design law, in inverted form. -/
theorem lowerMedianBreakdown_ge_iff (n r : ℕ) (hr : 1 ≤ r) :
    r ≤ lowerMedianBreakdown n ↔ 2 * r - 1 ≤ n := by
  unfold lowerMedianBreakdown
  omega

/-- **The least sample size whose lower median tolerates `r` corrupted seeds is `2r - 1`.** -/
theorem least_seeds_for_centre_robustness (r : ℕ) (hr : 1 ≤ r) :
    IsLeast {n : ℕ | r ≤ lowerMedianBreakdown n} (2 * r - 1) := by
  constructor
  · simpa [lowerMedianBreakdown] using (lowerMedianBreakdown_ge_iff (2 * r - 1) r hr).2 le_rfl
  · intro n hn
    exact (lowerMedianBreakdown_ge_iff n r hr).1 hn

/-- Three seeds are exactly what breakdown `2` costs — the design already in hand. -/
theorem seeds_for_centre_robustness_two : IsLeast {n : ℕ | 2 ≤ lowerMedianBreakdown n} 3 := by
  simpa using least_seeds_for_centre_robustness 2 (by norm_num)

/-- Breakdown `3` costs five seeds: the fourth cannot deliver it, the fifth can. -/
theorem seeds_for_centre_robustness_three : IsLeast {n : ℕ | 3 ≤ lowerMedianBreakdown n} 5 := by
  simpa using least_seeds_for_centre_robustness 3 (by norm_num)

/-- **The fourth seed is provably wasted on the centre.**  Four is not the least sample size
for any robustness level: whatever `r`, if four seeds achieve it then three already did. -/
theorem four_is_never_a_design_optimum (r : ℕ) (hr : 1 ≤ r) (h : r ≤ lowerMedianBreakdown 4) :
    r ≤ lowerMedianBreakdown 3 := by
  rw [lowerMedianBreakdown_ge_iff _ _ hr] at h ⊢
  omega

/-! ## 2.  The tail design law -/

section Tail

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- **The tail design law.**  A tail verdict that currently holds tolerates `r` corrupted
seeds exactly when its observed count exceeds the quota by at least `r - 1`. -/
theorem verdict_robustness_iff {K : ι → ℤ} {τ : ℤ} {m r : ℕ} (hm : 1 ≤ m)
    (hV : TailVerdict K τ m) : r ≤ verdictBreakdown K τ m ↔ m + r ≤ countLE K τ + 1 := by
  rw [verdictBreakdown_of_true hm hV]
  rw [TailVerdict] at hV
  omega

/-- **Seeds needed for a robust tail verdict.**  If `S` is a set of seeds recorded *above*
the bar and the tail verdict with quota `m` tolerates `r` corruptions, the ensemble must have
at least `m + r - 1 + #S` seeds: the tail seeds and the above-bar seeds are disjoint
populations. -/
theorem seeds_needed_for_tail_robustness {K : ι → ℤ} {τ : ℤ} {m r : ℕ} {S : Finset ι}
    (hm : 1 ≤ m) (hV : TailVerdict K τ m) (hS : ∀ i ∈ S, τ < K i)
    (hrob : r ≤ verdictBreakdown K τ m) : m + r - 1 + S.card ≤ Fintype.card ι := by
  classical
  have hcount : m + r ≤ countLE K τ + 1 := (verdict_robustness_iff hm hV).1 hrob
  have hdisj : Disjoint (univ.filter (fun i => K i ≤ τ)) S := by
    refine disjoint_left.2 fun i hi hiS => ?_
    simp only [mem_filter, mem_univ, true_and] at hi
    exact absurd (hS i hiS) (not_lt.2 hi)
  have hle : countLE K τ + S.card ≤ Fintype.card ι := by
    have := card_le_univ ((univ.filter (fun i => K i ≤ τ)) ∪ S)
    rw [card_union_of_disjoint hdisj] at this
    simpa [countLE] using this
  omega

end Tail

/-! ## 3.  The prediction for the next round -/

/-- The two recorded above-bar seeds of the `16×` cell: seeds 1 and 2, with knees `256` and
`224`, both above the tail bar `192`. -/
theorem knees4_above_bar (x : ℤ) : ∀ i ∈ ({0, 1} : Finset (Fin 4)), (192 : ℤ) < knees4 x i := by
  intro i hi
  fin_cases hi <;> norm_num [knees4]

/-- **The concrete design prediction.**  A four-seed ensemble that keeps the two recorded
above-bar knees cannot support a tail verdict robust to even one re-run seed: robustness `2`
would force at least five seeds.  Five seeds do support it (`fifth_seed_lifts_both`), so the
next round must be a fifth seed, exactly as the experiment plan asserts for the centre — and
now for the tail as well. -/
theorem net48_five_seeds_needed {x : ℤ} (hx : x ≤ 192) :
    ¬ (2 ≤ verdictBreakdown (knees4 x) 192 2) := by
  intro hrob
  have hV : TailVerdict (knees4 x) 192 2 := by
    rw [TailVerdict, countLE_knees4 hx]
  have h := seeds_needed_for_tail_robustness (m := 2) (r := 2) (S := ({0, 1} : Finset (Fin 4)))
    (by norm_num) hV (knees4_above_bar x) hrob
  have hcard : ({0, 1} : Finset (Fin 4)).card = 2 := by decide
  rw [hcard] at h
  simp only [Fintype.card_fin] at h
  omega

/-- **Five seeds suffice, and are the least that do.**  The reconciling ensemble
`{256, 224, 160, 192, 160}` attains tail-verdict robustness `2` and centre breakdown `3`;
by `net48_five_seeds_needed` and `seeds_for_centre_robustness_three` neither is attainable at
four.  This is the complete answer to "what should the next round run?". -/
theorem net48_design_conclusion :
    (2 ≤ verdictBreakdown (knees5 192 160) 192 2) ∧
      (3 ≤ breakdownNumber (knees5 192 160) 3) ∧
      (∀ x : ℤ, x ≤ 192 → verdictBreakdown (knees4 x) 192 2 < 2) ∧
      (∀ x : ℤ, breakdownNumber (knees4 x) 2 < 3) := by
  obtain ⟨h5tail, h5centre, -⟩ := fifth_seed_lifts_both
  refine ⟨by omega, by omega, fun x hx => ?_, fun x => ?_⟩
  · rw [tail_verdict_four_breakdown hx]; omega
  · rw [breakdown_four]; omega

end Catalog.Physics.LowTail