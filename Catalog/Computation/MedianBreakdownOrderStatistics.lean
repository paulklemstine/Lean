/-
# The breakdown profile of the order statistics

Why the *median* and not some other quantile?  This file computes the breakdown
number of **every** order statistic and thereby answers the question exactly.

For a sample of size `n`, let `orderStat j` be the `j`-th smallest observation
(`0`-indexed, with the index clamped so that the estimator is total and
translation equivariant).  We prove

* `orderStat_bounded` — `orderStat j` survives every contamination budget
  `k < min (j+1) (n-j)`;
* `orderStat_unbounded` — it is destroyed by budget `min (j+1) (n-j)`;
* `orderStat_breakdownNumber` — hence its breakdown number is *exactly*
  `min (j+1) (n-j)`;
* `orderStat_breakdownNumber_le_median` and `median_index_breakdownNumber` — the
  discrete optimisation `max_{j<n} min (j+1) (n-j) = ⌈n/2⌉` is attained at the
  median index `j = ⌊(n-1)/2⌋`, and only there up to the even-`n` tie.

Combined with `breakdownNumber_le` from `Computation.MedianBreakdownOptimality`,
this pins the median down twice over: it is optimal inside the order-statistic
family, and the value it attains is the universal equivariant ceiling.

The technical engine is a pair of *converse* order-statistic sandwich lemmas
(`orderStat_le_of_countP`, `le_orderStat_of_countP`), which read a bound on an
order statistic off a mere count — this is what lets the sharpness half avoid
computing any sorted list explicitly.
-/
import Mathlib
import Computation.MedianBreakdown
import Computation.MedianBreakdownOptimality
import Computation.MedianBreakdownSelector

namespace MedianBreakdown

/-! ## 1. Order statistics as total, equivariant estimators -/

/-- The `j`-th smallest observation (`0`-indexed).  The index is clamped to
`n - 1` so that the estimator is total and genuinely equivariant. -/
def orderStat (j : ℕ) (xs : List ℚ) : ℚ := (sortedList xs).getD (min j (xs.length - 1)) 0

lemma orderStat_eq_getElem {xs : List ℚ} {j : ℕ} (hj : j < xs.length) :
    orderStat j xs = (sortedList xs)[j]'(by rw [length_sortedList]; exact hj) := by
  have hmin : min j (xs.length - 1) = j := by omega
  rw [orderStat, hmin, List.getD_eq_getElem]

lemma lowerMedian_eq_orderStat (xs : List ℚ) :
    lowerMedian xs = orderStat ((xs.length - 1) / 2) xs := by
  have hmin : min ((xs.length - 1) / 2) (xs.length - 1) = (xs.length - 1) / 2 := by omega
  rw [lowerMedian, orderStat, hmin]

lemma orderStat_equivariant (j : ℕ) : Equivariant (orderStat j) := by
  intro xs hxs c
  have hpos : 0 < xs.length := List.length_pos_iff.mpr hxs
  have hlen : (xs.map (· + c)).length = xs.length := List.length_map ..
  have hj : min j (xs.length - 1) < (sortedList xs).length := by
    rw [length_sortedList]; omega
  rw [orderStat, orderStat, hlen, sortedList_map_add,
    List.getD_eq_getElem _ _ (by rw [List.length_map]; exact hj),
    List.getD_eq_getElem _ _ hj]
  simp

/-! ## 2. Converse sandwich lemmas: counts control order statistics -/

