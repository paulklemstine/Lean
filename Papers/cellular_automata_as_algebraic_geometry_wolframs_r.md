# Computational evidence

## Small cases

Using periodic boundary conditions and Wolfram's standard bit ordering, exhaustive enumeration gave the following fixed-state counts.

| array length `n` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Rule 0 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| Rule 110 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| Rule 204 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 | 4096 |

For Rule 110, the unique fixed configuration in each tested size was the all-zero state. The Lean development proves the corresponding result whenever the right-neighbor map has one forward orbit, which includes the usual periodic cycle.

## OEIS search

The Rule 204 row is the standard powers-of-two sequence, OEIS A000079. The constant-one rows are A000012. These identifications add no evidence beyond the defining formulas.

## Counterexample hunt

The proposed maximality claim for Rule 110 fails immediately: on every nonempty array the all-one state is mapped to all zero locally at each `111` neighborhood and therefore is not fixed. Thus Rule 110 cannot have all `2^n` states as fixed points. In contrast, Rule 204 fixes every state. Both facts are proved for arbitrary boundary maps in `Speculative/CellularAutomataGeometry.lean`.

The stronger periodic-boundary search found only one Rule 110 fixed state through `n = 12`, not a maximal family. No tested case supported the proposed correlation between computational universality and abundance of fixed points.

## Table interpretation

Fixed-point cardinality is not itself Krull dimension. Moreover, the set of `GF(2)`-rational points of polynomial equations does not determine the dimension of the associated scheme without specifying the coordinate ring (including the Boolean equations `x_i^2-x_i`) and base field. The formal results therefore address the precise finite-state fixed-point claim and the degree-three polynomial representation, rather than assigning an undefined geometric dimension.
