# Computational Evidence: Conservation in Jigsaw Assemblies

This note records the small-case exploration that motivated the conservation law
for validly assembled puzzles, in which a *tab* edge carries potential `+1`, a
*blank* edge carries `-1`, and a *flat* border edge carries `0`.

## 1. The signed potential of an edge

| edge  | potential |
|-------|-----------|
| tab   | `+1`      |
| blank | `-1`      |
| flat  | `0`       |

Complementation (the shape that physically interlocks with a given edge) swaps
tab and blank and fixes flat, so it **negates** the potential. This is the single
fact that forces the conservation law.

## 2. Small-case row calculations

We laid out rows of interlocking pieces. In every row the far-left and far-right
edges are flat, and each interior interface pairs a right edge with the
complementary left edge of its neighbour. Counting exposed tabs versus blanks:

| pieces in row | interface pattern (right→left)     | tabs | blanks |
|---------------|------------------------------------|------|--------|
| 1             | (none)                             | 0    | 0      |
| 2             | tab ⟷ blank                        | 1    | 1      |
| 2             | blank ⟷ tab                        | 1    | 1      |
| 3             | tab ⟷ blank, blank ⟷ tab           | 2    | 2      |
| 3             | tab ⟷ blank, tab ⟷ blank           | 2    | 2      |
| 4             | tab, blank, tab (interior rights)  | 3    | 3      |

In all cases **tabs = blanks**. The reason is local: each interior interface
contributes one edge `e` and its complement, hence exactly one tab and one blank,
regardless of the value of `e`; the two flat ends contribute neither.

## 3. Two-dimensional check

For rectangular assemblies the same balance holds. Summing the row identity across
all rows accounts for every horizontal (left/right) edge; summing an analogous
column identity accounts for every vertical (top/bottom) edge. A worked `2 × 2`
example with tabs and blanks placed on the four interior interfaces yields 4 tabs
and 4 blanks. The general handshake bookkeeping
`2·(interior interfaces) + (border edges) = 4·(pieces)` was checked symbolically
for the `(r+1)×(c+1)` family.

## 4. Counterexample hunt

We searched for a valid row or rectangle with unequal tab and blank counts and
found none: any imbalance would require an interior interface whose two sides are
not complementary, which violates the interlocking rule, or a non-flat border
edge, which violates the boundary rule. This search *failed to find a
counterexample*, consistent with the theorem.

## 5. The symmetry group of interlocking

Enumerating all six relabellings of the three edge shapes, exactly two preserve
the relation "these two shapes interlock": the identity and the tab↔blank swap.
Both commute with complementation; the other four do not. The automorphism group
of the matching relation therefore has order two.

These observations are made precise and proved in `Catalog/Novelty/JigsawGridTopology.lean`.
