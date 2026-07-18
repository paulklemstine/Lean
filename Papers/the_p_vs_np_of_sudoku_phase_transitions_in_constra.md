# Computational Evidence

## Small cases

The critical numerical claim was tested first at the level of ensemble definitions rather than solver timing. For block sizes `n = 2, 3, 4`, restricting any completed grid to any chosen clue set preserves that completed grid as a witness. Consequently, in the deletion-from-solution ensemble, the satisfiability probabilities are exactly:

| Block size | Grid size | Number of retained clues | Satisfiability probability |
|---:|---:|---:|---:|
| 2 | 4×4 | 0 through 16 | 1 |
| 3 | 9×9 | 0 through 81 | 1 |
| 4 | 16×16 | 0 through 256 | 1 |

This directly contradicts an ensemble-independent drop in solvability at densities `3/4`, `8/9`, or `15/16`. The conclusion is not a sampling artifact: it follows for every subset of every valid completion.

## Sequence search

The natural structural counts in the construction are the grid side lengths `n²` and cell counts `n⁴`, giving `1, 4, 9, 16, …` and `1, 16, 81, 256, …`. No OEIS identification is needed for the argument; these are the square and fourth-power sequences arising directly from the definition of generalized Sudoku.

## Counterexample hunt

The universal-density formulation was challenged by varying the clue-generation law while holding clue count fixed. The deletion-from-solution law is a countermodel: every generated instance is solvable at every clue count. Therefore density alone cannot determine an existence threshold. Independently sampled clue values may behave differently, but that is a distinct ensemble and requires separate analysis.

## Relevant table

| Proposed density | Proposed interpretation | Structural countermodel |
|---:|---|---|
| `(n²-1)/n²` | universal solvability threshold | retain exactly that fraction of any valid completion |
| any density in `[0,1]` | density determines solvability | restrictions of a completion remain solvable |
| high density | instances become trivially unsatisfiable | a fully filled valid grid is solvable |

The formal development additionally establishes an explicit completion for every positive block size, so the countermodel is nonempty throughout the generalized family.
