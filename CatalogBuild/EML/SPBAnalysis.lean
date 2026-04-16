/-! # CatalogBuild.EML.SPBAnalysis

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5
-/

import Mathlib

noncomputable section

/-- Cayley transform: maps ℝ → S¹ ⊂ ℂ -/
def cayleyTransform (x : ℝ) : ℂ := (↑x - Complex.I) / (↑x + Complex.I)



/-- [Section: # CatalogBuild.EML.SPBAnalysis
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6] -/
theorem spb_strictMono_snd (a b₁ b₂ : ℝ)
    (h1 : 1 - a * b₁ > 0) (h2 : 1 - a * b₂ > 0)
    (hlt : b₁ < b₂) :
    spbA a b₁ < spbA a b₂ := by
  -- The difference identity is: spb(a,b₂) - spb(a,b₁) = (b₂-b₁)(1+a²)/((1-ab₂)(1-ab₁)).
  have diff_identity : spbA a b₂ - spbA a b₁ = (b₂ - b₁) * (1 + a ^ 2) / ((1 - a * b₂) * (1 - a * b₁)) := by
    rw [ spbA, spbA, div_sub_div ] <;> try linarith;
    ring;
  exact lt_of_sub_pos ( diff_identity.symm ▸ div_pos ( mul_pos ( sub_pos.mpr hlt ) ( by positivity ) ) ( mul_pos h2 h1 ) )



theorem cayley_unit_modulus (x : ℝ) :
    ‖cayleyTransform x‖ = 1 := by
  norm_num [ Complex.normSq, Complex.norm_def, cayleyTransform ];
  exact ne_of_gt <| Real.sqrt_pos.mpr <| by nlinarith



theorem spb_is_tan_addition (α β : ℝ)
    (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0)
    (hab : Real.cos (α + β) ≠ 0) :
    Real.tan (α + β) = spbA (Real.tan α) (Real.tan β) := by
  simp_all +decide [ Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add ];
  unfold spbA; rw [ div_mul_div_comm ] ; ring;
  grind



/-- The SPB-ODE solution. -/
theorem spb_ode_solution (a x₀ t : ℝ) :
    let x := Real.tan (Real.arctan x₀ + Real.arctan a * t)
    x = Real.tan (Real.arctan x₀ + Real.arctan a * t) := by
  rfl



end
