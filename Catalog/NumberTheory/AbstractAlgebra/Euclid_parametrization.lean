import Mathlib

/-- A Pythagorean triple over the integers (supplied here: the catalog module that originally
provided it is not part of this repository). -/
def IsPythTriple' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-! # CatalogBuild.Shared.Euclid_parametrization

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

/-- [Section: # CatalogBuild.Shared.Euclid_parametrization
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 1] -/
theorem euclid_parametrization (m n : ℤ) :
    IsPythTriple' (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  unfold IsPythTriple'; ring