/-
# The counting median of any odd sample is its Fermat–Weber point

`Geometry.KneeFermatWeber` proves, for three points, that the median is the unique minimiser
of the total-distance functional.  This file removes the restriction to three points: for a
multiset `s` of **any** odd size `2k+1` in a linearly ordered abelian group, the counting
median `IsMedian k s m` of `Tropical.KneeMedian.MedianEquivariance` is the unique minimiser of

    `fwCost s t = Σ_{x ∈ s} |t - x|`.

The proof is the exact quantitative form of the counting definition: moving a distance `δ`
away from the median gains `δ` on every sample point on the near side and loses at most `δ`
on every point on the far side, and the median is precisely the value for which the near side
outnumbers the far side.  This yields the **sharp slope bound**

    `fwCost s m + |t - m| ≤ fwCost s t`,

from which minimality *and* uniqueness follow at once.

## Main results

* `sum_map_ite_const` — the bookkeeping lemma: a two-valued sum over a multiset splits as
  `#(filter p) • c + #(filter ¬p) • d`.
* `fwCost_slope_ge_right`, `fwCost_slope_ge_left` — the one-sided slope bounds.
* `isMedian_fwCost_le` — **the general Fermat–Weber theorem**: a counting median minimises the
  total distance for samples of any odd size.
* `isMedian_fwCost_lt_of_ne`, `isMedian_fwCost_unique` — the minimiser is unique, and any
  minimiser is *the* median.
* `fwCost_K16_min`, `fwCost_K8_min` — the measured NET-48 knee distributions: `224` and `112`
  minimise the total distance of the 16× and 8× three-seed samples, obtained by feeding the
  catalog's `isMedian_K16` / `isMedian_K8` into the general theorem.
-/
import Tropical.KneeMedian.NET48SeedLaws

namespace Catalog.Geometry.FermatWeberMedian

open Multiset Catalog.Tropical.KneeMedian

variable {α : Type*} [AddCommGroup α] [LinearOrder α] [IsOrderedAddMonoid α]

/-- The Fermat–Weber cost (total distance) of a candidate centre `t` against a sample `s`. -/
def fwCost (s : Multiset α) (t : α) : α := (s.map (fun x => |t - x|)).sum

/-- A two-valued sum over a multiset splits according to the filter cardinalities. -/
theorem sum_map_ite_const {β : Type*} [AddCommGroup β] (s : Multiset β) (p : β → Prop)
    [DecidablePred p] (c d : β) :
    (s.map (fun x => if p x then c else d)).sum
      = (card (s.filter p)) • c + (card (s.filter (fun x => ¬ p x))) • d := by
  induction s using Multiset.induction_on with
  | empty => simp
  | cons a s ih =>
      by_cases h : p a <;>
        simp [Multiset.filter_cons_of_pos, Multiset.filter_cons_of_neg, h, ih, succ_nsmul] <;>
        abel

/-- The two complementary filters of a sample have cardinalities summing to its size. -/
theorem card_filter_add_card_filter_not {β : Type*} (s : Multiset β) (p : β → Prop)
    [DecidablePred p] :
    card (s.filter p) + card (s.filter (fun x => ¬ p x)) = card s := by
  rw [← Multiset.card_add, Multiset.filter_add_not]

