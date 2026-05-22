import Mathlib
import Speculative.Collatz.Core

/-!
# Accelerated Collatz Map and 2-adic Valuation

This file defines the 2-adic valuation on natural numbers, the accelerated
odd Collatz map, and proves the fundamental recurrence identity:

  `3 * n + 1 = 2 ^ v2Nat(3*n+1) * accelCollatzOdd n`

for positive `n`.

The accelerated map strips all factors of 2 from `3n+1`, jumping directly
from one odd number to the next in the Collatz orbit. This exposes the
symbolic/2-adic structure of Collatz dynamics.
-/

namespace Collatz

/-- The 2-adic valuation of a natural number: `multiplicity 2 n`. -/
noncomputable def v2Nat (n : ℕ) : ℕ := multiplicity 2 n

/-- The odd part of a natural number: `n / 2^(v2Nat n)`. -/
noncomputable def oddPart (n : ℕ) : ℕ := n / 2 ^ v2Nat n

/-- The accelerated odd Collatz map: compute `3n+1` and strip all factors of 2. -/
noncomputable def accelCollatzOdd (n : ℕ) : ℕ := oddPart (3 * n + 1)

/-- `2 ^ v2Nat n` divides `n`. -/
theorem pow_v2Nat_dvd (n : ℕ) : 2 ^ v2Nat n ∣ n := by
  exact pow_multiplicity_dvd 2 n

/-- The fundamental factorization: `n = 2 ^ v2Nat n * oddPart n`. -/
theorem factorization_v2 (n : ℕ) : n = 2 ^ v2Nat n * oddPart n := by
  simp only [oddPart, v2Nat]
  rw [mul_comm]
  exact (Nat.div_mul_cancel (pow_multiplicity_dvd 2 n)).symm

/-- The fundamental recurrence identity for the accelerated map:
    `3 * n + 1 = 2 ^ v2Nat(3*n+1) * accelCollatzOdd n`. -/
theorem accel_formula (n : ℕ) :
    3 * n + 1 = 2 ^ v2Nat (3 * n + 1) * accelCollatzOdd n :=
  factorization_v2 (3 * n + 1)

/-
`v2Nat` of an odd number is 0.
-/
theorem v2Nat_odd {n : ℕ} (hodd : ¬ 2 ∣ n) : v2Nat n = 0 := by
  exact multiplicity_eq_zero.mpr hodd

/-
`2 ∣ 3n+1` when `n` is odd.
-/
theorem two_dvd_three_mul_add_one {n : ℕ} (hodd : n % 2 = 1) : 2 ∣ 3 * n + 1 := by
  norm_num [ Nat.dvd_iff_mod_eq_zero, Nat.add_mod, Nat.mul_mod, hodd ]

/-
`v2Nat` of `3n+1` is at least 1 when `n` is odd.
-/
theorem v2Nat_three_mul_add_one_pos {n : ℕ} (hodd : n % 2 = 1) :
    1 ≤ v2Nat (3 * n + 1) := by
  exact multiplicity_pos_of_dvd ( dvd_trans ( by decide ) ( two_dvd_three_mul_add_one hodd ) )

/-
`oddPart n` is not divisible by 2 when `n > 0`.
-/
theorem oddPart_not_two_dvd {n : ℕ} (hn : 0 < n) : ¬ 2 ∣ oddPart n := by
  -- By definition of multiplicity, $2^{v2Nat n}$ is the largest power of 2 that divides $n$, so $2^{v2Nat n + 1}$ does not divide $n$.
  have h_not_div : ¬(2 ^ (v2Nat n + 1) ∣ n) := by
    unfold v2Nat;
    rw [ Nat.Prime.pow_dvd_iff_le_factorization ] <;> norm_num;
    · rw [ Nat.multiplicity_eq_factorization ] ; norm_num;
      positivity;
    · linarith;
  contrapose! h_not_div;
  convert Nat.mul_dvd_mul_left ( 2 ^ v2Nat n ) h_not_div using 1;
  exact factorization_v2 n

/-
`oddPart n` is odd when `n > 0`.
-/
theorem oddPart_odd {n : ℕ} (hn : 0 < n) : oddPart n % 2 = 1 := by
  exact Nat.mod_two_ne_zero.mp fun h => oddPart_not_two_dvd hn <| Nat.dvd_of_mod_eq_zero h

/-
`oddPart n > 0` when `n > 0`.
-/
theorem oddPart_pos {n : ℕ} (hn : 0 < n) : 0 < oddPart n := by
  exact Nat.div_pos ( Nat.le_of_dvd hn ( pow_v2Nat_dvd n ) ) ( pow_pos ( by decide ) _ )

/-- The accelerated odd map produces an odd number for positive input. -/
theorem accelCollatzOdd_odd {n : ℕ} (hn : 0 < n) :
    accelCollatzOdd n % 2 = 1 :=
  oddPart_odd (by omega : 0 < 3 * n + 1)

/-- The accelerated odd map produces a positive number for positive input. -/
theorem accelCollatzOdd_pos {n : ℕ} (hn : 0 < n) :
    0 < accelCollatzOdd n :=
  oddPart_pos (by omega : 0 < 3 * n + 1)

/-- Recursive sequence of accelerated odd iterates. -/
noncomputable def accelSeq (n : ℕ) : ℕ → ℕ
  | 0 => n
  | k + 1 => accelCollatzOdd (accelSeq n k)

/-
The accelerated sequence preserves oddness for odd positive seeds.
-/
theorem accelSeq_odd {n : ℕ} (hn : 0 < n) (hodd : n % 2 = 1) (k : ℕ) :
    accelSeq n k % 2 = 1 := by
  -- We proceed by induction on $k$.
  induction' k with k ih;
  · exact hodd;
  · exact accelCollatzOdd_odd ( show 0 < accelSeq n k from Nat.pos_of_ne_zero fun h => by simp_all +decide [ Nat.add_mod, Nat.mul_mod ] )

/-
The accelerated sequence preserves positivity for positive odd seeds.
-/
theorem accelSeq_pos {n : ℕ} (hn : 0 < n) (hodd : n % 2 = 1) (k : ℕ) :
    0 < accelSeq n k := by
  exact Nat.recOn k hn fun k hk => accelCollatzOdd_pos hk

/-- The accelerated sequence satisfies `accelSeq n (k+1) = accelSeq (accelCollatzOdd n) k`. -/
theorem accelSeq_succ (n : ℕ) (k : ℕ) : accelSeq n (k + 1) = accelSeq (accelCollatzOdd n) k := by
  induction k with
  | zero => simp [accelSeq]
  | succ k ih => simp only [accelSeq]; congr 1

end Collatz