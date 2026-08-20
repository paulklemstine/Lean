/-
# The NET-48 seed ensembles: what a fourth seed cannot buy

Applying `Physics.LowTailOrderStatistics` to the measured `16×` cell
(`d = 4`, `ctx = 2048`, product point `P = 256`, knee set `{160, 224, 256}` from seeds
1, 2, 3, median `224 = (7/8) P`, low tail `160 = (5/8) P`).

**Lab notes carried over (round NET-48, speed axis).**  `CausalTF`, `d_model = 64`, 4 heads,
Gutenberg word corpus, vocab 4097, held-out last 10 %, data-free top-`k` attention
truncation, bar `= 0.98` of full accuracy.  Seed 3 knee `160` with margin `0.001`; seeds 1
and 2 knees `256`, `224`.  The pre-registered fourth-seed outcomes are `{160, 192, 224, 256}`.

## Main results

* `isOStat_knees3_median` — the measured three-seed sample really has `224` as its lower
  median (order statistic `k = 2`), so the robustness statements below are about the actual
  data and not about an empty hypothesis.
* `median3_robust_to_one_seed` — one arbitrary seed (of three) cannot move the median
  outside the measured range `[160, 256]`.  This upgrades `KneeMedian.med3_breakdown` from
  `ℕ` to a genuine two-sided adversarial statement.
* `breakdown_three`, `breakdown_four`, `breakdown_five` — the breakdown numbers
  `2`, `2`, `3`.
* `fourth_seed_no_robustness_gain` — **the negative result.**  Whatever the fourth seed
  turns out to be, the four-seed lower median has exactly the breakdown number of the
  three-seed median.
* `four_seed_no_rung_beats_three` — stronger: *no* order statistic of a four-seed ensemble
  beats the three-seed median.  The failure is not a bad choice of estimator, it is a parity
  obstruction of the sample size.
* `fifth_seed_strict_gain` — a fifth seed does strictly increase the breakdown number.
* `median4_break_two_seeds` — the matching attack: two corrupted seeds out of four drive the
  reading below any bound.
-/
import Physics.LowTailOrderStatistics
import Logic.KneeQuotaScaling

namespace Catalog.Physics.LowTail

open Finset

/-! ## 1.  The measured samples, over `ℤ` -/

/-- The completed three-seed knee set at the `16×` cell, as an integer sample. -/
def knees3 : Fin 3 → ℤ := ![256, 224, 160]

/-- The three measured knees together with a pending fourth seed `x`. -/
def knees4 (x : ℤ) : Fin 4 → ℤ := ![256, 224, 160, x]

/-- The three measured knees together with two further seeds. -/
def knees5 (x y : ℤ) : Fin 5 → ℤ := ![256, 224, 160, x, y]

theorem countLE_fin3 (K : Fin 3 → ℤ) (w : ℤ) :
    countLE K w =
      (if K 0 ≤ w then 1 else 0) + (if K 1 ≤ w then 1 else 0) + (if K 2 ≤ w then 1 else 0) := by
  rw [countLE, card_filter, Fin.sum_univ_three]

/-- The measured three-seed median is the `7/8` value `224`, in the order-statistic sense
of `Physics.LowTailOrderStatistics`. -/
theorem isOStat_knees3_median : IsOStat knees3 2 224 := by
  constructor
  · rw [countLE_fin3]
    simp only [knees3, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Matrix.cons_val_two, Matrix.tail_cons]
    norm_num
  · intro w hw
    rw [countLE_fin3]
    simp only [knees3, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Matrix.cons_val_two, Matrix.tail_cons]
    split_ifs <;> omega

/-- The low tail `160 = (5/8) P` is the smallest measured knee: it is the first order
statistic of the three-seed sample. -/
theorem isOStat_knees3_min : IsOStat knees3 1 160 := by
  constructor
  · rw [countLE_fin3]
    simp only [knees3, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Matrix.cons_val_two, Matrix.tail_cons]
    norm_num
  · intro w hw
    rw [countLE_fin3]
    simp only [knees3, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Matrix.cons_val_two, Matrix.tail_cons]
    split_ifs <;> omega

