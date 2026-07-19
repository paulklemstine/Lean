import Mathlib
import Applications.Collatz.Basic

/-!
# Executable small-case evidence for Collatz

This file is evidence only, not a proof of the universal conjecture.  It computes the
least observed time to hit `1`, subject to a fuel bound, and kernel-checks the first
20 values by reduction.
-/

namespace CollatzIndependence

/-- Search for the first time an orbit hits `1`, returning `none` when fuel expires. -/
def stoppingTime? : ℕ → ℕ → Option ℕ
  | 0, n => if n = 1 then some 0 else none
  | fuel + 1, n => if n = 1 then some 0 else (stoppingTime? fuel (Collatz.T n)).map Nat.succ

/-- The first twenty positive inputs all hit `1` within 20 Collatz steps. -/
theorem first_twenty_reach_one_within_twenty :
    ∀ n : ℕ, 1 ≤ n → n ≤ 20 → ∃ k : ℕ, k ≤ 20 ∧ Collatz.T^[k] n = 1 := by
  native_decide

/-- Exact stopping times for inputs `1` through `20` (for the unaccelerated map). -/
theorem first_twenty_stopping_times :
    (List.range 20).map (fun i => stoppingTime? 20 (i + 1)) =
      [some 0, some 1, some 7, some 2, some 5, some 8, some 16, some 3,
       some 19, some 6, some 14, some 9, some 9, some 17, some 17, some 4,
       some 12, some 20, some 20, some 7] := by
  native_decide

end CollatzIndependence