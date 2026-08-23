/-
# A concrete equivariant estimator attaining the breakdown ceiling

`Computation.MedianBreakdown` computed the breakdown number of the *median as a
set-valued notion* (`MedianBounded`), and `Computation.MedianBreakdownOptimality`
proved the universal ceiling `⌈n/2⌉` for translation-equivariant estimators.
A critic can still object: the ceiling is only interesting if some *bona fide
single-valued* equivariant estimator attains it.

This file removes that objection.  We build the **lower sample median**
`lowerMedian`, a genuine function `List ℚ → ℚ`, and prove

* `isMedian_lowerMedian` — it really is a median (an order-statistic argument on
  the sorted sample),
* `lowerMedian_equivariant` — it is translation equivariant (sorting commutes
  with an order isomorphism, via uniqueness of sorted permutations),
* `lowerMedian_breakdownNumber` — its breakdown number is exactly `⌈n/2⌉`, so it
  attains the ceiling of `breakdownNumber_le`.

The results are then instantiated on the two measured normalised distributions.
-/
import Mathlib
import Computation.MedianBreakdown
import Computation.MedianBreakdownOptimality

namespace MedianBreakdown

/-! ## 1. Sorting the sample -/

/-- Boolean order used for sorting rational samples. -/
def sortLe (a b : ℚ) : Bool := decide (a ≤ b)

/-- The sample sorted in non-decreasing order. -/
def sortedList (xs : List ℚ) : List ℚ := xs.mergeSort sortLe

lemma sortedList_perm (xs : List ℚ) : (sortedList xs).Perm xs :=
  List.mergeSort_perm xs sortLe

lemma length_sortedList (xs : List ℚ) : (sortedList xs).length = xs.length :=
  (sortedList_perm xs).length_eq

lemma sortedList_pairwise (xs : List ℚ) :
    List.Pairwise (fun a b : ℚ => a ≤ b) (sortedList xs) := by
  have h := List.pairwise_mergeSort (le := sortLe)
    (fun a b c hab hbc => by
      simp only [sortLe, decide_eq_true_eq] at *; exact le_trans hab hbc)
    (fun a b => by
      simp only [sortLe, Bool.or_eq_true, decide_eq_true_eq]; exact le_total a b) xs
  exact h.imp (by simp [sortLe])

lemma countP_sortedList (p : ℚ → Bool) (xs : List ℚ) :
    (sortedList xs).countP p = xs.countP p :=
  (sortedList_perm xs).countP_eq p

/-! ## 2. Order statistics of a sorted list -/

lemma sorted_countP_le_ge (s : List ℚ) (hs : List.Pairwise (fun a b : ℚ => a ≤ b) s)
    {j : ℕ} (hj : j < s.length) :
    j + 1 ≤ s.countP (fun x => decide (x ≤ s[j])) := by
  have hget := List.pairwise_iff_getElem.mp hs
  have hsplit : s = s.take (j + 1) ++ s.drop (j + 1) := (List.take_append_drop _ s).symm
  have hall : ∀ x ∈ s.take (j + 1), (fun x => decide (x ≤ s[j])) x = true := by
    intro x hx
    obtain ⟨i, hi, rfl⟩ := List.mem_iff_getElem.mp hx
    rw [List.length_take] at hi
    have hij : i < s.length := by omega
    simp only [List.getElem_take, decide_eq_true_eq]
    rcases lt_or_eq_of_le (show i ≤ j by omega) with h | h
    · exact hget i j hij hj h
    · subst h; simp
  have hcount : (s.take (j + 1)).countP (fun x => decide (x ≤ s[j])) = j + 1 := by
    rw [List.countP_eq_length.mpr hall, List.length_take]
    omega
  calc j + 1 = (s.take (j + 1)).countP (fun x => decide (x ≤ s[j])) := hcount.symm
    _ ≤ (s.take (j + 1)).countP (fun x => decide (x ≤ s[j])) +
          (s.drop (j + 1)).countP (fun x => decide (x ≤ s[j])) := Nat.le_add_right _ _
    _ = s.countP (fun x => decide (x ≤ s[j])) := by
        rw [← List.countP_append, ← hsplit]

