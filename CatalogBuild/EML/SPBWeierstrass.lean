/-! # CatalogBuild.EML.SPBWeierstrass

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6
-/

import Mathlib

noncomputable section

/-- The SPB operator -/
def spbW (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic SPB (Einstein velocity addition) -/

def spbHW (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## Weierstrass Substitution -/

/-- sin(θ) = 2·tan(θ/2) / (1 + tan²(θ/2)) = spbH(t, t) where t = tan(θ/2). -/

theorem pythagorean_from_rational_point (p q : ℤ) :
    (2 * p * q) ^ 2 + (q ^ 2 - p ^ 2) ^ 2 = (q ^ 2 + p ^ 2) ^ 2 := by ring

/-! ## Brahmagupta-Fibonacci Identity -/

/-- The Brahmagupta-Fibonacci identity:
    (a² + b²)(c² + d²) = (ac - bd)² + (ad + bc)²
    This is the norm-multiplicativity of Gaussian integers. -/

theorem spb_norm_composition (a b : ℝ) (h : 1 - a * b ≠ 0) :
    (1 + (spbW a b) ^ 2) * (1 - a * b) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) := by
  unfold spbW; field_simp; ring

/-! ## SPB and Gaussian Integer Norms -/

/-- The "augmented norm" identity:
    (1 + a²)(1 + b²) = (1-ab)² + (a+b)²
    Shows SPB numerator and denominator are components of
    Gaussian integer multiplication: (1+ai)(1+bi) = (1-ab) + (a+b)i. -/

theorem spb_gaussian_norm_identity (a b : ℤ) :
    (1 + a ^ 2) * (1 + b ^ 2) = (1 - a * b) ^ 2 + (a + b) ^ 2 := by ring

/-- Real version. -/

theorem spb_gaussian_norm_identity_real (a b : ℝ) :
    (1 + a ^ 2) * (1 + b ^ 2) = (1 - a * b) ^ 2 + (a + b) ^ 2 := by ring


end
