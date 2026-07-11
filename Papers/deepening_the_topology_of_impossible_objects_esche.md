# Computational Evidence: Cohomology of Impossible Figures

Concise numerical support for the two theorems proved this cycle.

## 1. One–dimensional figures: `H¹(S¹) ≅ A` via holonomy

A cyclic figure on `n` overlapping patches carries increments `t : ZMod n → A`;
its holonomy is `∑ i, t i`, and it is realizable iff the holonomy vanishes.

Small cases (real depth increments):

| figure                                  | n | holonomy | realizable? |
|-----------------------------------------|---|----------|-------------|
| Penrose triangle `(1,1,1)`              | 3 | 3        | no          |
| `(1, 2, -3)`                            | 3 | 0        | yes         |
| Escher staircase `(1,1,1,1)` ascending  | 4 | 4        | no          |
| balanced staircase `(1,-1,1,-1)`        | 4 | 0        | yes         |
| any coboundary `h(i+1)-h(i)`            | n | 0        | yes         |

Observations confirmed in the formal development:
- Holonomy is surjective onto `A` (concentrate the whole increment on one overlap),
  so every real number is the impossibility class of some figure — `H¹ ≅ ℝ`.
- Two figures are cohomologous (differ by a coboundary) **iff** they share a
  holonomy value; e.g. `(1,2,-3)` and `(0,0,0)` are cohomologous (both holonomy `0`),
  while `(1,1,1)` (holonomy `3`) is not cohomologous to either.
- The Penrose triangle is a generator: every three–patch figure is cohomologous to
  the constant figure `holonomy/3`.

## 2. Orientation (`A = ℤ/2`): the Möbius/Klein class

Holonomy in `ℤ/2` counts orientation flips modulo `2`:

| flips around loop | holonomy in ℤ/2 | orientable? |
|-------------------|-----------------|-------------|
| 0                 | 0               | yes         |
| 1 (Möbius)        | 1               | no          |
| 2                 | 0               | yes         |
| 3 (Klein loop)    | 1               | no          |

An odd number of flips is a nonzero class, hence non-orientable — matching the
formal `klein_orientation_impossible`.

## 3. Two–dimensional figures on the torus: curvature and periods

A figure `(a, b)` on `ZMod m × ZMod n` has, per unit square, the curvature
`curv(i,j) = a(i,j) + b(i+1,j) - a(i,j+1) - b(i,j)`, and two global periods
`periodX = ∑_i a(i,0)`, `periodY = ∑_j b(0,j)`.

Test figures:

| figure                                   | flat? | periodX | periodY | realizable? |
|------------------------------------------|-------|---------|---------|-------------|
| any gradient `(dx h, dy h)`              | yes   | 0       | 0       | yes         |
| Waterfall `a≡1, b≡0` on `3×3`            | yes   | 3       | 0       | no          |
| twisted tile (curv `1` at origin) `2×2`  | no    | 0       | 0       | no          |
| flat + zero periods                      | yes   | 0       | 0       | yes         |

Discrete Stokes check: summing `curv` over all tiles gives `0` for **every** test
figure above, including the twisted tile (its single `+1` tile is balanced by a `-1`
tile forced by periodicity). This is the closed–surface identity
`total_curvature_zero`, and it shows the two obstruction types are independent: the
Waterfall is flat yet impossible (global period), while the twisted tile has zero
periods yet is impossible (local curvature).

## Counterexample hunt

We searched for the naive claims that (a) uniform local data implies impossibility
and (b) non-uniform local data implies realizability. Both fail: the balanced
staircase `(1,-1,1,-1)` is maximally non-uniform yet realizable, and the Penrose
triangle is maximally uniform yet impossible. Impossibility is genuinely a global
(cohomological) invariant, not a property of the local data — consistent with the
completed classification.

## No OEIS sequence

The invariants here are group elements (holonomy, periods) rather than integer
sequences, so no OEIS lookup applies; the evidence above is the relevant check.
