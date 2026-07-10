# Computational Evidence — The Lazy Caterer Hierarchy

## 1. Small-case calculations

Lazy caterer numbers `p n = n(n+1)/2 + 1` (regions of the plane cut by `n` lines):

| n   | 0 | 1 | 2 | 3 | 4  | 5  | 6  | 7  | 8  |
|-----|---|---|---|---|----|----|----|----|----|
| p n | 1 | 2 | 4 | 7 | 11 | 16 | 22 | 29 | 37 |

Cake numbers `c n = (n³ + 5n + 6)/6` (regions of space cut by `n` planes):

| n   | 0 | 1 | 2 | 3 | 4  | 5  | 6  | 7  | 8  |
|-----|---|---|---|---|----|----|----|----|----|
| c n | 1 | 2 | 4 | 8 | 15 | 26 | 42 | 64 | 93 |

## 2. OEIS matches

* `p n` = **A000124** (central polygonal numbers / lazy caterer): 1, 2, 4, 7, 11, 16, 22, 29, 37, …
* `c n` = **A000125** (cake numbers): 1, 2, 4, 8, 15, 26, 42, 64, 93, …

Both are consecutive partial sums of a single Pascal row:
`p n = C(n,0)+C(n,1)+C(n,2)`, `c n = C(n,0)+C(n,1)+C(n,2)+C(n,3)`.

## 3. Identity checks (all confirmed on n ≤ 8)

* First difference: `p(n+1) − p n = n+1`. E.g. p5−p4 = 16−11 = 5. ✓
* Constant second difference: `p(n+2)+p n = 2·p(n+1)+1`. E.g. n=3: 16+7 = 23 = 2·11+1. ✓
* Layer recurrence: `c(n+1) = c n + p n`. E.g. c5 = c4 + p4 = 15 + 11 = 26. ✓
* Partial sum: `∑_{k≤n} p k = (n+1) + C(n+2,3)`. E.g. n=3: 1+2+4+7 = 14 = 4 + C(5,3) = 4+10. ✓

## 4. Parity hunt

`p n` is odd for n = 0, 3, 4, 7, 8, 11, 12, … i.e. exactly when `n mod 4 ∈ {0, 3}`.
Checked for n ≤ 40; no counterexample. This is the content of `caterer_odd_iff`.

## 5. Counterexample search

The layer recurrence `c(n+1) = c n + p n` was tested against the independent closed forms
for all n ≤ 200 with no discrepancy, supporting the "one dimension up = one binomial layer"
hypothesis that is proved in general in `LazyCatererHierarchy.lean`.
