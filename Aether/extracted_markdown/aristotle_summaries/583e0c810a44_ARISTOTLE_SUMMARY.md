# Summary of changes for run 588aa1ef-2fdb-41e6-86ca-aca942d9b09f
Produced a new, self-contained Lean 4 artifact `Catalog/MachineLearning/NTKSpectral.lean` plus a `FUTURE_DIRECTIONS.md`, completing one full research cycle on spectral convergence of Neural-Tangent-Kernel gradient descent.

**Lean file `Catalog/MachineLearning/NTKSpectral.lean`** (sorry-free, axiom-clean — every result depends only on `propext`, `Classical.choice`, `Quot.sound`, verified via `#print axioms`). Since this was a cold start (no prior `NTKCore` existed in the catalog), the file folds in the core definitions (`ntkGramMatrix = Φ Φᵀ`, the GD update operator `gdUpdateOp = I - ηK`, and the residual recursion `gdResidual`) and then proves 11 theorems:

- `gdUpdateOp_mulVec_eigenvector` — `I - ηK` acts as the scalar `1 - ηλ` on eigenvectors (diagonalization).
- `gdResidual_eigenvector` — the residual along an eigenvector is exactly `(1 - ηλ)ᵗ • v`.
- `gdResidual_eigenvector_norm` — exact geometric norm law `‖uₜ‖ = |1 - ηλ|ᵗ ‖v‖`.
- `gdResidual_eigenvector_decay` — any per-mode bound `|1-ηλ| ≤ c` upgrades to `‖uₜ‖ ≤ cᵗ ‖v‖`.
- `eigenvalue_stable_iff` — strict contraction iff `0 < ηλ < 2` (the classical stability window).
- `optimalRate_contraction`, `optimalRate_lt_one`, `optimalRate_minimizes` — the optimal learning-rate triple: at `η* = 2/(μ+L)` both extreme modes contract by exactly `(L-μ)/(L+μ)`, this factor is `< 1` because `μ > 0`, and no step size beats it on the worse mode.
- `ntkGramMatrix_posSemidef`, `ntkGram_eigenvalues_nonneg` — the NTK Gram spectrum is nonnegative (bridged to Mathlib's PSD eigenvalue API).
- `ntk_eigen_convergence` — capstone: for a genuine NTK eigenmode with `λ > 0` and `η` in range, exact geometric decay with an explicit `< 1` rate.

The file includes the required `-- !-- ... -- !--` proof-sketch blocks before each theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

**`FUTURE_DIRECTIONS.md`** — a freeform narrative with a Synthesis, a Results Summary, and 5 falsifiable research directions (operator-norm = spectral radius; strict positive-definiteness from independent feature gradients; whole-vector convergence rate from the spectral gap; multi-output/block NTK via general index types; loss decay and the PL/strong-convexity bridge). Each direction states "The key insight is..." and a "Why now?" justification, and references the catalog theorems it extends.

Verification was done through the Lean language server (full-file elaboration with no errors or warnings, no remaining `sorry`/`admit`, and explicit axiom checks). Note: the project's build configuration does not currently wire the `Catalog/` tree into its lake targets, so verification was performed via the language server rather than `lake build`.