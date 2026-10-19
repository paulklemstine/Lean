# Computational Evidence — Round 44 NFS closure

Status of each number: **[Lean]** means a Lean theorem in `Catalog/Physics/NFSClosure*.lean`
proves it; **[exploratory]** means it comes from an ad-hoc Python run, was not checked in
Lean, and is included only to show what motivated the statements.

## 1. Surplus slope against width slope (channel 3)

| quantity | value | status |
|---|---|---|
| `log 7.94 / log 5.30` | 1.24237… | [exploratory] float value |
| `7.94^4 = 3974.50 < 5.3^5 = 4181.95` ⇒ slope `< 5/4` | | [Lean] `surplus_slope_bounds` |
| `5.3^6 = 22164.4 < 7.94^5 = 31557.5` ⇒ slope `> 6/5` | | [Lean] `surplus_slope_bounds` |
| slope `< 1.819` (width exponent) | | [Lean] `surplus_slope_lt_width_slope` |
| surplus/cost ratio strictly decreasing, tends to `0` | | [Lean] `round44_no_inversion` |

## 2. Truncated `left_dependencies` (channel 2)

[exploratory] Random sparse 𝔽₂ relation matrices (5 nonzeros per row, seed 1); "true" is
`rows − rank`, "reading" is `min(60, true)`:

| cols `c` | rows `r` | excess | true nullity | reading |
|---|---|---|---|---|
| 50 | 50 | 0 | 1 | 1 |
| 50 | 60 | 10 | 11 | 11 |
| 50 | 110 | 60 | 60 | 60 |
| 50 | 170 | 120 | 120 | **60** |
| 100 | 220 | 120 | 120 | **60** |
| 200 | 260 | 60 | 61 | **60** |
| 200 | 320 | 120 | 120 | **60** |

Every row with excess ≥ 60 reads 60. That this holds for *every* matrix is proved in Lean
(`truncated_reading_saturates`, `left_dependencies_cap60`), as is the vector-count variant
in which the cap is reached at excess 6 (`2^6 − 1 = 63 ≥ 60`,
`truncated_vector_count_saturates`).

## 3. Base-`m` selection (the column set is governed by `d`)

[exploratory]

| `N` | `d` | `m = ⌊N^{1/d}⌋` | degree of digit polynomial | all coefficients `< m` | `f(m) = N` |
|---|---|---|---|---|---|
| 10^12+39 | 3 | 10000 | 3 | yes | yes |
| 2^61−1 | 4 | 38967 | 4 | yes | yes |
| 123456789012345 | 5 | 658 | 5 | yes | yes |

The general statement is proved in Lean: `base_m_selection`.

## 4. Degree balance

[exploratory] With `u = x^{1/3}(log x)^{2/3}`, the integer `d` minimising `d·u + x/d`:

| `x = log N` | `u` | best integer `d` | `√(x/u)` | `d·u + x/d` | `2√(ux)` |
|---|---|---|---|---|---|
| 100 | 12.85 | 3 | 2.79 | 71.88 | 71.69 |
| 200 | 17.77 | 3 | 3.35 | 119.99 | 119.24 |
| 400 | 24.31 | 4 | 4.06 | 197.22 | 197.20 |

The integer optimum never goes below `2√(ux)`. Lean proves the lower bound for all real
`d > 0` (`degree_balance`), and that equality holds only at `d = √(x/u)`
(`degree_balance_eq_iff`).

## 5. Constant-factor channel

The rebuilt ratio `0.9932 ± 0.0122` is a factor bounded between the positive constants
`0.981` and `1.0054`. Lean proves that any factor bounded between positive constants leaves
the `L`-exponent unchanged (`LExponent.mul_of_bounded`). No OEIS sequence is involved.
