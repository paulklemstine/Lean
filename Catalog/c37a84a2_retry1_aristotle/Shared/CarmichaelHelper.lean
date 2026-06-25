import Mathlib

/-! # Carmichael's theorem: the prime case

This file provides the *prime* case of Carmichael's primitive divisor theorem for
Fibonacci numbers: if `n` is prime (and `n ≥ 13`, though `n ≥ 3` already suffices),
then `F(n)` has a *primitive* prime divisor — a prime `p` with `p ∣ F(n)` but
`p ∤ F(k)` for every `0 < k < n`.

The argument is elementary.  Take any prime divisor `p` of `F(n)` (one exists since
`F(n) > 1`).  If `p ∣ F(k)` for some `0 < k < n`, then `p ∣ F(gcd n k)` by the
gcd–Fibonacci identity `Nat.fib_gcd`.  Since `n` is prime and `gcd n k ≤ k < n`, we
must have `gcd n k = 1`, so `p ∣ F(1) = 1`, contradicting primality of `p`.

This file is imported by the composite-case development.
-/

set_option maxHeartbeats 800000

/-
**Carmichael's theorem, prime case.**  For prime `n ≥ 13`, `F(n)` has a primitive
prime divisor.  (The hypothesis `13 ≤ n` is stronger than needed: `3 ≤ n` suffices.)
-/
theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hnp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  -- Let p = Nat.minFac (Nat.fib n). Since n ≥ 13 ≥ 3, we have Nat.fib n > 1, so p is prime.
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n := by
    exact Nat.exists_prime_and_dvd ( ne_of_gt ( by linarith [ Nat.le_fib_add_one n ] ) );
  -- Since n is prime, Nat.gcd n k divides n so Nat.gcd n k = 1 or = n (Nat.Prime divisors).
  -- But Nat.gcd n k ≤ k < n (Nat.gcd_le_right, using 0 < k), so Nat.gcd n k ≠ n, hence Nat.gcd n k = 1.
  have h_gcd : ∀ k, 0 < k → k < n → Nat.gcd n k = 1 := by
    exact fun k hk hk' => hnp.coprime_iff_not_dvd.mpr <| Nat.not_dvd_of_pos_of_lt hk hk';
  refine' ⟨ p, hp_prime, hp_div, fun k hk hk' hk'' => _ ⟩;
  -- Since p divides both Nat.fib n and Nat.fib k, p must divide Nat.fib (Nat.gcd n k).
  have h_div_gcd : p ∣ Nat.fib (Nat.gcd n k) := by
    exact Nat.dvd_gcd hp_div hk'' |> fun h => h.trans ( by simp +decide [ Nat.fib_gcd ] );
  aesop