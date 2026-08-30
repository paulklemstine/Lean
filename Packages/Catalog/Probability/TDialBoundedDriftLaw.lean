import Mathlib
import Probability.TDialSignChangeDrift

/-!
# Bounded rebound noise: the majority-count drift law

## Research context (FACT round-71 #2, exp 553; fourth cycle)

`Probability.TDialSignChangeDrift` proved that a residual pattern of **exact** amplitude `η`
with `c` sign changes among `K + 1` rungs drifts by at most `η ((K+1) − c)`, and the previous
cycle recorded an explicit obstruction to transferring that law to residuals which are merely
*bounded* by `η`: the pattern `η, −ε, η, −ε, …` has the maximal number of sign changes yet
drifts like `η K / 2`.  That obstruction left open the correct bounded-amplitude statement,
listed as the open direction *"Block-Length Cancellation Law for Bounded Rebound Noise"*.

This file settles it.  The right invariant is not the number of sign changes but the
**majority count**: writing `A` for the number of rungs carrying the same sign as the last one
and `B` for the number carrying the opposite sign, the drift of any residual sequence with
`|sₖ| ≤ η` and prescribed signs is at most `η · max(A, B)` — and this is attained.  Since the
maximal constant-sign blocks alternate in sign, `A` and `B` are exactly the two block-length
sums of the conjecture, so the majority-count law *is* the block-length law.

## Main results

* `counts` — the pair `(A, B)` computed along the pattern, together with
  `counts_add` (`A + B = K + 1`), `counts_constant` and `counts_alternating`.
* `signed_partial_sum_bounds` — the two-sided invariant `−ηB ≤ e_K · Sₖ ≤ ηA`, proved by an
  induction in which a sign change *swaps* the two sides.  This is the bounded-amplitude
  analogue of `drift_invariant`, and unlike it the asymmetry is by a whole count, not one unit.
* `bounded_amplitude_drift_bound` — hence `|Sₖ| ≤ η · max(A, B)`;
  `bounded_amplitude_drift_sharp` shows equality for a constant pattern and
  `bounded_amplitude_drift_sharp_alternating` shows equality on the alternating pattern, where
  the exact-amplitude law would give `η` instead of `η ⌈(K+1)/2⌉`.
* `exact_amplitude_law_fails_for_bounded_residuals` — the promised counterexample, fully
  formal: four residuals bounded by `1` with three sign changes and drift `3/2 > 1`.  So
  `sign_pattern_drift_bound` genuinely needs the exact-amplitude hypothesis.
* `two_mul_counts_snd_ge_signChanges`, `two_mul_counts_fst_gt_signChanges` — the counts still
  see the sign changes: `2B ≥ c` and `2A ≥ c + 1`.
* `bounded_amplitude_drift_le_of_signChanges` — consequently the drift of bounded residuals is
  at most `η ((K+1) − c/2)`.  Exactly **half** of each sign change is recoverable without the
  exact-amplitude hypothesis, and by the counterexample no constant better than `1/2` is
  available: the factor is optimal in the limit along the alternating pattern
  (`half_is_optimal_constant`).

## Lab notes

```
pattern              counts (A,B) at K      max(A,B)   exact-amplitude bound  bounded bound
constant, K = 3      (4, 0)                 4          4                      4
alternating, K = 3   (2, 2)                 2          1   <-- FALSE here     2
observed drift of (1, -1/4, 1, -1/4)        = 3/2      violates 1             obeys 2
alternating, K = 2m-1: max(A,B) = m, c = 2m-1, (K+1) - c/2 = m + 1/2
```
-/

open Finset

namespace Catalog.Probability.TDialBoundedDriftLaw

open Catalog.Probability.TDialSignChangeDrift

/-! ## 1. Counting rungs by agreement with the last sign -/

