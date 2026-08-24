# Computational evidence — exp 527 / `CELL-CLOSED-DIAL-HOLDS-UNIF-48B`

All numbers below were produced by `#eval` inside the project (exact rational or
natural arithmetic, no floating point except where marked), and every claim they
support is proved in the Lean files listed at the end.

## 1. The exact-bitlen window profile (one-bit shift)

Trailing-zero block sizes of the window `[2^s, 2^(s+1))` versus the full-range
dyadic profile at bitlen `s`:

| `s` | `windowProfile s` | `dyadicBlocks s` |
|-----|-------------------|------------------|
| 1 | `[1, 1]` | `[1, 1]` |
| 2 | `[2, 1, 1]` | `[2, 1, 1]` |
| 3 | `[4, 2, 1, 1]` | `[4, 2, 1, 1]` |
| 5 | `[16, 8, 4, 2, 1, 1]` | `[16, 8, 4, 2, 1, 1]` |

Spot check at `s = 5`: `#(bitWindow 5) = 32`, `#(windowBlock 5 0) = 16`,
`#(windowBlock 5 1) = 8`, `#(windowBlock 5 5) = 1`.

Popcount side at `s = 4`: `weightWindowProfile 4 = [1,4,6,4,1] = binomBlocks 4`.

So *both* statistics have their exact-bitlen-`(s+1)` profile equal to the
full-range profile at bitlen `s`.  Proved: `windowProfile_eq_dyadicBlocks`,
`weightWindowProfile_eq_binomBlocks`.

## 2. Counterexample hunt for the ceiling-inversion law

Criterion `7·franel b < 8^b + 6` (equivalent to "popcount ceiling strictly above
trailing-zero ceiling", `inversion_of_franel_lt`):

| `b` | `7·franel b` | `8^b + 6` | strict? |
|-----|--------------|-----------|---------|
| 0 | 7 | 7 | no (equal) |
| 1 | 14 | 14 | no (equal) |
| 2 | 70 | 70 | no (equal) |
| 3 | 392 | 518 | yes |
| 4 | 2422 | 4102 | yes |
| 5 | 15764 | 32774 | yes |
| 6 | 106288 | 262150 | yes |
| 7 | 734720 | 2097158 | yes |
| 8 | 5174134 | 16777222 | yes |
| 9 | 36966524 | 134217734 | yes |

The hunt for a counterexample above `b = 2` fails, and the equalities at
`b ≤ 2` are exactly the degenerate cases: the profiles there are permutations
of each other (`[1,1]` vs `[1,1]`, `[2,1,1]` vs `[1,2,1]`).  This is what
`inversion_iff_three_le` proves: strict inversion **iff** `b ≥ 3`.

## 3. Ceiling values (exact rationals)

`spearmanSq (dyadicBlocks b)` (trailing-zero) versus `spearmanSq (binomBlocks b)`
(popcount):

| `b` | dyadic | ≈ | binomial | ≈ |
|-----|--------|---|----------|---|
| 1 | `1` | 1.0000 | `1` | 1.0000 |
| 2 | `9/10` | 0.9000 | `9/10` | 0.9000 |
| 3 | `73/84` | 0.8690 | `19/21` | 0.9048 |
| 4 | `117/136` | 0.8603 | `125/136` | 0.9191 |
| 5 | `151/176` | 0.8580 | `2543/2728` | 0.9322 |
| 6 | `12483/14560` | 0.8573 | `49/52` | 0.9423 |
| 7 | `2359/2752` | 0.8572 | `5188/5461` | 0.9500 |

The dyadic column decreases monotonically to `6/7 = 0.857143…`
(`ρ → √(6/7) ≈ 0.92582`), the binomial column increases towards `1`; they cross
between `b = 2` and `b = 3`, matching the proved threshold.

## 4. The recorded round-57 cell

Seeds 20261110/11/12: `0.7291 / 0.7286 / 0.7087`; pooled mean
`1354/1875 = 0.722133…`; implied count baseline `4411/7500 = 0.588133…`
(pooled minus the reported advantage `0.134`).

* All three seeds lie inside `[0.55, 0.85]` (`round57_inside_band`).
* All three squared seeds lie below `6/7 < ` the exact-bitlen-48 ceiling
  (`round57_seeds_below_ceiling`); the ceiling itself is
  `(6/7)(1 + 1/(2^47(2^47+1)))`, i.e. `ρ ≈ 0.92582`, so the measurement is at
  about 78 % of the attainable maximum.
* Ceiling difference between exact bitlen 48 and full bitlen 64: `< 4^{-47}`
  (`round57_ceiling_flat_but_dial_moves`), while the dial itself moves from
  `0.7221` to `0.648`.

## 5. Translation invariance spot checks

Trailing-zero profiles of arbitrary (non-aligned) windows of `2^s` consecutive
integers:

| window | profile |
|--------|---------|
| `[0, 32)` | `[16, 8, 4, 2, 1, 1]` |
| `[7, 39)` | `[16, 8, 4, 2, 1, 1]` |
| `[1234567, 1234599)` | `[16, 8, 4, 2, 1, 1]` |
| `[3, 67)` (`s = 6`) | `[32, 16, 8, 4, 2, 1, 1]` |

Each equals `dyadicBlocks s`.  The counterexample hunt for a placement-dependent
profile therefore fails, and `slidingProfile_eq_dyadicBlocks` proves it cannot
succeed for any offset or scale.

## 6. OEIS

The two cube sums appearing throughout are:

* dyadic: `Σ_{k<b} (2^{b-1-k})³ + 1 = (8^b − 1)/7 + 1` — repunits in base 8,
  OEIS A023001 (`1, 9, 73, 585, …`) shifted by the cap term;
* binomial: `franel b = Σ_j C(b,j)³` — the Franel numbers, OEIS A000172
  (`1, 2, 10, 56, 346, 2252, 15184, 104960, …`); the table in §2 is `7·A000172`.

## 7. Files

`Catalog/Novelty/ZeroFitDialExactBitlen48.lean`,
`Catalog/Novelty/ZeroFitDialInversionThreshold.lean`,
`Catalog/Novelty/ZeroFitDialAlignedWindow.lean`,
`Catalog/Novelty/ZeroFitDialTranslationInvariance.lean` — all build with zero `sorry`
and depend only on `propext`, `Classical.choice`, `Quot.sound`.
