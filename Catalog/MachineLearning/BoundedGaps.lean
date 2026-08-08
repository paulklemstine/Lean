import Mathlib

/-!
# The prime gap sequence

`Novelty/PrimePersistentHomology.lean` identifies the finite bars of the degree-zero
persistent homology of the prime point cloud with the gaps between consecutive primes.
This module supplies the gap sequence itself together with its basic properties.

* `TwinPrimeGaps.primeGap i = p_{i+1} - p_i`, where `p_i = Nat.nth Nat.Prime i` is the
  `i`-th prime (indexed from `p_0 = 2`).
* `primeGap_pos` — every gap is positive, since `Nat.nth Nat.Prime` is strictly monotone
  on the infinite set of primes.
* `nth_prime_add_gap` — the defining recurrence `p_{i+1} = p_i + gap i` (subtraction in `ℕ`
  is truncated, so this needs the positivity above).
* `primeGap_even` — from index `1` onwards all primes are odd, so all gaps are even.
* `twinPair_of_primeGap_eq_two` — a gap equal to `2` is exactly a twin prime pair.
-/

namespace TwinPrimeGaps

open Nat

/-- The `i`-th prime gap: the distance from the `i`-th prime to the next one. -/
noncomputable def primeGap (i : ℕ) : ℕ := Nat.nth Nat.Prime (i + 1) - Nat.nth Nat.Prime i

theorem nth_prime_lt_succ (i : ℕ) : Nat.nth Nat.Prime i < Nat.nth Nat.Prime (i + 1) :=
  Nat.nth_strictMono Nat.infinite_setOf_prime (Nat.lt_succ_self i)

theorem primeGap_pos (i : ℕ) : 0 < primeGap i :=
  Nat.sub_pos_of_lt (nth_prime_lt_succ i)

/-- The defining recurrence of the gap sequence. -/
theorem nth_prime_add_gap (i : ℕ) :
    Nat.nth Nat.Prime (i + 1) = Nat.nth Nat.Prime i + primeGap i := by
  have h := (nth_prime_lt_succ i).le
  unfold primeGap
  omega

/-- The zeroth gap is `3 - 2 = 1`. -/
theorem primeGap_zero : primeGap 0 = 1 := by
  have h0 : Nat.nth Nat.Prime 0 = 2 := by simp
  have h1 : Nat.nth Nat.Prime 1 = 3 := by simp
  simp [primeGap, h0, h1]

/-- Every prime with positive index is odd. -/
theorem odd_nth_prime_of_pos {i : ℕ} (hi : 0 < i) : Odd (Nat.nth Nat.Prime i) := by
  have hp : Nat.Prime (Nat.nth Nat.Prime i) := Nat.prime_nth_prime i
  have h0 : Nat.nth Nat.Prime 0 = 2 := by simp
  have hlt : Nat.nth Nat.Prime 0 < Nat.nth Nat.Prime i :=
    Nat.nth_strictMono Nat.infinite_setOf_prime hi
  rcases hp.eq_two_or_odd' with h | h
  · omega
  · exact h

/-- From index `1` on, all prime gaps are even. -/
theorem primeGap_even {i : ℕ} (hi : 0 < i) : Even (primeGap i) :=
  Nat.Odd.sub_odd (odd_nth_prime_of_pos (Nat.lt_of_lt_of_le hi (Nat.le_succ i)))
    (odd_nth_prime_of_pos hi)

/-- A gap of `2` is precisely a twin prime pair. -/
theorem twinPair_of_primeGap_eq_two {i : ℕ} (h : primeGap i = 2) :
    Nat.Prime (Nat.nth Nat.Prime i) ∧ Nat.Prime (Nat.nth Nat.Prime i + 2) := by
  refine ⟨Nat.prime_nth_prime i, ?_⟩
  have hrec := nth_prime_add_gap i
  rw [h] at hrec
  rw [← hrec]
  exact Nat.prime_nth_prime (i + 1)

end TwinPrimeGaps