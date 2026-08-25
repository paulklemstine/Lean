# Computational Evidence — Ellipsoid Central Sections

This note records the small-case numerics that guided the formalization in
`Catalog/Bridges/EllipsoidCentralSections.lean`,
`Catalog/Bridges/EllipsoidSlicingBounds.lean` and
`Catalog/Bridges/EllipsoidLowerDimSections.lean`.

Numbers in the tables below were obtained by `#eval` on exact rational arithmetic in Lean
(exploratory computations, not proofs). Wherever a table suggests a general identity, the
identity itself is stated and *proved* in the Lean files; the relevant theorem name is
given.

## 1. Hyperplane sections of a diagonal ellipsoid

For `A = diag(d₀, …, d_{n-1})` and a unit normal `u`, the proved formula
(`volume_centralSection`) is

```
vol_{n-1}(E A ∩ u^⊥) = (|det A| / ‖Aᵀ u‖) · vol(B^{n-1}).
```

For a coordinate normal `u = e_k` this collapses to `(∏ᵢ dᵢ) / d_k`.

| semiaxes `(d₀,d₁,d₂)` | ratio for `e₀` | for `e₁` | for `e₂` | product of the three ratios | `(det A)²` |
|---|---|---|---|---|---|
| `(1,2,3)` | 6 | 3 | 2 | 36 | 36 |
| `(1,1,5)` | 5 | 5 | 1 | 25 | 25 |
| `(2,2,2)` | 4 | 4 | 4 | 64 | 64 |

The last two columns agree in every case; in dimension `n` the product of the `n`
principal section ratios is `(det A)^{n-1}`. This is
`prod_det_div_eigenvalues` — proved, no `sorry`.

## 2. Non-coordinate normals in the plane

For `A = diag(a,b)` and `u = (cos θ, sin θ)`, `‖Aᵀu‖ = √(a²cos²θ + b²sin²θ)` so the section
length is `ab / √(a²cos²θ + b²sin²θ)`.

| `(a,b)` | `θ = 0` | `θ = π/2` | eigenvalue window `[λ_min, λ_max]` |
|---|---|---|---|
| `(1,3)` | 3 | 1 | `[1,3]` |
| `(2,5)` | 5 | 2 | `[2,5]` |
| `(4,4)` | 4 | 4 | `[4,4]` |

Every observed section length lies in `[λ_min, λ_max]`, and both endpoints are attained
exactly at the eigendirections. This is the content of `volume_centralSection_le`,
`le_volume_centralSection` (bounds) together with
`volume_centralSection_of_eigenvector` (attainment) — all proved.

## 3. Sections of arbitrary codimension

For `A = diag(1,2,3)` in `ℝ³` the three coordinate 2-planes give section areas
`|d_i d_j| · vol(B²)`:

| selected coordinates | `∏ |d_i|` |
|---|---|
| `{0,1}` | 2 |
| `{0,2}` | 3 |
| `{1,2}` | 6 |

With `lo = 1`, `hi = 3` and `m = 2` the codimension-free sandwich predicts a window
`[lo² , hi²] = [1, 9]`; all three values lie inside. The general statement is
`volume_centralSection_sandwich`, and the exact product formula for coordinate frames is
`volume_centralSection_coordFrame_diagonal` — both proved.

## 4. Counterexample hunt

Two natural strengthenings were tested and **refuted** numerically before any proof effort
was spent on them:

1. *"Every `m`-dimensional central section has volume at least `(det A)^{m/n} · vol(B^m)`."*
   Take `A = diag(1,1,5)` in `ℝ³`, `m = 2`, section by the `{x₃ = 0}` plane: the area
   factor is `1·1 = 1`, whereas `(det A)^{2/3} = 5^{2/3} ≈ 2.924`. **False.**

2. *"The Blaschke–Santaló volume product of an ellipsoid depends on its eccentricity."*
   `vol(E A) · vol(E A°) = |det A| · vol(B) · |det A|⁻¹ · vol(B) = vol(B)²` for every
   invertible `A`. The product is constant, so the guess is **false** — and the constancy
   itself is now a theorem, `volume_ellipsoid_mul_volume_polar`.

## 5. OEIS

No integer sequence arises here: all the quantities are continuous functions of the
semiaxes, and the only combinatorial datum (the number of coordinate `m`-sections of an
`n`-dimensional diagonal ellipsoid) is the binomial coefficient `C(n,m)`. No OEIS lookup
was warranted.

## 6. Intersection bodies of diagonal ellipsoids (second cycle)

For `A = diag(d)` positive definite, the intersection generator proved in
`Catalog/Bridges/EllipsoidIntersectionBody.lean` is `intersectionGen A = det A · A⁻¹`, i.e.
`diag(det A / d₀, …, det A / d_{n-1})`. Its coordinate semiaxes are exactly the coordinate
section ratios of `E A` listed in §1, which is the numerical shadow of
`mem_intersectionBody_iff_volume_le`.

