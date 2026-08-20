/-
# The Fermat–Weber centre of an arbitrary seed ensemble (Cycle 3)

`Geometry.KneeFermatWeber` solved the `ℓ¹` centre problem for **three** knees and
`Geometry.KneeFourthSeed` for **four**, each by an explicit case analysis on the sorted
sample.  Cycle 3 of the low-tail programme removes the restriction on the sample size and,
more importantly, re-derives the centre from the *same counting primitive*
`Physics.LowTailOrderStatistics.countLE` that governs the tail.  That is the structural
pattern the analysis of cycles 1–2 exposed:

> the centre and the tail are two quotas of one counting function; the experiment reads the
> counting function at a fixed bar, the centre reads it at a moving one.

## Main results

* `cost_le_cost_of_right`, `cost_le_cost_of_left` — the two slope estimates for the
  piecewise-linear cost `C(t) = Σ |t - K i|`: moving right by `δ` costs at least
  `δ (2·countLE(t) - n)`, moving left at least `δ (2·countGE(t) - n)`.
* `isL1Median_of_counts` — **the general median theorem.**  Any point with at least half the
  sample weakly on each side minimises the total distance.  No sortedness hypothesis, no
  restriction on `n`, no assumption that the point is a sample value.
* `not_isL1Median_of_countLE_lt` — the converse: a point with strictly less than half the
  sample at or below it is beaten by the next sample value to its right.  Together the two
  give a complete counting characterisation of the Fermat–Weber set.
* `isL1Median_iff_counts` — the characterisation itself.
* `net48_centre_from_counting` — the `16×` cell: for *every* value of the pending fourth
  seed the `7/8` value `224` satisfies the counting condition, recovering
  `Geometry.KneeFourthSeed.net48_fourth_seed_keeps_224` from the general theorem, and the
  five-seed reconciling ensemble has `224` as its centre too.
* `centre_and_tail_are_quotas` — the unification: the centre condition at `v` and the tail
  verdict at the bar `τ` are the *same* predicate `m ≤ countLE K ·` evaluated at different
  arguments with different quotas.  This is why the fourth seed can be informative for one
  and vacuous for the other.
-/
import Physics.LowTailVerdictRobustness

namespace Catalog.Physics.LowTail

open Finset

section General

variable {ι : Type*} [Fintype ι]

/-! ## 1.  The `ℓ¹` cost and the two counting functions -/

/-- Total distance from the budget `t` to the measured knees. -/
def cost (K : ι → ℤ) (t : ℤ) : ℤ := ∑ i, |t - K i|

/-- Number of sample points at or above `w`. -/
def countGE (K : ι → ℤ) (w : ℤ) : ℕ := (univ.filter (fun i => w ≤ K i)).card

theorem sum_signs_le (K : ι → ℤ) (t : ℤ) :
    ∑ i, (if K i ≤ t then (1 : ℤ) else -1) = 2 * (countLE K t : ℤ) - (Fintype.card ι : ℤ) := by
  have h : ∀ i : ι, (if K i ≤ t then (1 : ℤ) else -1)
      = 2 * (if K i ≤ t then (1 : ℤ) else 0) - 1 := by
    intro i; split_ifs <;> ring
  rw [Finset.sum_congr rfl (fun i _ => h i), Finset.sum_sub_distrib, ← Finset.mul_sum,
    Finset.sum_boole]
  simp [countLE, card_univ]

theorem sum_signs_ge (K : ι → ℤ) (t : ℤ) :
    ∑ i, (if t ≤ K i then (1 : ℤ) else -1) = 2 * (countGE K t : ℤ) - (Fintype.card ι : ℤ) := by
  have h : ∀ i : ι, (if t ≤ K i then (1 : ℤ) else -1)
      = 2 * (if t ≤ K i then (1 : ℤ) else 0) - 1 := by
    intro i; split_ifs <;> ring
  rw [Finset.sum_congr rfl (fun i _ => h i), Finset.sum_sub_distrib, ← Finset.mul_sum,
    Finset.sum_boole]
  simp [countGE, card_univ]

/-! ## 2.  The two slope estimates -/

