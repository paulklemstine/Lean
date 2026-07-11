# Computational Evidence

Two exactly-solvable statistical-mechanics models are formalized, each exhibiting
a phase transition in an order parameter as a coupling crosses a critical value.
Below is numerical evidence gathered by fixed-point iteration before the Lean
proofs were written. All formalized inequalities are confirmed.

## 1. Mean-field Ising / Curie–Weiss ferromagnet: `m = tanh(β m)`

Order parameter `m` (spontaneous magnetization), critical inverse temperature
`β_c = 1`. Fixed point obtained by iterating `m ↦ tanh(β m)`.

| β    | m*        | lower bound `√(3(β−1)/β³)` |
|------|-----------|----------------------------|
| 0.50 | 0.000000  | –                          |
| 0.90 | 0.000000  | –                          |
| 1.00 | 0.0 (→0)  | 0.000000                   |
| 1.01 | 0.173194  | 0.170639                   |
| 1.10 | 0.502941  | 0.474757                   |
| 1.50 | 0.858560  | 0.666667                   |
| 2.00 | 0.957504  | 0.612372                   |
| 3.00 | 0.994902  | 0.471405                   |

* For `β ≤ 1` the iteration collapses to `m = 0`
  (`magnetization_eq_zero_of_subcritical`).
* For `β > 1` a positive fixed point appears
  (`exists_pos_magnetization_of_supercritical`).
* The lower bound `√(3(β−1)/β³) ≤ m*` holds in every supercritical row
  (`magnetization_sq_ge_of_supercritical`), and near `β = 1` the ratio
  `m* / √(3(β−1)/β³) → 1`, confirming the mean-field critical exponent `1/2`.
* Near criticality (`β = 1.00`) convergence is slow (marginal fixed point); the
  limit is `0`, consistent with the subcritical/critical theory.

## 2. Erdős–Rényi / Poisson-branching percolation: `ρ = 1 − exp(−λ ρ)`

Order parameter `ρ` (survival probability / giant-component fraction), critical
connectivity `λ_c = 1`. Fixed point obtained by iterating `ρ ↦ 1 − exp(−λ ρ)`.

| λ    | ρ*        | lower bound `2(λ−1)/λ²` |
|------|-----------|-------------------------|
| 0.50 | 0.000000  | –                       |
| 0.90 | 0.000000  | –                       |
| 1.00 | 0.0 (→0)  | 0.000000                |
| 1.01 | 0.019867  | 0.019606                |
| 1.10 | 0.176134  | 0.165289                |
| 1.50 | 0.582812  | 0.444444                |
| 2.00 | 0.796812  | 0.500000                |
| 3.00 | 0.940480  | 0.444444                |

* For `λ ≤ 1` only `ρ = 0` survives
  (`survivalProb_eq_zero_of_subcritical`).
* For `λ > 1` a positive `ρ ∈ (0,1)` emerges
  (`exists_pos_survivalProb_of_supercritical`).
* The lower bound `2(λ−1)/λ² ≤ ρ*` holds in every supercritical row
  (`survivalProb_ge_of_supercritical`), and near `λ = 1` the ratio
  `ρ* / (2(λ−1)/λ²) → 1`, confirming the mean-field percolation exponent `1`
  (linear onset), contrasting the `1/2` exponent of model 1.

## Counterexample hunt

No counterexample to the formalized statements was found. The only subtlety is
the *critical point* `β = λ = 1` itself, where the fixed-point iteration converges
only marginally to `0`; this is fully consistent with the proved subcritical
uniqueness (which includes the boundary `β ≤ 1`, `λ ≤ 1`).

## OEIS

No integer sequence arises; the objects are transcendental fixed points, so an
OEIS search is not applicable.
