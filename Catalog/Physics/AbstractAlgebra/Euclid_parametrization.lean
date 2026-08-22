-- Repaired copy: this module was a stale, non-compiling duplicate of `Shared.AbstractAlgebra.Euclid_parametrization`.
-- Its content is synchronised with that (compiling) module.
import Mathlib

/-! # CatalogBuild.Shared.Euclid_parametrization

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

/-- A Pythagorean triple (integer form). -/
def IsPythTriple' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- [Section: # CatalogBuild.Shared.Euclid_parametrization
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 1] -/
theorem euclid_parametrization (m n : ℤ) :
    IsPythTriple' (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  unfold IsPythTriple'; ring