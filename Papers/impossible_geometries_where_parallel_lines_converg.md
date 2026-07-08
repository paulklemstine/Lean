# Computational Evidence — Split Geometry

Metric on `ℝ²`:  `ds² = dx²/cosh²(y) + cosh²(x) dy²`, i.e. `E = sech²(y)`, `G = cosh²(x)`.
Conjectured curvature sign-function:  `K(x,y) = sech²(x) − sech²(y)`, where
`sech²(t) = 1/cosh²(t)`.

## 1. Values of `sech²`

| t | cosh t | sech²(t) = 1/cosh²t |
|---|--------|---------------------|
| 0 | 1.0000 | 1.00000 |
| 1 | 1.5431 | 0.41997 |
| 2 | 3.7622 | 0.07065 |
| 3 | 10.068 | 0.00987 |

`sech²` is even and strictly decreasing in `|t|` — verified in Lean as
`sech2_lt_sech2_iff` / `sech2_eq_sech2_iff`.

## 2. Sign of `K` in the three phases

| (x,y) | comparison | K(x,y) | phase |
|-------|-----------|--------|-------|
| (1,2) | \|x\|<\|y\| | +0.349 | K>0 (elliptic side) |
| (2,1) | \|x\|>\|y\| | −0.349 | K<0 (hyperbolic side) |
| (1,−1)| \|x\|=\|y\| | 0 | flat (phase boundary) |
| (0,3) | \|x\|<\|y\| | +0.990 | K>0 |
| (3,0) | \|x\|>\|y\| | −0.990 | K<0 |

Matches `K_pos_of_abs_lt`, `K_neg_of_abs_lt`, `K_eq_zero_iff_abs`.

## 3. Phase boundary = diagonals

`K(x,y)=0 ⟺ |x|=|y| ⟺ x²=y² ⟺ (x=y ∨ x=−y)`.  The zero set is exactly the two
lines `y=x` and `y=−x`.  Verified as `phaseBoundary_eq_diagonals`.

## 4. Counterexample hunt: "crosses at most twice"

The phase boundary is the union of two straight lines, so a straight coordinate
line `t ↦ (x₀+ta, y₀+tb)` meets it wherever `(x₀+ta)² = (y₀+tb)²`, i.e. where
the quadratic `(a²−b²)t² + 2(x₀a−y₀b)t + (x₀²−y₀²) = 0` vanishes.

* If `a² ≠ b²` (line not parallel to a diagonal): leading coefficient nonzero,
  so at most **2** real roots.  Example `x₀=0, y₀=1, (a,b)=(1,0)`:
  `t² = 1`, roots `t = ±1` — exactly two crossings.
* If `a² = b²` (line parallel to a diagonal): the equation degenerates to a
  linear one, giving `0` or `1` crossings — unless the line *is* a diagonal, in
  which case every `t` is a "crossing".  This is why `geodesic_crosses_at_most_twice`
  requires `a² ≠ b²`; no counterexample exists under that hypothesis.

Tested random samples of `(a,b,x₀,y₀)` with `a²≠b²`: never more than two roots.
No counterexample found — consistent with the theorem.

## 5. Positive-definiteness (consistency)

`E = sech²y > 0` and `G = cosh²x ≥ 1 > 0` at every point, so
`E u² + G v² > 0` for all `(u,v) ≠ 0`.  Verified as `metric_posDef`; the metric
is a genuine Riemannian metric everywhere.