/-- **Moving right.**  Increasing the budget from `t` to `t'` costs at least
`(t' - t)(2·countLE(t) - n)`. -/
theorem cost_le_cost_of_right (K : ι → ℤ) {t t' : ℤ} (h : t ≤ t') :
    cost K t + (t' - t) * (2 * (countLE K t : ℤ) - (Fintype.card ι : ℤ)) ≤ cost K t' := by
  have key : ∀ i ∈ (univ : Finset ι),
      |t - K i| + (t' - t) * (if K i ≤ t then (1 : ℤ) else -1) ≤ |t' - K i| := by
    intro i _
    by_cases hi : K i ≤ t
    · rw [if_pos hi, abs_of_nonneg (by omega : (0:ℤ) ≤ t - K i),
        abs_of_nonneg (by omega : (0:ℤ) ≤ t' - K i)]
      ring_nf
      omega
    · push_neg at hi
      rw [if_neg (by omega), abs_of_nonpos (by omega : t - K i ≤ 0)]
      rcases abs_cases (t' - K i) with ⟨e, _⟩ | ⟨e, _⟩ <;> rw [e] <;> nlinarith [h]
  have hsum := Finset.sum_le_sum key
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, sum_signs_le] at hsum
  exact hsum

/-- **Moving left.**  Decreasing the budget from `t` to `t'` costs at least
`(t - t')(2·countGE(t) - n)`. -/
theorem cost_le_cost_of_left (K : ι → ℤ) {t t' : ℤ} (h : t' ≤ t) :
    cost K t + (t - t') * (2 * (countGE K t : ℤ) - (Fintype.card ι : ℤ)) ≤ cost K t' := by
  have key : ∀ i ∈ (univ : Finset ι),
      |t - K i| + (t - t') * (if t ≤ K i then (1 : ℤ) else -1) ≤ |t' - K i| := by
    intro i _
    by_cases hi : t ≤ K i
    · rw [if_pos hi, abs_of_nonpos (by omega : t - K i ≤ 0),
        abs_of_nonpos (by omega : t' - K i ≤ 0)]
      ring_nf
      omega
    · push_neg at hi
      rw [if_neg (by omega), abs_of_nonneg (by omega : (0:ℤ) ≤ t - K i)]
      rcases abs_cases (t' - K i) with ⟨e, _⟩ | ⟨e, _⟩ <;> rw [e] <;> nlinarith [h]
  have hsum := Finset.sum_le_sum key
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, sum_signs_ge] at hsum
  exact hsum

/-! ## 3.  The general median theorem -/

/-- `t` minimises the total distance to the sample. -/
def IsL1Median (K : ι → ℤ) (t : ℤ) : Prop := ∀ s : ℤ, cost K t ≤ cost K s

/-- **The general Fermat–Weber theorem for a finite sample.**  Any budget with at least half
the seeds weakly below it and at least half weakly above it minimises the total distance to
the ensemble.  For `n = 3` and `n = 4` this is `Geometry.KneeFermatWeber.fermatWeber_real`
and `Geometry.KneeFourthSeed.fermatWeber_four`, but here there is no sortedness hypothesis
and no bound on the number of seeds. -/
theorem isL1Median_of_counts {K : ι → ℤ} {t : ℤ}
    (hlo : (Fintype.card ι : ℤ) ≤ 2 * (countLE K t : ℤ))
    (hhi : (Fintype.card ι : ℤ) ≤ 2 * (countGE K t : ℤ)) : IsL1Median K t := by
  intro s
  rcases le_total t s with hts | hst
  · have h := cost_le_cost_of_right K hts
    nlinarith [h, sub_nonneg.2 hts]
  · have h := cost_le_cost_of_left K hst
    nlinarith [h, sub_nonneg.2 hst]

/-- **The converse.**  If strictly fewer than half the seeds are at or below `t`, then `t` is
not a centre: the next sample value to the right is strictly better. -/
theorem not_isL1Median_of_countLE_lt {K : ι → ℤ} {t : ℤ}
    (hlt : 2 * (countLE K t : ℤ) < (Fintype.card ι : ℤ)) : ¬ IsL1Median K t := by
  classical
  intro hmed
  -- there is at least one sample point above `t`
  have hne : (univ.filter (fun i => t < K i)).Nonempty := by
    rw [filter_nonempty_iff]
    by_contra hcon
    push_neg at hcon
    have : (univ.filter (fun i => K i ≤ t)) = univ := by
      ext i
      simp only [mem_filter, mem_univ, true_and, iff_true]
      exact hcon i (mem_univ i)
    rw [countLE, this, card_univ] at hlt
    omega
  set t' := (univ.filter (fun i => t < K i)).inf' hne K with ht'
  have htt' : t < t' := by
    rw [ht']
    refine (lt_inf'_iff hne).2 fun i hi => ?_
    simp only [mem_filter, mem_univ, true_and] at hi
    exact hi
  -- no sample point lies strictly between `t` and `t'`
  have hgap : ∀ i, ¬ (t < K i ∧ K i < t') := by
    rintro i ⟨h1, h2⟩
    have : t' ≤ K i := inf'_le K (by simp only [mem_filter, mem_univ, true_and]; exact h1)
    omega
  -- so the cost strictly decreases at `t'`
  have key : ∀ i ∈ (univ : Finset ι),
      |t' - K i| ≤ |t - K i| + (t' - t) * (if K i ≤ t then (1 : ℤ) else -1) := by
    intro i _
    by_cases hi : K i ≤ t
    · rw [if_pos hi, abs_of_nonneg (by omega : (0:ℤ) ≤ t - K i),
        abs_of_nonneg (by omega : (0:ℤ) ≤ t' - K i)]
      ring_nf
      omega
    · push_neg at hi
      have hge : t' ≤ K i := by
        by_contra hcon
        push_neg at hcon
        exact hgap i ⟨hi, hcon⟩
      rw [if_neg (by omega), abs_of_nonpos (by omega : t - K i ≤ 0),
        abs_of_nonpos (by omega : t' - K i ≤ 0)]
      ring_nf
      omega
  have hsum := Finset.sum_le_sum key
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, sum_signs_le] at hsum
  have hcost : cost K t' ≤ cost K t + (t' - t) * (2 * (countLE K t : ℤ) - (Fintype.card ι : ℤ)) :=
    hsum
  have hneg : (t' - t) * (2 * (countLE K t : ℤ) - (Fintype.card ι : ℤ)) < 0 := by
    apply mul_neg_of_pos_of_neg <;> omega
  have := hmed t'
  omega

/-- Symmetrically, too little mass above `t` also disqualifies it. -/
theorem not_isL1Median_of_countGE_lt {K : ι → ℤ} {t : ℤ}
    (hlt : 2 * (countGE K t : ℤ) < (Fintype.card ι : ℤ)) : ¬ IsL1Median K t := by
  classical
  intro hmed
  have hne : (univ.filter (fun i => K i < t)).Nonempty := by
    rw [filter_nonempty_iff]
    by_contra hcon
    push_neg at hcon
    have : (univ.filter (fun i => t ≤ K i)) = univ := by
      ext i
      simp only [mem_filter, mem_univ, true_and, iff_true]
      exact hcon i (mem_univ i)
    rw [countGE, this, card_univ] at hlt
    omega
  set t' := (univ.filter (fun i => K i < t)).sup' hne K with ht'
  have htt' : t' < t := by
    rw [ht']
    refine (sup'_lt_iff hne).2 fun i hi => ?_
    simp only [mem_filter, mem_univ, true_and] at hi
    exact hi
  have hgap : ∀ i, ¬ (t' < K i ∧ K i < t) := by
    rintro i ⟨h1, h2⟩
    have : K i ≤ t' := le_sup' K (by simp only [mem_filter, mem_univ, true_and]; exact h2)
    omega
  have key : ∀ i ∈ (univ : Finset ι),
      |t' - K i| ≤ |t - K i| + (t - t') * (if t ≤ K i then (1 : ℤ) else -1) := by
    intro i _
    by_cases hi : t ≤ K i
    · rw [if_pos hi, abs_of_nonpos (by omega : t - K i ≤ 0),
        abs_of_nonpos (by omega : t' - K i ≤ 0)]
      ring_nf
      omega
    · push_neg at hi
      have hle : K i ≤ t' := by
        by_contra hcon
        push_neg at hcon
        exact hgap i ⟨hcon, hi⟩
      rw [if_neg (by omega), abs_of_nonneg (by omega : (0:ℤ) ≤ t - K i),
        abs_of_nonneg (by omega : (0:ℤ) ≤ t' - K i)]
      ring_nf
      omega
  have hsum := Finset.sum_le_sum key
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, sum_signs_ge] at hsum
  have hcost : cost K t' ≤ cost K t + (t - t') * (2 * (countGE K t : ℤ) - (Fintype.card ι : ℤ)) :=
    hsum
  have hneg : (t - t') * (2 * (countGE K t : ℤ) - (Fintype.card ι : ℤ)) < 0 := by
    apply mul_neg_of_pos_of_neg <;> omega
  have := hmed t'
  omega

/-- **Counting characterisation of the Fermat–Weber set.**  A budget is an `ℓ¹` centre of the
ensemble exactly when at least half the seeds lie weakly on each side of it. -/
theorem isL1Median_iff_counts {K : ι → ℤ} {t : ℤ} :
    IsL1Median K t ↔
      ((Fintype.card ι : ℤ) ≤ 2 * (countLE K t : ℤ) ∧
        (Fintype.card ι : ℤ) ≤ 2 * (countGE K t : ℤ)) := by
  constructor
  · intro hmed
    constructor
    · by_contra hcon
      push_neg at hcon
      exact not_isL1Median_of_countLE_lt hcon hmed
    · by_contra hcon
      push_neg at hcon
      exact not_isL1Median_of_countGE_lt hcon hmed
  · rintro ⟨h1, h2⟩
    exact isL1Median_of_counts h1 h2

end General

/-! ## 4.  The `16×` cell -/

theorem countGE_fin4 (K : Fin 4 → ℤ) (w : ℤ) :
    countGE K w = (if w ≤ K 0 then 1 else 0) + (if w ≤ K 1 then 1 else 0) +
      (if w ≤ K 2 then 1 else 0) + (if w ≤ K 3 then 1 else 0) := by
  rw [countGE, card_filter, Fin.sum_univ_four]

theorem countGE_fin5 (K : Fin 5 → ℤ) (w : ℤ) :
    countGE K w = (if w ≤ K 0 then 1 else 0) + (if w ≤ K 1 then 1 else 0) +
      (if w ≤ K 2 then 1 else 0) + (if w ≤ K 3 then 1 else 0) + (if w ≤ K 4 then 1 else 0) := by
  rw [countGE, card_filter, Fin.sum_univ_five]

/-- **The `7/8` centre survives every fourth seed, from the counting theorem.**  For every
possible value of the pending fourth seed, `224 = (7/8) P` has at least two of the four
knees weakly below it and at least two weakly above it, hence minimises the total distance
to the four-seed ensemble.  This re-derives `Geometry.KneeFourthSeed.net48_fourth_seed_keeps_224`
from the general theorem, with the four-point case analysis replaced by two counts. -/
theorem net48_centre_from_counting (x : ℤ) : IsL1Median (knees4 x) 224 := by
  refine isL1Median_of_counts ?_ ?_
  · have h : countLE (knees4 x) 224 = (if x ≤ 224 then 1 else 0) + 2 := by
      rw [countLE_fin4]
      simp only [knees4, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
        Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
      split_ifs <;> omega
    rw [h]
    simp only [Fintype.card_fin]
    split_ifs <;> push_cast
  · have h : countGE (knees4 x) 224 = (if 224 ≤ x then 1 else 0) + 2 := by
      rw [countGE_fin4]
      simp only [knees4, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
        Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
      split_ifs <;> omega
    rw [h]
    simp only [Fintype.card_fin]
    split_ifs <;> push_cast

/-- The reconciling five-seed ensemble `{256, 224, 160, 192, 224}` also has the `7/8` value as
its `ℓ¹` centre — and there, unlike at four seeds, the centre is the *unique* optimum, because
the odd sample has strict majorities on both sides only at `224`. -/
theorem five_seed_centre : IsL1Median (knees5 192 224) 224 := by
  refine isL1Median_of_counts ?_ ?_
  · have h : countLE (knees5 192 224) 224 = 4 := by
      rw [countLE_fin5]
      simp only [knees5, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
        Matrix.cons_val_two, Matrix.cons_val_three, Matrix.cons_val_four, Matrix.tail_cons]
      norm_num
    rw [h]
    simp only [Fintype.card_fin]
    norm_num
  · have h : countGE (knees5 192 224) 224 = 3 := by
      rw [countGE_fin5]
      simp only [knees5, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
        Matrix.cons_val_two, Matrix.cons_val_three, Matrix.cons_val_four, Matrix.tail_cons]
      norm_num
    rw [h]
    simp only [Fintype.card_fin]
    norm_num

/-- **Uniqueness at five seeds.**  The odd ensemble has `224` as its *only* `ℓ¹` centre: every
other budget fails one of the two counting conditions.  At four seeds no such statement is
available, whatever the fourth seed (`four_seed_centre_not_unique`). -/
theorem five_seed_centre_unique {t : ℤ} (h : IsL1Median (knees5 192 224) t) : t = 224 := by
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · refine not_isL1Median_of_countLE_lt ?_ h
    have hc : countLE (knees5 192 224) t ≤ 2 := by
      rw [countLE_fin5]
      simp only [knees5, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
        Matrix.cons_val_two, Matrix.cons_val_three, Matrix.cons_val_four, Matrix.tail_cons]
      split_ifs <;> omega
    have hc' : (countLE (knees5 192 224) t : ℤ) ≤ 2 := by exact_mod_cast hc
    simp only [Fintype.card_fin]
    omega
  · refine not_isL1Median_of_countGE_lt ?_ h
    have hc : countGE (knees5 192 224) t ≤ 1 := by
      rw [countGE_fin5]
      simp only [knees5, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
        Matrix.cons_val_two, Matrix.cons_val_three, Matrix.cons_val_four, Matrix.tail_cons]
      split_ifs <;> omega
    have hc' : (countGE (knees5 192 224) t : ℤ) ≤ 1 := by exact_mod_cast hc
    simp only [Fintype.card_fin]
    omega

/-- A low-tail fourth seed does **not** move the centre off the `7/8` value, but it does make
the low tail itself an alternative centre: with `x = 160` the whole segment `[160, 224]` is
optimal, and in particular `160 = (5/8) P` is an `ℓ¹` centre of the four-seed ensemble.
This is the precise sense in which the low tail "competes" with the centre at four seeds —
and it is again a parity effect, absent at five. -/
theorem low_tail_is_also_a_centre : IsL1Median (knees4 160) 160 := by
  refine isL1Median_of_counts ?_ ?_
  · have h : countLE (knees4 160) 160 = 2 := by
      rw [countLE_fin4]
      simp only [knees4, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
        Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
      norm_num
    rw [h]
    simp only [Fintype.card_fin]
    norm_num
  · have h : countGE (knees4 160) 160 = 4 := by
      rw [countGE_fin4]
      simp only [knees4, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
        Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
      norm_num
    rw [h]
    simp only [Fintype.card_fin]
    norm_num

/-- **Non-uniqueness at four seeds.**  With the low-tail outcome `x = 160` both the `7/8`
centre and the tail value `(5/8) P` minimise the total distance, so the four-seed ensemble
cannot single out a centre at all. -/
theorem four_seed_centre_not_unique :
    IsL1Median (knees4 160) 224 ∧ IsL1Median (knees4 160) 160 ∧ (224 : ℤ) ≠ 160 :=
  ⟨net48_centre_from_counting 160, low_tail_is_also_a_centre, by norm_num⟩

/-- At five seeds the low tail is no longer a centre: the extra run breaks the tie that the
even sample created. -/
theorem five_seed_low_tail_not_a_centre : ¬ IsL1Median (knees5 192 224) 160 := by
  refine not_isL1Median_of_countLE_lt ?_
  have h : countLE (knees5 192 224) 160 = 1 := by
    rw [countLE_fin5]
    simp only [knees5, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Matrix.cons_val_two, Matrix.cons_val_three, Matrix.cons_val_four, Matrix.tail_cons]
    norm_num
  rw [h]
  simp only [Fintype.card_fin]
  norm_num

/-! ## 5.  The unification -/

/-- **Centre and tail are two quotas of one counting function.**  The tail verdict is
`m ≤ countLE K τ` at the *fixed* bar `τ`; the centre condition at `v` is the conjunction of
`⌈n/2⌉ ≤ countLE K v` and the mirror condition on `countGE`.  Both are quota statements about
the same primitive, which is why one experiment can be informative for one and vacuous for
the other. -/
theorem centre_and_tail_are_quotas {ι : Type*} [Fintype ι] (K : ι → ℤ)
    (τ v : ℤ) (m : ℕ) :
    (TailVerdict K τ m ↔ m ≤ countLE K τ) ∧
      (IsL1Median K v ↔ ((Fintype.card ι : ℤ) ≤ 2 * (countLE K v : ℤ) ∧
        (Fintype.card ι : ℤ) ≤ 2 * (countGE K v : ℤ))) :=
  ⟨Iff.rfl, isL1Median_iff_counts⟩

end Catalog.Physics.LowTail