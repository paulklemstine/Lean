/-
# The low-tail experiment: what the fourth seed measures, and what it cannot measure

Round NET-48 leaves one open cell: a **fourth seed at `ctx = 2048`** (`d = 4`, product point
`P = d·ctx/32 = 256`).  The three recorded knees are `{256, 224, 160}`, with median
`224 = (7/8) P` and low tail `160 = (5/8) P`.  The pre-registered outcomes for the fourth
knee are `{160, 192, 224, 256}`, and the experiment plan claims:

> a fourth knee in `{160, 192}` establishes the `0.625 P` low tail as a stable feature of the
> `16×` cell, while a value in `{224, 256}` marks it seed-specific; strengthening the centre
> requires a fifth seed, since a fourth improves neither the breakdown number nor the
> calibration.

This file turns that plan into theorems.

## The tail bar

The natural separating threshold is the midpoint of the low tail and the centre,
`(5/8 P + 7/8 P)/2 = (3/4) P = 192` (`tailBar_is_midpoint`, `tailBar_eq_three_quarters`).
With that bar the pre-registered outcomes split exactly as announced.

## Main results

* `lowTailCount_eq`, `tailStable_iff` — the tail statistic of the four-seed ensemble is a
  threshold functional of the fourth seed: two seeds sit in the low tail iff `x ≤ 192`.
* `lowtail_experiment_dichotomy` — **the experiment, as pre-registered.**  On the announced
  outcome set the verdict is "stable" exactly for `{160, 192}` and "seed-specific" exactly
  for `{224, 256}`.
* `lowtail_experiment_is_one_bit` — the verdict is constant on each announced pair and
  differs across them: the fourth seed carries exactly one bit about the tail.
* `tail_not_a_function_of_fermatWeber_centre`, `tail_not_a_function_of_breakdown` —
  **diagnostic for the tail, not the centre.**  The two centre summaries (the Fermat–Weber
  optimality of `224`, from `Geometry.KneeFourthSeed`, and the finite-sample breakdown
  number, from `Physics.LowTailSeedBreakdown`) are *constant* across all four announced
  outcomes, so no function of either can reproduce the tail verdict.  The tail bit is
  logically independent of everything the centre records.
* `tail_stability_costs_calibration`, `no_outcome_both_confirms_and_calibrates` — **the
  trade-off.**  Every outcome that confirms the tail biases the four-seed reading by at
  least `16 = P/16`; confirmation and calibration are mutually exclusive at four seeds.
* `fifth_seed_reconciles` — with five seeds they are no longer exclusive: the ensemble
  `{256, 224, 160, 192, 224}` has a stable low tail, an exactly calibrated median rung
  `224 = (7/8) P`, and breakdown number `3`.  The fifth seed is what the plan says it is.
* `tail_stable_speedup_gain` — the physical payoff: a stable low tail certifies a majority
  budget of at most `(3/4) P`, i.e. an attention speed-up of at least `32/3` against the
  `8×` guaranteed by the product point.
-/
import Physics.LowTailSeedBreakdown
import Probability.SeedFourSeedMedian
import Geometry.KneeFourthSeed

namespace Catalog.Physics.LowTail

open Finset KneeMedian KneeQuota

/-! ## 1.  The tail bar -/

/-- The `16×` product point `P = d·ctx/32 = 256`. -/
def P16 : ℕ := 256

/-- The tail bar: the midpoint of the measured low tail `160 = (5/8) P` and the measured
centre `224 = (7/8) P`. -/
def tailBar : ℕ := 192

theorem tailBar_is_midpoint : 2 * tailBar = 160 + 224 := by norm_num [tailBar]

theorem tailBar_eq_three_quarters : 4 * tailBar = 3 * P16 := by norm_num [tailBar, P16]

theorem lowTail_eq_five_eighths : 8 * 160 = 5 * P16 := by norm_num [P16]

theorem centre_eq_seven_eighths : 8 * 224 = 7 * P16 := by norm_num [P16]

/-! ## 2.  The tail statistic of the four-seed ensemble -/

/-- The number of seeds of the four-seed ensemble whose knee lies in the low tail
`k ≤ (3/4) P`. -/
def lowTailCount (x : ℕ) : ℕ := (passSet (knees16four x) tailBar).card

