# Summary of changes for run 79363282-6189-49b2-9ded-bd1d61f2ff83
Created `Catalog/Algebra/MarkovBases/TwoWay.lean`, a self-contained mini-library on the algebraic soundness of the basic 2×2 Markov-basis move for two-way contingency tables.

Contents:
- A documentation header and the requested definitions: `Table m n := Matrix (Fin m) (Fin n) ℤ`, `rowSum`, `colSum`, `totalSum`, `sameMargins`, and the `if`-based `basicMove i i' j j'` (placing +1 at (i,j') and (i',j), −1 at (i,j) and (i',j'), 0 elsewhere).
- A small local helper `two_support` for summing a function supported on two distinct indices, used to evaluate the row/column sums of a move.
- Complete proofs (no `sorry`) of all eight requested results, in order: `rowSum_add`, `colSum_add`, `totalSum_add`, `rowSum_basicMove`, `colSum_basicMove`, `basicMove_preserves_margins`, `basicMove_totalSum_zero`, plus the `legalBasicStep` predicate (distinct i≠i', j≠j', the move equation, and entrywise nonnegativity of both tables) and `legalBasicStep_preserves_margins`.

The row/column-sum proofs split on whether the queried row/column matches a moved index, as suggested. The file contains no tropical, valuation, polynomial, or species material and no malformed/placeholder declarations.

Verification: the file compiles cleanly with `lake env lean` (no errors or warnings); a search confirms no `sorry`/`admit`; and `#print axioms` on the key theorems shows they rely only on `propext`, `Classical.choice`, and `Quot.sound`.