/-
# Optimality of the median: the universal breakdown ceiling

`Computation.MedianBreakdown` established that the sample median on `n` points
has breakdown number exactly `⌈n/2⌉`: it survives any contamination budget
`k` with `2k < n` (`median_robust_interval`) and is completely destroyed as soon
as `2k ≥ n` (`isMedian_contaminate`).

This file answers the obvious follow-up question — *could some cleverer location
estimator do better?* — in the negative.  We prove the **breakdown ceiling**:
for every translation-equivariant estimator `T` and every non-empty dataset,
a contamination budget of `⌈n/2⌉` already makes `T` unbounded.  Hence
`⌈n/2⌉` is a universal ceiling and the median attains it.

The proof is a *two-sample equivariance shear*: given a budget `k` with
`2k ≥ n`, we exhibit two contaminated datasets `ys`, `zs`, each within Hamming
distance `k` of the original sample, with `ys = zs + c` for a freely chosen
shift `c`.  Equivariance forces `T ys - T zs = c`, so no single bound can
control both.  The combinatorial content is that the two "halves" `take m` and
`drop m` of the sample can *both* be paid for out of the budget precisely when
`2k ≥ n`.

## Main results

* `EstBounded`, `Equivariant` — the estimator-level vocabulary.
* `breakdown_ceiling_unbounded` — the Donoho–Huber shear: `2k ≥ n` breaks every
  equivariant estimator.
* `breakdownNumber_le` — every equivariant estimator has breakdown number at
  most `⌈n/2⌉`.
* `median_breakdown_optimal` — the median attains the ceiling, so it is an
  optimally robust equivariant location estimator.
* `mean_breakdownNumber` — by contrast the mean's breakdown number is exactly
  `1`, the worst possible value.
* `ratios16_no_equivariant_survives_eight`,
  `ratios8_no_equivariant_survives_four` — the ceiling on the measured data.
-/
import Mathlib
import Computation.MedianBreakdown

namespace MedianBreakdown

/-! ## 1. Estimator vocabulary -/

/-- `T` is *bounded on `xs` under contamination budget `k`* if some a priori
bound survives every replacement of at most `k` of the entries of `xs`. -/
def EstBounded (T : List ℚ → ℚ) (xs : List ℚ) (k : ℕ) : Prop :=
  ∃ B : ℚ, ∀ ys : List ℚ, ys.length = xs.length → diffCount xs ys ≤ k → |T ys| ≤ B

/-- Translation equivariance of a location estimator on non-empty samples. -/
def Equivariant (T : List ℚ → ℚ) : Prop :=
  ∀ xs : List ℚ, xs ≠ [] → ∀ c : ℚ, T (xs.map (· + c)) = T xs + c

/-! ## 2. Hamming-distance toolkit for the shear -/

lemma diffCount_map_le (l : List ℚ) (f : ℚ → ℚ) : diffCount l (l.map f) ≤ l.length := by
  simpa using diffCount_le_length l (l.map f)

lemma eq_of_diffCount_eq_zero :
    ∀ {xs ys : List ℚ}, xs.length = ys.length → diffCount xs ys = 0 → xs = ys := by
  intro xs
  induction xs with
  | nil =>
    intro ys hlen _
    cases ys with
    | nil => rfl
    | cons _ _ => simp at hlen
  | cons a l ih =>
    intro ys hlen hd
    cases ys with
    | nil => simp at hlen
    | cons b m =>
      simp only [List.length_cons] at hlen
      simp only [diffCount_cons] at hd
      have hab : a = b := by by_contra h; simp [h] at hd
      have hrest : diffCount l m = 0 := by
        rw [hab] at hd; simpa using hd
      rw [hab, ih (by omega) hrest]

/-! ## 3. The shear construction

For a split point `m` we build the "upper shear" `shearHi` (which moves the tail
`drop m`) and the "lower shear" `shearLo` (which moves the head `take m` by the
opposite amount).  They are translates of one another. -/

/-- Move the last `n - m` entries of `xs` by `c`. -/
def shearHi (xs : List ℚ) (m : ℕ) (c : ℚ) : List ℚ :=
  xs.take m ++ (xs.drop m).map (· + c)

/-- Move the first `m` entries of `xs` by `-c`. -/
def shearLo (xs : List ℚ) (m : ℕ) (c : ℚ) : List ℚ :=
  (xs.take m).map (· + -c) ++ xs.drop m

