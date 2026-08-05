# Computational evidence — Gilbert's disc model conditioned on the square lattice

Model: one point per cell of the grid `ℤ²`, the point of cell `(i,j)` lying in the
closed square `[i,i+1] × [j,j+1]`; two points are joined when their Euclidean distance
is `< R`.  Three critical radii are of interest:

| radius | definition |
|---|---|
| `Rmin`  | infimum of the `R` for which **some** placement has an infinite component |
| `Rconn` | infimum of the `R` for which **some** placement connects all points |
| `Rfull` | infimum of the `R` for which **every** placement connects all points |

All computations below are exploratory (floating point); they are **not** verified
proofs.  The verified statements are the Lean theorems in `Catalog/Shared/`.

## 1. `Rmin`: search over periodic drifting paths

A placement percolates iff there is an infinite path of cells `c_0, c_1, …` (all
distinct) whose points are at consecutive distance `< R`.  The natural finite search
space is that of *periodic* paths: a cyclic sequence of cell steps
`(m_k,n_k) ∈ {-1,0,1}² \ {(0,0)}`, `k = 0,…,T-1`, with nonzero total drift `D`, whose
cells are pairwise distinct modulo the lattice `ℤD` (so that each cell carries a single
point).  For each such step sequence one minimises the longest edge

`L = max_k |(m_k + a_{k+1} - a_k , n_k + b_{k+1} - b_k)|`

over the offsets `(a_k,b_k) ∈ [0,1]²`.  This is a convex program, solved here by
projected subgradient descent with random restarts (`scripts/search_periodic.py`,
`scripts/search_periodic5.py`).

| period `T` | search | best longest edge `L` |
|---|---|---|
| 2 | exhaustive (64 sequences) | **0.500000** |
| 3 | exhaustive (512) | 0.500000 |
| 4 | exhaustive (4096) | 0.500000 |
| 5 | 1500 random sequences | 0.500006 |
| 6 | 1500 random sequences | 0.500006 |
| 7 | 1500 random sequences | ≥ 0.5 |
| 8 | 1500 random sequences | ≥ 0.5 |

Nothing below `1/2` was found.  The optimum `L = 1/2` is attained e.g. by the period-2
sequence of steps `(-1,0), (1,-1)` with offsets `(0, 0.8484)`, `(1, 0.3484)`, i.e. by the
**line configuration**: the points of the rows `j = 0` and `j = 1` are put on the line
`y = 1`, at abscissae `i + 3/4` (row `0`) and `i + 1/4` (row `1`), so that consecutive
points are at distance exactly `1/2`.  This is the configuration formalised as
`GilbertLattice.lineConfig`, and it proves `Rmin ≤ 1/2`.

Heuristic reason why `1/2` should be optimal: a chain of points can be squeezed onto a
straight line only by using the two rows adjacent to that line, which puts exactly two
points per unit of length; the mean spacing along the chain is then `1/2`.

## 2. A relaxation that is *not* valid

`scripts/search_rmin.py` discretises the offsets and looks for a cycle with nonzero
drift in the "offset transition graph" (state = offset of the current point, edge =
cell step).  It reports drifting cycles for every `R ≥ 0.3`.  This is **not** evidence
of percolation: the relaxation forgets that a cell visited twice must carry the *same*
point, and the reported cycles do revisit cells with different offsets.  The script is
kept as a record of the failed approach and of why the "one point per cell" constraint
is the entire difficulty of the model.

## 3. `Rfull`: cuts of the plane

To disconnect the graph one has to place the points so that some cut of the plane is
crossed by no edge.  For a horizontal cut, the best choice pushes the points of the rows
`j ≥ 1` to the top of their cells and the points of the rows `j ≤ 0` to the bottom,
staggering the two halves horizontally by `1/2`.  Nearest opposite points are then at
distance

`√(2² + (1/2)²) = √17 / 2 ≈ 2.06155`,

which gives `Rfull ≥ √17/2` (`GilbertLattice.cutConfig_not_connected`).  Diagonal
staircase cuts were checked by hand and are worse (they contain edge-adjacent cells at
distance `≈ 1`).  On the other side, two points in edge-adjacent cells are always at
distance `≤ √(2² + 1²) = √5 ≈ 2.23607`, whence `Rfull ≤ √5`.

## 4. `Rconn`

The centred configuration (every point at the centre of its cell) has all
edge-adjacent points at distance exactly `1`, so `Rconn ≤ 1`; and `Rconn ≥ Rmin`.
Numerically, no placement was found which connects *all* the points with a longest
nearest-neighbour link below `1`: compressing points onto a line (as for `Rmin`) leaves
the parallel lines two units apart, which is worse.

## 5. Summary of the verified bounds

| quantity | verified lower bound | verified upper bound | conjectured value |
|---|---|---|---|
| `Rmin`  | `1/3` | `1/2` | `1/2` |
| `Rconn` | `1/3` | `1` | `1` |
| `Rfull` | `√17/2 ≈ 2.0616` | `√5 ≈ 2.2361` | `√5` (?) |

No OEIS sequence is relevant here: the objects are real critical radii, not integer
sequences.
