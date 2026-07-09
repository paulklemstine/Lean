# Computational Evidence: Split Geometry

Metric under study (the "Split metric" on the plane):
$$ ds^2 = \frac{dx^2}{\cosh^2 y} + \cosh^2 x \, dy^2, \qquad
   E(y)=\operatorname{sech}^2 y,\quad G(x)=\cosh^2 x. $$

The conjecture claimed Gaussian curvature `K = sech²x − sech²y`, changing sign across
the diagonals `y = ±x`, elliptic (`K>0`) on `|x|>|y|` and hyperbolic (`K<0`) on `|y|>|x|`.

## 1. Symbolic curvature from the Brioschi formula

Using the orthogonal-coordinate Brioschi formula
`K = -1/(2√(EG)) [ ∂ₓ(∂ₓG/√(EG)) + ∂_y(∂_yE/√(EG)) ]` with `√(EG) = cosh x / cosh y`:

| quantity | value |
|---|---|
| `∂ₓG` | `2 cosh x sinh x` |
| `(∂ₓG)/√(EG)` | `2 sinh x cosh y` |
| `∂ₓ[(∂ₓG)/√(EG)]` | `2 cosh x cosh y` |
| `∂_yE` | `−2 sinh y / cosh³y` |
| `(∂_yE)/√(EG)` | `−2 sinh y /(cosh²y cosh x)` |
| `∂_y[(∂_yE)/√(EG)]` | `−2(2 − cosh²y)/(cosh x cosh³y)` |

Assembling:
$$ K(x,y) = 2\,\operatorname{sech}^2x\,\operatorname{sech}^2y - \operatorname{sech}^2x - \cosh^2 y. $$

A computer-algebra check confirms `K − (2 sech²x sech²y − sech²x − cosh²y) = 0`
identically, and that this is **not** equal to the conjectured `sech²x − sech²y`.

## 2. Sign of the true curvature (counterexample hunt)

Sampling `K` at 2000 random points in `[-3,3]²`:

- maximum observed value ≈ `−1.0×10⁻³` (i.e. `K ≤ 0` throughout, approaching `0` near the origin).

Spot values:

| (x,y) | true `K` | conjectured `sech²x − sech²y` |
|---|---|---|
| (0.3, 1.2) | −3.635 | +0.610 |
| (2.0, 0.5) | −1.231 | −0.716 |
| (1.0, 1.0) | −2.448 | 0 |
| (0, 1) | −2.541 | +0.580 |

The point `(0,1)` is decisive: the conjecture predicts an **elliptic** point (`+0.58`),
but the true curvature is strictly **negative**. There is no elliptic region at all.

## 3. Two independent failures of the conjecture

1. **Realisation failure.** The stated metric does not produce the stated curvature.
   The decomposition
   `K = 2 sech²x (sech²y − 1) + (sech²x − cosh²y)`
   writes `K` as a sum of two non-positive terms, each vanishing only at the origin;
   hence `K ≤ 0` everywhere and `K = 0 ⇔ (x,y) = (0,0)`. The Split metric is a
   globally non-positively curved (hyperbolic-type) geometry, never sign-changing.

2. **Sign-region failure.** Even taking the *idealised* function `S = sech²x − sech²y`
   at face value, its positive region is `|x| < |y|`, the **reverse** of the claim,
   because `sech` is decreasing in `|·|`. What survives is the zero set: `S = 0`
   exactly on the diagonals `x² = y²`.

## 4. What is formalised

- `SplitGeometry.lean` — analytic properties of both curvatures:
  `gaussCurv_nonpos`, `gaussCurv_eq_zero_iff`, `no_elliptic_region`,
  the corrected sign regions `claimedCurv_pos_iff`/`claimedCurv_neg_iff`,
  the phase boundary `claimedCurv_eq_zero_iff`, and the refutation
  `conjecture_curvature_false`.
- `SplitGeometryBrioschi.lean` — the derivation of the closed-form curvature from the
  Brioschi formula, term by term, culminating in `brioschiCurv_eq_gaussCurv`.
