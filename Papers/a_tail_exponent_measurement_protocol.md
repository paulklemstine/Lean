# Computational evidence — tail-exponent measurement protocol

All numbers below were produced by evaluating an exact-rational (`ℚ`) model of the
pipeline inside Lean (`hm`, `ret`, `kst`, `en`, `floor2` mirroring `headMass`, `retained`,
`kstar`, `energy`, `g²/E`), plus a few `Float` evaluations for the log/root steps.  They are
*evidence*, not proof; every claim that is asserted as a theorem is proved separately and
`sorry`-free in `Catalog/Shared/AttentionBudget*.lean`.

## 1. The energy floor against the true knee

Gate `g = 0.98` throughout (the deployment gate of the catalog's NET-65 experiment).

| profile | `n` | true `k*` | energy floor `g²/E` | ratio `k*/floor` |
|---|---|---|---|---|
| flat `wᵢ = 1` | 8 | 8 | 7.68 | 1.04 |
| flat | 16 | 16 | 15.37 | 1.04 |
| flat | 32 | 32 | 30.73 | 1.04 |
| flat | 64 | 63 | 61.47 | 1.02 |
| Zipf-1 `1/(i+1)` | 8 | 8 | 4.x | 1.9 |
| Zipf-1 | 16 | 15 | 6.x | 2.4 |
| Zipf-1 | 32 | 30 | 9.x | 3.2 |
| Zipf-1 | 64 | 59 | 13.x | 4.4 |
| geometric `r = 1/2` | 16…128 | 6 | 2.88 | 2.1 |
| geometric `r = 0.9` | 16 | 16 | 12.x | 1.3 |
| geometric `r = 0.9` | 32 | 28 | 17.x | 1.6 |
| geometric `r = 0.9` | 64 | 37 | 18.x | 2.0 |
| geometric `r = 0.9` | 128 | 38 | 18.x | 2.0 |

Observations.

* The floor is never violated (consistent with `budget_sandwich`).
* On the flat profile the floor is within 4 % of the knee — matching the resolution limit
  `1/g² = 1.0412` proved in `sandwich_ratio_le_gate_sq`, and matching the sharpness
  statement `budget_sandwich_sharp_uniform` at `g = 1`.
* For `r = 0.9` the floor saturates at `18.2`, which is exactly the predicted limit
  `g²(1+r)/(1-r) = 0.9604 · 1.9 / 0.1 = 18.25` of `energy_geometric`.  The finite-`n`
  formula was checked at `n = 16, 32, 64, 128` and agrees to the last rational digit.
* No counterexample to the floor was found in any of the 20 profile/context pairs tested.

## 2. The spike counterexample (entropy is not a certificate)

`w = (16, 1, 1, …, 1)` on `n = 17` keys, gate `g = 1/2`:

* `k* = 1`, `E = 17/64`, energy floor `g²/E = 16/17 ≈ 0.94 ≤ 1` ✓
* Hartley ("support size") floor `g² n = 17/4 = 4.25 > 1` ✗
* Shannon entropy `H₁ = 3 log 2 = log 8` exactly, so the Shannon floor
  `g² e^{H₁} = 2 > 1` ✗
* collision entropy `H₂ = log(64/17) ≈ 1.325 < 2.079 = H₁`, a strict gap.

These are the exact values proved in `hartley_floor_refuted`, `shannonEntropy_spike` and
`shannon_floor_refuted`.

## 3. The two-point tail fit on measured data

Tails `1 - M(k)` of the geometric profile `r = 0.9` at context `n = 128` (exact rationals,
truncated to four decimals):

| `k` | 1 | 2 | 4 | 8 | 12 | 16 |
|---|---|---|---|---|---|---|
| `1 - M(k)` | 0.8999 | 0.8099 | 0.6560 | 0.4304 | 0.2824 | 0.1853 |

Two-point fit at `k₁ = 4`, `k₂ = 16` (`d = 12`):

* `r̂ = (0.1853/0.6560)^{1/12} = 0.900011` (true `r = 0.9`)
* `Ĉ = 0.6560 / r̂⁴ = 0.999848` (true `C = 1`)
* reported budget `⌈log((1-τ)/Ĉ)/log r̂⌉ = ⌈37.13⌉ = 38` at `τ = 0.98`
* measured knee at `n = 128`: `k* = 38`.

The fit is exact to five digits and the reported budget coincides with the true knee, which
is the finite-sample face of `fitRatio_exact`, `fitConst_exact` and
`budgetOfFit_two_point_exact`.

## 4. Error damping by probe separation

With a multiplicative data error `ε = 0.05` the fitted-ratio inflation factor
`((1+ε)/(1-ε))^{1/d}` is

| `d` | 4 | 12 |
|---|---|---|
| factor | 1.0253 | 1.0084 |

so a 5 % error on each tail measurement becomes a 0.8 % error on the fitted ratio at probe
separation 12 — the quantitative content of `fitRatio_error_bound` and
`fit_precision_of_probe_separation`.

## 5. Counterexample hunt

* Floor `g²/E ≤ k*`: tested on flat, Zipf-1, Zipf-2, geometric (`r = 1/2, 0.9`) and spike
  profiles at contexts `8 … 128` and gates `1/2, 0.98`; no violation.
* Hartley floor `g² n ≤ k*`: violated already by the 17-key spike (reported above).
* Shannon floor `g² e^{H₁} ≤ k*`: violated by the same profile.
* Exact flatness `k*(2n) = k*(n)`: violated for `r = 0.9` (`k*(32) = 28`, `k*(64) = 37`),
  confirming the cycle-2 refutation `exact_flatness_refuted` at a second data point.

No OEIS sequence was searched: the objects here are real-valued functionals of a
real-valued profile, and the integer sequences appearing (knee tables such as
`6, 6, 6, 6` or `16, 28, 37, 38`) are gate- and profile-dependent rather than universal.
