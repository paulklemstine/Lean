# Computational Evidence: Finite Pruning Bounds

## Small-case calculations

For the serial update that removes the least candidate, starting from `{0,1,2,3}` gives:

| Round | Candidate set |
|---:|:---|
| 0 | `{0,1,2,3}` |
| 1 | `{1,2,3}` |
| 2 | `{2,3}` |
| 3 | `{3}` |
| 4 | `∅` |
| 5 | `∅` |

Thus all four rounds permitted by the initial cardinality can be changing rounds, and the next round is fixed. This witnesses sharpness of the general bound.

## Sequence search

The candidate-set cardinalities are `4, 3, 2, 1, 0, 0, ...`. This finite countdown is elementary and was not treated as requiring an OEIS identification; no external sequence claim is used.

## Counterexample hunt

Dropping contraction permits oscillation on only two states. The update sending `{0}` to `{1}` and every other input to `{0}` yields

`{0}, {1}, {0}, {1}, ...`.

Hence finite state alone does not imply convergence. The subset condition is a genuine boundary of the stabilization theorem.

Dropping monotonicity does not invalidate termination for contracting updates, but it can invalidate the interpretation of the result as the greatest fixed set below the input. This distinguishes the termination hypothesis from the semantic maximality hypothesis.

## Evidence status

The two concrete calculations above are represented as examples in `KCopwinTermination.lean`; the sharp countdown is evaluated directly, while the oscillation is proved for every natural-numbered round.
