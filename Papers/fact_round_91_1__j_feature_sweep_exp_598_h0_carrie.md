# Computational evidence

All numbers below were produced inside this Lean project (either by `#eval`, or
— for the arithmetic claims — by kernel `decide` proofs that are now permanent
theorems in `Catalog/Logic/JFeatureSmallCases.lean`).

## 1. Roots and adjacent double-hits of `y_v = (s+v)² − N mod q`

`#eval` over all nonzero squares `N` for `q ∈ {3,5,7,11,13,17,19,23}` (with
`s = 0`), reporting `(N, #roots, #adjacent double-hits)`:

| q | (N, #roots, #pairs) |
|---|---------------------|
| 3 | (1,2,1) |
| 5 | (1,2,0) (4,2,**1**) |
| 7 | (1,2,0) (2,2,**1**) (4,2,0) |
| 11 | (1,2,0) (3,2,**1**) (4,2,0) (5,2,0) (9,2,0) |
| 13 | (1,2,0) (3,2,0) (4,2,0) (9,2,0) (10,2,**1**) (12,2,0) |
| 17 | (1,2,0) (2,2,0) (4,2,0) (8,2,0) (9,2,0) (13,2,**1**) (15,2,0) (16,2,0) |
| 19 | (1,2,0) (4,2,0) (5,2,**1**) (6,2,0) (7,2,0) (9,2,0) (11,2,0) (16,2,0) (17,2,0) |
| 23 | (1,2,0) (2,2,0) (3,2,0) (4,2,0) (6,2,**1**) (8,2,0) (9,2,0) (12,2,0) (13,2,0) (16,2,0) (18,2,0) |

Two observations, both now proved in general:

* the root count is **always exactly 2** (`card_divSet`);
* the adjacent double-hit count is **0 for every `N` except one**, and that
  exceptional residue is precisely the solution of `4N ≡ 1 (mod q)`:
  `4·4=16≡1 (5)`, `4·2=8≡1 (7)`, `4·3=12≡1 (11)`, `4·10=40≡1 (13)`,
  `4·13=52≡1 (17)`, `4·5=20≡1 (19)`, `4·6=24≡1 (23)`
  (`four_mul_eq_one_of_adjacent`, `pairSet_eq_empty`, `pairSet_eq_singleton`).

`q = 3` is degenerate: there `4N ≡ N`, so the unique square `N = 1` is itself
exceptional — consistent with the theorem, which asserts the dichotomy for every
odd prime.

A machine-checked subset of this table is now a set of `decide` theorems
(`pairSet_card_7_1`, `pairSet_card_7_2`, `pairSet_card_11_3`, … in
`Catalog/Logic/JFeatureSmallCases.lean`), stated with the *same* definitions
used by the general theorems, so they certify non-vacuity.

## 2. No OEIS sequence involved

The relevant counting sequences are constant (`2` roots per prime) or an
indicator of the single residue `4N ≡ 1`, so no OEIS lookup is informative.

## 3. Counterexample hunt for the marginal-blindness claims

`enrich_marginal_feature_eq_one` was tested against the obvious failure mode:
its conclusion is *exactly* `1`, so any row-imbalanced hit set should break it.
It does — the hypothesis `RowBalanced H m` is load-bearing and the theorem is
stated with it. The complementary claim (`0 < m`) is also necessary: with `m = 0`
the enrichment is the Lean value `0/0 = 0`, which is why the hypothesis appears.

## 4. Extreme-value / selection-noise simulation

A deterministic LCG places hits uniformly at random among `K·cellSize`
positions; we record the largest cell count over `K = 105` cells (`#eval`,
10 seeds). The maximum cell-to-global **ratio** is `maxCount / expected`:

| setup | expected hits/cell | observed max counts | max ratio |
|---|---|---|---|
| 105 cells × 10, 105 hits | 1 | 4,4,3,4,4,3,4,3,3,7 | 3.0 – 7.0 |
| 105 cells × 1000, 10500 hits | 100 | 120,127,125,128,121 | 1.20 – 1.28 |
| 105 cells × 1022, 2730 hits | 26 | 39,39,43,37,40,43,38,37,40,43 | 1.42 – 1.65 |

The third row matches the occupancy of the reported `j mod 105` sweep cell
(`n = 1022`, 26 hits). Under **pure noise** the max-of-105 ratio already sits
around `1.5`, straddling the reported raw maximum `1.5578` and the reported null
median max `1.6334`. This is a numerical illustration — not a proof — of the two
theorems that make the inference rigorous:
`pval_maxRatio_eq_one` (the uncalibrated scan rejects always) and
`pval_ge_half_of_le_median` (an observation below the null median has `p ≥ 1/2`).

## 5. What is *not* claimed

No claim here rests on the exp598 data file itself; the dataset was not
re-analysed. The Lean development formalises the *inferential structure* of the
reported verdict and the *arithmetic* of the pre-registered follow-up study.

## Cycle 3 — the lag profile (new)

Kernel-evaluated with the same `pairSetLag` definition that the theorems in
`Catalog/Logic/JFeatureLagSpectrum.lean` are stated about.  Each row lists
`#pairSetLag k s N` for `k = 1, …, q-1` (the number of positions `v` at which
`q` divides both `y_v` and `y_{v+k}`).

| `q` | `s` | `N = r²` | profile over lags `k = 1 … q-1` | exceptional lags found |
|---|---|---|---|---|
| 13 | 0 | 1 = 1² | `[0,1,0,0,0,0,0,0,0,0,1,0]` | `k = 2, 11 = ±2·1` |
| 11 | 3 | 9 = 3² | `[0,0,0,0,1,1,0,0,0,0]` | `k = 5, 6 = ±2·3` |
| 17 | 5 | 4 = 2² | `[0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0]` | `k = 4, 13 = ±2·2` |

`#divSet = 2` in every case (`(0, 13, 1) ↦ 2`, `(5, 17, 4) ↦ 2`), so the
single-position density is `2/q` throughout and the covariance at every
non-exceptional lag is `0/q - (2/q)² = -4/q²`.

This is exactly the content of `lag_spectrum_flat` and `card_exceptionalLags`:
precisely two of the `q-1` nonzero lags are exceptional, namely `k = ±2r`, and
the profile is otherwise identically zero.  A subset of these rows is re-checked
by the kernel as `decide` theorems in `Catalog/Logic/JFeatureSmallCases.lean`.
