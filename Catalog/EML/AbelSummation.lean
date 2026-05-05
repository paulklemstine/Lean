/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Abel Summation (Summation by Parts)

This file formalizes Abel's summation formula, also known as "summation by parts",
the discrete analog of integration by parts. This is a fundamental identity in
discrete analysis with applications to convergence of series, partial summation
bounds, and number theory.

## Main results

* `EML.abel_summation`: The Abel summation formula:
  ∑_{k=0}^{n-1} a(k) * (b(k+1) - b(k)) = a(n) * b(n) - a(0) * b(0) - ∑_{k=0}^{n-1} (a(k+1) - a(k)) * b(k+1)

* `EML.abel_inequality`: If a is non-negative and decreasing, and partial sums of c
  are bounded, then |∑ a(k) * c(k)| ≤ a(0) * M.

## References

* Abel, N.H. (1826). Untersuchungen über die Reihe ...
* Apostol, T.M. "Introduction to Analytic Number Theory", Chapter 4.
-/

import Mathlib

namespace EML

open Finset BigOperators

/-! ### Abel Summation Formula -/

/-
**Abel Summation (Summation by Parts)**: The discrete analog of integration by parts.

For sequences a, b : ℕ → ℝ and any n:
  ∑_{k=0}^{n-1} a(k) * (b(k+1) - b(k)) = a(n)*b(n) - a(0)*b(0) - ∑_{k=0}^{n-1} (a(k+1) - a(k)) * b(k+1)

This is the discrete counterpart of ∫ u dv = uv - ∫ v du.
-/
theorem abel_summation (a b : ℕ → ℝ) (n : ℕ) :
    ∑ k ∈ Finset.range n, a k * (b (k + 1) - b k) =
    a n * b n - a 0 * b 0 - ∑ k ∈ Finset.range n, (a (k + 1) - a k) * b (k + 1) := by
  induction n <;> simp_all +decide [ Finset.sum_range_succ ] ; ring

/-
An equivalent formulation: the "summation by parts" identity rearranged.
  ∑_{k=0}^{n-1} a(k) * c(k) = a(n) * B(n) - ∑_{k=0}^{n-1} (a(k+1) - a(k)) * B(k+1)
where B(k) = ∑_{j=0}^{k-1} c(j) is the partial sum of c.
-/
theorem abel_summation_partial_sums (a c : ℕ → ℝ) (n : ℕ) :
    let B : ℕ → ℝ := fun k => ∑ j ∈ Finset.range k, c j
    ∑ k ∈ Finset.range n, a k * c k =
    a n * B n - ∑ k ∈ Finset.range n, (a (k + 1) - a k) * B (k + 1) := by
  convert abel_summation a ( fun k ↦ ∑ j ∈ Finset.range k, c j ) n using 1 <;> simp +decide [ Finset.sum_range_succ ]

/-! ### Monotone Summation Bound (Abel's Inequality) -/

/-
**Abel's Inequality**: If a is non-negative and non-increasing, and the partial sums
of c are bounded by M, then |∑_{k=0}^{n-1} a(k) * c(k)| ≤ a(0) * M.

This is a powerful tool for bounding sums with oscillating terms.
-/
theorem abel_inequality (a c : ℕ → ℝ) (n : ℕ) (M : ℝ)
    (ha_nonneg : ∀ k, 0 ≤ a k)
    (ha_anti : Antitone a)
    (hM : ∀ k, |∑ j ∈ Finset.range k, c j| ≤ M) :
    |∑ k ∈ Finset.range n, a k * c k| ≤ a 0 * M := by
  -- Use abel_summation_partial_sums to write ∑ a(k)*c(k) = a(n)*B(n) - ∑(a(k+1)-a(k))*B(k+1).
  let B : ℕ → ℝ := fun k => ∑ j ∈ Finset.range k, c j
  have h_sum : ∑ k ∈ Finset.range n, a k * c k = a n * B n - ∑ k ∈ Finset.range n, (a (k + 1) - a k) * B (k + 1) := by
    exact abel_summation_partial_sums a c n
  -- We have |B(k)| ≤ M for all k. So |∑ a(k)*c(k)| ≤ |a(n)*B(n)| + |∑(a(k+1)-a(k))*B(k+1)| ≤ a(n)*M + ∑|a(k+1)-a(k)|*M.
  have h_bound : |∑ k ∈ Finset.range n, a k * c k| ≤ a n * M + ∑ k ∈ Finset.range n, |a (k + 1) - a k| * M := by
    rw [ h_sum ];
    refine' le_trans ( abs_sub _ _ ) ( add_le_add _ _ );
    · simpa only [ abs_mul, abs_of_nonneg ( ha_nonneg n ) ] using mul_le_mul_of_nonneg_left ( hM n ) ( ha_nonneg n );
    · exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => by rw [ abs_mul ] ; exact mul_le_mul_of_nonneg_left ( hM _ ) ( abs_nonneg _ ) );
  -- Since a is decreasing, ∑|a(k+1)-a(k)| = a(0) - a(n).
  have h_sum_abs : ∑ k ∈ Finset.range n, |a (k + 1) - a k| = a 0 - a n := by
    rw [Finset.sum_congr rfl fun i hi => abs_of_nonpos <| sub_nonpos.mpr <| ha_anti <| Nat.le_succ i]
    simp +decide
    rw [← Finset.sum_sub_distrib, Finset.sum_range_sub']
  exact h_bound.trans_eq ( by rw [ ← Finset.sum_mul _ _ _ ] ; rw [ h_sum_abs ] ; ring )

end EML