# Summary of changes for run 3214f43b-01b9-4ffb-833f-84cd726cab92
Created a coherent, fully-proved finite information-geometry foundation.

**New file `Catalog/Geometry/InformationGeometry/FiniteCore.lean`** (compiles cleanly, no `sorry`, depends only on the standard axioms `propext`/`Classical.choice`/`Quot.sound`):

- A module docstring describing the finite (manifold-free, derivative-free) scope.
- `FiniteStatModel Θ Ω` over a `Fintype` sample space with fields `pmf`, `pmf_nonneg`, `pmf_sum_one` (no unused `logLik`).
- Weighted statistics: `expectation`, `centered`, `covariance`, `variance`.
- Statistics lemmas: `expectation_const`, `covariance_symm`, `variance_eq_covariance_self`, `variance_nonneg`, `variance_const`, `covariance_const_left` (plus `covariance_const_right`).
- `fisherMatrix M dlogp θ` from an externally supplied score function `dlogp : Θ → Ω → Fin n → ℝ`.
- Matrix properties: `fisherMatrix_apply_symm`, `fisherMatrix_isSymm`, and the main nontrivial theorem `fisherMatrix_quadratic_form` reducing the quadratic form to `∑ ω, pmf θ ω * (∑ i, v i * dlogp θ ω i)^2`, with the PSD corollary `fisherMatrix_posSemidef_quadratic`.
- Elementary finite exponential family: `partitionFunction`, `expFamPmf`, with `expFamPmf_sum_one` (pmf sums to one when the partition function is nonzero), plus `partitionFunction_pos` and `expFamPmf_nonneg`.

**Optional second file `Catalog/Geometry/InformationGeometry/TwoPointExamples.lean`** (also compiles cleanly, no `sorry`, no warnings): instantiates the core on the two-point space `Bool` via a Bernoulli family `bernoulli`, proving `bernoulli_expectation_indicator` and exhibiting the general variance-nonnegativity, Fisher PSD, and partition-function-positivity results as concrete instances.

Note: the project's pre-existing `lakefile.toml` default targets do not match the `Catalog/` directory layout, so verification was done by compiling the modules directly with the project's Lean/Mathlib toolchain (v4.28.0); both files build with exit code 0 and contain no placeholders.