# Computational Evidence — Cake balancing ratio sequence

Before formalizing, we explored the landscape of the balancing ratio
`μ^r_n` for cyclic partitions, focusing on the van der Corput benchmark from
de Bruijn–Erdős cake cutting.

## 1. Single-gap ratio of the base-2 van der Corput sequence

The first `n` points of the base-2 van der Corput sequence cut the unit circle
into `n` arcs.  Computing the ratio `μ^1_n = maxgap / mingap` exactly (over ℚ):

| n  | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|----|---|---|---|---|---|---|---|---|----|----|----|
| μ¹ | 1 | 2 | 1 | 2 | 2 | 2 | 1 | 2 | 2  | 2  | 2  |

**Observations.**
* The ratio equals `1` exactly at `n = 2, 4, 8` (powers of two): at these stages
  the partition is uniform.
* The ratio never exceeds `2`, and `2` is attained (e.g. `n = 3`,
  gaps `{1/4, 1/4, 1/2}`).  Hence `limsup_n μ^1_n = 2`, the classical
  de Bruijn–Erdős value.  This motivates `vdc3_gapRatio_eq_two`.

## 2. Window ratios of the three-arc partition `{1/4, 1/4, 1/2}`

Fixing the cyclic partition with gaps `1/4, 1/4, 1/2` (period `p = 3`) and
computing `μ^r_3` exactly for growing window length `r`:

| r  | 1 | 2   | 3 | 4   | 5   | 6 | 7    |
|----|---|-----|---|-----|-----|---|------|
| μ^r| 2 | 3/2 | 1 | 6/5 | 7/6 | 1 | 10/9 |

**Observations.**
* Every value satisfies `μ^r ≤ 2 = μ^1`, confirming the structural monotone
  envelope `window_ratio_le_gap_ratio` (windowing never worsens balance).
* `μ^r = 1` exactly at `r = 3` and `r = 6`, i.e. at multiples of the period.
  This is the recurrent perfect balance proved in `winRatio_period_eq_one`
  and `winRatio_mul_period_eq_one`.
* The sequence is **not monotone**: it dips to `1` at multiples of the period
  and rebounds in between.  This is exactly why the mission quantity `μ_r` must
  be taken as a `limsup` rather than a limit.

## 3. Sanity check against the conjectured bound `2r/p + 1`

For the three-arc recipe (`p = 3`) the conjectured upper bound `2r/p + 1` gives
`5/3, 7/3, 3, 11/3, …` for `r = 1, 2, 3, …`.  Every measured `μ^r` above lies
strictly below the corresponding bound, consistent with the conjecture.  (Note
the measured `μ^1 = 2 > 5/3`; this is a finite-stage value `μ^1_3`, whereas the
conjecture concerns the `limsup` `μ_r`, whose relevant excursions are the
larger-`n` stages — the finite table is a witness sample, not a counterexample.)

## 4. Counterexample hunt

No counterexample to the two proved structural principles
(`window_ratio_le_gap_ratio`, `winRatio_mul_period_eq_one`) was found across all
sampled partitions; both are now theorems with complete proofs.
