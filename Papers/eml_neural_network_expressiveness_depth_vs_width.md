# Computational Evidence — EML depth/width tradeoffs for `x ↦ x²`

All numbers below were produced with `Float` arithmetic inside Lean (`#eval`),
sampling `x` on the uniform grid `{0, 1/1000, …, 1}` of `[0,1]` and reporting the
maximal absolute error.

Notation.

* forward EML net (the construction already in the catalog,
  `EML.QuadraticApproxRate.emlQuadApprox`):
  `F_h(x) = (2/h²)·(exp(h x) − 1 − h x)`  — one exponential unit;
* **central** EML net (new):
  `S_h(x) = (exp(h x) + exp(−h x) − 2)/h²` — two exponential units
  (`log`-parts switched off by `log 1 = 0`), i.e. a **width-2** EML layer;
* depth-2 net `S_h ∘ S_h` (target `x⁴`);
* derivative of the central net, `S_h'(x) = (exp(h x) − exp(−h x))/h` (target `2x`).

## 1. Rate of the central (width-2) EML layer versus the forward one

| h | max‖S_h − x²‖ | ratio /h² | max‖F_h − x²‖ | ratio /h |
|---|---|---|---|---|
| 0.5    | 2.1008e-2 | 0.084031 | 1.89770e-1 | 0.379540 |
| 0.25   | 5.219e-3  | 0.083507 | 8.8813e-2  | 0.355253 |
| 0.125  | 1.303e-3  | 0.083377 | 4.3002e-2  | 0.344016 |
| 0.0625 | 3.26e-4   | 0.083344 | 2.1163e-2  | 0.338607 |

The ratios converge to `1/12 = 0.08333…` and `1/3 = 0.3333…` respectively:
the central net is **Θ(h²)** and the forward net is exactly **Θ(h)**.
This is the numerical basis for the two proved statements
`sqLayer_error` (`≤ h²x⁴/6`, safe constant) and
`emlQuadApprox_forward_lower_bound` (`≥ h/3` at `x = 1`).

## 2. Depth-2 composition and gradient error

| h | max‖S_h(S_h(x)) − x⁴‖ | ratio /h² | max‖S_h′ − 2x‖ | ratio /h² |
|---|---|---|---|---|
| 0.5   | 6.5294e-2 | 0.261177 | 8.4381e-2 | 0.337525 |
| 0.25  | 1.5795e-2 | 0.252716 | 2.0899e-2 | 0.334377 |
| 0.125 | 3.917e-3  | 0.250674 | 5.212e-3  | 0.333594 |

Ratios converge to `1/4` and `1/3`; the proved bounds (`≤ h²` for the depth-2
quartic net, `≤ h²/2` for the gradient) are therefore true with room to spare,
which is what makes them provable with the crude `Real.exp_bound` remainder.

## 3. Counterexample hunt for the ReLU lower bound

Best piecewise-linear approximation of `x²` on `[0,1]` with `k` equal pieces has
error exactly `1/(8k²)`:

| k | 1 | 2 | 4 | 8 | 16 |
|---|---|---|---|---|---|
| error | 0.125 | 0.03125 | 0.0078125 | 0.001953 | 0.000488 |

A one-hidden-layer ReLU network with `k` units (plus an affine skip connection) is
piecewise linear with at most `k` breakpoints, so no sampling of parameters can
beat `Θ(k⁻²)`; the proved bound `ε ≥ 1/(32(k+1)²)` is the same order with a
constant that is a factor `4·((k+1)/k)²` off the optimum — the loss comes from
using quarter points of the empty interval rather than its endpoints.
No counterexample was found; the numerics agree with the proved inequality.

## 4. What the numbers refute

The mission conjecture predicts error `Θ((w·d)^{-2})` in dimension `n = 1`.
For `x²` the numerics show the *width is irrelevant*: a **fixed** width-2 EML
layer reaches any accuracy by scaling the single hyperparameter `h`
(error `≈ h²/12`). So the conjectured rate is an upper bound but is *not tight*
for analytic targets — the accuracy is bought with weight magnitude `1/h²`
rather than with width. That observation is what the formal file proves.

## 5. Softplus emulation of ReLU (second research cycle)

`log(1 + exp(M t))/M − relu t` at `M = 10`:

| t | −1 | −0.1 | 0 | 0.1 | 1 |
|---|---|---|---|---|---|
| gap | 4.5e-6 | 0.031326 | 0.069315 | 0.031326 | 4.5e-6 |

The maximum `0.069315 = log 2 / 10` is attained at `t = 0`, so the proved bound
`|softplus(Mt)/M − relu t| ≤ log 2 / M` is **sharp**.

## 6. Piecewise-linear interpolation of `x²` (second research cycle)

Maximal error of the `N`-piece interpolant realised as a ReLU network
(`lipReluNet`), sampled on the same grid:

| N | 1 | 2 | 4 | 8 |
|---|---|---|---|---|
| error | 0.25 | 0.0625 | 0.015625 | 0.003906 |

These are exactly `1/(4N²)` — the interpolation error `(x−a)(b−x)` of a parabola.
For `f = x²` on `[0,1]` one may take `L = 2`, so the proved bound `2L/N = 4/N`
is loose for this particular (smooth) `f` — as it must be, since the bound is
uniform over the whole Lipschitz class, where the rate is genuinely `Θ(1/N)`.

## 7. Cycle 3: the polarisation multiplication gate

Gate `P_h(x,y) = (S_h(x+y) − S_h(x−y))/4`, where
`S_h(t) = (exp(h t) + exp(−h t) − 2)/h²`.  Sampled on the 51 × 51 uniform grid
of `[0,1]²` (Lean `Float`, `#eval`):

| h      | max&#124;P_h − xy&#124; | ratio to h² |
|--------|-------------------------|-------------|
| 0.5    | 8.6161e-2               | 0.344645    |
| 0.25   | 2.1008e-2               | 0.336124    |
| 0.125  | 5.219e-3                | 0.334029    |
| 0.0625 | 1.303e-3                | 0.333507    |

The ratio converges to `1/3`, confirming an exact `Θ(h²)` rate for the width-4
gate; the maximum is attained at the corner `(1,1)`, as the analytic bound
`h²((x+y)⁴+(x−y)⁴)/24` predicts.  The proved constant `17/24 ≈ 0.708` (rounded
up to `1` in `prodGate_error_unit`) is therefore within a factor `≈ 2.1` of the
observed truth — the slack is the triangle inequality between the two
polarisation branches, whose errors partially cancel.

No counterexample to the `Θ(h²)` claim was found in the sample; the ratio is
monotonically decreasing towards `1/3` from above, consistent with the
`h⁴`-order correction term.
