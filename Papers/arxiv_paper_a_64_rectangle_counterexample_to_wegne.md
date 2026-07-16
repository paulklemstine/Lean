# Computational Evidence

## Small cases

For the recurrence `a(0)=4` and `a(r+1)=a(r)^2`, the first four values are:

| `r` | `a(r)` | `4^(2^r)` |
|---:|---:|---:|
| 0 | 4 | 4 |
| 1 | 16 | 16 |
| 2 | 256 | 256 |
| 3 | 65,536 | 65,536 |

The general equality is established in `Catalog/Applications/WegnerRectangles/Core.lean` by `squaring_recurrence_closed_form`.

For 64 members, the triangle-free capacity bound gives `64 ≤ 2|T|`, hence `|T| ≥ 32`. At packing value 16, Wegner's proposed upper bound is `2·16−1=31`, one below this lower bound. These implications are established respectively by `sixtyFour_requires_thirtyTwo` and `wegner_numeric_violation`.

The rational comparison is

`17891/8064 ≈ 2.2186269841 < 2.28125 = 73/32`.

The exact strict inequality is established by `gap_seventyThree_over_thirtyTwo_improves`.

## Counterexample hunt

The universal counting claim was tested against its sharp boundary: a point may cover two members, but three distinct members through one point would violate `PointTriangleFree`. Thus two-member fibers show that the factor two cannot be improved from triangle-freeness alone. No counterexample exists under the stated hypotheses, as proved by `triangleFree_transversal_count`.

The coordinate realization itself was not computationally reconstructed because no coordinate dataset accompanied the mission. Consequently, this evidence does not claim an independent coordinate-level check of all 64 rectangles.

## Sequence search

The sequence `4, 16, 256, 65536, …` is completely described by `a(r)=4^(2^r)`. No OEIS identification is asserted here: the closed form supplies the relevant structural information, and an unverified database match would add no mathematical evidence.
