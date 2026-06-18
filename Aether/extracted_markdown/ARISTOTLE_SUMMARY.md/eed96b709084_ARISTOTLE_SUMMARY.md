# Summary of changes for run 2328c2b8-978a-4cdd-9a5e-5bcd06740262
Built a new, self-contained formalization of the **tropical (min-plus) determinant** in `Catalog/Tropical/TropicalDeterminant.lean`. The catalog's referenced `tropDet`/`permSum` infrastructure did not actually exist in the project (cold start), so I created it from scratch over the min-plus semiring `WithTop ℤ`.

**Theorem declarations (Step 1) — all `proved`, 0 `sorry`, only standard axioms (`propext`, `Classical.choice`, `Quot.sound`):**

1. `tropDet_le_permSum`: the tropical determinant is a lower bound for every assignment cost — proved — infimum-over-permutations is ≤ any term.
2. `tropDet_hadamard`: tropical Hadamard / row-minimum bound `∑ᵢ minⱼ A i j ≤ tropDet A` — proved — term-by-term row minima plus monotonicity of sums.
3. `tropDet_submul`: submultiplicativity `tropDet (A ⊗ B) ≤ tropDet A + tropDet B` (the tropical analogue of `det(AB) = det A · det B` as an inequality) — proved — choose optimal σ, τ, use the composite `σ.trans τ` and reindex by σ.
4. `tropDet_transpose`: invariance under transpose — proved — reindex the infimum by `σ ↦ σ⁻¹`.
5. `tropDet_row_col_perm`: invariance under permuting rows and columns — proved — reindex by `σ ↦ p.symm.trans (σ.trans q)`.
6. `tropDet_zero_diag_eq_zero`: matrices with zero diagonal and nonnegative entries (the "tropical Birkhoff polytope") have `tropDet = 0` — proved — identity permutation gives the upper bound, the Hadamard bound gives the lower bound.

The supporting definitions are `permSum` (assignment cost of a permutation), `tropDet` (min assignment cost), and `tropMatMul` (min-plus matrix product). Each theorem carries a brief `!--` proof-sketch comment block. The best result, `tropDet_submul`, comes with a strengthening direction (strict equality over a supertropical/ghost layer) and the natural boundary discussion (the Hadamard-gap / rank-1 tightness condition) recorded in the future directions.

Also delivered `Catalog/Tropical/FUTURE_DIRECTIONS.md` with five testable, falsifiable conjectures extending the work — the Hadamard-gap/rank-1 characterization, strict supertropical multiplicativity, a tropical Cauchy–Binet identity, the tropical Birkhoff polytope and its vertices, and the bridge to minimum-mean-cycle tropical spectral theory — each with a "key insight" and a "Why now?" justification grounded in the proved lemmas.

Compilation was verified through the language server (standalone elaboration succeeds and an axiom check on the core results returns only the permitted axioms); a search confirms no `sorry`/`admit` remain in the file.