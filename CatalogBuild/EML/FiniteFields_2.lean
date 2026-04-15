/-! # CatalogBuild.EML.FiniteFields_2

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 8
-/

import Mathlib

noncomputable section

/-- SPB over an arbitrary field. -/
def spbField (x y : F) : F := (x + y) / (1 - x * y)


/-- SPB is commutative over any field. -/
theorem spbField_comm (x y : F) : spbField x y = spbField y x := by
  simp [spbField, add_comm, mul_comm]


/-- 0 is the identity. -/
theorem spbField_zero (x : F) : spbField x 0 = x := by
  simp [spbField]


/-- -x is the inverse. -/
theorem spbField_neg (x : F) : spbField x (-x) = 0 := by
  simp [spbField]


/-- [Section: ## SPB over a general field] -/
theorem spbField_assoc (x y z : F)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spbField x y * z ≠ 0) (h4 : 1 - x * spbField y z ≠ 0) :
    spbField (spbField x y) z = spbField x (spbField y z) := by
  unfold spbField at *;
  grind


/-- [Section: ## The SPB Group Structure] -/
theorem spbField_denom_product (x y z : F) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spbField x y * z) = (1 - y * z) * (1 - x * spbField y z) := by
  unfold spbField;
  grind


/-- [Section: ## SPB Fixed Points] -/
theorem spbField_fixed_point (x a : F) (ha : a ≠ 0) (hd : 1 - x * a ≠ 0) :
    spbField x a = x ↔ x ^ 2 = -1 := by
  -- By definition of spbField, we have spbField x a = (x + a) / (1 - x * a).
  rw [spbField];
  grind


/-- spb(x, x) = 2x/(1-x²), the doubling map in the tangent group. -/
theorem spbField_self (x : F) : spbField x x = 2 * x / (1 - x * x) := by
  unfold spbField; ring

-- The doubling map iterated gives the "power map" in the circle group.
-- The SPB group over 𝔽_p has interesting structure:
-- When p ≡ 1 (mod 4), -1 is a QR, so SPB has fixed points (the square roots of -1)
-- When p ≡ 3 (mod 4), -1 is not a QR, so SPB acts freely
-- The group (𝔽_p, spb) with appropriate domain is isomorphic to a subgroup of ℙ¹(𝔽_p)


end