/-- If at least `j + 1` observations are `≤ t`, the `j`-th order statistic is `≤ t`. -/
lemma orderStat_le_of_countP {xs : List ℚ} {j : ℕ} (hj : j < xs.length) {t : ℚ}
    (h : j + 1 ≤ xs.countP (fun x => decide (x ≤ t))) : orderStat j xs ≤ t := by
  by_contra hcon
  push_neg at hcon
  set s := sortedList xs with hs
  have hslen : s.length = xs.length := length_sortedList xs
  have hjs : j < s.length := by omega
  have hval : orderStat j xs = s[j] := orderStat_eq_getElem hj
  have hget := List.pairwise_iff_getElem.mp (sortedList_pairwise xs)
  have hdrop : (s.drop j).countP (fun x => decide (x ≤ t)) = 0 := by
    refine List.countP_eq_zero.mpr ?_
    intro x hx
    obtain ⟨i, hi, rfl⟩ := List.mem_iff_getElem.mp hx
    rw [List.length_drop] at hi
    have hij : j + i < s.length := by omega
    simp only [List.getElem_drop, decide_eq_true_eq, not_le]
    rcases Nat.eq_zero_or_pos i with hi0 | hi0
    · subst hi0; simpa [hval] using hcon
    · have : s[j] ≤ s[j + i] := hget j (j + i) hjs hij (by omega)
      rw [hval] at hcon
      linarith
  have hsplit : s = s.take j ++ s.drop j := (List.take_append_drop _ s).symm
  have hcount : s.countP (fun x => decide (x ≤ t)) ≤ j := by
    conv_lhs => rw [hsplit]
    rw [List.countP_append, hdrop, add_zero]
    exact le_trans List.countP_le_length (by rw [List.length_take]; omega)
  rw [countP_sortedList] at hcount
  omega

/-- If at least `n - j` observations are `≥ t`, the `j`-th order statistic is `≥ t`. -/
lemma le_orderStat_of_countP {xs : List ℚ} {j : ℕ} (hj : j < xs.length) {t : ℚ}
    (h : xs.length - j ≤ xs.countP (fun x => decide (t ≤ x))) : t ≤ orderStat j xs := by
  by_contra hcon
  push_neg at hcon
  set s := sortedList xs with hs
  have hslen : s.length = xs.length := length_sortedList xs
  have hjs : j < s.length := by omega
  have hval : orderStat j xs = s[j] := orderStat_eq_getElem hj
  have hget := List.pairwise_iff_getElem.mp (sortedList_pairwise xs)
  have htake : (s.take (j + 1)).countP (fun x => decide (t ≤ x)) = 0 := by
    refine List.countP_eq_zero.mpr ?_
    intro x hx
    obtain ⟨i, hi, rfl⟩ := List.mem_iff_getElem.mp hx
    rw [List.length_take] at hi
    have hij : i < s.length := by omega
    simp only [List.getElem_take, decide_eq_true_eq, not_le]
    rcases lt_or_eq_of_le (show i ≤ j by omega) with hlt | heq
    · have : s[i] ≤ s[j] := hget i j hij hjs hlt
      rw [hval] at hcon
      linarith
    · subst heq; simpa [hval] using hcon
  have hsplit : s = s.take (j + 1) ++ s.drop (j + 1) := (List.take_append_drop _ s).symm
  have hcount : s.countP (fun x => decide (t ≤ x)) ≤ s.length - (j + 1) := by
    conv_lhs => rw [hsplit]
    rw [List.countP_append, htake, zero_add]
    exact le_trans List.countP_le_length (by rw [List.length_drop])
  rw [countP_sortedList, hslen] at hcount
  omega

/-! ## 3. Counting inside a contaminated sample -/

lemma countP_contaminate_le {xs : List ℚ} (k : ℕ) (t : ℚ) :
    k ≤ (contaminate xs k t).countP (fun x => decide (x ≤ t)) := by
  rw [contaminate, List.countP_append, countP_replicate_self k t _ (by simp)]
  omega

lemma countP_contaminate_ge {xs : List ℚ} (k : ℕ) (t : ℚ) :
    k ≤ (contaminate xs k t).countP (fun x => decide (t ≤ x)) := by
  rw [contaminate, List.countP_append, countP_replicate_self k t _ (by simp)]
  omega

/-! ## 4. Robustness of an arbitrary order statistic -/

