# Computational Evidence — Discrete Pseudomanifolds at the Vertex Threshold

This note records the small-case computations that motivated and validated the two
Lean files in `Catalog/Geometry/PseudomanifoldRP2/`.

## 1. The minimal 6-vertex ℝP² triangulation

Facets (vertices `0..5`), the Möbius triangulation:

```
{0,1,2} {0,2,3} {0,3,4} {0,4,5} {0,1,5}
{1,2,4} {1,3,4} {1,3,5} {2,3,5} {2,4,5}
```

Direct enumeration gives:

| quantity | value | meaning |
|----------|-------|---------|
| facets `f₂` | 10 | triangles |
| edges  `f₁` | 15 | all `C(6,2)` pairs occur (2-neighborly) |
| vertices `f₀` | 6 | all vertices used |
| ridge degree | 2 for every edge | non-branching (pseudomanifold) |
| Euler char `f₀ − f₁ + f₂` | `6 − 15 + 10 = 1` | ℝP² |

An initial candidate facet list was tested first and **rejected**: some edges had
ridge degree ≠ 2. The counterexample hunt (printing the per-edge facet counts)
located the bad edges and led to the correct Möbius list above, whose 15 edges all
have degree exactly 2.

Handshake check: `(d+1)·f_d = 2·(#ridges)` reads `3·10 = 2·15 = 30`. ✔

## 2. Suspension and Euler characteristic

The combinatorial suspension `Σ` adds two fresh apex vertices and cones the whole
complex to each. Computed values of the iterated suspension of ℝP²₆:

| iterate `k` | dimension | vertices | Euler characteristic |
|-------------|-----------|----------|----------------------|
| 0 | 2 | 6  | 1 |
| 1 | 3 | 8  | 1 |
| 2 | 4 | 10 | 1 |

The Euler characteristic is invariant under suspension here because `1` is the fixed
point of `x ↦ 2 − x`, matching the general formula `χ(ΣC) = 2 − χ(C)`.

Vertex count of the `(d−2)`-fold suspension: `6 + 2(d−2) = 2d + 2`. (Note: this is
the standard vertex-minimal figure; it differs from the `2d+7` quoted informally in
the mission statement, which we do not reproduce because the standard construction
gives `2d+2`.)

## 3. Sphere comparison

The boundary of the `(d+1)`-simplex (a simplicial `d`-sphere) has Euler
characteristic `1 + (−1)^d`:

| d | χ(sphere) |
|---|-----------|
| 2 | 2 |
| 3 | 0 |
| 4 | 2 |
| 5 | 0 |

Since `1 + (−1)^d ∈ {0, 2}` is never `1`, the iterated suspensions of ℝP²₆ (all with
χ = 1) can never be simplicial spheres. This is the dimension-uniform obstruction
formalized in `SuspensionEuler.lean`.

## 4. OEIS

The f-vector `(6, 15, 10)` and the sequence of suspension vertex counts
`6, 8, 10, 12, …` (arithmetic, difference 2) are elementary and were not pursued as
OEIS lookups; the mathematically meaningful invariant is the constant Euler
characteristic `1`.
