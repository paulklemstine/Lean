import Mathlib

/-! # CatalogBuild.EML.WickRotation_2

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 8
-/

noncomputable section

/-- spbHyp is definitionally (x+y)/(1+xy). -/
theorem spbHyp_def (x y : ℝ) :
    spbHyp x y = (x + y) / (1 + x * y) := rfl

/-- [Section: # CatalogBuild.EML.WickRotation_2
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 8] -/
theorem spbCirc_identity (x : ℝ) : spbCirc x 0 = x := by simp [spbCirc]

/-- [Section: # CatalogBuild.EML.WickRotation_2
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 8] -/
theorem spbHyp_identity (x : ℝ) : spbHyp x 0 = x := by simp [spbHyp]

theorem spbCirc_inverse (x : ℝ) : spbCirc x (-x) = 0 := by simp [spbCirc]

theorem spbHyp_inverse (x : ℝ) : spbHyp x (-x) = 0 := by simp [spbHyp]

/-- The rapidity-velocity relationship: v = tanh(φ). -/
def rapidityToVelocity (φ : ℝ) : ℝ := tanh φ

/-- Rapidity addition: tanh(a+b) = spbHyp(tanh a, tanh b).
Stated as: the result equals (tanh a + tanh b)/(1 + tanh a · tanh b). -/
theorem rapidity_addition (a b : ℝ) :
    tanh (a + b) = spbHyp (tanh a) (tanh b) := by
  rw [spbHyp]
  rw [Real.tanh_eq_sinh_div_cosh, Real.sinh_add, Real.cosh_add]
  rw [Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh]
  field_simp

/-- γ(v₁ ⊕ v₂) expressed via spbHyp. -/
theorem lorentz_factor_composition (v₁ v₂ : ℝ) :
    spbHyp v₁ v₂ = (v₁ + v₂) / (1 + v₁ * v₂) := rfl

end
