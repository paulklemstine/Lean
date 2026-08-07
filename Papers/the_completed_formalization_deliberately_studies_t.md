# Computational evidence

All numbers below were produced with `#eval` inside this project's Lean
toolchain (IEEE `Float` arithmetic, so they are indicative rather than
certified; every *claim* that they motivate is proved exactly in the `.lean`
files listed at the end).

## 1. Weight-decayed gradient flow and the derived delay

Model: `w'(t) = s - λ w`, `w(t) = s/λ + (w₀ - s/λ)e^{-λt}`, activation
threshold `θ`, derived delay `crossTime = λ⁻¹ log((s/λ - w₀)/(s/λ - θ))`.

With `λ = 0.5`, `s = 1` (so `s/λ = 2`), `w₀ = 0`, `θ = 1.9`:

| quantity | value |
|---|---|
| `crossTime` | `5.991465` |
| `w(5.98)` | `1.899425` (below `θ`) |
| `w(6.00)` | `1.900426` (above `θ`) |

The trajectory crosses `θ` exactly at `crossTime`, as `wdFlow_gt_threshold_iff`
asserts.

## 2. Divergence of the delay at the critical weight decay

Fix `s = 1`, `θ = 1`, `w₀ = 0`, so `λ_c = s/θ = 1`.

| `λ` | `crossTime(λ)` |
|---|---|
| `0.9` | `2.558428` |
| `0.99` | `4.651687` |
| `0.999` | `6.914670` |
| `0.9999` | `9.211261` |

The delay grows like `log(1/(λ_c - λ))`: increments of `≈ 2.30 = log 10` per
decade. This is the numerical signature of
`crossTime_diverges_at_criticality`, and matches the exact lower bound
`crossTime ≥ λ⁻¹ log((θ - w₀)/(s/λ - θ))`.

## 3. Discrete weight-decayed gradient descent

`w_{k+1} = w_k - η(λ w_k - s)` with `η = 0.1`, `λ = 0.5`, `s = 1`, `w₀ = 0`;
compared against the closed form `s/λ + (w₀ - s/λ)(1-ηλ)^k`.

| `k` | recursion | closed form |
|---|---|---|
| `20` | `1.283028` | `1.283028` |
| `50` | `1.846110` | `1.846110` |

Exact agreement, matching `gdSeq_closed_form`.

Crossing step for `θ = 1.9`: the first `k` with `w_k > 1.9` is **59**, while the
proved lower bound `log((s/λ-θ)/(s/λ-w₀))/log(1-ηλ)` evaluates to `58.403975`.
The bound in `gd_delay_lower_bound` is therefore tight to one step here.

## 4. Margin of the vector-valued example network

Two-point test set (positive point of signal `+1`, negative point of signal
`-1`), output bias `-1`; worst-case margin `min(-1 + relu t, 1 - relu(-t))`:

| `t` | `0.5` | `0.9` | `1.0` | `1.1` | `2.0` |
|---|---|---|---|---|---|
| margin | `-0.5` | `-0.1` | `0.0` | `0.1` | `1.0` |

Sign change exactly at `t = 1`, confirming `exMargin_threshold_one`
(margin `≤ 0` for `t ≤ 1`, `> 0` for `t > 1`).

## 5. Counterexample hunt for the robustness claim

Perturbed field `g(x) = (μ - x²) + ε sin(10x)` with `μ = 1`, `ε = 0.2`
(so `‖g - snField μ‖_∞ ≤ ε < μ`, a genuinely non-polynomial perturbation):

| `x` | `-1.1` | `-1.0` | `-0.9` | `0.9` | `1.0` | `1.1` |
|---|---|---|---|---|---|---|
| `g(x)` | `-0.010002` | `0.108804` | `0.107576` | `0.272424` | `-0.108804` | `-0.409998` |

Sign changes occur in `(-1.1, -1.0)` and `(0.9, 1.0)`: two equilibria survive,
one negative and one positive, and both satisfy `|x² - μ| ≤ ε`
(`x ∈ [0.894, 1.095]` in modulus). No counterexample to
`perturbed_two_equilibria` / `perturbed_zero_near_branch` was found in this or
in the sampled family `ε ∈ {0.05, 0.1, 0.2}`.

## 6. Delay scaling with signal strength

Single-unit score `-1 + relu(t·s)` has threshold `1/s`:

| `s` | `1` | `0.5` | `0.1` | `0.01` |
|---|---|---|---|---|
| delay | `1` | `2` | `10` | `100` |

Inverse-signal scaling, matching the exact sandwich
`|c|/S ≤ τ ≤ (|c|/a_{j₀} - b_{j₀})/g_{j₀}` (`delay_scaling_sandwich`) and the
unbounded train/test delay ratio (`grokking_ratio_unbounded`).

## 7. Bottleneck passage time below the bifurcation (cycle 3)

Explicit Riccati solution `x(t) = -k tan(kt)` of `x' = μ - x²` with `μ = -k²`;
passage time from `x = +1` to `x = -1` is `2 arctan(1/k)/k`.

| `k = √(-μ)` | passage time | bound `π/(2k)` |
|---|---|---|
| `0.1` | `29.42` | `15.71` |
| `0.01` | `312.16` | `157.08` |
| `0.001` | `3139.59` | `1570.80` |

Each tenfold decrease of `k` multiplies the passage time by ten: the delay
scales as `|μ|^{-1/2}`, exactly as the proved bound
`π/(2√(-μ)) ≤ passageTime` (`bottleneck_delay_inverse_sqrt`).  Contrast §2,
where the weight-decay delay diverges only logarithmically — the two mechanisms
have different, empirically distinguishable exponents.

