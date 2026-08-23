/-
# The finite-sample breakdown theorem for the median, with measured data

This file completes a two-sided ("breakdown" + "sharpness") analysis of the
robustness of the sample median against adversarial contamination, and then
instantiates it on two *measured normalised distributions*, encoded here as
lists of rationals obtained from measured count triples.

## Setting

A dataset is a `List ℚ` of length `n`.  A *contamination budget* `k` allows an
adversary to replace at most `k` of the `n` entries by arbitrary rationals; the
resulting dataset `ys` has the same length as `xs` and Hamming distance
`diffCount xs ys ≤ k`.

`IsMedian xs m` is the usual order-statistic-free definition: at least half of
the entries are `≤ m` and at least half are `≥ m`.  (For even `n` this makes the
median an interval, which is the honest state of affairs; every theorem below is
stated for *every* median of the contaminated sample, so nothing is hidden in a
tie-breaking convention.)

## Results

* `countP_le_countP_add_diffCount` — the combinatorial core: a predicate count
  changes by at most the Hamming distance.
* `median_robust_quant` — quantitative robustness: `n ≤ 2·#{x ∈ xs | x ≤ m} + 2d`.
* `median_robust_mem_le` / `median_robust_le_mem` — the **breakdown half**: if
  `2k < n` then any median of any `k`-contamination is sandwiched between two
  *uncontaminated* data values.
* `isMedian_contaminate` — the **sharpness half**: if `2k ≥ n` then `k`
  replacements make *any* prescribed rational the median.
* `medianBounded_iff` — the two halves combine into an exact criterion, and
  `median_breakdown_number` identifies the breakdown number as `⌈n/2⌉`.
* `mean_breakdown_one` — the contrast: the mean has breakdown number `1`.
* `isMedian_ratios16`, `isMedian_ratios8` — the two measured normalised
  distributions and their medians, followed by the fully instantiated
  breakdown/sharpness statements for them.
-/
import Mathlib

namespace MedianBreakdown

/-! ## 1. Hamming distance between equal-length datasets -/

/-- Number of positions at which two lists differ (positions beyond the shorter
list are ignored; we only ever use it on equal-length lists). -/
def diffCount : List ℚ → List ℚ → ℕ
  | [], _ => 0
  | _, [] => 0
  | x :: xs, y :: ys => (if x = y then 0 else 1) + diffCount xs ys

@[simp] lemma diffCount_nil_left (ys : List ℚ) : diffCount [] ys = 0 := by
  cases ys <;> rfl

@[simp] lemma diffCount_nil_right (xs : List ℚ) : diffCount xs [] = 0 := by
  cases xs <;> rfl

@[simp] lemma diffCount_cons (x y : ℚ) (xs ys : List ℚ) :
    diffCount (x :: xs) (y :: ys) = (if x = y then 0 else 1) + diffCount xs ys := rfl

@[simp] lemma diffCount_self (xs : List ℚ) : diffCount xs xs = 0 := by
  induction xs with
  | nil => rfl
  | cons a l ih => simp [ih]

lemma diffCount_le_length (xs ys : List ℚ) : diffCount xs ys ≤ xs.length := by
  induction xs generalizing ys with
  | nil => simp
  | cons a l ih =>
    cases ys with
    | nil => simp
    | cons b m =>
      simp only [diffCount_cons, List.length_cons]
      have := ih m
      split <;> omega

lemma diffCount_append (a b c d : List ℚ) (h : a.length = b.length) :
    diffCount (a ++ c) (b ++ d) = diffCount a b + diffCount c d := by
  induction a generalizing b with
  | nil =>
    cases b with
    | nil => simp
    | cons _ _ => simp at h
  | cons x l ih =>
    cases b with
    | nil => simp at h
    | cons y m =>
      simp only [List.cons_append, diffCount_cons, List.length_cons] at *
      rw [ih m (by omega)]
      omega

