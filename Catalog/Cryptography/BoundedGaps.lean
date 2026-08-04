/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The prime gap sequence

The gap sequence of the primes, `primeGap i = p_{i+1} - p_i`, where `p_i` is the
`i`-th prime (`Nat.nth Nat.Prime i`, indexed from `p₀ = 2`).

This file provides the definition and its elementary properties: the gaps are
positive, they reconstruct the prime sequence, and "gap two" is exactly the twin
prime condition.  Bounded-gap statements about this sequence (Zhang–Maynard) are
the arithmetic input studied by the downstream files; nothing beyond elementary
facts is claimed here.
-/

namespace TwinPrimeGaps

/-- The `i`-th prime gap: the difference between consecutive primes. -/
noncomputable def primeGap (i : ℕ) : ℕ :=
  Nat.nth Nat.Prime (i + 1) - Nat.nth Nat.Prime i

/-- Consecutive primes are strictly increasing. -/
theorem nth_prime_lt_succ (i : ℕ) :
    Nat.nth Nat.Prime i < Nat.nth Nat.Prime (i + 1) :=
  Nat.nth_strictMono Nat.infinite_setOf_prime (Nat.lt_succ_self i)

/-- Prime gaps are positive. -/
theorem primeGap_pos (i : ℕ) : 0 < primeGap i := by
  have := nth_prime_lt_succ i
  simp only [primeGap]
  omega

/-- The gap sequence reconstructs the primes: `p_{i+1} = p_i + gap i`. -/
theorem nth_prime_succ_eq (i : ℕ) :
    Nat.nth Nat.Prime (i + 1) = Nat.nth Nat.Prime i + primeGap i := by
  have := nth_prime_lt_succ i
  simp only [primeGap]
  omega

/-- Real-valued form of the gap, as used by metric/persistence arguments. -/
theorem cast_primeGap (i : ℕ) :
    (primeGap i : ℝ) = (Nat.nth Nat.Prime (i + 1) : ℝ) - (Nat.nth Nat.Prime i : ℝ) := by
  have h := (nth_prime_lt_succ i).le
  rw [primeGap, Nat.cast_sub h]

/-- A gap equal to `2` is exactly a twin prime pair at that index. -/
theorem primeGap_eq_two_iff (i : ℕ) :
    primeGap i = 2 ↔ Nat.nth Nat.Prime (i + 1) = Nat.nth Nat.Prime i + 2 := by
  have := nth_prime_lt_succ i
  simp only [primeGap]
  omega

/-- Both endpoints of a gap are prime. -/
theorem prime_nth (i : ℕ) : Nat.Prime (Nat.nth Nat.Prime i) :=
  Nat.prime_nth_prime i

/-- A gap of two exhibits a genuine twin prime pair `(p, p + 2)`. -/
theorem twin_of_primeGap_eq_two {i : ℕ} (h : primeGap i = 2) :
    Nat.Prime (Nat.nth Nat.Prime i) ∧ Nat.Prime (Nat.nth Nat.Prime i + 2) := by
  refine ⟨prime_nth i, ?_⟩
  rw [← (primeGap_eq_two_iff i).mp h]
  exact prime_nth (i + 1)

end TwinPrimeGaps