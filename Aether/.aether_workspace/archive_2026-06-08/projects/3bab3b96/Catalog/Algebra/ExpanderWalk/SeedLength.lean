/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Seed Length Bounds for Expander Walk Derandomization

This file formalizes the quantitative "linear seed length" slogan:
if the state space has cardinality N ≤ 3^n, then the seed length
(number of random bits to specify an initial state) is O(n).

The key inequality is:  3^n ≤ 2^(2n)  for all n,
which means ⌈log₂(3^n)⌉ ≤ 2n, so the seed length is at most 2n bits.

Combined with the spectral mixing theorems from Core.lean, this yields:
- t walk steps on a 3^n-vertex expander need O(n + t) random bits total,
- for constant t, this is O(n) — linear seed derandomization.
-/

import Mathlib

open Finset Real BigOperators

/-! ## Elementary power inequalities -/

/-
3^n ≤ 4^n for all natural numbers n.
-/
theorem pow_three_le_pow_four (n : ℕ) : 3 ^ n ≤ 4 ^ n := by
  gcongr ; norm_num

/-
The key seed-length theorem: 3^n can be encoded in 2n bits.
    Equivalently, 3^n ≤ 2^(2n).
-/
theorem three_pow_le_two_pow_two_mul (n : ℕ) : 3 ^ n ≤ 2 ^ (2 * n) := by
  simpa only [ pow_mul ] using pow_le_pow_left' ( by norm_num ) _

/-
Seed length bound: for a state space of size at most 3^n,
    there exists k ≤ 2n such that the state space fits in k bits.
-/
theorem seed_length_bound (n : ℕ) :
    ∃ k : ℕ, k ≤ 2 * n ∧ 3 ^ n ≤ 2 ^ k := by
  use 2 * n;
  exact ⟨ le_rfl, three_pow_le_two_pow_two_mul n ⟩

/-
General seed length bound: for any N ≤ 3^n, N fits in 2n bits.
-/
theorem seed_bits_linear_of_card_le_three_pow
    (N n : ℕ) (hN : N ≤ 3 ^ n) :
    ∃ k : ℕ, k ≤ 2 * n ∧ N ≤ 2 ^ k := by
  exact ⟨ 2 * n, le_rfl, hN.trans <| by rw [ pow_mul ] ; gcongr ; norm_num ⟩

/-! ## Walk cost analysis -/

/-
Total random bits for an expander walk of length t on a state space
    of size ≤ 3^n on a d-regular graph: the initial vertex costs ⌈log₂ N⌉ bits,
    and each step costs ⌈log₂ d⌉ bits. For constant d this is O(n + t).
-/
theorem total_seed_length
    (n t d : ℕ) (hd : 0 < d) :
    ∃ k : ℕ, k ≤ 2 * n + t * (Nat.log 2 d + 1) ∧
      3 ^ n * d ^ t ≤ 2 ^ k := by
  refine' ⟨ 2 * n + t * ( Nat.log 2 d + 1 ), by nlinarith, _ ⟩;
  rw [ pow_add, pow_mul, pow_mul' ];
  gcongr;
  · grind;
  · exact le_of_lt ( Nat.lt_pow_succ_log_self ( by decide ) _ )

/-! ## Logarithmic bound via real logarithms -/

/-
log₂(3) < 2, stated as a real inequality.
-/
theorem log_base2_three_lt_two : Real.log 3 / Real.log 2 < 2 := by
  rw [ div_lt_iff₀ ( by positivity ), ← log_rpow, Real.log_lt_log_iff ] <;> norm_num