# Summary of changes for run a7941f30-f6ff-49d1-9a8f-7fff2d44d91a
Created `Catalog/Geometry/InformationGeometry/FiniteCore.lean`, a self-contained finite information-geometry core over `ℝ` and a finite sample space.

Contents:
- `structure FiniteStatModel (Ω) [Fintype Ω]` with fields `pmf`, `pmf_nonneg`, `pmf_sum_one`.
- Definitions `expectation`, `centered`, `covariance`, and `variance` (defined via `covariance f f`).
- Fully proved theorems: `expectation_const`, `expectation_add`, `expectation_sub`, `expectation_smul`, `expectation_centered`, `covariance_def`, `covariance_comm`, `covariance_const_left`, `covariance_const_right`, `covariance_add_left`, `covariance_add_right`, `covariance_smul_left`, `covariance_smul_right`, `variance_eq_covariance_self`, `variance_nonneg`, and `variance_eq_expectation_sq_sub_sq_expectation` (the `Var(f) = E[f²] − (E[f])²` identity).

Proofs are elementary (`Finset.sum` manipulations, `simp`, `ring`, `Finset.sum_nonneg`, `positivity`). The scope is restricted exactly as requested: no Fisher information, entropy, KL divergence, exponential families, matrices, or other unrelated content. The module builds successfully with no `sorry` and no placeholder bodies (verified by building the `Geometry.InformationGeometry.FiniteCore` target).