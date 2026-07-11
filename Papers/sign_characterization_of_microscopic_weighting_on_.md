# Computational Evidence: Sign of the Microscopic Weighting

## Setup and the key reduction

For a finite metric space `X = {x_1,...,x_n}` the **magnitude** theory of Leinster
studies the similarity matrix `Z_t` with entries `(Z_t)_{ij} = exp(-t·d(x_i,x_j))`
at scale `t > 0`. A **weighting** at scale `t` is `w_t` with `Z_t w_t = 𝟙`
(the all-ones vector), and the magnitude is `|tX| = Σ w_t`.

The **microscopic weighting** is the small-scale limit `μ = lim_{t→0⁺} w_t / Σ w_t`
(normalised to sum `1`, since `|tX| → 1` as `t → 0`).

**Key algebraic reduction.** Expanding `Z_t = J - tD + O(t²)` where `J` is the
all-ones matrix and `D = (d(x_i,x_j))` is the distance matrix, a first-order
perturbation analysis of `Z_t w_t = 𝟙` gives, at leading order,

    D μ = λ·𝟙   and   Σ μ = 1

for a scalar `λ`. When `D` is invertible this pins down `μ = D⁻¹𝟙 / (𝟙ᵀ D⁻¹𝟙)`.
This is the object we formalise: `μ` is a *distance-matrix weighting*.

## Small-case calculations

All rows below solve `D μ = λ𝟙, Σμ = 1` exactly.

### 2 points at distance r  (both extreme)
`D = [[0,r],[r,0]]`, `μ = (1/2, 1/2)`, `λ = r/2`.
Both weights `> 0`; both points are vertices of `conv(X)`. ✓

### 3 collinear points 0,1,2 in ℝ  (middle non-extreme)
`D = [[0,1,2],[1,0,1],[2,1,0]]`, `μ = (1/2, 0, 1/2)`, `λ = 1`.
Endpoints `1/2 > 0` (extreme); middle `0 ≤ 0` (non-extreme, boundary case). ✓

### Equilateral triangle, side s  (all extreme)
`μ = (1/3,1/3,1/3) > 0`, all three points extreme. ✓

### Square {(±1,±1)} plus centre (0,0)  (centre strictly interior)
Distances: centre–vertex `√2`, edge `2`, diagonal `2√2`. Writing `s = √2`,
the exact microscopic weighting is
`μ_centre = 2(1-s)/(6-2s) < 0`, `μ_vertex = 1/(6-2s) > 0`, `λ = 4s/(6-2s) > 0`.
The strictly interior centre gets a **negative** weight; the four vertices
(extreme points) get positive weight. ✓

Numerical convergence check of the finite-scale weighting `w_t` for this
configuration (centre weight `c_t`), confirming `c_t → μ_centre ≈ -0.261`:

| t    | 1.0   | 0.5   | 0.4    | 0.2    | 0.1    | →0     |
|------|-------|-------|--------|--------|--------|--------|
| c_t  | 0.327 | 0.008 | -0.054 | -0.167 | -0.217 | -0.261 |

The interior weight is positive at large scale but becomes negative as `t → 0`;
the *microscopic* regime is exactly where the sign characterisation appears.

## Counterexample hunt

The naive claim "the ordinary (scale-1) weighting is `≤ 0` off the vertices" is
**false**: for 3 collinear points the middle weight is `(1-e⁻¹)/(1+e⁻¹) > 0`.
This is why the theorem must be about the *microscopic* (`t→0`) weighting, whose
middle weight is exactly `0`. The table above shows the same phenomenon for the
square+centre: sign only settles as `t → 0`.

## What is formalised

`Core.lean`: the distance-matrix weighting predicate `IsMicroWeighting`, the
well-definedness of the constant `λ` for symmetric `D`, uniqueness for invertible
`D`, and existence via the inverse.

`Examples.lean`: the four configurations above, each with its exact microscopic
weighting proved to satisfy `D μ = λ𝟙, Σμ = 1`, together with the sign of every
coordinate — the concrete instances of the sign characterisation.

`ExtremePoints.lean`: the geometric tie-in for the collinear case — the middle
point is genuinely *not* an extreme point of the convex hull while the endpoints
are — so "sign of `μ`" ↔ "extreme point" is verified there in full.
