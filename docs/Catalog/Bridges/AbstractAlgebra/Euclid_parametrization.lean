import Mathlib

/-! # CatalogBuild.Shared.Euclid_parametrization

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

/-- A Pythagorean triple over the integers.  (The auto-generated file used this
predicate without carrying its definition along; it is restated here verbatim from
`Shared/AbstractAlgebra/Euclid_parametrization.lean`.) -/
def IsPythTriple' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- [Section: # CatalogBuild.Shared.Euclid_parametrization
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 1] -/
theorem euclid_parametrization (m n : ℤ) :
    IsPythTriple' (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  unfold IsPythTriple'; ring