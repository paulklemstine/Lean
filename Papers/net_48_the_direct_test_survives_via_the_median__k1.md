# Computational evidence — NET-48 seed-ensemble rung theory

All numbers below were computed in exact rational arithmetic (Python `fractions`) *before*
the Lean proofs were written, and every claim they support is now a `sorry`-free theorem in
`Catalog/Probability/`.  The Lean statements, not this file, are the certified artefacts.

## 1.  The calibration table (coin-flip seeds, `p = 1/2`)

`rungProb n m (1/2)` = probability that at least `m` of `n` coin-flip seeds pass.
Rows `n = 1 … 8`, entries `m = 0 … n+1`:

| `n` | rung values `m = 0,1,…,n+1` | rungs equal to `1/2` |
|---|---|---|
| 1 | 1, **1/2**, 0 | `m = 1` |
| 2 | 1, 3/4, 1/4, 0 | none |
| 3 | 1, 7/8, **1/2**, 1/8, 0 | `m = 2` |
| 4 | 1, 15/16, 11/16, 5/16, 1/16, 0 | none |
| 5 | 1, 31/32, 13/16, **1/2**, 3/16, 1/32, 0 | `m = 3` |
| 6 | 1, 63/64, 57/64, 21/32, 11/32, 7/64, 1/64, 0 | none |
| 7 | 1, 127/128, 15/16, 99/128, **1/2**, 29/128, 1/16, 1/128, 0 | `m = 4` |
| 8 | 1, 255/256, 247/256, 219/256, 163/256, 93/256, 37/256, 9/256, 1/256, 0 | none |

Observed pattern: a calibrated rung exists exactly for odd `n`, and then only at
`m = (n+1)/2`.  Formalised as `SeedQuota.rungProb_half_eq_iff`,
`SeedQuota.exists_calibrated_rung_iff_odd`, `SeedQuota.even_no_calibrated_rung`,
`SeedQuota.calibrated_rung_unique`.

**Counterexample hunt.**  All `n ≤ 200` and all `0 ≤ m ≤ n+1` were swept in exact
arithmetic (testing `2·tailCount n m = 2^n`).  Zero anomalies: no even ensemble has a calibrated
rung, and every odd ensemble has exactly one, at `2m = n+1`.

## 2.  The calibration defect of an even ensemble

`defect r = C(2r,r)/2^(2r+1)` — the distance of either central rung of a `2r`-seed ensemble
from `1/2`.  Central binomial coefficients `C(2r,r) = 1, 2, 6, 20, 70, 252, 924, …` are
OEIS **A000984**.

| `r` | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| `defect r` | 1/2 | 1/4 | **3/16** | 5/32 | 35/256 | 63/512 | 231/2048 |
| decimal | 0.5000 | 0.2500 | 0.1875 | 0.1563 | 0.1367 | 0.1230 | 0.1128 |

Further out: `defect 10 = 0.0881`, `defect 50 = 0.0398`, `defect 200 = 0.0199` — the decay is
visibly `~ r^{-1/2}` (halving `defect` needs quadrupling `r`).

The four-seed defect `3/16` is exactly the offset of the measured pair `11/16, 5/16`;
strict decrease and the `r^{-1/2}` decay are `SeedQuota.defect_strictAnti` and
`SeedQuota.defect_tendsto_zero` (through `SeedQuota.centralBinom_sq_mul_le`, checked
numerically for `0 ≤ r ≤ 2000`: `C(2r,r)^2 (3r+1) ≤ 16^r` holds throughout, with maximum
ratio `1.0` attained at `r = 0`, so the constant `3` in `3r+1` cannot be improved at the
base point).

## 3.  The Condorcet ladder at the measured frequency `p = 2/3`

`p = 2/3` is the NET-48 six-seed frequency of landing at or below the `7/8` budget.