lemma length_shearHi (xs : List ℚ) (m : ℕ) (c : ℚ) :
    (shearHi xs m c).length = xs.length := by
  simp only [shearHi, List.length_append, List.length_map, List.length_take, List.length_drop]
  omega

lemma length_shearLo (xs : List ℚ) (m : ℕ) (c : ℚ) :
    (shearLo xs m c).length = xs.length := by
  simp only [shearLo, List.length_append, List.length_map, List.length_take, List.length_drop]
  omega

/-- The two shears differ by the global translation `c`: this is the pivot of the
whole argument. -/
lemma shearLo_map_add (xs : List ℚ) (m : ℕ) (c : ℚ) :
    (shearLo xs m c).map (· + c) = shearHi xs m c := by
  simp only [shearLo, shearHi, List.map_append, List.map_map]
  congr 1
  refine (List.map_congr_left ?_).trans (List.map_id _)
  intro a _
  simp

lemma diffCount_shearHi (xs : List ℚ) (m : ℕ) (c : ℚ) :
    diffCount xs (shearHi xs m c) ≤ xs.length - m := by
  have hsplit : xs = xs.take m ++ xs.drop m := (List.take_append_drop m xs).symm
  have hlen : (xs.take m).length = (xs.take m).length := rfl
  calc diffCount xs (shearHi xs m c)
      = diffCount (xs.take m ++ xs.drop m) (xs.take m ++ (xs.drop m).map (· + c)) := by
        rw [← hsplit]; rfl
    _ = diffCount (xs.take m) (xs.take m) + diffCount (xs.drop m) ((xs.drop m).map (· + c)) :=
        diffCount_append _ _ _ _ hlen
    _ ≤ xs.length - m := by
        rw [diffCount_self]
        have := diffCount_map_le (xs.drop m) (· + c)
        simpa using this

lemma diffCount_shearLo (xs : List ℚ) (m : ℕ) (c : ℚ) :
    diffCount xs (shearLo xs m c) ≤ m := by
  have hsplit : xs = xs.take m ++ xs.drop m := (List.take_append_drop m xs).symm
  have hlen : (xs.take m).length = ((xs.take m).map (· + -c)).length := by simp
  calc diffCount xs (shearLo xs m c)
      = diffCount (xs.take m ++ xs.drop m) ((xs.take m).map (· + -c) ++ xs.drop m) := by
        rw [← hsplit]; rfl
    _ = diffCount (xs.take m) ((xs.take m).map (· + -c)) + diffCount (xs.drop m) (xs.drop m) :=
        diffCount_append _ _ _ _ hlen
    _ ≤ m := by
        rw [diffCount_self]
        have := diffCount_map_le (xs.take m) (· + -c)
        simp only [List.length_take] at this
        omega

/-! ## 4. The breakdown ceiling -/

/-- **Donoho–Huber breakdown ceiling.**  If the contamination budget reaches half
the sample, *every* translation-equivariant location estimator becomes unbounded.
No equivariant estimator is more robust than the median. -/
theorem breakdown_ceiling_unbounded {T : List ℚ → ℚ} (hT : Equivariant T)
    (xs : List ℚ) (hxs : xs ≠ []) {k : ℕ} (hk : xs.length ≤ 2 * k) :
    ¬ EstBounded T xs k := by
  rintro ⟨B, hB⟩
  set n := xs.length with hn
  set m := n - k with hm
  have hmk : m ≤ k := by omega
  have hnm : n - m ≤ k := by omega
  set c : ℚ := 2 * |B| + 1 with hc
  have hlo : (shearLo xs m c).length = n := length_shearLo xs m c
  have hhi : (shearHi xs m c).length = n := length_shearHi xs m c
  have hlone : shearLo xs m c ≠ [] := by
    intro h
    have : n = 0 := by rw [← hlo, h]; rfl
    exact hxs (List.eq_nil_of_length_eq_zero (by omega))
  have hdlo : diffCount xs (shearLo xs m c) ≤ k := le_trans (diffCount_shearLo xs m c) hmk
  have hdhi : diffCount xs (shearHi xs m c) ≤ k :=
    le_trans (diffCount_shearHi xs m c) (by simpa [hm, hn] using hnm)
  have key : T (shearHi xs m c) = T (shearLo xs m c) + c := by
    rw [← shearLo_map_add xs m c, hT _ hlone c]
  have h1 : |T (shearLo xs m c)| ≤ B := hB _ hlo hdlo
  have h2 : |T (shearHi xs m c)| ≤ B := hB _ hhi hdhi
  have hb1 := abs_le.mp h1
  have hb2 := abs_le.mp h2
  have hBabs : B ≤ |B| := le_abs_self B
  rw [key] at hb2
  have : c ≤ 2 * B := by linarith [hb1.1, hb2.2]
  rw [hc] at this
  linarith

