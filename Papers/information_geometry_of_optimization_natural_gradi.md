# Computational Evidence

## Small-case calculations

For the matched quadratic energy
\[
L(x)=\tfrac12\sum_i w_i x_i^2,
\]
a natural-gradient step is `x⁺=(1-η)x`. With `w=(1,100)`, `x=(2,3)`, and `η=1/4`, the initial energy is `452` and the next energy is `254.25 = (3/4)^2·452`. The contraction factor does not involve the weight ratio `100`.

For harmonic steps `η_k=1/(k+2)`, the first parameter factors are:

| k | x_k / x_0 | L(x_k) / L(x_0) |
|---:|---:|---:|
| 0 | 1 | 1 |
| 1 | 1/2 | 1/4 |
| 2 | 1/3 | 1/9 |
| 3 | 1/4 | 1/16 |
| 4 | 1/5 | 1/25 |

These values are instances of the exact laws established in `NaturalGradient.lean`.

## OEIS search results

The objective ratios have denominators `1, 4, 9, 16, 25, …`, the square numbers (OEIS A000290). No sequence identification is needed in the argument; the closed form follows directly from the iteration.

## Counterexample hunt

The universal assertion that a natural-gradient Euler update is an exact geodesic step fails already in one dimension. For metric `g(x)=4x²`, the flattening coordinate is `Φ(x)=x²` on the positive half-line. The geodesic midpoint from `2` to `1` therefore has squared coordinate `5/2`. An Euler natural-gradient step with inverse metric `1/16`, loss derivative `8`, and unit step ends at `3/2`, whose square is `9/4`, not `5/2`.

A second boundary test concerns the proposed exponential rate under harmonic steps. Even in the matched strongly convex quadratic, `η_k=1/(k+2)` gives exactly `L(x_k)=L(x_0)/(k+1)²`, which is polynomial rather than exponential.

## Numerical comparison target

For regularized logistic regression, the appropriate table should report both the feature covariance condition number and the generalized eigenvalue spread of the loss Hessian relative to the empirical Fisher. The exact model predicts that natural-gradient performance tracks the latter mismatch, whereas ordinary gradient descent tracks Euclidean curvature conditioning.
