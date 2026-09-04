# Computational evidence — Spearman dial geometry (round-44 #2, exp 499)

All numbers below were produced inside the project's Lean environment (`#eval` on the
definitions in `Catalog/Geometry/Spearman*.lean`), not in an external script.  Claims that were
turned into *proved* statements are marked **[proved]**; claims that remain evidence only are
marked **[evidence]** and appear in `FUTURE_DIRECTIONS.md`.

## 1. The value set of the raw statistic `D σ τ = ∑ d²`

Sorted multiset of `D σ 1` over all of `S₃` and `S₄`:

| `n` | values of `∑d²` |
|-----|-----------------|
| 3   | `0, 2, 2, 6, 6, 8` |
| 4   | `0, 2, 2, 2, 4, 6, 6, 6, 6, 8, 8, 10, 10, 12, 12, 14, 14, 14, 14, 16, 18, 18, 18, 20` |

Observations, all confirmed by proof:

* every value is **even** — **[proved]** `D_even`;
* the smallest nonzero value is `2`, i.e. there is a gap `(0, 2)` — **[proved]**
  `D_two_le_of_ne`, and in correlation units `sprho_le_one_sub_gap`;
* the largest value is the reversal's — **[proved]** `D_le_D_rev`.

## 2. Diameter of the permutohedron

`D revPerm 1` for `n = 3, 4, 5, 6`: `8, 20, 40, 70`.
These match `n(n² − 1)/3 = 8, 20, 40, 70` exactly — **[proved]** `three_mul_D_rev`.
The closed form is `2·C(n+1, 3)`, twice a tetrahedral number; no new sequence is involved, so
no OEIS lookup was needed.

## 3. First moment (null mean)

`∑_{σ ∈ Sₙ} D σ 1` for `n = 3, 4, 5`: `24, 240, 2400`.
Dividing by `n!` gives means `4, 10, 20`, i.e. exactly `n(n² − 1)/6` — **[proved]**
`six_mul_sum_D`, and hence `sprho_null_mean : ∑_σ sprho σ 1 = 0`.

## 4. Footrule versus inversions (Diaconis–Graham)

Exhaustive checks:

| statement | `n = 3` | `n = 4` | `n = 5` | `n = 6` |
|-----------|---------|---------|---------|---------|
| `F σ 1 ≤ 2·inv σ` | true | true | true | true | **[proved in general]** `footrule_le_two_mul_inv` |
| `inv σ ≤ F σ 1` | true | true | true | true | **[evidence]** |
| `inv σ + T σ ≤ F σ 1`, `T = |support| − |cycleType|` | true | true (kernel-checked, `labnote_dg_lower_fin4`) | true | true | **[evidence]** |

Sharpness of the factor `2`: `swap 0 1` in `S₃` has `F = 2`, `inv = 1` (bound attained);
`swap 0 2` has `F = 4`, `inv = 3` (bound strict).  Recorded as `labnote_dg_sharp_fin3`.

## 5. The threshold (block) ceiling

Ceiling `3m(n−m)/(n²−1)` on the squared point-biserial correlation, at `n = 100`:

| flagged fraction `p = m/n` | ceiling on `corr²` | ceiling on `corr` |
|---|---|---|
| `0.50` | `2500/3333 ≈ 0.7500` | `≈ 0.866` |
| `0.20` | `1600/3333 ≈ 0.4800` | `≈ 0.693` |
| `0.10` | `300/1111 ≈ 0.2700` | `≈ 0.520` |

**[proved]** `pbCorrSq_le_block_ceiling`, `dial_ceiling_at_ten_percent`,
`band_floor_unreachable_at_ten_percent`.

Reading for the experiment: with a pre-registered band floor of `0.71`, a two-block
(thresholded) statistic needs `3p(1−p) ≥ 0.71²`, i.e. `p ∈ [0.216, 0.784]`.  Any operating
point outside that window is *structurally* out of band, whatever the statistic.  The
round-44 breach at `0.487` is consistent with a flagged fraction near `p ≈ 0.1`.

## 6. Counterexample hunt

* Odd values of `∑d²`: none found (and impossible — `D_even`).
* Pairs with `0 < D < 2`: none (impossible — `D_two_le_of_ne`).
* `F > D` or `D > (n−1)F`: none over `S₃`, `S₄` (impossible — `F_le_D`, `D_le_pred_mul_F`).
* `inv σ > F σ 1`: none over `S₃`–`S₆`; no counterexample to the Diaconis–Graham lower bound
  was found.
