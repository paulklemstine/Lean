/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Thue–Morse generating function and its coefficient sequence

Let `T(x) = ∏_{k≥0} (1 - x^{2^k})`.  Expanding the product, the coefficient of
`x^n` is `(-1)^{s₂(n)}`, where `s₂(n)` is the number of `1`s in the binary
expansion of `n` (equivalently, the digit sum in base `2`); this is because the
binary representation of `n` is the *unique* way to write `n` as a sum of
distinct powers of two, and each factor `(1 - x^{2^k})` contributes a sign
`-1` when its term is selected.

We call this the **Thue–Morse sign sequence** `tm n = (-1)^{s₂(n)}`.

This file establishes the two defining functional recurrences of `tm` (which are
the coefficient-level form of the functional equation `T(x) = (1 - x)·T(x²)`),
together with the fact that every value is `±1`.  The latter is exactly the
statement that the `2`-adic valuation of the coefficients of `T(x)^1` is `0`
everywhere — the trivial (`m = 1`) case of the exact-valuation program pursued
in `Power5.lean`.

## Main results

* `tm_two_mul`         : `tm (2*n) = tm n`
* `tm_two_mul_add_one` : `tm (2*n+1) = - tm n`     (sign flip)
* `tm_eq_one_or_neg_one`, `tm_sq` : every value is `±1`
* `tm_not_two_dvd`     : `¬ 2 ∣ tm n`               (the `m = 1` valuation: `ν₂ = 0`)

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The coefficients of `T(x) = ∏(1-x^{2^k})` are the
  Thue–Morse signs `(-1)^{s₂(n)}`, and they satisfy `T(x) = (1-x) T(x²)`, whose
  coefficient form is `tm(2n)=tm n`, `tm(2n+1) = -tm n`.
Experiment (Experimenter): Verified computationally that
  `[tm 0,…,tm 15] = [1,-1,-1,1,-1,1,1,-1,-1,1,1,-1,1,-1,-1,1]`, matching the
  expansion of `∏_{k}(1-x^{2^k})` up to degree 15, and confirming both
  recurrences on `0 ≤ n ≤ 4000`.
Analysis (Analyst): The recurrences follow from `Nat.digits_def'`: appending the
  last binary digit `n % 2` either adds `0` (even) or `1` (odd) to the digit sum.
Critique (Critic): `tm` is genuinely `±1`-valued, so `¬ 2 ∣ tm n`; this is the
  base (`m=1`) case of the valuation program and is not vacuous.
-- !-- Lab Notes -- !--
-/

import Mathlib

namespace ThueMorsePower

open scoped BigOperators

/-- The Thue–Morse sign sequence: the coefficient of `x^n` in
`T(x) = ∏_{k≥0} (1 - x^{2^k})`, equal to `(-1)^{s₂(n)}`. -/
def tm (n : ℕ) : ℤ := (-1) ^ ((Nat.digits 2 n).sum)

@[simp] theorem tm_zero : tm 0 = 1 := by simp [tm]

/-- Coefficient-level functional equation, even part: `tm (2n) = tm n`. -/
theorem tm_two_mul (n : ℕ) : tm (2 * n) = tm n := by
  unfold tm
  rcases Nat.eq_zero_or_pos n with h | h
  · subst h; simp
  · rw [Nat.digits_def' (by norm_num : 2 ≤ 2) (by omega)]
    simp

/-- Coefficient-level functional equation, odd part: `tm (2n+1) = - tm n`. -/
theorem tm_two_mul_add_one (n : ℕ) : tm (2 * n + 1) = - tm n := by
  unfold tm
  rw [Nat.digits_def' (by norm_num : 2 ≤ 2) (by omega)]
  have h1 : (2 * n + 1) % 2 = 1 := by omega
  have h2 : (2 * n + 1) / 2 = n := by omega
  rw [h1, h2]
  simp
  ring

/-- Every value of the Thue–Morse sign sequence is `±1`. -/
theorem tm_eq_one_or_neg_one (n : ℕ) : tm n = 1 ∨ tm n = -1 := by
  unfold tm
  rcases Nat.even_or_odd ((Nat.digits 2 n).sum) with ⟨k, hk⟩ | ⟨k, hk⟩
  · left; rw [hk]; rw [show k + k = 2 * k by ring, pow_mul]; simp
  · right; rw [hk]; rw [pow_add, pow_mul]; simp

/-- The Thue–Morse signs square to `1`. -/
theorem tm_sq (n : ℕ) : tm n * tm n = 1 := by
  rcases tm_eq_one_or_neg_one n with h | h <;> rw [h] <;> ring

/-- The `m = 1` valuation statement: the coefficients of `T(x)^1` are never even,
i.e. their `2`-adic valuation is `0`. -/
theorem tm_not_two_dvd (n : ℕ) : ¬ (2 : ℤ) ∣ tm n := by
  rcases tm_eq_one_or_neg_one n with h | h <;> rw [h] <;> decide

end ThueMorsePower