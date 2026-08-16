# Computational evidence — NET-45 (d = 4, ctx = 2048, seed 1)

All numbers below are recomputed as **exact rationals** and machine-checked in
`Catalog/Logic/KneeMarginChainEvidence.lean` (namespace `KneeMarginEvidence`), plus the
real-valued statements in `Catalog/Logic/KneeMarginChain.lean`. Nothing here relies on
`native_decide`; every check is `norm_num` / `decide` on exact arithmetic.

## 1. The sweep and its knee

| `k`   | 96   | 128  | 160  | 192  | 224  | **256**  | 288  | 384  | 512  | 768  | 1024 |
|-------|------|------|------|------|------|----------|------|------|------|------|------|
| ret.  | .939 | .951 | .963 | .970 | .976 | **.9813**| .984 | .993 | .997 | .996 | .998 |
| pass  | ✗    | ✗    | ✗    | ✗    | ✗    | **✓**    | ✓    | ✓    | ✓    | ✓    | ✓    |

* knee `= 256 = d·ctx/32` — `KneeMarginEvidence.knee_net45`, and, as a statement about an
  arbitrary curve realising the measurement, `KneeMarginChain.net45_knee`;
* margin at the knee `0.9813 − 0.98 = 0.0013` (`margin_256`);
* deficit at the preceding grid point `0.98 − 0.976 = 0.004` (`deficit_224`).

## 2. Counterexample hunt inside the round's own data

Two claims of the round fail on its own numbers:

1. **The retained curve is not monotone.** `c(512) = 0.997 > 0.996 = c(768)`
   (`KneeMarginEvidence.curve_dips`, `KneeMarginChain.net45_curve_not_monotone`). This is
   the first dip in the programme; every earlier file assumed monotonicity. The knee
   reading survives (`IsKnee` never uses monotonicity), the robustness criterion does not
   — which is why the perturbations in `KneeMarginChain` are built by hand from explicit
   monotone envelopes (`envUp`, `envDown`).

2. **The reported speedup at the alternative reading is wrong.** `2048/224 = 64/7 ≈ 9.14`,
   not the reported `10.3` (`speedups_rational`,
   `KneeMarginChain.net45_reported_speedup_at_224_is_inconsistent`). The reported `8.0×`
   at the knee is correct.

A third tension, in the concentration numbers: the reported effective support `526.39`
is **not** compatible with the reported top-`k` masses if `N_eff` is read as the inverse
participation ratio `1/‖p‖₂²`. Cauchy–Schwarz forces `T_256² ≤ 256‖p‖₂²`, so
`T_256 = 0.731` implies `1/‖p‖₂² ≤ 256/0.731² ≈ 479 < 526.39`
(`SelectionDilution.net45_reported_support_exceeds_participation_ratio`, arithmetic in
`net45_topmass_exceeds_l2_cap`). The reported `N_eff` must therefore be an
entropy-based functional; the two numbers may not be substituted into one bound.

## 3. Margin chain and certified depth

| rung `i`      | 0     | 1     | 2     | 3     | 4      |
|---------------|-------|-------|-------|-------|--------|
| `ctx`         | 128   | 256   | 512   | 1024  | 2048   |
| knee          | 16    | 32    | 64    | 128   | 256    |
| margin        | 0.007 | 0.010 | 0.003 | 0.006 | 0.0013 |
| prefix minimum| 0.007 | 0.007 | 0.003 | 0.003 | 0.0013 |

Reading the prefix minima gives the certified depth as a function of the noise level
(`KneeMarginChain.net45_depth_*`, arithmetic in `KneeMarginEvidence.prefix_min_margins`):

| noise `η` | 0.0013 | 0.002 | 0.004 | 0.006 (measured inter-seed spread) | 0.010 |
|-----------|--------|-------|-------|------------------------------------|-------|
| depth     | 5      | 4     | 2     | **2**                              | 0     |

Shifting the seed-1 sweep up by the measured spread `0.006` already reports `224`
(`KneeMarginEvidence.knee_net45_shifted`): the NET-46 seed-2 reading is inside the
seed-1 noise and is not independent evidence.

## 4. Robustness radius

`KneeMarginChain.net45_robustness_radius`: the claim `k* = 256` survives every monotone
`η`-perturbation **iff** `η ≤ 0.0013`. The failure direction is witnessed by the explicit
monotone curve `envUp − η` (within `η` of the measurement on the grid, retained accuracy
`0.9813 − η < 0.98` at `256`), and at `η = 0.006` by the monotone curve
`envDown + 0.006`, whose knee is `224`
(`KneeMarginChain.net45_spread_perturbation_reads_224`).

## 5. Concentration

* `N_eff : 291.16 → 526.39` on the doubling, ratio in `(1.80, 1.81)`
  (`KneeMarginEvidence.support_ratio`); sublinear in the context, no saturation.
* Consequently no fixed budget retains a fixed fraction of the attention mass
  (`SelectionDilution.no_bounded_working_set`), and retaining a fraction `β` costs at
  least `β²·N_eff` positions (`SelectionDilution.budget_ge_of_retained_mass`).
* Numerically: at the reported concentration, budget `256` cannot carry more than `0.70`
  of the attention mass (`SelectionDilution.net45_mass_retention_at_knee_bound`), while
  the accuracy bar at that budget is `0.98`. **Mass retention and accuracy retention are
  different thresholds**; the knee measures the latter.

## 6. Selection gaps

Reported top-`k` vs random-`k` accuracy gaps (percentage points):

| `ctx`     | 512        | 1024       | 2048       |
|-----------|------------|------------|------------|
| gap       | +5.3 / +4.6| +5.9 / +4.6| +1.7 / +1.8|

Two facts, both proved:

* the gap is **always** non-negative (`SelectionDilution.uniform_le_topMass`), so the sign
  of the measurement is not evidence for anything;
* under exact self-similar refinement the gap is **exactly invariant**
  (`SelectionExchange.selection_gap_split_eq`), so the observed drop
  `+5.9 → +1.7` refutes exact self-similarity of the attention profile across the
  `1024 → 2048` doubling (`SelectionExchange.gap_change_refutes_self_similarity`), and a
  gap of exactly zero would force a uniform profile
  (`SelectionDilution.uniform_of_topMass_eq`).

## 7. Null model for a five-rung chain

Under an unbiased per-rung coin (each rung reads the predicted budget or one grid step
below), exactly one ladder in `2^n` is exact at every rung
(`KneeMarginChain.allExact_card`, `chain_null_probability`). Hence the five-rung chain has
null probability `1/32 < 0.05`, whereas the two-cell replication of the neighbouring round
has `1/4 > 0.05` (`chain_significance`). The chain is significant *as a coincidence*;
what it is not is *certified*, since at realistic noise its certified depth is 2.

## No OEIS entry

The sequences here (`16, 32, 64, 128, 256`, and the margin ladder) are the powers of two
scaled by `d/32` and a five-term measured ladder; neither is an interesting OEIS lookup
(`A000079` for the former). No search was performed beyond that observation.
