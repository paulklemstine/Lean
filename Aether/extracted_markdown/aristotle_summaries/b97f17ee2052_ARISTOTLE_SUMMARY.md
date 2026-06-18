# Summary of changes for run 0bcbe618-0caf-441a-83ab-bd0531b34491
## Cycle deliverable: NTK Spectral Convergence Theory

I extended the existing `Catalog/MachineLearning/NTKCore.lean` along Research Direction #1 (opening the opaque contractivity constant `c < 1` of `gdResidual_geometric_decay` into explicit spectral content) by adding a new file `Catalog/MachineLearning/NTKSpectral.lean` containing **10 theorems, all fully proved with no `sorry`** (verified by build and by `#print axioms`, which shows only the standard `propext`/`Classical.choice`/`Quot.sound`).

**Theorems proved** (in `namespace NTKSpectral`):
- `gdUpdateOp_mulVec_eigenvector` — the GD update operator `I − ηK` acts as the scalar `1 − ηλ` on eigenvectors.
- `gdResidual_eigenvector` — the residual along an eigenvector is exactly `(1 − ηλ)^t · v`.
- `gdResidual_eigenvector_norm` — exact geometric norm law `‖u_t‖ = |1 − ηλ|^t ‖v‖` (sharpens the catalog's `≤` to `=` per mode).
- `gdResidual_eigenvector_decay` — any per-mode bound `|1 − ηλ| ≤ c` upgrades to `‖u_t‖ ≤ c^t ‖v‖`.
- `eigenvalue_stable_iff` — strict per-mode contraction iff the stability window `0 < ηλ < 2`.
- `optimalRate_contraction`, `optimalRate_lt_one`, `optimalRate_minimizes` — the classical optimal learning rate `η* = 2/(μ+L)` achieves contraction `(L−μ)/(L+μ)`, this is `< 1` exactly when `μ > 0`, and no step size beats it (optimality, via the η-free identity `L(1−ημ) − μ(1−ηL) = L − μ`).
- `ntkGram_eigenvalues_nonneg` — bridges the catalog's `ntkGramMatrix_posSemidef` to Mathlib's `Matrix.PosSemidef.eigenvalues_nonneg`.
- `ntk_eigen_convergence` — capstone tying exact decay + explicit `< 1` rate together for a genuine NTK eigenmode.

Each theorem carries a `-- !-- ... -- !--` proof sketch, and the file ends with a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

**Notes file**: `FUTURE_DIRECTIONS.md` (at the project root) contains the required `## Synthesis`, `## Results Summary`, and five falsifiable `## Research Directions` (operator-norm = spectral-radius; positive-definiteness from independent feature gradients; whole-vector convergence rate from the spectral gap; multi-output/block NTK via product index types; loss decay & local strong convexity), each with Hypothesis / Test / Why now / If true / If false.

**Infrastructure fix**: the project's `lakefile.toml` was missing `srcDir = "Catalog"`, so nothing built (module paths like `import MachineLearning.NTKCore` could not resolve). I added that single line; the project and both `NTKCore` and the new `NTKSpectral` modules now build successfully against the prebuilt Mathlib.