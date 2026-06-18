# Summary of changes for run d4e6376d-1696-4ed5-8ad2-f7ad5003acf0
Delivered a self-contained Lean 4 research artifact on NTK (neural-tangent-kernel) spectral convergence, plus the required research-direction notes.

**New files**
- `Catalog/MachineLearning/NTKSpectral.lean` — 12 fully-proved theorems, **0 sorries**, axiom-clean (only `propext`, `Classical.choice`, `Quot.sound`). Verified via a full module build of `MachineLearning.NTKSpectral` and `#print axioms` on the capstone and key lemmas.
- `Catalog/MachineLearning/FUTURE_DIRECTIONS.md` — narrative Synthesis + Results Summary + 5 falsifiable research directions, each with a "The key insight is…" sentence and a "Why now?" justification.

**What is proved.** Starting from cold (no prior NTK core in the catalog), the file folds in the core definitions `ntkGramMatrix` (`Φ Φᵀ`), `gdUpdateOp` (`I - ηK`), and `gdResidual` (`(I-ηK)ᵗ u₀`), then opens the contractivity "black box" spectrally:
- `gdUpdateOp_mulVec_eigenvector` — the update map acts as the exact scalar `1 - ηλ` on eigenvectors.
- `gdResidual_eigenvector` / `gdResidual_eigenvector_norm` — exact geometric residual law `‖uₜ‖ = |1-ηλ|ᵗ‖v‖`.
- `gdResidual_eigenvector_decay`, `eigenvalue_stable_iff` (`0 < ηλ < 2`).
- The optimal learning-rate triple at `η*=2/(μ+L)`: `optimalRate_contraction`, `optimalRate_lt_one`, and the optimality direction `optimalRate_minimizes`.
- The PSD bridge to Mathlib's Hermitian eigenvalue API: `ntkGramMatrix_posSemidef`, `ntkGram_eigenvalues_nonneg`, `ntkGram_eigenpair`.
- Capstone `ntk_eigen_convergence`: exact geometric decay with an explicit `< 1` rate for a genuine NTK eigenmode.

The file also contains the requested `-- !--` proof-sketch comments on every theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

**Build fix.** The project's `lakefile.toml` was missing the source root, so no module could resolve (sources live under `Catalog/` while modules are named e.g. `MachineLearning.X`). I added `srcDir = "Catalog"` to the package configuration; the target module now builds successfully.