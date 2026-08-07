# Computational Evidence

All numbers below were produced with `#eval` inside the Lean 4 project (Float
arithmetic), before the corresponding statements were formalised. They are
*evidence*, not proof; every claim that survived is proved exactly in
`Catalog/Physics/Chaos/`.

## 1. The Routh quartic and its unstable root

The linearisation of the equilateral (Lagrange) three-body solution in the rotating
frame has characteristic polynomial (in units of the mean motion `ω`)

```
p_K(z) = z⁴ + z² + (27/4)·K ,     K = (m₁m₂ + m₂m₃ + m₃m₁)/(m₁+m₂+m₃)² .
```

Conjectured explicit root: `z₀ = σ(K) + i ν(K)` with

```
σ(K) = ½√(√(27K) − 1),      ν(K) = ½√(√(27K) + 1).
```

Residuals at `K = 1/3` (equal masses), computed numerically:

| quantity | value |
|---|---|
| `σ(1/3)` | `0.707107` |
| `ν(1/3)` | `1.000000` |
| `1/√2` | `0.707107` |
| `Re p_K(z₀)` | `-0.000000` |
| `Im p_K(z₀)` | `0.000000` |

So the equal-mass growth rate is `1/√2` to machine precision, and `ν = 1` exactly.
Formalised exactly as `ThreeBody.lagrange_char_root` and
`ThreeBody.equalMass_lagrangeExponent`.

## 2. Monotonicity and the Routh threshold `K = 1/27`

| `K` | `σ(K)` |
|---|---|
| `0.037037 = 1/27` | `0.000000` |
| `0.040000` | `0.099033` |
| `0.050000` | `0.201181` |
| `0.100000` | `0.400989` |
| `0.200000` | `0.575280` |
| `0.333333 = 1/3` | `0.707107` |

`σ` vanishes exactly at `K = 1/27` and increases with `K`; below the threshold the
quartic has four purely imaginary roots (`ThreeBody.routh_stable_roots_pure_imaginary`),
above it the explicit root has `Re > 0` (`ThreeBody.lagrangeExponent_pos`). Both
directions are combined in `ThreeBody.routh_instability_iff`.

## 3. Counterexample hunt for `K ≤ 1/3`

Universal claim tested: `K(m₁,m₂,m₃) ≤ 1/3`, i.e. equal masses maximise the
instability.

| `(m₁,m₂,m₃)` | `K` | `σ(K)` |
|---|---|---|
| `(1,1,1)` | `0.333333` | `0.707107` |
| `(1,1,0.001)` | `0.250250` | `0.632332` |
| `(1,2,3)` | `0.305556` | `0.684157` |
| `(5,1,1)` | `0.224490` | `0.604557` |
| `(1,1,0.04)` | `0.259516` | `0.641689` |
| `(1,0.5,0.5)` | `0.312500` | — |
| `(1,0.9,0.1)` | `0.272500` | — |

No counterexample found; the maximum `1/3` is attained only at equal masses. Proved
as `ThreeBody.routhParam_le_third` (a sum-of-squares inequality, valid for *all* real
mass values), hence `ThreeBody.lagrangeExponent_le_equalMass`: `σ ≤ √2/2` always.

## 4. Where the threshold sits physically

With two unit masses and a third mass `M`, `K = 1/27` at

```
M² − 50M − 23 = 0 ,   M = 25 + √648 ≈ 50.4558 .
```

Numerically `K(1, 1, 50.4558) = 0.037037 = 1/27` (agreeing to 6 digits), and
`K(1,1,50) = 0.037352 > 1/27` (unstable) while `K(1,1,51) = 0.036668 < 1/27` (stable).
Equivalently, in the restricted problem, `K(1, 0.0400642, 0) = 1/27`, the classical
Routh ratio `1 : 24.96`, which is why the Sun–Jupiter Trojans are stable but a system
of three comparable masses never is.

## 5. What the evidence does *not* show

