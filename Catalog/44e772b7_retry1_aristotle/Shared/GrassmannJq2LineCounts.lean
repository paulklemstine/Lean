import Mathlib

/-! # Foundational line counts for the Grassmann scheme `J_q(4,2)`

The Grassmann scheme `J_q(4,2)` has as its points the `2`-dimensional subspaces of a
`4`-dimensional vector space over `𝔽_q`, equivalently the *lines* of the projective
space `PG(3, q)`.  This file records the elementary `q`-counting formulas that underlie
the study of Cameron–Liebler line classes on `J_q(4,2)`.

* `Shared.GrassmannJq2.numLinesThroughPoint q = q^2 + q + 1` is the number of lines of
  `PG(3,q)` through a fixed point.
* `Shared.GrassmannJq2.numLines q = (q^2 + 1) * (q^2 + q + 1)` is the total number of
  lines, i.e. the Gaussian binomial coefficient `⟦4 ; 2⟧_q`.

These are kept as plain definitions over `ℕ` together with their basic positivity and
factorization lemmas, which is all that the arithmetic core of the Bruen–Drudge
construction needs.
-/

namespace Shared.GrassmannJq2

/-- Number of lines of `PG(3,q)` through a fixed point: `q^2 + q + 1`
(the number of points of the quotient plane `PG(2,q)`). -/
def numLinesThroughPoint (q : ℕ) : ℕ := q ^ 2 + q + 1

/-- Total number of lines of `PG(3,q)`, i.e. the Gaussian binomial coefficient
`⟦4 ; 2⟧_q = (q^2 + 1)(q^2 + q + 1)`. -/
def numLines (q : ℕ) : ℕ := (q ^ 2 + 1) * (q ^ 2 + q + 1)

/-- The total line count factors as `(q^2+1)` copies of the per-point count. -/
theorem numLines_eq (q : ℕ) :
    numLines q = (q ^ 2 + 1) * numLinesThroughPoint q := rfl

/-- There is at least one line through a point. -/
theorem numLinesThroughPoint_pos (q : ℕ) : 0 < numLinesThroughPoint q := by
  unfold numLinesThroughPoint; positivity

theorem numLines_pos (q : ℕ) : 0 < numLines q := by
  unfold numLines; positivity

end Shared.GrassmannJq2