# Computational Evidence — Split Geometry

We study the split metric `ds² = dx²/cosh²(y) + cosh²(x) dy²` on `ℝ²` and its
posited curvature function `K(x,y) = sech²(x) − sech²(y) = 1/cosh²(x) − 1/cosh²(y)`.

## 1. Sample values of `K`

Computed with `kf x y = 1/cosh²(x) − 1/cosh²(y)` (Lean `Float`):

| (x, y)      | K(x, y)   | region (by \|x\| vs \|y\|) |
|-------------|-----------|----------------------------|
| (0, 1)      |  +0.580   | \|x\| < \|y\|  ⇒ K > 0     |
| (1, 0)      |  −0.580   | \|y\| < \|x\|  ⇒ K < 0     |
| (2, 2)      |   0.000   | \|x\| = \|y\|  ⇒ K = 0     |
| (2, −2)     |   0.000   | \|x\| = \|y\|  ⇒ K = 0     |
| (0.5, 1.5)  |  +0.606   | \|x\| < \|y\|  ⇒ K > 0     |
| (3, 1)      |  −0.410   | \|y\| < \|x\|  ⇒ K < 0     |
| (1, 3)      |  +0.410   | \|x\| < \|y\|  ⇒ K > 0     |
| (0, 0)      |   0.000   | \|x\| = \|y\|  ⇒ K = 0     |

Observations, all later proved in `Algebra/SplitGeometry.lean`:

* `K = 0` exactly when `|x| = |y|` (the diagonals `y = ±x`): the **phase boundary**.
* `|x| < |y| ⇒ K > 0`; `|y| < |x| ⇒ K < 0`.
* `K(x,y) = −K(y,x)` (antisymmetry): compare `(3,1)` with `(1,3)`, `(0,1)` with `(1,0)`.
* All values lie strictly inside `(−1, 1)` (boundedness `|K| < 1`).

## 2. Correction to the informal conjecture

The informal statement labels `|x| > |y|` as *elliptic* (`K > 0`) and `|y| > |x|`
as *hyperbolic* (`K < 0`).  The table shows the **opposite** signs for the posited
function `K = sech²x − sech²y`: e.g. at `(1,0)` we have `|x| > |y|` but
`K = −0.58 < 0`.  Reason: `cosh` is strictly increasing in `|·|`, so a larger
`|x|` gives a *smaller* `sech²x`.  The theorems record the mathematically correct
signs.  The zero set / phase boundary along `y = ±x` is exactly as conjectured.

## 3. Counterexample hunt

* Claim "`K = 0 ↔ |x| = |y|`": tested on a grid of points; no counterexample.
* Claim "`|K| < 1`": as `x → ∞, y = 0`, `K → −1`; as `y → ∞, x = 0`, `K → +1`.
  The bound is strict (never attained) and sharp. No point with `|K| ≥ 1` found.

## 4. Metric positivity

`gxx = 1/cosh²(y) > 0` and `gyy = cosh²(x) ≥ 1 > 0` at every point, so the metric
determinant `gxx·gyy = cosh²(x)/cosh²(y) > 0` everywhere — the split metric is a
genuine positive-definite Riemannian metric on all of `ℝ²`.

No OEIS sequence arises (the objects are continuous/analytic, not integer
sequences).
