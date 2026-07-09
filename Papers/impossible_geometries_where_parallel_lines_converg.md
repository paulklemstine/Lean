# Computational Evidence — Split Geometry

Metric under study (on `ℝ²`):

```
ds² = dx²/cosh²y + cosh²x · dy²,      i.e.   g_xx = sech²y,  g_yy = cosh²x,  g_xy = 0.
```

We record (1) the exact Christoffel/curvature computation, (2) a numerical check
of the true Gaussian curvature against the conjectured formula, and (3) the sign
table for the phase function that the Lean file proves.

---

## 1. Christoffel symbols (exact)

For a diagonal metric `g = E dx² + G dy²` with `E = sech²y` (function of `y`
only) and `G = cosh²x` (function of `x` only), the nonzero Levi-Civita symbols
are

| symbol | formula | value for split metric |
|---|---|---|
| `Γ¹₁₂ = Γ¹₂₁` | `E_y / (2E)` | `-tanh y` |
| `Γ¹₂₂`        | `-G_x / (2E)` | `-cosh x · sinh x · cosh²y` |
| `Γ²₁₁`        | `-E_y / (2G)` | `sinh y / (cosh³y · cosh²x)` |
| `Γ²₁₂ = Γ²₂₁` | `G_x / (2G)` | `tanh x` |
| `Γ¹₁₁`, `Γ²₂₂` | `E_x/(2E)`, `G_y/(2G)` | `0` (since `E_x = G_y = 0`) |

using `E_y = d/dy sech²y = -2 sinh y / cosh³y` and
`G_x = d/dx cosh²x = 2 cosh x · sinh x`.  All five nonzero/zero closed forms are
proved in Lean (`Gamma_xxy_eq`, `Gamma_xyy_eq`, `Gamma_yxx_eq`, `Gamma_yxy_eq`,
`Gamma_xxx_deriv_zero`, `Gamma_yyy_deriv_zero`).

## 2. Gaussian curvature — the conjecture is **false**

The prompt conjectured `K = sech²x − sech²y`.  The Brioschi formula for an
orthogonal metric,

```
K = −1/(2√(EG)) · [ ∂_x( G_x/√(EG) ) + ∂_y( E_y/√(EG) ) ],
```

gives instead the exact closed form

```
K_true(x,y) = −cosh²y + (2·sech²y − 1)·sech²x.
```

Numerical check (finite-difference Brioschi `K_num` vs. our closed form
`K_true` vs. the conjecture `K_conj = sech²x − sech²y`):

```
  x     y     K_num       K_true       K_conj
 0.00  0.00   -0.000000    0.000000    0.000000
 1.00  0.00   -0.580026   -0.580026   -0.580026
 0.00  1.00   -2.541149   -2.541149    0.580026
 1.00  1.00   -2.448315   -2.448315    0.000000
 2.00  0.50   -1.231065   -1.231065   -0.715797
 0.50  2.00  -14.829438  -14.829438    0.715797
 1.50  1.50   -5.649228   -5.649228    0.000000
 2.00  1.00   -2.392406   -2.392406   -0.349324
 0.30  0.90   -2.077681   -2.077681    0.428220
```

Conclusions:

* `K_true` matches the numerically computed curvature to full accuracy at every
  sample point, so `K_true(x,y) = −cosh²y + (2·sech²y − 1)·sech²x` is the actual
  Gaussian curvature.
* The conjectured `K_conj = sech²x − sech²y` agrees with `K_true` **only on the
  coordinate axes** (`x=0` or `y=0`); off the axes they differ, e.g. at `(1,1)`
  the true curvature is `−2.448…` while the conjecture gives `0`.
* In particular the "sign-changing curvature / elliptic region" picture is
  **false**: the true curvature is `≤ 0` everywhere and equals `0` only at the
  origin.  The metric is a (non-strictly) non-positively curved surface, not a
  surface that is "simultaneously elliptic and hyperbolic".

So the geometric *conjecture* does not hold.  What survives, and is genuinely
true and clean, is the transcendental/algebraic identity about the *proposed
sign field* `K_conj` — see §3.  This is what the Lean file proves, stated
honestly as a statement about the phase function rather than the curvature.

## 3. The phase function `K(x,y) = sech²x − sech²y` (the connector)

Because `cosh` is even and strictly increasing on `[0,∞)`, `sech² = 1/cosh²` is
strictly *decreasing* in `|t|`.  Hence the transcendental sign field
`K = sech²x − sech²y` is controlled *exactly* by the algebraic order of `x²` and
`y²`:

| region | `x² vs y²` | `K = sech²x − sech²y` |
|---|---|---|
| `\|x\| < \|y\|` | `x² < y²` | `K > 0` |
| `\|x\| = \|y\|` (diagonals `y = ±x`) | `x² = y²` | `K = 0` |
| `\|x\| > \|y\|` | `x² > y²` | `K < 0` |

The zero set `{K = 0}` is *exactly* the degenerate conic `x² = y²`, i.e. the
union of the two lines `y = x` and `y = -x`.  This is the bridge formalized in
`SplitGeometry.lean`:

* `splitPhase_eq_zero_iff : K x y = 0 ↔ x² = y²`
* `splitPhase_pos_iff     : 0 < K x y ↔ x² < y²`
* `splitPhase_neg_iff     : K x y < 0 ↔ y² < x²`
* `splitPhase_boundary    : K x y = 0 ↔ (y = x ∨ y = -x)`

Spot check of the sign table (`+` means `K>0`, `-` means `K<0`, `0` on boundary):

```
K(x,y) = sech²x − sech²y
(0.5, 2.0):  +0.7158   (|x|<|y|)   +
(2.0, 0.5):  -0.7158   (|x|>|y|)   -
(1.0, 1.0):   0.0000   (diagonal)  0
(3.0, 3.0):   0.0000   (diagonal)  0
(0.3, 0.9):  +0.4282   (|x|<|y|)   +
```

## Notes / OEIS

No integer sequence arises (the objects are real-analytic), so no OEIS entry is
relevant.  The counterexample hunt in §2 *did* find the decisive counterexample:
the conjectured curvature formula fails off the axes, and the conjectured
sign-changing behaviour of the true curvature does not occur at all.
