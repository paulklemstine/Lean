# Summary of changes for run 27f9e5f1-7778-4f60-a908-775f39257954
Built `Catalog/Algebra/MarkovBases/TwoWay.lean`, a clean, standalone, sorry-free Lean 4 formalization of the two-way contingency-table Markov basis theorem (Diaconis–Sturmfels Fundamental Theorem of Markov Bases) for the **general `m × n` case**.

What it contains and proves:

Definitions
- `Table m n := Fin m → Fin n → ℤ`, `rowSum`, `colSum`, `SameMargins`, `Nonneg`.
- `basicMove i i' j j'` — the standard `+1,+1,-1,-1` `2×2` swap (`e_{i,j'}+e_{i',j}-e_{i,j}-e_{i',j'}`).
- `Step u v` — an oriented admissible step: `v = u + basicMove i i' j j'` with `i ≠ i'`, `j ≠ j'`, and the two subtraction sites already `≥ 1` in `u` (so nonnegativity is preserved).
- `tdist u v := ∑ i, ∑ j, |u i j - v i j|` (the ℓ¹ distance), with helper `tdist_eq_prod`.

Algebraic lemmas (fully proved)
- `basicMove_preserves_rowSums`, `basicMove_preserves_colSums`, `basicMove_preserves_margins`, `Step.preserve_margins` (plus `Step.preserve_nonneg`).

Core extraction and reduction
- `sign_rectangle` — the precise sign-rectangle pigeonhole: for distinct equal-margin tables it extracts `(i,i',j,j')` with `i≠i'`, `j≠j'` and the sign pattern `v i j < u i j`, `u i j' < v i j'`, `v i' j' < u i' j'` (so the two decremented cells are `≥ 1` in `u`, giving admissibility).
- `tdist_decrease` — the sign-aligned move strictly drops the ℓ¹ distance.
- `exists_reducing_step` — from any nonnegative `u ≠ v` in a fiber, a single admissible `Step` that stays nonnegative, keeps the margins, and strictly decreases `tdist`.

Main theorem
- `twoWay_fiber_connected` — any two nonnegative tables with equal row and column margins are joined by a walk of admissible basic moves (`Relation.ReflTransGen Step`), proved by strong induction on `(tdist u v).natAbs`.

The full general `m × n` statement is proved; no `2 ≤ m`/`2 ≤ n` hypotheses are needed because distinctness of the extracted rows/columns is forced by their opposite sign patterns. The file uses only `import Mathlib`, has a module docstring, no leftover/unrelated declarations, and no `sorry`/`axiom`/`@[implemented_by]`. It compiles with no warnings, and `twoWay_fiber_connected` depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.