# Computational Evidence — NET-96 cost law

All numbers below were recomputed in exact rational arithmetic before any Lean
proof was attempted; every claim marked **[verified]** is additionally backed by
a `sorry`-free Lean theorem in `Catalog/Computation/`. Claims marked
*(exploratory)* were computed in scratch rational arithmetic only and are not
part of the formal deliverable.

## 1. Provenance of the survival vectors

The mission brief records summary statistics of the NET-96 sweep, not the raw
per-cell table. The vectors used in `SpeculativeSurvivalNet96.lean` are a
reconstruction pinned by every reported anchor:

| anchor reported for NET-96 | reconstruction |
|---|---|
| overhead `c = 0.118` | `costRate = 118/1000` |
| prose `s₁ = 0.670`, `s₅ = 0.119 < s₁/2` | `proseSurv 0 = 0.670`, `proseSurv 4 = 0.119` |
| three differenced values `> 1` | prose pos. 2; code pos. 2, 4 |
| one differenced value `< 0` | prose pos. 7 (`−0.030`) |
| measured optima: prose 4, code 8 | reproduced, see §2 |

Everything proved is a statement about these explicit vectors; nothing is
asserted about unrecorded runs. The file header repeats this caveat.

## 2. Cost-law table (exact rationals, `c = 118/1000`)

prose: `s = (0.670, 1.050, 0.420, 0.860, 0.119, 0.050, −0.030, 0.100)`

| d | A(d)=Σ s | gain = A/(1+cd) |
|---|---|---|
| 1 | 0.670 | 0.5993 |
| 2 | 1.720 | 1.3916 |
| 3 | 2.140 | 1.5805 |
| 4 | **3.000** | **2.0380** |
| 5 | 3.119 | 1.9616 |
| 6 | 3.169 | 1.8554 |
| 7 | 3.139 | 1.7191 |
| 8 | 3.239 | 1.6662 |

code: `s = (0.820, 1.120, 0.910, 1.060, 0.780, 0.830, 0.740, 0.690)`

| d | A(d) | gain |
|---|---|---|
| 1 | 0.820 | 0.7335 |
| 2 | 1.940 | 1.5696 |
| 3 | 2.850 | 2.1049 |
| 4 | 3.910 | 2.6562 |
| 5 | 4.690 | 2.9497 |
| 6 | 5.520 | 3.2319 |
| 7 | 6.260 | 3.4283 |
| 8 | **6.950** | **3.5751** |

**[verified]** `prose_argmax_eq_four`, `code_argmax_eq_eight`: argmax = 4 / 8,
matching the directly measured optima. **[verified]** and, with the curves
extended by zero past the unmeasured horizon, these are global optima over all
depths (`prose_global_optimum_four`, `code_global_optimum_eight`); the marginals
are `+0.670, +1.095, +0.316, +0.912` at depths 0–3 and negative from depth 4 on
for prose, so the single-crossing condition holds even though the curve is not
antitone.

## 3. Robustness radius (counterexample hunt for the argmax)

Using the exact bound `|Δgain(d)| ≤ ε·d/(1+cd)`, the largest sup-norm
perturbation `ε` that provably cannot move the argmax is

* prose: `ε* = 0.01303…` (binding competitor `d = 5`, gap 0.0764),
* code:  `ε* = 0.01847…` (binding competitor `d = 7`, gap 0.1468).

**[verified]** at the certified radius `ε = 1/100 < min(ε*)`:
`prose_argmax_robust`, `code_argmax_robust`. No perturbation below that radius
is a counterexample; above `ε*` the bound is no longer sufficient (the technique,
not necessarily the conclusion, fails there).

## 4. Differencing noise amplification

For `ŝ_d = d·m̂(d) − (d−1)·m̂(d−1)` with `|m̂ − m| ≤ δ`:

| position i (0-based) | worst-case per-position error | worst-case cumulative error |
|---|---|---|
| 1 | 3δ | 2δ |
| 3 | 7δ | 4δ |
| 7 | 15δ | 8δ |

Ratio `(2i+1)/(i+1) → 2`: differencing asymptotically doubles the relative noise.
**[verified]** `diffSurv_error_bound` (upper bound), `diffSurv_error_tight`
(the bound is attained by an alternating-sign aggregate error), and
`diffSurv_amplification_ratio` (ratio bracketed in `[3/2, 2)` for `i ≥ 1`).

## 5. Calibrated geometric model

With `c = 0.118` and a single geometric acceptance rate `r = 0.8`, the marginal
`M(d) = rᵈ(1+cd) − c·(1−rᵈ)/(1−r)` evaluates to

| d | 5 | 6 | 7 | 8 |
|---|---|---|---|---|
| M(d) | +0.1243 | +0.0124 | −0.0833 | −0.1649 |

so the sign change is between 6 and 7 and the optimum is `d = 7`, lying between
the two measured register optima — a single-rate model cannot reproduce a
register split. **[verified]** `geom_example_optimal_depth_seven`.

## 6. Sequence search

No integer sequence arises here (the observables are rational throughput ratios),
so no OEIS lookup applies.
