# Computational Evidence — Round-6: the Noise-Floor Principle and the Trace-Lemma Frontier

All numbers below were produced by a short floating-point search *before* the Lean
formalisation, to test each conjecture for counterexamples and to calibrate the
constants that ended up in the theorem statements.  Every claim that survived is
now a machine-checked theorem in `Catalog/MachineLearning/NoiseFloor/`; the
numerics are exploratory only and are **not** part of the formal record.

Notation: spectrum `a : ι → ℝ≥0`, noise level `b > 0`, spectral filter `t`,
`risk(a,b,t) = Σ aᵢ(1-tᵢ)² + b tᵢ²`, `floor(a,b) = Σ aᵢb/(aᵢ+b)`.

## 1. Is the floor really a floor? (Conjecture C1)

20 000 random instances (`|ι| = 4`, `aᵢ ∈ [0,3]`, `b ∈ [0.1,2]`) with random
filters `tᵢ ∈ [-0.5, 1.5]`:

```
max over samples of (floor(a,b) - risk(a,b,t))  =  0.0     (never positive)
|risk(a, b, wiener) - floor(a,b)|               =  0.0     (attained exactly)
```

No counterexample; the Wiener filter `tᵢ = aᵢ/(aᵢ+b)` always meets the bound.
→ formalised as `filterRisk_ge_noiseFloor`, `filterRisk_wiener`,
`isLeast_filterRisk`, with uniqueness `filterRisk_eq_noiseFloor_iff`.

## 2. How far off is ridge? (Conjecture C3)

Spectrum `a = (1,0)`, flat covariance `mu = (1,1)`, `b = 1`.  Ridge is forced to
use one constant weight `c`:

| `c`   | 0    | 1/5  | **1/3**  | 1/2  | 1    |
|-------|------|------|----------|------|------|
| risk  | 1.00 | 0.72 | **0.667**| 0.75 | 2.00 |

Exact minimum `min_c (1-c)² + 2c² = 2/3` at `c = 1/3`, against
`floor = 1/2`.  Ratio `= 4/3`, and the Wiener optimum `(1/2, 0)` is *not*
constant.  → formalised as `ridge_strict_gap_two_modes` (bound) and
`ridge_gap_sharp` (attainment), plus `two_mode_wiener_not_constant`.

## 3. Head/tail sandwich (Conjecture C4)

Random `|ι| = 6`, `aᵢ ∈ [0,4]`, `b = 1`; `minSum = Σ min(aᵢ,b)`:

```
minSum/2 = 2.3772   floor = 3.0770   minSum = 4.7545
minSum/2 = 2.6735   floor = 3.8469   minSum = 5.3471
minSum/2 = 2.5139   floor = 3.3348   minSum = 5.0277
minSum/2 = 3.0000   floor = 4.2318   minSum = 6.0000
minSum/2 = 2.7951   floor = 4.1388   minSum = 5.5903
```

Sandwich holds in every sample and both ends are approached in the degenerate
one-mode limits.  → `half_minSum_le_noiseFloor`, `noiseFloor_le_minSum`,
`minSum_head_tail`, `sandwich_lower_sharp`, `sandwich_upper_sharp`.

## 4. Capacity frontier (Conjecture C5)

Random `|ι| = 6`, `aᵢ ∈ [0,4]`, `b = 0.7`:

```
effDim = 4.1634   ≤   logDet = 8.0436   ≤   trace/b = 20.0053
```

Single mode at the noise level (`a = b = 1`): `1/2 < log 2 = 0.6931 < 1`, so the
capacity strictly separates the two classical bounds.  → `effDim_le_logDet`,
`logDet_le_trace_div`, `capacity_frontier_strict`,
`logDet_eq_log_det_matrix`, `noiseFloor_le_capacity`.

## 5. Which spectrum is hardest? (Conjecture C6)

Fixed energy `S = 2`, `n = 5`, `b = 0.3`; 200 000 random spectra on the simplex:

```
max over random spectra   floor = 0.85712641
flat spectrum aᵢ = S/n    floor = 0.85714286
closed form S b n/(S+nb)        = 0.85714286
```

The maximum is approached but never exceeded by random spectra; the flat
spectrum matches the closed form to 8 digits.  → `noiseFloor_le_flat`,
`noiseFloor_flat_value`, `isGreatest_noiseFloor_of_energy`.

## 6. Early stopping versus matched ridge (Conjecture C7)

200 000 random one-mode instances (`mu, tau ∈ [0.01,10]`, `A ∈ [0,100]`,
`b ∈ [0.01,5]`), `u = mu·tau`, ridge `lam = 1/tau`:

```
max over samples of  risk(gradient flow) / risk(ridge)  =  1.68
```

so the formal constant `4` in `gradFlow_le_four_mul_ridge` is safe but not
sharp (the true worst case appears to be below `2`).  In the other direction:

```
A = e^20, tau = 10, mu = 1, b = 1:
  risk(gradient flow) = 1 + (1-e^{-10})² ≈ 2.00
  risk(matched ridge) = e^20/121 + 100/121 ≈ 4.01e6
  ratio ≈ 2.0e6
```

→ `gradFlow_le_four_mul_ridge` and `ridge_can_be_arbitrarily_worse`
(formalised with the conservative constant `100`).

## 7. Geometric scaling law (Conjecture C8)

`r = 1/2`, `n = 10`, `b = 1/10`, natural cut `m = 3`:

```
b(m+1)/2 = 0.200   ≤   floor = 0.38993   ≤   b(m+1) + b/(1-r) = 0.600
```

Ratio to the predicted law `b·log(1/b)/log(1/r)` as `b` shrinks (`n = 60`):

| `b`    | floor     | floor / (b log(1/b)/log(1/r)) |
|--------|-----------|-------------------------------|
| 0.1    | 0.39187   | 1.1797                        |
| 0.01   | 0.07154   | 1.0768                        |
| 0.001  | 0.01047   | 1.0503                        |

The ratio is bounded and drifts towards `1`, consistent with
`noiseFloor ≍ b log(1/b)/log(1/r)`.  → `geometric_scaling_upper`,
`geometric_scaling_lower`, `geometric_scaling_law`,
`geometric_scaling_law_example` (the first row is exactly the formal example).

## 8. Sequences / OEIS

No integer sequence arises: all objects here are continuous spectral functionals.
An OEIS search is therefore not applicable.

## 9. Counterexample hunt summary

| Conjecture | Status after search | Final disposition |
|---|---|---|
| C1 universal floor | no counterexample | proved |
| C2 uniqueness of minimiser | no counterexample | proved |
| C3 ridge optimal in general | **counterexample found** (§2) | disproved; replaced by the exact criterion `ridge_optimal_iff_self_similar` and the `4/3` separation |
| C4 head/tail sandwich with constant 1 on both sides | **counterexample** (factor 2 needed) | proved with the sharp constants `1/2, 1` |
| C5 capacity strictly between | no counterexample | proved |
| C6 flat spectrum is worst | no counterexample | proved |
| C7 ridge ≈ early stopping (two-sided) | **counterexample** (§6) | one-sided version proved |
| C8 geometric log-corrected law | no counterexample | proved (two-sided, explicit constants) |
