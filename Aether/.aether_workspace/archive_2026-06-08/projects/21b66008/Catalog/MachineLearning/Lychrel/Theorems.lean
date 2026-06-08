/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reverse-and-Add Dynamics: Core Theorems

This file contains the main structural theorems about reverse-and-add dynamics,
palindrome obstructions, and digit-dynamical invariants.

## Main Results

* `revAdd_mod9` — The reverse-and-add map satisfies T(n) ≡ 2n (mod 9), connecting
  digit dynamics to modular arithmetic via digit-sum invariance.
* `self_le_revAdd` — Monotonicity: n ≤ T(n) for all n.
* `reverseNat_pos` — Digit reversal preserves positivity.
* `strict_growth_of_nonpalindrome` — Strict growth for non-palindromes without
  trailing zeros: if n is not a palindrome and n % 10 ≠ 0, then n < T(n).
* `palindrome_mod11_of_even_length` — Even-length base-10 palindromes are divisible
  by 11, establishing a cross-domain bridge between digit combinatorics and modular
  arithmetic. This provides a congruence sieve for palindrome avoidance.
* `revAddIter_monotone` — The iterated reverse-and-add sequence is monotone.
* `revAdd_mod9_iter` — Modular evolution: T^k(n) ≡ 2^k · n (mod 9).

## Proof Strategy

The proofs combine:
1. **Digit-list induction** with carry decomposition for structural results
2. **Modular arithmetic** (mod 9 via digit sums, mod 11 via alternating sums)
3. **List combinatorics** for palindrome characterization
-/

import Mathlib
import Speculative.Lychrel.Defs

namespace Lychrel

open Nat List

/-! ## Modular Invariants -/

/-- Helper: `Nat.ofDigits 10 L ≡ Nat.ofDigits 1 L (mod 9)`.
Since `ofDigits 1 L = L.sum`, this says a number is congruent to its digit sum mod 9. -/
theorem ofDigits10_mod9_eq_sum (L : List ℕ) :
    Nat.ofDigits 10 L % 9 = Nat.ofDigits 1 L % 9 := by
  induction L with
  | nil => simp [Nat.ofDigits]
  | cons h t ih =>
    simp only [Nat.ofDigits]
    omega

/-- The digit sum of a number equals n mod 9 (the classical "casting out nines"). -/
theorem digitSum_mod9 (n : ℕ) :
    (digits10 n).sum % 9 = n % 9 := by
  have h := ofDigits10_mod9_eq_sum (Nat.digits 10 n)
  rw [Nat.ofDigits_one, Nat.ofDigits_digits] at h
  exact h.symm

/-
Digit reversal preserves the digit sum.
-/
theorem reverseNat_digitSum (n : ℕ) :
    (digits10 (reverseNat n)).sum % 9 = (digits10 n).sum % 9 := by
  convert digitSum_mod9 ( reverseNat n ) using 1;
  unfold reverseNat;
  unfold ofDigits10; norm_num [ Nat.ofDigits_one, Nat.ofDigits_mod, List.sum_reverse ] ;

/-
**Theorem A (Modular Evolution Law):** The reverse-and-add map satisfies
`T(n) ≡ 2n (mod 9)`. This follows because `rev(n)` has the same digit sum as `n`,
hence `rev(n) ≡ n (mod 9)`, so `T(n) = n + rev(n) ≡ 2n (mod 9)`.

This is the fundamental modular invariant of reverse-and-add dynamics, connecting
the integer iteration to a deterministic finite-state evolution on ℤ/9ℤ.
-/
theorem revAdd_mod9 (n : ℕ) : revAdd n % 9 = (2 * n) % 9 := by
  have := ofDigits10_mod9_eq_sum ( Nat.digits 10 n ).reverse; simp_all +decide [ ← Nat.mul_mod, Nat.ofDigits_one ] ;
  exact Nat.ModEq.add_left _ this |> Nat.ModEq.trans <| by rw [ two_mul ] ; exact Nat.ModEq.add ( Nat.ModEq.refl _ ) ( digitSum_mod9 _ ) ;

/-! ## Growth Theorems -/

/-
Monotonicity of reverse-and-add: `n ≤ T(n)`.
-/
theorem self_le_revAdd (n : ℕ) : n ≤ revAdd n := by
  exact Nat.le_add_right _ _

/-
Digit reversal of a positive number is positive. The key fact is that
`Nat.digits b n` for `n > 0` produces a nonempty list whose last element
(the most significant digit) is nonzero.
-/
theorem reverseNat_pos {n : ℕ} (hn : 0 < n) : 0 < reverseNat n := by
  unfold reverseNat;
  unfold digits10 ofDigits10;
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | n ) <;> simp_all +decide [ ofDigits ];
  simp +arith +decide [ ofDigits_append, ofDigits ];
  contrapose! ih; simp_all +arith +decide [ ofDigits ] ;
  use (n + 11) / 10;
  exact ⟨ Nat.div_le_of_le_mul <| by linarith, Nat.div_pos ( by omega ) ( by decide ), by simp_all +decide [ ofDigits_append, ofDigits_singleton ] ⟩

