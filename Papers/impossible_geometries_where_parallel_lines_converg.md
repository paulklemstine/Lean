# Computational evidence: split-metric curvature

The investigated metric is

\[
ds^2=\frac{dx^2}{\cosh^2 y}+\cosh^2x\,dy^2.
\]

The orthogonal-metric curvature calculation gives

\[
K_G(x,y)=-\cosh^2 y-\operatorname{sech}^2x
          +2\operatorname{sech}^2x\operatorname{sech}^2y.
\]

For comparison, the conjectured phase field is
\(K_P(x,y)=\operatorname{sech}^2x-\operatorname{sech}^2y\).

## Small-case calculations

| `(x,y)` | conjectured `K_P` | actual `K_G` |
|---:|---:|---:|
| `(0,0)` | `0.000000000` | `0.000000000` |
| `(1,0)` | `-0.580025658` | `-0.580025658` |
| `(0,1)` | `0.580025658` | `-2.541149162` |
| `(1,1)` | `0.000000000` | `-2.448315292` |
| `(2,0.5)` | `-0.715796908` | `-1.231064780` |
| `(0.5,2)` | `0.715796908` | `-14.829437789` |
| `(-1,1)` | `0.000000000` | `-2.448315292` |

These samples immediately refute both the proposed curvature formula and the
claim that the diagonals are flat away from the origin.

## Counterexample hunt

A representative counterexample to the conjectured identity is `(0,1)`:
`K_P(0,1) > 0`, while `K_G(0,1) < 0`.  The diagonal point `(1,1)` is a
counterexample to the proposed phase boundary: the phase field vanishes there,
but the actual curvature is strictly negative.

The numerical search suggested the stronger corrected theorem formalized in
`Catalog/Novelty/SplitGeometryCurvature.lean`: actual Gaussian curvature is
nonpositive globally, equals zero exactly at `(0,0)`, and is strictly negative
elsewhere.

## OEIS search

No integer sequence naturally arises from this continuous curvature problem, so
an OEIS search is not applicable.

## Plot/table interpretation

The table indicates a single flat point rather than diagonal phase boundaries.
The formal result proves this globally, so a plot would add visualization but no
additional evidentiary value.
