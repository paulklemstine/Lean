# Computational Evidence: coindex as a complete invariant of finite free ℤ₂-sets

Model recap. A *free ℤ₂-set* is a finite vertex set with a fixed-point-free involution
`anti` (the antipodal map). Its simplicial structure is the octahedral one: faces are the
antipodal-pair-free subsets. The octahedral sphere `Oct n = Sⁿ` is the signed unit vectors
`Fin (n+1) × Bool` with `anti (i,b) = (i,!b)`; it has `2(n+1)` vertices and `n+1` antipodal
orbits. The coindex is `coind K = sup { m | there is an equivariant simplicial map Sᵐ → K }`.

## 1. Small-case calculations (orbit count vs. coindex)

| free ℤ₂-set                         | vertices | orbits | coind (computed) |
|-------------------------------------|:--------:|:------:|:----------------:|
| `S⁰ = Oct 0` (2 antipodal points)   | 2        | 1      | 0                |
| 4 points, 2 orbits (`= Oct 1`, a 4-cycle = S¹) | 4 | 2 | 1        |
| `Oct 2` (octahedron boundary = S²)  | 6        | 3      | 2                |
| `Oct m`                             | 2(m+1)   | m+1    | m                |

Key observation: for every finite free ℤ₂-set the octahedral complex on its `2c` vertices is
exactly the boundary of the `c`-dimensional cross-polytope, i.e. a sphere `S^{c-1}`. Hence
`coind = orbits − 1 = vertices/2 − 1` in every computed case. There is no gap between the
lower bound (an explicit equivariant bijection to `Oct (c-1)`) and the upper bound (vertex
injectivity of any equivariant simplicial map forces `2(m+1) ≤ vertices`).

## 2. Join calculations

The join `K ⋆ L` takes the disjoint union of vertices; orbits add:
`orbits(K ⋆ L) = orbits(K) + orbits(L)`. Therefore
`coind(K ⋆ L) = orbits(K ⋆ L) − 1 = (orbits K − 1) + (orbits L − 1) + 1
             = coind K + coind L + 1`.

| K        | L        | coind K | coind L | coind(K⋆L) | K⋆L ≅        |
|----------|----------|:-------:|:-------:|:----------:|--------------|
| `Oct 0`  | `Oct 0`  | 0       | 0       | 1          | `Oct 1`      |
| `Oct 1`  | `Oct 0`  | 1       | 0       | 2          | `Oct 2`      |
| `Oct m`  | `Oct n`  | m       | n       | m+n+1      | `Oct (m+n+1)`|

All rows satisfy `coind(K⋆L) = coind K + coind L + 1` exactly — both the lower and the upper
half. This is the sharp join law, confirmed to hold in full generality (arbitrary finite
nonempty free ℤ₂-sets), not merely on the octahedral tower.

## 3. Counterexample hunt

We tested whether a finite free ℤ₂-set could have coindex strictly below `orbits − 1`
(which would make the upper half of the join law a genuine extra obstruction). No such object
exists in this model: an equivariant bijection to the octahedral sphere of the matching orbit
count always exists (choose one representative per orbit), so the coindex always attains its
maximal possible value `orbits − 1`. The "cohomological obstruction" that separates the two
halves of the join law in the topological setting therefore collapses in the combinatorial
octahedral model.

## 4. Sequences

The vertex counts of the octahedral tower are `2, 4, 6, 8, …` (the even numbers, OEIS A005843),
and the coindices are `0, 1, 2, 3, …` (OEIS A001477). The join law is the shift-by-one
additive structure on the latter, i.e. the octahedral spheres form a monoid isomorphic to
`(ℕ, (a,b) ↦ a+b+1)`.
