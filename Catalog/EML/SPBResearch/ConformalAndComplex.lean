import Mathlib

/-! # CatalogBuild.EML.SPBResearch.ConformalAndComplex

Auto-generated from theorem catalog database.
Domain: EML/SPBResearch
Declarations: 9
-/

noncomputable section

/-- The norm-squared identity for numerator and denominator -/
theorem cayley_normSq_eq (x : ℝ) :
    Complex.normSq (1 + ↑x * I) = Complex.normSq (1 - ↑x * I) := by
  simp [Complex.normSq_apply]

/-- Re(C(x)) = (1 - x²)/(1 + x²) -/
theorem cayley_re (x : ℝ) : (cayley x).re = (1 - x ^ 2) / (1 + x ^ 2) := by
  unfold cayley; simp [Complex.div_re, Complex.normSq_apply]; ring

/-- Im(C(x)) = 2x/(1 + x²) -/
theorem cayley_im (x : ℝ) : (cayley x).im = 2 * x / (1 + x ^ 2) := by
  unfold cayley; simp [Complex.div_im, Complex.normSq_apply]; ring

/-- The Gaussian norm of 1 + ix is 1 + x² -/
theorem gaussian_norm_one_plus_ix (x : ℝ) :
    Complex.normSq (1 + ↑x * I) = 1 + x ^ 2 := by
  simp [Complex.normSq_apply]; ring

/-- The factorization (1+ix)(1+iy) = (1-xy) + i(x+y) -/
theorem gaussian_spb_factorization (x y : ℝ) :
    (1 + ↑x * I) * (1 + ↑y * I) = ↑(1 - x * y) + ↑(x + y) * I := by
  push_cast; apply Complex.ext <;> simp <;> ring

/-- Also: |(1-xy) + i(x+y)|² = (1+x²)(1+y²) -/
theorem gaussian_product_norm_alt (x y : ℝ) :
    Complex.normSq (↑(1 - x * y) + ↑(x + y) * I) = (1 + x ^ 2) * (1 + y ^ 2) := by
  simp [Complex.normSq_apply]; ring

/-- C(0) = 1 for the complex Cayley -/
def cayleyC (z : ℂ) : ℂ := (1 + I * z) / (1 - I * z)

/-- [Section: # SPB and Complex Analysis] -/
theorem cayleyC_zero : cayleyC 0 = 1 := by simp [cayleyC]

/-- The conformal factor is positive -/
theorem cayley_conformal_factor (x : ℝ) : 2 / (1 + x ^ 2) > 0 := by positivity

end