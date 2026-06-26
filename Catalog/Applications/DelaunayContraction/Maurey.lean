/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Maurey's empirical method and the approximate Carathéodory base case

Catalog references for this mission: *approximate Carathéodory theorem* and
*Maurey's empirical method*. Maurey's empirical method proves the approximate
Carathéodory theorem: a point of a convex hull can be approximated by an average
of few extreme points. Its engine is a single combinatorial fact —

> among a family of candidates, at least one is no worse than the (weighted)
> average ("you can always beat, or tie, the mean").

This file formalizes that engine (`exists_le_weighted_average`) and uses it,
together with the parallelogram/inner-product expansion, to prove the
**one-sample (base) case of approximate Carathéodory** in a real inner product
space: every point `x = Σ pᵢ Vᵢ` of a convex hull of vectors of norm `≤ R` has a
single vertex within squared distance `R² - ‖x‖² ≤ R²`.

All results are proved with zero `sorry`s.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Maurey's bound `‖x - (1/k)Σ Vᵢ‖ ≤ R/√k` should reduce,
at `k = 1`, to a deterministic "good vertex exists" statement, and the whole proof
should rest on an averaging (probabilistic-method) selection principle.

Experiment (Experimenter): (1) Proved `exists_le_weighted_average` by taking the
arg-min and comparing it to the convex combination. (2) Computed the weighted
average of squared distances:
  `Σ pᵢ ‖x - Vᵢ‖² = (Σ pᵢ ‖Vᵢ‖²) - ‖x‖²`
via `‖x - v‖² = ‖x‖² - 2⟪x,v⟫ + ‖v‖²`, using `x = Σ pᵢ Vᵢ` to collapse the cross
term to `2‖x‖²`. (3) Bounded `Σ pᵢ‖Vᵢ‖² ≤ R²` and applied the averaging principle.

Analysis (Analyst): The cross-term collapse is *exactly* where the "`x` is a
convex combination" hypothesis is used — drop it and the identity fails. The
identity also exposes the variance interpretation: the mean squared distance from
`x` to a random vertex equals the (weighted) variance `Σpᵢ‖Vᵢ‖² - ‖x‖²`, so the
best vertex beats the variance. This is precisely Maurey's `k = 1` term.

Critique (Critic): Not vacuous and not `simp`-only: the proof needs the inner
product expansion, a `Finset.sum` manipulation, the arg-min selection, and an
`nlinarith` bound. The hypothesis `Σ pᵢ = 1` with `pᵢ ≥ 0` (a genuine convex
combination) is load-bearing in two distinct places.

Synthesis (PI): The averaging principle is the reusable nugget; the `k = 1`
Carathéodory bound is its first geometric payoff. The full `R/√k` rate is logged
as a future direction (it needs the product-measure variance computation).
-- !-- end Lab Notes -- !--
-/

namespace ApproxCaratheodory

open scoped RealInnerProductSpace
open Finset

