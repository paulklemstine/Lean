# Computational Evidence

All numerical claims below were subsequently *formalised and machine-checked* in
`Catalog/Geometry/Taxicab*.lean`; the tables here only record the exploration that
selected the statements worth proving.

## 1. Unsigned representations (`a³ + b³ = N`, `1 ≤ a ≤ b`)

Exhaustive enumeration over `1 ≤ a ≤ b ≤ 215` (all `N ≤ 10⁷`):

| N | representations | count |
|---|---|---|
| 1729 | (1,12), (9,10) | 2 |
| 4104 | (2,16), (9,15) | 2 |
| 13832 | (2,24), (18,20) | 2 |
| 20683 | (10,27), (19,24) | 2 |
| 32832 | (4,32), (18,30) | 2 |
| 43 | — | 0 |
| 344 | (1,7) | 1 |
| 728 | (6,8) | 1 |

First value with two representations: **1729** (OEIS A011541 lists the taxicab numbers
1729, 87539319, 6963472309248, 48988659276962496, 24153319581254312065344).

Witnesses used in the formalisation (all verified by direct cube arithmetic):

* `87539319 = 167³+436³ = 228³+423³ = 255³+414³`
* `6963472309248 = 2421³+19083³ = 5436³+18948³ = 10200³+18072³ = 13322³+16630³`
* `48988659276962496`: (38787,365757), (107839,362753), (205292,342952), (221424,336588),
  (231518,331954)
* `24153319581254312065344`: (582162,28906206), (3064173,28894803), (8519281,28657487),
  (16218068,27093208), (17492496,26590452), (18289922,26224366)

## 2. Counterexample hunt: the "cube-free core" conjecture

Claim tested: `r(m³N₀) = r(N₀)` for cube-free `N₀`. Scanning all `N ≤ 10⁵` that are
sums of two positive cubes and divisible by a cube:

| N | factorisation | r(N) | r(core) |
|---|---|---|---|
| 152 | 2³·19 | 1 | 0 |
| 189 | 3³·7 | 1 | 0 |
| 344 | 2³·43 | 1 | 0 |
| 351 | 3³·13 | 1 | 0 |
| 513 | 3³·19 | 1 | 0 |

The claim fails already at `152`; the counterexample chosen for formalisation is
`344 = 2³·43` (`344 = 1³+7³` but `43` is not a sum of two positive cubes).

## 3. Signed ("cabtaxi") representations (`a³ + b³ = N`, `a, b ∈ ℤ∖{0}`, `a ≤ b`)

Enumeration over `|a|,|b| ≤ 200`, `0 < N ≤ 10⁵`:

| N | representations | count |
|---|---|---|
| 91 | (−5,6), (3,4) | 2 |
| 152 | (−4,6), (3,5) | 2 |
| 728 | (−10,12), (−1,9), (6,8) | 3 |

First value with two signed representations: **91**; first with three: **728**
(cabtaxi numbers, OEIS A047696: 91, 728, 2741256, …). Note the sharp drop compared with
the unsigned problem (1729 and 87539319).

Search-space bound used in the proofs: for `a³+b³ = N > 0` with `a,b ≠ 0` one always has
`a² ≤ N` and `b² ≤ N`, so `N ≤ 90` only needs the box `[-9,9]²` (15 admissible pairs) and
`N ≤ 727` only needs `[-26,26]²` (78 admissible pairs). Both boxes were checked
exhaustively inside Lean by kernel evaluation, not merely in the scratch scan.

## 4. Growth rate data

Known values (A011541) against the elementary floor proved here (`110 (n-1)³`):

| n | least known N with n reps | `110(n-1)³` |
|---|---|---|
| 2 | 1729 | 110 |
| 3 | 87539319 | 880 |
| 4 | 6963472309248 | 2970 |
| 5 | 48988659276962496 | 7040 |
| 6 | 24153319581254312065344 | 13750 |

The observed values grow roughly like `10^{3.7n}`, i.e. exponentially in `n`, whereas the
best elementary lower bound is only cubic in `n`. This 18-orders-of-magnitude gap at
`n = 6` is what motivates the super-polynomial growth conjecture in
`FUTURE_DIRECTIONS.md`.

## 5. Chord–tangent check

Tangent duplication on `x³+y³=N` at `(x,y)`:
`x' = x(x³+2y³)/(x³−y³)`, `y' = −y(2x³+y³)/(x³−y³)`.
At `(1,2)` on `x³+y³=9`: `x' = −17/7`, `y' = 20/7`, and
`(−17/7)³+(20/7)³ = 3087/343 = 9`. Verified numerically and then proved as an identity.
