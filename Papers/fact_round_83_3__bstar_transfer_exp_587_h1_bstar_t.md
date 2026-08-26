# Computational evidence

All numeric claims that appear in the Lean files are *proved there* (rational
arithmetic, `norm_num`); the exploration below is what suggested them.  Where a
number comes only from a scratch script it is explicitly marked **unverified**.

## 1. The object

For orthogonal columns `v_0, …, v_{m-1}` and response `y`, with per-column data
`a_i = ⟪v_i, y⟫`, `s_i = ‖v_i‖²` and weights `w_i`, the prefix score is

```
R²(w, B) = (Σ_{i<B} w_i a_i)² / ( (Σ_{i<B} w_i² s_i) · ‖y‖² ).
```

This is the exact `R²` of the OLS regression of `y` on the window statistic
`S_{w,B} = Σ_{i<B} w_i v_i` (`Model.R2_eq_Rsq`, `rss_decomposition`).

## 2. Small-case curves (all of these are Lean-verified)

| model | `a` | `s` | weight | curve `R²(0..m)` | Lean theorem |
|---|---|---|---|---|---|
| 4 orthonormal columns, `y = (1,1,0,0)` | `1,1,0,0` | `1,1,1,1` | `1` | `0, 1/2, 1, 2/3, 1/2` | `saturationExample_curve` |
| order-4 Hadamard rows, `y = (2,0,2,0)` | `4,4,0,0` | `4,4,4,4` | `1` | `0, 1/2, 1, 2/3, 1/2` | `hadamardExample_curve` |
| 3 orthonormal columns, `y = (3,1,1)` | `3,1,1` | `1,1,1` | `1` | `0, 9/11, 8/11, 25/33` | `bimodalExample_curve` |
| same, matched weight `a_i/s_i` | — | — | `3,1,1` | `9/11, 10/11, 1` | `bimodalExample_matched_curve` |

The first two rows exhibit the empirical shape: rise, interior peak, decay ("the
window saturates at an interior `B*`"). The third shows a *dip*: the curve falls
and then rises again, so the argmax landscape has two local maxima.

## 3. Counterexample hunt: is the curve unimodal?

Conjecture tested: *if the columns are orthogonal with equal mass and are sorted
by decreasing per-column efficiency `a_i / s_i`, the prefix curve is unimodal.*

Random search over decreasing nonnegative signal vectors with unit masses
(100 000 trials, lengths 3–7, entries drawn from `{0} ∪ U(0,1) ∪ 100·U(0,1)`):
**0.49 % of instances have two or more local maxima** (unverified scratch
computation).  The smallest witness found, and the one formalised, is

```
a = (3, 1, 1),  s = (1, 1, 1),  ‖y‖² = 11
prefix numerators  A = 3, 4, 5
curve  A²/(k‖y‖²) = 9/11, 8/11, 25/33  ≈  0.818, 0.727, 0.758
```

so `R²(1) > R²(2) < R²(3)`: a strict interior local minimum.  This is proved in
Lean as `bimodalExample_dip` and `bimodalExample_not_unimodal`; the efficiencies
`3 ≥ 1 ≥ 1` are checked in `bimodalExample_efficiency_antitone`.  Conclusion:
**unimodality is false**, so a second bump in a bootstrap argmax distribution is
not by itself evidence of estimator noise.

Under the matched weight the same data give the strictly increasing curve
`9/11, 10/11, 1` — the dip is a property of the weight, not of the columns
(`bimodalExample_matched_curve`, and in general `matched_curve_monotone`).

## 4. Where the interior peak comes from

The exact one-step change (`R2_step_identity`) is

```
R²(B+1) − R²(B) = ( S·p·(2A+p) − A²·c ) / ( S·(S+c)·‖y‖² ),
A = Σ_{i<B} w_i a_i,  S = Σ_{i<B} w_i² s_i,  p = w_B a_B,  c = w_B² s_B.
```

Two immediate consequences, both formalised:

* `p = 0`, `c > 0`, `A ≠ 0` ⇒ strict decrease (`noise_dilutes`): a window step
  that adds only columns orthogonal to the response *strictly dilutes* the score.
  Saturation is dilution, not flattening.
* `p·S ≥ A·c`, `p, A, S > 0` ⇒ strict increase (`matched_step_increases`).

Hence the matched-signal-then-noise model has a unique interior argmax
(`unique_interior_argmax`), while the matched filter is monotone and plateaus
(`matched_curve_monotone`, `matched_plateau`).

## 5. Peak margin (the "near-tie" arithmetic)

`peak_margin_eq`: in a signal-then-noise window,

```
R²(t) − R²(m) = R²(t) · ( ‖S_m‖² − ‖S_t‖² ) / ‖S_m‖² .
```

For the Hadamard example: `R²(2) − R²(4) = 1 · (16−8)/16 = 1/2`
(`hadamardExample_peak_margin`).  A near-tie between the interior peak and the
edge window therefore means precisely that the mass added after the peak is a
small fraction of the total mass — not that the two windows carry comparable
signal.

## 6. Realisability check

Before proving `interior_argmax_realizable` (every interior location `1 ≤ t < m`
occurs for the response `y = v_0 + ⋯ + v_{t-1}`), the construction was checked on
`m = 5` orthonormal columns: the resulting signals are `a = (1,…,1,0,…,0)` with
`t` ones, giving the curve `k²/(k·t) = k/t` for `k ≤ t` and `t/k` afterwards —
peak exactly at `t`, for each `t = 1,2,3,4` (unverified scratch computation; the
general statement is the Lean theorem).

## 7. OEIS

No integer sequence is produced by this development: the objects are rational
score curves depending on continuous data, and the two families of examples give
`0, 1/2, 1, 2/3, 1/2` and `0, 9/11, 8/11, 25/33`.  No OEIS match was sought or
claimed.
