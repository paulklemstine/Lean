# Summary of changes for run 02b1725f-2914-413c-aee1-f285d99e8548
Created `Catalog/Computation/NovikovConsistency.lean`, a single self-contained, fully-proved Lean 4 file formalizing "Novikov self-consistency as a fixed-point theorem". It depends only on Mathlib and contains no `sorry` or unproved headers; all declarations verified to compile and to use only the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Modeling dictionary (in the module docstring): a closed-timelike-curve boundary condition is a self-map `T : X → X`, a self-consistent history is a fixed point `T x = x`, and `dist x (T x)` is the one-step inconsistency.

Contents:

1. Contraction (complete metric space) regime — thin wrappers over Mathlib's `ContractingWith` (Banach) API:
   - `novikov_exists_unique`: unique self-consistent history.
   - `novikov_picard_converges`: Picard iterates `T^[n] x` converge to it.
   - `novikov_error_bound`: `dist x x* ≤ dist x (T x) / (1 - K)`.
   - `novikov_iterate_bound`: geometric a-priori bound `dist (T^[n] x) x* ≤ dist x (T x) * K^n / (1 - K)`.
   - Supporting `novikovContracting`, `novikovFixedPoint`, `novikov_isFixedPt`.

2. Interval (topological, 1D) regime — existence only, via the intermediate value theorem (1D Brouwer):
   - `novikov_exists_interval` (real form, continuous `T : ℝ → ℝ` mapping `Icc a b` into itself).
   - `novikov_exists_interval_subtype` (continuous self-map `T : Set.Icc a b → Set.Icc a b`).

3. Examples:
   - `affine_contraction` and `affine_novikov_fixedPoint`: `T x = c*x+d` with `|c|<1` is a contraction with unique fixed point `d/(1-c)`.
   - `constant_novikov_interval`: constant rule trivially consistent.
   - `identity_novikov_interval`: identity makes every point fixed (nonuniqueness witness).
   - `grandfather_no_fixedPoint` and `grandfather_not_selfMap`: the shift `T x = x+1` has no fixed point and is not a self-map of any `Icc a b`, making the obstruction explicit.

Note on reuse: the interval result is proved directly from Mathlib's IVT (the 1D Brouwer theorem) rather than importing the catalog's `brouwer_fixedPoint_Icc_general`, because the project's source layout means that module is not importable in isolation; keeping the file self-contained guarantees it builds. The file lives under `Catalog/Computation/`, matching the `Computation` library target.