/-- **Robustness half for order statistics.**  The `j`-th order statistic
tolerates any budget `k` with `k ≤ j` and `k < n - j`. -/
theorem orderStat_bounded {xs : List ℚ} {j : ℕ} (hj : j < xs.length) {k : ℕ}
    (hk1 : k ≤ j) (hk2 : k < xs.length - j) : EstBounded (orderStat j) xs k := by
  obtain ⟨B, hB⟩ := exists_abs_bound xs
  refine ⟨B, ?_⟩
  intro ys hlen hd
  have hjy : j < ys.length := by omega
  set m := orderStat j ys with hm
  have hval : m = (sortedList ys)[j]'(by rw [length_sortedList]; exact hjy) :=
    orderStat_eq_getElem hjy
  have hlow : j + 1 ≤ ys.countP (fun x => decide (x ≤ m)) := by
    have h := sorted_countP_le_ge (sortedList ys) (sortedList_pairwise ys)
      (j := j) (by rw [length_sortedList]; exact hjy)
    rw [hval]
    rw [countP_sortedList] at h
    exact h
  have hhigh : ys.length - j ≤ ys.countP (fun x => decide (m ≤ x)) := by
    have h := sorted_countP_ge_le (sortedList ys) (sortedList_pairwise ys)
      (j := j) (by rw [length_sortedList]; exact hjy)
    rw [countP_sortedList] at h
    rw [hval]
    calc ys.length - j = (sortedList ys).length - j := by rw [length_sortedList]
      _ ≤ _ := h
  have htl := countP_le_countP_add_diffCount (fun x => decide (x ≤ m)) hlen.symm
  have hth := countP_le_countP_add_diffCount (fun x => decide (m ≤ x)) hlen.symm
  have hpos1 : 0 < xs.countP (fun x => decide (x ≤ m)) := by omega
  have hpos2 : 0 < xs.countP (fun x => decide (m ≤ x)) := by omega
  obtain ⟨a, ha, hab⟩ := List.countP_pos_iff.mp hpos1
  obtain ⟨b, hb, hbc⟩ := List.countP_pos_iff.mp hpos2
  have h1 : a ≤ m := by simpa using hab
  have h2 : m ≤ b := by simpa using hbc
  have hA := abs_le.mp (hB a ha)
  have hBb := abs_le.mp (hB b hb)
  exact abs_le.mpr ⟨le_trans hA.1 h1, le_trans h2 hBb.2⟩

/-! ## 5. Sharpness for an arbitrary order statistic -/

/-- **Sharpness half for order statistics.**  Budget `min (j+1) (n-j)` destroys
the `j`-th order statistic: pushing the low tail down (if `j + 1` is cheaper) or
the high tail up (if `n - j` is cheaper). -/
theorem orderStat_unbounded {xs : List ℚ} {j : ℕ} (hj : j < xs.length) {k : ℕ}
    (hk : min (j + 1) (xs.length - j) ≤ k) : ¬ EstBounded (orderStat j) xs k := by
  rintro ⟨B, hB⟩
  rcases le_total (j + 1) (xs.length - j) with hcase | hcase
  · -- cheap to flood the low tail with `j + 1` copies of a very negative value
    have hk' : j + 1 ≤ k := le_trans (by omega) hk
    have hkle : j + 1 ≤ xs.length := by omega
    set t : ℚ := -(|B| + 1) with ht
    set ys := contaminate xs (j + 1) t with hys
    have hlen : ys.length = xs.length := length_contaminate hkle t
    have hd : diffCount xs ys ≤ k := le_trans (diffCount_contaminate hkle t) hk'
    have hjy : j < ys.length := by omega
    have hcount : j + 1 ≤ ys.countP (fun x => decide (x ≤ t)) := countP_contaminate_le _ _
    have hle : orderStat j ys ≤ t := orderStat_le_of_countP hjy hcount
    have hlow := (abs_le.mp (hB ys hlen hd)).1
    have hBabs : B ≤ |B| := le_abs_self B
    linarith
  · -- cheap to flood the high tail with `n - j` copies of a very positive value
    have hk' : xs.length - j ≤ k := le_trans (by omega) hk
    have hkle : xs.length - j ≤ xs.length := by omega
    set t : ℚ := |B| + 1 with ht
    set ys := contaminate xs (xs.length - j) t with hys
    have hlen : ys.length = xs.length := length_contaminate hkle t
    have hd : diffCount xs ys ≤ k := le_trans (diffCount_contaminate hkle t) hk'
    have hjy : j < ys.length := by omega
    have hcount : ys.length - j ≤ ys.countP (fun x => decide (t ≤ x)) := by
      rw [hlen]; exact countP_contaminate_ge _ _
    have hge : t ≤ orderStat j ys := le_orderStat_of_countP hjy hcount
    have hup := (abs_le.mp (hB ys hlen hd)).2
    have hBabs : B ≤ |B| := le_abs_self B
    linarith

