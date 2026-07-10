# Computational Evidence — Turing's Flowers: Morphogenesis as Algebraic Geometry

## 1. The Chebyshev correspondence (number of modes = algebraic degree)

Each spatial mode `cos(n θ)` is a polynomial of degree `n` in `X = cos θ`
(the Chebyshev polynomial of the first kind, `T_n`).  Small cases:

| n | cos(n θ) as a polynomial in X = cos θ | degree | leading coeff |
|---|----------------------------------------|--------|---------------|
| 0 | 1                                      | 0      | 1             |
| 1 | X                                      | 1      | 1             |
| 2 | 2X² − 1                                | 2      | 2             |
| 3 | 4X³ − 3X                               | 3      | 4             |
| 4 | 8X⁴ − 8X² + 1                          | 4      | 8             |
| 5 | 16X⁵ − 20X³ + 5X                       | 5      | 16            |

Observed degree = `n` exactly, and leading coefficient = `2^(n-1)` for `n ≥ 1`.
This confirms the "number of modes = degree" prediction: a `k`-mode superposition
is a polynomial of degree `≤ k` (equal to `k` when the top mode is present); the
squared three-mode amplitude reaches degree 6 (a sextic), matching the "up to 6"
prediction for hexagonal (three-mode) systems.

## 2. Conic level sets (two-mode = degree 2)

Level sets of the degree-2 building block, tested on a grid:

* Definite form `a x² + b y² = c` (`a,b,c > 0`): **bounded** — every solution
  satisfies `x² ≤ c/a`, `y² ≤ c/b`.  Numerically the solution set is an ellipse
  (a spot).  Isotropic case `a = b`: an exact circle of radius `√(c/a)`.
* Indefinite form `x² − y² = c` (`c > 0`): **unbounded** — the sample point
  `(√(t²+c), t)` lies on the curve for all `t`, with squared norm `2t² + c → ∞`.
  Numerically a hyperbola (a labyrinth branch).
* Single mode `cos x = c` (`−1 < c < 1`): **unbounded and 2π-periodic** — the point
  `(arccos c, y)` lies on the set for all `y`, and the pattern repeats under
  `x ↦ x + 2πk`.  Numerically an infinite family of parallel stripes.

## 3. Counterexample hunt

* *Claim tested*: "spot (circle) and labyrinth (hyperbola) level sets could coincide."
  **Refuted** computationally and then proved: the hyperbola contains points of
  squared norm `> ρ²` for any `ρ`, whereas the circle `x² + y² = ρ²` does not.  The
  two sets are always distinct.
* *Claim tested*: "cos(nθ) needs degree > n as a polynomial in cos θ."  **Refuted**:
  degree is exactly `n` in every sampled case (table above).

## 4. Topology / genus (recorded, not formalised here)

For the complexified projective conic, the genus of a smooth conic is 0 (spot ↔
oval ↔ sphere-like component) and a degenerate conic (pair of lines ↔ stripe)
behaves like the boundary between genus classes.  The genus reading of higher-degree
(sextic) curves is consistent with hexagonal topology but requires the theory of real
plane curves; it is deferred to the future-directions note.

## Conclusion

The computational landscape supports the core conjecture: mode count is a polynomial
degree, and the bounded/unbounded dichotomy of the associated conic distinguishes
spots from labyrinths and stripes.  These are the statements proved formally in
`TuringFlowersAlgebraicGeometry.lean`.
