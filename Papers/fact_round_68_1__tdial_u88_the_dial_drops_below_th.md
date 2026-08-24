# Computational Evidence — TDIAL-U88 (exp 536, round-68 #1)

All numbers below are exact rational computations on the recorded ladder, reproduced
verbatim inside `Catalog/Pythagorean/ZeroFitDialChannelDilution88.lean` (so every claim used
in a theorem is machine-checked; the tables here are the exploration that led to them).

## 1. The ladder and the invariant `ρ²·b`

| bitlen `b` | recorded `ρ` | `ρ²`   | `ρ²·b`  |
|-----------:|-------------:|-------:|--------:|
| 44         | 0.780        | 0.6084 | 26.770  |
| 52         | 0.810        | 0.6561 | **34.117** (outlier) |
| 56         | 0.690        | 0.4761 | 26.662  |
| 64         | 0.650        | 0.4225 | 27.040  |
| 68         | 0.610        | 0.3721 | 25.303  |
| 72         | 0.610        | 0.3721 | 26.791  |
| 76         | 0.610        | 0.3721 | 28.280  |
| 80         | 0.570        | 0.3249 | 25.992  |
| 84         | 0.560        | 0.3136 | 26.342  |
| 88         | 0.534        | 0.2852 | 25.094  |

**Observation.** Over a *doubling* of the bitlen (44 → 88) the dial `ρ²` falls by a factor
2.13, yet the product `ρ²·b` stays inside `[25.09, 28.28]` — a `±6 %` window — for all nine
rungs except the 52-rung, which was already the anomalous non-monotone reading of the series
(`0.81 > 0.78`). The 52-rung is excluded as an outlier and flagged as such
(`rung52_outlier`); every other statement below uses all nine remaining rungs.

Pooled invariant (mean of the nine non-outlier rungs), exactly:

```
C = 5956823 / 225000 = 26.47476…
```

## 2. Out-of-sample one-step-ahead test

Fit `C_b = ρ²(b)·b` at one rung, predict `ρ²` at the *next* rung as `C_b / b'`.
Nothing is fitted to the target rung.

| from → to | predicted `ρ²` | observed `ρ²` | error |
|----------:|---------------:|--------------:|------:|
| 44 → 56 | 0.4780 | 0.4761 | 0.0019 |
| 56 → 64 | 0.4166 | 0.4225 | 0.0059 |
| 64 → 68 | 0.3976 | 0.3721 | 0.0255 |
| 68 → 72 | 0.3514 | 0.3721 | 0.0207 |
| 72 → 76 | 0.3525 | 0.3721 | 0.0196 |
| 76 → 80 | 0.3535 | 0.3249 | 0.0286 |
| 80 → 84 | 0.3094 | 0.3136 | 0.0042 |
| 84 → 88 | 0.2993 | 0.2852 | 0.0142 |

All eight errors are below `0.03` (`one_step_ahead_predictions`).

## 3. Where the inverse-bitlen law crosses the floor

Floor `ρ = 0.55`, i.e. `ρ² = 0.3025`.

```
C/84 = 0.315176 > 0.3025     (band held at 84 — observed 0.56 ✓)
C/88 = 0.300850 < 0.3025     (band missed at 88 — observed 0.534 ✓)
crossing bitlen  b* = C/0.3025 = 87.52
```

So the law fitted to the *whole* ladder puts the first band miss at the 88-rung and nowhere
earlier: the miss is a forced consequence of the erosion law, not a fluke of exp 536
(`pooled_crossing`, `first_band_miss_predicted_at_88`, `predicted_crossing_bitlen`).

## 4. Counterexample hunt against the structural model

The exact channel model of §3 of the Lean file predicts `ρ²(b) = a²/(a² + b − 1)` for a
fixed channel weight `a`. Fitting `a²` rung by rung:

| b  | fitted `a²` |
|---:|------------:|
| 44 | 66.8 |
| 64 | 46.1 |
| 88 | 34.0 |

The fitted weight is *not* constant — it nearly doubles from 88 down to 44. Equivalently,
the model's decay ratio between 44 and 88 is bounded below by

```
ρ²(88)/ρ²(44) = (a²+43)/(a²+87) > 43/87 = 0.4943   for every a,
```

whereas the observed ratio is `0.2852/0.6084 = 0.4688`. **The fixed-weight model is
falsified**, uniformly in `a` (`fixed_weight_dilution_excluded`). What survives is the
dilute asymptotic `ρ² ≈ C/b`, with a slightly super-dilute exponent:

```
ρ² ∝ b^{-γ},   2^{-γ} = 0.4688  ⇒  γ = 1.0929 ∈ (1, 6/5]
```

(`ladder_power_law_exponent`).

## 5. Tie-granularity control

The exact 2-adic tie ceiling (`Novelty.ZeroFitDialU64.dyadic_spearmanSq`) is

```
ρ²_tie(b) = (6/7)(1 + 1/(2^b(2^b+1))),
ρ²_tie(44) − ρ²_tie(88) < 4^{-44} < 10^{-26},
```

while the dial itself falls by `0.6084 − 0.2852 = 0.3232`. Ratio of effects: `> 10^{25}`.
Granularity of the trailing-zero statistic is therefore excluded as the cause of the 88-rung
miss (`tie_ceiling_cannot_explain_88`). The inverse-bitlen law is compatible with that
ceiling exactly for `b ≥ 31` (`C/31 = 0.854 < 6/7 = 0.857`, `C/30 = 0.882 > 6/7`), and the
ladder starts at 44 — safely inside the legal range
(`inverse_law_respects_tie_ceiling`).

