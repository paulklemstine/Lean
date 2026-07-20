# Computational Evidence

## Small-case calculations

For the standard square cellulation of a torus with linear size `n`, the edge count is
`2n²` and the shortest essential cycle has length `n`. The resulting parameters are:

| `n` | edges | shortest essential cycle | squared distance |
|---:|---:|---:|---:|
| 1 | 2 | 1 | 1 |
| 2 | 8 | 2 | 4 |
| 3 | 18 | 3 | 9 |
| 4 | 32 | 4 | 16 |
| 5 | 50 | 5 | 25 |
| 6 | 72 | 6 | 36 |
| 8 | 128 | 8 | 64 |
| 10 | 200 | 10 | 100 |

In every case, `2 · distance² = edges`. The identity is established for arbitrary
natural `n` by `square_torus_distance_area`.

## Sequence search

The edge counts `2, 8, 18, 32, 50, 72, 98, 128, …` are twice the positive squares.
No external sequence identifier is needed for the argument: the closed form `2n²` is
the complete description used by the proof.

## Counterexample hunt

The unqualified prediction that distance is bounded solely by genus fails already at
genus one. Refining the square torus cellulation leaves genus fixed while the shortest
essential edge cycle has length `n`, which is unbounded. The theorem
`no_genus_only_distance_bound` records the numerical obstruction for every proposed
bound. This forced the surviving genus statement to include an area normalization and
a systolic inequality.

## Structural conclusion

The computations support square-root growth in the number of edges, not in genus alone.
They therefore distinguish two claims: exact distance–systole equality survives, while
an `O(√g)` assertion requires geometric restrictions that tie area to genus.