The numerics concern the *linearised* flow around the Lagrange homographic solution.
Positivity of the maximal Lyapunov exponent of the *full nonlinear* three-body flow on
a positive-measure set of initial data is not established by these computations, nor
by the formal proofs; see `FUTURE_DIRECTIONS.md`.

---

## Cycle 2 evidence (for `Catalog/Physics/Chaos/ChaosExtensions.lean`)

These numbers are exploratory floating-point computations used to test the conjectures
*before* formalising them; the statements themselves are now machine-checked in Lean
(`routhParam_robin_hood`, `lagrangeExponent_lt_equalMass_of_ne`,
`lagrangeExponent_midpoint_concave`).

### Robin Hood transfers (`m₃ = 1` fixed, `m₁ + m₂ = 2`)

| ε | masses | K | σ(K) |
|---|--------|---|------|
| 0.0 | (0.50, 1.50, 1.00) | 0.305556 | 0.684157 |
| 0.1 | (0.60, 1.40, 1.00) | 0.315556 | 0.692623 |
| 0.2 | (0.70, 1.30, 1.00) | 0.323333 | 0.699045 |
| 0.3 | (0.80, 1.20, 1.00) | 0.328889 | 0.703550 |
| 0.4 | (0.90, 1.10, 1.00) | 0.332222 | 0.706222 |
| 0.5 | (1.00, 1.00, 1.00) | 0.333333 | 0.707107 |

Both `K` and `σ(K)` increase strictly along the transfer, saturating exactly at the
equal-mass point with `σ = √2/2 ≈ 0.7071068`.

### Midpoint concavity gap `σ((K+L)/2) − ½(σ(K)+σ(L))`

| K | L | gap |
|---|---|-----|
| 0.040000 | 0.330000 | 1.539030e−01 |
| 0.050000 | 0.300000 | 1.014247e−01 |
| 0.037038 | 0.333333 | 2.014217e−01 |
| 0.100000 | 0.200000 | 1.497113e−02 |
| 0.300000 | 0.330000 | 2.631832e−04 |

The gap is positive and shrinks quadratically as `K → L`, consistent with concavity rather
than with a stronger (e.g. affine) behaviour.

### Counterexample hunt

`200 000` random samples of `(K, L) ∈ [1/27, 1]²` and of mass triples in `[0, 5]³`
produced **no** violation of midpoint concavity and **no** violation of `K ≤ 1/3`
(tolerance `10⁻¹²`).

## Exploratory scan of the collinear (Euler) quartic — this cycle

Floating-point exploration (not a verified computation; the corresponding statements are
the Lean-verified ones in `Catalog/Physics/Chaos/EulerCollinear.lean`). For each Euler
parameter `A` the four roots of `z⁴ + (2 − A)z² + (1 + A − 2A²)` were computed and the
largest real part recorded, together with the largest residual `|p(z)|`.

| `A` | discriminant `A(9A − 8)` | max Re z | max residual |
|---|---|---|---|
| 0.500 | −1.7500 | 0.353553 | 0.0e+00 |
| 0.800 | −0.6400 | 0.246080 | 2.2e-16 |
| 0.889 (= 8/9) | 0.0000 | 0.000000 | 0.0e+00 |
| 0.950 | 0.5225 | 0.000000 | 2.8e-16 |
| 1.000 | 1.0000 | 0.000000 | 0.0e+00 |
| 1.050 | 1.5225 | 0.376760 | 2.2e-16 |
| 1.500 | 8.2500 | 1.089101 | 0.0e+00 |
| 3.000 | 57.0000 | 2.067587 | 7.1e-15 |
| 7.000 | 385.0000 | 3.508662 | 0.0e+00 |
| 20.000 | 3440.0000 | 6.190780 | 4.6e-13 |

The scan matches the proved trichotomy exactly: `max Re z = 0` precisely on the closed
window `[8/9, 1]` and `max Re z > 0` on both sides of it, with the growth rate increasing
monotonically above the window. It also shows the qualitative difference between the two
unstable regimes: below `8/9` the maximising roots come as a complex quadruplet
(`Im z ≠ 0`), while above `1` the maximising root is real.