lemma sorted_countP_ge_le (s : List ℚ) (hs : List.Pairwise (fun a b : ℚ => a ≤ b) s)
    {j : ℕ} (hj : j < s.length) :
    s.length - j ≤ s.countP (fun x => decide (s[j] ≤ x)) := by
  have hget := List.pairwise_iff_getElem.mp hs
  have hsplit : s = s.take j ++ s.drop j := (List.take_append_drop _ s).symm
  have hall : ∀ x ∈ s.drop j, (fun x => decide (s[j] ≤ x)) x = true := by
    intro x hx
    obtain ⟨i, hi, rfl⟩ := List.mem_iff_getElem.mp hx
    rw [List.length_drop] at hi
    have hij : j + i < s.length := by omega
    simp only [List.getElem_drop, decide_eq_true_eq]
    rcases Nat.eq_zero_or_pos i with h | h
    · subst h; simp
    · exact hget j (j + i) hj hij (by omega)
  have hcount : (s.drop j).countP (fun x => decide (s[j] ≤ x)) = s.length - j := by
    rw [List.countP_eq_length.mpr hall, List.length_drop]
  calc s.length - j = (s.drop j).countP (fun x => decide (s[j] ≤ x)) := hcount.symm
    _ ≤ (s.take j).countP (fun x => decide (s[j] ≤ x)) +
          (s.drop j).countP (fun x => decide (s[j] ≤ x)) := Nat.le_add_left _ _
    _ = s.countP (fun x => decide (s[j] ≤ x)) := by
        rw [← List.countP_append, ← hsplit]

/-! ## 3. The lower sample median -/

/-- The lower sample median: the `⌈n/2⌉`-th smallest observation. -/
def lowerMedian (xs : List ℚ) : ℚ := (sortedList xs).getD ((xs.length - 1) / 2) 0

lemma lowerMedian_eq_getElem {xs : List ℚ} (hxs : xs ≠ []) :
    lowerMedian xs = (sortedList xs)[(xs.length - 1) / 2]'(by
      rw [length_sortedList]
      have : 0 < xs.length := List.length_pos_iff.mpr hxs
      omega) := by
  have hlt : (xs.length - 1) / 2 < (sortedList xs).length := by
    rw [length_sortedList]
    have : 0 < xs.length := List.length_pos_iff.mpr hxs
    omega
  rw [lowerMedian, List.getD_eq_getElem _ _ hlt]

/-- **The lower sample median is a median.** -/
theorem isMedian_lowerMedian {xs : List ℚ} (hxs : xs ≠ []) :
    IsMedian xs (lowerMedian xs) := by
  have hpos : 0 < xs.length := List.length_pos_iff.mpr hxs
  set s := sortedList xs with hsdef
  have hslen : s.length = xs.length := length_sortedList xs
  set j := (xs.length - 1) / 2 with hj
  have hjlt : j < s.length := by rw [hslen]; omega
  have hval : lowerMedian xs = s[j] := lowerMedian_eq_getElem hxs
  constructor
  · have h1 := sorted_countP_le_ge s (sortedList_pairwise xs) hjlt
    have h2 : (s.countP fun x => decide (x ≤ s[j])) = xs.countP fun x => decide (x ≤ s[j]) :=
      countP_sortedList _ xs
    rw [hval, ← h2]
    omega
  · have h1 := sorted_countP_ge_le s (sortedList_pairwise xs) hjlt
    have h2 : (s.countP fun x => decide (s[j] ≤ x)) = xs.countP fun x => decide (s[j] ≤ x) :=
      countP_sortedList _ xs
    rw [hval, ← h2]
    rw [hslen] at h1
    omega

/-! ## 4. Equivariance -/

lemma sortedList_map_add (xs : List ℚ) (c : ℚ) :
    sortedList (xs.map (· + c)) = (sortedList xs).map (· + c) := by
  refine List.Perm.eq_of_pairwise (le := fun a b : ℚ => a ≤ b)
    (fun a b _ _ hab hba => le_antisymm hab hba)
    (sortedList_pairwise _) ?_ ?_
  · rw [List.pairwise_map]
    exact (sortedList_pairwise xs).imp (fun h => by simpa using h)
  · exact (sortedList_perm _).trans (((sortedList_perm xs).map (· + c)).symm)

/-- **The lower sample median is translation equivariant.** -/
theorem lowerMedian_equivariant : Equivariant lowerMedian := by
  intro xs hxs c
  have hpos : 0 < xs.length := List.length_pos_iff.mpr hxs
  have hmne : xs.map (· + c) ≠ [] := by simpa using hxs
  have hlen : (xs.map (· + c)).length = xs.length := List.length_map ..
  have h1 : lowerMedian (xs.map (· + c)) =
      (sortedList (xs.map (· + c)))[((xs.map (· + c)).length - 1) / 2]'(by
        rw [length_sortedList]; omega) := lowerMedian_eq_getElem hmne
  have h2 : lowerMedian xs = (sortedList xs)[(xs.length - 1) / 2]'(by
      rw [length_sortedList]; omega) := lowerMedian_eq_getElem hxs
  rw [h1, h2]
  simp only [hlen]
  simp [sortedList_map_add]

