# Computational evidence — NET-44 knee analysis

All numbers below are **checked inside Lean** (kernel-evaluated `ℚ` arithmetic, `decide`
or `norm_num`; no `native_decide`) in `Catalog/Logic/KneeFluctuationEvidence.lean`.
Nothing here was computed only in a scratch script.

## 1. The measured sweeps

Cell `(d = 4, ctx = 1024)`, bar `= 0.98` of full accuracy.

| budget `k` | 64 | 96 | 112 | 128 | 768 |
|---|---|---|---|---|---|
| retained, seed 1 (NET-37) | 0.968 | 0.977 | — | 0.986 | 1.000 |
| retained, seed 2 (NET-44) | 0.979 | 0.987 | 0.991 | 0.993 | 1.000 |

Verified in Lean:

* `KneeEvidence.knee_s1 : kneeOf sweepS1 = some 128`
* `KneeEvidence.knee_s2 : kneeOf sweepS2 = some 96`

`kneeOf` is the first budget in the (increasing) sweep whose retained accuracy reaches
the bar, i.e. exactly the `IsKnee` predicate of `Catalog/Logic/KneeFluctuationTwoSeed.lean`
restricted to the measured points.

## 2. Margin table — why one end of the bracket is lucky and the other is not

| budget | seed-1 value | signed margin `c(k) − bar` | vs. spread `0.010` |
|---|---|---|---|
| 64 | 0.968 | −0.012 | deficit **exceeds** spread → protected |
| 96 | 0.977 | −0.003 | deficit **inside** spread → unprotected |
| 128 | 0.986 | +0.006 | pass margin inside spread |

Verified in Lean: `KneeEvidence.margin_s1_96_lt_spread`,
`KneeEvidence.deficit_s1_64_gt_spread`.

This is the whole content of the "seed-luck" reading, and it matches the robustness
criterion proved abstractly as `KneeFluctuation.robustKnee_iff`: a knee claim is
`η`-robust iff the bar is cleared by `≥ η` at the knee and missed by `> η` below it.
At `η = 0.010` the seed-1 sweep fails the second condition at `k = 96`.

## 3. Counterexample hunt (the perturbation that breaks the exact law)

Shifting the entire seed-1 curve by the observed inter-seed spread `+0.010` gives
`0.978 / 0.987 / 0.996` at `64 / 96 / 128`; this reproduces the *actual* seed-2 numbers
`0.979 / 0.987 / 0.993` to within `0.003` (to within `0.001` at `64` and `96`), and its
knee is `96`.

Verified in Lean: `KneeEvidence.knee_s1_shifted`, `KneeEvidence.shift_matches_s2`, and
the abstract version `KneeFluctuation.net44_seed1_admits_knee_96_perturbation`.

So the counterexample to "the seed-1 sweep certifies `k* = 128`" is explicit, and it is
essentially the observed seed-2 curve.

## 4. Grid quantisation

Sweep step `32`; `96 = 32·3`, `128 = 32·4`. A reported grid knee `q` means a true knee in
`(q − 32, q]`, so the two seeds' true knees lie in the **disjoint** windows `(64, 96]`
and `(96, 128]` (`KneeLaw.net44_true_knee_windows`). Conversely,
`KneeFluctuation.oneStepFluctuation` shows that for any `ε > 0` there are true knees
within `ε` of one another reporting `96` and `128` — one-step fluctuations are cheap.

## 5. Doubling chain

`16, 32, 64, 128` at `ctx = 128, 256, 512, 1024` is exactly `ctx/8 = d·ctx/32` at
`d = 4`. Under the exact doubling relation `f(2n) = 2f(n)` with anchor `f(128) = 16`, the
value `f(1024) = 128` is *forced* (`KneeLaw.doubling_chain_law`,
`KneeLaw.chain_predicts_128`). Without that relation, the three measured points plus
monotonicity are compatible with **every** value `> 64` at `ctx = 1024`
(`KneeLaw.chain_extension_underdetermined`). No OEIS sequence is involved; the chain is
the geometric sequence `16·2^m`.

## 6. Speedups

`1024/128 = 8`, `1024/96 = 32/3 ≈ 10.67`, ratio `4/3` (`KneeEnsemble.net44_waste_ratio`).
The bracket `(64, 128]` gives the speedup window `[8, 16)`
(`KneeFluctuation.net44_speedup_bracket`).