| ensemble `n = 2s+1` | 3 | 5 | 7 | 9 | 11 | 13 |
|---|---|---|---|---|---|---|
| median rung | 20/27 | 64/81 | 1808/2187 | 16832/19683 | 640/729 | 476416/531441 |
| decimal | 0.7407 | 0.7901 | 0.8267 | 0.8552 | 0.8779 | 0.8965 |

Strictly increasing, as `SeedCondorcet.condorcet_ladder_strict` requires; the three-seed
value `20/27` reproduces `KneeAmplify.net48_amplification_example`.

## 4.  The rate bound versus the true miss probability (`p = 2/3`)

Bound: `2(1-p)(4p(1-p))^r = (2/3)·(8/9)^r`.

| `r` | 1 | 5 | 10 | 20 | 35 | 36 |
|---|---|---|---|---|---|---|
| true `1 - rung` | 0.2593 | 0.1221 | 0.0557 | 0.0135 | 0.00185 | 0.00163 |
| bound | 0.5926 | 0.3700 | 0.2053 | 0.0632 | 0.01080 | 0.00960 |
| bound `≤ 1/100`? | no | no | no | no | **no** | **yes** |

So the bound first certifies `1 %` at `r = 36`, i.e. `73` seeds
(`SeedCondorcetRate.net48_seeds_for_one_percent`,
`SeedCondorcetRate.net48_thirty_five_insufficient`).  The true miss probability reaches
`1 %` already at `r = 23` (`n = 47` seeds), so the elementary bound costs roughly a factor
`1.55` in seed count — an honest gap recorded in `FUTURE_DIRECTIONS.md` (conjecture C3).

## 5.  Breakdown numbers (integer check)

`breakdownNumber n m = min (m-1, n-m)`, the two-sided corruption tolerance of the `m`-th
rung, computed for small ensembles:

| `n \ m` | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| 3 | 0 | **1** | 0 | | |
| 4 | 0 | 1 | 1 | 0 | |
| 5 | 0 | 1 | **2** | 1 | 0 |

Unique maximiser for odd `n` (at `2m = n+1`, the calibrated rung), two maximisers for even
`n` — the integer shadow of the same parity obstruction
(`SeedBreakdown.calibrated_iff_maximally_robust`, `SeedBreakdown.even_no_unique_centre`).

## 6.  What the evidence does *not* show

Nothing here validates the empirical `7/8`-median law itself; that law's status is the
three-seed knee set `{160, 224, 256}` and its `ctx = 1024` counterpart `{96, 112, 128}`, as
recorded in `Logic.KneeMedianLaw`.  This file's numbers concern only the *reading rule* — how
a centre of a seed ensemble behaves as a statistic — which is what the planned fourth seed
puts at stake.

---

# Cycle 3 evidence — the fourth seed, the ladder sum, the sharpened rate

Same protocol: exact rational arithmetic first, Lean proofs after.  Every claim below is now
a `sorry`-free theorem in `Catalog/Probability/`.

## 7.  The four-seed reading as a function of the fourth seed (closes C1)

Four-seed reading = mean of the two central order statistics of `{256, 224, 160, x}`
(`quotaBudget` rungs 2 and 3 of `KneeQuota.knees16four`):

| fourth seed `x` | ≤ 160 | 176 | 192 | 208 | **224** | 240 | 256 | ≥ 256 |
|---|---|---|---|---|---|---|---|---|
| reading | 192 | 200 | 208 | 216 | **224** | 232 | 240 | 240 |
| bias from `224` | 32 | 24 | 16 | 8 | **0** | 8 | 16 | 16 |

A strict V with a unique zero at `x = 224`, half-step slope on both arms, flat at `32` below
`160` and at `16` above `256`; `bias ≤ 16 ⟺ x ≥ 192`.  Formalised as
`SeedFourMedian.bias_eq_zero_iff`, `bias_le_sixteen_iff`, `bias_eq_thirtytwo_iff`,
`bias_strictAnti_low`, `bias_strictMono_high`.

## 8.  The ladder sum and the generating function (closes C4)

