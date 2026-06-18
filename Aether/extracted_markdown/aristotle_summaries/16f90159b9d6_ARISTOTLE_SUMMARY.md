# Summary of changes for run 3d48ade1-04e2-46b3-b4cf-1e4c32bc0eff
## Spectral Universality of Neural Tangent Kernels on Arithmetic Expanders

I produced a new, fully machine-checked Lean 4 file plus a research-directions narrative.

### New Lean file: `Catalog/MachineLearning/ArithmeticExpanderNTKUniversality.lean`
It formalizes the rigorous algebraic core of the spectral-universality conjecture for graph neural tangent kernels (NTKs), building on the existing catalog work `MachineLearning/NTKCore.lean` and `MachineLearning/NTKSpectral.lean` and connecting it to the arithmetic-expander spectral picture.

Definitions introduced: `normAdj` (degree-normalized graph operator `A/d`), `graphNTK` (lazy-regime NTK as a power series `Σ_k c_k (A/d)^k`), and `ntkSymbol` (the universal scalar symbol `Σ_k c_k ρ^k`).

Six theorems, all **proved with no `sorry`** and depending only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`:
1. `mulVec_pow_eigen` — powers of an operator act as `μ^k` on its eigenvectors.
2. `graphNTK_mulVec_eigen` — the graph NTK acts on an adjacency eigenvector (eigenvalue `ρ`) exactly by the universal symbol `ntkSymbol c N ρ`, a function of `ρ` alone (the universality core).
3. `graphNTK_eigenvalue_universal` — two different graph constructions sharing an eigenvalue produce identical NTK eigenvalues (construction independence).
4. `regular_const_eigen` — the degree-normalized constant mode is fixed at eigenvalue 1 for any d-regular operator.
5. `spectral_gap_scaling` — the residual bound `(1-gap)^t` is monotone in the spectral gap (explicit scaling law).
6. `expander_ntk_training_decay` — capstone bridging to the NTK training dynamics: gradient-descent residuals along a spectral mode decay exactly as `(1 - η·symbol)^t`, governed solely by the adjacency eigenvalue.

Each theorem carries a one–two sentence proof sketch in `-- !-- ... -- !--` blocks, and the file header lists the theorem declarations and their statuses.

### `FUTURE_DIRECTIONS.md`
Five falsifiable conjectures extending the work (quantitative perturbation universality, a full generalization-error scaling law, architecture independence via symbol equivalence, Ramanujan optimality of the scaling constant, and finite-width feature-learning corrections), each with an explicit "The key insight is…" statement and a "Why now?" justification.

### Verification
The module builds cleanly (`lake build MachineLearning.ArithmeticExpanderNTKUniversality`), contains zero `sorry`, and an axiom audit confirms all six results rest only on the permitted standard axioms.

Note: the outer wrapper `lakefile.toml` at the project root was given `srcDir = "Catalog"` so the project also builds from the top level; the real package configuration under `Catalog/` is unchanged.