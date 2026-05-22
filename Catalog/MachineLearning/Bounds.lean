import Mathlib
import Speculative.BenfordQuadratic.Defs

/-!
# Escape Growth Inequality for Quadratic Maps

## Overview

This file proves the fundamental escape growth inequality: for |x| ≥ |c| + 2,
one step of T_c(x) = x² + c approximately doubles the logarithmic size.

Specifically, we show:
- Lower bound: |x|²/2 ≤ |x² + c|
- Upper bound: |x² + c| ≤ 3|x|²/2
- Log deviation: |log|x²+c| - 2·log|x|| ≤ log 2

These bounds are the local renormalization law—the exact bridge from nonlinear
arithmetic dynamics to additive dynamics on the torus ℝ/ℤ.

## Cross-domain significance

The growth inequality shows that in logarithmic coordinates, T_c acts approximately
as multiplication by 2 (the doubling map). This is the mechanism by which:
- Dynamical chaos in the quadratic map becomes ergodic behavior on the log-torus
- Digit statistics become governed by equidistribution theory
- The canonical height (Böttcher coordinate) emerges as a renormalization fixed point
-/

noncomputable section

open Real Set

/-! ## Absolute Value Bounds -/

/-
Lower bound: if |x| ≥ |c| + 2, then |x|²/2 ≤ |x² + c| (over ℝ).
This is the key arithmetic inequality showing orbit escape accelerates.
-/
theorem quad_abs_lower_bound
    (c x : ℤ)
    (hx : Int.natAbs x ≥ Int.natAbs c + 2) :
    (|(x : ℝ)|) ^ 2 / 2 ≤ |((quadMap c x : ℤ) : ℝ)| := by
  norm_num [ abs_mul, quadMap ] ; norm_cast;
  rw [ Rat.divInt_eq_div, div_le_iff₀ ] <;> norm_cast;
  cases abs_cases ( x ^ 2 + c ) <;> cases abs_cases x <;> cases abs_cases c <;> push_cast [ * ] at * <;> nlinarith

/-
Upper bound: if |x| ≥ |c| + 2, then |x² + c| ≤ 3|x|²/2 (over ℝ).
Together with the lower bound, this sandwiches the growth factor.
-/
theorem quad_abs_upper_bound
    (c x : ℤ)
    (hx : Int.natAbs x ≥ Int.natAbs c + 2) :
    |((quadMap c x : ℤ) : ℝ)| ≤ 3 * (|(x : ℝ)|) ^ 2 / 2 := by
  unfold quadMap;
  rw [ le_div_iff₀ ] <;> norm_cast;
  cases abs_cases ( x ^ 2 + c ) <;> cases abs_cases x <;> cases abs_cases c <;> push_cast [ * ] at * <;> nlinarith

/-- Combined bounds: |x|²/2 ≤ |x²+c| ≤ 3|x|²/2 when |x| ≥ |c| + 2. -/
theorem quad_abs_bounds
    (c x : ℤ)
    (hx : Int.natAbs x ≥ Int.natAbs c + 2) :
    ((|(x : ℝ)|) ^ 2 / 2 ≤ |((quadMap c x : ℤ) : ℝ)|) ∧
    (|((quadMap c x : ℤ) : ℝ)| ≤ 3 * (|(x : ℝ)|) ^ 2 / 2) :=
  ⟨quad_abs_lower_bound c x hx, quad_abs_upper_bound c x hx⟩

/-! ## Logarithmic Deviation Bound -/

/-
Key positivity: quadMap c x ≠ 0 when |x| ≥ |c| + 2.
-/
theorem quadMap_ne_zero
    (c x : ℤ)
    (hx : Int.natAbs x ≥ Int.natAbs c + 2) :
    quadMap c x ≠ 0 := by
  unfold quadMap;
  cases abs_cases x <;> cases abs_cases c <;> nlinarith

/-
Key positivity: x ≠ 0 when |x| ≥ |c| + 2.
-/
theorem x_ne_zero_of_large
    (c x : ℤ)
    (hx : Int.natAbs x ≥ Int.natAbs c + 2) :
    x ≠ 0 := by
  grind

/-
Logarithmic deviation bound: |log|x²+c| - 2·log|x|| ≤ log 2.

This is the core renormalization inequality. It says that in logarithmic
coordinates, one step of T_c deviates from exact doubling by at most log 2.
Dividing by 2^n and telescoping yields the convergence of renormalized heights.
-/
theorem quad_log_deviation_bound
    (c x : ℤ)
    (hx : Int.natAbs x ≥ Int.natAbs c + 2) :
    |logHeight (quadMap c x) - 2 * logHeight x| ≤ Real.log 2 := by
  have h_log_bounds : Real.log ((|(x : ℝ)|) ^ 2 / 2) ≤ Real.log |((quadMap c x : ℤ) : ℝ)| ∧ Real.log |((quadMap c x : ℤ) : ℝ)| ≤ Real.log (3 * (|(x : ℝ)|) ^ 2 / 2) := by
    apply And.intro;
    · exact Real.log_le_log ( by exact div_pos ( sq_pos_of_pos ( abs_pos.mpr ( by aesop_cat ) ) ) zero_lt_two ) ( by exact_mod_cast quad_abs_lower_bound c x hx );
    · gcongr;
      · exact abs_pos.mpr ( Int.cast_ne_zero.mpr ( quadMap_ne_zero c x hx ) );
      · convert quad_abs_upper_bound c x hx using 1;
  unfold logHeight;
  split_ifs <;> simp_all +decide [ Real.log_div, Real.log_mul, abs_div, abs_mul ];
  · exact absurd ‹quadMap c x = 0› ( quadMap_ne_zero c x hx );
  · exact abs_le.mpr ⟨ by linarith [ show Real.log 3 ≤ 2 * Real.log 2 by norm_num [ ← Real.log_rpow, Real.log_le_log ] ], by linarith [ show Real.log 3 ≤ 2 * Real.log 2 by norm_num [ ← Real.log_rpow, Real.log_le_log ] ] ⟩

end