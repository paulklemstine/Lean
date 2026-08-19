import Mathlib

/-! # CatalogBuild.Shared.SpbHyp_comm

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6
-/

noncomputable section

/-- The hyperbolic (relativistic) speed-addition law. -/
def spbHyp (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- Hyperbolic SPB is commutative. -/
theorem spbHyp_comm (x y : ℝ) : spbHyp x y = spbHyp y x := by
  simp [spbHyp, add_comm, mul_comm]


/-- Hyperbolic SPB inverse. -/
theorem spbHyp_neg (x : ℝ) : spbHyp x (-x) = 0 := by
  simp [spbHyp]


theorem spbHyp_tanh_add (α β : ℝ) :
    spbHyp (Real.tanh α) (Real.tanh β) = Real.tanh (α + β) := by
  unfold spbHyp;
  rw [ Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh, Real.sinh_add, Real.cosh_add ];
  field_simp


/-- The hyperbolic SPB (Einstein velocity addition). -/


theorem spbHyp_subluminal (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    |spbHyp x y| < 1 := by
  unfold spbHyp;
  rw [ abs_lt ] at *;
  exact ⟨ by rw [ lt_div_iff₀ ] <;> nlinarith, by rw [ div_lt_iff₀ ] <;> nlinarith ⟩


/-- Hyperbolic SPB identity. -/
theorem spbHyp_zero (x : ℝ) : spbHyp x 0 = x := by
  simp [spbHyp]


end