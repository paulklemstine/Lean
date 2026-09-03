# Computational Evidence — footprint recalibration limits (round-45 #3, exp 503)

All numbers below were computed inside Lean (exact rational arithmetic, `#eval`
over the catalog definitions `dial`, `localFactor`, `dialFeature`,
`structureCorrection`), not in a floating-point script.  Every quantity that the
Lean files claim as a theorem is also reproduced numerically here, and the two
agree exactly.

## 1. Local (single-prime) moments of the centred dial `x_p(N) = dial p N − 1`

| quantity | p = 3 | p = 5 | p = 7 | p = 11 | proved as |
|---|---|---|---|---|---|
| `∑_N x_p(N)` | 0 | 0 | 0 | 0 | `sum_dialFeature` |
| `∑_N x_p(N)²` | 2 | 4 | 6 | 10 | `sum_dialFeature_sq` (`= p − 1`) |
| `∑_N localFactor p N · x_p(N)` | −1 | −1 | −1 | −1 | `sum_localFactor_mul_dialFeature` |

So each dial feature is exactly centred, has variance exactly `(p−1)/p`, and
couples to the local smoothness weight with covariance exactly `−1/p`.

## 2. Full brute force over the `{3,5,7}` residue data (105 classes)

Target: the structure correction `C(N) = ∏_p (p − dial p N)/(p − 1)`.
Features: the three centred dials.  Exhaustive enumeration of all 105 residue
data gives

| quantity | exact value | decimal | proved as |
|---|---|---|---|
| `#{N}` | 105 | — | `card_pi_zmod` |
| `𝔼 C` | 1 | 1.0000 | `avg_structureCorrection` |
| `Var C` | 61/240 | 0.25417 | `variance_structureCorrection` (`= ∏(1+1/(p(p−1))) − 1`) |
| `cov(C, x_p)` | (−1/3, −1/5, −1/7) | −0.3333, −0.2000, −0.1429 | `cov_structureCorrection` (`= −1/p`) |
| `Var x_p` | (2/3, 4/5, 6/7) | 0.6667, 0.8000, 0.8571 | `avg_dialFootprint_sq` (`= (p−1)/p`) |
| optimal `β*_p` | (−1/2, −1/4, −1/6) | — | `optimal_weights_structureCorrection` (`= −1/(p−1)`) |
| zero-fit MSE | 61/240 | 0.25417 | `mse_zeroFit` |
| best refit MSE | 23/1680 | 0.01369 | — |
| best possible gain | 101/420 | 0.24048 | `energy_structureCorrection` (`= ∑ 1/(p(p−1))`) |
| recovery ratio (gain / Var) | 404/427 | 0.94614 | `energy_lt_variance_structureCorrection` (`< 1`) |

**Deficit.**  `101/420 < 61/240`: even a *perfectly refitted* three-prime
footprint leaves `61/240 − 101/420 = 23/1680 ≈ 0.0137`, i.e. `≈ 5.4 %` of the
signal, permanently unreachable.  That residue is exactly the multi-prime
interaction part `∏(1+c_p) − 1 − ∑ c_p` with `c_p = 1/(p(p−1))`.

## 3. Counterexample hunt: can a wrongly-signed refit ever help?

| refit weights `β` | `MSE(β) − MSE(0)` | verdict |
|---|---|---|
| theory profile `2/p` | +1366396/1157625 ≈ **+1.1804** | strictly worse than not refitting |
| `−β*` (sign-flipped optimum) | +101/140 ≈ **+0.7214** | strictly worse |
| `β*` | −101/420 ≈ −0.2405 | the unique optimum |

The positive-profile row is the exact analogue of the measured
`paired gain = −0.0238, 5/5 negative`: because the true optimal profile is
*negative* (`β*_p = −1/(p−1)`), any nonnegative "theory-shaped" weight vector is
provably worse than the unrefit zero-fit dial.  This is proved in general as
`positive_profile_gain_neg`, and the sign anti-correlation as
`optimal_profile_anticorrelated`.

## 4. Orthogonality / independence check

Evaluated over all 105 residue data, `𝔼[x_i] = 0` for each of `p = 3,5,7` and
`𝔼[x_i x_j] = 0` for all three pairs `i ≠ j`, exactly
(consistent with the exact joint uniformity of
`Catalog.NumberTheory.QuadraticDialIndependence`), which is what makes the
design orthogonal and the least-squares algebra exact rather than approximate
(`dialDesign_isOrthogonal`).

## 5. OEIS

No integer sequence arises in this experiment: the ceiling
`∑_{p ≤ B, p odd} 1/(p(p−1))` and the variance
`∏_{p ≤ B, p odd} (1 + 1/(p(p−1))) − 1` are single rationals attached to a prime
family, not a sequence of integers, so an OEIS lookup is not applicable and none
was performed.
