# Computational Evidence — Turing's Flowers: Morphogenesis as Algebraic Geometry

This note records the small-case sanity checks behind the formal results in
`Catalog/Novelty/TuringFlowersAlgebraicGeometry.lean`.

## 1. Chebyshev correspondence `cos(nθ) = T_n(cos θ)`

The central claim is that a spatial mode `θ ↦ cos(n θ)` is a polynomial of degree
exactly `n` in `X = cos θ`. First few Chebyshev polynomials `T_n(X)`:

| n | T_n(X)                    | deg |
|---|---------------------------|-----|
| 0 | 1                         | 0   |
| 1 | X                         | 1   |
| 2 | 2X² − 1                   | 2   |
| 3 | 4X³ − 3X                  | 3   |
| 6 | 32X⁶ − 48X⁴ + 18X² − 1    | 6   |

Numerical spot check at `θ = π/5`, `X = cos(π/5) ≈ 0.809017`:

* `cos(2θ) = cos(2π/5) ≈ 0.309017`;  `2X² − 1 ≈ 2(0.654508) − 1 = 0.309017`. ✓
* `cos(3θ) = cos(3π/5) ≈ −0.309017`; `4X³ − 3X ≈ 4(0.529508) − 3(0.809017) = −0.309017`. ✓

So `two_mode_degree_two` (deg 2), `mode_as_poly` (deg n), and
`sextic_from_three_modes` (`cos(3θ)²` via `T_3²`, deg 6) are consistent.

## 2. Boundedness dichotomy (spots vs. labyrinths vs. stripes)

* **Spot / ellipse** `a x² + b y² = c`, `a,b>0`: bounded. e.g. `x²+4y²=4` gives
  `|x|≤2, |y|≤1`, so `x²+y² ≤ 4 = c/a + c/b = 4 + 1`? Bound used is `c/a + c/b = 5`,
  a valid (loose) upper bound. ✓ (matches `ellipse_bounded`).
* **Labyrinth / hyperbola** `x² − y² = c`, `c>0`: for `t` large, the point
  `(√(t²+c), t)` lies on the curve and has squared norm `2t² + c → ∞`. Taking
  `t² = |R|+1` beats any `R`. ✓ (matches `hyperbola_unbounded`).
* **Stripe** `cos x = c`: the point `(0, √(|R|+1))` has `cos 0 = 1 = c` and squared
  norm `|R|+1 > R`; also invariant under `x ↦ x + 2πk`. ✓ (matches `stripe_unbounded`,
  `stripe_periodic`).

## 3. Separation of morphological classes

Because the hyperbola and stripe sets are unbounded while any circle
`{x²+y² = ρ²}` is bounded, no circle set can equal a hyperbola set
(`spot_not_labyrinth`) or a stripe set (`spot_not_stripe`). Concrete witness for
`ρ² = 1`, `c = 1`: the hyperbola point with `2t²+1 > 1` is not on the unit circle. ✓

## Conclusion

Every headline theorem is witnessed by an explicit construction (a named polynomial
of the claimed degree, or an explicit point with the required norm), so none of the
statements is vacuous. All checks are consistent with the formalized proofs.
