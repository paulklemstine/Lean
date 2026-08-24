# Computational evidence for E3 (margin depth-independence)

Scope note.  The claim under test is arithmetic in nature: *what does a knee
measured with relative error `η` imply about the ratio of the margins the
mechanism assigns to two depths?*  The evidence below is the numerical content of
that map, computed exactly over the rationals, together with the two-hypothesis
separation used by the acceptance test.  Every statement quoted here is proved
in `Catalog/Computation/MarginDepthInvariance.lean`; the tables are exploratory
aids, not the verification (all verified claims are the Lean theorems).

## 1.  The band map `η ↦ [(1-η)/(1+η), (1+η)/(1-η)]`

The mechanism assigns to a knee `K` at depth `d` the margin
`m = 4·L·B·A·d·ctx / K`.  If `K` is measured within a relative tolerance `η` of
the depth-linear law `d·ctx/c`, then the depth, the context, the tail amplitude
`A` and the read-out constant `L·B` cancel out of the ratio `m(d₁)/m(d₂)`, which
is confined to `[(1-η)/(1+η), (1+η)/(1-η)]`.

| knee tolerance `η` | lower end of margin ratio | upper end |
|---|---|---|
| 0.0100 | 0.98020 | 1.02020 |
| 0.0200 | 0.96078 | 1.04082 |
| 0.03125 (= 1/32) | 0.93939 | 1.06452 |
| **0.047619 (= 1/21)** | **0.90909** | **1.10000** |
| 0.0500 | 0.90476 | 1.10526 |
| 0.1000 | 0.81818 | 1.22222 |

`η = 1/21` is the largest *simple* tolerance whose induced window still fits
inside the `±10 %` claim: the upper end is exactly `1.1` and the lower end
`10/11 ≈ 0.909 > 0.9`.  This is the constant used in
`margin_depth_independent_ten_percent`, and `ten_percent_window_sharp` exhibits
knee measurements inside the band attaining the value `1.1` exactly — so the
window cannot be tightened without tightening the knee measurement.

## 2.  Separation from the naive `1/d` expectation, under measurement noise

Reported ratio `r̂ = r·(1+e)` with `|e| ≤ 1/2` (a `±50 %` multiplicative error):

| true ratio `r` | worst-case low `r̂` | worst-case high `r̂` |
|---|---|---|
| 0.9  (mechanism, low end)  | 0.4500 | 1.3500 |
| 1.0  (mechanism, centre)   | 0.5000 | 1.5000 |
| 1.1  (mechanism, high end) | 0.5500 | 1.6500 |
| 0.25 (naive `m(16)=m(4)/4`)| 0.1250 | 0.3750 |
| 0.275 (naive, +10 %)       | 0.1375 | 0.4125 |

The two families of intervals are disjoint: everything the mechanism can produce
is `≥ 0.45`, everything the naive law can produce is `≤ 0.4125`.  The threshold
test at `0.45` is therefore correct on both sides even at `±50 %` reporting
error; this is `threshold_test_correct`.

## 3.  Power-law exponent implied by a `±10 %` flat margin

Fitting `m(d) = m₁ · d^(-α)` and using only the two depths `4` and `16`:

```
ratio m(16)/m(4) = 4^(-α)
9/10 ≤ 4^(-α) ≤ 11/10   ⟹   |α| ≤ log(10/9)/log 4
log(10/9)/log 4  = 0.07600154672252503
log(11/10)/log 4 = 0.06875176187496751
```

So a margin flat to `±10 %` pins the exponent to `|α| ≤ 0.0761`, an order of
magnitude below the naive `α = 1`.  The Lean statement
(`margin_exponent_small`) keeps the bound in closed form `log(10/9)/log 4`, so no
floating-point step enters the proof; `naive_exponent_excluded` derives `α ≠ 1`
from `log(10/9) < log 4` alone.

## 4.  Counterexample hunt

*Attempted refutation 1 — can the band theorem be vacuous?*  No: with
`L = B = A = 1`, `ctx = 128`, `c = 32` and knees measured exactly at `d·ctx/32`,
the hypotheses hold and the implied margins are all equal to `128·L·B·A = 128`.
`ten_percent_window_sharp` exhibits non-central witnesses as well, so the band
is populated at both ends.

*Attempted refutation 2 — does the sign convention hide the naive law?*  No.
`naive_quarter_scaling_refuted` shows the two are inconsistent: a measured
`m(16) = m(4)/4` cannot be produced by knees inside the `±1/21` band, since the
band forces `m(16)/m(4) ≥ 0.9` and `0.9 > 0.25`.

*Attempted refutation 3 — can a minority of broken seeds move the reported
statistic out of the band?*  No, provided fewer than half of the runs are
corrupted: `median_ratio_in_band`, via the breakdown theory of
`Catalog/Computation/MedianBreakdown.lean`.  With `2·(#corrupted) ≥ #runs` the
conclusion genuinely fails — the sharpness half of that file shows an adversary
can then place the median anywhere — so the hypothesis is not removable.

## 5.  No OEIS entry

No integer sequence arises: the objects here are real-valued tolerance bands and
one exponent bound, so an OEIS lookup is not applicable.
