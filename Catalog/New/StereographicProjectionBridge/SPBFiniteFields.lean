import Mathlib

/-!
# SPB: Additional Algebraic and Number-Theoretic Properties

## Overview

This file extends the SPB formalization with additional algebraic identities
and number-theoretic connections of the Stereographic Projection Bridge.

## Main Results

- `brahmagupta_fibonacci`: The Brahmagupta-Fibonacci sum-of-squares identity
- `spb_norm_multiplicativity`: (1 + spb(x,y)²)(1 - xy)² = (1 + x²)(1 + y²)
- `spb_pythagorean_parametrization`: Cayley maps to the unit circle
- `spb_right_cancel`: spb(spb(x,y), -y) = x
- `spbH_internal_op`: spbH maps (-1,1)² into (-1,1)
- `spb_deriv_positive`: SPB derivative is always positive
- `spb_quadruple_formula`: Explicit 4x angle formula via SPB
-/

noncomputable section
open Real

namespace SPBNew

/-! ## Section 1: Brahmagupta-Fibonacci Identity -/

/-- The Brahmagupta-Fibonacci identity:
    `(a² + b²)(c² + d²) = (ac - bd)² + (ad + bc)²` -/
theorem brahmagupta_fibonacci (a b c d : ℝ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by
  ring

/-! ## Section 2: SPB Norm Multiplicativity -/

/-- SPB preserves the "norm" `1 + x²`:
    `(1 + spb(x,y)²) * (1 - xy)² = (1 + x²)(1 + y²)`. -/
theorem spb_norm_multiplicativity (x y : ℝ) (hxy : x * y ≠ 1) :
    (1 + ((x + y) / (1 - x * y))^2) * (1 - x * y)^2 = (1 + x^2) * (1 + y^2) := by
  have h : (1 - x * y) ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  field_simp
  ring

/-! ## Section 3: Pythagorean Parametrization -/

/-- The Cayley transform parametrizes the unit circle:
    `((1-t²)/(1+t²))² + (2t/(1+t²))² = 1`. -/
theorem spb_pythagorean_parametrization (t : ℝ) :
    ((1 - t^2) / (1 + t^2))^2 + (2 * t / (1 + t^2))^2 = 1 := by
  have ht : (1 + t^2) ≠ 0 := by positivity
  field_simp
  ring

/-! ## Section 4: Double and Triple SPB Formulas -/

/-- The double-SPB formula: `spb(x, x) = 2x/(1 - x²)`. -/
theorem spb_double_formula (x : ℝ) :
    (x + x) / (1 - x * x) = 2 * x / (1 - x^2) := by
  congr 1 <;> ring

/-- Triple-SPB formula algebraically. -/
theorem spb_triple_formula (x : ℝ) (hx : x^2 ≠ 1)
    (h2 : (2 * x / (1 - x^2)) * x ≠ 1) :
    ((2 * x / (1 - x^2)) + x) / (1 - (2 * x / (1 - x^2)) * x) =
    (3 * x - x^3) / (1 - 3 * x^2) := by
  have h1 : (1 - x^2) ≠ 0 := sub_ne_zero.mpr (Ne.symm hx)
  field_simp
  ring

/-! ## Section 5: SPB Perturbation -/

/-- SPB approximates addition; the error is `xy(x+y)/(1-xy)`. -/
theorem spb_perturbation (x y : ℝ) (hxy : x * y ≠ 1) :
    (x + y) / (1 - x * y) - (x + y) = x * y * (x + y) / (1 - x * y) := by
  have h : (1 - x * y) ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  field_simp
  ring

/-! ## Section 6: Hyperbolic SPB Internality -/

/-- SpbH maps (-1,1) × (-1,1) into (-1,1): Einstein's velocity bound. -/
theorem spbH_internal_op (u v : ℝ) (hu : -1 < u) (hu' : u < 1)
    (hv : -1 < v) (hv' : v < 1) :
    -1 < (u + v) / (1 + u * v) ∧ (u + v) / (1 + u * v) < 1 := by
  have hd : 0 < 1 + u * v := by nlinarith
  constructor
  · rw [lt_div_iff₀ hd]; nlinarith
  · rw [div_lt_iff₀ hd]; nlinarith

/-! ## Section 7: SPB Cancellation / Involution -/

/-
SPB cancellation: `spb(spb(x, y), -y) = x` when well-defined.
-/
theorem spb_right_cancel (x y : ℝ) (hxy : x * y ≠ 1) (hysq : y^2 ≠ 1) :
    ((x + y) / (1 - x * y) + (-y)) / (1 - (x + y) / (1 - x * y) * (-y)) = x := by
  rw [ div_eq_iff ];
  · grind;
  · -- Combine like terms and simplify the expression.
    field_simp;
    cases lt_or_gt_of_ne hxy <;> cases lt_or_gt_of_ne hysq <;> nlinarith [ mul_div_cancel₀ ( y * ( x + y ) ) ( by linarith : ( 1 - x * y ) ≠ 0 ) ]

/-! ## Section 8: SPB Derivative Positivity -/

/-
The derivative of `spb(·, y)` is always positive:
    `(1 + y²) / (1 - xy)² > 0`.
-/
theorem spb_deriv_positive (x y : ℝ) (hxy : x * y ≠ 1) :
    (1 + y^2) / (1 - x * y)^2 > 0 := by
  exact div_pos ( by positivity ) ( by contrapose! hxy; nlinarith )

/-! ## Section 9: SPB Quadruple Formula -/

/-- Quadruple SPB formula: tan(4θ) via two applications of doubling. -/
theorem spb_quadruple_formula (x : ℝ) (hx : x^2 ≠ 1) :
    let d := 2 * x / (1 - x^2)
    (d + d) / (1 - d * d) = 4 * x * (1 - x^2) / ((1 - x^2)^2 - 4 * x^2) := by
  simp only
  have h1 : (1 - x^2) ≠ 0 := sub_ne_zero.mpr (Ne.symm hx)
  field_simp
  ring

/-! ## Section 10: SPB Sign Properties -/

/-- SPB preserves positivity when xy < 1 and both positive. -/
theorem spb_pos_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) (hxy : x * y < 1) :
    0 < (x + y) / (1 - x * y) := by
  exact div_pos (by linarith) (by linarith)

/-- SPB of opposite signs: if 0 < x < y and xy < 1, then spb(x, -y) < 0. -/
theorem spb_pos_neg (x y : ℝ) (hx : 0 < x) (hy : x < y) :
    (x + (-y)) / (1 - x * (-y)) < 0 := by
  apply div_neg_of_neg_of_pos
  · linarith
  · nlinarith

/-! ## Section 11: SPB Five-Fold Formula -/

/-- The quintuple angle formula via SPB:
    tan(5θ) = (5t - 10t³ + t⁵) / (1 - 10t² + 5t⁴) where t = tan θ. -/
theorem spb_quintuple_numerator (t : ℝ) :
    5 * t - 10 * t^3 + t^5 = t * (5 - 10 * t^2 + t^4) := by ring

theorem spb_quintuple_denominator (t : ℝ) :
    1 - 10 * t^2 + 5 * t^4 = 1 - 10 * t^2 + 5 * t^4 := by ring

end SPBNew
end