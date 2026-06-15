Formalize a single coherent Lean 4 file in `Catalog/Algebra/MarkovBases/TwoWay.lean` about the algebraic soundness of the basic `2 × 2` Markov-basis move for two-way contingency tables. Do not include any tropical, valuation, polynomial, or species material in this file.

Work with `Table (m n) := Matrix (Fin m) (Fin n) ℤ`. Define:
- `rowSum (T : Table m n) (i : Fin m) : ℤ := ∑ j, T i j`
- `colSum (T : Table m n) (j : Fin n) : ℤ := ∑ i, T i j`
- `totalSum (T : Table m n) : ℤ := ∑ i, ∑ j, T i j`
- `sameMargins (T T' : Table m n) : Prop := (∀ i, rowSum T i = rowSum T' i) ∧ (∀ j, colSum T j = colSum T' j)`

Then define the basic move for distinct rows `i ≠ i'` and distinct columns `j ≠ j'` as the matrix with entries
`(+1)` at `(i, j')` and `(i', j)`,
`(-1)` at `(i, j)` and `(i', j')`,
and `0` elsewhere.
A direct `if`-based definition is fine. Prefer a definition that makes pointwise evaluation reducible by `by_cases` on index equalities.

Prove, in this order, the following lemmas with complete proofs and no `sorry`:
1. `rowSum_add`: `rowSum (T + U) i = rowSum T i + rowSum U i`
2. `colSum_add`: `colSum (T + U) j = colSum T j + colSum U j`
3. `totalSum_add`: `totalSum (T + U) = totalSum T + totalSum U`
4. `rowSum_basicMove`: every row sum of the basic move is `0`
5. `colSum_basicMove`: every column sum of the basic move is `0`
6. `basicMove_preserves_margins`: `sameMargins T (T + basicMove ...)`
7. `basicMove_totalSum_zero`: `totalSum (basicMove ...) = 0`

After that, define a predicate or structure for a legal basic step between nonnegative tables. Keep this lightweight: for example, `legalBasicStep T T'` can mean there exist distinct `i i' j j'` such that `T' = T + basicMove i i' j j'` and both tables are entrywise nonnegative. Then prove:
8. `legalBasicStep_preserves_margins`

Important constraints:
- The file must compile cleanly.
- Remove all malformed/truncated declarations and theorem-name placeholders.
- Keep the scope narrow and self-contained.
- Use finite-sum lemmas from `BigOperators`; do not introduce unnecessary abstraction.
- If a proof of row/column sums of the basic move is easier by splitting on whether the queried row/column matches one of the moved indices, do that.
- If needed, add helper lemmas for the sum of a matrix supported on two columns or two rows, but keep them local and purposeful.

The final file should read like a polished mini-library entry: concise documentation header, precise definitions, complete proofs, and no unrelated material.