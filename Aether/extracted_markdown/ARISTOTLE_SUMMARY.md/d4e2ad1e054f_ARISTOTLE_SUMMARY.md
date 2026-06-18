# Summary of changes for run 90aa35f4-3054-46b5-8b53-c92e3caae08d
Extended the project's Neural Tangent Kernel convergence theory with a new, fully proven Lean file and a research-directions note.

**New file:** `Catalog/MachineLearning/NTKConvergenceRate.lean` (module `MachineLearning.NTKConvergenceRate`). It builds directly on the existing `MachineLearning.NTKCore` and `MachineLearning.NTKSpectral` results (`gdResidual`, `ntkGramMatrix`, `gdResidual_eigenvector`, `gdResidual_eigenvector_norm`, `gdResidual_eigenvector_decay`, `optimalRate_contraction`, `optimalRate_minimizes`). It contains 7 theorems plus a worked example, all proven with no `sorry` and depending only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

- `optimalRate_band_contraction` — the optimal step size η* = 2/(μ+L) contracts *every* eigenvalue in the whole spectral band [μ,L] by at most the inverse-condition-number factor (L−μ)/(L+μ), not merely the two extreme modes.
- `ntk_optimalRate_uniform_decay` (capstone) — consequently every genuine NTK eigenmode with eigenvalue in [μ,L] has residual decaying at the single explicit rate ((L−μ)/(L+μ))^t.
- `optimalRate_isMinimax` — η* is a global minimiser, over all real step sizes, of the worst-case two-mode contraction.
- `contraction_eq_condition_number` and `contraction_mono_condition_number` — the rate equals (κ−1)/(κ+1) with κ = L/μ and is monotone increasing in the condition number.
- `optimalRate_decay_tight` — the band bound is attained exactly at the smallest eigenvalue (tightness).
- `zero_eigenvalue_stationary` — boundary/failure case: a zero-eigenvalue mode is stationary under gradient descent for every step size (the degenerate μ = 0 case where the theory breaks down).

Each theorem carries a brief `-- !-- ... -- !--` proof sketch, and the file ends with a concrete numerical `example`. The whole file compiles successfully (verified via build and an axiom check).

**Research notes:** `Catalog/MachineLearning/FUTURE_DIRECTIONS.md` lays out five testable, falsifiable conjectures extending this work (full-vector decay via spectral decomposition, condition-number iteration complexity, Polyak heavy-ball acceleration to the √κ rate, robustness to spectrum misestimation, and a two-sided lower-bound optimality result), each with a "key insight" and a "Why now?" justification grounded in the lemmas just proven.