/-- Every translation-equivariant estimator has breakdown number at most
`⌈n/2⌉ = (n+1)/2`. -/
theorem breakdownNumber_le {T : List ℚ → ℚ} (hT : Equivariant T)
    (xs : List ℚ) (hxs : xs ≠ []) {k : ℕ}
    (hk : IsLeast {j | ¬ EstBounded T xs j} k) : k ≤ (xs.length + 1) / 2 := by
  refine hk.2 ?_
  exact breakdown_ceiling_unbounded hT xs hxs (by omega)

/-! ## 5. The median attains the ceiling -/

/-- **Optimality of the median.**  The median's breakdown number `⌈n/2⌉` is the
largest breakdown number attainable by a translation-equivariant location
estimator. -/
theorem median_breakdown_optimal (xs : List ℚ) (hxs : xs ≠ []) :
    IsLeast {k | ¬ MedianBounded xs k} ((xs.length + 1) / 2) ∧
      ∀ T : List ℚ → ℚ, Equivariant T → ∀ k : ℕ,
        IsLeast {j | ¬ EstBounded T xs j} k → k ≤ (xs.length + 1) / 2 :=
  ⟨median_breakdown_number xs hxs, fun _ hT _ hk => breakdownNumber_le hT xs hxs hk⟩

/-! ## 6. The mean sits at the opposite extreme -/

lemma mean_equivariant : Equivariant mean := by
  intro xs hxs c
  have hlen : (0 : ℚ) < (xs.length : ℚ) := by
    exact_mod_cast List.length_pos_iff.mpr hxs
  have hsum : (xs.map (· + c)).sum = xs.sum + xs.length * c := by
    induction xs with
    | nil => simp
    | cons a l ih =>
      by_cases hl : l = []
      · subst hl; simp
      · have := ih hl (by exact_mod_cast List.length_pos_iff.mpr hl)
        simp only [List.map_cons, List.sum_cons, List.length_cons] at *
        push_cast
        rw [this]
        ring
  rw [mean, mean, hsum]
  simp only [List.length_map]
  field_simp

/-- The mean cannot even be trusted under a single corrupted observation, and it
*is* trustworthy under none: its breakdown number is exactly `1`. -/
theorem mean_breakdownNumber (xs : List ℚ) (hxs : xs ≠ []) :
    IsLeast {k | ¬ EstBounded mean xs k} 1 := by
  constructor
  · simp only [Set.mem_setOf_eq]
    rintro ⟨B, hB⟩
    obtain ⟨ys, hlen, hd, hgt⟩ := mean_breakdown_one xs hxs B
    exact absurd (hB ys hlen hd) (not_le.mpr hgt)
  · intro k hk
    simp only [Set.mem_setOf_eq] at hk
    by_contra hcon
    push_neg at hcon
    interval_cases k
    refine hk ⟨|mean xs|, ?_⟩
    intro ys hlen hd
    have : xs = ys := eq_of_diffCount_eq_zero hlen.symm (Nat.le_zero.mp hd)
    rw [← this]

/-! ## 7. The ceiling on the measured normalised distributions -/

/-- On the measured 16-sample run, no translation-equivariant estimator whatsoever
survives eight corrupted measurements — the median's tolerance of seven is
optimal. -/
theorem ratios16_no_equivariant_survives_eight {T : List ℚ → ℚ} (hT : Equivariant T) :
    ¬ EstBounded T ratios16 8 := by
  refine breakdown_ceiling_unbounded hT ratios16 ?_ (by rw [length_ratios16])
  rw [ratios16_eq]; simp

/-- On the measured 8-sample run, no translation-equivariant estimator survives
four corrupted measurements. -/
theorem ratios8_no_equivariant_survives_four {T : List ℚ → ℚ} (hT : Equivariant T) :
    ¬ EstBounded T ratios8 4 := by
  refine breakdown_ceiling_unbounded hT ratios8 ?_ (by rw [length_ratios8])
  rw [ratios8_eq]; simp

end MedianBreakdown