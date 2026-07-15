# Computational Evidence: The Three-Halves Steering Word

## Small cases

Nearest-integer rounding of `(3/2)^n` begins as follows. The tie convention chooses the integer for which the error lies in `[-1/2,1/2)`.

| `n` | `(3/2)^n` | `m_n` | `t_n = 2m_{n+1}-3m_n` |
|---:|---:|---:|---:|
| 0 | 1 | 1 | 1 |
| 1 | 3/2 | 2 | -2 |
| 2 | 9/4 | 2 | 0 |
| 3 | 27/8 | 3 | 1 |
| 4 | 81/16 | 5 | 1 |
| 5 | 243/32 | 8 | -2 |
| 6 | 729/64 | 11 | 1 |
| 7 | 2187/128 | 17 | 1 |

These terms already show that the alphabet cannot be restricted to `{-1,0,1}`.

## OEIS and literature search

No OEIS identifier is asserted here. The directly relevant object is the steering word described in the paper named in the research mission; identifying an OEIS entry from a short prefix would be unreliable.

## Counterexample hunt

The finite calculations challenge two overly strong candidate claims:

* “Every steering correction has absolute value at most one” fails at `n=1`, where `t_1=-2`.
* “The word has no zero correction” fails at `n=2`, where `t_2=0`.

They support the guarded five-symbol theorem: every correction belongs to `{-2,-1,0,1,2}`. The table is exploratory evidence only; the general bound is established separately from the rounding-error inequalities.

## Structural checks

For the first three corrections `1,-2,0`, the recursive weighted correction is
`3(3·1 + 2·(-2)) + 4·0 = -3`. The endpoint identity gives
`2^3m_3 = 8·3 = 24` and `3^3m_0 + (-3) = 27-3 = 24`, confirming the reconstruction formula in this sample.
