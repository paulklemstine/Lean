import Tropical.FundamentalTheorem.Basic
import Tropical.FundamentalTheorem.TropicalPolynomial
import Tropical.FundamentalTheorem.Kapranov
import Tropical.FundamentalTheorem.Bezout

/-!
# Tropical geometry: the connection between varieties and their tropicalizations

This is the entry point gathering the formalization of the link between classical algebraic
varieties over a non-Archimedean valued field `K` and their tropicalizations.

* `Tropical.FundamentalTheorem.Basic` — the non-Archimedean valued field `K`
  (`AddValuation K (WithTop ℝ)`), tropicalization of a polynomial, the corner locus, and the
  compatibility of tropicalization with the valuation (`tropMonomial_eq_valuation_term`).
* `Tropical.FundamentalTheorem.TropicalPolynomial` — tropical polynomials as elements of the
  tropical (min-plus) semiring `Tropical (WithTop ℝ)` and their piecewise-linear structure.
* `Tropical.FundamentalTheorem.Kapranov` — the Fundamental Theorem of Tropical Geometry for a
  hypersurface: the forward inclusion `Trop(V(f)) ⊆ cornerLocus(trop f)` is proved
  unconditionally (`TropV_subset_tropicalHypersurface`); the full equality
  (`kapranov_fundamental_theorem`) follows from the explicit lifting hypothesis.
* `Tropical.FundamentalTheorem.Bezout` — tropical intersection multiplicity and Tropical
  Bézout in one variable: a degree-`d` tropical polynomial has exactly `d` roots counted with
  multiplicity (`tropical_bezout`, `tropical_bezout_sum_mult`), local multiplicities match
  slope drops (`slope_drop_eq_mult`), and classical roots' valuations are the tropical roots
  (`tropPolyValue_linearFactor`).
-/