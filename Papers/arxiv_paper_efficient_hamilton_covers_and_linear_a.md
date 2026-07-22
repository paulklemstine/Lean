# Computational Evidence

## Small-case calculations

For degree `d`, the local capacity model uses `m = ⌈d/2⌉ = (d+1)/2` two-incidence layers and records slack `2m-d`.

| `d` | `m` | slack |
|---:|---:|---:|
| 0 | 0 | 0 |
| 1 | 1 | 1 |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 2 | 0 |
| 5 | 3 | 1 |
| 6 | 3 | 0 |
| 7 | 4 | 1 |
| 8 | 4 | 0 |
| 9 | 5 | 1 |
| 10 | 5 | 0 |
| 11 | 6 | 1 |
| 12 | 6 | 0 |
| 13 | 7 | 1 |
| 14 | 7 | 0 |
| 15 | 8 | 1 |
| 16 | 8 | 0 |

The alternating values agree with `d mod 2`. The general identity, not merely these instances, is established by `optimal_capacity_slack_eq_parity` in `Catalog/Computation/EfficientHamiltonCovers.lean`.

## Sequence search

The slack sequence begins `0, 1, 0, 1, 0, 1, ...`; it is simply the parity sequence. No specialized sequence identification is needed for this elementary periodic pattern.

## Counterexample hunt

The potentially problematic boundary cases are degree zero, an empty layer index type, and odd maximum degree. Degree zero has zero required layers and zero slack. If a positive target degree is covered by two-regular layers, the capacity theorem rules out an empty layer family. Odd degree produces exactly one unused incidence slot rather than an equality failure. Thus the small cases reveal no counterexample to the parity law.

The puncturing statement was also checked structurally: an edge outside the image of the chosen transversal cannot equal the erased edge in any layer, so any layer witnessing its original coverage continues to contain it after puncturing.
