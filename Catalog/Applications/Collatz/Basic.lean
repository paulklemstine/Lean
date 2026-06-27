/-
  The Collatz shortcut map: basic definitions
  ===========================================

  This file sets up the elementary machinery used by the cycle–obstruction
  lemmas in `Applications.Collatz.CycleObstruction`.

  We work with the Collatz step map on the natural numbers
      T(n) = n / 2          if n is even,
      T(n) = 3 n + 1        if n is odd.
  This is the same map `T` used elsewhere in the catalog
  (`Cryptography.CollatzHash`); here it is repackaged in the `Collatz`
  namespace together with the basic parity evaluation lemmas and the
  pointwise monotonicity facts.

  Iteration of `T` is denoted with the standard Mathlib notation
  `T^[k]` (`Function.iterate`).
-/
import Mathlib

namespace Collatz

/-- The Collatz step map on natural numbers:
    `T n = n / 2` when `n` is even and `T n = 3 n + 1` when `n` is odd. -/
def T (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else 3 * n + 1

/-- On an even input the map halves: `T n = n / 2`. -/
lemma T_even {n : ℕ} (h : Even n) : T n = n / 2 := by
  unfold T; rw [if_pos (Nat.even_iff.mp h)]

/-- On an odd input the map applies `3 n + 1`. -/
lemma T_odd {n : ℕ} (h : Odd n) : T n = 3 * n + 1 := by
  unfold T; rw [if_neg]; simp [Nat.odd_iff.mp h]

/-- A single even step is strictly decreasing on positive inputs. -/
lemma T_lt_of_even {n : ℕ} (hn : 0 < n) (h : Even n) : T n < n := by
  rw [T_even h]; exact Nat.div_lt_self hn one_lt_two

/-- A single odd step is strictly increasing. -/
lemma T_gt_of_odd {n : ℕ} (h : Odd n) : T n > n := by
  rw [T_odd h]; omega

end Collatz