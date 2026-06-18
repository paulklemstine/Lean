Create a single self-contained Lean 4 file formalizing the basic algebra of the `2 × 2` move for two-way contingency tables, with complete proofs and no unrelated material.

Target file: `Catalog/Algebra/MarkovBases/TwoWay.lean`

Scope:
- Work only with integer-valued tables `Matrix (Fin m) (Fin n) ℤ`.
- Define:
  - `Table (m n : ℕ) := Matrix (Fin m) (Fin n) ℤ`
  - `rowSum`, `colSum`, `totalSum`
  - `sameMargins`
  - the basic move `basicMove (i i' : Fin m) (j j' : Fin n) : Table m n`
    representing `e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}`.
- Use hypotheses `hii' : i ≠ i'` and `hjj' : j ≠ j'` exactly where needed.

Main theorems to prove completely:
1. `rowSum_basicMove`:
   for every row `r`, `rowSum (basicMove i i' j j') r = 0` under `i ≠ i'` and `j ≠ j'`.
2. `colSum_basicMove`:
   for every column `c`, `colSum (basicMove i i' j j') c = 0` under the same hypotheses.
3. `totalSum_basicMove_zero`:
   `totalSum (basicMove i i' j j') = 0`.
4. `basicMove_preserves_rowSum` and `basicMove_preserves_colSum`:
   adding the basic move to any table preserves each row sum and column sum.
5. `basicMove_preserves_margins`:
   `sameMargins T (T + basicMove i i' j j')`.

Recommended proof strategy:
- Keep the implementation elementary and explicit.
- Define `basicMove` entrywise using `if` expressions on index equalities.
- Prove helper lemmas for entries of `basicMove` when the row/column matches one of the four affected positions.
- For row and column sums, split into cases on whether the row equals `i`, `i'`, or neither, and similarly for columns. Use `Finset.sum_ite`, `by_cases`, and simplification lemmas.
- If a direct proof of `totalSum_basicMove_zero` is awkward, derive it from zero row sums or zero column sums.
- Prefer robustness and clarity over abstraction.

Important constraints:
- The file must compile on its own with standard Mathlib imports.
- No `sorry`, no placeholders, no truncated declarations.
- Do not include claims about Markov bases generating fibers, connectivity, toric ideals, or random walks.
- Do not mix in unrelated catalog topics.

Optional only if easy and fully provable:
- Define `legalBasicStep` for a table and move that preserves entrywise nonnegativity after addition, and prove that any legal basic step preserves margins. Skip this if it risks incompleteness.

Deliverable:
- A polished, minimal theorem file with complete proofs suitable as a foundation for later work on Markov bases.