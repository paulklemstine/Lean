import Mathlib

/-! # CatalogBuild.Speculative.OpenProblems.SPBHyperbolicBridge

Auto-generated from theorem catalog database.
Domain: Speculative/OpenProblems
Declarations: 4
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.OpenProblems.SPBHyperbolicBridge
Auto-generated from theorem catalog database.
Domain: Speculative/OpenProblems
Declarations: 4] -/
theorem spbHyp_assoc (x y z : ℝ)
    (h1 : 1 + x * y ≠ 0) (h2 : 1 + y * z ≠ 0)
    (h3 : 1 + spbHyp x y * z ≠ 0) (h4 : 1 + x * spbHyp y z ≠ 0) :
    spbHyp (spbHyp x y) z = spbHyp x (spbHyp y z) := by
  simp only [spbHyp]; field_simp; ring

/-- 1 - spbH(u,v)² has a nice factored form. -/
theorem spbHyp_one_minus_sq (u v : ℝ) (h : 1 + u * v ≠ 0) :
    1 - spbHyp u v ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) / (1 + u * v) ^ 2 := by
  unfold spbHyp; field_simp; ring

/-- [Section: # CatalogBuild.Speculative.OpenProblems.SPBHyperbolicBridge
Auto-generated from theorem catalog database.
Domain: Speculative/OpenProblems
Declarations: 4] -/
theorem spbHyp_velocity_bound (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbHyp u v| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbHyp ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ], by rw [ spbHyp ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ] ⟩

/-- The hyperbolic norm identity. -/
theorem spbHyp_norm_identity (x y : ℝ) (h : 1 + x * y ≠ 0) :
    (1 + x * y) ^ 2 * (1 - spbHyp x y ^ 2) = (1 - x ^ 2) * (1 - y ^ 2) := by
  unfold spbHyp; field_simp; ring

end
