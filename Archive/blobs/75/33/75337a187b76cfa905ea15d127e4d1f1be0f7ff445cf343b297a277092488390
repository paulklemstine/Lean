# Summary of changes for run 0cfeb96e-f72a-4d04-ade5-4e4191e98709
Created `Catalog/Algebra/MarkovBases/TwoWay.lean`, a self-contained Lean 4 file (module `Algebra.MarkovBases.TwoWay`) formalizing the basic 2×2 move on integer-valued two-way contingency tables. It compiles cleanly with `lake env lean` (no errors, no warnings, no `sorry`).

Contents:
- Core definitions: `Table m n := Matrix (Fin m) (Fin n) ℤ`, `rowSum`, `colSum`, `totalSum`, and `sameMargins`.
- `basicMove i i' j j'`: defined by an ordered `ite` entrywise formula giving `-1` at `(i,j)` and `(i',j')`, `+1` at `(i,j')` and `(i',j)`, and `0` elsewhere — definitionally total for all `m n`.
- Additivity lemmas: `rowSum_add`, `colSum_add`, `totalSum_add`.
- Pointwise evaluation lemmas at the four distinguished coordinates: `basicMove_apply_same_left_same_left`, `basicMove_apply_same_left_same_right`, `basicMove_apply_same_right_same_left`, `basicMove_apply_same_right_same_right`, plus off-coordinate vanishing lemmas (`basicMove_apply_off_col`, `basicMove_apply_off_row`, `basicMove_apply_of_ne`) and the cancellation helpers `basicMove_row_pair`, `basicMove_col_pair`.
- Zero-margin results: `rowSum_basicMove` (under `j ≠ j'`), `colSum_basicMove` (under `i ≠ i'`), `totalSum_basicMove` (under `j ≠ j'`).
- Margin-preservation: `basicMove_preserves_rowSum`, `basicMove_preserves_colSum`, and `basicMove_preserves_margins` showing `sameMargins T (T + basicMove i i' j j')` under `i ≠ i'` and `j ≠ j'`.

The sum-vanishing proofs use `Finset.sum_subset` together with `Finset.sum_pair`, splitting on whether the queried row/column equals a distinguished index, so degenerate dimensions `m = 0`/`n = 0` are handled automatically. The file was verified to build via `lake env lean` directly (the package's default build targets have a pre-existing srcDir mismatch unrelated to this file, so the file was compiled directly).