# Computational evidence (exploratory) — binning-independence of a mid-window hump

*Status of this file: **exploratory numerics**, produced with double-precision quadrature
in a scratch script.  Nothing here is a verified result.  Every claim that this cycle
actually asserts is proved in Lean in `Catalog/Computation/BinwidthUShiftProbe.lean` and
`Catalog/Computation/BinwidthUShiftShapeTest.lean` (0 sorries, standard axioms only).*

## 1. Purpose

Exp 582 ran a 6 × 5 grid (bin widths `nb ∈ {10,20,33,50,66,100}` × circular `u`-grid
shifts `sh ∈ {-0.25 … +0.25}`) on a ratio curve `R = T/M` and reported

* a raw-max hump in 30/30 cells,
* an **absolute** vertex `vx + sh` pinned to `0.6482–0.6492`,
* one erratic `nb = 33` local-quadratic fit (vertex off by 0.19),
* three control cells breaching a flat `1.02` bar at `1.0215–1.0305`.

Before formalising, we replayed the *same grid geometry* on a synthetic curve whose
peak location is known exactly, to check which of those four observations are forced by
the geometry of binning (and hence provable) and which are contingent on the data.

## 2. Test curve and grid

`f(u) = 1 + 0.26 · exp(−(u − 0.65)² / (2 · 0.09²))` on `[0,1]`, true peak `u* = 0.65`,
bin averages computed by 4000-point midpoint quadrature per bin, grid offset
`o = −sh·w` with `w = 1/nb` (exactly the circular-shift convention of the experiment).

| nb | sh | raw max | argmax bin centre | \|centre − u*\| |
|---|---|---|---|---|
| 10 | −0.250 | 1.23877 | 0.67500 | 0.02500 |
| 10 | +0.000 | 1.24722 | 0.65000 | 0.00000 |
| 10 | +0.250 | 1.23877 | 0.62500 | 0.02500 |
| 20 | −0.250 | 1.25429 | 0.63750 | 0.01250 |
| 20 | +0.250 | 1.25429 | 0.66250 | 0.01250 |
| 33 | +0.000 | 1.25874 | 0.65152 | 0.00152 |
| 33 | +0.250 | 1.25820 | 0.64394 | 0.00606 |
| 50 | +0.000 | 1.25947 | 0.65000 | 0.00000 |
| 66 | +0.125 | 1.25887 | 0.65720 | 0.00720 |
| 100 | −0.250 | 1.25977 | 0.64750 | 0.00250 |
| 100 | +0.250 | 1.25977 | 0.65250 | 0.00250 |

(30 cells run; a representative subset is shown.)

Aggregates over all 30 cells:

* raw max range `1.23877 – 1.25977` (spread `0.021`, i.e. `≈ 1.7 %`) — hump in 30/30;
* `max |argmax bin centre − u*| = 0.025`, against the coarsest half-bin `w/2 = 0.05`;
* the bound is saturated only at `nb = 10`, and shrinks like `O(w)` thereafter.

**Reading.** Both "hump present in every cell" and "absolute vertex pinned" are
reproduced *by a curve with a single genuine peak*, i.e. they are the expected
signature of a real feature rather than of a binning artefact.  This is what motivated
proving them as theorems rather than testing them further:

* the persistence direction is `hump_certifies_peak` (a bin average `≥ c` forces
  `f ≥ c` somewhere) — binning can only flatten a hump;
* the vertex-pinning direction is `argmax_bin_near_peak`, whose bound
  `w/2 + (L/κ)·w` is offset-free, and, under symmetry, the exact
  `closest_bin_dominates`.

## 3. Closed-form check of the binning deflation

For `f(s) = c − k(s − u*)²` the box average has the exact closed form
`c − k((x − u*)² + w²/12)` (`slidingAvg_quadratic`).  Numerical check with
`c = 1, k = 3`:

| w | quadrature | `c − k w²/12` |
|---|---|---|
| 0.10 | 0.9975000002 | 0.9975000000 |
| 0.02 | 0.9999000000 | 0.9999000000 |
| 0.01 | 0.9999750000 | 0.9999750000 |

So the *only* effect of the bin width on a parabolic hump is a deterministic amplitude
deflation `k w² / 12`; the vertex does not move at all.  This is the quantitative form
of "estimator stricter than phenomenon": at `nb = 10` a curvature `k` deflates the
apparent amplitude by `k/1200`, and a fixed amplitude bar such as `≥ 1.10` therefore
tests a *different* quantity at each bin width.

## 4. Control bars

The three control breaches at `1.0215–1.0305` are compared with the two candidate
ceilings.  With `n` bins and a per-bin exceedance probability `p`, the probability that
*some* bin breaches a flat bar is `1 − (1 − p)ⁿ`:

| n | p = 0.001 | p = 0.005 |
|---|---|---|
| 10 | 0.00996 | 0.04889 |
| 50 | 0.04879 | 0.22170 |
| 100 | 0.09521 | 0.39421 |

i.e. a flat bar loses control monotonically in `n`, which is exactly why only the
`nb ∈ {50, 66, 100}` cells breached.  Formalised as
`fwer_flat_threshold_tendsto_one` (the breach probability tends to 1) and
`fwer_aware_threshold_controlled` (the `α/n` bar keeps it `≤ α`).

## 5. Counterexample hunt

We looked for a curve with **no** peak whose histogram nonetheless shows a raw-max
hump above the flat bar for some offset.  None exists for the *exact* bin-average
convention: `binAvg f a w ≤ max_{[a,a+w]} f` is an inequality, not an approximation, so
a raw-max hump of height `c` is a certificate that `f ≥ c` somewhere.  Any apparent
counterexample must come from a *counting* (multinomial) fluctuation rather than from
the averaging operator — which is precisely the control-bar issue of §4, and is why the
mechanical ARTIFACT-CONTAMINATED string is not evidentially binding here.

No OEIS sequence arises (all quantities here are real-analytic, not integer sequences).
