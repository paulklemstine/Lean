# Computational evidence — TDIAL-U52 (round-58 #1, exp 528)

This note records the numerical exploration that guided the three Lean files
`Catalog/MachineLearning/ZeroFitDialUnif52.lean`,
`Catalog/MachineLearning/ZeroFitDialResolution.lean` and
`Catalog/MachineLearning/ZeroFitDialEnvelope.lean`.
Everything asserted as a *theorem* in those files is proved in Lean; the tables below are
exploratory arithmetic only (exact rational arithmetic in Python's `fractions`), and are
labelled as such.

## 1. The two tie profiles at bitlen `b`

* trailing-zero ("zero-fit dial") profile on `{0,…,2^b-1}`:
  block sizes `2^(b-1), 2^(b-2), …, 2, 1, 1` — a *dominant-block* shape;
* Hamming-weight ("count") profile: block sizes `C(b,0), …, C(b,b)` — a *spread* shape.

Both have `b+1` distinct values and total mass `2^b`.

Tie-attenuation law (proved in `Novelty.ZeroFitDialU64`):
`ρ² = 1 - Σⱼ(mⱼ³-mⱼ)/(n³-n)`.

## 2. Exact ceilings versus the bounds proved in Lean

`exact` = exact count ceiling `1 - (F(b) - 2^b)/(8^b - 2^b)` with `F(b) = Σₖ C(b,k)³`
(Franel numbers, OEIS **A000172**: `1, 2, 10, 56, 346, 2252, 15184, 104960, 739162, …`);
`lower` = the bound proved as `count_ceiling_ge` (`1 - 4/(3b+2)`, even `b`);
`upper` = the bound proved as `resolution_law`/`count_ceiling_upper` (`1 - 1/(b+1)² + 4⁻ᵇ`);
`dyadic` = the exact dial ceiling `(6/7)(1 + 1/(2^b(2^b+1)))`.

| b  | exact count | lower (proved) | upper (proved) | dyadic (exact) |
|----|-------------|----------------|----------------|----------------|
| 2  | 0.900000    | 0.500000       | 0.951389       | 0.900000       |
| 4  | 0.919118    | 0.714286       | 0.963906       | 0.860294       |
| 6  | 0.942308    | 0.800000       | 0.979836       | 0.857349       |
| 8  | 0.955957    | 0.846154       | 0.987670       | 0.857156       |
| 10 | 0.964457    | 0.875000       | 0.991736       | 0.857144       |
| 20 | 0.981927    | 0.935484       | 0.997732       | 0.857143       |
| 52 | 0.992977    | **0.974684**   | **0.999644**   | **0.857143**   |
| 64 | 0.994287    | 0.979381       | 0.999763       | 0.857143       |

Observations that became theorems:

* the count ceiling **exceeds** the dyadic ceiling from `b = 4` onwards; the proved lower
  bound clears `6/7` from `b = 10` onwards (this is exactly the hypothesis `m ≥ 5`, i.e.
  `b ≥ 10`, in `ceiling_inversion`);
* the count ceiling appears to converge to `1` (proved: `count_ceiling_tendsto_one`), while
  the dyadic one stalls at `6/7 = 0.857142…`;
* the resolution bound `1 - 1/(b+1)²` is far above the dyadic value at every `b ≥ 4`
  (proved at `b = 52` as `dyadic_far_below_resolution_law`), so the number of distinct
  values does not determine a ceiling.

## 3. Counterexample hunt

* *Is the count baseline ever more tie-limited than the dial?* — scanned exactly for every
  `b ≤ 200`: never. The exact count ceiling exceeds the dyadic ceiling for every `b ≥ 3`,
  and the two are equal only at `b ∈ {1, 2}`, where the profiles coincide. This is the
  content of `ceiling_inversion`; the small cases `b ≤ 8` are excluded there by the
  hypothesis `m ≥ 5` because the *bound* used in the proof, not the statement, degrades.
* *Is the power-mean step `n³ ≤ K²·Σmⱼ³` tight?* — enumerated all compositions with
  `n ≤ 12`: the inequality never failed and equality occurred exactly at the balanced
  profiles (`m₁ = … = m_K`), 34 cases. The Lean proof exhibits the slack explicitly as
  `(Km - s)²(K²m + 2Km + 2Ks + s) ≥ 0`.
* *Half-mass cap.* — enumerated all compositions with at most `4` parts and `4 ≤ n ≤ 119`
  having a part of mass `≥ n/2`: no violation of `ρ² ≤ 7/8 + 7/(8(n²-1))`, the largest
  observed excess over `7/8` being `0.025` at small `n` (the correction term is genuinely
  needed, which is why the Lean statement keeps it).

## 4. The envelope-constant witness

Profiles `A = (2^52 - 1, 1)` and `B = (2^52 - 1 - d, 1 + d)` with `d = ⌊2^52/100⌋ =
45035996273704` have equal mass `2^52`, total variation `d/2^52 < 1/100`, and exact ceiling
gap

```
ρ²(B) - ρ²(A) = 40159171015229442027711162032 / 1352160640243444694929816752401 = 0.029700…
```

i.e. `2.97` times the total variation. That exact rational is what
`envelope_constant_ge_two_point_nine` certifies in Lean (stated with the safe rational
threshold `296/10000`), and it is what pins the envelope Lipschitz constant from below.

## 5. Recorded round-58 numbers

Seeds 20261120/21/22: `0.698 / 0.697 / 0.720`, mean `0.705`; advantage over count `+0.070`,
CI `[0.046, 0.093]`, implied count reading `0.635`.

| quantity | value | dial ceiling | count ceiling |
|----------|-------|--------------|---------------|
| ρ² of dial reading  | 0.497 | 0.857 | — |
| ρ² of count reading | 0.403 | — | ≥ 0.975 |
| deficit             | 0.360 | | ≥ 0.572 |

Both readings sit far below their ceilings, and the *count* statistic — the one with the
higher ceiling — reads lower. This inversion is what `count_advantage_not_tie_artefact` and
`count_deficit_exceeds_dial_deficit` formalise.
