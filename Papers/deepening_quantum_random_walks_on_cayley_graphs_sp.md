# Computational Evidence

## Small-case calculations

A finite Fourier orbit provides a transparent periodic test family. For period `N`, the return amplitude

\[
a_n=\frac1N\sum_{j=0}^{N-1}e^{2\pi ijn/N}
\]

has Born probabilities `1,0,…,0` through one period. The calculations gave:

| period `N` | one-period return probabilities | one-period mean |
|---:|:---|---:|
| 2 | 1, 0 | 1/2 |
| 3 | 1, 0, 0 | 1/3 |
| 4 | 1, 0, 0, 0 | 1/4 |
| 5 | 1, 0, 0, 0, 0 | 1/5 |
| 6 | 1, 0, 0, 0, 0, 0 | 1/6 |
| 8 | 1, 0, 0, 0, 0, 0, 0, 0 | 1/8 |

Repeating any row `q` times leaves its empirical mean unchanged, suggesting the exact complete-block identity proved in the accompanying development.

## Counterexample hunt

The same examples refute instantaneous convergence: the return probability repeatedly jumps from `0` to `1`. They do not refute time-averaged mixing; on a cyclic orbit the average return probability is exactly `1/N`. Tests with arbitrary short real-valued periodic lists likewise found that averaging over `q` complete copies always reproduced the mean of one copy.

## Sequence-database search

No sequence-database identification is relevant here: the central observation is an exact block-sum identity for arbitrary periodic sequences, not a conjectured integer sequence.

## Numerical boundary

Incomplete final periods generally change the finite empirical mean. Consequently, the exact theorem is deliberately stated for complete-period windows; extending it to all window lengths requires a quantitative remainder estimate rather than an exact equality.