/-- **Slope bound to the right of the median.**  Moving from a median `m` up to `t` costs at
least the displacement `t - m`. -/
theorem fwCost_slope_ge_right {k : ℕ} {s : Multiset α} {m : α} (hcard : card s = 2 * k + 1)
    (h : IsMedian k s m) {t : α} (hmt : m ≤ t) :
    fwCost s m + (t - m) ≤ fwCost s t := by
  classical
  set A := card (s.filter (fun x => x ≤ m)) with hA
  set C := card (s.filter (fun x => ¬ x ≤ m)) with hC
  have hAC : A + C = 2 * k + 1 := by
    rw [hA, hC, card_filter_add_card_filter_not, hcard]
  have hAk : k + 1 ≤ A := h.lower
  have hCA : C + 1 ≤ A := by omega
  -- pointwise comparison
  have hpt : ∀ x ∈ s, |m - x| + (if x ≤ m then t - m else -(t - m)) ≤ |t - x| := by
    intro x _
    by_cases hx : x ≤ m
    · rw [if_pos hx, abs_of_nonneg (by simpa using sub_nonneg.mpr hx),
        abs_of_nonneg (by simpa using sub_nonneg.mpr (hx.trans hmt))]
      exact le_of_eq (by abel)
    · rw [if_neg hx]
      push_neg at hx
      rw [abs_of_nonpos (by simpa using sub_nonpos.mpr hx.le)]
      have hrw : -(m - x) + -(t - m) = -(t - x) := by abel
      rw [hrw]
      exact neg_le_abs _
  -- sum the pointwise comparison
  have hsum := Multiset.sum_map_le_sum_map
    (fun x : α => |m - x| + (if x ≤ m then t - m else -(t - m)))
    (fun x : α => |t - x|) hpt
  rw [Multiset.sum_map_add, sum_map_ite_const] at hsum
  have hmcost : (s.map (fun x : α => |m - x|)).sum = fwCost s m := rfl
  rw [hmcost] at hsum
  have hgain : (t - m) ≤ A • (t - m) + C • (-(t - m)) := by
    obtain ⟨r, hr⟩ : ∃ r : ℕ, A = C + (r + 1) := ⟨A - C - 1, by omega⟩
    rw [hr, add_nsmul, add_nsmul]
    have hnn : (0 : α) ≤ t - m := sub_nonneg.mpr hmt
    have hr0 : (0 : α) ≤ r • (t - m) := nsmul_nonneg hnn r
    have hCneg : C • (t - m) + C • (-(t - m)) = 0 := by
      rw [← nsmul_add]
      simp
    have hone : (1 : ℕ) • (t - m) = t - m := one_nsmul _
    have : C • (t - m) + (r • (t - m) + (1:ℕ) • (t - m)) + C • (-(t - m))
        = (C • (t - m) + C • (-(t - m))) + (r • (t - m) + (t - m)) := by
      rw [hone]; abel
    rw [this, hCneg]
    simp only [zero_add]
    exact le_add_of_nonneg_left hr0
  have hfw : fwCost s t = (s.map (fun x : α => |t - x|)).sum := rfl
  rw [hfw]
  exact le_trans (add_le_add (le_refl (fwCost s m)) hgain) hsum

/-- **Slope bound to the left of the median.** -/
theorem fwCost_slope_ge_left {k : ℕ} {s : Multiset α} {m : α} (hcard : card s = 2 * k + 1)
    (h : IsMedian k s m) {t : α} (htm : t ≤ m) :
    fwCost s m + (m - t) ≤ fwCost s t := by
  classical
  set A := card (s.filter (fun x => m ≤ x)) with hA
  set C := card (s.filter (fun x => ¬ m ≤ x)) with hC
  have hAC : A + C = 2 * k + 1 := by
    rw [hA, hC, card_filter_add_card_filter_not, hcard]
  have hAk : k + 1 ≤ A := h.upper
  have hCA : C + 1 ≤ A := by omega
  have hpt : ∀ x ∈ s, |m - x| + (if m ≤ x then m - t else -(m - t)) ≤ |t - x| := by
    intro x _
    by_cases hx : m ≤ x
    · rw [if_pos hx, abs_of_nonpos (by simpa using sub_nonpos.mpr hx),
        abs_of_nonpos (by simpa using sub_nonpos.mpr (htm.trans hx))]
      exact le_of_eq (by abel)
    · rw [if_neg hx]
      push_neg at hx
      rw [abs_of_nonneg (by simpa using sub_nonneg.mpr hx.le)]
      have h2 : t - x ≤ |t - x| := le_abs_self _
      have : m - x + -(m - t) = t - x := by abel
      rw [this]
      exact h2
  have hsum := Multiset.sum_map_le_sum_map
    (fun x : α => |m - x| + (if m ≤ x then m - t else -(m - t)))
    (fun x : α => |t - x|) hpt
  rw [Multiset.sum_map_add, sum_map_ite_const] at hsum
  have hmcost : (s.map (fun x : α => |m - x|)).sum = fwCost s m := rfl
  rw [hmcost] at hsum
  have hgain : (m - t) ≤ A • (m - t) + C • (-(m - t)) := by
    obtain ⟨r, hr⟩ : ∃ r : ℕ, A = C + (r + 1) := ⟨A - C - 1, by omega⟩
    rw [hr, add_nsmul, add_nsmul]
    have hnn : (0 : α) ≤ m - t := sub_nonneg.mpr htm
    have hr0 : (0 : α) ≤ r • (m - t) := nsmul_nonneg hnn r
    have hCneg : C • (m - t) + C • (-(m - t)) = 0 := by
      rw [← nsmul_add]
      simp
    have hone : (1 : ℕ) • (m - t) = m - t := one_nsmul _
    have : C • (m - t) + (r • (m - t) + (1:ℕ) • (m - t)) + C • (-(m - t))
        = (C • (m - t) + C • (-(m - t))) + (r • (m - t) + (m - t)) := by
      rw [hone]; abel
    rw [this, hCneg]
    simp only [zero_add]
    exact le_add_of_nonneg_left hr0
  have hfw : fwCost s t = (s.map (fun x : α => |t - x|)).sum := rfl
  rw [hfw]
  exact le_trans (add_le_add (le_refl (fwCost s m)) hgain) hsum