/-! ## 6. The breakdown profile and its maximiser -/

/-- **The breakdown number of the `j`-th order statistic is exactly
`min (j+1, n-j)`.** -/
theorem orderStat_breakdownNumber {xs : List ℚ} {j : ℕ} (hj : j < xs.length) :
    IsLeast {k | ¬ EstBounded (orderStat j) xs k} (min (j + 1) (xs.length - j)) := by
  constructor
  · exact orderStat_unbounded hj (le_refl _)
  · intro k hk
    simp only [Set.mem_setOf_eq] at hk
    by_contra hcon
    push_neg at hcon
    exact hk (orderStat_bounded hj (by omega) (by omega))

/-- No order statistic beats the median: the profile `min (j+1, n-j)` never
exceeds `⌈n/2⌉`. -/
theorem orderStat_breakdownNumber_le_median {n j : ℕ} (hj : j < n) :
    min (j + 1) (n - j) ≤ (n + 1) / 2 := by omega

/-- The median index attains the maximum of the breakdown profile. -/
theorem median_index_breakdownNumber {n : ℕ} (hn : 0 < n) :
    min ((n - 1) / 2 + 1) (n - (n - 1) / 2) = (n + 1) / 2 := by omega

/-- **Synthesis.**  Inside the order-statistic family the breakdown number is the
concave profile `min (j+1, n-j)`; it is maximised exactly at the median index,
where it equals `⌈n/2⌉`, which by `breakdownNumber_le` is also the ceiling over
*all* translation-equivariant estimators. -/
theorem orderStat_profile_maximised_at_median (xs : List ℚ) (hxs : xs ≠ []) :
    (∀ j, j < xs.length →
        IsLeast {k | ¬ EstBounded (orderStat j) xs k} (min (j + 1) (xs.length - j)) ∧
        min (j + 1) (xs.length - j) ≤ (xs.length + 1) / 2) ∧
      IsLeast {k | ¬ EstBounded (orderStat ((xs.length - 1) / 2)) xs k}
        ((xs.length + 1) / 2) := by
  have hpos : 0 < xs.length := List.length_pos_iff.mpr hxs
  refine ⟨fun j hj => ⟨orderStat_breakdownNumber hj, orderStat_breakdownNumber_le_median hj⟩, ?_⟩
  have hjm : (xs.length - 1) / 2 < xs.length := by omega
  have h := orderStat_breakdownNumber hjm
  rwa [median_index_breakdownNumber hpos] at h

/-! ## 7. The profile on the measured normalised distributions -/

/-- The complete breakdown profile of the 16 measured samples: order statistic
`j` tolerates `min (j+1, 16-j) - 1` corrupted measurements, peaking at `j = 7`
(the lower median) with a breakdown number of `8`. -/
theorem ratios16_orderStat_profile {j : ℕ} (hj : j < 16) :
    IsLeast {k | ¬ EstBounded (orderStat j) ratios16 k} (min (j + 1) (16 - j)) := by
  have hj' : j < ratios16.length := by rw [length_ratios16]; exact hj
  have h := orderStat_breakdownNumber hj'
  rwa [length_ratios16] at h

/-- The complete breakdown profile of the 8 measured samples, peaking at `j = 3`
with a breakdown number of `4`. -/
theorem ratios8_orderStat_profile {j : ℕ} (hj : j < 8) :
    IsLeast {k | ¬ EstBounded (orderStat j) ratios8 k} (min (j + 1) (8 - j)) := by
  have hj' : j < ratios8.length := by rw [length_ratios8]; exact hj
  have h := orderStat_breakdownNumber hj'
  rwa [length_ratios8] at h

/-- Extremes of the profile on the measured 16-sample run: the sample minimum and
maximum have breakdown number `1`, exactly as bad as the mean. -/
theorem ratios16_extremes_breakdown :
    IsLeast {k | ¬ EstBounded (orderStat 0) ratios16 k} 1 ∧
      IsLeast {k | ¬ EstBounded (orderStat 15) ratios16 k} 1 := by
  refine ⟨?_, ?_⟩
  · have h := ratios16_orderStat_profile (j := 0) (by omega)
    simpa using h
  · have h := ratios16_orderStat_profile (j := 15) (by omega)
    simpa using h

end MedianBreakdown