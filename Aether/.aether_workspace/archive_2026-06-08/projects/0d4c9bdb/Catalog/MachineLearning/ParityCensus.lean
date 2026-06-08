/-
Copyright (c) 2025. All rights reserved.
The k-ary Parity Census Law for additive prime decompositions.
-/
import Mathlib

/-!
# k-ary Parity Census Law

In any additive decomposition of a natural number into primes, the count
of 2s is governed by a universal parity constraint:

  `countTwos L ≡ L.sum + L.length (mod 2)`

This is because every odd prime contributes 1 mod 2, so the sum mod 2
equals the number of odd primes mod 2 = (length - countTwos) mod 2.

## Main Results

* `prime_mod2` — a prime satisfies `p % 2 = if p = 2 then 0 else 1`
* `count_twos_parity_of_prime_sum` — the universal parity census law
* `count_twos_parity_of_prime_decomposition` — target-sum version
* `count_twos_parity_2` — specialization to Goldbach pairs
* `count_twos_parity_4` — specialization to arity 4
-/

namespace PrimeDecomp

/-- Count the number of 2s in a list of natural numbers. -/
def countTwos (L : List ℕ) : ℕ := L.count 2

/-
A prime number satisfies `p % 2 = if p = 2 then 0 else 1`.
-/
theorem prime_mod2 (p : ℕ) (hp : Nat.Prime p) :
    p % 2 = if p = 2 then 0 else 1 := by
  -- If p is not 2, then p must be odd because primes are greater than 2.
  cases Nat.Prime.eq_two_or_odd hp <;> aesop

/-
**The k-ary Parity Census Law.** For any list of primes,
the count of 2s satisfies `countTwos L % 2 = (L.sum + L.length) % 2`.

This is a universal conservation law: in any additive prime decomposition
`a₁ + a₂ + ⋯ + aₖ = n`, the number of indices with `aᵢ = 2` has the
same parity as `n + k`.
-/
theorem count_twos_parity_of_prime_sum
    (L : List ℕ) (hprime : ∀ x ∈ L, Nat.Prime x) :
    countTwos L % 2 = (L.sum + L.length) % 2 := by
  unfold countTwos;
  induction L <;> simp +arith +decide [ *, Nat.add_mod, Nat.mul_mod ];
  rename_i k l ih; specialize ih ( fun x hx => hprime x ( List.mem_cons_of_mem _ hx ) ) ; cases Nat.Prime.eq_two_or_odd ( hprime _ ( List.mem_cons_self ) ) <;> simp_all +arith +decide;
  · omega;
  · rw [ List.count_cons_of_ne ] <;> aesop

/-
Parity census law with explicit target sum.
-/
theorem count_twos_parity_of_prime_decomposition
    (L : List ℕ) (n : ℕ)
    (hprime : ∀ x ∈ L, Nat.Prime x)
    (hsum : L.sum = n) :
    countTwos L % 2 = (n + L.length) % 2 := by
  rw [ ← hsum, count_twos_parity_of_prime_sum L hprime ]

/-
Specialization to arity 2 (Goldbach pairs).
-/
theorem count_twos_parity_2
    (n a b : ℕ)
    (ha : Nat.Prime a) (hb : Nat.Prime b)
    (hsum : a + b = n) :
    (countTwos [a, b]) % 2 = n % 2 := by
  convert count_twos_parity_of_prime_decomposition [ a, b ] n ( by aesop ) ( by simpa using hsum ) using 1 ; simp +arith +decide [ Nat.add_mod ]

/-
Specialization to arity 4.
-/
theorem count_twos_parity_4
    (n a b c d : ℕ)
    (ha : Nat.Prime a) (hb : Nat.Prime b)
    (hc : Nat.Prime c) (hd : Nat.Prime d)
    (hsum : a + b + c + d = n) :
    (countTwos [a, b, c, d]) % 2 = n % 2 := by
  have := @count_twos_parity_of_prime_decomposition;
  convert this [ a, b, c, d ] n _ _ using 1 <;> simp_all +arith +decide;
  norm_num [ Nat.add_mod ]

end PrimeDecomp