import Mathlib

/-!
# Statistical Distance for Finite Distributions

This file defines statistical distance (total variation distance) for
distributions on finite types represented as PMFs, and proves basic properties
including non-negativity, symmetry, the triangle inequality, and self-distance.

## Main Definitions

* `statDist` — Statistical distance between two probability mass functions.

## Main Results

* `statDist_nonneg` — Statistical distance is non-negative.
* `statDist_symm` — Statistical distance is symmetric.
* `statDist_triangle` — Triangle inequality for statistical distance.
* `statDist_self` — Distance from a distribution to itself is zero.
-/

noncomputable section

open Finset BigOperators

namespace OrbitPRG

/-- Statistical distance (total variation distance) between two distributions
    represented as real-valued functions on a finite type. -/
def statDist {α : Type*} [Fintype α] (p q : α → ℝ) : ℝ :=
  (1 / 2) * ∑ x : α, |p x - q x|

theorem statDist_nonneg {α : Type*} [Fintype α] (p q : α → ℝ) :
    0 ≤ statDist p q :=
  mul_nonneg (by norm_num) (Finset.sum_nonneg fun _ _ => abs_nonneg _)

theorem statDist_symm {α : Type*} [Fintype α] (p q : α → ℝ) :
    statDist p q = statDist q p := by
  unfold statDist; congr 1; congr 1 with x; rw [abs_sub_comm]

theorem statDist_triangle {α : Type*} [Fintype α] (p q r : α → ℝ) :
    statDist p r ≤ statDist p q + statDist q r := by
  unfold statDist
  rw [← mul_add, ← Finset.sum_add_distrib]
  gcongr with x _
  exact abs_sub_le (p x) (q x) (r x)

theorem statDist_self {α : Type*} [Fintype α] (p : α → ℝ) :
    statDist p p = 0 := by
  simp [statDist]

end OrbitPRG