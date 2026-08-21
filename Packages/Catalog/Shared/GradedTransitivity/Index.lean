import Shared.GradedTransitivity.FiniteDifference
import Shared.GradedTransitivity.PolynomialGrowth
import Shared.GradedTransitivity.BinomialGF
import Shared.GradedTransitivity.GSet
import Shared.GradedTransitivity.Structure
import Shared.GradedTransitivity.Newton
import Shared.GradedTransitivity.Sharpness
import Shared.GradedTransitivity.Profile
import Shared.GradedTransitivity.PolyClassification
import Shared.GradedTransitivity.Burnside

/-!
# Rational Hilbert series of graded `G`-sets — index

Entry point for the cluster.  The result the cluster is organised around is

> for a graded `G`-set `Y = ⨆_n Y_n` whose grades are eventually
> `r`-transitive, the generating function `∑_n t_r(Y_n) qⁿ` is a rational
> function of `q` with denominator dividing `(1-q)^{r+1}`,

where `t_r(Y)` is the number of `G`-orbits on injective `r`-tuples of `Y`
(`GradedTransitivity.torbits`, built on Mathlib's
`MulAction.IsMultiplyPretransitive`).

## Layout

* `FiniteDifference` — the analytic engine: `(1-q)^k` clears a generating
  function iff the `k`-th forward difference vanishes eventually
  (`sdiff_iter_eventuallyZero_iff`), plus the honest quotient formulation.
* `PolynomialGrowth` — eventually polynomial growth of degree `≤ r` gives
  denominator `(1-q)^{r+1}` (`exists_poly_of_eventually_polynomial`).
* `BinomialGF` — the exact evaluation `∑ C(n,r) qⁿ = q^r/(1-q)^{r+1}` and the
  optimality of the exponent.
* `GSet` — the `G`-set layer: `torbits`, `IsRTransitive`, the main theorem
  `gen_hilbertSeq_rational_pow`, and the symmetric-group model.
* `Structure` — the subring `ratOneSubring` of series with poles only at
  `q=1`, and the residue theorem `hilbertSeq_residue_one`.
* `Newton` — Newton's forward difference formula and the resulting three-way
  classification `rationality_tfae_newton`.
* `Sharpness` — the trivial-group graded set, showing the exponent `r+1` is
  exactly right without transitivity.
* `Profile` — downward closure of `r`-transitivity and rationality of the
  whole profile `(t_s)_{s ≤ r}`.
* `PolyClassification` — the closing equivalence: denominator `(1-q)^{r+1}` iff
  the coefficient sequence is eventually a polynomial of degree `≤ r`.
* `Burnside` — a second, transitivity-free route to rationality through
  Burnside's orbit-counting lemma and polynomial fixed-point growth.
-/