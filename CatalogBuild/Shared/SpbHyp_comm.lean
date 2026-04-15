/-! # CatalogBuild.Shared.SpbHyp_comm

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6
-/

import Mathlib

noncomputable section

theorem spbHyp_comm (x y : ℝ) : spbHyp x y = spbHyp y x := by
  simp [spbHyp, add_comm, mul_comm]

/-- Circular SPB identity. -/

theorem spbHyp_zero (x : ℝ) : spbHyp x 0 = x := by
  simp [spbHyp]

/-- Circular SPB inverse. -/

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

theorem spbHyp_neg (x : ℝ) : spbHyp x (-x) = 0 := by
  simp [spbHyp]

/-! ## Hyperbolic SPB Preserves the Interval (-1, 1) -/

/-
Sub-luminal closure: if |x|, |y| < 1 then |spbHyp(x,y)| < 1.
    This is the physical statement that velocities below c compose to velocities below c.
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

def spbHyp (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## Wick Rotation as Sign Flip -/

/-- The Wick rotation on SPB is a sign flip in the denominator.
    spbCirc(x, -y) gives a "mixed" formula. -/

end