/-- **Combinatorial core of the breakdown theorem.**  Replacing `d` entries of a
dataset can destroy at most `d` witnesses of any predicate. -/
lemma countP_le_countP_add_diffCount (p : ℚ → Bool) {xs ys : List ℚ}
    (hlen : xs.length = ys.length) :
    ys.countP p ≤ xs.countP p + diffCount xs ys := by
  induction xs generalizing ys with
  | nil =>
    cases ys with
    | nil => simp
    | cons b m => simp at hlen
  | cons x l ih =>
    cases ys with
    | nil => simp
    | cons y m =>
      simp only [List.length_cons] at hlen
      have hrec := ih (ys := m) (by omega)
      simp only [List.countP_cons, diffCount_cons]
      by_cases hxy : x = y
      · subst hxy; split <;> omega
      · simp only [if_neg hxy]; split <;> split <;> omega

/-! ## 2. Medians -/

/-- `m` is a median of the dataset `xs`: at least half of the entries are `≤ m`
and at least half are `≥ m`. -/
def IsMedian (xs : List ℚ) (m : ℚ) : Prop :=
  xs.length ≤ 2 * xs.countP (fun x => decide (x ≤ m)) ∧
  xs.length ≤ 2 * xs.countP (fun x => decide (m ≤ x))

instance (xs : List ℚ) (m : ℚ) : Decidable (IsMedian xs m) := by
  unfold IsMedian; infer_instance

/-! ## 3. The breakdown half: `2k < n` keeps the median inside the data range -/

/-- Quantitative robustness of the lower half-count. -/
theorem median_robust_quant_le {xs ys : List ℚ} {m : ℚ}
    (hlen : xs.length = ys.length) (hm : IsMedian ys m) :
    xs.length ≤ 2 * xs.countP (fun x => decide (x ≤ m)) + 2 * diffCount xs ys := by
  have h := countP_le_countP_add_diffCount (fun x => decide (x ≤ m)) hlen
  have := hm.1
  omega

/-- Quantitative robustness of the upper half-count. -/
theorem median_robust_quant_ge {xs ys : List ℚ} {m : ℚ}
    (hlen : xs.length = ys.length) (hm : IsMedian ys m) :
    xs.length ≤ 2 * xs.countP (fun x => decide (m ≤ x)) + 2 * diffCount xs ys := by
  have h := countP_le_countP_add_diffCount (fun x => decide (m ≤ x)) hlen
  have := hm.2
  omega

/-- **Breakdown half (lower sandwich).**  If strictly fewer than half of the
entries are contaminated, every median of the contaminated sample dominates some
genuine data point. -/
theorem median_robust_mem_le {xs ys : List ℚ} {m : ℚ}
    (hlen : xs.length = ys.length) (hd : 2 * diffCount xs ys < xs.length)
    (hm : IsMedian ys m) : ∃ x ∈ xs, x ≤ m := by
  have h := median_robust_quant_le hlen hm
  have hpos : 0 < xs.countP (fun x => decide (x ≤ m)) := by omega
  obtain ⟨x, hx, hxm⟩ := List.countP_pos_iff.mp hpos
  exact ⟨x, hx, by simpa using hxm⟩

/-- **Breakdown half (upper sandwich).** -/
theorem median_robust_le_mem {xs ys : List ℚ} {m : ℚ}
    (hlen : xs.length = ys.length) (hd : 2 * diffCount xs ys < xs.length)
    (hm : IsMedian ys m) : ∃ x ∈ xs, m ≤ x := by
  have h := median_robust_quant_ge hlen hm
  have hpos : 0 < xs.countP (fun x => decide (m ≤ x)) := by omega
  obtain ⟨x, hx, hxm⟩ := List.countP_pos_iff.mp hpos
  exact ⟨x, hx, by simpa using hxm⟩