/-- The tail statistic is a threshold functional of the fourth seed. -/
theorem lowTailCount_eq (x : ℕ) : lowTailCount x = if x ≤ tailBar then 2 else 1 := by
  rw [lowTailCount, card_passSet_knees16four]
  simp only [tailBar]
  split_ifs <;> omega

/-- The low tail is a *stable* feature of the cell if at least two of the four seeds land in
it. -/
def TailStable (x : ℕ) : Prop := 2 ≤ lowTailCount x

/-- The low tail is *replicated* if the fourth seed reproduces the recorded tail value
`160 = (5/8) P` itself. -/
def TailReplicated (x : ℕ) : Prop := x ≤ 160

theorem tailStable_iff (x : ℕ) : TailStable x ↔ x ≤ tailBar := by
  rw [TailStable, lowTailCount_eq]
  split_ifs with h
  · simp [h]
  · omega

theorem tailReplicated_imp_stable {x : ℕ} (h : TailReplicated x) : TailStable x :=
  (tailStable_iff x).2 (le_trans h (by norm_num [tailBar]))

instance (x : ℕ) : Decidable (TailStable x) := by
  rw [TailStable]; infer_instance

/-! ## 3.  The pre-registered experiment -/

/-- The four pre-registered outcomes for the fourth knee. -/
def prereg : Finset ℕ := {160, 192, 224, 256}

/-- **The low-tail experiment, as pre-registered.**  On the announced outcome set the tail
verdict is exactly the announced dichotomy: `{160, 192}` establishes the low tail as a stable
feature of the `16×` cell, `{224, 256}` marks it seed-specific. -/
theorem lowtail_experiment_dichotomy (x : ℕ) (hx : x ∈ prereg) :
    (TailStable x ↔ (x = 160 ∨ x = 192)) := by
  simp only [prereg, mem_insert, mem_singleton] at hx
  rw [tailStable_iff]
  rcases hx with rfl | rfl | rfl | rfl <;> simp [tailBar]

/-- **The experiment carries exactly one bit.**  The verdict is constant on each announced
pair and differs between them; in particular the run cannot distinguish a repeat of the
recorded tail value `160` from the intermediate rung `192`. -/
theorem lowtail_experiment_is_one_bit :
    (TailStable 160 ↔ TailStable 192) ∧ (¬ TailStable 224 ↔ ¬ TailStable 256) ∧
      (TailStable 160 ∧ ¬ TailStable 224) := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [tailStable_iff, tailBar]

/-- The tail statistic separates the two announced pairs, so the experiment is informative:
both verdicts are attainable. -/
theorem lowtail_experiment_informative :
    lowTailCount 160 = 2 ∧ lowTailCount 192 = 2 ∧ lowTailCount 224 = 1 ∧
      lowTailCount 256 = 1 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [lowTailCount_eq, tailBar]

/-- Only the exact repeat `x ≤ 160` replicates the recorded tail value; `192` gives tail
stability without replication.  The experiment therefore has a finer three-way reading than
its pre-registered two-way verdict. -/
theorem tail_three_way_reading (x : ℕ) (hx : x ∈ prereg) :
    (TailReplicated x ↔ x = 160) ∧ (TailStable x ∧ ¬ TailReplicated x ↔ x = 192) := by
  simp only [prereg, mem_insert, mem_singleton] at hx
  rcases hx with rfl | rfl | rfl | rfl <;>
    simp [TailReplicated, tailStable_iff, tailBar]

/-! ## 4.  Diagnostic for the tail, not the centre -/

/-- **Centre summary 1 is constant.**  For every announced outcome the `7/8` value `224` is a
Fermat–Weber point of the four-seed knee distribution (`Geometry.KneeFourthSeed`). -/
theorem centre_fermatWeber_constant (x : ℕ) :
    ∀ t : ℝ, Catalog.Geometry.KneeFourthSeed.cost16 (x : ℝ) 224 ≤
      Catalog.Geometry.KneeFourthSeed.cost16 (x : ℝ) t :=
  fun t => Catalog.Geometry.KneeFourthSeed.net48_fourth_seed_keeps_224 (x : ℝ) t

