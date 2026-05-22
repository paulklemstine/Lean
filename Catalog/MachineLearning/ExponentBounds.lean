/-
Copyright (c) 2025. All rights reserved.

# Exponent Reciprocal Bounds and Fermat–Catalan Connection

This file proves that for exponents `x, y, z > 2`:
1. `1/x + 1/y + 1/z ≤ 1` (the Beal exponent regime sits at or below the
   Fermat–Catalan threshold)
2. Equality holds iff `x = y = z = 3` (the cubic boundary case)

These results formally position Beal inside the landscape of generalized
Fermat equations and show why abc/Fermat–Catalan technology is naturally adjacent.
-/
import Mathlib

/-! ## Reciprocal sum bound -/

/-
For exponents `x, y, z > 2`, the sum of reciprocals is at most 1.
This places Beal solutions in the "hyperbolic" or "boundary" regime
of the Fermat–Catalan classification.
-/
theorem beal_exponents_reciprocal_bound
    {x y z : ℕ} (hx : 2 < x) (hy : 2 < y) (hz : 2 < z) :
    (1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z ≤ 1 := by
  exact le_trans ( add_le_add_three ( one_div_le_one_div_of_le ( by positivity ) ( Nat.cast_le.mpr hx ) ) ( one_div_le_one_div_of_le ( by positivity ) ( Nat.cast_le.mpr hy ) ) ( one_div_le_one_div_of_le ( by positivity ) ( Nat.cast_le.mpr hz ) ) ) ( by norm_num )

/-
The reciprocal sum equals 1 if and only if all exponents are exactly 3.
This identifies `(3,3,3)` as the unique boundary case.
-/
theorem reciprocal_sum_eq_one_iff_three_three_three
    {x y z : ℕ} (hx : 2 < x) (hy : 2 < y) (hz : 2 < z) :
    ((1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z = 1) ↔ (x = 3 ∧ y = 3 ∧ z = 3) := by
  constructor <;> intro H;
  · -- Assume that $x$, $y$, and $z$ are all greater than 2 and satisfy the equation. We'll derive a contradiction if any of them is greater than 3.
    by_cases hx3 : x > 3
    by_cases hy3 : y > 3
    by_cases hz3 : z > 3;
    · field_simp at H;
      norm_cast at H; nlinarith only [ mul_pos ( by linarith : 0 < y ) ( by linarith : 0 < z ), mul_pos ( by linarith : 0 < x ) ( by linarith : 0 < z ), mul_pos ( by linarith : 0 < x ) ( by linarith : 0 < y ), H, hx3, hy3, hz3 ] ;
    · interval_cases z ; norm_num at *;
      field_simp at H;
      norm_cast at H; nlinarith;
    · interval_cases y ; norm_num at *;
      field_simp at H;
      norm_cast at H; nlinarith [ show z = 2 by nlinarith ] ;
    · interval_cases x ; norm_num at *;
      field_simp at H;
      norm_cast at H; rcases y with ( _ | _ | _ | _ | y ) <;> rcases z with ( _ | _ | _ | _ | z ) <;> norm_num at * <;> nlinarith;
  · norm_num [ H ]

/-
For exponents `x, y, z > 2` not all equal to 3, the reciprocal sum is strictly less than 1.
This is the regime where Fermat–Catalan predicts only finitely many primitive solutions.
-/
theorem strict_reciprocal_bound_of_not_all_three
    {x y z : ℕ} (hx : 2 < x) (hy : 2 < y) (hz : 2 < z)
    (hNot : ¬(x = 3 ∧ y = 3 ∧ z = 3)) :
    (1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z < 1 := by
  convert lt_of_le_of_ne ( beal_exponents_reciprocal_bound hx hy hz ) ?_;
  convert reciprocal_sum_eq_one_iff_three_three_three hx hy hz |>.not.mpr hNot using 1;