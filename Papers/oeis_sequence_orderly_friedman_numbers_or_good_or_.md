# Computational evidence

## Small cases

The following calculations motivated and are checked by the Lean development:

| digits | expression preserving digit order | result |
|---|---|---:|
| 1,2,7 | `-1 + 2^7` | 127 |
| 7,3,6 | `7 + 3^6` | 736 |
| 1,2,7,1,2,7 | concatenate `(-1+2^7)` with `(-1+2^7)` | 127127 |
| three copies of 1,2,7 | concatenate three copies | 127127127 |

The repeated values satisfy `F(0)=127` and `F(n+1)=1000 F(n)+127`.

## OEIS anchoring

The prompt identifies A036057 as the parent Friedman-number sequence.  It supplies the orderly terms
`127, 343, 736, 1285, 2187, 2502, 2592, 2737, 3125, 3685, 3864, 3972, 4096, 6455, 11264, 11664, 12850, 13825, 14641, 155`.
No independent external OEIS lookup was available, so no unverified subsequence identifier is reported.

## Counterexample hunt

- The conjecture that all orderly Friedman numbers are odd fails at 736, certified by `7+3^6`.
- The conjecture that the supplied list is strictly increasing fails at its final transition `14641, 155`.
- The conjecture that there are only finitely many fails through the repeatable 127 block; Lean proves the resulting family strictly increasing.

## Growth table

| n | F(n) |
|---:|---:|
| 0 | 127 |
| 1 | 127127 |
| 2 | 127127127 |
| 3 | 127127127127 |

The formal identity is `999 F(n) = 127 (1000^(n+1)-1)`.
