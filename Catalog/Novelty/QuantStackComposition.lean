import Mathlib
import Novelty.QuantCurvatureNoFloor

/-!
# Composing quantisation axes: the serving-stack budget is a seminorm

Cycle 2 of the NET-95 thread.  The practical claim attached to the measurement is
that a CPU serving stack composes independent compressions — `q4_k_m` weights
(+1.816%) with a K8/V4 cache (+0.14%) — and that the aggregate cost is "about the
sum".  This file proves what the curvature model actually licenses, which is
strictly stronger and quantitative.

In the second-order model of `Novelty.QuantCurvatureNoFloor`, the excess loss
`quadExcess lam e = ½ ∑ᵢ λᵢ eᵢ²` is the *square of a seminorm* in the
perturbation `e`.  Consequently:

* `quadExcess_sqrt_subadditive` / `quadExcess_add_le` — the triangle inequality:
  `√Q(e + f) ≤ √Q(e) + √Q(f)`.  Costs add in the square-root scale, never worse.
  (Proved from the discrete Cauchy–Schwarz inequality applied to the vectors
  `√λᵢ eᵢ` and `√λᵢ fᵢ`; degeneracy `λᵢ = 0` is allowed.)
* `stack_excess_le` — hence a two-axis budget: `Q ≤ a + b + 2√(ab)`.
* `cpu_stack_aggregate_bound` — instantiated at the measured numbers, the whole
  weight + cache stack is guaranteed to cost **under 3%** of perplexity, whatever
  the correlation between the two perturbations.
* `stack_excess_additive_of_orthogonal` — and if the two perturbations are
  orthogonal in the Hessian metric (the "independent noise" hypothesis), the cost
  is *exactly* additive.  With the measured numbers this predicts
  `1.816% + 0.14% = 1.956%`, versus the worst-case `2.97%`: a sharp, falsifiable
  prediction for the joint weight × cache arm that has not yet been run.
-/

namespace Catalog.Novelty.QuantStack

open Finset Catalog.Novelty.QuantCurvature

variable {n : ℕ}

/-- The Hessian-metric pairing of two perturbations. -/
noncomputable def quadPair (lam e f : Fin n → ℝ) : ℝ := (1 / 2) * ∑ i, lam i * (e i * f i)

/-- Expansion of the quadratic excess along a sum of perturbations. -/
theorem quadExcess_add_expand (lam e f : Fin n → ℝ) :
    quadExcess lam (e + f) = quadExcess lam e + quadExcess lam f + 2 * quadPair lam e f := by
  have key : ∑ i, lam i * (e i + f i) ^ 2
      = (∑ i, lam i * e i ^ 2) + (∑ i, lam i * f i ^ 2) + 2 * ∑ i, lam i * (e i * f i) := by
    rw [Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  simp only [quadExcess, quadPair, Pi.add_apply, key]
  ring

/-- **Cauchy–Schwarz in the Hessian metric.**  Valid for a positive
*semi*definite Hessian: eigenvalues are only assumed nonnegative. -/
theorem quadPair_sq_le (lam e f : Fin n → ℝ) (hlam : ∀ i, 0 ≤ lam i) :
    quadPair lam e f ^ 2 ≤ quadExcess lam e * quadExcess lam f := by
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun i => Real.sqrt (lam i) * e i) (fun i => Real.sqrt (lam i) * f i)
  have hrw : ∀ (g : Fin n → ℝ), ∑ i, (Real.sqrt (lam i) * g i) ^ 2 = ∑ i, lam i * g i ^ 2 := by
    intro g
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [mul_pow, Real.sq_sqrt (hlam i)]
  have hmix : ∑ i, (Real.sqrt (lam i) * e i) * (Real.sqrt (lam i) * f i)
      = ∑ i, lam i * (e i * f i) := by
    refine Finset.sum_congr rfl fun i _ => ?_
    have : Real.sqrt (lam i) * Real.sqrt (lam i) = lam i :=
      Real.mul_self_sqrt (hlam i)
    calc (Real.sqrt (lam i) * e i) * (Real.sqrt (lam i) * f i)
        = (Real.sqrt (lam i) * Real.sqrt (lam i)) * (e i * f i) := by ring
      _ = lam i * (e i * f i) := by rw [this]
  rw [hmix, hrw e, hrw f] at hcs
  have h4 : (4 : ℝ) * (quadPair lam e f ^ 2) ≤ 4 * (quadExcess lam e * quadExcess lam f) := by
    simp only [quadPair, quadExcess]
    nlinarith [hcs]
  linarith

