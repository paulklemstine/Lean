# Summary of changes for run a83a3abd-a595-46c7-af79-b94c28bbf2a4
Created a single new, tightly-scoped Lean file `Computation/NovikovSelfConsistency.lean` developing Novikov-style self-consistency purely as fixed-point mathematics (Banach contraction + 1-D interval results), with a module docstring explaining the interpretation: a self-consistent history solves `f x = x`, and contraction yields existence, uniqueness, convergence, and certified error bounds.

The file (namespace `NovikovSelfConsistency`) contains exactly the four requested families, all fully proved (no `sorry`, no extra axioms beyond `propext`/`Classical.choice`/`Quot.sound`), reusing Mathlib's `ContractingWith`/`LipschitzWith` API:

1. Existence & uniqueness on complete metric spaces:
   - `exists_fixedPoint_of_contractingWith` (∃ fixed point)
   - `fixedPoint_unique_of_contractingWith` (uniqueness)
   - `existsUnique_fixedPoint_of_contractingWith` (packaged `∃!`)

2. Picard iteration convergence:
   - `tendsto_iterate_fixedPoint_of_contractingWith` (orbit `f^[n] x0 → x_star`)

3. Explicit error bounds:
   - `dist_iterate_succ_le_geometric`: `dist (f^[n] x0) (f^[n+1] x0) ≤ K^n * dist (f x0) x0`
   - `dist_iterate_fixedPoint_le_geometric` (a priori): `dist (f^[n] x0) x_star ≤ (K^n/(1-K)) * dist (f x0) x0`
   - `aposteriori_dist_iterate_fixedPoint_le_geometric` (a posteriori): `dist (f^[n] x0) x_star ≤ (1/(1-K)) * dist (f^[n] x0) (f^[n+1] x0)`

4. Compact interval consequences on ℝ:
   - `existsUnique_fixedPoint_Icc_of_contractingWith`: a contraction mapping `Set.Icc a b` into itself has a unique fixed point in the interval (proved via closedness of `Icc` and convergence of the iterates from `a`).
   - `exists_fixedPoint_Icc_of_continuous_mapsTo`: a continuous self-map of `Set.Icc a b` has at least one fixed point, via the intermediate value theorem applied to `g x = f x - x`; uniqueness is not claimed.

The contraction constant uses Mathlib's bundled `ContractingWith K f` (with `K : NNReal`, which carries `K < 1` and `0 ≤ K`), as permitted by the request. The file imports only `Mathlib` and adds no declarations outside these theorem families and the minimal helper steps inside their proofs.

Verification: `lake build Computation.NovikovSelfConsistency` succeeds with no errors and no warnings; a grep confirms no `sorry`; `#print axioms` on the main theorems shows only the standard axioms. (Note: the project's overall default build has a pre-existing unrelated failure from a missing file `Algebra/SpectralNovelty/CutMetric.lean`, independent of this new file.)