/-- **Averaging principle (Maurey's empirical-method engine).**
For any probability weights `p` (nonnegative, summing to `1`) over a nonempty
finite index set and any real family `g`, some index does at least as well as the
weighted average. This is the deterministic core behind the probabilistic method:
"there exists a sample no worse than its expectation." -/
theorem exists_le_weighted_average {ι : Type*} [Fintype ι] [Nonempty ι]
    (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) (g : ι → ℝ) :
    ∃ i, g i ≤ ∑ j, p j * g j := by
  obtain ⟨i₀, _, hi₀⟩ :=
    Finset.exists_min_image Finset.univ g Finset.univ_nonempty
  refine ⟨i₀, ?_⟩
  calc g i₀ = ∑ j, p j * g i₀ := by rw [← Finset.sum_mul, hsum, one_mul]
    _ ≤ ∑ j, p j * g j :=
        Finset.sum_le_sum fun j _ =>
          mul_le_mul_of_nonneg_left (hi₀ j (Finset.mem_univ j)) (hp j)

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable {ι : Type*} [Fintype ι]

/-- **The variance identity.** For a convex combination `x = Σ pᵢ Vᵢ`, the weighted
mean of the squared distances to the points equals the weighted second moment
minus `‖x‖²`. This is the `k = 1` term of Maurey's expectation bound and the
quantitative heart of approximate Carathéodory. -/
theorem weighted_mean_sq_dist (p : ι → ℝ) (hsum : ∑ i, p i = 1) (V : ι → E) :
    ∑ i, p i * ‖(∑ j, p j • V j) - V i‖ ^ 2
      = (∑ i, p i * ‖V i‖ ^ 2) - ‖∑ j, p j • V j‖ ^ 2 := by
  set x := ∑ j, p j • V j with hx
  have expand : ∀ i, ‖x - V i‖ ^ 2 = ‖x‖ ^ 2 - 2 * ⟪x, V i⟫ + ‖V i‖ ^ 2 :=
    fun i => norm_sub_sq_real x (V i)
  simp_rw [expand, mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib]
  have h1 : ∑ i, p i * ‖x‖ ^ 2 = ‖x‖ ^ 2 := by rw [← Finset.sum_mul, hsum, one_mul]
  have h2 : ∑ i, p i * (2 * ⟪x, V i⟫) = 2 * ‖x‖ ^ 2 := by
    have step : ∑ i, p i * (2 * ⟪x, V i⟫) = 2 * ⟪x, ∑ i, p i • V i⟫ := by
      rw [inner_sum, Finset.mul_sum]
      exact Finset.sum_congr rfl fun i _ => by rw [inner_smul_right]; ring
    rw [step, ← hx, real_inner_self_eq_norm_sq]
  rw [h1, h2]; ring

/-- **Approximate Carathéodory, base case (Maurey, `k = 1`).**
Every point `x = Σ pᵢ Vᵢ` of the convex hull of vectors of norm at most `R` has a
single vertex `Vᵢ` within squared distance `R²`. -/
theorem maurey_one_point [Nonempty ι]
    (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (V : ι → E) (R : ℝ) (hR : ∀ i, ‖V i‖ ≤ R) :
    ∃ i, ‖(∑ j, p j • V j) - V i‖ ^ 2 ≤ R ^ 2 := by
  set x := ∑ j, p j • V j with hx
  -- the mean squared distance is at most R²
  have hmean : ∑ i, p i * ‖x - V i‖ ^ 2 ≤ R ^ 2 := by
    rw [weighted_mean_sq_dist p hsum V]
    have hsm : ∑ i, p i * ‖V i‖ ^ 2 ≤ ∑ i, p i * R ^ 2 :=
      Finset.sum_le_sum fun i _ =>
        mul_le_mul_of_nonneg_left
          (by nlinarith [norm_nonneg (V i), hR i]) (hp i)
    rw [← Finset.sum_mul, hsum, one_mul] at hsm
    nlinarith [sq_nonneg ‖x‖]
  -- some vertex beats the mean
  obtain ⟨i₀, hi₀⟩ :=
    exists_le_weighted_average p hp hsum (fun i => ‖x - V i‖ ^ 2)
  exact ⟨i₀, le_trans hi₀ hmean⟩

/-- The sharper form of the base case: the best vertex even beats the variance
`R² - ‖x‖²`. -/
theorem maurey_one_point_variance [Nonempty ι]
    (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (V : ι → E) (R : ℝ) (hR : ∀ i, ‖V i‖ ≤ R) :
    ∃ i, ‖(∑ j, p j • V j) - V i‖ ^ 2 ≤ R ^ 2 - ‖∑ j, p j • V j‖ ^ 2 := by
  set x := ∑ j, p j • V j with hx
  have hmean : ∑ i, p i * ‖x - V i‖ ^ 2 ≤ R ^ 2 - ‖x‖ ^ 2 := by
    rw [weighted_mean_sq_dist p hsum V]
    have hsm : ∑ i, p i * ‖V i‖ ^ 2 ≤ ∑ i, p i * R ^ 2 :=
      Finset.sum_le_sum fun i _ =>
        mul_le_mul_of_nonneg_left
          (by nlinarith [norm_nonneg (V i), hR i]) (hp i)
    rw [← Finset.sum_mul, hsum, one_mul] at hsm
    linarith
  obtain ⟨i₀, hi₀⟩ :=
    exists_le_weighted_average p hp hsum (fun i => ‖x - V i‖ ^ 2)
  exact ⟨i₀, le_trans hi₀ hmean⟩

end ApproxCaratheodory