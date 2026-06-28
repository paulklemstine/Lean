/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Binomial coefficient toolkit for the layered-star construction

This file collects the elementary facts about binomial coefficients that the
layered-star VC construction relies on:

* `choose_le_middle`  — every entry of row `n` of Pascal's triangle is at most the
  central entry `n.choose (n / 2)` (the *middle binomial coefficient* is maximal);
* `choose_mono_n`     — `n ↦ n.choose k` is monotone;
* `sum_range_choose_eq` — the full row sums to `2 ^ n`.

These are thin, well-named wrappers around `Mathlib` so that the downstream files
`LayeredStarFormula.lean` and `UniformVCStar.lean` can cite them by name.
-/
import Mathlib

open Finset

namespace Catalog.Novelty.Binomial

/-- **Middle binomial coefficient is maximal.**
Every entry `n.choose k` of row `n` is bounded by the central entry
`n.choose (n / 2)`. -/
theorem choose_le_middle (n k : ℕ) : n.choose k ≤ n.choose (n / 2) :=
  Nat.choose_le_middle k n

/-- Binomial coefficients are monotone in the upper index. -/
theorem choose_mono_n {n m : ℕ} (k : ℕ) (h : n ≤ m) : n.choose k ≤ m.choose k :=
  Nat.choose_mono k h

/-- The full row of Pascal's triangle sums to `2 ^ n`. -/
theorem sum_range_choose_eq (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), n.choose k = 2 ^ n :=
  Nat.sum_range_choose n

/-- A truncated row sum is bounded by the full row sum, hence by `2 ^ n`. -/
theorem sum_range_choose_le_pow (n d : ℕ) (h : d ≤ n) :
    ∑ k ∈ Finset.range (d + 1), n.choose k ≤ 2 ^ n := by
  calc ∑ k ∈ Finset.range (d + 1), n.choose k
      ≤ ∑ k ∈ Finset.range (n + 1), n.choose k :=
        Finset.sum_le_sum_of_subset (Finset.range_mono (by omega))
    _ = 2 ^ n := sum_range_choose_eq n

end Catalog.Novelty.Binomial