# Summary of changes for run 2eb0b0dd-71ba-4672-ab67-15761d19fc36
Created a self-contained finite information geometry core at `Geometry/InformationGeometry/FiniteCore.lean` in the namespace `Catalog.InformationGeometry.FiniteCore`.

The file defines:
- `FiniteStatModel Ω` — a structure wrapping `pmf : Ω → ℝ` with nonnegativity and sum-to-one proofs.
- `expectation`, `centered`, `variance`, and `covariance` exactly as specified.

It proves, with complete statements and complete proofs (no sorries), all 10 requested theorems:
1. `expectation_const`
2. `expectation_add`
3. `expectation_smul`
4. `covariance_symm`
5. `variance_eq_covariance_self`
6. `covariance_const_left`
7. `variance_const`
8. `variance_nonneg`
9. `covariance_linear_left`
10. `variance_add_covariance`

The file is 175 lines, imports only minimal Mathlib modules (plus `Mathlib.Tactic`), and excludes the Fisher information matrix and exponential families as requested. One import path was adjusted to match this Mathlib version (`Mathlib.Algebra.BigOperators.Group.Finset.Basic`). The module builds successfully (`lake build Geometry.InformationGeometry.FiniteCore`) and a grep confirms there are no remaining `sorry` occurrences.