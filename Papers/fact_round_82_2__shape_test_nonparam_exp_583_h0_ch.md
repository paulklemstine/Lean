# Computational Evidence — shape/leakage decomposition (exp 583 thread)

All numbers below were produced with double-precision floating-point evaluation before the
Lean formalisation; they are *evidence*, not proof. Every claim they support is proved
without `sorry` in `Catalog/Novelty/ShapeTestMonotoneDecline.lean`.

## 1. The power law has no interior mode, but is genuinely nonlinear

`T(x) = C (1+x)^(-a)` with `C = 0.0295`, `a = 1.104` on the window `[0,1]`, decile samples
(`x = 0.05, 0.15, …, 0.95`), values ×10⁴:

| x | 0.05 | 0.15 | 0.25 | 0.35 | 0.45 | 0.55 | 0.65 | 0.75 | 0.85 | 0.95 |
|---|------|------|------|------|------|------|------|------|------|------|
| T(x)·10⁴ | 279.5 | 252.8 | 230.6 | 211.8 | 195.7 | 181.8 | 169.7 | 159.0 | 149.6 | 141.1 |

Strictly declining, exactly as the reported deciles `[1554 … 694]`. The peak/end ratio over
`[0,1]` is `2^1.104 = 2.1495`; a *measured* ratio of `2.54` over the same window inverts (via
`exponent_eq_log_ratio`) to `a = log 2.54 / log 2 = 1.3448 > 1`, i.e. the steepness test
`exponent_gt_one_of_ratio_gt_window` fires whenever the measured ratio exceeds the window
ratio `ρ = (1+u)/(1+l)`.

Nonlinearity check (midpoint gap, the quantity that `rateT_log_not_affine` makes strict):
with `a = 1.104`, `l = 0`, `u = 1`, `m = 0.5`,
`½(log T(l) + log T(u)) − log T(m) = a·[log 1.5 − ½(log 1 + log 2)] = 1.104 × 0.05890 = 0.0650 > 0`,
i.e. the log rate at the midpoint lies strictly *below* the chord — convex curvature.
So no affine-in-`x` log model can interpolate the three points — the LRT rejection is real,
and it is *convex* curvature, which cannot make a hump.

## 2. The ghost peak sits at the logarithmic mean

Residual `R(x) = d·log(1+x) + b·x` with `d = 0.5` and `b` the endpoint-matching tilt
`b = −d(log(1+u) − log(1+l))/(u − l)`. Numerical argmax on a 20001-point grid vs. the
predicted logarithmic-mean location `L(1+l, 1+u) − 1`:

| window `[l,u]` | grid argmax | `logMean(1+l,1+u) − 1` | `R(l)` | `R(u)` | relative position |
|---|---|---|---|---|---|
| [0, 1]     | 0.44270 | 0.44270 | 0.0 | 0.0 | 0.4427 |
| [0.02, 1]  | 0.45541 | 0.45542 | 0.0030304 | 0.0030304 | 0.4443 |
| [0, 3]     | 1.16400 | 1.16404 | 0.0 | 0.0 | 0.3880 |
| [0.1, 0.9] | 0.46376 | 0.46374 | 0.0134961 | 0.0134961 | 0.4547 |

Endpoint values agree to machine precision (as `logResidual_edges_eq` proves), and the
maximiser matches `logMean − 1` to grid resolution (as `ghost_peak_eq_logMean` +
`logResidual_strict_max` prove). Unit window: `1/log 2 − 1 = 0.4426950409`, bracketed in Lean
by `ghost_peak_unit_window_gt/lt` as `0.4426 < · < 0.4428`.

The peak location is **independent of the mismatch size `d`** (it cancels in `−d/b`), which is
why a purely denominator-side curvature error reproduces a stable mid-window bump. The
observed blip near relative position `≈0.55–0.65` is of the same order as, but not identical
to, the leakage prediction `≈0.44` for the windows tabulated here; the leakage mechanism is
therefore a *sufficient* explanation of a mid-window bump, and the exact relative location is
window-dependent (`0.388` for `[0,3]`, `0.455` for `[0.1,0.9]`).

## 3. Counterexample hunt

* Searched for an interior maximiser of `T(x) = C(1+x)^(-a)` on 10⁵-point grids over windows
  `[0,1]`, `[0.02,1]`, `[0,3]` and exponents `a ∈ {0.1, 0.5, 1.104, 3}`: none found; the
  maximum is always at the left edge (consistent with `rateT_no_interiorMode`).
* Searched for a *strict* interior maximiser of an affine residual on the same grids: none
  found (consistent with `no_strictInteriorMode_of_affine`).
* Searched for a window on which the log-mean prediction fails: none; `A < L(A,B) < B` held on
  every tested pair, matching `logMean_mem_Ioo`.

## 4. OEIS

No integer sequence arises here (all objects are real-analytic), so no OEIS lookup applies.