/-
**Theorem C (Strict Growth):** For non-palindromic numbers with no trailing zero,
the reverse-and-add map strictly increases the value. This follows because
`reverseNat n > 0` whenever `n > 0`.

Combined with palindrome obstruction results, this shows the orbit of a Lychrel
candidate grows without bound — a necessary condition for non-termination.
-/
theorem strict_growth_of_nonpalindrome
    (n : ℕ) (hn : 0 < n)
    (_h0 : n % 10 ≠ 0) :
    n < revAdd n := by
  exact Nat.lt_add_of_pos_right ( reverseNat_pos hn )

/-! ## Iteration Monotonicity -/

/-
The iterated reverse-and-add sequence is monotonically nondecreasing.
-/
theorem revAddIter_monotone (k : ℕ) (n : ℕ) :
    n ≤ revAddIter k n := by
  induction' k with k ih generalizing n <;> simp_all +arith +decide [ revAddIter ];
  exact le_trans ( ih _ ) ( self_le_revAdd _ )

/-
**Modular evolution under iteration:** `T^k(n) ≡ 2^k · n (mod 9)`.
This follows by induction from the single-step law `T(n) ≡ 2n (mod 9)`.
-/
theorem revAdd_mod9_iter (k n : ℕ) :
    revAddIter k n % 9 = (2 ^ k * n) % 9 := by
  induction k <;> simp +arith +decide [ *, revAddIter ];
  convert revAdd_mod9 ( revAddIter _ _ ) using 1 ; ring;
  norm_num [ Nat.mul_mod, Nat.pow_mod, ‹_› ];
  norm_num [ mul_comm ]

/-! ## Even-Length Palindrome Mod 11 Obstruction -/

/-
**Theorem D (Congruence Obstruction):** Every even-length base-10 palindrome
is divisible by 11.

*Proof sketch:* Since `10 ≡ -1 (mod 11)`, we have `n ≡ alternatingSum(digits) (mod 11)`.
For an even-length palindrome `L = L.reverse` of length `2k`, pairing position `i` with
position `2k-1-i` gives contributions `(-1)^i · d_i + (-1)^{2k-1-i} · d_i`. Since
`i + (2k-1-i) = 2k-1` is odd, the signs are opposite and each pair cancels. Therefore
the alternating sum is 0, giving `n ≡ 0 (mod 11)`.

This is the key cross-domain theorem connecting digit combinatorics to number theory,
providing a congruence sieve for palindrome avoidance.
-/
theorem palindrome_mod11_of_even_length
    (n : ℕ)
    (hpal : IsPalindromeNat n)
    (hlen : Even (digits10 n).length) :
    n % 11 = 0 := by
  have h_mod11 : (Nat.ofDigits 10 (digits10 n) : ℤ) ≡ 0 [ZMOD 11] := by
    -- Since `10 ≡ -1 (mod 11)`, we have `Nat.ofDigits 10 L ≡ Nat.ofDigits (-1) L (mod 11)`.
    have h_mod11_equiv : (Nat.ofDigits 10 (digits10 n) : ℤ) ≡ (Nat.ofDigits (-1 : ℤ) (digits10 n)) [ZMOD 11] := by
      induction ( digits10 n ) <;> simp_all +decide [ Int.ModEq, Int.negSucc_eq, Nat.ofDigits ];
      omega;
    -- Since `L` is a palindrome, we have `L = L.reverse`.
    have h_palindrome : digits10 n = (digits10 n).reverse := by
      exact hpal;
    -- Since `L` is a palindrome, we have `Nat.ofDigits (-1) L = -Nat.ofDigits (-1) L`.
    have h_palindrome_neg : (Nat.ofDigits (-1 : ℤ) (digits10 n)) = -(Nat.ofDigits (-1 : ℤ) (digits10 n)) := by
      conv_lhs => rw [ h_palindrome ];
      norm_num [ ofDigits_one, ofDigits_neg_one, List.sum_reverse ];
      rw [ List.alternatingSum_reverse ];
      norm_num [ hlen, pow_succ' ];
    grind;
  -- Since `Nat.ofDigits 10 (digits10 n)` is equivalent to `n` in the integers, we can conclude that `n ≡ 0 [ZMOD 11]`.
  have h_cong : (n : ℤ) ≡ 0 [ZMOD 11] := by
    convert h_mod11 using 1;
    exact_mod_cast Eq.symm ( Nat.ofDigits_digits 10 n );
  exact Nat.cast_injective h_cong

end Lychrel