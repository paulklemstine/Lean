# Summary of changes for run 1e6fa58f-6452-4636-baa5-ac0976438775
I extended the project's Neural Tangent Kernel (NTK) formalization along its stated Research Direction #1 (explicit spectral control of gradient-descent training), building directly on the existing catalog files `MachineLearning/NTKCore.lean` and `MachineLearning/NTKSpectral.lean`.

## New file: `Catalog/MachineLearning/NTKSpectralConvergence.lean`

It pushes the NTK theory from single-eigenmode statements to the full training trajectory, with 9 theorems, all fully proved (zero `sorry`, only standard axioms `propext`/`Classical.choice`/`Quot.sound`):

1. `gdResidual_smul`, `gdResidual_add`, `gdResidual_sum` — the gradient-descent residual map `u₀ ↦ gdResidual K η u₀ t` is linear (homogeneity, additivity, and commuting with finite sums).
2. `gdResidual_sum_eigenbasis` — the **closed-form spectral solution**: for any eigen-expansion `u₀ = Σ cᵢ vᵢ` of the kernel, the residual after `t` steps is the mode-by-mode decay `Σ (cᵢ·(1−ηλᵢ)ᵗ) vᵢ`.
3. `gdResidual_eigenbasis_decay` — the capstone for Direction #1: turns explicit per-eigenvalue bounds `|1−ηλᵢ| ≤ c` into the global decay estimate `‖u_t‖ ≤ cᵗ·Σ|cᵢ|‖vᵢ‖`, with no opaque contractivity assumption — the contraction is computed from the spectrum.
4. `gdResidual_norm_tendsto_zero` and `gdResidual_tendsto_zero` — under contractivity the residual (norm and vector) converges to 0.
5. `gdResidual_eigenvector_tendsto_zero` — a single eigen-mode in the classical stability window `0 < ηλ < 2` decays to 0.
6. `gdResidual_eigenvector_divergence` — the matching boundary/counterexample: an unstable mode `|1−ηλ| > 1` makes the residual norm diverge to +∞, showing the stability window is necessary, not just sufficient.

For the best result (`gdResidual_eigenbasis_decay`) I also removed an unnecessary nonnegativity hypothesis `0 ≤ c`, since it follows automatically from `|1−ηλᵢ| ≤ c`, yielding a cleaner statement (noted in its docstring). The divergence theorem serves as the boundary case for the convergence results.

## `Catalog/MachineLearning/FUTURE_DIRECTIONS.md`

Five testable, falsifiable research conjectures extending the work, each with a "The key insight is…" sentence and a "Why now?" justification: (1) Euclidean operator-norm spectral contractivity removing the ℓ¹ overhead; (2) optimal-rate min–max convergence by condition number; (3) quantitative iteration-complexity/stopping-time bounds; (4) lazy-regime robustness of the closed form under kernel perturbation; (5) spectral-bias mode-ordering of convergence.

## Build fix

The repository's root `lakefile.toml` was missing a source directory setting, so the root project could not locate the library sources under `Catalog/`. I added `srcDir = "Catalog"` to the root `lakefile.toml`; the project now builds correctly from the repository root, and the new module compiles cleanly with no errors, warnings, or sorries.