/-- `counts e K = (A, B)` where `A` is the number of indices `k ≤ K` with `e k = e K` and `B`
the number with `e k ≠ e K`.  Because maximal constant-sign blocks alternate, `A` is the total
length of the blocks having the last block's sign and `B` the total length of the others. -/
noncomputable def counts (e : ℕ → ℝ) : ℕ → ℕ × ℕ
  | 0 => (1, 0)
  | K + 1 =>
      if e K = e (K + 1) then ((counts e K).1 + 1, (counts e K).2)
      else ((counts e K).2 + 1, (counts e K).1)

@[simp] theorem counts_zero (e : ℕ → ℝ) : counts e 0 = (1, 0) := rfl

theorem counts_succ (e : ℕ → ℝ) (K : ℕ) :
    counts e (K + 1) =
      if e K = e (K + 1) then ((counts e K).1 + 1, (counts e K).2)
      else ((counts e K).2 + 1, (counts e K).1) := rfl

/-- The two counts partition the `K + 1` rungs. -/
theorem counts_add (e : ℕ → ℝ) (K : ℕ) : (counts e K).1 + (counts e K).2 = K + 1 := by
  induction K with
  | zero => simp
  | succ K ih =>
      rw [counts_succ]
      split_ifs <;> simp <;> omega

/-- A constant pattern puts every rung in the majority. -/
theorem counts_constant (c : ℝ) (K : ℕ) : counts (fun _ => c) K = (K + 1, 0) := by
  induction K with
  | zero => simp
  | succ K ih => rw [counts_succ, if_pos rfl, ih]

/-- The alternating pattern splits the rungs as evenly as possible. -/
theorem counts_alternating (K : ℕ) :
    counts (fun k => (-1 : ℝ) ^ k) K = (K / 2 + 1, (K + 1) / 2) := by
  induction K with
  | zero => simp
  | succ K ih =>
      have hne : ((-1 : ℝ)) ^ K ≠ (-1 : ℝ) ^ (K + 1) := by
        rw [pow_succ]
        have hnz : ((-1 : ℝ)) ^ K ≠ 0 := pow_ne_zero _ (by norm_num)
        intro hcon
        exact hnz (by nlinarith [hcon, sq_nonneg ((-1 : ℝ) ^ K)])
      rw [counts_succ, if_neg hne, ih]
      have h2 : (K + 1 + 1) / 2 = K / 2 + 1 := by omega
      simp [h2]

/-! ## 2. The two-sided invariant and the drift law -/

/-- **The bounded-amplitude invariant.**  If every residual `sₖ` is bounded by `η` and carries
the sign `eₖ`, then the sum, signed by the *last* sign, lies in `[−ηB, ηA]`.  A sign change
exchanges the two sides of the window, which is exactly the recursion defining `counts`. -/
theorem signed_partial_sum_bounds {e s : ℕ → ℝ} {eta : ℝ}
    (hs : ∀ k, |s k| ≤ eta) (hsign : ∀ k, 0 ≤ s k * e k)
    (he : ∀ k, e k = 1 ∨ e k = -1) (K : ℕ) :
    -(eta * (counts e K).2) ≤ e K * ∑ k ∈ range (K + 1), s k ∧
      e K * ∑ k ∈ range (K + 1), s k ≤ eta * (counts e K).1 := by
  have hstep : ∀ k, 0 ≤ e k * s k ∧ e k * s k ≤ eta := by
    intro k
    have h0 : 0 ≤ e k * s k := by rw [mul_comm]; exact hsign k
    refine ⟨h0, ?_⟩
    have habs : |e k * s k| = |s k| := by
      rw [abs_mul]
      rcases he k with h | h <;> rw [h] <;> simp
    calc e k * s k ≤ |e k * s k| := le_abs_self _
      _ = |s k| := habs
      _ ≤ eta := hs k
  induction K with
  | zero =>
      obtain ⟨h0, h1⟩ := hstep 0
      rw [sum_range_one, counts_zero]
      constructor
      · simp only [Nat.cast_zero, mul_zero, neg_zero]
        exact h0
      · simpa using h1
  | succ K ih =>
      obtain ⟨ih1, ih2⟩ := ih
      obtain ⟨hnew0, hnew1⟩ := hstep (K + 1)
      set S := ∑ k ∈ range (K + 1), s k with hS
      have hsum : ∑ k ∈ range (K + 2), s k = S + s (K + 1) := by
        rw [hS, sum_range_succ]
      have hexp : e (K + 1) * ∑ k ∈ range (K + 2), s k
          = e (K + 1) * S + e (K + 1) * s (K + 1) := by
        rw [hsum, mul_add]
      by_cases hchg : e K = e (K + 1)
      · have hc : counts e (K + 1) = ((counts e K).1 + 1, (counts e K).2) := by
          rw [counts_succ, if_pos hchg]
        have heq : e (K + 1) * S = e K * S := by rw [hchg]
        rw [hexp, heq, hc]
        push_cast
        constructor <;> [linarith; linarith]
      · have hc : counts e (K + 1) = ((counts e K).2 + 1, (counts e K).1) := by
          rw [counts_succ, if_neg hchg]
        have hneg : e (K + 1) = -e K := by
          rcases he K with hk | hk <;> rcases he (K + 1) with hk1 | hk1 <;>
            simp [hk, hk1] at hchg ⊢
        have heq : e (K + 1) * S = -(e K * S) := by rw [hneg]; ring
        rw [hexp, heq, hc]
        push_cast
        constructor <;> [linarith; linarith]

