/-
# Bridge: Gaussian binomials and the catalog's Grassmann line counts

`Shared/FoundationalLineCounts/GrassmannJq2LineCounts.lean` records the counting
formulas for the Grassmann scheme `J_q(4,2)` — the lines of `PG(3,q)` — as plain
polynomial definitions, *asserting* in its documentation that

* `numLinesThroughPoint q = q^2 + q + 1` is `⟦3 ; 1⟧_q`, and
* `numLines q = (q^2+1)(q^2+q+1)` is the Gaussian binomial `⟦4 ; 2⟧_q`.

Here those assertions become theorems about the recursively defined `qBinom` of
`Applications.QVandermondeQBinomial`, and the line count is then *rederived* from
the q-Vandermonde convolution, i.e. from the decomposition of a 4-dimensional
space as `2 + 2`.
-/

import Applications.QBinomialGaussProduct
import Shared.FoundationalLineCounts.GrassmannJq2LineCounts

namespace Catalog.Applications.QBinomial

open Finset

/-- The number of lines of `PG(3,q)` through a point is the Gaussian binomial
`⟦3,1⟧_q`. -/
theorem qBinom_three_one_eq_numLinesThroughPoint (q : ℕ) :
    qBinom q 3 1 = Shared.GrassmannJq2.numLinesThroughPoint q := by
  rw [qBinom_one, Shared.GrassmannJq2.numLinesThroughPoint]
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero]
  ring

/-- The total number of lines of `PG(3,q)` is the Gaussian binomial `⟦4,2⟧_q`. -/
theorem qBinom_four_two_eq_numLines (q : ℕ) :
    qBinom q 4 2 = Shared.GrassmannJq2.numLines q := by
  have h42 : qBinom q 4 2 = qBinom q 3 1 + q ^ 2 * qBinom q 3 2 := qBinom_succ_succ q 3 1
  have h32 : qBinom q 3 2 = qBinom q 2 1 + q ^ 2 * qBinom q 2 2 := qBinom_succ_succ q 2 1
  have h31 : qBinom q 3 1 = 1 + q + q ^ 2 := by
    rw [qBinom_one, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
      Finset.sum_range_zero]
    ring
  have h21 : qBinom q 2 1 = 1 + q := by
    rw [qBinom_one, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero]
    ring
  rw [h42, h32, h31, h21, qBinom_self, Shared.GrassmannJq2.numLines]
  ring

/-- Casting Gaussian binomials from `ℕ` to `ℤ`, an instance of the ring-hom
transfer principle `map_qBinom`. -/
lemma qBinom_natCast (q n k : ℕ) : ((qBinom q n k : ℕ) : ℤ) = qBinom (q : ℤ) n k :=
  map_qBinom (Nat.castRingHom ℤ) q n k

/-- **The catalog line count, rederived from the q-Vandermonde convolution.**
Splitting `4 = 2 + 2` expresses the number of lines of `PG(3,q)` as
`∑_{j≤2} q^{(2-j)^2} ⟦2,j⟧_q ⟦2,2-j⟧_q`. -/
theorem numLines_eq_qVandermonde (q : ℕ) :
    (Shared.GrassmannJq2.numLines q : ℤ) =
      ∑ j ∈ range 3, (q : ℤ) ^ ((2 - j) * (2 - j)) * qBinom (q : ℤ) 2 j * qBinom (q : ℤ) 2 (2 - j) := by
  rw [← qBinom_vandermonde (q : ℤ) 2 2 2, ← qBinom_natCast, qBinom_four_two_eq_numLines]

/-- The same count written out: `(q^2+1)(q^2+q+1) = q^4 + q(1+q)^2 + 1`, the three
q-Vandermonde terms corresponding to the possible dimensions of the intersection
of a line with a fixed plane. -/
theorem numLines_vandermonde_expansion (q : ℕ) :
    (Shared.GrassmannJq2.numLines q : ℤ) = (q : ℤ) ^ 4 + (q : ℤ) * (1 + (q : ℤ)) ^ 2 + 1 := by
  rw [numLines_eq_qVandermonde]
  have h21 : qBinom (q : ℤ) 2 1 = 1 + (q : ℤ) := by
    rw [qBinom_one, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero]
    ring
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [h21]
  ring

end Catalog.Applications.QBinomial