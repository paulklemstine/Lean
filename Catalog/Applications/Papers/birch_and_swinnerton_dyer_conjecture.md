# Computational Evidence — BSD Research Cycle

This note records the small-case checks performed before formalization. The cycle
targets the *structural* components of the Birch–Swinnerton-Dyer conjecture
(Frobenius eigenvalues / Hasse bound, order of vanishing, and the rank bridge),
so the evidence is algebraic rather than large-scale numerics.

## 1. Frobenius eigenvalues and the Hasse / Riemann-Hypothesis equivalence

For the characteristic polynomial of Frobenius `X² − a X + p`, we test the claim
`normSq(root) = p  ⇔  a² ≤ 4p`:

| `a` | `p` | roots                | `normSq(root)` | `a² ≤ 4p`? | central value of `normSq = p`? |
|----:|----:|----------------------|---------------:|:----------:|:------------------------------:|
| 2   | 2   | `1 ± i`              | `2`            | `4 ≤ 8` ✓  | `2 = 2` ✓                      |
| 0   | 3   | `±√3 · i`            | `3`            | `0 ≤ 12` ✓ | `3 = 3` ✓                      |
| 3   | 2   | `1, 2` (real)        | `1`, `4`       | `9 ≤ 8` ✗  | `≠ 2` ✓ (consistent)          |
| 4   | 4   | `2` (double)         | `4`            | `16 ≤ 16`✓ | `4 = 4` ✓ (boundary)          |
| 5   | 4   | `1, 4` (real)        | `1`, `16`      | `25 ≤ 16`✗ | `≠ 4` ✓ (consistent)          |

Every row matches the conjectured equivalence, including the boundary case
`a² = 4p` (the double root sits exactly on the circle of radius `√p`). This is
formalized as `BSD.LocalFactor.frobenius_normSq_eq_iff`.

## 2. Hasse point-count interval

`#E(𝔽_p) = p + 1 − a_p` with `|a_p| ≤ 2√p`. Spot checks of `p + 1 − 2√p > 0`:

| `p`  | `2√p`   | `p + 1 − 2√p` |
|-----:|--------:|--------------:|
| 2    | 2.828…  | 0.171… > 0    |
| 5    | 4.472…  | 1.527… > 0    |
| 97   | 19.69…  | 78.30… > 0    |

The deviation `(√p − 1)² = p + 1 − 2√p` is positive for all `p ≠ 1`, confirming
`BSD.RankBridge.hasse_point_count_pos`.

## 3. Order of vanishing of the model L-function

Model `L(s) = (s − 1)^r · c`, `c ≠ 0`. Symbolically the order of vanishing at
`s = 1` is exactly `r`, and `L(1) = 0 ⇔ r ≥ 1`. Checked for `r = 0,1,2,3`:
`L(1) = c·0^r`, which is `c ≠ 0` for `r = 0` and `0` for `r ≥ 1`. Formalized as
`BSD.AnalyticRank.modelL_analyticRank` and `modelL_central_value`.

## 4. Mordell–Weil infinitude

`ℤ^r × T` (`T` finite nonempty) is infinite iff `r ≥ 1`:

| `r` | `T` size | `ℤ^r × T` |
|----:|---------:|:---------:|
| 0   | any `≥1` | finite    |
| 1   | any      | infinite  |
| 2   | any      | infinite  |

Matches `BSD.RankBridge.mordellWeil_infinite_iff`. Concretely `E(ℚ)` for
`y² = x³ − x` has rank `0` and is finite (torsion `ℤ/2 × ℤ/2`), while
`y² = x³ − 2` has rank `1` and is infinite — consistent with the table.

## Counterexample hunt

No counterexamples were found to any formalized statement. The only "near miss"
is the unrestricted central-value claim `modelL r c 1 = 0 ↔ 0 < r`, which fails
for `r = 0, c = 0`; the formalization therefore carries the honest hypothesis
`c ≠ 0`.