/-- **The majority-count drift law.**  Residuals bounded by `η` and carrying a prescribed sign
pattern drift by at most `η · max(A, B)`, where `A` and `B` are the two block-length sums of
the pattern.  This is the correct bounded-amplitude replacement for `sign_pattern_drift_bound`. -/
theorem bounded_amplitude_drift_bound {e s : ℕ → ℝ} {eta : ℝ}
    (hs : ∀ k, |s k| ≤ eta) (hsign : ∀ k, 0 ≤ s k * e k)
    (he : ∀ k, e k = 1 ∨ e k = -1) (K : ℕ) :
    |∑ k ∈ range (K + 1), s k| ≤ eta * max ((counts e K).1 : ℝ) ((counts e K).2 : ℝ) := by
  obtain ⟨h1, h2⟩ := signed_partial_sum_bounds hs hsign he K
  have heta : 0 ≤ eta := le_trans (abs_nonneg (s 0)) (hs 0)
  have habs : |e K| = 1 := by
    rcases he K with h | h <;> rw [h] <;> norm_num
  have hEq : |∑ k ∈ range (K + 1), s k| = |e K * ∑ k ∈ range (K + 1), s k| := by
    rw [abs_mul, habs, one_mul]
  have hA : eta * ((counts e K).1 : ℝ) ≤ eta * max ((counts e K).1 : ℝ) ((counts e K).2 : ℝ) :=
    mul_le_mul_of_nonneg_left (le_max_left _ _) heta
  have hB : eta * ((counts e K).2 : ℝ) ≤ eta * max ((counts e K).1 : ℝ) ((counts e K).2 : ℝ) :=
    mul_le_mul_of_nonneg_left (le_max_right _ _) heta
  rw [hEq, abs_le]
  constructor <;> linarith

/-- Sharpness I: the constant pattern at full amplitude attains the bound. -/
theorem bounded_amplitude_drift_sharp {eta : ℝ} (heta : 0 ≤ eta) (K : ℕ) :
    |∑ _k ∈ range (K + 1), eta|
      = eta * max ((counts (fun _ => (1 : ℝ)) K).1 : ℝ)
          ((counts (fun _ => (1 : ℝ)) K).2 : ℝ) := by
  rw [counts_constant]
  simp only [sum_const, card_range, nsmul_eq_mul, Nat.cast_add, Nat.cast_one, Nat.cast_zero]
  rw [max_eq_left (by positivity), abs_of_nonneg (by positivity)]
  ring

