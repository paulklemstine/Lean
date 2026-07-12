# Computational Evidence: Geodesics and the Wrapping Lattice of the Flat 3-Torus

Before formalizing, we checked the core claims computationally on the flat
three-torus `𝕋³ = (ℝ/ℤ)³`.

## 1. Closed geodesics from integer directions

A geodesic of the flat metric is the projection of a straight line
`t ↦ x + t·v` in the universal cover `ℝ³`. Such a line projects to a *closed*
loop precisely when some positive time `T` sends the displacement `T·v` into the
integer lattice `ℤ³`.

Small-case checks (direction `v`, first return time `T`):

| direction `v` | integer? | first return `T` | closed? |
|---|---|---|---|
| `(1,0,0)` | yes | `1` | yes |
| `(0,1,0)` | yes | `1` | yes |
| `(2,3,0)` | yes | `1` | yes |
| `(1,1,1)` | yes | `1` | yes |
| `(√2,0,0)` | no | none | no (dense line) |
| `(1,√2,0)` | no | none | no |

Every integer direction closes up at `T = 1`; irrational directions never close
(they equidistribute), matching the classical Kronecker/Weyl picture. Only the
integer case is formalized here, as `geo_periodic`.

## 2. Nontriviality (genuine wrapping)

For a nonzero integer direction `n`, the half-period point
`t = 1/(2 nᵢ)` (for a coordinate with `nᵢ ≠ 0`) maps to the order-two element
`1/2 ∈ ℝ/ℤ`, which differs from the base point `0`. Hence the loop is
nonconstant. Spot check: `n = (2,0,0)`, `t = 1/4`, first coordinate
`t·n₀ = 1/2 ≠ 0` in `ℝ/ℤ`. Formalized as `geo_nontrivial`.

## 3. The wrapping lattice = `ℤ³`

The kernel of the covering projection `ℝ³ → 𝕋³` is the set of points with all
integer coordinates:

    proj x = 0  ⇔  x ∈ ℤ³.

We verified representative points: `(0,0,0), (1,0,0), (−3,2,7)` lie in the
kernel; `(1/2,0,0), (1,1/3,0)` do not. This is the covering-space form of
`π₁(𝕋³) ≅ ℤ³` and is formalized as `mem_ker_iff` / `ker_proj_eq_range`.

## 4. Three independent families

The three standard directions `e₀,e₁,e₂` are `ℤ`-linearly independent: no
nontrivial integer combination `a e₀ + b e₁ + c e₂` vanishes unless
`a = b = c = 0`. This gives exactly three independent generators of the wrapping
group — the three independent families of loops. Formalized as
`standard_basis_indep`.

## 5. Minimal-volume hyperbolic 3-manifold (Weeks manifold) — evidence only

The Weeks manifold has hyperbolic volume

    Vol ≈ 0.9427073627769277...

Numerically it is the smallest known value among closed orientable hyperbolic
3-manifolds, and the Gabai–Meyerhoff–Milley program established minimality. This
sits far outside the formalizable range here (it requires the full theory of
hyperbolic Dehn surgery and rigorous volume estimates), so it is recorded as a
conjecture in `FUTURE_DIRECTIONS.md` rather than proved.
