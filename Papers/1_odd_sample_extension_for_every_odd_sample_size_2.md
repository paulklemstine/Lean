# Computational Evidence — Tropical `L¹` medians and clipped subgradient descent

All numbers below were produced by exact rational (`ℚ`) computation inside Lean 4
(`#eval`) before the corresponding statements were formalized.  Every claim these
experiments support is now a `sorry`-free theorem in `Catalog/Tropical/EML/`.

## Lab Note 1 — odd sample: unique median, unit growth rate

Sample `x = (-3, -1, 0, 4, 9)` (`2k+1` with `k = 2`, median `x₂ = 0`),
`L(θ) = Σᵢ |θ − xᵢ|`:

| θ  | −6 | −5 | −4 | −3 | −2 | −1 | **0** | 1 | 2 | 3 | 4 | 5 | 6 |
|----|----|----|----|----|----|----|-------|---|---|---|---|---|---|
| L  | 39 | 34 | 29 | 24 | 21 | 18 | **17**| 18| 19| 20| 21| 24| 27|

Observations:
* the minimum is attained only at `θ = 0` — the sample median;
* `L(θ) − L(0) ≥ |θ|` everywhere, with **equality on `0 ≤ θ ≤ 4`** (slope exactly `1`
  between the median and the next order statistic) and slope `3` beyond `θ = 4`.

Formalized as `odd_l1Loss_growth` (bound) and `odd_l1Loss_slab` (sharpness).

## Lab Note 2 — even sample: a flat minimizer segment

Sample `x = (-3, -1, 2, 5)` (`2k+2` with `k = 1`, central statistics `-1` and `2`):

| θ  | −6 | −5 | −4 | −3 | −2 | **−1** | **0** | **1** | **2** | 3 | 4 | 5 | 6 |
|----|----|----|----|----|----|--------|-------|-------|-------|---|---|---|---|
| L  | 27 | 23 | 19 | 15 | 13 | **11** | **11**| **11**| **11**| 13| 15| 17| 21|

The loss is *constant* on `[−1, 2]` and grows with slope exactly `2` immediately
outside it (`13 = 11 + 2·1`), then faster.  Formalized as
`even_l1Loss_const_on_Icc`, `even_l1Loss_growth_left/right` and
`even_minimizes_iff_mem_Icc`.

## Lab Note 3 — exact termination time of clipped descent

`m = 0`, `η = 3/2`, `x₀ = −5`; iterates of `x ↦ tropicalFlow m η x`:

| n  | 0  | 1    | 2  | 3    | 4 | 5 | 6 | 7 |
|----|----|------|----|------|---|---|---|---|
| xₙ | −5 | −7/2 | −2 | −1/2 | 0 | 0 | 0 | 0 |

`⌈|x₀ − m|/η⌉ = ⌈10/3⌉ = 4`, exactly the first index reaching the median, and
`x₃ ≠ m`.  Formalized as `odd_descent_terminates_ceiling` and
`odd_descent_before_ceiling` (with the general characterization
`odd_descent_iterate_eq_iff`).

## Lab Note 4 — descent onto the even-sample interval

`lo = −1`, `hi = 2`, `η = 1`, two initializations `−4` and `5`:

| n            | 0  | 1  | 2  | 3  | 4  | 5  |
|--------------|----|----|----|----|----|----|
| from `−4`    | −4 | −3 | −2 | −1 | −1 | −1 |
| from `5`     |  5 |  4 |  3 |  2 |  2 |  2 |

Each trajectory freezes at the metric projection of its initialization onto
`[−1, 2]` — the projection, not the midpoint.  Formalized as
`intervalStep_iterate`, `intervalStep_terminates_ceiling` and
`interval_descent_reaches_minimizer`.

## Lab Note 5 — perturbed descent: the `max ε` floor is real

`m = 0`, `η = 1`, per-step error `ε = 1/4`, `u₀ = 5`, `uₙ₊₁ = tropicalFlow m η uₙ + ε`:

| n  | 0 | 1    | 2   | 3    | 4 | 5   | 6   | 7   | 8   | 9   |
|----|---|------|-----|------|---|-----|-----|-----|-----|-----|
| uₙ | 5 | 17/4 | 7/2 | 11/4 | 2 | 5/4 | 1/2 | 1/4 | 1/4 | 1/4 |

The distance decays at rate `η − ε = 3/4` per step and then **stalls at exactly
`ε = 1/4`**, never reaching `0`.  This is a counterexample to the naive bound
`max 0 (|x₀ − m| − n(η − ε))` and motivated the corrected statement
`perturbed_distance_bound` (with `max ε`), together with the sharpness witness
`perturbed_ball_bound_sharp`.

## Lab Note 6 — counting kinks of the update map (ReLU width)

Discrete second differences `f(x+h) + f(x−h) − 2f(x)` of `f = intervalStep (−1) 2 1`
at radius `h = 1/2`:

| x   | −2   | −1  | 2    | 3   | 0 | 7/2 |
|-----|------|-----|------|-----|---|-----|
| D   | −1/2 | 1/2 | −1/2 | 1/2 | 0 | 0   |

Four points with nonzero curvature (alternating in sign, at `lo − η, lo, hi, hi + η`)
and zero curvature elsewhere.  Since each ReLU unit can supply curvature only inside
one window around its own kink, at least four units are needed; four suffice.
Formalized as `reluNet_kink_witness`, `intervalStep_relu_width_ge_four` and
`intervalStep_relu_width_four_exact`, with the point-minimizer case giving width two
(`descent_step_relu_width_dichotomy`).

## Counterexample hunt

* `max 0` version of the perturbed bound: **refuted** (Lab Note 5), replaced by a
  proved `max ε` version plus a proved sharpness witness.
* "Single ReLU unit represents the clipped update": **refuted** for every `t > 0`
  (`no_single_relu`), and strengthened to a width-`≥ 2` bound allowing an arbitrary
  affine skip term (`tropicalFlow_relu_width_ge_two`).
* Median uniqueness for even samples: **refuted** by construction — the minimizer set
  is a full segment (Lab Note 2), which is why the even case is stated as an interval.

No OEIS sequence is involved: all data here are piecewise-linear values over `ℚ`,
not integer sequences.
