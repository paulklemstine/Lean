# Computational evidence: split-metric curvature

The sampled expression is
\[
K(x,y)=-\cosh^2y+\frac{1-\sinh^2y}{\cosh^2x\cosh^2y}.
\]

## Small-case table

| x | y | K(x,y) |
|---:|---:|---:|
| 0 | 0 | 0.000000000 |
| 0.5 | 0 | -0.213552267 |
| 0 | 0.5 | -0.698644851 |
| 0.5 | 0.5 | -0.820987977 |
| 1 | 0 | -0.580025658 |
| 0 | 1 | -2.541149162 |
| 1 | 1 | -2.448315292 |
| 2 | 0.5 | -1.231064780 |

## Counterexample hunt

Sampling the origin, both coordinate axes, the diagonal, and an anisotropic point
found no positive value. The only sampled zero was the origin. Symbolic expansion
then reduced the intrinsic-frame question to the identity
\[
\det\bigl(g(u_i,u_j)\bigr)=E G\,(u_1v_2-u_2v_1)^2,
\]
which predicts that the sectional quotient is independent of every nondegenerate
choice of tangent frame.

## Sequence-database search

No integer sequence arises from this continuous curvature problem, so an OEIS or
LMFDB search is not applicable.

## Plot-level conclusion

The table supports a single isolated zero rather than a sign-changing phase
boundary. The completed algebraic results establish this globally, beyond the
sampled points.
