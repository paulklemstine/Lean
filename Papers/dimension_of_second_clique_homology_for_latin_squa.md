# Computational Evidence: Latin Square Graphs, Regularity, and Intercalates

All computations below were run directly with `#eval` in Lean over exact
finite types (`Fin n`), so the numbers are exact, not floating point.

## 1. Degree of the Latin square graph `L(M)`

For the cyclic Latin square `M i j = i + j`, the degree of a fixed cell is:

| n | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|
| deg | 3 | 6 | 9 | 12 | 15 |

This matches `3(n-1)` exactly. The general theorem
`LatinSquare.neighbors_card` proves `deg = 3(n-1)` for **every** Latin square, by
partitioning the neighbourhood into the co-row, co-column, and co-symbol blocks
(each of size `n-1`), whose disjointness is exactly the Latin property.

## 2. Number of cells carrying a fixed symbol

| n | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| #cells with symbol s | 1 | 2 | 3 | 4 | 5 |

Always `n`, confirming the co-symbol block has size `n-1` after removing the base
cell (used in `LatinSquare.symSet_card`).

## 3. Intercalate counts of the cyclic Latin square

An intercalate is a `2×2` Latin subsquare (rows `r₁<r₂`, cols `c₁<c₂` with the
crossed pattern). Counts for `M i j = i+j`:

| n | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| I(M) | 0 | 1 | 0 | 4 | 0 | 9 | 0 | 16 |

Pattern: `I = (n/2)²` for even `n`, and `I = 0` for odd `n`. The half-shift
`m = n/2` is the unique nonzero solution of `2(c₁-c₂) = 0` in `Z_n`, which is why
odd orders have none. The existence direction (even `n` ⇒ an intercalate exists)
is proved in `Cyclic.lean` as `cyclicLatin_intercalate_even`.

- OEIS: the even-order subsequence `1, 4, 9, 16, 25, …` is `A000290` (squares);
  the full interleaved sequence `0,1,0,4,0,9,0,16,…` is the squares placed at even
  indices.

## 4. Consistency check for the homology dimension formula

The research target claims `dim H₂ = (n-1)³ - I(M)`. A necessary sanity condition
is `I(M) ≤ (n-1)³` (a dimension is non-negative). The maximum number of
intercalates over all Latin squares of order `n` is at most `n²(n-1)/4`
(each unordered row pair contributes at most `n/2` intercalates, from the 2-cycles
of the permutation linking the two rows). Since
`n²(n-1)/4 ≤ (n-1)³ ⟺ n² ≤ 4(n-1)² ⟺ n ≤ 2(n-1) ⟺ n ≥ 2`,
the RHS is non-negative for all `n ≥ 2`, consistent with being a dimension. The
cyclic square realizes only `(n/2)²`, far below this maximum.

## 5. Tetrahedra hunt

For each intercalate, the four cells are pairwise adjacent (a `K₄`), and the two
diagonal edges are *symbol* edges connecting cells in different rows and columns.
Checked on the order-4 and order-6 cyclic squares: every intercalate yields such a
mixed `K₄`, and no `K₄` of this mixed diagonal type occurs without an intercalate.
This is the local mechanism behind the `-I(M)` term and is proved in generality by
`Intercalate.forms_clique` and `Intercalate.diagonal_is_symbol_edge`.
