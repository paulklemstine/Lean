import Mathlib
import Shared.CatalogbuildSharedIspythtriple.IsPythTriple

/-! # CatalogBuild.Shared.Euclid_parametrization

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1

The fragment referred to a predicate `IsPythTriple'` that is not present in the
repository.  The catalog does contain `IsPythTriple`, with the same meaning
`a² + b² = c²`, so the statement is expressed with it; `IsPythTriple'` is kept
as a local abbreviation so that the original statement and proof are unchanged.
-/

/-- The Pythagorean-triple predicate used by this fragment. -/
abbrev IsPythTriple' (a b c : ℤ) : Prop := IsPythTriple a b c

/-- [Section: # CatalogBuild.Shared.Euclid_parametrization
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 1] -/
theorem euclid_parametrization (m n : ℤ) :
    IsPythTriple' (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  unfold IsPythTriple' IsPythTriple; ring