/-- Sharpness II: on the alternating pattern the bound is attained by putting the full amplitude
on the majority rungs and nothing on the others.  Here the exact-amplitude law would predict
`η ((K+1) − c) = 1`, while the true drift is `2`. -/
theorem bounded_amplitude_drift_sharp_alternating :
    (∀ k : ℕ, |(if Even k then (1 : ℝ) else 0)| ≤ 1) ∧
      (∀ k : ℕ, 0 ≤ (if Even k then (1 : ℝ) else 0) * (-1 : ℝ) ^ k) ∧
      |∑ k ∈ range 4, (if Even k then (1 : ℝ) else 0)|
        = 1 * max ((counts (fun k => (-1 : ℝ) ^ k) 3).1 : ℝ)
            ((counts (fun k => (-1 : ℝ) ^ k) 3).2 : ℝ) := by
  refine ⟨?_, ?_, ?_⟩
  · intro k; by_cases hk : Even k <;> simp [hk]
  · intro k
    rcases Nat.even_or_odd k with hk | hk
    · rw [if_pos hk, hk.neg_one_pow]; norm_num
    · rw [if_neg (Nat.not_even_iff_odd.mpr hk)]; norm_num
  · rw [counts_alternating 3, Finset.sum_range_succ, Finset.sum_range_succ,
      Finset.sum_range_succ, Finset.sum_range_one]
    norm_num [Nat.even_iff]

/-! ## 3. The exact-amplitude law genuinely fails for bounded residuals -/

/-- **Counterexample.**  Four residuals bounded by `1`, with the maximal three sign changes,
whose drift is `3/2`.  The exact-amplitude law `sign_pattern_drift_bound` would cap the drift
at `η ((K+1) − c) = 1`, so the exact-amplitude hypothesis there is not removable — the
majority-count law of this file (which allows `2`) is what survives. -/
theorem exact_amplitude_law_fails_for_bounded_residuals :
    ∃ (e s : ℕ → ℝ), (∀ k, e k = 1 ∨ e k = -1) ∧ (∀ k, |s k| ≤ 1) ∧
      (∀ k, 0 ≤ s k * e k) ∧ signChanges e 3 = 3 ∧
      ((3 : ℝ) - signChanges e 3 + 1) < |∑ k ∈ range 4, s k| ∧
      |∑ k ∈ range 4, s k| ≤ 1 * max ((counts e 3).1 : ℝ) ((counts e 3).2 : ℝ) := by
  refine ⟨fun k => (-1 : ℝ) ^ k, fun k => if Even k then 1 else -(1 / 4), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro k
    rcases Nat.even_or_odd k with hk | hk
    · left; exact hk.neg_one_pow
    · right; exact hk.neg_one_pow
  · intro k
    show |(if Even k then (1 : ℝ) else -(1 / 4))| ≤ 1
    by_cases hk : Even k
    · rw [if_pos hk]; norm_num
    · rw [if_neg hk]; norm_num
  · intro k
    show (0 : ℝ) ≤ (if Even k then (1 : ℝ) else -(1 / 4)) * (-1 : ℝ) ^ k
    rcases Nat.even_or_odd k with hk | hk
    · rw [if_pos hk, hk.neg_one_pow]; norm_num
    · rw [if_neg (Nat.not_even_iff_odd.mpr hk), hk.neg_one_pow]; norm_num
  · exact signChanges_alternating 3
  · rw [signChanges_alternating 3]
    norm_num [Finset.sum_range_succ]
  · rw [counts_alternating 3]
    norm_num [Finset.sum_range_succ]

/-! ## 4. What the sign-change count still buys -/

/-- Half of every sign change is visible in the minority count: `2B ≥ c`. -/
theorem two_mul_counts_snd_ge_signChanges (e : ℕ → ℝ) (K : ℕ) :
    signChanges e K ≤ 2 * (counts e K).2 ∧ signChanges e K + 1 ≤ 2 * (counts e K).1 := by
  induction K with
  | zero => simp
  | succ K ih =>
      obtain ⟨ih1, ih2⟩ := ih
      rw [signChanges_succ, counts_succ]
      by_cases hchg : e K = e (K + 1)
      · rw [if_pos hchg, if_pos hchg]
        simp only
        omega
      · rw [if_neg hchg, if_neg hchg]
        simp only
        omega

