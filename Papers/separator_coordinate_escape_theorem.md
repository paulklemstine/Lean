# Computational Evidence — Separator-Coordinate Escape

## Reduction used for all searches
For snakes `p` (length `L`) and `q` (length `K`), the vertices `(p i, q j, t)` with
`t ∈ Q_c` induce in `Q_{m+n+c}` exactly the graph `P_{L+1} □ P_{K+1} □ Q_c`: the Hamming distance
splits as `d(p i,p i') + d(q j,q j') + d(t,t')`, and for a snake `d(p i,p i')` is `0`, `1`, `≥ 2`
exactly when `|i-i'|` is `0`, `1`, `≥ 2`. (This is the Lean lemma `SnakeEscape.lift_gridSnake`.)
So the searches below compute the maximum number of vertices of an induced path in the grid
`a × b × 2^c` with `a = L+1`, `b = K+1`.

## Exhaustive search (DFS over induced paths, symmetry-reduced start vertex, all runs completed)

Maximum number of vertices of an induced path:

| grid `a × b` | cells `ab` | `c = 0` | `c = 1` |
|---|---|---|---|
| 2×2 | 4 | 3 | 5 |
| 2×3 | 6 | 5 | 8 |
| 2×4 | 8 | 6 | 10 |
| 2×5 | 10 | 8 | 13 |
| 3×3 | 9 | 7 | 11 |
| 3×4 | 12 | 9 | 14 |
| 3×5 | 15 | 11 | 18 |
| 3×6 | 18 | – | 22 |
| 3×8 | 24 | – | 28 |
| 4×4 | 16 | 11 | 19 |
| 4×5 | 20 | 14 | 24 |
| 4×6 | 24 | – | 28 |
| 5×5 (`L=K=4`) | 25 | **17** | **30** |
| 2×8 | 16 | – | 20 |

Observations:
* `c = 0`: the plain product stays well below `ab` (17/25 at `L=K=4`, ratio ≈ 0.68).
* `c = 1`: in every tested case the maximum is **above** `ab` (it is about `ab + 4` once `b` is
  moderately large). So one separator coordinate already recovers the full main term in all
  small cases.
* `c = 2`: the general construction proved in Lean gives `(L+1)(K+1) + K` vertices,
  i.e. 29 at `L=K=4`.

These table entries come from a scratch search script and are **not** formally verified, with
two exceptions: the 30-vertex path for `5×5, c = 1` is checked in Lean (`gridSnake55`, by
`decide`) and lifted to every pair of length-4 snakes (`one_coordinate_escape_4_4`), and the
29-vertex `c = 2` path is an instance of the general theorem `separator_escape`.

## Per-cell separator patterns (`b(i,j)`)
The search over all `2^25` per-cell patterns at `L=K=4` is unnecessary: the Lean theorem
`cell_separator_no_gain` shows that if the separator bits depend only on the cell `(i,j)`,
they are constant along any snake. So every per-cell pattern gives at most the `c = 0`
maximum, 17 vertices at `L=K=4`. The escape needs some cells to be visited **twice**, with
different separator values. The 30-vertex `c=1` witness visits 5 cells twice and leaves none
empty.

## The `c = 1`, `5×5` witness (column, row, bit)
```
(0,0,0)(0,0,1)(1,0,1)(1,1,1)(1,1,0)(2,1,0)(2,0,0)(3,0,0)(4,0,0)(4,0,1)
(4,1,1)(3,1,1)(3,2,1)(3,2,0)(4,2,0)(4,3,0)(4,3,1)(4,4,1)(3,4,1)(3,4,0)
(2,4,0)(2,3,0)(2,3,1)(1,3,1)(1,4,1)(0,4,1)(0,4,0)(0,3,0)(0,2,0)(0,2,1)
```

## Independent check of the `c = 2` construction
For the snake `000,100,110,111,011` in `Q_3` taken twice, an `#eval` checked all
`29·28/2` pairs of the 29-vertex escape sequence in `Q_8` and returned `true`.

## OEIS
The snake-in-the-box maxima (A099155: 1, 2, 4, 7, 13, 26, 50, 98 for edges in `Q_d`) are the
relevant reference sequence. The `c = 1` grid maxima above (5, 8, 10, 13, …) were not looked up.
