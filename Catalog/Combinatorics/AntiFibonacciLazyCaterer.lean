/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The listed "anti-Fibonacci" terms are the lazy-caterer numbers — and they are *not* sum-free

The anti-Fibonacci task lists the opening terms `1, 1, 2, 4, 7, 11, 16, …` and claims they are
produced by the rule "each term avoids being the sum of the two previous terms".  Those terms
are the **lazy-caterer numbers** `lc n = 1 + C(n, 2)` (OEIS A000124, the maximal number of
pieces of a pancake cut by `n` straight lines), a *quadratic* sequence — a different object from
the genuinely greedy sum-avoiding sequence studied in `AntiFibonacci`.

This companion file pins down that object and stress-tests the "avoids sums" claim:

* `lc_recurrence` — the defining recurrence `lc (n+1) = lc n + n`;
* `lc_two_mul` — the exact closed form `2·lc n + n = n² + 2` (i.e. `lc n = 1 + n(n-1)/2`);
* `lc_sum_coincidence` — **the sum-avoidance claim is false**: `lc (n+1) = lc n + lc (n-1)`
  holds *exactly* at `n = 1` and `n = 4` (giving `2 = 1 + 1` and `11 = 7 + 4`), and nowhere
  else.  So the listed sequence is *not* sum-free, contradicting the informal description.

-- !-- Lab Notes -- !--
HYPOTHESIS.  The listed terms `1,1,2,4,7,11,16` satisfy "each term is not the sum of the two
previous terms".

EXPERIMENT.  Differencing the list gives `0,1,2,3,4,5`, so `lc n = 1 + n(n-1)/2`, the
lazy-caterer numbers.  Testing the Fibonacci-type equation `lc(n+1) = lc n + lc(n-1)` on the
list finds two hits: `lc 2 = 2 = 1 + 1 = lc 1 + lc 0` and `lc 5 = 11 = 7 + 4 = lc 4 + lc 3`.

ANALYSIS.  Via the recurrence `lc(n+1) = lc n + n`, the equation `lc(n+1) = lc n + lc(n-1)`
reduces to `lc(n-1) = n`, i.e. `1 + (n-1)(n-2)/2 = n`, i.e. `k² = 3k` after the substitution
`n = k+1`; the only solutions are `k ∈ {0,3}`, i.e. `n ∈ {1,4}`.  Hence the listed terms
violate their own stated defining property at exactly two indices.

CRITIQUE.  This does not merely nitpick notation: it shows the informal problem statement is
inconsistent.  The two natural readings — "listed terms" and "greedy sum-avoiding" — are
*different sequences*, one quadratic and not sum-free (this file), one linear and genuinely
sum-free (`AntiFibonacci`).  The corrected asymptotics are `lc n ~ n²/2` (this file) versus
`antiFib n ~ 3n/2` (the greedy object); neither is the conjectured `n²/4`.

SYNTHESIS.  The listed "anti-Fibonacci" terms are the lazy-caterer numbers; they grow like
`n²/2` and fail the anti-Fibonacci property at `n = 1` and `n = 4`.  The genuine greedy
anti-Fibonacci sequence is a separate, provably sum-free, linear object.
-/

namespace AntiFibonacciLazyCaterer

/-- The lazy-caterer numbers `lc n = 1 + C(n, 2)`; opening terms `1, 1, 2, 4, 7, 11, 16, …`.
These are exactly the terms listed in the informal "anti-Fibonacci" description. -/
def lc (n : ℕ) : ℕ := 1 + n.choose 2

/-- The listed terms are reproduced exactly. -/
example : (List.range 7).map lc = [1, 1, 2, 4, 7, 11, 16] := by decide

/-- The defining recurrence `lc (n+1) = lc n + n`. -/
theorem lc_recurrence (n : ℕ) : lc (n + 1) = lc n + n := by
  unfold lc
  rw [Nat.choose_succ_succ n 1]
  simp [Nat.choose_one_right, Nat.add_comm, Nat.add_left_comm]

/-- The exact closed form, stated without truncated subtraction: `2·lc n + n = n² + 2`,
equivalently `lc n = 1 + n(n-1)/2`.  In particular `lc n ~ n²/2`. -/
theorem lc_two_mul (n : ℕ) : 2 * lc n + n = n ^ 2 + 2 := by
  unfold lc
  rw [Nat.choose_two_right]
  have h2 : 2 * (n * (n - 1) / 2) = n * (n - 1) :=
    Nat.mul_div_cancel' (Nat.even_mul_pred_self n).two_dvd
  have key : n * (n - 1) + n = n ^ 2 := by
    cases n with
    | zero => rfl
    | succ m => have h : m + 1 - 1 = m := rfl; rw [h]; ring
  omega

/-- **Main theorem (the "avoids sums" claim is false).**  The Fibonacci-type coincidence
`lc (n+1) = lc n + lc (n-1)` holds for `n ≥ 1` *exactly* when `n = 1` or `n = 4`
(the cases `2 = 1 + 1` and `11 = 7 + 4`).  Thus the listed anti-Fibonacci terms are **not**
sum-free, contradicting the informal description. -/
theorem lc_sum_coincidence (n : ℕ) (hn : 1 ≤ n) :
    lc (n + 1) = lc n + lc (n - 1) ↔ (n = 1 ∨ n = 4) := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  rw [lc_recurrence, lc_recurrence]
  unfold lc
  rw [Nat.choose_two_right]
  have h2 : 2 * (k * (k - 1) / 2) = k * (k - 1) :=
    Nat.mul_div_cancel' (Nat.even_mul_pred_self k).two_dvd
  have key : k * (k - 1) + k = k ^ 2 := by
    cases k with
    | zero => rfl
    | succ m => have h : m + 1 - 1 = m := rfl; rw [h]; ring
  constructor
  · intro h
    have hsq : k ^ 2 = 3 * k := by omega
    have hk : k = 0 ∨ k = 3 := by
      rcases Nat.eq_zero_or_pos k with h0 | hp
      · exact Or.inl h0
      · exact Or.inr (Nat.eq_of_mul_eq_mul_right hp (by rw [← pow_two]; exact hsq))
    omega
  · rintro (h | h)
    · have hk : k = 0 := by omega
      subst hk; decide
    · have hk : k = 3 := by omega
      subst hk; decide

end AntiFibonacciLazyCaterer