/-- **The triangle inequality for quantisation cost.**  `√Q` is a seminorm in the
perturbation, so the excess of a composed stack is at most the square of the sum
of the individual square-root costs. -/
theorem quadExcess_add_le (lam e f : Fin n → ℝ) (hlam : ∀ i, 0 ≤ lam i) :
    quadExcess lam (e + f)
      ≤ (Real.sqrt (quadExcess lam e) + Real.sqrt (quadExcess lam f)) ^ 2 := by
  have hne := quadExcess_nonneg lam e hlam
  have hnf := quadExcess_nonneg lam f hlam
  have hcs := quadPair_sq_le lam e f hlam
  have hpair : quadPair lam e f ≤ Real.sqrt (quadExcess lam e) * Real.sqrt (quadExcess lam f) := by
    have hprod : Real.sqrt (quadExcess lam e) * Real.sqrt (quadExcess lam f)
        = Real.sqrt (quadExcess lam e * quadExcess lam f) := (Real.sqrt_mul hne _).symm
    rw [hprod]
    have h1 : quadPair lam e f ≤ |quadPair lam e f| := le_abs_self _
    have h2 : |quadPair lam e f| ≤ Real.sqrt (quadExcess lam e * quadExcess lam f) := by
      rw [← Real.sqrt_sq_eq_abs]
      exact Real.sqrt_le_sqrt hcs
    linarith
  have hexp := quadExcess_add_expand lam e f
  have hse : Real.sqrt (quadExcess lam e) ^ 2 = quadExcess lam e := Real.sq_sqrt hne
  have hsf : Real.sqrt (quadExcess lam f) ^ 2 = quadExcess lam f := Real.sq_sqrt hnf
  nlinarith [hexp, hpair, hse, hsf]

/-- The square-root form of the triangle inequality: costs are subadditive in the
`√Q` scale. -/
theorem quadExcess_sqrt_subadditive (lam e f : Fin n → ℝ) (hlam : ∀ i, 0 ≤ lam i) :
    Real.sqrt (quadExcess lam (e + f))
      ≤ Real.sqrt (quadExcess lam e) + Real.sqrt (quadExcess lam f) := by
  have h := quadExcess_add_le lam e f hlam
  have hsum : 0 ≤ Real.sqrt (quadExcess lam e) + Real.sqrt (quadExcess lam f) := by positivity
  calc Real.sqrt (quadExcess lam (e + f))
      ≤ Real.sqrt ((Real.sqrt (quadExcess lam e) + Real.sqrt (quadExcess lam f)) ^ 2) :=
        Real.sqrt_le_sqrt h
    _ = Real.sqrt (quadExcess lam e) + Real.sqrt (quadExcess lam f) := by
        rw [Real.sqrt_sq hsum]

/-- **Two-axis budget.**  If the weight-quantisation arm costs at most `a` and the
cache-quantisation arm at most `b`, the composed stack costs at most
`a + b + 2√(ab)` — whatever the correlation between the two perturbations. -/
theorem stack_excess_le (lam ew ec : Fin n → ℝ) (hlam : ∀ i, 0 ≤ lam i) (a b : ℝ)
    (hw : quadExcess lam ew ≤ a) (hc : quadExcess lam ec ≤ b) :
    quadExcess lam (ew + ec) ≤ a + b + 2 * Real.sqrt (a * b) := by
  have hne := quadExcess_nonneg lam ew hlam
  have hnf := quadExcess_nonneg lam ec hlam
  have ha : 0 ≤ a := le_trans hne hw
  have hb : 0 ≤ b := le_trans hnf hc
  have hexp := quadExcess_add_expand lam ew ec
  have hcs := quadPair_sq_le lam ew ec hlam
  have hpairle : quadPair lam ew ec ≤ Real.sqrt (a * b) := by
    have h1 : quadPair lam ew ec ≤ |quadPair lam ew ec| := le_abs_self _
    have h2 : |quadPair lam ew ec| ≤ Real.sqrt (a * b) := by
      rw [← Real.sqrt_sq_eq_abs]
      refine Real.sqrt_le_sqrt (le_trans hcs ?_)
      nlinarith [hne, hnf, hw, hc]
    linarith
  linarith [hexp, hpairle, hw, hc]

/-- **The measured CPU stack.**  `q4_k_m` weights (`+1.816%`) composed with a
K8/V4 cache (`+0.14%`) cost under `3%` in the curvature model — even in the
worst case, where the two perturbations are perfectly aligned. -/
theorem cpu_stack_aggregate_bound (lam ew ec : Fin n → ℝ) (hlam : ∀ i, 0 ≤ lam i)
    (hw : quadExcess lam ew ≤ 1816 / 100000) (hc : quadExcess lam ec ≤ 14 / 10000) :
    quadExcess lam (ew + ec) < 3 / 100 := by
  have hbound := stack_excess_le lam ew ec hlam _ _ hw hc
  have hsqrt : Real.sqrt ((1816 / 100000 : ℝ) * (14 / 10000)) ≤ 51 / 10000 := by
    have h1 : ((1816 / 100000 : ℝ) * (14 / 10000)) ≤ (51 / 10000) ^ 2 := by norm_num
    calc Real.sqrt ((1816 / 100000 : ℝ) * (14 / 10000))
        ≤ Real.sqrt ((51 / 10000 : ℝ) ^ 2) := Real.sqrt_le_sqrt h1
      _ = 51 / 10000 := Real.sqrt_sq (by norm_num)
  have : (1816 / 100000 : ℝ) + 14 / 10000 + 2 * (51 / 10000) < 3 / 100 := by norm_num
  linarith

/-- **The sharp prediction.**  If the two perturbations are orthogonal in the
Hessian metric — the natural "independent compressions" hypothesis — the costs
are *exactly* additive.  At the measured numbers this predicts `1.956%` for the
joint weight × cache arm, against the worst-case guarantee of under `3%`. -/
theorem stack_excess_additive_of_orthogonal (lam ew ec : Fin n → ℝ)
    (horth : quadPair lam ew ec = 0) :
    quadExcess lam (ew + ec) = quadExcess lam ew + quadExcess lam ec := by
  rw [quadExcess_add_expand, horth]
  ring

end Catalog.Novelty.QuantStack