Partial ladder sums `∑_{r<R} gap(2/3, r)` (exact):

| `R` | 1 | 2 | 3 | 5 | 10 | 20 | → ∞ |
|---|---|---|---|---|---|---|---|
| partial sum | 2/27 | 0.1235 | 0.1600 | 0.2112 | 0.2776 | 0.3198 | **1/3** |

The limit is exactly `1 - p = 1/3` (`SeedLadderGF.tsum_gap`).  Substituting
`p = (1+√(1-4x))/2` turns this into the central binomial identity
`∑_{r≥0} C(2r+1,r) x^{r+1} = (1/2)(1/√(1-4x) - 1)` for `0 < x < 1/4`
(`SeedLadderGF.hasSum_centralBinomOdd`); at the measured frequency `x = p(1-p) = 2/9` the
series is exactly `1` (`SeedLadderGF.net48_generating_function`).  Coefficients
`C(2r+1,r) = 1, 3, 10, 35, 126, …` are OEIS **A001700**.

## 9.  The sharpened rate and the exact crossing (closes C3, upper half)

Sharpened bound `C(2r+1,r)(p(1-p))^{r+1}/(2p-1)` at `p = 2/3`, versus the crude bound and the
truth:

| seeds `n = 2r+1` | 43 | 45 | **47** | **49** | 73 |
|---|---|---|---|---|---|
| true miss | 0.01180 | 0.01030 | **0.00900** | 0.00787 | 0.00163 |
| sharpened bound | 0.01344 | 0.01169 | 0.01017 | **0.00886** | 0.00178 |
| crude bound | 0.05620 | 0.04995 | 0.04440 | 0.03947 | 0.00960 |

So the truth crosses `1 %` at `47` seeds, the sharpened bound at `49`, the crude bound only at
`73`.  All three readings are now Lean theorems: `SeedExactCrossing.miss_47_le_one_percent`
and `miss_45_gt_one_percent` (exact tails, binomials evaluated through
`Nat.choose_eq_descFactorial_div_factorial`), `SeedSharpRate.net48_sharp_49_seeds` and
`net48_sharp_47_insufficient`, `SeedCondorcetRate.net48_seeds_for_one_percent`.

## 10.  Counterexample hunt against conjecture C5 (refuted)

C5 predicted `risk(2r) < risk(2r+1)` at the upper central rung.  Exact values at `p = 2/3`:

| reading | `n = 2` at `m = 2` | `n = 3` at `m = 2` | `n = 4` at `m = 3` | `n = 5` at `m = 3` |
|---|---|---|---|---|
| rung | 4/9 | 20/27 | 16/27 | 64/81 |
| risk | 0.5556 | **0.2593** | 0.4074 | **0.2099** |

Every even ensemble read at its upper central rung is riskier than the odd ensemble one seed
larger, at every size tested (`r < 60`, exact arithmetic), and the excess is exactly
`p·C(2r,r)p^r(1-p)^r` — proved in `SeedRisk.odd_median_sub_even_upper` and
`SeedRisk.even_upper_central_strictly_riskier`, with the numerical instance in
`SeedRisk.net48_C5_counterexample`.

## 11.  The central binomial sandwich and the defect rate (cycle 4, D1 structural half)

Both halves of the sandwich `C(2r,r)^2(3r+1) ≤ 16^r ≤ C(2r,r)^2(4r+1)` were checked in exact
integer arithmetic for every `r < 400` (no failures).  The slack of the *lower* half is exactly
`0` at `r = 0` and then grows (`4, 68, 1104, 17764, 285008` at `r = 1..5`), which is what makes
the induction close with the constant `4`:

| `r` | 1 | 2 | 5 | 10 | 50 | 200 | 1000 | limit |
|---|---|---|---|---|---|---|---|---|
| `defect r · √r` | 0.25000 | 0.26517 | 0.27514 | 0.27859 | 0.28139 | 0.28192 | 0.28206 | `1/(2√π) = 0.28209` |