| semiaxes `(d₀,d₁,d₂)` | `det A` | semiaxes of `I(E A)` | `det` of the intersection generator | `|det A|^{n-1}` |
|---|---|---|---|---|
| `(1,2,3)` | 6 | `(6,3,2)` | 36 | 36 |
| `(1,1,5)` | 5 | `(5,5,1)` | 25 | 25 |
| `(2,2,2)` | 8 | `(4,4,4)` | 64 | 64 |
| `(1,1,1)` | 1 | `(1,1,1)` | 1 | 1 |

The last two columns agree in every row; the general identity is `det_intersectionGen`,
proved with no `sorry`. The last row also illustrates the fixed-point statement
`eq_one_of_intersectionGen_eq_self`: among unimodular positive definite generators the
identity is the only one with `intersectionGen A = A`, e.g. for `A = diag(2, 1/2)` (also
unimodular) one gets `intersectionGen A = diag(1/2, 2) = A⁻¹ ≠ A`, and applying the
construction once more returns `A`, as the involution theorem predicts.

## 7. Extremal sections of unimodular ellipsoids (second cycle)

Sampling unimodular diagonal generators in `ℝ³` and computing the coordinate section
ratios `det A / d_k = 1 / d_k`:

| semiaxes `(d₀,d₁,d₂)`, `det = 1` | section ratios | min | max |
|---|---|---|---|
| `(1,1,1)` | `1,1,1` | 1 | 1 |
| `(2, 1, 1/2)` | `1/2, 1, 2` | 1/2 | 2 |
| `(4, 1/2, 1/2)` | `1/4, 2, 2` | 1/4 | 2 |
| `(1/3, 3, 1)` | `3, 1/3, 1` | 1/3 | 3 |

In every sample the minimum is `≤ 1` and the maximum is `≥ 1`, with equality throughout
only for the ball. This is the numerical content of `exists_centralSection_le_ball` and
`exists_centralSection_ge_ball`, both proved from `∏ λᵢ = det A`.

## 8. Equality case of the slicing bounds (third cycle)

Take `A = diag(3, 2, 1)` in `ℝ³`, so `λ_max = 3` and `λ_min = 1`. The section factor of a
unit direction `u` is `‖Aᵀu‖ = ‖Au‖`, and the table records both it and the eigenvector
defect `‖Au − 3u‖`.

| unit direction `u` | `‖Au‖` | `‖Au − 3u‖` |
|---|---|---|
| `(1, 0, 0)` | 3.0000 | 0.0000 |
| `(0, 1, 0)` | 2.0000 | 1.0000 |
| `(0, 0, 1)` | 1.0000 | 2.0000 |
| `(0.707, 0.707, 0)` | 2.5495 | 0.7071 |
| `(0.577, 0.577, 0.577)` | 2.1602 | 1.2910 |
| `(0.990, 0.141, 0)` | 2.9834 | 0.1410 |

Only the exact eigenvector reaches the value 3, and a direction 8° away from it already
loses the bound; a sample of 200000 uniformly random unit vectors gives a maximum of
2.999998, approaching but never attaining `λ_max` off the eigenspace. This is the
quantitative shadow of `eucNorm_transpose_mulVec_eq_max_iff`, which proves that the defect
`‖Au − hi·u‖` vanishes *exactly* when the section factor equals the bound.

Note that the last row also shows how the equality case can fail to be robust: the section
factor is within 0.6% of the extreme value while the direction is not an eigenvector at
all, so the formalized statement is an exact-equality statement and does not by itself
give a stability estimate. Quantifying that gap is a natural follow-up.

## 9. Maximal-volume inscribed ellipsoids (third cycle)

Small-case data for the objective `det A` maximized over inscribed generators, computed
from the classical closed forms and compared with what the formalized existence theorem
guarantees:

| body `K` in `ℝⁿ` | maximizing generator `A` | `det A` |
|---|---|---|
| unit ball `B` | `I` | 1 |
| cube `[-1,1]ⁿ` | `I` | 1 |
| box `∏ [-a_i, a_i]` | `diag(a)` | `∏ a_i` |
| ellipsoid `E A₀` | `A₀` | `det A₀` |

Every entry is a maximizer of a continuous function over the compact set
`inscribedGens K` of `Catalog/Bridges/EllipsoidJohnExistence.lean`, whose compactness the
file proves via the entry bound `|A i j| ≤ R` for `K ⊆ B(0, R)`; the sharpness of that
bound is visible in the box row, where the maximizing generator has an entry equal to
`max_i a_i`. Only the *existence* of a maximizer is formalized: the table's identification
of which generator maximizes is classical input, not a verified claim, except for the unit
ball row, which is the instantiation `exists_maxVolume_inscribed_ellipsoid_closedBall`.
