# Computational Evidence — Pythagorean Energy Spectrum / Fermat Descent

All results here were computed inside Lean 4 (`#eval`) and directly motivate the
formal theorems in `Catalog/Pythagorean/PythagoreanEnergySpectrum.lean`.

## 1. The energy spectrum locates factors (small odd numbers)

For each odd `N` we scan the abscissa `s` upward from `⌈√N⌉` and accept the first
`s` with `s² − N = t²` a perfect square (this is exactly minimizing the strictly
convex energy `E N s = s² − N` subject to the "square residual" constraint). We
record `(N, s, t, s−t, s+t)`:

```
(9,  3, 0, 3, 3)      15→(4,1, 3, 5)     21→(5,2, 3, 7)     33→(7,4, 3,11)
(11, 6, 5, 1, 11)     17→(9,8, 1,17)     23→(12,11,1,23)    35→(6,1, 5, 7)
(13, 7, 6, 1, 13)     19→(10,9,1,19)     25→(5,0, 5, 5)     45→(7,2, 5, 9)
(27, 6, 3, 3, 9)      29→(15,14,1,29)    31→(16,15,1,31)    51→(10,7,3,17)
(37,19,18,1,37)       39→(8,5, 3,13)     41→(21,20,1,41)    55→(8,3, 5,11)
(43,22,21,1,43)       47→(24,23,1,47)    49→(7,0, 7, 7)     53→(27,26,1,53)
```

**Reading the table.**
- **Composite `N`** (e.g. `15, 21, 33, 35, 39, 45, 51, 55`): the descent stops at a
  *balanced* pair `(s−t)·(s+t) = N` with `1 < s−t`, i.e. a genuine non-trivial
  factor. This is `factor_from_repr`.
- **Prime `N`** (e.g. `11,13,17,19,23,29,31,37,41,43,47,53`): the only stopping
  point is `s−t = 1`, `s+t = N`, the trivial factorization. This is the `¬` side of
  `composite_iff_diff_squares`.
- **Perfect squares** `9, 25, 49`: `t = 0`, `s = √N`, `s−t = √N`. The criterion
  handles these via `0 ≤ t` (not `0 < t`), which is why the formal statement uses
  `0 ≤ t ∧ 1 < s − t`.

## 2. Convexity / monotonicity of the spectrum

`E N s = s² − N` restricted to `s ≥ 0` is strictly increasing, so the first accepted
`s` gives the factor pair with the smallest `t` — the most *balanced* factorization
(closest divisors to `√N`). Sampled slopes of `E 55`:

```
s     : 8   9   10  11  12
E 55 s: 9   26  45  66  89   (strictly increasing, second differences = 2 > 0)
```

This is the discrete witness of `energy_strictConvexOn` and `energy_strictMonoOn`,
and the ordering underlies `balanced_minimizes_energy` /
`energy_lt_of_more_balanced`.

## 3. Berggren tree sanity checks

The three Berggren maps applied to the root `(3,4,5)`:
```
A (3,4,5) = (5, 12, 13)
B (3,4,5) = (21, 20, 29)
C (3,4,5) = (15, 8, 17)
```
All satisfy `a²+b²=c²` and all have hypotenuse `> 5`, matching `bergA_pyth`,
`bergB_pyth`, `bergC_pyth` and `bergA_hyp_grow`. Each triple also exhibits the
leg–square factorization `a² = (c−b)(c+b)` (`leg_sq_factorization`), e.g. for
`(5,12,13)`: `5² = 25 = 1·25 = (13−12)(13+12)`.

## 4. Counterexample hunt

No counterexamples were found to the universal claims. In particular, over all odd
`N ≤ 999` the equivalence "`N` composite ⇔ a non-trivial point `(s,t)` on
`s² = N + t²` exists" held in every case (checked computationally), which is exactly
the theorem `composite_iff_diff_squares` proved formally.

## OEIS note

The sequence of least `s−t > 1` over odd composites, and the `t = 0` behaviour at
squares, are elementary consequences of Fermat's method; no single distinctive OEIS
entry is claimed here since the tables are standard difference-of-squares data.
