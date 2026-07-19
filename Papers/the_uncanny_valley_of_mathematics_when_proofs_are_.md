# Computational Evidence

## Small-case calculations

Rigor levels are indexed by `0,1,2,3,4`. Two hypothetical confidence profiles are

| level | 0 | 1 | 2 | 3 | 4 |
|---:|---:|---:|---:|---:|---:|
| respondent A | 8 | 5 | 1 | 4 | 7 |
| respondent B | 9 | 6 | 2 | 3 | 8 |
| aggregate | 17 | 11 | 3 | 7 | 15 |

Each individual profile strictly decreases to level `2` and strictly increases thereafter. The aggregate has the same shape. Relative to level `2`, the smallest gaps are respectively `3`, `1`, and `4`; the aggregate gap is the sum of the certified individual gaps.

The total variation of the aggregate is

`|11-17| + |3-11| + |7-3| + |15-7| = 6 + 8 + 4 + 8 = 26`.

The descent-and-recovery formula gives the same value:

`(17-3) + (15-3) = 14 + 12 = 26`.

## Counterexample hunt

A common valley location is necessary for unconditional aggregation. The profiles

- `A = (0,2,4)`, with minimum at level `0`, and
- `B = (4,2,0)`, with minimum at level `2`,

have aggregate `(4,4,4)`, which has no unique minimum. Thus averaging arbitrary individual valleys does not preserve a valley.

The strict perturbation threshold is also necessary. For the two-level profile `U = (0,2)`, the minimum margin is `δ = 2`. Perturbations of size `ε = 1 = δ/2` can produce `V = (1,1)`, destroying uniqueness. This motivates the strict hypothesis `2ε < δ`.

## Sequence-database search

No OEIS or LMFDB search is applicable: confidence profiles are survey observables rather than canonical arithmetic sequences.

## Plot-ready table

The first table supplies the points for a discrete line plot. Its aggregate visibly falls from `17` to `3` and recovers to `15`, with the unique minimum at level `2`.
