# Computational evidence: relation matrix-product factorizations

The formal target is the structural criterion saying that a zero-one matrix product is
a target adjacency matrix exactly when target pairs have one intermediate witness and
non-target pairs have none.

## Small cases

For the cycle `C₅`, label vertices modulo 5 and let `R(x,y)` mean that `y-x = ±1`.
Each ordered pair of distinct vertices has exactly one two-step decomposition in which
both steps are cycle edges: adjacent pairs use the route going the long way by two signed
steps, while distance-two pairs use their common neighbor. Hence the adjacency matrix
satisfies `A_R² = J - I`. Its valency check is `2·2 = 5-1`.

For cycles `Cₙ`, the same product has diagonal entry 2 at every vertex, so `A_R²` itself
cannot be loopless. The `C₅` phenomenon concerns the relevant factor relations as framed
by the unique-witness criterion, and demonstrates why witness multiplicity is decisive.

## Counterexample hunt / boundary checks

* Empty factor: if either relation has no outgoing edges, the product is zero; the
  criterion predicts no witnesses everywhere.
* Complete directed loopless relation on 3 vertices: a diagonal pair has two two-step
  witnesses, so its square is not zero-one. This is correctly rejected.
* A permutation relation has exactly one outgoing edge. Multiplying by it merely relabels
  columns, and every resulting entry remains zero-one; this is the valency-one (trivial)
  family highlighted in Hamming-scheme classifications.

## Sequence/OEIS

No new integer sequence is needed: the numerical consequence is the elementary divisor
constraint `r*s = |V|-1` in the universal-complement case, rather than a sequence claim.
Accordingly no OEIS search was relevant.

## Table

| vertices | factor valencies `(r,s)` allowed by `r*s=n-1` |
|---:|:---|
| 3 | `(1,2)`, `(2,1)` |
| 4 | `(1,3)`, `(3,1)` |
| 5 | `(1,4)`, `(2,2)`, `(4,1)` |
| 6 | `(1,5)`, `(5,1)` |
| 7 | `(1,6)`, `(2,3)`, `(3,2)`, `(6,1)` |

These calculations are motivation only; the Lean development proves the criterion and
valency restrictions uniformly for every finite vertex type.
