# Computational Evidence — Wall–Menger Separator Optimality

Object: the `(m+1) × (n+1)` grid graph `Grid m n = pathGraph (m+1) □ pathGraph (n+1)`,
with the **left/right cut** separating column `0` from column `n` (= `Fin.last n`).

We study two quantities:
- `cut(m,n)` = minimum number of vertices whose property "meets every left→right walk"
  (an `A`–`B` separator).
- `paths(m,n)` = maximum number of pairwise vertex-disjoint left→right paths.

Menger duality predicts `cut = paths`. The conjecture under test: for the
left/right cut, `cut(m,n) = paths(m,n) = m+1` (the height), independent of width
`n` (for `n ≥ 1`).

## Small-case calculations

| grid (rows × cols) | m | n | height m+1 | disjoint paths (rows) | column cut size |
|--------------------|---|---|------------|-----------------------|-----------------|
| 1 × 2              | 0 | 1 | 1          | 1                     | 1               |
| 2 × 2              | 1 | 1 | 2          | 2                     | 2               |
| 2 × 3              | 1 | 2 | 2          | 2                     | 2               |
| 3 × 3              | 2 | 2 | 3          | 3                     | 3               |
| 3 × 4              | 2 | 3 | 3          | 3                     | 3               |
| 4 × 5              | 3 | 4 | 4          | 4                     | 4               |

In every case the explicit row-paths (one per row) are pairwise disjoint and give
`m+1` disjoint left→right paths, while any single full column `{x | x.2 = c}` has
exactly `m+1` vertices and meets every left→right walk. Hence
`paths ≥ m+1` and `cut ≤ m+1`; the abstract lower bound forces `cut ≥ m+1`, so
`cut = paths = m+1`.

## Why optimality holds (the mechanism)

- **Lower bound (cut ≥ #disjoint paths).** Each of the `m+1` row-paths must contain
  a separator vertex; distinct rows are vertex-disjoint, so the chosen vertices are
  distinct → at least `m+1` separator vertices. (Formalized:
  `menger_separator_lower_bound`.)
- **Upper bound (a column is a separator of size `m+1`).** Along any walk the column
  coordinate changes by at most 1 per edge, so a left→right walk (column `0` to
  column `n`) hits every intermediate column value — a discrete intermediate value
  theorem. (Formalized: `walk_exists_mem_support_of_le`, `grid_column_isSeparator`.)

## Sequence note

The optimal cut value as a function of height is simply `cut(m,·) = m+1`
(the identity sequence `1, 2, 3, 4, …`, OEIS A000027 shifted), confirming the
height-only dependence and width-independence (for `n ≥ 1`).

## Counterexample hunt

We tested the width-independence claim across `n ∈ {1,…,4}` for fixed heights
`m+1 ∈ {1,…,4}`: in all cases the cut equals the height. No counterexample to
`cut(m,n) = m+1` was found. (The degenerate `n = 0` single-column grid has
`A = B`, which is excluded by the hypothesis `1 ≤ n`.)

All claims above are now machine-checked in `WallMengerSeparator.lean`
(0 sorries; axioms: `propext`, `Classical.choice`, `Quot.sound`).
