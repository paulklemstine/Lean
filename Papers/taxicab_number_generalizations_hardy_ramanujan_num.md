# Computational Evidence: Hardy–Ramanujan Taxicab Numbers

## 1. Small-case calculations

A taxicab representation of `N` is a pair of positive integers `a ≤ b` with
`a³ + b³ = N`. The `n`-th taxicab number is the least `N` with exactly (at least)
`n` such representations.

| n | Taxicab(n)      | Representations `a³ + b³` |
|---|-----------------|---------------------------|
| 1 | 2               | 1³ + 1³ |
| 2 | 1729            | 1³ + 12³ = 9³ + 10³ |
| 3 | 87539319        | 167³ + 436³ = 228³ + 423³ = 255³ + 414³ |
| 4 | 6963472309248   | 2421³ + 19083³ = 5436³ + 18948³ = 10200³ + 18072³ = 13322³ + 16630³ |

All identities were confirmed by direct arithmetic:

```
1³ + 12³        = 1 + 1728            = 1729
9³ + 10³        = 729 + 1000          = 1729

167³ + 436³     = 4657463 + 82881856  = 87539319
228³ + 423³     = 11852352 + 75686967 = 87539319
255³ + 414³     = 16581375 + 70957944 = 87539319

2421³  + 19083³  = 6963472309248
5436³  + 18948³  = 6963472309248
10200³ + 18072³  = 6963472309248
13322³ + 16630³  = 6963472309248
```

## 2. OEIS

The taxicab numbers form OEIS **A011541**: `2, 1729, 87539319, 6963472309248,
48988659276962496, 24153319581254312065344, …`.

## 3. Cubic lower bound — sanity check

The proved bound `Taxicab(n) > n³` predicts:

| n | n³   | Taxicab(n)     | n³ < Taxicab(n)? |
|---|------|----------------|------------------|
| 2 | 8    | 1729           | yes |
| 3 | 27   | 87539319       | yes |
| 4 | 64   | 6963472309248  | yes |

The bound is far from tight (the true growth is much faster), but it is
elementary and unconditional: `n` distinct representations use `n` distinct
smaller summands, the largest of which is at least `n`, whence `n³ < N`.

## 4. Counterexample hunt

No counterexample to the cubic lower bound is possible: it is a theorem. The
witness tables above were checked to be genuine (each pair satisfies
`0 < a ≤ b` and the cube identity), and the smaller summands within each row are
pairwise distinct, so each row genuinely realises the claimed representation
count.
