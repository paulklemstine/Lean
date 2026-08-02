# Computational evidence: signed hypercube adjacency

## Small cases

For the recursive signed operator

\[
A_{n+1}=\begin{pmatrix}A_n&I\\I&-A_n\end{pmatrix},\qquad A_0=(0),
\]

direct block multiplication gives the following table.

| dimension `n` | matrix size | observed square | possible real eigenvalues |
|---:|---:|---:|---:|
| 0 | 1 | `0` | `0` |
| 1 | 2 | `I` | `±1` |
| 2 | 4 | `2 I` | `±√2` |
| 3 | 8 | `3 I` | `±√3` |
| 4 | 16 | `4 I` | `±2` |

The Lean theorem `signedAdj_sq` proves the pattern for every `n`, rather than
relying on these finite calculations. The theorem
`eigenvalue_sq_eq_dimension` proves the corresponding eigenvalue statement.

## OEIS search

The scalar sequence in the squares is simply `0, 1, 2, 3, 4, ...`; no OEIS
identification is mathematically informative here. Matrix sizes are the
standard powers of two `1, 2, 4, 8, 16, ...`.

## Counterexample hunt

The first dimension where the all-positive (unsigned) operator can have a
non-cancelling two-step walk to a distinct vertex is `n = 2`. For the delta
function at vertex `(true,true)`, evaluating the square at `(false,false)`
gives `2`, whereas `2 I` gives `0`. Thus the conjecture that *every* signing
squares to dimension times identity already fails on the four-vertex square.
The Lean theorem `not_every_signing_has_scalar_square` certifies this
counterexample.

## Conclusion

The experiments support the canonical alternating signing and reject the
arbitrary-signing extension. They also indicate that the spectral magnitude
`√n` is exact, not merely a lower bound.
