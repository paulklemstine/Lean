/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Wigner Semicircle Density

This file develops the analytic side of the Wigner semicircle law: the density
of the (radius-1) semicircle distribution,

  f(x) = (2/π) · √(1 - x²),

supported on `[-1, 1]`.  This is the probability density towards which the
empirical spectral measures of normalized Wigner ensembles converge.  We prove it
is a genuine probability density (nonnegative, symmetric, integrates to `1`) and
compute its low-order moments (mean `0`, second moment `1/4`).

## Main results

- `scDensity_nonneg`        — the density is nonnegative.
- `scDensity_symm`          — the density is even (symmetry of the spectrum).
- `scDensity_eq_zero`       — the density vanishes outside `[-1, 1]` (compact support).
- `scDensity_normalization` — `∫_{-1}^{1} f = 1` (total probability mass).
- `scDensity_mean_zero`     — `∫_{-1}^{1} x · f(x) dx = 0` (mean of the law).
- `scDensity_second_moment` — `∫_{-1}^{1} x² · f(x) dx = 1/4` (variance of the law).
-/
import Mathlib

namespace MachineLearning.WignerSemicircle

open scoped Real
open MeasureTheory intervalIntegral

/-- The density of the radius-`1` Wigner semicircle distribution,
`f(x) = (2/π)·√(1 - x²)`.  Outside `[-1,1]` the argument of the square root is
negative, so `Real.sqrt` returns `0` and the density has compact support. -/
noncomputable def scDensity (x : ℝ) : ℝ := (2 / Real.pi) * Real.sqrt (1 - x ^ 2)

/-- The semicircle density is nonnegative. -/
theorem scDensity_nonneg (x : ℝ) : 0 ≤ scDensity x := by
  unfold scDensity; positivity

/-- The semicircle density is even: `f(-x) = f(x)`. -/
theorem scDensity_symm (x : ℝ) : scDensity (-x) = scDensity x := by
  unfold scDensity; rw [show (1 : ℝ) - (-x) ^ 2 = 1 - x ^ 2 by ring]

/-- The semicircle density has compact support: it vanishes outside `[-1,1]`. -/
theorem scDensity_eq_zero {x : ℝ} (hx : 1 < |x|) : scDensity x = 0 := by
  unfold scDensity
  have hx2 : 1 < x ^ 2 := by nlinarith [sq_abs x, abs_nonneg x]
  rw [Real.sqrt_eq_zero_of_nonpos (by linarith), mul_zero]

/-- Normalization: the semicircle density integrates to `1` over its support,
so it is a genuine probability density. -/
theorem scDensity_normalization : ∫ x in (-1 : ℝ)..1, scDensity x = 1 := by
  unfold scDensity
  rw [intervalIntegral.integral_const_mul, integral_sqrt_one_sub_sq]
  field_simp

/-- The mean of the semicircle distribution is `0` (spectral symmetry).  This is
proved by an odd-function symmetry argument: substituting `x ↦ -x` negates the
integrand but preserves the (symmetric) domain. -/
theorem scDensity_mean_zero : ∫ x in (-1 : ℝ)..1, x * scDensity x = 0 := by
  have h1 : (∫ x in (-1 : ℝ)..1, (-x) * scDensity (-x)) = ∫ x in (-1 : ℝ)..1, x * scDensity x := by
    have h := integral_comp_neg (a := (-1 : ℝ)) (b := 1) (f := fun x => x * scDensity x)
    simpa using h
  have h2 : (∫ x in (-1 : ℝ)..1, (-x) * scDensity (-x)) = - ∫ x in (-1 : ℝ)..1, x * scDensity x := by
    rw [← intervalIntegral.integral_neg]
    apply integral_congr
    intro x _
    simp only
    rw [scDensity_symm]; ring
  rw [h2] at h1
  linarith

/-- The second moment (variance) of the radius-`1` semicircle distribution is
`1/4`.  Equivalently `∫_{-1}^{1} x²·√(1-x²) dx = π/8`. -/
theorem scDensity_second_moment : ∫ x in (-1 : ℝ)..1, x ^ 2 * scDensity x = 1 / 4 := by
  have key : ∫ x in (-1 : ℝ)..1, x ^ 2 * Real.sqrt (1 - x ^ 2) = π / 8 := by
    calc ∫ x in (-1 : ℝ)..1, x ^ 2 * Real.sqrt (1 - x ^ 2)
        = ∫ x in Real.sin (-(π / 2))..Real.sin (π / 2), x ^ 2 * Real.sqrt (1 - x ^ 2) := by
            rw [Real.sin_neg, Real.sin_pi_div_two]
      _ = ∫ x in (-(π / 2))..(π / 2),
            (Real.sin x) ^ 2 * Real.sqrt (1 - (Real.sin x) ^ 2) * Real.cos x :=
            (integral_comp_mul_deriv (fun x _ => Real.hasDerivAt_sin x)
              Real.continuousOn_cos (by fun_prop)).symm
      _ = ∫ x in (-(π / 2))..(π / 2), Real.sin x ^ 2 * Real.cos x ^ 2 := by
            refine integral_congr_ae (MeasureTheory.ae_of_all _ fun _ h => ?_)
            rw [Set.uIoc_of_le (neg_le_self (le_of_lt (half_pos Real.pi_pos))), Set.mem_Ioc] at h
            rw [← Real.cos_eq_sqrt_one_sub_sin_sq (le_of_lt h.1) h.2]; ring
      _ = π / 8 := by
            rw [integral_sin_sq_mul_cos_sq]
            have e1 : (4 : ℝ) * (π / 2) = 2 * π := by ring
            have e2 : (4 : ℝ) * (-(π / 2)) = -(2 * π) := by ring
            rw [e1, e2, Real.sin_neg, Real.sin_two_pi]
            ring
  have hpull : (∫ x in (-1 : ℝ)..1, x ^ 2 * scDensity x)
      = (2 / π) * ∫ x in (-1 : ℝ)..1, x ^ 2 * Real.sqrt (1 - x ^ 2) := by
    rw [← intervalIntegral.integral_const_mul]
    apply integral_congr
    intro x _
    unfold scDensity; ring
  rw [hpull, key]
  field_simp
  ring

end MachineLearning.WignerSemicircle