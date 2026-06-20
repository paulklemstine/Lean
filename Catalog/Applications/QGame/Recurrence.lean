/-
# QGame probability recurrence

This module defines the probability sequence `P q n` arising from a `q`-game and
records its defining recurrence.

For each fixed parameter `q`, the sequence is defined by

* `P q 0 = 1`
* `P q (n+1) = (1 + ∑ j ∈ Finset.range ((n+1) - q), P q j) / (n+1)`.

The summation range only references strictly smaller indices, so the recursion is
well founded.
-/
import Mathlib

namespace QGame

open Finset

/-- The `q`-game probability sequence, valued in `ℚ`.

The summation is taken over `(Finset.range ((n+1) - q)).attach` so that the
membership proof is available for the well-foundedness check; the clean recurrence
`P_succ` recovers the ordinary sum form. -/
def P (q : ℕ) : ℕ → ℚ
  | 0 => 1
  | (n + 1) =>
      (1 + ∑ j ∈ (Finset.range ((n + 1) - q)).attach, P q j.1) / ((n : ℚ) + 1)
decreasing_by
  · have hj := j.2
    simp only [Finset.mem_range] at hj
    omega

/-- Base case of the recurrence. -/
@[simp] theorem P_zero (q : ℕ) : P q 0 = 1 := by
  rw [P]

/-- Successor case of the recurrence. -/
theorem P_succ (q n : ℕ) :
    P q (n + 1) = (1 + ∑ j ∈ Finset.range ((n + 1) - q), P q j) / ((n : ℚ) + 1) := by
  rw [P]
  rw [Finset.sum_attach (Finset.range ((n + 1) - q)) (fun j => P q j)]

end QGame