/-- The median of a lightly contaminated sample stays inside any interval that
contains the *uncontaminated* data. -/
theorem median_robust_interval {xs ys : List ℚ} {m a b : ℚ}
    (hlen : xs.length = ys.length) (hd : 2 * diffCount xs ys < xs.length)
    (hm : IsMedian ys m) (ha : ∀ x ∈ xs, a ≤ x) (hb : ∀ x ∈ xs, x ≤ b) :
    a ≤ m ∧ m ≤ b := by
  obtain ⟨x, hx, hxm⟩ := median_robust_mem_le hlen hd hm
  obtain ⟨y, hy, hmy⟩ := median_robust_le_mem hlen hd hm
  exact ⟨le_trans (ha x hx) hxm, le_trans hmy (hb y hy)⟩

/-! ## 4. The sharpness half: `2k ≥ n` breaks the median completely -/

/-- Replace the first `k` entries of `xs` by the value `t`. -/
def contaminate (xs : List ℚ) (k : ℕ) (t : ℚ) : List ℚ :=
  List.replicate k t ++ xs.drop k

lemma length_contaminate {xs : List ℚ} {k : ℕ} (hk : k ≤ xs.length) (t : ℚ) :
    (contaminate xs k t).length = xs.length := by
  simp [contaminate, hk]

lemma diffCount_contaminate {xs : List ℚ} {k : ℕ} (hk : k ≤ xs.length) (t : ℚ) :
    diffCount xs (contaminate xs k t) ≤ k := by
  have hsplit : xs = xs.take k ++ xs.drop k := (List.take_append_drop k xs).symm
  have hlen : (xs.take k).length = (List.replicate k t).length := by
    simp [hk]
  calc diffCount xs (contaminate xs k t)
      = diffCount (xs.take k ++ xs.drop k) (List.replicate k t ++ xs.drop k) := by
        rw [← hsplit]; rfl
    _ = diffCount (xs.take k) (List.replicate k t) + diffCount (xs.drop k) (xs.drop k) :=
        diffCount_append _ _ _ _ hlen
    _ ≤ k := by
        rw [diffCount_self]
        have := diffCount_le_length (xs.take k) (List.replicate k t)
        simp only [List.length_take] at this
        omega

lemma countP_replicate_self (k : ℕ) (t : ℚ) (p : ℚ → Bool) (hp : p t = true) :
    (List.replicate k t).countP p = k := by
  induction k with
  | zero => simp
  | succ n ih => simp [List.replicate_succ, hp, ih]

/-- **Sharpness half.**  With a contamination budget of at least half the sample,
the adversary can install *any* prescribed value `t` as a median. -/
theorem isMedian_contaminate {xs : List ℚ} {k : ℕ} (hk : k ≤ xs.length)
    (hhalf : xs.length ≤ 2 * k) (t : ℚ) : IsMedian (contaminate xs k t) t := by
  have hlen := length_contaminate hk t
  have hle : k ≤ (contaminate xs k t).countP (fun x => decide (x ≤ t)) := by
    rw [contaminate, List.countP_append, countP_replicate_self k t _ (by simp)]
    omega
  have hge : k ≤ (contaminate xs k t).countP (fun x => decide (t ≤ x)) := by
    rw [contaminate, List.countP_append, countP_replicate_self k t _ (by simp)]
    omega
  exact ⟨by omega, by omega⟩

/-! ## 5. The exact breakdown number -/

/-- The median is *bounded under a contamination budget of `k`* if some a priori
bound survives every `k`-contamination. -/
def MedianBounded (xs : List ℚ) (k : ℕ) : Prop :=
  ∃ B : ℚ, ∀ ys m, ys.length = xs.length → diffCount xs ys ≤ k → IsMedian ys m → |m| ≤ B