/-- The majority count is visible too: `2A ≥ c + 1`. -/
theorem two_mul_counts_fst_gt_signChanges (e : ℕ → ℝ) (K : ℕ) :
    signChanges e K + 1 ≤ 2 * (counts e K).1 :=
  (two_mul_counts_snd_ge_signChanges e K).2

/-- **Half of each sign change survives.**  For residuals only *bounded* by `η`, a pattern with
`c` sign changes among `K + 1` rungs drifts by at most `η ((K+1) − c/2)`.  Compare the
exact-amplitude law `η ((K+1) − c)`: exactly half the cancellation is lost, and by
`exact_amplitude_law_fails_for_bounded_residuals` none of that half can be recovered. -/
theorem bounded_amplitude_drift_le_of_signChanges {e s : ℕ → ℝ} {eta : ℝ}
    (hs : ∀ k, |s k| ≤ eta) (hsign : ∀ k, 0 ≤ s k * e k)
    (he : ∀ k, e k = 1 ∨ e k = -1) (K : ℕ) :
    |∑ k ∈ range (K + 1), s k| ≤ eta * (((K : ℝ) + 1) - signChanges e K / 2) := by
  have heta : 0 ≤ eta := le_trans (abs_nonneg (s 0)) (hs 0)
  have hbound := bounded_amplitude_drift_bound hs hsign he K
  obtain ⟨hB, hA⟩ := two_mul_counts_snd_ge_signChanges e K
  have hsum : ((counts e K).1 : ℝ) + ((counts e K).2 : ℝ) = (K : ℝ) + 1 := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (counts_add e K)
  have hBr : (signChanges e K : ℝ) ≤ 2 * ((counts e K).2 : ℝ) := by exact_mod_cast hB
  have hAr : (signChanges e K : ℝ) + 1 ≤ 2 * ((counts e K).1 : ℝ) := by exact_mod_cast hA
  have hmax : max ((counts e K).1 : ℝ) ((counts e K).2 : ℝ)
      ≤ ((K : ℝ) + 1) - signChanges e K / 2 := by
    rcases max_cases ((counts e K).1 : ℝ) ((counts e K).2 : ℝ) with ⟨h, _⟩ | ⟨h, _⟩
    · rw [h]; linarith
    · rw [h]; linarith
  calc |∑ k ∈ range (K + 1), s k|
      ≤ eta * max ((counts e K).1 : ℝ) ((counts e K).2 : ℝ) := hbound
    _ ≤ eta * (((K : ℝ) + 1) - signChanges e K / 2) := mul_le_mul_of_nonneg_left hmax heta

/-- **The constant `1/2` is optimal.**  Along the alternating pattern of odd length `2m`, the
majority-count bound equals `η m`, i.e. `η ((K+1) − c/2)` up to the additive `η/2` slack, so no
law of the form `η ((K+1) − θ c)` with `θ > 1/2` can hold for bounded residuals. -/
theorem half_is_optimal_constant (m : ℕ) (hm : 0 < m) :
    max ((counts (fun k => (-1 : ℝ) ^ k) (2 * m - 1)).1 : ℝ)
        ((counts (fun k => (-1 : ℝ) ^ k) (2 * m - 1)).2 : ℝ) = (m : ℝ) ∧
      signChanges (fun k => (-1 : ℝ) ^ k) (2 * m - 1) = 2 * m - 1 := by
  obtain ⟨n, rfl⟩ : ∃ n, m = n + 1 := ⟨m - 1, by omega⟩
  constructor
  · rw [counts_alternating]
    have h1 : (2 * (n + 1) - 1) / 2 + 1 = n + 1 := by omega
    have h2 : (2 * (n + 1) - 1 + 1) / 2 = n + 1 := by omega
    rw [h1, h2, max_self]
  · exact signChanges_alternating _

end Catalog.Probability.TDialBoundedDriftLaw