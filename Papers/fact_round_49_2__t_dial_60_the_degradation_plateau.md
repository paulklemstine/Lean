# Computational evidence for T-DIAL-60-PLATEAU

All numbers below were produced with `#eval` in Lean 4 (exact `ℤ`/`ℚ` arithmetic except
where `Float` is stated), using the same definitions as
`Catalog/Combinatorics/TDialPlateau60.lean`. Every claim they support is proved as a
theorem in that file; nothing here is used as a substitute for a proof.

## 1. Extremal squared displacement: brute force vs. the closed form

Brute force over **all** permutations of `{0,…,m-1}`, maximising `∑ (i - σ i)²`:

| `m` | brute-force max `∑ d²` | `(m³-m)/3` |
| --- | --- | --- |
| 0 | 0 | 0 |
| 1 | 0 | 0 |
| 2 | 2 | 2 |
| 3 | 8 | 8 |
| 4 | 20 | 20 |
| 5 | 40 | 40 |
| 6 | 70 | 70 |
| 7 | 112 | 112 |

Exact agreement, and the maximiser is in every case the order reversal.
Proved: `three_mul_sqDisp_le` (bound), `three_mul_sqDisp_revMap` (attained),
`eq_revMap_of_sqDisp_max` (uniqueness of the maximiser).

## 2. Block-localised dials: displacement depends on the window only

`sqDisp n (blockRev 0 m)` computed directly against `(m³-m)/3`:

| `(n, m)` | `∑ d²` | `(m³-m)/3` |
| --- | --- | --- |
| (10, 7) | 112 | 112 |
| (10, 3) | 8 | 8 |
| (60, 40) | 21320 | 21320 |
| (60, 39) | 19760 | 19760 |
| (100, 66) | 95810 | 95810 |

The displacement is independent of `n` — the whole content of `sqDisp_block_eq`.

## 3. The plateau: `ρ` is stationary in `n` at fixed shape `α = m/n`

| `n` | `m` | `ρ = 1 - 2(m³-m)/(n³-n)` | shape law `1 - 2α³` | gap |
| --- | --- | --- | --- | --- |
| 10 | 3 | 0.951515 | 0.946000 | 0.0055 |
| 10 | 7 | 0.321212 | 0.314000 | 0.0072 |
| 60 | 40 | 0.407613 | 0.407407 | 0.00021 |
| 100 | 66 | 0.425083 | 0.425008 | 0.000075 |
| 1000 | 660 | 0.425009 | 0.425008 | 0.0000008 |

The gap is bounded by `2/(n²-1)` in every row (e.g. `n = 10`: `0.0072 ≤ 0.0202`), which is
the proved `rho_blockRev_alpha_law`; the convergence in the last rows is
`rho_blockRev_tendsto`.

**Counterexample hunt.** Exhaustive scan (in Lean, exact `ℤ`/`ℚ` arithmetic) over every
`n ≤ 12` with `n ≥ 2`, every window `[a, a+m) ⊆ [0,n)` with `m ≤ 6`, and *every* permutation
of that window — checking both `3∑d² ≤ m³-m` and `ρ ≥ 1 - 2(m/n)³`: **0 violations** out of
the whole scan. Consistent with `three_mul_sqDisp_block_le` and `plateau_floor`. Note that
for windows wider than `2^{-1/3}n` the floor itself turns negative; that is not a
counterexample but the phase transition recorded in `rho_blockRev_pos_iff`.

## 4. Calibration against exp 512

Reported: `Spearman(T, rate) = 0.437`, CI `[0.393, 0.480]`, `T − count = +0.070`.

* Shape `α = 0.66` gives floor `1 - 2·0.66³ = 0.425008 ∈ [0.393, 0.480]`
  (`plateau_value_in_reported_CI`).
* Shape `α = 0.69` gives `0.342982`; adding the worst-case finite-`n` error `2/399` at
  `n = 20` still leaves a gap of `0.077 > 0.070` (`T_beats_count`).
* The observed `0.437` corresponds to `α ≈ 0.6549`; `0.66` is the rational calibration used
  in the formal statements, chosen inside the interval.

## 5. Fragmentation regime (cycle 2)

Two segments of length three, both reversed (`segRevTwo`): `∑ d² = 16`,
`ρ = 1 - 96/210 = 0.542857`, against the proved floor `1 - 2/k² = 0.5` for `k = 2`.
For `k` segments of length `m` the exact value of the all-segments-reversed dial is
`1 - 2k(m³-m)/((km)³-km)`, e.g. `k=4, m=15`: `0.8755`, `k=2, m=30`: `0.5004`, always above
`1 - 2/k²` and converging to it as `m → ∞` for fixed `k`.

## Sequences

No new integer sequence is introduced: the extremal values `(m³-m)/3 = 0, 0, 2, 8, 20, 40,
70, 112, …` are the standard "maximal Spearman displacement" values (twice the tetrahedral
numbers, `2·C(m+1,3)/…`); we make no OEIS identification claim beyond the closed form
proved here.
