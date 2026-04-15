/-! # CatalogBuild.Shared.IsPythQuadruple

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 1
-/

import Mathlib

def IsPythQuadruple (a b c d : ℤ) : Prop :=
  a^2 + b^2 + c^2 = d^2

/-
The parametric construction of a Pythagorean quadruple from four parameters.
    Given (m, n, p, q), define:
      a = m² + n² - p² - q²
      b = 2(mq + np)
      c = 2(nq - mp)
      d = m² + n² + p² + q²
    This always yields a valid quadruple.
-/
