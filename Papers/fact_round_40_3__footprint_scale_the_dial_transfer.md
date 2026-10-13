# Computational Evidence — FOOTPRINT-SCALE (FACT round-40 #3, exp 478)

The raw exp-478 data (`exp478_result.json`) is **not** in this repository; the only inputs
used are the summary numbers quoted in the assignment. Everything below is exact rational
arithmetic on those numbers. Each line marked **[Lean]** is also a theorem in
`Catalog/Tropical/FootprintScaleReliability.lean` or `Catalog/Tropical/FootprintScaleCalibration.lean`
that builds without `sorry`. Lines marked *(scratch)* were only computed in a scratch script and are not verified.

## 1. Relation-count curve, cell u = 2.5 / bitlen 48

Model: \(R^2(m) = V/(V+F+\sigma/m)\), so \(1/R^2\) is affine in \(1/m\).
Inputs: \(R^2(80)=0.41\), \(R^2(240)=0.60\).

| quantity | exact | decimal | status |
|---|---|---|---|
| Spearman–Brown prediction for 240 (pure noise, F = 0) | 123/182 | 0.6758 | [Lean] `exp478_structural_floor` (used to show F > 0) |
| measured R²(240) | 3/5 | 0.60 | input |
| ⇒ structural residual F | > 0 | — | [Lean] `exp478_structural_floor` |
| ceiling V/(V+F) | 82/105 | 0.7810 | [Lean] `exp478_ceiling` |
| noise ratio σ/V | 3800/41 | 92.68 | [Lean] `exp478_ceiling` |
| relation count needed for R² ≥ 0.70 | m ≥ 53200/85 | 625.88 → **626** | [Lean] `exp478_relations_for_070`, `exp478_min_relations_070` |
| R² < 0.79 at every m | — | — | [Lean] `exp478_never_079` |

Predicted curve *(scratch, from the fitted model)*:

| m (values/N) | 80 | 160 | 240 | 400 | 626 | 1000 | 10000 | ∞ |
|---|---|---|---|---|---|---|---|---|
| R²(m) | 0.410 | 0.538 | 0.600 | 0.661 | 0.700 | 0.728 | 0.775 | 0.781 |

## 2. Calibration slopes (bitlen 52: 0.834 at both 80 and 240)

Under the attenuation model with relation-averaged noise, an identical slope at two
relation counts forces the relation-noise term to be zero (`slope_stable_forces_no_relation_noise` [Lean]),
so the 52-bit deficit \(1-0.834\) is attributed to scale drift \(c<1\) or to fixed noise, not to too few relations.
At bitlen 48 the slope rises 0.896 → 0.912, which agrees with `attSlope_mono` [Lean].

## 3. d(N) effect size implied by min |t| = 3.92

| residual df | partial R² lower bound τ²/(τ²+df) | status |
|---|---|---|
| 77 (80 values, 3 params) | 0.1664 > 0.166 | [Lean] `partialRsq_lower_bound_exp478_80` |
| 237 (240 values) | 0.0609 > 0.06 | [Lean] `partialRsq_lower_bound_exp478_240` |

The degrees of freedom assume three fitted parameters (intercept, dial, d(N)); if the lab regression has more
covariates the df, and therefore the bounds, change slightly.

## 4. Counterexample hunt

* A first draft claimed partial R² > 1/6 at df = 77. Exact check: 15.3664/92.3664 = 0.16636 < 1/6 = 0.16667. **False** —
  corrected to 0.166 before the proof was written.
* Spearman–Brown taken as an exact law (F = 0) is **refuted** by the data: 0.6758 ≠ 0.60.

## 5. OEIS
Not applicable (no integer sequence arises).
