# Computational Evidence

All numerical facts below are additionally **machine-checked** inside
`Catalog/Applications/BalancedHClique.lean` (the finite octahedron facts are
proved by Lean's kernel `decide`, so this file only records the reasoning).

## 1. The forbidden graph: complement of `3K₂`

`3K₂` is the perfect matching on `Fin 6` with edges `{0,1}, {2,3}, {4,5}`
(vertices `i, j` adjacent iff `i ≠ j` and `⌊i/2⌋ = ⌊j/2⌋`).

Its complement `(3K₂)ᶜ` has `i ~ j` iff `i ≠ j` and `⌊i/2⌋ ≠ ⌊j/2⌋`.
This is exactly the octahedron `K_{2,2,2}` with parts `{0,1}, {2,3}, {4,5}`.

The equality `(3K₂)ᶜ = Oct` is proved as `oct_eq_compl_threeK2`.

## 2. Maximal cliques of the octahedron

A clique of `K_{2,2,2}` picks at most one vertex from each antipodal pair,
so the maximal cliques are exactly the `2·2·2 = 8` "transversal" triangles:

```
{0,2,4} {0,2,5} {0,3,4} {0,3,5} {1,2,4} {1,2,5} {1,3,4} {1,3,5}
```

Each is a maximal clique (adding a 4th vertex forces two antipodal, hence
non-adjacent, vertices). Verified for the three triangles used below via
`oct_maxClique_024`, `oct_maxClique_125`, `oct_maxClique_134` (kernel `decide`).

## 3. The bad triple — a single obstruction in two worlds

Take the three maximal cliques

```
A = {0,2,4}   B = {1,2,5}   C = {1,3,4}
```

Pairwise intersections:

```
A ∩ B = {2}     A ∩ C = {4}     B ∩ C = {1}     A ∩ B ∩ C = ∅
```

### (a) Helly obstruction (graph theory)

`A, B, C` are three maximal cliques that pairwise intersect but have **no common
vertex** — so the octahedron is **not clique-Helly**. This is the classical
smallest non-clique-Helly graph. Proved as `oct_not_cliqueHelly`.

### (b) Balancedness obstruction (0/1-matrix theory)

Incidence of rows `A, B, C` against the columns (vertices) `2, 4, 1`:

|   | 2 | 4 | 1 |
|---|---|---|---|
| A | 1 | 1 | 0 |
| B | 1 | 0 | 1 |
| C | 0 | 1 | 1 |

This `3 × 3` submatrix of the clique matrix has **exactly two `1`'s in every row
and every column** and **odd** order `3`. Hence the clique matrix is not
balanced, and the octahedron is **not balanced**. Proved as `oct_not_balanced`.

Both (a) and (b) are read off the *same* combinatorial object, captured
abstractly as `BadTriple` and turned into the two obstructions by
`not_cliqueHelly_of_badTriple` and `not_balanced_of_badTriple`.

## 4. Counterexample hunt for the full three-way equivalence

The description's conjecture (i)⟺(ii)⟺(iii) has a subtle direction:
*balanced ⇒ no induced octahedron*. Unlike the clique-Helly side, this does
**not** reduce to a local transport of the bad triple, because a triangle of an
induced octahedron need not remain a *maximal* clique in the ambient graph, and
balancedness is a statement about the *maximal*-clique matrix. We therefore do
**not** assert this direction; we prove the robust part
(hereditary clique-Helly ⇒ no induced octahedron) and the concrete two-world
obstruction on the octahedron itself. See `FUTURE_DIRECTIONS.md`.

No counterexample to the proved statements was found; small cases are consistent
with the octahedron being the minimal simultaneous obstruction.
