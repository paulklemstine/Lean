# Computational Evidence

Concise numerical sanity checks for the claims later proved in Lean.  All values are exact or
to 4 decimals.

## 1. Maslov dequantization `(1/t)·log(e^{tx}+e^{ty}) → max x y`

Take `x = 3`, `y = 1` (so `max = 3`).  The universal sandwich predicts
`3 ≤ value ≤ 3 + (log 2)/t = 3 + 0.6931/t`.

| t   | (1/t)·log(e^{3t}+e^{t}) | 3 + (log2)/t | error      |
|-----|-------------------------|--------------|------------|
| 1   | 3.1269                  | 3.6931       | 0.1269     |
| 2   | 3.0090                  | 3.3466       | 0.0090     |
| 5   | 3.0000045               | 3.1386       | 4.5e-6     |
| 10  | 3.0000000002            | 3.0693       | 2e-10      |

Error → 0, always positive, always below `(log 2)/t`.  Consistent with `logAddExp_lower`,
`logAddExp_upper`, `tendsto_logAddExp_max`.  For `x = y = 2`: value `= 2 + (log 2)/t` exactly
(e.g. `t=1 → 2.6931`), confirming the worst case is the diagonal (Conjecture 1).

Exact multiplication: `(1/t)·log(e^{tx}·e^{ty}) = x + y` for every `t` (no limit needed),
matching `logMulExp_eq`.

## 2. Tropical Bézout / asymptotic slopes for `tropPoly a d`

Coefficients `a = [0, 0, 0]`, degree `d = 2`, so `tropPoly x = min(0, x, 2x)`.

| x    | min(0, x, 2x) | active term | local slope |
|------|---------------|-------------|-------------|
| -3   | -6            | 2x          | 2           |
| -1   | -2            | 2x          | 2           |
|  0   |  0            | 0/x/2x tie  | corner      |
|  1   |  0            | 0           | 0           |
|  3   |  0            | 0           | 0           |

Left slope `= 2 = d`, right slope `= 0`.  Total slope drop `= 2 = d`: tropical Bézout
(`tropical_bezout_slope_drop`).  Roots (corners, min attained twice): here `x = 0` is a double
root (slope drop 2).  For `a = [0, -1, -3]`: `min(0, x-1, 2x-3)` has two simple corners at
`x = 1` and `x = 2`, total slope drop `2 = d` again — multiplicities sum to the degree
regardless of coefficients.

## 3. Binary corner `min(c₀+b₀x, c₁+b₁x)`

`b₀ = 0, c₀ = 0, b₁ = 1, c₁ = -2`: `binRoot = (0-(-2))/(1-0) = 2`.  Left of `2`, the `1·x-2`
piece is smaller (slope 1); right of `2`, the constant `0` piece wins (slope 0).  Slope drop
`= b₁ - b₀ = 1 > 0`: a genuine corner (`binTrop_corner`); away from `x = 2` the function is a
single line (`binTrop_smooth_off_root`).

## 4. Convexity signs

`min(0, x, 2x)` is concave (a downward kink at `0`); its superlevel sets `{x | c ≤ tropPoly x}`
are intervals (convex).  `max(0, x, 2x)` is convex; its sublevel sets are intervals.  Matches
`tropPoly_concaveOn`, `tropicalQuadratic_convexOn`, and the bridge to
`Geometry.SublevelDuality.convex_le_of_convexOn`.

## OEIS

No new integer sequence is introduced; the only sequence is the trivial degree/slope-drop
identity `slope(-∞) - slope(+∞) = d`.
