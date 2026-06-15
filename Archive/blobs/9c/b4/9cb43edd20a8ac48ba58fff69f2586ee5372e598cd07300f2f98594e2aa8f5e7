Formalize a clean and complete Lean 4 development for the algebraic soundness of the 2×2 basic move on two-way contingency tables, replacing the previous malformed species/EGF bridge attempt.

Target file: `Catalog/Algebra/MarkovBases/TwoWay.lean`

Scope:
Work only with integer-valued `m × n` tables `Matrix (Fin m) (Fin n) ℤ`. Do not include unrelated generating-function or species material. The goal is a self-contained theorem package proving that the basic 2×2 move preserves row and column margins.

Definitions to include:
1. `abbrev Table (m n : ℕ) := Matrix (Fin m) (Fin n) ℤ`
2. `rowSum (T : Table m n) (i : Fin m) : ℤ := ∑ j, T i j`
3. `colSum (T : Table m n) (j : Fin n) : ℤ := ∑ i, T i j`
4. `totalSum (T : Table m n) : ℤ := ∑ i, ∑ j, T i j`
5. `sameMargins (T T' : Table m n) : Prop := (∀ i, rowSum T i = rowSum T' i) ∧ (∀ j, colSum T j = colSum T' j)`
6. A total definition of the basic move
   `basicMove (i i' : Fin m) (j j' : Fin n) : Table m n`
   with entries
   - `-1` at `(i,j)`
   - `+1` at `(i,j')`
   - `+1` at `(i',j)`
   - `-1` at `(i',j')`
   - `0` elsewhere.
   Implement this with nested `if`/`ite` on index equality so it is easy to simplify by cases.

Required theorem package:
A. Basic linearity lemmas
- `rowSum_add : rowSum (T + U) i = rowSum T i + rowSum U i`
- `colSum_add : colSum (T + U) j = colSum T j + colSum U j`
- `totalSum_add : totalSum (T + U) = totalSum T + totalSum U`
- optionally also `rowSum_zero`, `colSum_zero`, `totalSum_zero` if useful.

B. Vanishing margins for the basic move
Assuming `hii' : i ≠ i'` and `hjj' : j ≠ j'`, prove:
- `rowSum_basicMove : rowSum (basicMove i i' j j') r = 0` for every row `r`
- `colSum_basicMove : colSum (basicMove i i' j j') c = 0` for every column `c`
- `totalSum_basicMove : totalSum (basicMove i i' j j') = 0`

C. Margin preservation
- `basicMove_preserves_rowSum : rowSum (T + basicMove i i' j j') r = rowSum T r`
- `basicMove_preserves_colSum : colSum (T + basicMove i i' j j') c = colSum T c`
- `basicMove_preserves_margins : sameMargins T (T + basicMove i i' j j')`
under the distinctness hypotheses.

Suggested proof strategy:
1. First prove the additive lemmas by unfolding definitions and using `Finset.sum_add_distrib` / `ring` / `simp`.
2. For the basic move, avoid overly abstract matrix basis machinery. Instead, use the concrete `if`-based definition and prove the row/column claims by case splitting on whether the summation index equals the special row/column indices.
3. To evaluate finite sums with only one or two nonzero terms, use `Finset.sum_eq_single` or `by_cases h : x = y <;> simp [basicMove, h, hii', hjj']` as appropriate.
4. Keep the development robust for edge cases `m = 0` or `n = 0`; because all indices are `Fin m` / `Fin n`, the statements should remain valid without extra assumptions.
5. Ensure the file is coherent, complete, and contains no `sorry`, placeholders, truncation, or unrelated declarations.

Deliverable standard:
Produce one polished Lean file compiling cleanly with full proofs. The emphasis is correctness and coherence, not breadth. If a convenience lemma is needed for `Matrix`, add it locally in the file rather than importing unrelated material.