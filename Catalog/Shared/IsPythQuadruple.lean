/-! # CatalogBuild.Shared.IsPythQuadruple

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

import Mathlib

/-- A Pythagorean quadruple (a, b, c, d) satisfies a² + b² + c² = d² -/
def IsPythQuadruple (a b c d : ℤ) : Prop :=
  a^2 + b^2 + c^2 = d^2


