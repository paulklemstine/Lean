/-
# Breakdown as a unique-decoding radius: a robust-statistics / coding-theory bridge

The previous files show that the median's breakdown threshold sits exactly at
`2k = n`.  The number `n` is not an accident: it is the **minimum Hamming
distance of the translation orbit** `{xs, xs + c}` inside `ℚ^n`.  Shifting every
coordinate of a sample by a non-zero `c` changes *every* coordinate, so the
two-point "code" `{xs, xs + c}` has minimum distance `n`, and a corruption budget
of `k` allows an adversary to confuse the two hypotheses precisely when
`2k ≥ n` — the classical unique-decoding criterion `2k < d`.

The main theorem `confusable_iff` proves this criterion from scratch (Hamming
symmetry, triangle inequality, and an explicit confusing word), and
`breakdown_iff_confusable` identifies the two thresholds:

> the sample median breaks down under budget `k`
> **iff** the translation code `{xs, xs + c}` fails unique decoding at radius `k`.

So the statistical breakdown point and the coding-theoretic decoding radius are
literally the same combinatorial quantity.
-/
import Mathlib
import Computation.MedianBreakdown

namespace MedianBreakdown

/-! ## 1. `diffCount` is a Hamming metric -/

lemma diffCount_comm (xs ys : List ℚ) : diffCount xs ys = diffCount ys xs := by
  induction xs generalizing ys with
  | nil => simp
  | cons x l ih =>
    cases ys with
    | nil => simp
    | cons y m =>
      simp only [diffCount_cons, ih m]
      by_cases h : x = y
      · simp [h]
      · simp [h, Ne.symm h]

lemma diffCount_triangle {xs ys : List ℚ} (zs : List ℚ) (h : xs.length = ys.length) :
    diffCount xs zs ≤ diffCount xs ys + diffCount ys zs := by
  induction xs generalizing ys zs with
  | nil => simp
  | cons x l ih =>
    cases ys with
    | nil => simp at h
    | cons y m =>
      cases zs with
      | nil => simp
      | cons z p =>
        simp only [List.length_cons] at h
        have hrec := ih (ys := m) (zs := p) (by omega)
        simp only [diffCount_cons]
        have hxz : (if x = z then (0 : ℕ) else 1) ≤
            (if x = y then 0 else 1) + (if y = z then 0 else 1) := by
          by_cases h1 : x = y
          · subst h1; simp
          · simp only [if_neg h1]; split_ifs <;> omega
        omega

/-- A non-zero global shift changes **every** coordinate: the translation orbit is
a two-point code of minimum distance `n`. -/
lemma diffCount_map_add_of_ne_zero {c : ℚ} (hc : c ≠ 0) (xs : List ℚ) :
    diffCount xs (xs.map (· + c)) = xs.length := by
  induction xs with
  | nil => simp
  | cons x l ih =>
    have hne : ¬ (x = x + c) := by
      intro h; exact hc (by linarith)
    simp only [List.map_cons, diffCount_cons, List.length_cons, ih, if_neg hne]
    omega

/-! ## 2. The unique-decoding criterion -/

/-- The adversary can *confuse* the sample `xs` with its translate `xs + c` at
budget `k` if some single dataset lies within `k` corruptions of both. -/
def Confusable (xs : List ℚ) (c : ℚ) (k : ℕ) : Prop :=
  ∃ ws : List ℚ, ws.length = xs.length ∧
    diffCount xs ws ≤ k ∧ diffCount (xs.map (· + c)) ws ≤ k

