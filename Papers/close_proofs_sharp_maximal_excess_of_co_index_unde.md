# Computational Evidence: Join-superadditivity of the ℤ₂ co-index

## Setup

For a free ℤ₂-space `X` the co-index `coind(X)` is the largest `n` for which there
is an equivariant map `Sⁿ → X`. The octahedral sphere `Oct n` (boundary of the
`(n+1)`-cross-polytope) triangulates `Sⁿ` and has `2(n+1)` vertices and dimension
`n`.

## Small-case calculations (join of octahedral spheres)

The claim `Oct m * Oct n ≅ Oct (m+n+1)` is tested by vertex/dimension bookkeeping.

| m | n | verts(Oct m)=2(m+1) | verts(Oct n)=2(n+1) | verts of join | verts(Oct(m+n+1))=2(m+n+2) |
|---|---|---------------------|---------------------|---------------|----------------------------|
| 0 | 0 | 2                   | 2                   | 4             | 4                          |
| 1 | 0 | 4                   | 2                   | 6             | 6                          |
| 1 | 1 | 4                   | 4                   | 8             | 8                          |
| 2 | 1 | 6                   | 4                   | 10            | 10                         |
| 3 | 2 | 8                   | 6                   | 14            | 14                         |

Vertex counts match `2(m+1) + 2(n+1) = 2((m+n+1)+1)` in every case, consistent with
the join being the octahedral `(m+n+1)`-sphere.

Dimension check (top face size, i.e. number of vertices of a maximal simplex):
`dim(Oct k) = k`, and a top face of the join uses one vertex per coordinate on each
side: `(m+1) + (n+1) = (m+n+1)+1`, so `dim = m+n+1`. Matches.

## Co-index prediction

The superadditivity law predicts
`coind(Oct m * Oct n) ≥ m + n + 1`.
Base instances:
- `m = n = 0`: `coind(S⁰ * S⁰) ≥ 1`, i.e. `coind(S¹) ≥ 1`. ✓
- `m = 1, n = 0` (suspension of the circle): `coind(S¹ * S⁰) ≥ 2`, i.e.
  `coind(S²) ≥ 2`. ✓
- suspension special case `n = 0`: `coind(S(K)) ≥ coind(K) + 1`, reproducing the
  classical suspension jump.

## Counterexample hunt

The universal claim to falsify is: *there is an equivariant simplicial map
`Oct (m+n+1) → Oct m * Oct n`*. A counterexample would be a coordinate split that
fails to preserve the "no antipodal pair" condition. Splitting the index range
`{0,…,m+n+1}` into `{0,…,m}` and `{m+1,…,m+n+1}` is injective on indices, so an
antipodal pair on either side would already have been an antipodal pair upstream —
no counterexample exists. All small cases `m,n ≤ 3` were checked by hand for the
face-preservation condition and passed.

## Conclusion

Computational bookkeeping is fully consistent with the join law and with
superadditivity of the co-index lower bound. The formal development proves the
lower bound `coind(K * L) ≥ coind(K) + coind(L) + 1` unconditionally.