The proved window is `[1/(2√5), 1/(2√3)] = [0.22361, 0.28868]`; it contains the Wallis limit
`0.28209` but does not identify it — the gap that conjecture **E1** targets.  Formalised as
`SeedStirling.centralBinom_sq_mul_ge` and `SeedStirling.defect_sqrt_bracket`.

## 12.  Why `47` is out of reach of the sharpened route (cycle 4, D1 numerical half — refuted)

Exact rationals at `p = 2/3`, `r = 23` (i.e. `47` seeds):

| quantity | value | `< 1/100`? |
|---|---|---|
| true miss `1 - rungProb 47 24 (2/3)` | 0.0090029 | **yes** |
| sharpened rate `C(47,23)(p(1-p))^{24}/(2p-1)` | 0.0101739 | **no** |
| sharpened rate at `49` seeds | 0.0088626 | yes |

So the sharpened rate is already above `1 %` at `47`: *any* bound dominating it fails there,
whatever Stirling estimate is fed in.  The loss is `0.0101739 / 0.0090029 = 1.130`, i.e. the
`13 %` overshoot of the geometric majorant over the true tail — a `Θ(1/r)` effect, which is
conjecture **E2**.  Formalised as `SeedStirling.no_sharp_route_certifies_47` and
`truth_at_47_below_one_percent`.

## 13.  The off-centre ladder sums (cycle 4, D3)

Partial sums `∑_{k ≤ r < 60} offsetGap k (2/3) r` in exact arithmetic, against the closed form
`1 - p^{2k+1}`:

| offset `k` | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| partial sum (`r < 60`) | 0.333256 | 0.703544 | 0.867995 | 0.940857 |
| closed form `1 - (2/3)^{2k+1}` | 0.333333 | 0.703704 | 0.868313 | 0.941472 |

Convergence is geometric and the residuals are exactly the omitted tail.  Note that the
off-centre steps are *not* dominated by the median step: the step ratio
`offsetGap k p r / offsetGap k p (r-1)` exceeds `1` well off the centre (maximum `2.872` found
at `r = 11, k = 10, p = 0.55` over `r ≤ 11`, `k < r`, `p ∈ {0.55, …, 0.95}`), whereas at the
centre it is always below `1` (`0.667, 0.741, 0.778, 0.800, 0.815` for `r = 1..5` at `p = 2/3`).
This is why the off-centre convergence needed its own bound
(`SeedOffsetLadder.offset_tail_bound`) rather than the median argument.  Closed form:
`SeedOffsetLadder.hasSum_offsetGap`.

## 14.  The quota threshold law (cycle 4, D5)

Brute-force check of the ascent criterion `rungProb n (m+1) p ≤ rungProb (n+2) (m+2) p ⟺
(1-p)(n+1) ≤ m+1` over all `1 ≤ n ≤ 13`, `0 ≤ m < n`, `p ∈ {1/20, …, 19/20}` (exact rationals):
**0 mismatches** out of 2223 cases.  Formalised as `SeedThreshold.ladder_ascends_iff`; the
median specialisation is the Condorcet condition `p ≥ 1/2`, and NET-48's own `3/3` guarantee
rung ascends already at `p ≥ 1/4` (`net48_unanimity_threshold`).

The hypothesis `m ≤ n` in `SeedThreshold.rate_sharp_general` is necessary: for `m ≥ n+2` the
rung is empty, so the left side is `1`, while the right side can drop below it — the smallest
instance is `n = 0, m = 3, p = 13/20`, where the right side is `0.9154`.

## 15.  The contamination curve on the round's own sample (cycle 4, D2)

Clean sample `K = {160, 224, 256}` (the three measured `16×` knees), `n = 3`:

| rung `m` | 1 | 2 (median) | 3 (the `3/3` guarantee) |
|---|---|---|---|
| clean reading `quotaBudget K m` | 160 | **224** | 256 |
| breakdown number `min(m-1, n-m)` | 0 | **1** | 0 |
| reachable set at `c = 1` | — | `[160, 256]` | unbounded above |

