Complete a single Lean 4 file formalizing the elementary 2×2 Markov move for two-way contingency tables, with emphasis on finishing all missing declarations and keeping the development minimal, explicit, and robust.

Target file theme:
- Two-way integer tables as `Matrix (Fin m) (Fin n) ℤ`
- Margins: row sums, column sums, total sum
- Basic 2×2 Markov move on distinct rows/columns
- Legal basic step between entrywise nonnegative tables
- Main theorem: legal basic steps preserve margins

Please implement a self-contained development along the following lines.

1. Core definitions
- `abbrev Table (m n : ℕ) := Matrix (Fin m) (Fin n) ℤ`
- `rowSum (T : Table m n) (i : Fin m) : ℤ := ∑ j, T i j`
- `colSum (T : Table m n) (j : Fin n) : ℤ := ∑ i, T i j`
- `totalSum (T : Table m n) : ℤ := ∑ i, ∑ j, T i j`
- `sameMargins (T T' : Table m n) : Prop := (∀ i, rowSum T i = rowSum T' i) ∧ (∀ j, colSum T j = colSum T' j)`
- `Nonneg (T : Table m n) : Prop := ∀ i j, 0 ≤ T i j`

2. Basic move
Define
- `basicMove (i i' : Fin m) (j j' : Fin n) : Table m n`
so that it is `-1` at `(i,j)` and `(i',j')`, `+1` at `(i,j')` and `(i',j)`, and `0` elsewhere.
Use an explicit `if ... then ... else if ...` definition that is easy to simplify by cases. The theorem statements should assume `hii' : i ≠ i'` and `hjj' : j ≠ j'` when needed.

3. Additivity lemmas
Fully prove:
- `rowSum_add : rowSum (T + U) i = rowSum T i + rowSum U i`
- `colSum_add : colSum (T + U) j = colSum T j + colSum U j`
- `totalSum_add : totalSum (T + U) = totalSum T + totalSum U`
These should be straightforward finite-sum lemmas using `simp [rowSum, colSum, totalSum]` and standard sum distributivity.

4. Zero-margin lemmas for the basic move
Prove complete checked statements such as:
- `rowSum_basicMove : rowSum (basicMove i i' j j') r = 0` for every row `r`, assuming `i ≠ i'` and `j ≠ j'`
- `colSum_basicMove : colSum (basicMove i i' j j') c = 0` for every column `c`, assuming `i ≠ i'` and `j ≠ j'`
- `basicMove_totalSum_zero : totalSum (basicMove i i' j j') = 0`
Recommended proof strategy: split on whether `r = i`, `r = i'`, or neither, and similarly for columns; then use `Finset.sum_eq_single` or direct `simp` after case splits on index equalities. Keep the proofs elementary and explicit rather than abstract.

5. Margin preservation under addition of a basic move
Prove:
- `basicMove_preserves_margins : sameMargins T (T + basicMove i i' j j')`
using the additivity lemmas plus the zero-margin lemmas.
Also prove preservation of total sum if convenient:
- `totalSum (T + basicMove i i' j j') = totalSum T`

6. Legal basic steps
Define a legal basic step as a proposition or structure, whichever is simpler, expressing that:
- both source and target tables are entrywise nonnegative, and
- the target equals `T + basicMove i i' j j'`
For example a proposition
- `legalBasicStep T T' i i' j j' : Prop := Nonneg T ∧ Nonneg T' ∧ T' = T + basicMove i i' j j'`
Then prove:
- `legalBasicStep_preserves_margins : legalBasicStep T T' i i' j j' -> sameMargins T T'`

7. Scope control
Important: do not expand into connectivity of fibers, generation of the full Markov basis, transportation polytopes, or species/tropical material. The task is only the finite algebraic soundness of one basic move and the legality wrapper.

8. Style requirements
- No `sorry`, no placeholders, no unfinished theorem bodies.
- Prefer explicit theorem statements with all hypotheses visible.
- Keep imports minimal if possible, but `import Mathlib` is acceptable if that is fastest and most stable.
- Use names close to the ones already sketched: `rowSum_add`, `colSum_add`, `totalSum_add`, `rowSum_basicMove`, `colSum_basicMove`, `basicMove_preserves_margins`, `basicMove_totalSum_zero`, `legalBasicStep`, `legalBasicStep_preserves_margins`.
- If the originally attempted theorem statements are too awkward to prove directly, slightly refactor the statements while preserving the same mathematical content and pipeline.

Deliverable:
A single complete Lean file that compiles and contains the full margin-preservation pipeline for 2×2 basic moves on two-way contingency tables.