/-- **Centre summary 2 is constant.**  For every announced outcome the four-seed median has
breakdown number `2`, the breakdown number of the three-seed median. -/
theorem centre_breakdown_constant (x : ℕ) :
    breakdownNumber (knees4 (x : ℤ)) 2 = breakdownNumber knees3 2 :=
  fourth_seed_no_robustness_gain (x : ℤ)

/-- **The tail bit is not a function of the Fermat–Weber centre.**  No predictor, however
cleverly built out of the statement "`224` is an optimal centre of the four-seed sample", can
reproduce the tail verdict: that statement holds for every outcome, while the verdict does
not. -/
theorem tail_not_a_function_of_fermatWeber_centre :
    ¬ ∃ f : Prop → Bool, ∀ x ∈ prereg,
        f (∀ t : ℝ, Catalog.Geometry.KneeFourthSeed.cost16 (x : ℝ) 224 ≤
          Catalog.Geometry.KneeFourthSeed.cost16 (x : ℝ) t) = decide (TailStable x) := by
  rintro ⟨f, hf⟩
  have h160 := hf 160 (by simp [prereg])
  have h256 := hf 256 (by simp [prereg])
  have hprop : (∀ t : ℝ, Catalog.Geometry.KneeFourthSeed.cost16 ((160 : ℕ) : ℝ) 224 ≤
      Catalog.Geometry.KneeFourthSeed.cost16 ((160 : ℕ) : ℝ) t) =
      (∀ t : ℝ, Catalog.Geometry.KneeFourthSeed.cost16 ((256 : ℕ) : ℝ) 224 ≤
      Catalog.Geometry.KneeFourthSeed.cost16 ((256 : ℕ) : ℝ) t) :=
    propext ⟨fun _ => centre_fermatWeber_constant 256, fun _ => centre_fermatWeber_constant 160⟩
  rw [hprop, h256] at h160
  have hs : TailStable 160 := (tailStable_iff 160).2 (by norm_num [tailBar])
  have hns : ¬ TailStable 256 := by
    rw [tailStable_iff]; norm_num [tailBar]
  simp [hs, hns] at h160

/-- **The tail bit is not a function of the breakdown number either.**  The robustness
summary of the four-seed ensemble is the same for every announced outcome, so it cannot
predict the tail verdict. -/
theorem tail_not_a_function_of_breakdown :
    ¬ ∃ g : ℕ → Bool, ∀ x ∈ prereg,
        g (breakdownNumber (knees4 (x : ℤ)) 2) = decide (TailStable x) := by
  rintro ⟨g, hg⟩
  have h160 := hg 160 (by simp [prereg])
  have h256 := hg 256 (by simp [prereg])
  rw [centre_breakdown_constant 160] at h160
  rw [centre_breakdown_constant 256] at h256
  rw [h256] at h160
  have hs : TailStable 160 := (tailStable_iff 160).2 (by norm_num [tailBar])
  have hns : ¬ TailStable 256 := by
    rw [tailStable_iff]; norm_num [tailBar]
  simp [hs, hns] at h160

/-! ## 5.  Confirmation versus calibration -/

open SeedFourMedian in
/-- **Tail stability costs calibration.**  Any fourth seed that confirms the low tail biases
the four-seed reading away from the `7/8` value by at least `16 = P/16`. -/
theorem tail_stability_costs_calibration {x : ℕ} (h : TailStable x) : 16 ≤ bias x := by
  rw [tailStable_iff, tailBar] at h
  by_cases hx : x ≤ 160
  · rw [bias_of_le_160 hx]; norm_num
  · push_neg at hx
    rw [bias_of_low (by omega) (by omega)]
    have : (x : ℚ) ≤ 192 := by exact_mod_cast h
    linarith

open SeedFourMedian in
/-- **No four-seed outcome both confirms the tail and calibrates the centre.**  The two
objectives of the run are mutually exclusive at four seeds — the parity obstruction of
`Probability.SeedFourSeedMedian` in its sharpest form. -/
theorem no_outcome_both_confirms_and_calibrates (x : ℕ) : ¬ (TailStable x ∧ bias x = 0) := by
  rintro ⟨hs, hb⟩
  have := tail_stability_costs_calibration hs
  rw [hb] at this
  norm_num at this

/-! ## 6.  The fifth seed -/

/-- A five-seed ensemble: the three measured knees, a fourth seed and a fifth. -/
def knees16five (x y : ℕ) : Fin 5 → ℕ := ![256, 224, 160, x, y]

