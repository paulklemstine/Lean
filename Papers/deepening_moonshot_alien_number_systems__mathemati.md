# Computational evidence: negabinary

The target is the unique finite representation of every integer in radix `-2` with digits `0,1`.

## Small cases

Digits below are written most-significant first (the Lean representation reverses them).

| integer | negabinary |
|---:|:---|
| -10 | 1010 |
| -9 | 1011 |
| -8 | 1000 |
| -7 | 1001 |
| -6 | 1110 |
| -5 | 1111 |
| -4 | 1100 |
| -3 | 1101 |
| -2 | 10 |
| -1 | 11 |
| 0 | empty |
| 1 | 1 |
| 2 | 110 |
| 3 | 111 |
| 4 | 100 |
| 5 | 101 |
| 6 | 11010 |
| 7 | 11011 |
| 8 | 11000 |
| 9 | 11001 |
| 10 | 11110 |

The Lean file includes kernel-checked sample evaluations for `-9`, `2`, and `19`.

## Sequence search

No sequence theorem is needed: the core object is a bijective numeral system rather than a numerical sequence, so no OEIS identification was used.

## Counterexample hunt

Repeated Euclidean division by `-2`, choosing the residue in `{0,1}`, terminates on the displayed positive and negative samples. Exhaustively comparing all canonical bit lists of length at most five gives distinct values; their ranges interleave positive and negative integers as predicted. No counterexample was found. This table is motivation only; the universal result is proved in Lean without relying on finite testing.
