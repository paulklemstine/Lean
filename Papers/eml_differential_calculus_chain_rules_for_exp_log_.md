# Computational Evidence

## Small-case calculations

For \(f(x)=e^{x^2}\log(x+1)\), direct symbolic differentiation gives

\[
f'(x)=e^{x^2}\left(2x\log(x+1)+\frac1{x+1}\right),
\]

\[
f''(x)=e^{x^2}\left((4x^2+2)\log(x+1)+\frac{4x}{x+1}-\frac1{(x+1)^2}\right),
\]

and

\[
f'''(x)=e^{x^2}\left((8x^3+12x)\log(x+1)
 +\frac{12x^2+6}{x+1}-\frac{6x}{(x+1)^2}+\frac2{(x+1)^3}\right).
\]

These formulas are proved pointwise on the differentiability domain in
`Catalog/Applications/EML/ExpLogChainRules.lean`.

## Counterexample hunt

The proposed identity
\[
( e^h\log g)'=e^h\log g\,(h'+g'/g)
\]
fails already for \(h(x)=0\), \(g(x)=e^x\), and \(x=2\). The left side is the
derivative of \(x\), hence `1`, while the proposed right side is `2`. This counterexample
is proved in `proposed_factorization_counterexample`.

The corrected factor is
\[
e^h\log g\left(h'+\frac{g'}{g\log g}\right),
\]
where `g` and `log g` are nonzero.

## Sequence search

No unambiguous integer sequence was extracted from only three derivatives, so no OEIS
identifier is asserted. The logarithmic coefficients begin
\(1,2x,4x^2+2,8x^3+12x\), suggesting the standard derivative-polynomial recurrence for
\(e^{x^2}\), but an external sequence identification is unnecessary for the proved claims.

## Structural table

| derivative order | logarithmic coefficient | maximal pole order at `x=-1` |
|---:|---|---:|
| 0 | `1` | 0 |
| 1 | `2x` | 1 |
| 2 | `4x²+2` | 2 |
| 3 | `8x³+12x` | 3 |

The table motivates the pole-order normal-form conjecture in `FUTURE_DIRECTIONS.md`.