theorem card_passSet_five (K : Fin 5 → ℕ) (b : ℕ) :
    (passSet K b).card = (if K 0 ≤ b then 1 else 0) + (if K 1 ≤ b then 1 else 0) +
      (if K 2 ≤ b then 1 else 0) + (if K 3 ≤ b then 1 else 0) + (if K 4 ≤ b then 1 else 0) := by
  rw [passSet, card_filter, Fin.sum_univ_five]

theorem card_passSet_knees16five (x y b : ℕ) :
    (passSet (knees16five x y) b).card = (if 256 ≤ b then 1 else 0) + (if 224 ≤ b then 1 else 0) +
      (if 160 ≤ b then 1 else 0) + (if x ≤ b then 1 else 0) + (if y ≤ b then 1 else 0) := by
  rw [card_passSet_five]
  simp [knees16five]

/-- The median rung (quota `3` of `5`) of the reconciling five-seed ensemble is exactly the
`7/8` value. -/
theorem five_seed_median : quotaBudget (knees16five 192 224) 3 = 224 := by
  refine le_antisymm (quotaBudget_le_of_card ?_) ?_
  · rw [card_passSet_knees16five]; norm_num
  · have h := card_passSet_quotaBudget (K := knees16five 192 224) (m := 3) (by simp)
    rw [card_passSet_knees16five] at h
    revert h
    split_ifs <;> omega

/-- The reconciling five-seed ensemble still has two seeds in the low tail. -/
theorem five_seed_tail : (passSet (knees16five 192 224) tailBar).card = 2 := by
  rw [card_passSet_knees16five]
  norm_num [tailBar]

/-- **The fifth seed reconciles confirmation with calibration.**  The ensemble
`{256, 224, 160, 192, 224}` simultaneously (i) keeps two seeds in the low tail, (ii) reads
the median rung exactly at the `7/8` value `224` — zero bias, unlike every four-seed
ensemble, and (iii) raises the breakdown number to `3`, which no four-seed ensemble attains.
All three claims fail for four seeds: (i)∧(ii) by `no_outcome_both_confirms_and_calibrates`,
(iii) by `four_seed_no_rung_beats_three`. -/
theorem fifth_seed_reconciles :
    (passSet (knees16five 192 224) tailBar).card = 2 ∧
      quotaBudget (knees16five 192 224) 3 = 224 ∧
      breakdownNumber (knees5 192 224) 3 = 3 ∧
      ∀ x : ℤ, breakdownNumber (knees4 x) 2 < breakdownNumber (knees5 192 224) 3 :=
  ⟨five_seed_tail, five_seed_median, breakdown_five 192 224, fun x => by
    rw [breakdown_four x, breakdown_five]; omega⟩

/-! ## 7.  The physical payoff of a stable low tail -/

open KneeFluctuation in
/-- **Speed-up gain.**  If the fourth seed confirms the low tail then the majority (quota-2)
budget of the `16×` cell is at most `(3/4) P = 192`, so the attention speed-up certified for
a majority of seeds is at least `2048/192 = 32/3`, against the `8×` that the product point
`P = 256` guarantees for all seeds. -/
theorem tail_stable_speedup_gain {x : ℕ} (h : TailStable x) :
    quotaBudget (knees16four x) 2 ≤ tailBar ∧
      (32 : ℝ) / 3 ≤ speedup 2048 ((quotaBudget (knees16four x) 2 : ℕ) : ℝ) := by
  rw [tailStable_iff, tailBar] at h
  have hq : quotaBudget (knees16four x) 2 ≤ 192 := by
    rw [fourSeed_lower_median]; omega
  have hpos : (0 : ℝ) < ((quotaBudget (knees16four x) 2 : ℕ) : ℝ) := by
    have : 160 ≤ quotaBudget (knees16four x) 2 := by
      rw [fourSeed_lower_median]; omega
    have : (0 : ℕ) < quotaBudget (knees16four x) 2 := by omega
    exact_mod_cast this
  refine ⟨hq, ?_⟩
  have hle : ((quotaBudget (knees16four x) 2 : ℕ) : ℝ) ≤ 192 := by exact_mod_cast hq
  rw [speedup, le_div_iff₀ hpos]
  linarith

end Catalog.Physics.LowTail