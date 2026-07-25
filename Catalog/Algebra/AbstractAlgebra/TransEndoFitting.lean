/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Fitting no-revival law for endomorphism rank profiles

For a finite-dimensional vector space `V` over a field `K` and an endomorphism
`g : V →ₗ[K] V`, the ranges of the powers of `g` form a decreasing chain.  Once
two consecutive ranges coincide the chain stabilizes forever: the rank profile
never "revives".  This file collects the basic facts behind this phenomenon.
-/
import Mathlib

namespace Catalog.Algebra.TransEndoFitting

open LinearMap Module Submodule

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]

omit [FiniteDimensional K V] in
/-- The range of `g ^ (n + 1)` is contained in the range of `g ^ n`. -/
theorem range_pow_succ_le (g : V →ₗ[K] V) (n : ℕ) :
    range (g ^ (n + 1)) ≤ range (g ^ n) := by
  rw [pow_succ]
  show range ((g ^ n) ∘ₗ g) ≤ range (g ^ n)
  rw [LinearMap.range_comp]
  exact LinearMap.map_le_range

/-- If the rank does not drop from step `k` to step `k + 1`, the ranges are equal. -/
theorem range_pow_succ_eq_of_finrank_eq (g : V →ₗ[K] V) (k : ℕ)
    (h : finrank K (range (g ^ (k + 1))) = finrank K (range (g ^ k))) :
    range (g ^ (k + 1)) = range (g ^ k) :=
  Submodule.eq_of_le_of_finrank_eq (range_pow_succ_le g k) h

omit [FiniteDimensional K V] in
/-- Once the range stabilizes at step `k`, it stays constant for all later steps. -/
theorem range_pow_stable (g : V →ₗ[K] V) (k : ℕ)
    (h : range (g ^ (k + 1)) = range (g ^ k)) (m : ℕ) :
    range (g ^ (k + m)) = range (g ^ k) := by
  -- The successor of a range is obtained by applying `g`, so equal ranges have
  -- equal successors.
  have step : ∀ j : ℕ, range (g ^ (j + 1)) = Submodule.map g (range (g ^ j)) := by
    intro j
    rw [pow_succ' g j]
    show range (g ∘ₗ g ^ j) = Submodule.map g (range (g ^ j))
    rw [LinearMap.range_comp]
  induction m with
  | zero => simp
  | succ n ih =>
    have hk : k + (n + 1) = (k + n) + 1 := by ring
    rw [hk, step (k + n), ih, ← step k, h]

/-- If the rank plateaus at step `k`, then it equals that plateau value forever. -/
theorem rank_pow_plateau_implies_stable (g : V →ₗ[K] V) (k : ℕ)
    (h : finrank K (range (g ^ (k + 1))) = finrank K (range (g ^ k)))
    (m : ℕ) :
    finrank K (range (g ^ (k + m))) = finrank K (range (g ^ k)) := by
  have hr : range (g ^ (k + 1)) = range (g ^ k) :=
    range_pow_succ_eq_of_finrank_eq g k h
  rw [range_pow_stable g k hr m]

/-- At each step the rank either stays the same or strictly decreases. -/
theorem rank_pow_strictAnti_until_stangle (g : V →ₗ[K] V) (k : ℕ) :
    finrank K (range (g ^ (k + 1))) = finrank K (range (g ^ k)) ∨
      finrank K (range (g ^ (k + 1))) < finrank K (range (g ^ k)) :=
  eq_or_lt_of_le (Submodule.finrank_mono (range_pow_succ_le g k))

end Catalog.Algebra.TransEndoFitting