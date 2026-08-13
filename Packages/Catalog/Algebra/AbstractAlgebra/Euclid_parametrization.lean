import Mathlib

/-! # CatalogBuild.Shared.Euclid_parametrization

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1

Repaired: the predicate `IsPythTriple'` used by the statement was never defined
in the catalog; it is supplied here with its intended meaning.
-/

noncomputable section

/-- `(a, b, c)` is a Pythagorean triple. -/
def IsPythTriple' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Euclid's parametrisation of Pythagorean triples. -/
theorem euclid_parametrization (m n : ℤ) :
    IsPythTriple' (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  unfold IsPythTriple'; ring

end