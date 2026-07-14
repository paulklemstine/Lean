# Computational Evidence: the suspension tower over the octahedral spheres

This note records the small-case landscape that guided the theorems in
`SuspensionCoindexTower.lean` before they were proved.

## Objects

For a free ℤ₂-complex `K` the (unreduced) suspension is `S(K) = K * S⁰`; the
`k`-fold tower is `Sᵏ(K)`. The guiding examples are the octahedral spheres
`Oct n` (boundary of the `(n+1)`-cross-polytope, a triangulation of `Sⁿ`).

Two integer invariants are tracked:

* `coind` — the largest `m` with an equivariant simplicial map `Oct m → K`
  (a subdivision-free lower bound for the topological ℤ₂-co-index);
* `dim` — one less than the maximal face cardinality.

## Small cases: dimension of the tower over `Oct n`

The vertex count and top-face size of `Sᵏ(Oct n)` were computed directly from the
face rule (a face is antipodal-pair-free in the base and uses at most one of the two
apexes at each suspension level).

| `n` | `k` | vertices `= 2(n+1) + 2k` | top-face size `= (n+1) + k` | `dim = n + k` |
|-----|-----|--------------------------|-----------------------------|----------------|
| 0   | 0   | 2                        | 1                           | 0              |
| 0   | 1   | 4                        | 2                           | 1              |
| 0   | 2   | 6                        | 3                           | 2              |
| 0   | 3   | 8                        | 4                           | 3              |
| 1   | 0   | 4                        | 2                           | 1              |
| 1   | 1   | 6                        | 3                           | 2              |
| 1   | 2   | 8                        | 4                           | 3              |
| 2   | 1   | 8                        | 4                           | 3              |

The top-face size is `(n+1) + k` in every case: each suspension adds exactly one
apex to a top face. This is the content of `SuspIter_Oct_dim_lower`
(a face of size `n+1+k` exists) and `SuspIter_Oct_dim_upper` (no face is larger),
which together pin `dim(Sᵏ(Oct n)) = n + k`.

## Small cases: co-index of the tower

Each suspension provides an explicit equivariant map `Oct (m+1) → S(K)` out of one
`Oct m → K`, so `coind` climbs by at least one per level:

| `n` | `k` | `coind ≥` (from the tower map) | `dim` |
|-----|-----|--------------------------------|-------|
| 0   | 1   | 1                              | 1     |
| 0   | 2   | 2                              | 2     |
| 0   | 3   | 3                              | 3     |
| 1   | 2   | 3                              | 3     |

In every computed row `coind ≥ dim`, and since `coind ≤ dim` always holds, the tower
is **co-index efficient**: excess `coind − dim = 0`. This is exactly the opposite
regime from the maximal-excess programme and makes the tower a clean control family.

## Counterexample hunt: does the tower ever map back to `S⁰`?

We searched for an equivariant simplicial map `Sᵏ(Oct 0) → Oct 0` for `k = 1, 2, 3`
by attempting to 2-colour the vertices consistently with the antipodal action and the
apex-disjointness rule. Every attempt forces two vertices joined by an edge to
receive antipodal colours, which the face rule of `Oct 0` forbids. No such map was
found for any `k ≥ 1`. This matched the proved statement
`no_map_susp_tower_to_S0`: composing the tower map `Oct k → Sᵏ(Oct 0)` with a
hypothetical retraction would yield `Oct k → Oct 0`, contradicting the Borsuk–Ulam
base case.

## Conclusion

The computational landscape is fully consistent with — and predicted — the three
proved phenomena: linear co-index growth (`+1` per suspension), exact dimension
`n + k`, and the non-existence of a tower retraction to `S⁰`. No contradicting case
was found, so we proceeded to the formal proofs.
