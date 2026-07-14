# Computational Evidence: ℤ₂-coindex of combinatorial spheres

## Model recap

`Sⁿ` is the boundary of the `(n+1)`-cross-polytope; its vertices are the `2(n+1)` signed unit
vectors `±eᵢ`, with the free ℤ₂-action given by the antipodal map. An equivariant simplicial
map `Sᵐ → Sⁿ` is determined by the images of the `m+1` positive vertices, so the existence of
such a map is a finite, decidable question about a function `Fin (m+1) → Fin (n+1) × Bool`.

## Small-case existence table (coindex witnesses `Sᵐ → Sⁿ`)

| m \ n | 0 | 1 | 2 |
|-------|---|---|---|
| 0     | yes | yes | yes |
| 1     | **no** | yes | yes |
| 2     | no | **no** | yes |
| 3     | no | no | **no** |

- The "yes" cells on and below the diagonal are realized explicitly: identity maps on the
  diagonal, equatorial inclusions (and their suspensions) above it. This is the constructive
  lower bound `coind(Sⁿ) ≥ n`.
- The first "no" in each column, on the super-diagonal `m = n+1`, is a finite Borsuk–Ulam
  obstruction: `S¹ → S⁰`, `S² → S¹`, and (new this cycle) `S³ → S²`. These pin
  `coind(Sⁿ) = n` for `n = 0, 1, 2`.

## Counterexample hunt

The universal claim under test is "each suspension raises the coindex by exactly one". The
lower half (at least one) is the suspension functor; the upper half (at most one) is the
super-diagonal obstruction. An exhaustive finite search over positive-vertex data confirms the
super-diagonal `no` entries above; no map `S^{n+1} → Sⁿ` was found for `n ≤ 2`, i.e. no
counterexample to sharpness in the verified range.

## Search-space sizes

For `S³ → S²` the positive-vertex data ranges over `(2·3)^4 = 1296` functions, each checked on
all `8 · 8 = 64` ordered vertex pairs. The space is small enough to settle by exhaustive
evaluation but large enough that naive structural recursion overflows the default recursion
depth — consistent with the obstruction being genuinely finite-combinatorial rather than
formal.

## Notes

No matching OEIS sequence is expected: the diagonal boundary of the existence table is simply
`coind(Sⁿ) = n`, the identity sequence, which is exactly the content being certified.
