/-
Copyright (c) 2025. All rights reserved.

# The Binary Sum-of-Digits Function and Subadditivity

## Overview

This file develops the foundational arithmetic of the **binary sum-of-digits
function** `s₂(n) = (Nat.digits 2 n).sum`, the central object in Cusick's
conjecture on the density of integers `n` with `s₂(n + t) ≥ s₂(n)`.

The headline results here are:

* `CusickSumDigits.s2_add_val` — the additive form of **Legendre's formula** for
  `p = 2`: `s₂(n) + v₂(n!) = n`, where `v₂` is the 2-adic valuation.
* `CusickSumDigits.s2_subadditive` — **subadditivity** `s₂(a + b) ≤ s₂(a) + s₂(b)`,
  derived from Legendre's formula together with the divisibility
  `a! · b! ∣ (a + b)!`.
* `CusickSumDigits.s2_block_sum` — the **average digit sum** over a dyadic block:
  `∑_{x < 2ᵏ} s₂(x) = k · 2^{k-1}`, i.e. the mean of `s₂` over `[0, 2ᵏ)` is `k/2`.

These supply the quantitative skeleton on which the carry reformulation
(in `CusickCarryReformulation.lean`) and the density witnesses
(in `CusickDensityWitness.lean`) are built.

This file relates to the catalog references
`binary_sum_of_digits_function` and `2_adic_valuation_binomial_coefficients`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The function `s₂` should be subadditive, and its
behaviour should be completely governed by 2-adic valuations of factorials and
binomial coefficients (Legendre / Kummer).  If so, the Cusick inequality
`s₂(n+t) ≥ s₂(n)` becomes a *carry-counting* statement.

Experiment (Experimenter): Mathlib supplies `sub_one_mul_padicValNat_factorial`
(Legendre) and `sub_one_mul_padicValNat_choose_eq_sub_sum_digits'` (Kummer).
The subtraction form of these lemmas is in `ℕ`, so naive `omega` fails to deduce
subadditivity directly (truncated subtraction hides the inequality).  The fix:
go through the *additive* Legendre identity `s₂(n) + v₂(n!) = n`, combine with
`a!·b! ∣ (a+b)!` and monotonicity of `v₂` under divisibility.

Analysis (Analyst): The additive reformulation is the load-bearing trick — once
`v₂` is monotone under `∣` and `v₂` is additive on products, subadditivity is a
single `omega`.  The block-sum theorem (`Nat.sum_sum_digits_eq`) pins the mean of
`s₂` at exactly `k/2`, which is *why* the Cusick density hovers around `1/2`.

Critique (Critic): All theorems are general over `ℕ` (no finite `decide`).  Each
proof uses an insight-bearing step (`omega` over the Legendre identities, or a
divisibility transport).  No theorem is vacuous: `s2_subadditive` is tight (e.g.
`a = b = 1` gives equality) and `s2_block_sum` is an exact equality, not a bound.
-/

import Mathlib

open Nat Finset

namespace CusickSumDigits

/-- The binary sum-of-digits function `s₂(n)`: the number of `1`s in the binary
expansion of `n` (equivalently, the sum of its base-2 digits). -/
noncomputable def s2 (n : ℕ) : ℕ := (Nat.digits 2 n).sum

@[simp] theorem s2_zero : s2 0 = 0 := by simp [s2]

@[simp] theorem s2_one : s2 1 = 1 := by simp [s2]

/-- `s₂(n) ≤ n`: the digit sum never exceeds the number. -/
theorem s2_le (n : ℕ) : s2 n ≤ n := Nat.digit_sum_le 2 n

/-- Monotonicity of the 2-adic valuation under divisibility. -/
theorem padicVal2_mono {m k : ℕ} (hk : k ≠ 0) (h : m ∣ k) :
    padicValNat 2 m ≤ padicValNat 2 k := by
  have : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have key : (2 : ℕ) ^ (padicValNat 2 m) ∣ k := dvd_trans pow_padicValNat_dvd h
  exact (padicValNat_dvd_iff_le hk).mp key

/-- **Legendre's formula, additive form** (`p = 2`): the digit sum and the
2-adic valuation of the factorial partition `n`, i.e. `s₂(n) + v₂(n!) = n`. -/
theorem s2_add_val (n : ℕ) : s2 n + padicValNat 2 n.factorial = n := by
  have h := @sub_one_mul_padicValNat_factorial 2 ⟨Nat.prime_two⟩ n
  have hle := Nat.digit_sum_le 2 n
  simp only [s2] at *
  omega

/-- **Subadditivity of the binary digit sum**: `s₂(a + b) ≤ s₂(a) + s₂(b)`.

Proof via Legendre's formula and the integrality of `C(a+b, a) = (a+b)!/(a!b!)`:
since `a!·b! ∣ (a+b)!`, the valuation `v₂((a+b)!) ≥ v₂(a!) + v₂(b!)`, and the
additive Legendre identity turns this into the digit-sum inequality. -/
theorem s2_subadditive (a b : ℕ) : s2 (a + b) ≤ s2 a + s2 b := by
  have hdvd : a.factorial * b.factorial ∣ (a + b).factorial :=
    Nat.factorial_mul_factorial_dvd_factorial_add a b
  have hmono := padicVal2_mono (Nat.factorial_ne_zero (a + b)) hdvd
  have hmul : padicValNat 2 (a.factorial * b.factorial)
      = padicValNat 2 a.factorial + padicValNat 2 b.factorial :=
    padicValNat.mul (Nat.factorial_ne_zero _) (Nat.factorial_ne_zero _)
  have e1 := s2_add_val a
  have e2 := s2_add_val b
  have e3 := s2_add_val (a + b)
  omega

/-- **Average digit sum over a dyadic block.** The total of `s₂` over the block
`[0, 2ᵏ)` is exactly `k · 2^{k-1}`; equivalently the mean of `s₂` over the block
is `k/2`.  This is the quantitative reason the Cusick density sits near `1/2`. -/
theorem s2_block_sum (k : ℕ) : ∑ x ∈ range (2 ^ k), s2 x = k * 2 ^ (k - 1) := by
  have := Nat.sum_sum_digits_eq (b := 2) (by norm_num) k
  simpa [s2] using this

end CusickSumDigits