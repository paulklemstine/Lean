# Computational evidence — TDIAL-U84 "approaching but not crossed" (exp 535)

All numbers below are exact rational computations reproduced *inside Lean* in the three
files of this cycle; nothing here is an unchecked script result.  Where a line is marked
**[Lean]** the corresponding statement is a theorem with a machine-checked proof.

## 1. The recorded record

```
bitlen :  44     52     64     72     76     84      92     96
rho    :  0.78   0.705  0.648  0.605  0.608  0.558   0.563  0.5739
```

U84 (exp 535, seeds 20261190–92): pooled `0.558`, CI `[0.536, 0.581]`,
per-seed `0.572 / 0.578 / 0.522`, band floor `0.55`.

| quantity | value | status |
|---|---|---|
| margin to the floor | `0.558 − 0.55 = 0.008` | **[Lean]** `u84_not_crossed` |
| CI straddles the floor | `0.536 < 0.55 < 0.581` | **[Lean]** `u84_ci_straddles_floor` |
| CI half-width | `0.0225` | **[Lean]** `u84_halfwidth_exceeds_margin` |
| per-seed mean vs pooled | `|0.55733 − 0.558| ≤ 0.001` | **[Lean]** `u84_seed_mean_matches_pooled` |
| seeds below floor | one of three (`0.522`) | **[Lean]** `u84_only_one_seed_below_floor` |
| step U76→U84 | `−0.05` (6× the residual margin) | **[Lean]** `u84_step_dwarfs_margin` |

## 2. Small-case calculations for the rank-metric budget

The Spearman statistic on `n` paired ranks is `ρ = 1 − 6∑(σk − k)²/(n(n²−1))`.  The exact
transposition identity (**[Lean]** `sumSqDev_transposeAt`) gives, for the swap of positions
`i ≠ j`,

```
Δ∑(σk − k)² = 2 (j − i)(σ j − σ i)          Δρ = −12 (j − i)(σ j − σ i) / (n(n²−1))
```

Hand-checked small cases (all reproduced by the Lean identity):

| n | σ | swap | Δ∑d² | Δρ |
|---|---|---|---|---|
| 3 | id | (0,1) | `2·1·1 = 2` | `−12/24 = −0.5` |
| 3 | id | (0,2) | `2·2·2 = 8` | `−48/24 = −2` (`ρ: 1 → −1`) |
| 4 | id | (1,2) | `2` | `−12/60 = −0.2` |
| 4 | `[3,0,1,2]`* | (0,1) | `2·1·(0−3) = −6` | `+72/60 = +1.2` |

(*the `flipVec` witness; it attains the maximal adjacent step `12/(n(n+1))` — **[Lean]**
`adjacent_step_bound_sharp`.)

The two ends of the scale: `ρ(identity) = +1`, `ρ(reversal) = −1`, the latter because
`∑(σk − k)² = n(n²−1)/3` for the reversal — verified by hand for `n = 2` (`2 = 2·3/3`),
`n = 3` (`8 = 3·8/3`), `n = 4` (`20 = 4·15/3`) and proved in general (**[Lean]**
`sumSqDev_revVec`).

Derived budgets at `n = 4096`, `D = n(n²−1) = 68 719 472 640`:

| bound | formula | value | status |
|---|---|---|---|
| margin crossing (linear) | `0.008 · n(n+1)/12` | `≥ 11188` swaps | **[Lean]** `u84_crossing_budget_4096` |
| erosion distance (linear) | `0.442 · n(n+1)/12` | `≥ 618112` swaps | **[Lean]** `u84_kendall_linear_budget` |
| erosion distance (quadratic) | `√(0.442·D/24)` | `≥ 35576` swaps | **[Lean]** `u84_kendall_quadratic_budget` |

The margin is `11188/618112 = 1.81 %` of the erosion distance already travelled.

## 3. Dispersion of the three seeds

```
mean       = 209/375        = 0.5573333…
variance   = 709/1125000    = 6.30222e-4      [Lean] u84_seed_variance
Bhatia–Davis ceiling (M−μ)(μ−m) = 1643/2250000 = 7.30222e-4   [Lean]
ratio      = 0.863          (near-extremal spread for its range)
9 · margin² = 5.76e-4  <  variance                            [Lean]
```

So the seed-to-seed standard deviation (`≈ 0.0251`) is more than three times the margin
(`0.008`).

## 4. Counterexample hunt: does *any* monotone fade fit the ladder?

Universal claim tested: "the dial erodes monotonically towards the floor".
Counterexample found in the record itself: `ρ(84) = 0.558 < ρ(92) = 0.563 < ρ(96) = 0.5739`
(**[Lean]** `ladder_rebounds`).  Quantitatively, any nonincreasing fit must absorb
`η ≥ (0.5739 − 0.558)/2 = 0.00795`, which is `159/160` of the entire margin (**[Lean]**
`u84_monotone_noise_floor`, `u84_noise_floor_vs_margin`).

Least-squares slope through the three post-84 rungs: `+49/40000 = +0.001225` per bit —
positive, i.e. away from the floor (**[Lean]** `u84_post_trend_value`,
`u84_post_trend_positive`); extrapolating one rung gives `0.5788 > 0.55`.

## 5. Model-indistinguishability search

Search for two contractive fades `ρ_j = L + aλ^j` fitting `(0.558, 0.563, 0.5739)` within
`η = 0.008` on opposite sides of the floor:

| model | `L` | `a` | `λ` | `ρ₀, ρ₁, ρ₂` | max residual |
|---|---|---|---|---|---|
| A | `0.5659` | `1e−6` | `0.5` | `0.565901, 0.5659005, 0.56590025` | `0.00799975` |
| B | `0.549` | `0.017` | `0.998` | `0.566, 0.565966, 0.5659321` | `0.008` |

Both fit; `A` never crosses (`L > 0.55`), `B` crosses eventually (`L < 0.55`).  This search
result is the content of **[Lean]** `crossing_undecidable_at_margin_resolution`.

## 6. OEIS

The only integer sequence arising is the reversal displacement
`n(n²−1)/3 = 0, 0, 2, 8, 20, 40, 70, …` for `n = 0,1,2,…` — the doubled tetrahedral numbers
(`2·C(n+1,3)`), OEIS A007290 up to indexing.  It appears here as the exact `ℓ²` diameter of
the Spearman scale and is proved in Lean (`sumSqDev_revVec`), so no external lookup is
load-bearing.
