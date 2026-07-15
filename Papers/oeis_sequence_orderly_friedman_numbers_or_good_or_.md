# Computational Evidence: Orderly Friedman Numbers

## Small-case calculations

The following orderly identities use digits from left to right:

| Number | Certificate |
|---:|:---|
| 127 | `-1 + 2^7` |
| 343 | `(3 + 4)^3` |
| 736 | `7 + 3^6` |
| 1285 | `(1 + 2^8) * 5` |
| 2592 | `2^5 * 9^2` |

Repeating the certified block `127` gives the affine recurrence
`F(0)=127`, `F(n+1)=1000F(n)+127`:

| n | F(n) |
|---:|---:|
| 0 | 127 |
| 1 | 127127 |
| 2 | 127127127 |
| 3 | 127127127127 |

The calculated values satisfy `999F(n)=127(1000^(n+1)-1)`.

## OEIS identification

The orderly Friedman-number sequence is OEIS A080035. The supplied prefix begins
`127, 343, 736, 1285, 2187, 2502, 2592, ...`. The final supplied value `155`
appears after `14641`, so the displayed data are not in increasing order.

## Counterexample hunt

Two universal claims were tested against explicit certificates:

* “Every orderly Friedman number is odd” fails at `736`, since `736 = 7 + 3^6`.
* “The supplied list is strictly increasing” fails at its final transition
  `14641, 155`.

The repeated-block family also provides a systematic test of proposed growth
bounds. Its exact normalized error is
`127/999 - F(n)/1000^(n+1) = 127/(999*1000^(n+1))`, so any sharper universal
bound for this family must respect that geometric rate.