/-- **Unique-decoding criterion for the translation code.**  For a non-zero shift,
the two hypotheses `xs` and `xs + c` become confusable at corruption budget `k`
exactly when `2k` reaches the minimum distance `n`. -/
theorem confusable_iff {c : ℚ} (hc : c ≠ 0) (xs : List ℚ) (k : ℕ) :
    Confusable xs c k ↔ xs.length ≤ 2 * k := by
  constructor
  · rintro ⟨ws, hlen, h1, h2⟩
    have hmaplen : (xs.map (· + c)).length = xs.length := List.length_map ..
    have htri : diffCount xs (xs.map (· + c)) ≤ diffCount xs ws + diffCount ws (xs.map (· + c)) :=
      diffCount_triangle _ hlen.symm
    rw [diffCount_map_add_of_ne_zero hc xs, diffCount_comm ws] at htri
    omega
  · intro hk
    set m := xs.length - k with hm
    refine ⟨(xs.take m).map (· + c) ++ xs.drop m, ?_, ?_, ?_⟩
    · simp only [List.length_append, List.length_map, List.length_take, List.length_drop]
      omega
    · have hsplit : xs = xs.take m ++ xs.drop m := (List.take_append_drop m xs).symm
      have hlen : (xs.take m).length = ((xs.take m).map (· + c)).length := by simp
      calc diffCount xs ((xs.take m).map (· + c) ++ xs.drop m)
          = diffCount (xs.take m ++ xs.drop m) ((xs.take m).map (· + c) ++ xs.drop m) := by
            rw [← hsplit]
        _ = diffCount (xs.take m) ((xs.take m).map (· + c)) + diffCount (xs.drop m) (xs.drop m) :=
            diffCount_append _ _ _ _ hlen
        _ ≤ k := by
            rw [diffCount_self]
            have := diffCount_le_length (xs.take m) ((xs.take m).map (· + c))
            simp only [List.length_take] at this
            omega
    · have hsplit : xs.map (· + c) = (xs.take m).map (· + c) ++ (xs.drop m).map (· + c) := by
        rw [← List.map_append, List.take_append_drop]
      have hlen : ((xs.take m).map (· + c)).length = ((xs.take m).map (· + c)).length := rfl
      calc diffCount (xs.map (· + c)) ((xs.take m).map (· + c) ++ xs.drop m)
          = diffCount ((xs.take m).map (· + c) ++ (xs.drop m).map (· + c))
              ((xs.take m).map (· + c) ++ xs.drop m) := by rw [← hsplit]
        _ = diffCount ((xs.take m).map (· + c)) ((xs.take m).map (· + c)) +
              diffCount ((xs.drop m).map (· + c)) (xs.drop m) :=
            diffCount_append _ _ _ _ hlen
        _ ≤ k := by
            rw [diffCount_self]
            have := diffCount_le_length ((xs.drop m).map (· + c)) (xs.drop m)
            simp only [List.length_map, List.length_drop] at this
            omega

/-! ## 3. The two thresholds coincide -/

/-- **Bridge theorem.**  The statistical breakdown of the median and the failure
of unique decoding for the translation code happen at exactly the same budget.
The breakdown point of the median is therefore a purely coding-theoretic
quantity: half the minimum distance of the translation orbit. -/
theorem breakdown_iff_confusable (xs : List ℚ) (hxs : xs ≠ []) {c : ℚ} (hc : c ≠ 0) (k : ℕ) :
    ¬ MedianBounded xs k ↔ Confusable xs c k := by
  rw [confusable_iff hc, medianBounded_iff xs hxs, not_lt]

/-- Explicit form for the 16-sample measured run: the median survives budget `k`
iff the measured distribution cannot be confused with any of its translates. -/
theorem ratios16_breakdown_iff_confusable {c : ℚ} (hc : c ≠ 0) (k : ℕ) :
    ¬ MedianBounded ratios16 k ↔ Confusable ratios16 c k :=
  breakdown_iff_confusable ratios16 (by rw [ratios16_eq]; simp) hc k

/-- Explicit form for the 8-sample measured run. -/
theorem ratios8_breakdown_iff_confusable {c : ℚ} (hc : c ≠ 0) (k : ℕ) :
    ¬ MedianBounded ratios8 k ↔ Confusable ratios8 c k :=
  breakdown_iff_confusable ratios8 (by rw [ratios8_eq]; simp) hc k

/-- The measured 16-sample distribution is confusable with any non-trivial
translate at budget 8, but not at budget 7. -/
theorem ratios16_confusable_threshold {c : ℚ} (hc : c ≠ 0) :
    Confusable ratios16 c 8 ∧ ¬ Confusable ratios16 c 7 := by
  constructor
  · exact (confusable_iff hc ratios16 8).mpr (by rw [length_ratios16])
  · intro h
    have := (confusable_iff hc ratios16 7).mp h
    rw [length_ratios16] at this
    omega

/-- The measured 8-sample distribution is confusable at budget 4 but not at 3. -/
theorem ratios8_confusable_threshold {c : ℚ} (hc : c ≠ 0) :
    Confusable ratios8 c 4 ∧ ¬ Confusable ratios8 c 3 := by
  constructor
  · exact (confusable_iff hc ratios8 4).mpr (by rw [length_ratios8])
  · intro h
    have := (confusable_iff hc ratios8 3).mp h
    rw [length_ratios8] at this
    omega

end MedianBreakdown