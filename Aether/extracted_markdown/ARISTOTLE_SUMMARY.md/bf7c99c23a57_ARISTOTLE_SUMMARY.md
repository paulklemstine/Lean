# Summary of changes for run e08315a2-6f78-408c-b7ac-dfeaba31996f
Built a new, fully self-contained Lean 4 nucleus for the **tropical (min-plus) determinant** and the linear assignment problem, plus a research-direction file.

## Deliverables

**`Catalog/Tropical/TropicalDeterminant.lean`** (11 declarations, no `sorry`, no `native_decide`). It defines the min-plus determinant `tropDet A = minₛ ∑ᵢ A i (σ i)` over `WithTop ℤ` together with `permSum`, the min-plus matrix product `tropMul`, the row-minimum `hadamardBound`, and a local rank-1 predicate `IsTropRankOne` (the `k=1` case of `IsTropFactorization` from `Catalog/Tropical/Basic.lean`). Proven theorems:
- `tropDet_le_permSum` — every assignment upper-bounds `tropDet`.
- `exists_perm_eq_tropDet` — the minimum is attained.
- `tropDet_hadamard` — the tropical Hadamard / row-minimum lower bound.
- `tropDet_transpose` — transpose invariance.
- `tropDet_row_col_perm` — the full `Sₙ × Sₙ` row/column symmetry.
- `tropDet_submul` — submultiplicativity over the min-plus product.
- `tropDet_zero_diag_eq_zero` — nonnegative zero-diagonal matrices have `tropDet = 0`.
- `tropDet_separable` — closed form `tropDet (i,j ↦ uᵢ + vⱼ) = ∑uᵢ + ∑vⱼ`.

All invariances are derived from a single reindexing lemma `tropDet_eq_inf_comp`. Each result carries a `-- !-- ... --!--` proof sketch, and the file opens with a `-- !-- Lab Notebook --!--` block (Hypothesis / Result / Insight / Failure analysis).

**Adversarial finding:** the seed program's Direction 1 conjecture (Hadamard gap `= 0` ⇔ rank-1) is refuted in *both* directions, with formal witnesses `rankOne_gap_can_be_positive` (a rank-1 matrix with gap 10) and `gap_zero_not_rankOne` (the identity-like matrix: gap 0 but not rank-1, reusing the factor-rank-2 fact from `Catalog/Tropical/Basic.lean`).

Verification: every theorem was checked to depend only on the allowed axioms `propext`, `Classical.choice`, `Quot.sound` (no `sorryAx`).

**`Catalog/Tropical/FUTURE_DIRECTIONS.md`** — a narrative with the adversarial refutation plus five falsifiable directions, each with a "The key insight is…" sentence and a "Why now?" justification: (1) the corrected gap criterion via a Hall/SDR matching condition on the argmin graph, (2) strict multiplicativity over a supertropical ghost layer, (3) a tropical Cauchy–Binet for rectangular costs, (4) the tropical Birkhoff set and its permutation-pattern vertices, and (5) the min mean-cycle weight / tropical eigenvalue. Each builds on the proven nucleus and on catalog results in `Catalog/Tropical/Basic.lean`.

Note: the project's `lakefile.toml` library globs target top-level directories that do not exist for the `Catalog/` tree, so `Catalog.*` modules are not lake build targets; the file was verified through the compiler (it elaborates cleanly under `import Mathlib`, matching the catalog's self-contained convention).