# Computational Evidence — Finite-type cluster algebra on Schubert cells (type A)

Model: convex `m`-gon ↔ cluster algebra of type `A_{m-3}` on `Gr(2,m)` (the
basic Schubert-cell case inside the type-A flag variety). Diagonals ↔ mutable
cluster variables, triangulations ↔ clusters, diagonal flips ↔ mutations.

All numbers below were produced by the *decidable* Finset model in
`Catalog/Geometry/ClusterFiniteTypeA.lean` and are re-checked there by
`native_decide`.

## 1. Small-case calculations

| polygon `m` | cluster type | #diagonals = `m(m-3)/2` | #clusters | rank (diagonals/cluster) | exchange degree |
|-------------|--------------|--------------------------|-----------|--------------------------|-----------------|
| 3 (`A_0`)   | trivial      | 0                        | 1         | 0                        | 0               |
| 4 (`A_1`)   | `A_1`        | 2                        | 2         | 1                        | 1               |
| 5 (`A_2`)   | `A_2`        | 5                        | 5         | 2                        | 2               |
| 6 (`A_3`)   | `A_3`        | 9                        | 14        | 3                        | 3               |
| 7 (`A_4`)   | `A_4`        | 14                       | 42        | 4                        | 4               |

## 2. OEIS

* #clusters `1, 2, 5, 14, 42, …` = Catalan numbers **A000108** (here
  `catalan (m-2)`), the count of triangulations of a convex polygon / vertices
  of the type-A associahedron (Stasheff polytope).
* #cluster variables `0, 2, 5, 9, 14, …` = `r(r+3)/2` for `r = m-3`,
  i.e. **A000096** (`n(n+3)/2`), the number of cluster variables of finite
  type `A_r` (Fomin–Zelevinsky).

## 3. Counterexample hunt

* "Every cluster has the same size `m-3`" — tested over **all** triangulations
  for `m ≤ 7`; no counterexample (theorems `rank_const_*`).
* "Exchange graph is `(m-3)`-regular" — tested over all clusters for `m ≤ 7`;
  no counterexample (theorems `exchange_regular_*`).
* "#clusters `= catalan (m-2)`" — exact for `m = 3,…,7`
  (theorems `clusters_eq_catalan_*`).

## 4. Notes

The enumeration is bounded only by the `2^{#diagonals}` powerset search
(`#diagonals = 14` at `m = 7`), not by any mathematical obstruction; the finite
type property itself (finitely many clusters) is proved structurally for **all**
`m` in `ClusterA.finiteType`.