## No OEIS entry

No integer sequence arises in this project (all objects are real-analytic), so
an OEIS search is not applicable.

## Where the corresponding theorems live

* `Catalog/MachineLearning/GrokkingDelayedTransition/GradientFlowThreshold.lean`
  (§1, §2, §3)
* `Catalog/MachineLearning/GrokkingDelayedTransition/VectorMargin.lean`
  (§4, §6)
* `Catalog/MachineLearning/GrokkingDelayedTransition/SaddleNodeLocal.lean` (§5)

## 8. Cycle-4 data: the three sub-conjectures (N1)–(N3)

The rational quantities in the tables below were produced with `#eval` in Lean
(exact rational arithmetic); the two logarithms in §8.1 are evaluated
numerically to three decimals.  Each table is matched by a theorem in
`Catalog/MachineLearning/GrokkingDelayedTransition/NextCycle.lean`.

### 8.1 Divergence of the delay along `λ ↑ λ_c` (N1)

With `s = θ = 1` (so `λ_c = 1`) and `w₀ = 0`, the log-argument of `crossTime` is
`(s/λ - w₀)/(s/λ - θ)`:

| `λ` | `0.9` | `0.99` | `0.999` |
|---|---|---|---|
| log-argument | `10` | `100` | `1000` |
| `crossTime = λ⁻¹ log(·)` | `2.558` | `4.652` | `6.914` |

The delay grows like `log(1/(λ_c - λ))` and is unbounded — the numerical
counterpart of `crossTime_tendsto_atTop`.

### 8.2 Exact `1/m` width law (N2)

Symmetric width-`m` network with `A = g = 1`, `c = -1`, zero hidden biases;
`τ(m) = |c|/(m A g)`:

| `m` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| `τ(m)` | `1` | `1/2` | `1/3` | `1/4` | `1/5` | `1/6` | `1/7` | `1/8` |
| `m·τ(m)` | `1` | `1` | `1` | `1` | `1` | `1` | `1` | `1` |

`m·τ(m)` is constant, exactly as `symNet_delay_width_law` asserts.

### 8.3 Grok, un-grok: the hat network (N3)

`hatNet t = -1/2 + relu t - 2 relu(t-1) + relu(t-2)`, tabulated on a quarter-integer
grid (`fail` = `hatNet t ≤ 0`):

| `t` | `0` | `1/4` | `1/2` | `3/4` | `1` | `5/4` | `3/2` | `7/4` | `2` | `3` | `4` |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `hatNet t` | `-1/2` | `-1/4` | `0` | `1/4` | `1/2` | `1/4` | `0` | `-1/4` | `-1/2` | `-1/2` | `-1/2` |
| fail | yes | yes | yes | no | no | no | yes | yes | yes | yes | yes |

The failure set is `(-∞, 1/2] ∪ [3/2, ∞)`: two components, so it is not an
interval — the counterexample hunt for the converse of the convexity theorem
succeeded (`hatNet_failure_set`, `hatNet_failure_not_convex`).

## 9. Cycle 3 evidence (`WidthLawsAndRelapses.lean`)

All tables below were produced with `#eval` on exact rationals (or `Float`
where a logarithm is involved) before the corresponding theorem was formalized.

### 9.1 Comb of hat units: linearly many relapses (M2)

`combNet 3 t = -1/2 + Σ_{i<3} bump i t`, `bump i t = relu(t-2i) - 2relu(t-2i-1)
+ relu(t-2i-2)`, on a half-integer grid:

| `t` | `0` | `1/2` | `1` | `3/2` | `2` | `5/2` | `3` | `7/2` | `4` | `9/2` | `5` | `11/2` | `6` | `13/2` | `7` |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `combNet 3 t` | `-1/2` | `0` | `1/2` | `0` | `-1/2` | `0` | `1/2` | `0` | `-1/2` | `0` | `1/2` | `0` | `-1/2` | `-1/2` | `-1/2` |

The failure set `{t : combNet 3 t ≤ 0}` is
`(-∞,1/2] ∪ [3/2,5/2] ∪ [7/2,9/2] ∪ [11/2,∞)`: four components for width
`3·3 = 9`, matching the proved lower bound `k+1 = 4`
(`combNet_failure_components_card`).  So relapses grow linearly in the width.

### 9.2 The width law under a non-i.i.d. but Cesàro-convergent signal (M1)

Unit signals `u j = 1 + (j mod 3)`, so `S_m/m → 2` and `c = -1`:

| `m` | 10 | 100 | 1000 | 10000 |
|---|---|---|---|---|
| `S_m/m` | `19/10` | `199/100` | `1999/1000` | `19999/10000` |
| `m·τ_m` | `10/19` | `100/199` | `1000/1999` | `10000/19999` |

`m·τ_m → 1/2 = |c|/L`, exactly the limit proved in `unitDelay_width_law`.
(The i.i.d. case is `iid_width_law_ae`, via the strong law of large numbers.)

### 9.3 Exponent competition: logarithm versus inverse square root (M3)

`K = D = 1`; the relaxation bound `log(1/μ)` against the bottleneck bound
`π/(2√μ)`:

| `μ` | `1e-1` | `1e-2` | `1e-3` | `1e-4` | `1e-6` | `1e-8` |
|---|---|---|---|---|---|---|
| `log(1/μ)` | `2.30` | `4.61` | `6.91` | `9.21` | `13.82` | `18.42` |
| `π/(2√μ)` | `4.97` | `15.71` | `49.67` | `157.08` | `1570.80` | `15707.96` |

The ratio diverges; no counterexample to the eventual domination was found, and
the domination is now a theorem (`log_delay_lt_bottleneck_delay`).
