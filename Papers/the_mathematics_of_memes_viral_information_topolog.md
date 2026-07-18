# Computational evidence

## Small-case calculations

For a two-term cellular cochain complex over a field,

\[
C^0 \xrightarrow{\delta} C^1,
\qquad b_0=\dim\ker\delta,
\qquad b_1=\dim(C^1/\operatorname{range}\delta).
\]

Writing `n = dim C⁰`, `m = dim C¹`, and `r = rank δ`, rank-nullity gives
`b₀ = n-r` and `b₁ = m-r`. Representative cases are:

| n | m | r | b₀ | b₁ | Interpretation |
|---:|---:|---:|---:|---:|---|
| 1 | 0 | 0 | 1 | 0 | one interpretation, no edge obstruction space |
| 2 | 0 | 0 | 2 | 0 | two interpretations, no edge obstruction space |
| 2 | 1 | 0 | 2 | 1 | maximal interpretations, but an obstruction remains |
| 2 | 1 | 1 | 1 | 0 | unobstructed, but one interpretation dimension is lost |
| 3 | 2 | 1 | 2 | 1 | intermediate tradeoff |
| 3 | 2 | 2 | 1 | 0 | surjective coboundary, hence unobstructed |

The `(2,1,0)` case is certified in Lean as `twoInterpretationExample_betti`.

## OEIS search

No OEIS search is relevant: the result is a finite-dimensional identity in three
parameters, not a distinguished integer sequence.

## Counterexample hunt

The universal suggestion that maximal `H⁰` and vanishing `H¹` naturally coexist
fails whenever `C¹` is nonzero. The smallest linear counterexample has
`C⁰ = ℚ²`, `C¹ = ℚ`, and `δ = 0`, yielding `(b₀,b₁) = (2,1)`.

More generally, the formal theorem `maximal_b0_and_zero_b1_forces_no_edge_data`
proves that maximal `H⁰` together with `H¹ = 0` forces `dim C¹ = 0` in this
finite-dimensional model.

## Table rather than plots

The table is more informative than a plot at this scale: both Betti numbers are
affine functions of the same rank parameter, decreasing together as rank grows.
