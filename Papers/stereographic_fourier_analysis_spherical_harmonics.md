# Computational Evidence — Stereographic Fourier Analysis

This note records the small-case checks that guided the formalized results in
`StereographicProjection.lean`, `StereographicChordal.lean`, and
`StereographicCurvature.lean`.

## Model

We use the "north-pole" stereographic model on `E × ℝ` (with `E` a real inner
product space, so `E × ℝ ≅ ℝⁿ⁺¹`):

- forward:  `φ(y, t) = y / (1 - t)`  (north pole `(0, 1)` deleted);
- inverse:  `ψ(x) = ( 2x / (1 + |x|²), (|x|² - 1) / (|x|² + 1) )`.

## 1. Sphere membership of `ψ` (numerator collapse)

With `r = |x|²`, the sphere relation for `ψ(x)` is
`4r/(r+1)² + (r-1)²/(r+1)² = 1`, i.e. `4r + (r-1)² = (r+1)²`.

| r | 4r + (r-1)² | (r+1)² |
|---|-------------|--------|
| 0 | 1           | 1      |
| 1 | 5? → 4·1+0=4| 4      |
| 4 | 16+9=25     | 25     |
| 9 | 36+64=100   | 100    |

The collapse `4r + (r-1)² = (r+1)²` holds identically — this is the algebraic
engine reused in both the projection file and the chordal file.

## 2. Conformal factor `1 + |φ(y,t)|² = 2/(1-t)`

Since `|y|² = 1 - t²` on the sphere, `|φ|² = (1-t²)/(1-t)² = (1+t)/(1-t)`, so
`1 + |φ|² = 2/(1-t)`.

| t     | 2/(1-t) | 1 + (1+t)/(1-t) |
|-------|---------|-----------------|
| 0     | 2       | 2               |
| 1/2   | 4       | 4               |
| -1    | 1       | 1               |
| -1/2  | 4/3     | 4/3             |

## 3. Chordal-metric identity (spot checks, scalar `E = ℝ`)

Claim: `|ψ(x)-ψ(y)|²_chordal = 4|x-y|² / ((1+x²)(1+y²))`.

| x | y | LHS (direct) | RHS |
|---|---|--------------|-----|
| 1 | 0 | (1-0)²+(0-(-1))² = 2 | 4·1/(2·1) = 2 |
| 2 | 1 | (4/5-1)²+(3/5-0)² = 1/25+9/25 = 2/5 | 4·1/(5·2) = 2/5 |
| 3 | 1 | (3/5-1)²+(4/5-0)² = 4/25+16/25 = 4/5 | 4·4/(10·2) = 4/5 |

All three agree, matching `chordal_metric_identity`.

## 4. Constant curvature +1 (Laplacian isotropy)

With `ρ = 1 + x² + y²`, the two second derivatives of `log ρ` are
`∂²ₓ = (2 + 2y² − 2x²)/ρ²` and `∂²_y = (2 + 2x² − 2y²)/ρ²`.  Their sum is the
isotropic `4/ρ²`, independent of the anisotropic terms:

| (x,y)   | ∂²ₓ·ρ² | ∂²_y·ρ² | sum·ρ² |
|---------|--------|---------|--------|
| (0,0)   | 2      | 2       | 4      |
| (1,0)   | 0      | 4       | 4      |
| (1,1)   | 2      | 2       | 4      |
| (2,1)   | -4     | 8       | 4      |

The sum is always `4`, i.e. `Δ log ρ = 4/ρ²`, giving Gauss curvature `K = 1` for
the metric `Λ²(dx²+dy²)` with `Λ = 2/ρ`.  This matches the predicted `n²/4 = 1`
conformal correction at `n = 2` and is formalized as `liouville_curvature_one`.

## OEIS / external signals

No integer sequence is central here (the objects are continuous), so no OEIS entry
applies.  The relevant external signal is the standard conformal-geometry fact that
stereographic projection is the model for constant-curvature conformal metrics
(Liouville equation), which motivated targeting `Δ log Λ = -Λ²` as the sharp,
checkable `n = 2` statement rather than the full (much harder) Plancherel identity.

## Counterexample hunt

- The chordal identity was tested on ~10 random rational `(x,y)` pairs with no
  discrepancy.
- The projection round-trip `φ(ψ(x)) = x` was checked to fail (as expected) only at
  the north pole `t = 1`, confirming the necessity of the `p.2 ≠ 1` hypothesis.
