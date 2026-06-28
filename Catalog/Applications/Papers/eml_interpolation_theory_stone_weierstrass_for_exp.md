# Computational Evidence — Multivariate EML Jackson Rate & LogSumExp

This evidence supports the two new Lean files

* `EML/MultivariateLipschitzRate.lean` — the `d`-dimensional Jackson rate
  (curse of dimensionality);
* `EML/LogSumExpMax.lean` — the `d`-variable LogSumExp smoothing of `max`.

All numbers below were computed with Lean `#eval` over `Float`.

## 1. LogSumExp bound `0 ≤ lse t x − max x ≤ (log d)/t`

Sample: `d = 3`, `x = (1, 0.5, −1)`, so `max x = 1`.

| `t`   | `lse t x` | `max x` | `max x + (log 3)/t` |
|-------|-----------|---------|---------------------|
| 4     | 1.031806  | 1       | 1.274653            |
| 20    | 1.000002  | 1       | 1.054930            |
| 100   | 1.000000  | 1       | 1.010986            |

Observations:
* `lse t x ≥ max x` always (over-approximation) — matches `lse_ge_max`.
* `lse t x ≤ max x + (log d)/t` — matches `lse_le_max` (at `t = 4` the slack
  `0.0318 ≤ 0.2747 = log 3/4`).
* `lse t x → max x` as `t → ∞` with rate `O(1/t)` — matches `lse_tendsto_max`.
* For `d = 2` the constant is `log 2`, exactly the catalog's `softmax_error`
  (`EML.AlgebraicMaxClosure`), recovered in `lse_error_dim_two`.

## 2. Multivariate Jackson width (curse of dimensionality)

Construction error is `L·d/(2n)`; the grid approximant takes `≤ (n+1)^d` values.
To reach accuracy `ε` we take `n = ⌈L·d/(2ε)⌉`, width `(n+1)^d`.

Sample: `L = 1`, `ε = 0.1`.

| `d` | `n` (`⌈d/(2ε)⌉`) | width `(n+1)^d` |
|-----|------------------|-----------------|
| 1   | 5                | 6               |
| 2   | 10               | 121             |
| 3   | 15               | 4096            |
| 5   | 25               | 11,881,376      |

The width grows like `ε^{-d}` (exponential in the dimension `d`) while the
*per-coordinate* resolution `n` grows only linearly — this is precisely the
mission's conjectured `O(ε^{-n/α})` exponent at `α = 1`, `n = d`.

## 3. Counterexample hunt

* LogSumExp lower bound `lse ≥ max` tested on randomized inputs and temperatures
  `t ∈ {0.1,…,100}`: no violation found (and it is now a theorem).
* The slack upper bound was probed near its tight regime `x = const` (all
  coordinates equal), where the slack equals `(log d)/t` exactly — consistent
  with the analytic claim, no counterexample.

## 4. Why no OEIS entry

Both results are continuous-analytic (rates/inequalities), not integer
sequences, so no OEIS lookup applies. The only integer data — the widths
`(n+1)^d` — are ordinary powers and carry no further combinatorial structure.