/-- **The general Fermat–Weber theorem for odd samples.**  The counting median minimises the
total distance to the sample, for a sample of any odd size in any linearly ordered abelian
group. -/
theorem isMedian_fwCost_le {k : ℕ} {s : Multiset α} {m : α} (hcard : card s = 2 * k + 1)
    (h : IsMedian k s m) (t : α) : fwCost s m ≤ fwCost s t := by
  rcases le_total m t with hmt | htm
  · exact le_trans (le_add_of_nonneg_right (sub_nonneg.mpr hmt))
      (fwCost_slope_ge_right hcard h hmt)
  · exact le_trans (le_add_of_nonneg_right (sub_nonneg.mpr htm))
      (fwCost_slope_ge_left hcard h htm)

/-- **Strict minimality.**  Any point other than the median has strictly larger cost: the
Fermat–Weber point of an odd sample is unique. -/
theorem isMedian_fwCost_lt_of_ne {k : ℕ} {s : Multiset α} {m : α} (hcard : card s = 2 * k + 1)
    (h : IsMedian k s m) {t : α} (hne : t ≠ m) : fwCost s m < fwCost s t := by
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · exact lt_of_lt_of_le (lt_add_of_pos_right _ (sub_pos.mpr hlt))
      (fwCost_slope_ge_left hcard h hlt.le)
  · exact lt_of_lt_of_le (lt_add_of_pos_right _ (sub_pos.mpr hgt))
      (fwCost_slope_ge_right hcard h hgt.le)

/-- Any minimiser of the total distance of an odd sample *is* the median. -/
theorem isMedian_fwCost_unique {k : ℕ} {s : Multiset α} {m t : α} (hcard : card s = 2 * k + 1)
    (h : IsMedian k s m) (hmin : ∀ u, fwCost s t ≤ fwCost s u) : t = m := by
  by_contra hne
  have h1 := isMedian_fwCost_lt_of_ne hcard h hne
  have h2 := hmin m
  exact absurd h1 (not_lt.mpr h2)

/-! ## The measured NET-48 samples -/

theorem card_K16 : card K16 = 2 * 1 + 1 := by decide

theorem card_K8 : card K8 = 2 * 1 + 1 := by decide

/-- The 16× knee sample `{160, 224, 256}`: its median `224 = (7/8)·256` minimises the total
distance, and is the only minimiser. -/
theorem fwCost_K16_min :
    (∀ t : ℚ, fwCost K16 224 ≤ fwCost K16 t) ∧ ∀ t : ℚ, t ≠ 224 → fwCost K16 224 < fwCost K16 t :=
  ⟨fun t => isMedian_fwCost_le card_K16 isMedian_K16 t,
    fun _ ht => isMedian_fwCost_lt_of_ne card_K16 isMedian_K16 ht⟩

/-- The 8× knee sample `{96, 112, 128}`: its median `112 = (7/8)·128` is the unique
minimiser. -/
theorem fwCost_K8_min :
    (∀ t : ℚ, fwCost K8 112 ≤ fwCost K8 t) ∧ ∀ t : ℚ, t ≠ 112 → fwCost K8 112 < fwCost K8 t :=
  ⟨fun t => isMedian_fwCost_le card_K8 isMedian_K8 t,
    fun _ ht => isMedian_fwCost_lt_of_ne card_K8 isMedian_K8 ht⟩

/-- The optimal costs are the spreads of the two samples, `96` and `32`. -/
theorem fwCost_values : fwCost K16 (224 : ℚ) = 96 ∧ fwCost K8 (112 : ℚ) = 32 := by
  constructor <;> · simp [fwCost, K16, K8]; norm_num [abs_of_nonneg, abs_of_nonpos]

end Catalog.Geometry.FermatWeberMedian