theorem knees3_inf : (univ.inf' univ_nonempty knees3) = 160 := by
  have : (univ : Finset (Fin 3)) = {0, 1, 2} := by decide
  simp [this, knees3, inf'_insert]

theorem knees3_sup : (univ.sup' univ_nonempty knees3) = 256 := by
  have : (univ : Finset (Fin 3)) = {0, 1, 2} := by decide
  simp [this, knees3, sup'_insert]

/-! ## 2.  One corrupted seed out of three -/

/-- **The three-seed median survives one adversarial seed.**  If a single seed of the three
is replaced by an arbitrary integer knee — arbitrarily large or arbitrarily small — the
median of the corrupted ensemble still lies inside the measured window `[160, 256]`. -/
theorem median3_robust_to_one_seed {K' : Fin 3 → ℤ} {S : Finset (Fin 3)} (hS : S.card ≤ 1)
    (hagree : ∀ i ∉ S, knees3 i = K' i) {v : ℤ} (hv : IsOStat K' 2 v) :
    160 ≤ v ∧ v ≤ 256 := by
  have h := ostat_bounded_of_agree hagree hv (by omega) (by simp; omega)
  rw [knees3_inf, knees3_sup] at h
  exact h

/-! ## 3.  Breakdown numbers of the three ensembles -/

/-- Three seeds: two corrupted seeds are needed to make the median arbitrary. -/
theorem breakdown_three : breakdownNumber knees3 2 = 2 := by
  rw [breakdownNumber_eq knees3 (by omega) (by simp)]
  simp

/-- Four seeds: still two. -/
theorem breakdown_four (x : ℤ) : breakdownNumber (knees4 x) 2 = 2 := by
  rw [breakdownNumber_eq (knees4 x) (by omega) (by simp)]
  simp

/-- Five seeds: three. -/
theorem breakdown_five (x y : ℤ) : breakdownNumber (knees5 x y) 3 = 3 := by
  rw [breakdownNumber_eq (knees5 x y) (by omega) (by simp)]
  simp

/-- **The fourth seed buys no robustness.**  For every possible value of the pending fourth
seed the four-seed median has exactly the breakdown number of the three-seed median. -/
theorem fourth_seed_no_robustness_gain (x : ℤ) :
    breakdownNumber (knees4 x) 2 = breakdownNumber knees3 2 := by
  rw [breakdown_four, breakdown_three]

/-- **The fifth seed does.** -/
theorem fifth_seed_strict_gain (x y : ℤ) :
    breakdownNumber knees3 2 < breakdownNumber (knees5 x y) 3 := by
  rw [breakdown_three, breakdown_five]
  omega

/-- **No rung of a four-seed ensemble beats the three-seed median.**  The obstruction is not
a poor choice of quota: every order statistic of a four-point sample has breakdown number at
most `2`.  In particular the certified (all-seeds) budget, quota `4`, has breakdown number
`1`, matching `KneeQuota.quota_one_seed_breakdown`. -/
theorem four_seed_no_rung_beats_three (x : ℤ) {k : ℕ} (hk1 : 1 ≤ k) (hk : k ≤ 4) :
    breakdownNumber (knees4 x) k ≤ breakdownNumber knees3 2 := by
  rw [breakdown_three, breakdownNumber_eq (knees4 x) hk1 (by simpa using hk)]
  simp only [Fintype.card_fin]
  omega

/-- The certified budget of a four-seed ensemble collapses under a single corrupted seed. -/
theorem four_seed_certified_breakdown_one (x : ℤ) : breakdownNumber (knees4 x) 4 = 1 := by
  rw [breakdownNumber_eq (knees4 x) (by omega) (by simp)]
  simp

/-- **General ceiling.**  At sample size `n` no order statistic can have breakdown number
above `⌈n/2⌉`, and the lower median attains it.  With `lowerMedianBreakdown_even_eq_pred`
this says the whole four-seed design is dominated by the three-seed one. -/
theorem breakdownNumber_le_lowerMedianBreakdown {ι : Type*} [Fintype ι] [DecidableEq ι]
    [Nonempty ι] (K : ι → ℤ) {k : ℕ} (hk1 : 1 ≤ k) (hk : k ≤ Fintype.card ι) :
    breakdownNumber K k ≤ lowerMedianBreakdown (Fintype.card ι) := by
  rw [breakdownNumber_eq K hk1 hk, lowerMedianBreakdown]
  omega

/-! ## 4.  The matching attack on four seeds -/

/-- **Two corrupted seeds out of four suffice.**  For any target bound `B` there is a
corruption of two of the four seeds whose lower median falls below `B`.  Together with
`median3_robust_to_one_seed` this brackets the four-seed design exactly: robust to one,
destroyed by two — the same as three seeds. -/
theorem median4_break_two_seeds (x : ℤ) (B : ℤ) :
    ∃ (K' : Fin 4 → ℤ) (S : Finset (Fin 4)) (v : ℤ),
      S.card ≤ 2 ∧ (∀ i ∉ S, knees4 x i = K' i) ∧ IsOStat K' 2 v ∧ v < B := by
  have hcard : ({0, 1} : Finset (Fin 4)).card = 2 := by decide
  obtain ⟨K', v, hagree, hv, hlt⟩ :=
    ostat_break_down (knees4 x) (k := 2) (by omega) (by simp) ({0, 1} : Finset (Fin 4))
      (by omega) B
  exact ⟨K', {0, 1}, v, by omega, hagree, hv, hlt⟩

/-- **Three corrupted seeds are needed to push a four-seed median up.**  The design is
asymmetric: it is easier to fake an optimistic (low) budget than a pessimistic one.  Two
corrupted seeds can never raise the reading above the measured maximum `max 256 x`. -/
theorem median4_up_robust_to_two {x : ℤ} {K' : Fin 4 → ℤ} {S : Finset (Fin 4)}
    (hS : S.card ≤ 2) (hagree : ∀ i ∉ S, knees4 x i = K' i) {v : ℤ} (hv : IsOStat K' 2 v) :
    v ≤ univ.sup' univ_nonempty (knees4 x) := by
  have hcard : 2 + S.card ≤ Fintype.card (Fin 4) := by
    simp only [Fintype.card_fin]
    omega
  exact ostat_le_sup_of_agree hagree hv hcard

end Catalog.Physics.LowTail