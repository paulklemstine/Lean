/-! # CatalogBuild.Algebra.Foundations.BrahmaguptaFibonacci

Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 1
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.Foundations.BrahmaguptaFibonacci
Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 1] -/
theorem gaussian_product_preserves_sum_of_squares (a b c d : ℤ)
    (h1 : ∃ x y : ℤ, a^2 + b^2 = x^2 + y^2)
    (h2 : ∃ x y : ℤ, c^2 + d^2 = x^2 + y^2) :
    ∃ x y : ℤ, (a^2 + b^2) * (c^2 + d^2) = x^2 + y^2 := by
  exact ⟨ a * c + b * d, a * d - b * c, by ring ⟩


