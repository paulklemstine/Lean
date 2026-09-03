# Computational evidence — real-parameter scale flow on knee chains

All numbers below were produced by evaluating Lean expressions (`#eval`, `Float`
arithmetic for the transcendental parts). Every claim that is *asserted* rather
than merely explored is proved in the accompanying Lean files with exact rational
bounds; the floats here are orientation, not verification.

## 1. Discrete cells (from `Combinatorics.OctaveShiftLaw`)

Base chain `K(j) = 16 + 4j`, table `k*(s, j) = K(j − s)` (truncated subtraction):

| scale index `s` | j=0 (512) | j=1 (1024) | j=2 (2048) | j=3 (4096) |
|---|---|---|---|---|
| 0 (0.5B, measured) | 16 | 20 | 24 | 28 |
| 1 (1.5B, measured) | 16 | 16 | 20 | 24 |
| 2 (7B, predicted)  | 16 | 16 | 16 | 20 |

`#eval` output: `[16, 20, 24, 28]`, `[16, 16, 20, 24]`, `[16, 16, 16, 20]`.
This reproduces the catalog's measured rows and its 7B prediction, and is the
integer restriction that the continuous table must match
(`ScaleFlowSweep.kstar_restricts`).

## 2. Non-uniqueness of monotone interpolation

Two monotone interpolants of the same measured chain, sampled at half-octaves
`t = 0, 0.5, 1, 1.5, 2`:

* ramp (piecewise-linear) interpolant: `[16, 18, 20, 22, 24]`
* staircase interpolant `K⌈t⌉`:        `[16, 20, 20, 24, 24]`

They agree at every integer cell and differ by 4 keys at `t = 1/2`. Formalised as
`ScaleFlowInterpolation.interp_not_unique`; the gap is what motivates the extra
"stationary increments" axiom that pins the interpolant
(`affine_of_monotone_of_stationary_increments`).

## 3. Log-linear calibration and the 3B sweep

Calibration `scaleIndex N = 1 + log(N/1.5)/log(14/3)` (anchors `1.5B ↦ 1`, `7B ↦ 2`).

`#eval (sIdx 1.5, sIdx 3, sIdx 7) = (1.000000, 1.449966, 2.000000)`.

Predicted 3B chain `k(σ,t) = 16 + 4·(t − σ)⁺` at `σ = 1.449966`:

| ctx | 512 | 1024 | 2048 | 4096 |
|---|---|---|---|---|
| 1.5B (σ=1) | 16 | 16 | 20 | 24 |
| **3B (σ≈1.45)** | 16 | 16 | **18.2001** | **22.2001** |
| 7B (σ=2) | 16 | 16 | 16 | 20 |

Rigorous version: `1.4 < scaleIndex 3 < 1.5` is proved from
`4 < 14/3 < 32^(1/5)`-type comparisons (`scaleIndex_3B_bounds`), giving the proved
windows `18 < k(3B, 2048) < 18.4` and `22 < k(3B, 4096) < 22.4`, hence integer
budgets 19 and 23 (`sweep_3B_ctx2048`, `sweep_3B_ctx4096`). The float value 18.2001
sits inside the proved window, as it must.

## 4. Counterexample hunt

* *Is monotone interpolation unique?* No — counterexample in §2, formalised.
* *Is the interpolated 3B budget an integer cell of the discrete table?* No: for
  every natural `s`, `k*(s, 2) ∈ {16, 20, 24, …}` and never equals `k(3B, 2048)`
  (`sweep_3B_not_discrete`). This is the falsifiable content of the extension.
* *Can a different rate be hidden by re-gauging the scale axis?* No
  (`kstar_rate_identifiable`): agreeing tables force equal base knee, equal rate and
  equal offset.
* *Does the continuous area equal the discrete cell count?* No, and the mismatch is
  not noise: `#eval` of `S(S+1)/2 − S²/2` for `S = 0..6` gives
  `[0, 0.5, 1, 1.5, 2, 2.5, 3]`, i.e. exactly `S/2`. Formalised as
  `ScaleFlowBudget.net66_staircase_defect`.

## 5. No OEIS entry needed

The only integer sequence that appears is the triangular-number cell count
`S(S+1)/2` (A000217), already identified in the catalog's
`served_card_two_mul`; the new content here is its continuous limit and the exact
`S/2` defect, not a new sequence.