lemma exists_abs_bound (xs : List ℚ) : ∃ B : ℚ, ∀ x ∈ xs, |x| ≤ B := by
  induction xs with
  | nil => exact ⟨0, by simp⟩
  | cons a l ih =>
    obtain ⟨B, hB⟩ := ih
    refine ⟨max |a| B, ?_⟩
    intro x hx
    rcases List.mem_cons.mp hx with h | h
    · subst h; exact le_max_left _ _
    · exact le_trans (hB x h) (le_max_right _ _)

/-- **The breakdown theorem, both halves at once.**  The sample median survives a
contamination budget of `k` if and only if `2k < n`. -/
theorem medianBounded_iff (xs : List ℚ) (hxs : xs ≠ []) (k : ℕ) :
    MedianBounded xs k ↔ 2 * k < xs.length := by
  constructor
  · rintro ⟨B, hB⟩
    by_contra hcon
    push_neg at hcon
    set k' := min k xs.length with hk'
    have hk'le : k' ≤ xs.length := min_le_right _ _
    have hk'k : k' ≤ k := min_le_left _ _
    have hhalf : xs.length ≤ 2 * k' := by
      have : 0 < xs.length := List.length_pos_iff.mpr hxs
      simp only [hk']
      omega
    set t : ℚ := |B| + 1 with ht
    have hmed := isMedian_contaminate hk'le hhalf t
    have hlen := length_contaminate hk'le t
    have hd : diffCount xs (contaminate xs k' t) ≤ k :=
      le_trans (diffCount_contaminate hk'le t) hk'k
    have := hB _ t hlen hd hmed
    have h1 : B < |t| := by
      rw [ht, abs_of_nonneg (by positivity)]
      have := le_abs_self B
      linarith
    linarith
  · intro hk
    obtain ⟨B, hB⟩ := exists_abs_bound xs
    refine ⟨B, ?_⟩
    intro ys m hlen hd hm
    have hd' : 2 * diffCount xs ys < xs.length := by omega
    have ha : ∀ x ∈ xs, -B ≤ x := by
      intro x hx; have := hB x hx; cases abs_le.mp this; linarith
    have hb : ∀ x ∈ xs, x ≤ B := by
      intro x hx; have := hB x hx; exact (abs_le.mp this).2
    obtain ⟨h1, h2⟩ := median_robust_interval hlen.symm hd' hm ha hb
    exact abs_le.mpr ⟨h1, h2⟩

/-- The **breakdown number** of the sample median on a dataset of size `n` is
exactly `⌈n/2⌉ = (n+1)/2`: it is the least contamination budget under which the
median becomes unbounded. -/
theorem median_breakdown_number (xs : List ℚ) (hxs : xs ≠ []) :
    IsLeast {k | ¬ MedianBounded xs k} ((xs.length + 1) / 2) := by
  constructor
  · simp only [Set.mem_setOf_eq, medianBounded_iff xs hxs]
    omega
  · intro k hk
    simp only [Set.mem_setOf_eq, medianBounded_iff xs hxs, not_lt] at hk
    omega

/-! ## 6. Contrast: the mean has breakdown number `1` -/

/-- The sample mean. -/
def mean (xs : List ℚ) : ℚ := xs.sum / xs.length

/-- **A single contaminated observation destroys the mean.**  This is the exact
counterpoint to `median_breakdown_number`: the breakdown budget of the mean is
`1`, independent of the sample size. -/
theorem mean_breakdown_one (xs : List ℚ) (hxs : xs ≠ []) (B : ℚ) :
    ∃ ys, ys.length = xs.length ∧ diffCount xs ys ≤ 1 ∧ B < |mean ys| := by
  obtain ⟨a, l, rfl⟩ : ∃ a l, xs = a :: l := by
    cases xs with
    | nil => exact absurd rfl hxs
    | cons a l => exact ⟨a, l, rfl⟩
  set n : ℚ := ((a :: l).length : ℚ) with hn
  have hnpos : 0 < n := by
    rw [hn]; exact_mod_cast List.length_pos_iff.mpr (by simp)
  set c : ℚ := n * (|B| + 1) - l.sum with hc
  refine ⟨c :: l, by simp, ?_, ?_⟩
  · simp only [diffCount_cons, diffCount_self, add_zero]
    split <;> omega
  · have hlen : (((c :: l).length : ℕ) : ℚ) = n := by rw [hn]; simp
    have hmean : mean (c :: l) = |B| + 1 := by
      rw [mean, hlen, List.sum_cons, hc]
      field_simp
      ring
    rw [hmean, abs_of_nonneg (by positivity)]
    linarith [le_abs_self B]

/-! ## 7. The two measured normalised distributions

Each measurement is a triple of raw counts `(a, b, c)` in three channels,
normalised to a probability vector by dividing by `a + b + c`; the recorded
statistic is the first coordinate `a / (a + b + c)`. -/

/-- Normalised first coordinate of a measured count triple. -/
def normRatio (t : ℕ × ℕ × ℕ) : ℚ := (t.1 : ℚ) / ((t.1 : ℚ) + (t.2.1 : ℚ) + (t.2.2 : ℚ))

/-- The 16 measured count triples of the first run. -/
def triples16 : List (ℕ × ℕ × ℕ) :=
  [(37, 41, 22), (35, 43, 22), (38, 40, 22), (36, 42, 22),
   (34, 44, 22), (39, 39, 22), (33, 45, 22), (40, 38, 22),
   (36, 41, 23), (37, 40, 23), (35, 42, 23), (38, 39, 23),
   (34, 43, 23), (39, 38, 23), (41, 37, 22), (32, 46, 22)]

/-- The 8 measured count triples of the second run. -/
def triples8 : List (ℕ × ℕ × ℕ) :=
  [(37, 41, 22), (35, 43, 22), (38, 40, 22), (36, 42, 22),
   (34, 44, 22), (39, 39, 22), (33, 45, 22), (40, 38, 22)]

/-- The first measured normalised distribution (16 samples). -/
def ratios16 : List ℚ := triples16.map normRatio

/-- The second measured normalised distribution (8 samples). -/
def ratios8 : List ℚ := triples8.map normRatio

lemma length_ratios16 : ratios16.length = 16 := by decide

lemma length_ratios8 : ratios8.length = 8 := by decide

/-- Explicit evaluation of the 16 measured normalised ratios. -/
lemma ratios16_eq : ratios16 =
    [37/100, 35/100, 38/100, 36/100, 34/100, 39/100, 33/100, 40/100,
     36/100, 37/100, 35/100, 38/100, 34/100, 39/100, 41/100, 32/100] := by
  simp [ratios16, triples16, normRatio]
  norm_num

/-- Explicit evaluation of the 8 measured normalised ratios. -/
lemma ratios8_eq : ratios8 =
    [37/100, 35/100, 38/100, 36/100, 34/100, 39/100, 33/100, 40/100] := by
  simp [ratios8, triples8, normRatio]
  norm_num

/-- The measured 16-sample distribution has median `73/200 = 0.365`.  (For an
even sample size the median is an interval; `73/200` is its midpoint.) -/
theorem isMedian_ratios16 : IsMedian ratios16 (73 / 200) := by
  refine ⟨?_, ?_⟩ <;>
    rw [length_ratios16, ratios16_eq] <;> norm_num [List.countP_cons]

/-- The measured 8-sample distribution has median `73/200 = 0.365`. -/
theorem isMedian_ratios8 : IsMedian ratios8 (73 / 200) := by
  refine ⟨?_, ?_⟩ <;>
    rw [length_ratios8, ratios8_eq] <;> norm_num [List.countP_cons]

lemma ratios16_bounds : ∀ x ∈ ratios16, (8 : ℚ) / 25 ≤ x ∧ x ≤ 41 / 100 := by
  intro x hx
  rw [ratios16_eq] at hx
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
  rcases hx with h|h|h|h|h|h|h|h|h|h|h|h|h|h|h|h <;> subst h <;> norm_num

lemma ratios8_bounds : ∀ x ∈ ratios8, (33 : ℚ) / 100 ≤ x ∧ x ≤ 2 / 5 := by
  intro x hx
  rw [ratios8_eq] at hx
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
  rcases hx with h|h|h|h|h|h|h|h <;> subst h <;> norm_num

/-! ## 8. Breakdown and sharpness for the measured data -/

/-- **Robustness for the 16-sample run.**  Up to 7 of the 16 measurements may be
corrupted arbitrarily and the median still lies inside the measured range
`[0.32, 0.41]`. -/
theorem ratios16_robust {ys : List ℚ} {m : ℚ} (hlen : ys.length = 16)
    (hd : diffCount ratios16 ys ≤ 7) (hm : IsMedian ys m) :
    (8 : ℚ) / 25 ≤ m ∧ m ≤ 41 / 100 := by
  refine median_robust_interval (a := 8 / 25) (b := 41 / 100)
    (by rw [length_ratios16, hlen]) (by rw [length_ratios16]; omega) hm
    (fun x hx => (ratios16_bounds x hx).1) (fun x hx => (ratios16_bounds x hx).2)

/-- **Sharpness for the 16-sample run.**  Eight corrupted measurements suffice to
install any prescribed value as the median. -/
theorem ratios16_sharp (t : ℚ) :
    (contaminate ratios16 8 t).length = 16 ∧
      diffCount ratios16 (contaminate ratios16 8 t) ≤ 8 ∧
      IsMedian (contaminate ratios16 8 t) t := by
  have hk : (8 : ℕ) ≤ ratios16.length := by rw [length_ratios16]; omega
  refine ⟨by rw [length_contaminate hk, length_ratios16], diffCount_contaminate hk t,
    isMedian_contaminate hk (by rw [length_ratios16]) t⟩

/-- **Robustness for the 8-sample run.** -/
theorem ratios8_robust {ys : List ℚ} {m : ℚ} (hlen : ys.length = 8)
    (hd : diffCount ratios8 ys ≤ 3) (hm : IsMedian ys m) :
    (33 : ℚ) / 100 ≤ m ∧ m ≤ 2 / 5 := by
  refine median_robust_interval (a := 33 / 100) (b := 2 / 5)
    (by rw [length_ratios8, hlen]) (by rw [length_ratios8]; omega) hm
    (fun x hx => (ratios8_bounds x hx).1) (fun x hx => (ratios8_bounds x hx).2)

/-- **Sharpness for the 8-sample run.** -/
theorem ratios8_sharp (t : ℚ) :
    (contaminate ratios8 4 t).length = 8 ∧
      diffCount ratios8 (contaminate ratios8 4 t) ≤ 4 ∧
      IsMedian (contaminate ratios8 4 t) t := by
  have hk : (4 : ℕ) ≤ ratios8.length := by rw [length_ratios8]; omega
  refine ⟨by rw [length_contaminate hk, length_ratios8], diffCount_contaminate hk t,
    isMedian_contaminate hk (by rw [length_ratios8]) t⟩

/-- The breakdown number of the median on the measured 16-sample distribution is
exactly `8`, i.e. the breakdown *point* is `8/16 = 1/2`. -/
theorem ratios16_breakdown_number : IsLeast {k | ¬ MedianBounded ratios16 k} 8 := by
  have h := median_breakdown_number ratios16 (by rw [ratios16_eq]; simp)
  rwa [length_ratios16] at h

/-- The breakdown number of the median on the measured 8-sample distribution is
exactly `4`, i.e. the breakdown *point* is `4/8 = 1/2`. -/
theorem ratios8_breakdown_number : IsLeast {k | ¬ MedianBounded ratios8 k} 4 := by
  have h := median_breakdown_number ratios8 (by rw [ratios8_eq]; simp)
  rwa [length_ratios8] at h

end MedianBreakdown