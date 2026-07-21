# Computational Evidence

## Small cases

For a binary alphabet, the cumulative ambient counts are

| cutoff `n` | `S 2 n` |
|---:|---:|
| 0 | 1 |
| 1 | 3 |
| 2 | 7 |
| 3 | 15 |
| 4 | 31 |
| 5 | 63 |
| 6 | 127 |

Thus a derivable family bounded by seven elements has upper density `7/(2^(n+1)-1)`, which tends to zero, while ambient entropy density tends to `log 2`.

For geometric length weights with `k = 2`, the first values are `1/2, 1/4, 1/8, 1/16, 1/32`. Their successive ratio is constantly `1/2 = exp(-log 2)`.

## OEIS signal

The binary cumulative counts `1, 3, 7, 15, 31, 63, 127, ...` are the Mersenne numbers, OEIS A000225.

## Counterexample hunt

The proposed raw-length power law fails in the homogeneous geometric model: a power law `n^(-α)` has successive ratio `(n/(n+1))^α`, which varies with `n` and tends to one, whereas the geometric model has the constant ratio `1/k < 1`.

Monotonicity is also necessary for an exact one-crossing theorem. The nonnegative sequence `r(n) = 1/(n+1)` for even `n` and `2/(n+1)` for odd `n` tends to zero but can cross a prescribed level more than once near the transition region.

## Interpretation

The calculations support entropy–density separation and reject the direct inference from exponential proof-space growth to a power law in raw theorem length. No external arXiv, LMFDB, or additional sequence signal was supplied for this cycle.
