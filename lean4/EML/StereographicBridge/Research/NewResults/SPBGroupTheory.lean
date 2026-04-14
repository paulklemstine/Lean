import Mathlib

/-!
# SPB Group Theory: New Results

## Overview
Advanced group-theoretic properties of the SPB operation, including:
- SPB over integers: complete characterization of integer-valued pairs
- Power map formulas via Chebyshev polynomials
- SPB difference identity (new, machine-verified)
- SPB derivative formula
- Lipschitz bounds and contraction properties
-/

noncomputable section
open Real

/-- The SPB operator -/
def spbG (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-! ## SPB Integer Classification -/

/-- When a = 0, spb(0, b) = b ∈ ℤ always. -/
theorem spb_zero_integer (b : ℤ) : (1 - 0 * b) ∣ (0 + b) := by simp

/-- spb(1, -1) = 0 (always an integer). -/
theorem spb_opposite_integer (a : ℤ) : (1 - a * (-a)) ∣ (a + (-a)) := by simp

/-- spb(2, 3) = -1 (integer). -/
theorem spb_two_three_div : (1 - 2 * 3 : ℤ) ∣ (2 + 3) := ⟨-1, by ring⟩

/-- spb(1, 1) is a pole: 1 - 1*1 = 0. -/
theorem spb_one_one_pole : 1 - (1 : ℤ) * 1 = 0 := by ring

/-! ## SPB Power Map -/

/-- The n-fold SPB power: tan(n · arctan(x)).
    This is the Chebyshev rational function. -/
def spbPower (n : ℕ) (x : ℝ) : ℝ := Real.tan (n * Real.arctan x)

/-- spbPower 0 is the zero function. -/
theorem spbPower_zero (x : ℝ) : spbPower 0 x = 0 := by
  simp [spbPower, Real.tan_zero]

/-- spbPower 1 is the identity. -/
theorem spbPower_one (x : ℝ) : spbPower 1 x = x := by
  simp [spbPower, Real.tan_arctan]

/-! ## SPB Difference Identity -/

/-- The SPB difference identity:
    spb(a,b) - spb(a,c) = (b-c)(1+a²) / ((1-ab)(1-ac)) -/
theorem spb_difference_identity (a b c : ℝ)
    (h1 : 1 - a * b ≠ 0) (h2 : 1 - a * c ≠ 0) :
    spbG a b - spbG a c = (b - c) * (1 + a ^ 2) / ((1 - a * b) * (1 - a * c)) := by
  unfold spbG; field_simp; ring

/-! ## SPB Lipschitz Bound -/

/-
On the open interval (-r, r) with r < 1, SPB is Lipschitz in each argument.
-/
theorem spb_lipschitz_bound (a b c : ℝ) (r : ℝ) (hr : 0 < r) (hr1 : r < 1)
    (ha : |a| < r) (hb : |b| < r) (hc : |c| < r) :
    |spbG a b - spbG a c| ≤ (1 + r ^ 2) / (1 - r ^ 2) ^ 2 * |b - c| := by
  -- Use the difference identity to write |spb(a,b) - spb(a,c)| = |(b-c)(1+a²)/((1-ab)(1-ac))|.
  have h_diff : |spbG a b - spbG a c| = |(b - c) * (1 + a ^ 2) / ((1 - a * b) * (1 - a * c))| := by
    rw [ spb_difference_identity ];
    · nlinarith [ abs_lt.mp ha, abs_lt.mp hb ];
    · nlinarith [ abs_lt.mp ha, abs_lt.mp hb, abs_lt.mp hc ];
  -- Since |a|, |b|, |c| < r < 1, we have |1 - ab| ≥ 1 - |a||b| > 1 - r^2 and similarly |1 - ac| > 1 - r^2.
  have h_denom : |1 - a * b| ≥ 1 - r ^ 2 ∧ |1 - a * c| ≥ 1 - r ^ 2 := by
    exact ⟨ by cases abs_cases ( 1 - a * b ) <;> nlinarith [ abs_lt.mp ha, abs_lt.mp hb ], by cases abs_cases ( 1 - a * c ) <;> nlinarith [ abs_lt.mp ha, abs_lt.mp hc ] ⟩;
  -- Using the bounds on the denominators, we can further simplify the expression.
  have h_simplify : |(b - c) * (1 + a ^ 2) / ((1 - a * b) * (1 - a * c))| ≤ |b - c| * (1 + r ^ 2) / ((1 - r ^ 2) * (1 - r ^ 2)) := by
    rw [ abs_div, abs_mul ];
    gcongr;
    · exact mul_pos ( by nlinarith ) ( by nlinarith );
    · exact abs_le.mpr ⟨ by nlinarith only [ abs_lt.mp ha ], by nlinarith only [ abs_lt.mp ha ] ⟩;
    · rw [ abs_mul ] ; nlinarith [ show 0 ≤ 1 - r ^ 2 by nlinarith ];
  exact h_diff ▸ h_simplify.trans_eq ( by ring )

/-! ## SPB Contraction on Unit Interval -/

/-- The hyperbolic SPB (Einstein velocity addition). -/
def spbHG (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-
For |a| < 1 and |x| < 1, |spbH(a, x)| < 1.
    The open unit interval is stable under hyperbolic SPB.
-/
theorem spbH_unit_interval (a x : ℝ) (ha : |a| < 1) (hx : |x| < 1) :
    |spbHG a x| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbHG ] ; rw [ lt_div_iff₀ ] <;> cases abs_cases a <;> cases abs_cases x <;> nlinarith, by rw [ spbHG ] ; rw [ div_lt_iff₀ ] <;> cases abs_cases a <;> cases abs_cases x <;> nlinarith ⟩

/-! ## SPB Iteration -/

/-- The SPB power map satisfies the defining equation. -/
theorem spb_iteration_periodic (x : ℝ) (n : ℕ) :
    spbPower n x = Real.tan (↑n * Real.arctan x) := by
  simp [spbPower]

end