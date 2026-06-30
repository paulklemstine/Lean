# Computational Evidence

Concise numerical sanity checks behind the two results in this cycle:
the **convexity obstruction** (tent vs. tropical polynomials) and the
**quantitative tropical-rational rate**.

## 1. The tent map and the convexity obstruction

The tent `T(x) = 1 - |2x - 1|` on the three dyadic nodes:

| x      | 0 | 1/2 | 1 |
|--------|---|-----|---|
| T(x)   | 0 |  1  | 0 |

A tropical polynomial `p` (a finite max of affine functions) is **convex**, so
the chord inequality `p(1/2) ≤ (p(0) + p(1)) / 2` always holds. If `p` matched the
tent within `ε` at all three nodes, then

```
1 - ε ≤ p(1/2) ≤ (p(0) + p(1)) / 2 ≤ (ε + ε)/2 = ε   ⟹   ε ≥ 1/2.
```

Counterexample hunt for `ε < 1/2`: any candidate convex `p` was tested by the chord
inequality and necessarily fails, e.g.

* `p ≡ 1/2` (constant): errors `(1/2, 1/2, 1/2)`, max error `1/2` — exactly the floor.
* `p(x) = |2x-1|` (convex, the "anti-tent"): values `(1, 0, 1)`, errors `(1, 1, 1)`.
* `p(x) = a|2x-1| + b` for any `a ≥ 0`: midpoint value `b`, endpoint values `a+b`;
  forcing `b ≥ 1-ε` and `a+b ≤ ε` gives `a ≤ 2ε-1 < 0`, impossible for `ε < 1/2`.

No convex `p` beats `ε = 1/2`. The bound is tight (constant `1/2`). The positive
side: `T(x) = 1 - max(2x-1, 1-2x)` is a difference of two tropical polynomials,
i.e. tropical *rational*.

## 2. Quantitative tropical-rational rate

For `f(x) = x²` on `[0,1]` (`1`-Lipschitz on `[0,1]` after the bound `|f'|≤2`, and
`W^{2,∞}` with second-derivative bound `M = 2`), the `2n`-ramp interpolation
network `reluInterpNet f n` is a tropical rational function with `2n` ramp
monomials. Sampled max error over a fine grid of `[0,1]`:

| n  | observed max error | linear bound L/n (L=2) | quadratic bound M/n² (M=2) |
|----|--------------------|------------------------|-----------------------------|
| 1  | 0.25               | 2.0                    | 2.0                         |
| 2  | 0.0625             | 1.0                    | 0.5                         |
| 4  | 0.0156             | 0.5                    | 0.125                       |
| 8  | 0.0039             | 0.25                   | 0.03125                     |

The empirical error scales like `1/(4n²)` (the sharp constant `M/8` for piecewise
linear interpolation of `x²`), comfortably under both certified bounds `L/n` and
`M/n²`. This confirms the proven rates are valid (and conservatively loose by the
expected `O(1)` factor).

## OEIS

No integer sequence is central to these results (the objects are real-valued rates
and convex obstructions), so no OEIS identifier applies.
