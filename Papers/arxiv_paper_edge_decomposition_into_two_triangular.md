# Computational evidence: decomposing graphs into two triangular forests

A *triangular forest* is a graph all of whose 2-connected blocks are single edges or triangles;
equivalently (the definition used in the Lean development) a graph in which **every cycle has
length 3**.

All numbers below come from exhaustive brute-force enumeration in Python (scratch scripts, not
machine-checked).  They are exploratory evidence only; the statements that are actually
*verified* are the Lean theorems in `Catalog/Logic/TriangularForest/`, and each is flagged as
such below.

## 1. Maximum size of a triangular forest on `n` vertices

For every subset of the edges of `Kₙ`, test whether the resulting graph has a cycle of length
`≥ 4`; take the largest edge count with no such cycle.

| `n` | max #edges of a triangular forest | `⌊3(n-1)/2⌋` |
|-----|-----------------------------------|--------------|
| 1   | 0                                 | 0            |
| 2   | 1                                 | 1            |
| 3   | 3                                 | 3            |
| 4   | 4                                 | 4            |
| 5   | 6                                 | 6            |
| 6   | 7                                 | 7            |
| 7   | 9                                 | 9            |

The two columns agree throughout the computed range.  This is exactly the shape of the bound
proved in Lean: `TriangularForest.two_mul_card_edgeFinset_le` states `2e ≤ 3(n-1)` for every
finite triangular forest (**verified**), and `TriangularForest.triangle_tight` exhibits equality
for `n = 3` (**verified**).  The evidence above suggests the bound is attained for *every* `n`
of the right parity pattern (odd `n`: unions of `(n-1)/2` triangles glued in a tree; even `n`:
one extra bridge), which is recorded as a conjecture in `FUTURE_DIRECTIONS.md`.

## 2. Decomposing `Kₙ` into two triangular forests

Exhaustive search over all `2^{\binom n 2}` red/blue edge colourings of `Kₙ`, testing both colour
classes:

| `n` | decomposable into two triangular forests? | certificate / obstruction |
|-----|-------------------------------------------|---------------------------|
| 3   | yes                                       | one triangle + empty graph |
| 4   | yes                                       | two paths / triangle + star |
| 5   | yes                                       | `{01,02,04,12,13}` ∪ `{03,14,23,24,34}` (each: a triangle with two pendant edges) |
| 6   | **no**                                    | `15 > 2·7` edges |
| 7   | **no**                                    | `21 > 2·9` edges |

The `n = 5` certificate is formalised and machine-checked as
`TriangularForest.completeGraph_decomposesIntoTwo_five` (**verified**), and the failure for all
`n ≥ 6` is `TriangularForest.completeGraph_not_decomposesIntoTwo_six` (**verified**).  Together
these give the exact threshold `TriangularForest.completeGraph_decomposesIntoTwo_iff_le_five`
(**verified**): `Kₙ` decomposes into two triangular forests iff `n ≤ 5`.

Note how tight the counting obstruction is: for `n = 6` the naive bound `e ≤ 2n-3 = 9` per part
gives `18 ≥ 15` and proves nothing, and even the sharp bound gives `2e ≤ 15` per part — it is
only the integrality step `e ≤ 7` that closes the gap `14 < 15`.  This is why the development
proves the sharp bound `2e ≤ 3(n-1)` rather than the easier degeneracy bound `e ≤ 2n-3`.

## 3. Counterexample hunt for the local structure

Random and exhaustive tests on graphs up to 7 vertices found no triangular forest in which

* some vertex neighbourhood contains a path of length two (i.e. neighbourhoods are matchings), or
* two distinct triangles share an edge, or
* a 4-cycle occurs.

All three are proved in Lean: `TriangularForest.no_four_cycle`,
`TriangularForest.neighborhood_matching`, `TriangularForest.triangle_edge_unique`
(**all verified**).

## 4. Minimum degree

Every triangular forest tested on `≤ 7` vertices has a vertex of degree `≤ 2`, with the bound
attained by unions of triangles.  Verified in Lean as
`TriangularForest.exists_degree_le_two` (2-degeneracy), and strengthened to
`TriangularForest.exists_adj_degree_le_two`: with minimum degree two there is always an *edge*
whose two endpoints both have degree two (a leaf triangle).

## 5. The extremal family (windmills)

For odd `n = 2k+1` the maximisers found by the search in §1 are the *windmills* `Fₖ`: `k`
triangles glued at a common hub.  Their edge counts `3k` (`k = 1,2,3` giving `3, 6, 9`) match the
maxima in the table, and the sequence of maxima `0, 1, 3, 4, 6, 7, 9, …` is `⌊3(n-1)/2⌋`
(OEIS A032766 shifted; the sequence `⌊3m/2⌋`).  The windmill family is now **verified** in Lean:
`TriangularForest.isTriangularForest_fan` (membership, via the hub criterion
`TriangularForest.isTriangularForest_of_unique_far_neighbour`),
`TriangularForest.card_edgeFinset_fan` (`#E(Fₖ) = 3k`) and
`TriangularForest.sparsity_bound_attained` (`2e = 3(n-1)` for every odd `n`).  A machine
evaluation of the decision procedure gives `#E(F₃) = 9`, matching the table.

## 6. Triangular thickness of `Kₙ`

Counting alone gives `n ≤ 3k` for a cover of `Kₙ` by `k` triangular forests
(`TriangularForest.triangularThickness_lower_bound_sharp`, **verified**), i.e.
`k ≥ ⌈n/3⌉`, improving the earlier `n - 1 ≤ 4k`.  A randomised greedy search (unverified Python)
found explicit covers matching `⌈n/3⌉` for

| `n`  | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|------|---|---|---|---|---|---|---|----|----|
| cover found with `k` = | 1 | 2 | 2 | 3 | 3 | 3 | 3 | 4 | 4 |
| `⌈n/3⌉` | 1 | 2 | 2 | 2 | 3 | 3 | 3 | 4 | 4 |

so the counting bound is attained for every computed `n` **except `n = 6`**, where
`⌈6/3⌉ = 2` but `K₆` provably does not decompose into two triangular forests
(`TriangularForest.completeGraph_not_decomposesIntoTwo_six`, **verified**) — an integrality
obstruction beyond edge counting.  This exceptional behaviour is the content of Conjecture C2 in
`FUTURE_DIRECTIONS.md`.  (Only the lower bound `n ≤ 3k` and the `n = 6` obstruction are
machine-checked; the covers above are exploratory.)
