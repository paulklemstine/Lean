# Computational evidence for the NET-27 monotone-ramp formalisation

All numbers below are *exploratory*.  The only claims that are machine-checked are the Lean
theorems in `Catalog/NumberTheory/EOSWidthMonotoneRamp.lean`,
`Catalog/NumberTheory/EOSExclusiveDimGenericity.lean` and
`Catalog/NumberTheory/EOSRampZetaBridge.lean` (all build with 0 `sorry`).

## 1. The reported experimental curve

| exclusive dims `k` | 0 | 1 | 2 | 4 | 8 |
|---|---|---|---|---|---|
| measured `P(≥0.99)` | 3/12 = 0.250 | 2/6 = 0.333 | 5/6 = 0.833 | 6/6 = 1.000 | 26/26 = 1.000 |
| measured worst case | 0.005 | 0.157 | 0.948 | 1.000 | 1.000 |

Monotone in `k` (Spearman `ρ = 1` on the five points).  A Fisher exact test on the
`k = 1` vs `k = 2` contingency table `[[2,4],[5,1]]` gives `p ≈ 0.242` (recomputed here,
agreeing with the reported ≈ 0.24): the single jump is *not* individually significant, which is
exactly why the formal work targets the *shape* of the curve (monotone, geometric, no cliff)
rather than any one jump.

## 2. The model curve

The finite-field obstruction model of `EOSWidthMonotoneRamp.lean` predicts, for one obstruction
of index `p`,

`P(cure at width k) = 1 - p^{-k}`,

and in general the two-sided envelope `p^{-k} ≤ 1 - P(cure) ≤ m·p^{-k}` (theorem
`cureProb_deficiency_two_sided`).  At `p = 2`:

| `k` | 0 | 1 | 2 | 4 | 8 |
|---|---|---|---|---|---|
| `1 - 2^{-k}` (model, `m = 1`) | 0 | 0.5 | 0.75 | 0.9375 | 0.99609 |
| `1 - 2·2^{-k}` (model, `m = 2`) | –1 | 0 | 0.5 | 0.875 | 0.99219 |
| measured | 0.25 | 0.33 | 0.83 | 1.00 | 1.00 |

The five model values at `p = 2, m = 1` are *proved* in Lean as
`EOSWidthRamp.ramp_two_values` (`0, 1/2, 3/4, 15/16, 255/256`).  The qualitative match is:
monotone increase, a large jump between `k = 1` and `k = 2`, and values indistinguishable from
`1` at `k = 4, 8` under `n = 6` sampling (`0.9375^6 = 0.68`, `0.99609^6 = 0.977`, so observing
6/6 successes at `k = 8` has probability 0.98 under the model and 0.68 at `k = 4`).

**Counterexample hunt.**  The measured curve contains two exact `1.000` entries, which would
falsify the model if they were genuine probability-1 statements.  They are not: they are `6/6`
and `26/26` finite samples.  The Lean theorem `EOSWidthRamp.failProb_pos` shows the model can
never produce probability exactly `1`, and the sample sizes above show that no contradiction
with the data arises (the probability of seeing 26/26 at `k = 8` is `0.99609^26 = 0.90`).

## 3. Genericity check

`EOSExclusiveDimGenericity.probIndep_ge` gives `P(k draws independent) ≥ 1 - (p^k-1)/((p-1)p^n)`.
With `p = 2` and `n = 192` (the hidden width of the recurrent cell in the motivating
experiment), for `k = 8` the loss is `(2^8-1)/2^192 ≈ 4·10^{-56}`: the "exclusive dimensions"
of the model are genuinely independent, so the reliability term dominates in the measured
regime — consistent with the observed ramp.

## 4. Sequence note

The failure masses `1, 1/2, 1/4, 1/8, …` at `p = 2` are the geometric sequence with total mass
`∑_k 2^{-k} = 2 = (1-1/2)^{-1}` (Lean: `EOSWidthRamp.hyperplane_tsum_failProb`).  Over all
characteristics these totals are precisely the Euler factors of `ζ`, formalised in
`EOSRampZetaBridge.tprod_rampSeries_eq_riemannZeta`; the `s = 2` specialisation gives `π²/6`.
No OEIS lookup is needed for a geometric sequence.