At the last level before breakdown the median can be pushed to either end of the clean spread
and no further — both endpoints attained, which is the content of
`SeedContamination.contamination_curve`; the guarantee rung, with breakdown number `0`, can be
pushed above *any* prescribed budget by a single corrupted seed
(`SeedContamination.net48_guarantee_fragile`).

## 16.  How often does the median minimise the contamination width? (cycle 5, E4/E6)

Monte-Carlo over i.i.d. samples of `n` seeds (`200 000` draws per cell, radius `c = 1`, rungs
restricted to those with a nonempty contamination curve, i.e. `2 ≤ m ≤ n-1`), for the standard
normal (symmetric unimodal, mode = median):

| `n` | 5 | 7 | 9 | 11 |
|---|---|---|---|---|
| mean width at the median rung | **0.992** | **0.707** | **0.548** | **0.449** |
| mean width at an extreme admissible rung (`m = 2`) | 1.164 | 1.000 | 0.913 | 0.858 |
| P(median minimises the *realised* width) | 0.346 | 0.253 | 0.191 | 0.153 |
| P(ladder is centre-minimal) | 0.243 | 0.028 | 0.0019 | 0.0001 |

Three readings, all of which shaped cycle 5 and conjecture **E6**.

* The **mean** width profile is exactly V-shaped and minimised at the median in every cell —
  E6(1).
* The **realised** width is minimised at the median only about a third of the time at `n = 5`,
  and the frequency *decreases* with `n` — so E4's original "for every sample" was not merely
  unlucky in one adversarial example, it fails for a constant fraction of typical draws (this
  is what turned E4 from a target into a refutation, `SeedWindow.median_not_always_narrowest`).
* **Centre-minimality**, the sufficient condition of `SeedWindow.width_median_minimal`, is a
  prescribed ordering of the realised spacings, and its probability collapses (`0.24 → 0.0001`
  from `n = 5` to `n = 11`) — strictly rarer than the median winning, which is E6(3).  This
  measurement is also what forced the hypothesis to be stated with a *strict* distance
  comparison: demanding equality of two equidistant gaps would make it fail almost surely for
  a continuous law, and the induction never needs such a comparison.

For an asymmetric law the median loses even in the mean, exactly as the mechanism predicts:
for the half-normal `|N(0,1)|` (mode at the boundary) the mean widths at `n = 9` are
`0.266, 0.281, 0.303, 0.337, 0.393, 0.496, 0.746` for `m = 2, …, 8` — minimised at the
*lowest* rung, the one sitting at the mode.  The minimiser follows the density, not the centre.

The deterministic instances used in the Lean file are exact: the straggler sample
`![0,0,0,10,20]` has ladder `0,0,0,10,20`, median window width `10` and second-rung window
width `0`; the centre-minimal ladder `0,6,10,12,14,18` has gaps `6,4,2,2,4` and window widths
`10, 6, 4, 6` at `m = 1,2,3,4`, minimised at the median `m = 3`.

## 17.  The Wallis constant, numerically (cycle 6, E1 limit half)

The quantity now proved to converge, `defect r · √r`, against its identified limit
`1/(2√π) = 0.2820948`:

| `r` | 1 | 2 | 5 | 10 | 50 | 200 | 1000 | 10000 |
|---|---|---|---|---|---|---|---|---|
| `defect r · √r` | 0.25000 | 0.26517 | 0.27514 | 0.27859 | 0.28139 | 0.28192 | 0.28206 | 0.282088 |
| relative error | 11.4 % | 6.0 % | 2.5 % | 1.24 % | 0.249 % | 0.0624 % | 0.0125 % | 0.00125 % |

The relative error is visibly `≈ 1/(8r)`, which is the effective two-sided form that the
restated **E1** now targets; the approach is monotone from below, consistent with the proved
lower bound `1/(2√(4r+1))` being the tighter of cycle 4's two ends near the limit.
