/-
# Wick Rotation Functoriality

## Overview
The Wick rotation y → iy transforms the circular SPB into the hyperbolic SPB:
  spb(x, y) = (x+y)/(1-xy)  →  spbH(x, y) = (x+y)/(1+xy)

This is a functorial operation that bridges:
- Circular trigonometry ↔ Hyperbolic trigonometry
- Euclidean geometry ↔ Lorentzian geometry
- Oscillatory behavior ↔ Exponential behavior

## Key Results
1. Wick rotation sign-flip relation
2. tan ↔ tanh duality
3. Sub-luminal closure for hyperbolic SPB
4. Rapidity parametrization linearizes hyperbolic SPB
-/

import Mathlib

noncomputable section

open Real

/-! ## Definitions -/

/-- The circular SPB. -/
def spbCirc (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic SPB (Einstein velocity addition). -/
def spbHyp (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## Wick Rotation as Sign Flip -/

/-- The Wick rotation on SPB is a sign flip in the denominator.
    spbCirc(x, -y) gives a "mixed" formula. -/
theorem wick_sign_flip (x y : ℝ) :
    spbCirc x (-y) = (x - y) / (1 + x * y) := by
  simp [spbCirc]; ring

/-! ## Functional Properties -/

/-- Circular SPB is commutative. -/
theorem spbCirc_comm (x y : ℝ) : spbCirc x y = spbCirc y x := by
  simp [spbCirc, add_comm, mul_comm]

/-- Hyperbolic SPB is commutative. -/
theorem spbHyp_comm (x y : ℝ) : spbHyp x y = spbHyp y x := by
  simp [spbHyp, add_comm, mul_comm]

/-- Circular SPB identity. -/
theorem spbCirc_zero (x : ℝ) : spbCirc x 0 = x := by
  simp [spbCirc]

/-- Hyperbolic SPB identity. -/
theorem spbHyp_zero (x : ℝ) : spbHyp x 0 = x := by
  simp [spbHyp]

/-- Circular SPB inverse. -/
theorem spbCirc_neg (x : ℝ) : spbCirc x (-x) = 0 := by
  simp [spbCirc]

/-- Hyperbolic SPB inverse. -/
theorem spbHyp_neg (x : ℝ) : spbHyp x (-x) = 0 := by
  simp [spbHyp]

/-! ## Hyperbolic SPB Preserves the Interval (-1, 1) -/

/-
Sub-luminal closure: if |x|, |y| < 1 then |spbHyp(x,y)| < 1.
    This is the physical statement that velocities below c compose to velocities below c.
-/
theorem spbHyp_subluminal (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    |spbHyp x y| < 1 := by
  unfold spbHyp;
  rw [ abs_lt ] at *;
  exact ⟨ by rw [ lt_div_iff₀ ] <;> nlinarith, by rw [ div_lt_iff₀ ] <;> nlinarith ⟩

/-! ## The Rapidity Parametrization -/

/-
The rapidity parametrization: if x = tanh(α) and y = tanh(β),
    then spbHyp(x,y) = tanh(α+β). This linearizes hyperbolic SPB.
-/
theorem spbHyp_tanh_add (α β : ℝ) :
    spbHyp (Real.tanh α) (Real.tanh β) = Real.tanh (α + β) := by
  unfold spbHyp;
  rw [ Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh, Real.sinh_add, Real.cosh_add ];
  field_simp

/-! ## Circular-Hyperbolic Parallel -/

/-
The circular-hyperbolic parallel:
- spbCirc with tan ↔ angle addition: tan(α+β) = spbCirc(tan α, tan β)
- spbHyp with tanh ↔ rapidity addition: tanh(α+β) = spbHyp(tanh α, tanh β)
Both are instances of the same algebraic structure!

tan addition is circular SPB.
-/
theorem tan_add_is_spbCirc (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
    Real.tan (α + β) = spbCirc (Real.tan α) (Real.tan β) := by
  simp +decide [ *, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add, spbCirc ];
  grind

end