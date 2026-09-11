# Computational evidence: the root law for optimal batch size

Model under test (`BatchRootLaw.blockCostM`):

```
cost(k) = A/k + c + q·(k^(μ−1) − 1),      A, q > 0,  μ > 1
```

Conjectured minimiser and minimum:

```
k*   = (A / ((μ−1)·q))^(1/μ)
cost* = c − q + μ·(μ−1)^((1−μ)/μ)·A^((μ−1)/μ)·q^(1/μ)
```

All numbers below were produced with `#eval` on `Float` inside Lean 4 (exploratory
floating-point computation, **not** kernel-verified). Everything that is claimed as
established is proved separately and sorry-free in
`Catalog/Computation/BatchSubquadraticRootLaw.lean`,
`Catalog/Computation/BatchRootLawGeometry.lean`,
`Catalog/Computation/BatchRootLawDiscrete.lean` and
`Catalog/Computation/BatchCrossoverRoot.lean`.

## 1. Predicted optimum vs. brute-force grid search

Grid: `k = 0.5, 1.0, …, 100000` (200 000 points), `c = 0`.

| A | q | μ | predicted `k*` | grid argmin | predicted `cost*` | grid min |
|---|---|---|---|---|---|---|
| 1000 | 1e−3 | 2.000 | 1000.0000 | 1000.0 | 1.999000 | 1.999000 |
| 1000 | 1e−3 | 1.585 | 8558.4235 | 8558.5 | 0.315577 | 0.315577 |
| 1000 | 1e−3 | 1.500 | 15874.0105 | 15874.0 | 0.187988 | 0.187988 |
| 5000 | 1e−2 | 1.585 | 5526.7458 | 5526.5 | 2.441173 | 2.441173 |

The grid argmin agrees with `k*` to the grid resolution and the grid minimum agrees
with `cost*` to all printed digits in every case. No counterexample to uniqueness
was found: the sampled cost curve is strictly decreasing before the argmin and
strictly increasing after it (this is now the theorem `blockCostM_unimodal`).

## 2. Degeneration as μ ↓ 1 ("bigger is always better")

`A = 1000`, `q = 1e−3`:

| μ | 2.000 | 1.585 | 1.500 | 1.200 | 1.100 | 1.050 |
|---|---|---|---|---|---|---|
| `k*` | 1.00e3 | 8.56e3 | 1.59e4 | 3.82e5 | 2.31e6 | 8.98e6 |

`k*` grows without bound, matching `optBatch_ge_of_mu_close_to_one` and the exact
`μ = 1` statement `no_optimum_of_mu_one` (the penalty term vanishes identically,
so the cost is strictly decreasing in `k`).

## 3. Flatness of the optimum

`A = 1000`, `q = 1e−3`, `μ = 1.585`, `k = θ·k*`; excess = `cost(θk*) − cost*`,
bound = `q (k*)^(μ−1) (μ−1)(θ−1)²/θ` (the bound proved in
`blockCostM_near_opt`):

| θ | 0.50 | 0.80 | 1.00 | 1.25 | 2.00 |
|---|---|---|---|---|---|
| excess | 0.05026 | 0.004768 | 0.0 | 0.004482 | 0.04145 |
| bound  | 0.05842 | 0.005842 | 0.0 | 0.005842 | 0.05842 |

The bound holds in every sample and is tight to within ~15 %: mis-sizing the batch
by a factor of two costs only a few percent of the optimal excess cost.

## 4. Counterexample hunt: is the cost convex in `k`?

For `μ = 2` the cost is convex. For `μ < 2` a short scan over
`(k₁, k₂)` pairs turned up violations of the midpoint inequality; the smallest
clean witness with integer data is `μ = 3/2`, `A = q = 1`, `c = 0`:

```
cost(4)   = 1.250000
cost(100) = 9.010000
average   = 5.130000
cost(52)  = 6.230333   >  5.130000
```

So ordinary (additive) convexity **fails**, while the geometric-mean inequality
was never violated in any sample. Both observations are now theorems:
`blockCostM_not_convex_of_subquadratic` and `blockCostM_geom_convex`.

## 5. Crossover thresholds

Calibrating to the measured schoolbook crossover `M* = 1715`
(`(s₁ − c₁)/q = 1714`), the root-form crossover
`(1 + (s₁−c₁)/q)^(1/(μ−1))` gives

| μ | 2 | 3/2 | 4/3 | 1.2 |
|---|---|---|---|---|
| crossover | 1.715e3 | 2.941e6 | 5.044e9 | 1.49e16 |

i.e. the reversal is pushed out of any realistic deployment range as soon as the
multiplication exponent drops below 2 — the content of
`crossover_ge_of_mu_le_two` and `crossover_karatsuba_calibrated`.

## 6. OEIS

No integer sequence arises: all objects here are real-analytic functions of
continuous parameters, so an OEIS search is not applicable.
