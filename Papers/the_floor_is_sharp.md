# Computational evidence — PTX no-starvation floor and its sharp factor `2`

All numbers below were produced by direct floating-point evaluation of the model
(`gridCeil 2 x = 2^⌈log₂ x⌉`) before the Lean formalisation.  Every claim that the evidence
suggested is now a machine-checked theorem in `Catalog/Physics/PTXStarvation*.lean`; the tables
are exploratory only and are *not* themselves a verification.

## 1. Slack of the dyadic arbiter on small cases

`ideal = γ d / (β log(1/p) + M + γ − r)`; `service = 2^⌈log₂ ideal⌉`; `slack = service/ideal`.

| ideal `x` | service | slack |
|---|---|---|
| 0.30 | 0.5 | 1.666667 |
| 0.50 | 0.5 | 1.000000 |
| 0.75 | 1.0 | 1.333333 |
| 1.00 | 1.0 | 1.000000 |
| 1.25 | 2.0 | 1.600000 |
| 1.50 | 2.0 | 1.333333 |
| 1.90 | 2.0 | 1.052632 |
| 2.00 | 2.0 | 1.000000 |
| 2.10 | 4.0 | 1.904762 |
| 3.00 | 4.0 | 1.333333 |
| 5.00 | 8.0 | 1.600000 |
| 7.90 | 8.0 | 1.012658 |
| 8.00 | 8.0 | 1.000000 |

Observations that became theorems:

* every slack lies in `[1, 2)` → `ptx_no_starvation`, `ptx_service_lt_two_ideal`,
  `ptx_slack_mem_Ico`;
* slack `= 1` exactly on powers of two → `ptx_service_eq_ideal_iff`, `ptx_floor_attained`;
* slack approaches `2` from below just above a power of two (`x = 2.1 → 1.9048`;
  `x = 1 + δ → 2/(1+δ)`) → `ptx_ratio_approaches_two`, `ptx_slack_spectrum_eq`;
* slack is unchanged under `x ↦ 2x` (`0.75 → 1.5 → 3`, all `1.333…`) → `ptx_slack_log_periodic`.

## 2. Counterexample hunt for the universal claims

* Attempt to find an instance with `slack ≥ 2`: swept `x` over `10⁶` log-uniform samples in
  `[10⁻⁶, 10⁶]`; maximal observed slack `1.9999985`, never `≥ 2`.  Consistent with the strict
  ceiling `ptx_service_lt_two_ideal`.
* Attempt to find an instance with `slack < 1`: none; minimum observed `1.0000001` on the random sweep, and exactly `1.0` at powers of two.  Consistent with the floor and with `ptx_floor_constant_optimal`.
* Attempt to beat `2` by phase randomisation: sweeping `θ` over a `10⁴`-point grid the maximal
  slack still reaches `1.9999998`; formalised as `jitterCeil_lt` plus
  `ptx_two_optimal_ceiling_iff`.

## 3. The slack orbit of a single exchange (ternary demand growth `α = 3`)

`logSlack(3ⁿ) = fract(−n log₂ 3)`, first values:

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|---|
| logSlack | 0.000000 | 0.415037 | 0.830075 | 0.245112 | 0.660150 | 0.075187 | 0.490225 | 0.905262 | 0.320300 | 0.735337 |

These are the orbit of the rotation by `−log₂ 3 ≈ −1.584963` on `ℝ/ℤ`; empirically it fills
`[0,1]` (max `0.999…`, min `0.000…` over `2·10⁵` steps).  Formalised as
`ptx_slack_orbit_dense_of_irrational`, `ptx_ternary_growth_saturates`, with the required
Diophantine input `irrational_logb_two_three` proved from `3^q = 2^p`.

Rational contrast: for `α = 4` one has `log₂ 4 = 2 ∈ ℚ`, and the orbit collapses to the single
value `0` (slack `≡ 1`), matching `logSlack_zpow_periodic` /
`ptx_slack_orbit_finite_of_rational`.

## 4. Average slack under jitter

Sampling `2·10⁵` orbit points of the `α = 3` ladder:

| quantity | empirical | proved value |
|---|---|---|
| mean log-slack | 0.500009 | `1/2` (`jitter_mean_log_slack`) |
| geometric-mean slack | 1.414223 | `√2 ≈ 1.4142136` (`jitter_geometric_mean_slack`) |
| arithmetic-mean slack | 1.442704 | `1/log 2 ≈ 1.4426950` (`ptx_dyadic_mean_slack`) |
| max slack | 1.999993 | supremum `2`, never attained |

## 5. Grid cost `ρ / log ρ`

| ρ | 1.5 | 2 | e | 3 | 4 | 8 |
|---|---|---|---|---|---|---|
| ρ/log ρ | 3.699455 | 2.885390 | 2.718282 | 2.730718 | 2.885390 | 3.847187 |

Two features of this table became theorems: the minimum at `ρ = e`
(`exp_one_le_gridCost`, `exp_one_lt_gridCost_of_ne`, `gridCost_exp_one`) and the exact
coincidence of the `ρ = 2` and `ρ = 4` entries (`gridCost_four_eq_gridCost_two`).  The ratio
`(2/log 2)/e = 1.061476` is the source of the `7 %` bound `dyadic_gridCost_lt`.

## 6. OEIS

The exponent sequence `⌈log₂ n⌉` for `n = 1, 2, 3, …` is `0, 1, 2, 2, 3, 3, 3, 3, 4, …`
(OEIS A029837, "binary order of n"), which is the discrete shadow of `gridCeil 2`; no new
integer sequence arose in this project, so no further OEIS search was warranted.
