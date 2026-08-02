# Computational evidence: Euler-brick near-misses

The formal development centers on the classical Euler brick `(44,117,240)`.
Direct arithmetic gives:

| edges | face diagonals | squared space diagonal | neighboring squares |
|---|---:|---:|---:|
| `(44,117,240)` | `(125,244,267)` | `73225` | `270²=72900 < 73225 < 73441=271²` |
| `(240,252,275)` | `(348,365,373)` | `196729` | `443²=196249 < 196729 < 197136=444²` |
| `(85,132,720)` | `(157,725,732)` | `543049` | `736²=541696 < 543049 < 543169=737²` |

Thus all three familiar examples pass the three face-square tests and fail the
space-square test.  The first row, including its failure, is proved in Lean in
`Catalog/Geometry/PerfectCuboid/AlgebraicSurface.lean`.

## Counterexample hunt

No perfect cuboid was found among these representative classical small Euler
bricks.  This is evidence only, not a bounded exhaustive-search theorem and not
a claim that the open perfect-cuboid problem has been resolved.

## Sequence search

No new integer sequence is asserted here, so an OEIS identification would not
add evidence for the theorem selected for formalization.  The numerical stage
is instead used to select and check the explicit near-miss proved in Lean.
