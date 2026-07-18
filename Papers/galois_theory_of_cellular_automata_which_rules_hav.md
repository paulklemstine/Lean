# Computational Evidence: Elementary Cellular Automata

## Small-case calculations

All 256 elementary binary rules were evaluated on periodic rings. A rule was counted as reversible when its global map on all `2^n` configurations was injective (and hence bijective).

| Ring size `n` | Rules reversible on that ring | Rules surviving every test through `n` |
|---:|---:|---:|
| 1 | 128 | 128 |
| 2 | 64 | 64 |
| 3 | 36 | 20 |
| 4 | 8 | 6 |
| 5 | 16 | 6 |
| 6 | 6 | 6 |
| 7 | 16 | 6 |
| 8 | 8 | 6 |
| 9 | 14 | 6 |
| 10 | 8 | 6 |
| 11 | 16 | 6 |
| 12 | 6 | 6 |

The intersection from sizes 1 through 12 is exactly
`{15, 51, 85, 170, 204, 240}`. These are complementation of the right coordinate, complementation of the center, complementation of the left coordinate, and the corresponding three projections.

## Counterexample hunt

The proposed finite neighbourhood-permutation group fails before enumeration: an elementary local rule has type `Bool^3 → Bool`, not `Bool^3 → Bool^3`, so it cannot be a permutation of eight neighbourhoods. The finite-group claim for global dynamics also fails on the bi-infinite lattice. Integral shifts are distinct reversible global maps, yielding infinitely many reversible dynamics. Both obstructions are established in `Catalog/Computation/CellularAutomata/ReversibleDynamics.lean`.

Individual periodic sizes are not reliable classifiers. For example, 36 rules are reversible at size 3, but only 8 at size 4; sizes 5, 7, 9, and 11 again admit accidental extra rules. This supports testing intersections across several circumferences rather than extrapolating from one finite ring.

## Sequence-database search

No OEIS identification is asserted. The sequence `128, 64, 36, 8, 16, 6, 16, 8, 14, 8, 16, 6` depends on the precise convention of periodic-ring reversibility and was used only as finite experimental evidence, not as a theorem.
