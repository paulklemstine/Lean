import Mathlib

/-! # Consecutive prime gaps

This file supplies the arithmetic gap observable used by the persistent-homology
formalization of the prime point cloud.
-/

namespace TwinPrimeGaps

/-- The gap between the `n`-th prime and its successor. -/
noncomputable def primeGap (n : ℕ) : ℕ :=
  Nat.nth Nat.Prime (n + 1) - Nat.nth Nat.Prime n

/-- Consecutive prime positions are strictly increasing. -/
theorem nth_prime_lt_succ (n : ℕ) :
    Nat.nth Nat.Prime n < Nat.nth Nat.Prime (n + 1) :=
  Nat.nth_strictMono Nat.infinite_setOf_prime (Nat.lt_succ_self n)

/-- Every consecutive prime gap is positive. -/
theorem primeGap_pos (n : ℕ) : 0 < primeGap n := by
  exact Nat.sub_pos_of_lt (nth_prime_lt_succ n)

/-- The successor prime is recovered by adding the corresponding gap. -/
theorem nth_prime_add_primeGap (n : ℕ) :
    Nat.nth Nat.Prime n + primeGap n = Nat.nth Nat.Prime (n + 1) := by
  exact Nat.add_sub_of_le (Nat.le_of_lt (nth_prime_lt_succ n))

end TwinPrimeGaps