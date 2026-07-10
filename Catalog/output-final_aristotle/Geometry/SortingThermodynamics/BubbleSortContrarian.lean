/-
# The Thermodynamics of Sorting II: Bubble Sort and a Contrarian Correction

The research brief conjectures that bubble sort performs `n²` comparisons, hence dissipates
thermodynamic work `W_bubble = kT · n²`.  This is **quantitatively false**: the standard
bubble sort performs exactly `n(n-1)/2 = ∑_{i<n} i` comparisons (a Gauss sum), not `n²`.

We model the comparison count of bubble sort as `bubbleComparisons n = ∑_{i ∈ range n} i`
(pass `k`, for `k = 1,…,n-1`, performs `n-k` adjacent comparisons).

## Main results

* `bubbleComparisons_eq`: `bubbleComparisons n = n(n-1)/2`.
* `bubble_sq_identity`: the exact correction `2 · bubbleComparisons n + n = n²`; the true
  count is `(n² - n)/2`, so the quoted `n²` overcounts by more than a factor of two.
* `bubble_lt_sq`: `bubbleComparisons n < n²` for `n ≥ 1` — the `n²` estimate is a strict
  overestimate. (Disproof of the `W_bubble = kT n²` conjecture as stated.)
* `bubble_ge_entropy_floor`: bubble sort nonetheless respects the entropy lower bound,
  `(n/2)·⌊log₂(n/2)⌋ ≤ bubbleComparisons n`; being a correct sort it pays at least the
  `Ω(n log n)` thermodynamic floor.
-/

import Mathlib

namespace SortingThermodynamics

open Nat Finset

/-- Comparison count of the standard (non-early-terminating) bubble sort on `n` elements:
pass `k` performs `n-k` adjacent comparisons for `k = 1,…,n-1`, totalling `∑_{i<n} i`. -/
def bubbleComparisons (n : ℕ) : ℕ := ∑ i ∈ Finset.range n, i

/-
Bubble sort performs exactly `n(n-1)/2` comparisons (Gauss).
-/
theorem bubbleComparisons_eq (n : ℕ) : bubbleComparisons n = n * (n - 1) / 2 := by
  convert Finset.sum_range_id n using 1

/-
**Contrarian correction.** The exact identity `2 · C(n) + n = n²`, so the true
comparison count `C(n)` equals `(n² - n)/2`, refuting the conjectured `n²`.
-/
theorem bubble_sq_identity (n : ℕ) : 2 * bubbleComparisons n + n = n ^ 2 := by
  induction n <;> simp_all +arith +decide [ Finset.sum_range_succ, bubbleComparisons ];
  grind +revert

/-
The conjectured `n²` strictly overestimates the true bubble-sort work for `n ≥ 1`.
-/
theorem bubble_lt_sq (n : ℕ) (hn : 1 ≤ n) : bubbleComparisons n < n ^ 2 := by
  nlinarith [ bubble_sq_identity n ]

/-
Bubble sort, being a correct comparison sort, still pays at least the entropy floor
`(n/2)·⌊log₂(n/2)⌋ = Ω(n log n)`.
-/
theorem bubble_ge_entropy_floor (n : ℕ) :
    (n / 2) * Nat.log 2 (n / 2) ≤ bubbleComparisons n := by
  rw [ bubbleComparisons_eq ];
  rcases n with ( _ | _ | n ) <;> simp +arith +decide;
  rw [ Nat.le_div_iff_mul_le ] <;> nlinarith [ Nat.div_mul_le_self n 2, Nat.log_le_self 2 ( n / 2 + 1 ) ]

end SortingThermodynamics