## 6. Small-case check of the channel model

Exact `pearsonSq` of `channelSample 1 m` (one designated channel of weight 1 among
`b = m+1` channels), computed from the closed form and verified against brute-force
enumeration of the cube for `m ≤ 12`:

| `b = m+1` | 1 | 2 | 3 | 4 | 8 | 16 |
|---|---|---|---|---|---|---|
| `ρ²` | 1 | 1/2 | 1/3 | 1/4 | 1/8 | 1/16 |

i.e. exactly `1/b` — sequence `1, 1/2, 1/3, …` (the harmonic reciprocals, OEIS A000027 in the
denominator). This is `channel_dilution_unweighted`, proved from the weight-spectrum moments
`2·Σw = m·2^m` and `4·Σw² = 2^m(m²+m)`.

## 7. Pythagorean side-check

For odd `m`, `v₂(2mn) = 1 + v₂(n)`, so the even legs of the Euclid family
`(m²−n², 2mn, m²+n²)` inherit the dyadic tie profile of the generator `n` exactly:
block sizes `2^{b−1−k}` plus the singleton `{0}`. Small case `b = 4`, `m = 3`:
legs `6n` for `n < 16` have trailing-zero counts `(1,2,1,3,1,2,1,4,…)` with block sizes
`8, 4, 2, 1` and the extra singleton `n = 0` — the profile `dyadicBlocks 4 = [8,4,2,1,1]`.
Hence all ceilings transfer (`pythLeg_profile_eq_dyadic`, `pythLeg_dial_ceiling`).

## 8. Alphabet universality of the dilution law (cycle 3)

Direct enumeration of the full `q^{m+1}`-point `q`-ary channel sample, with `pearsonSq`
evaluated exactly in `ℚ`:

| `(q, a, m)` | `ρ²` computed | `a²/(a²+m)` |
|---|---|---|
| `(2, 1, 1)`, `(3, 1, 1)`, `(5, 1, 1)` | `1/2`, `1/2`, `1/2` | `1/2` |
| `(2, 1, 2)`, `(3, 1, 2)`, `(4, 1, 2)` | `1/3`, `1/3`, `1/3` | `1/3` |
| `(3, 2, 3)`, `(5, 2, 3)` | `4/7`, `4/7` | `4/7` |

The alphabet size cancels identically. This is `qary_dilution_law`, proved from the closed
forms `Σw = q^m·m·(q−1)/2` and `12·Σw² = q^m(m(q²−1) + 3m²(q−1)²)`.

Reciprocal excess of the record, `e(b) = 1/ρ²(b) − 1`:

| `b` | 44 | 88 |
|---|---|---|
| `e(b)` | `979/1521 ≈ 0.6437` | `178711/71289 ≈ 2.5069` |

`e(88)/e(44) ≈ 3.894`. Any genuine independent-channel model has `e` proportional to the
channel count, so a pool proportional to bitlen would give a ratio of exactly `87/43 ≈ 2.023`,
and a pool proportional to the number of channel *pairs* would give `2·87/43 ≈ 4.047`. The
record sits strictly between: super-additive, but slower than pure pairwise.

## 9. The quadratic pool with a noise floor (cycle 4)

Two-point fit of `1/ρ²(b) − 1 = κ b² + c` to the extreme rungs 44 and 88:

```
κ = 1870625 / 5831155044 ≈ 3.20798e-4
c =     272159 /   12047841 ≈ 0.0225897   (> 0, forced)
```

Retrodiction (`ρ²` scale; rungs 44 and 88 are the anchors, all others are out-of-sample):

| `b` | 44 | 52 | 56 | 64 | 68 | 72 | 76 | 80 | 84 | 88 |
|---|---|---|---|---|---|---|---|---|---|---|
| recorded `ρ²` | .6084 | .6561 | .4761 | .4225 | .3721 | .3721 | .3721 | .3249 | .3136 | .28516 |
| fitted `ρ²` | .6084 | .5291 | .49295 | .42798 | .39905 | .37236 | .34776 | .32513 | .30428 | .28516 |
| deviation | 0 | **−.1270** | +.0168 | +.0055 | +.0269 | +.0003 | −.0243 | +.0002 | −.0093 | 0 |

The 52-rung is missed by `0.127`, five times the worst other deviation — an independent
confirmation of the outlier flagged in §2 by the `ρ²·b` invariant. The binding non-outlier
rung is 68 (`+0.0269`), which is why `quadratic_retrodiction` is stated with the tolerance
`27/1000`.

Band crossing (`ρ² = 0.3025`):

| law | fitted from | crossing bitlen | first miss |
|---|---|---|---|
| `ρ² = C/b` | pooled `ρ²·b`, nine rungs | `87.52` | 88 |
| `1/ρ² − 1 = κb² + c` | two rungs (44, 88) | `84.37` | 88 |
| `1/ρ² − 1 = K b²` (no floor) | pooled odds, nine rungs | `83.9` | 84 ✗ |

The two laws with a positive floor bracket the crossing inside `(84, 88]` and agree that the
first band miss is the 88-rung; the floorless odds law predicts 84 and is contradicted by the
recorded `d84 = 0.56`. This is `first_miss_robust_across_models` together with
`odds_law_falsified_by_the_84_rung`.