/-! ## 5. The lower median attains the universal ceiling -/

/-- **Capstone.**  The lower sample median is a translation-equivariant estimator
whose breakdown number is exactly `⌈n/2⌉`; by `breakdownNumber_le` no
equivariant estimator does better, so the ceiling is attained. -/
theorem lowerMedian_breakdownNumber (xs : List ℚ) (hxs : xs ≠ []) :
    IsLeast {k | ¬ EstBounded lowerMedian xs k} ((xs.length + 1) / 2) := by
  have hpos : 0 < xs.length := List.length_pos_iff.mpr hxs
  constructor
  · exact breakdown_ceiling_unbounded lowerMedian_equivariant xs hxs (by omega)
  · intro k hk
    simp only [Set.mem_setOf_eq] at hk
    by_contra hcon
    push_neg at hcon
    refine hk ?_
    obtain ⟨B, hB⟩ := exists_abs_bound xs
    refine ⟨B, ?_⟩
    intro ys hlen hd
    have hyne : ys ≠ [] := by
      intro h; rw [h] at hlen; simp at hlen; omega
    have hd' : 2 * diffCount xs ys < xs.length := by omega
    have ha : ∀ x ∈ xs, -B ≤ x := by
      intro x hx; have := abs_le.mp (hB x hx); linarith [this.1]
    have hb : ∀ x ∈ xs, x ≤ B := fun x hx => (abs_le.mp (hB x hx)).2
    obtain ⟨h1, h2⟩ :=
      median_robust_interval hlen.symm hd' (isMedian_lowerMedian hyne) ha hb
    exact abs_le.mpr ⟨h1, h2⟩

/-- The lower median attains the universal ceiling: its breakdown number equals
the maximum permitted by `breakdownNumber_le`. -/
theorem lowerMedian_attains_ceiling (xs : List ℚ) (hxs : xs ≠ []) :
    ∃ k : ℕ, IsLeast {j | ¬ EstBounded lowerMedian xs j} k ∧
      k = (xs.length + 1) / 2 ∧
      ∀ T : List ℚ → ℚ, Equivariant T → ∀ k' : ℕ,
        IsLeast {j | ¬ EstBounded T xs j} k' → k' ≤ k :=
  ⟨(xs.length + 1) / 2, lowerMedian_breakdownNumber xs hxs, rfl,
    fun _ hT _ hk => breakdownNumber_le hT xs hxs hk⟩

/-! ## 6. The measured normalised distributions -/

lemma ratios16_ne_nil : ratios16 ≠ [] := by rw [ratios16_eq]; simp

lemma ratios8_ne_nil : ratios8 ≠ [] := by rw [ratios8_eq]; simp

/-- On the 16 measured samples the lower median tolerates exactly 7 corrupted
measurements, and this is optimal among all equivariant estimators. -/
theorem ratios16_lowerMedian_breakdown :
    IsLeast {k | ¬ EstBounded lowerMedian ratios16 k} 8 := by
  have h := lowerMedian_breakdownNumber ratios16 ratios16_ne_nil
  rwa [length_ratios16] at h

/-- On the 8 measured samples the lower median tolerates exactly 3 corrupted
measurements, and this is optimal among all equivariant estimators. -/
theorem ratios8_lowerMedian_breakdown :
    IsLeast {k | ¬ EstBounded lowerMedian ratios8 k} 4 := by
  have h := lowerMedian_breakdownNumber ratios8 ratios8_ne_nil
  rwa [length_ratios8] at h

/-- The measured 16-sample median value produced by the selector is a genuine
median of the measured distribution. -/
theorem isMedian_lowerMedian_ratios16 : IsMedian ratios16 (lowerMedian ratios16) :=
  isMedian_lowerMedian ratios16_ne_nil

/-- The measured 8-sample median value produced by the selector is a genuine
median of the measured distribution. -/
theorem isMedian_lowerMedian_ratios8 : IsMedian ratios8 (lowerMedian ratios8) :=
  isMedian_lowerMedian ratios8_ne_nil

end MedianBreakdown