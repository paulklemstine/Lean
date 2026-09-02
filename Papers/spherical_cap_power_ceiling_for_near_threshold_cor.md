# Computational evidence — spherical-cap power ceiling for the U84 correlation test

All numbers below were produced by floating-point exploration *before* formalisation, to
check that the intended statements were true and non-vacuous.  Everything that is asserted
as a theorem is proved in Lean in `Catalog/Physics/SphericalCapPowerCeiling*.lean`; the
floating-point values in this file are exploratory and are **not** themselves machine-verified.
Where a Lean theorem covers a value it is marked *(Lean)*.

## 1. Cap geometry at the recorded alignment `c = 0.9999`

| quantity | value | Lean statement |
|---|---|---|
| chordal radius `√(2−2c) = √(2·10⁻⁴)` | `0.0141421356…` | `u84_cap_radius` *(Lean)* |
| angular radius `arccos(0.9999)` | `0.0141422535` rad `= 0.8102914°` | `u84_cap_angular_radius_lt_point_nine_degrees` proves `< 0.9°` *(Lean)* |
| `cos(0.9°)` | `0.9998766325 < 0.9999` | the numeric core of that proof *(Lean)* |
| Jordan bound `(π/2)·chord` | `0.0222144` (a valid but weaker angular bound) | `arccos_le_pi_div_two_mul_chord` *(Lean)* |

Sanity check for the `0.9°` proof route: it needs `sin(π/400) > √(5·10⁻⁵)`.
Numerically `sin(π/400) = 0.0078539009` versus `√(5·10⁻⁵) = 0.0070710678`, a comfortable
`11%` margin, so the crude cubic bound `sin x > x − x³/4` (with `π > 3`) suffices.

## 2. Power ceiling versus attainable separation

| quantity | value |
|---|---|
| reading gap to separate (`0.558` vs `0.550`) | `0.008` |
| ceiling for a `1`-Lipschitz statistic | `√2/100 = 0.0141421` *(Lean: `lipschitz_gap_le`)* |
| separation actually achieved by the correlation statistic | `0.008` *(Lean: `u84_correlation_test_near_optimal`)* |
| ratio achieved/ceiling | `0.5657` (ceiling loose by `<1.7678×`) |
| Lipschitz constant needed for full separation `δ = 1` | `100/√2 = 70.71` *(Lean: `≥ 70`)* |

**Counterexample hunt.** The obvious way to falsify the conjecture is a statistic that
separates the two hypotheses by more than `L·√(2ε)`.  A grid search over threshold statistics
`x ↦ 1{corr(x,w) ≥ t}` for `t ∈ {0.551, …, 0.557}` separates the two hypotheses by `1`, i.e.
`70×` the Lipschitz ceiling for `L = 1` — no contradiction, because these statistics have
*no finite* Lipschitz constant.  Formalised as `capIndicator_not_lipschitz`: for every `L` the
pair `x = (t, √(1−t²))`, `y = (t−d, √(1−t²))` with `d = min(t/2, 1/(2(|L|+1)))` violates the
`L`-Lipschitz inequality.  Explicit instance at `L = 100`, `t = 0.554`:

```
d          = 1/202 = 0.00495050
corr(x,w)  = 0.554000   -> indicator 1
corr(y,w)  = 0.550555   -> indicator 0
‖x − y‖    = 0.00495050 ->  L·‖x−y‖ = 0.49505 < 1 = |F(x) − F(y)|
```

No counterexample to the Lipschitz ceiling itself was found, as expected: the ceiling is a
consequence of Cauchy–Schwarz and is *attained* (`lipschitz_ceiling_attained`) by the
distance statistic `x ↦ L·‖x − v̂‖`.

## 3. Alignment window forced by the margin

The recorded margin `δ = 0.008` bounds how well the two hypotheses can be aligned:
`corr(u,v) ≤ 1 − δ²/2 = 0.999968`.  The catalog configuration attains `0.9999`, so the
window of realisable alignments is

```
0.999900  ≤  corr(u,v)  ≤  0.999968        (width 6.8e-5)
```

*(Lean: `u84_alignment_window`.)*

## 4. Cap capacity (how many rungs fit)

With per-rung gain `δ = 0.008` and `L = 1`, `k·0.008 ≤ 0.0141421` forces `k ≤ 1.7678`, i.e.
`k ≤ 1`.  A second resolvable rung would need alignment below `1 − (2·0.008)²/2 = 0.999872`.

| `k` | required `k·δ` | ceiling `√2/100` | fits? |
|---|---|---|---|
| 1 | 0.008 | 0.014142 | yes (attained, `u84_one_rung_is_resolvable`) |
| 2 | 0.016 | 0.014142 | no (`u84_at_most_one_resolvable_rung`) |
| 3 | 0.024 | 0.014142 | no |

## 5. Roughness trade-off (Hölder exponents)

Ceiling `C·(√2/100)^α` for a `(C,α)`-Hölder statistic, and the constant needed to separate
`δ = 0.008`:

| `α` | ceiling at `C=1` | needed `C` |
|---|---|---|
| 1 | 0.014142 | 0.5657 |
| 1/2 | 0.118921 | 0.06727 |
| 1/4 | 0.344849 | 0.02320 |
| 0 | 1 | 0.008 |

The monotone decay of the required constant as `α → 0` is the quantitative form of "rougher
statistics see more", and `α = 0` (arbitrary bounded statistics) recovers full separability —
consistent with the discontinuous threshold test.

## 6. OEIS

No integer sequence arises in this analysis (all objects are real-analytic/geometric), so no
OEIS search was applicable.

## 7. The optimal smooth test (cycle 4)

Correlating against the contrast direction `e = (û − v̂)/‖û − v̂‖` gives separation exactly
`chord(u,v)` *(Lean: `contrast_test_attains_chord`)*, which on the U84 configuration satisfies

```
0.008  ≤  chord(u,v)  ≤  √2/100 = 0.0141421
```

*(Lean: `u84_optimal_smooth_test`)*.  The recorded response correlation achieves `0.008`, i.e.
an efficiency of at least `0.008/0.0141421 = 0.5657` relative to the smooth optimum, and the
possible improvement is capped at `1.7678×` *(Lean: `u84_contrast_beats_response_correlation`)*.
Even the optimal smooth test therefore stays two orders of magnitude below the separation `1`
attained by the discontinuous threshold statistic.
