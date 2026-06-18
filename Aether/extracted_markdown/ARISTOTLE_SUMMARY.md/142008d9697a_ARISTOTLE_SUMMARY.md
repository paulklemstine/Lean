# Summary of changes for run da3b8dd8-44e4-411b-a4b4-87c008984785
Built a focused, standalone formalization of the corrected categorical-tropical-Rips interleaving quotient metric.

## New file: `Catalog/Bridges/CategoricalTropicalRipsQuotient.lean`
Compiles with no `sorry`; all headline results verified to use only the standard axioms `propext`, `Classical.choice`, `Quot.sound`. It reuses the existing catalog infrastructure (`PersMod`, `interleavingDist`, `interleavingDist_self/_comm/_triangle`, `FinInterleaved`, `rankMod`, `rank_interleavingDist_le`) rather than re-proving it.

Contents:
1. **Kernel relation** `DistZero M N := interleavingDist M N = 0`.
2. **Four-point descent lemma** `interleavingDist_eq_of_dist_zero`: `DistZero M M'` and `DistZero N N'` ⟹ `interleavingDist M N = interleavingDist M' N'` (proved from the catalog triangle inequality and commutativity).
3. **Setoid** `distZeroSetoid`, built from `distZero_refl` (self distance 0), `distZero_symm` (commutativity), `distZero_trans` (triangle inequality).
4. **Quotient distance** `quotDist` via `Quotient.lift₂`, with computation lemma `quotDist_mk`.
5. **Metric laws**: `quotDist_self`, `quotDist_comm`, `quotDist_triangle`, and the separation law `quotDist_eq_zero_iff : quotDist q q' = 0 ↔ q = q'` — i.e. a genuine point-separating ℝ≥0∞-valued metric on the quotient.
6. **Obstruction for the FinInterleaved quotient**, treating it as false in general (not as a positive theorem):
   - `constancy_forces_distZero`: constancy of `interleavingDist` on a class forces the representatives to be at distance 0 (so finiteness alone is insufficient);
   - `finInterleaved_not_distZero`: a concrete ℝ witness (identity module vs. its +1 shift) that is finitely interleaved but not at distance 0;
   - `finInterleaved_dist_not_welldefined`: two FinInterleaved modules whose interleaving distances to a common third module differ, so `interleavingDist` does not descend along `FinInterleaved`.
7. **Optional extension**: `rankMod_distZero`, the induced map `rankModQuot`, and `rankMod_descends_to_quotient` showing the catalog's 1-Lipschitz rank invariant factors through the zero-distance quotient and stays 1-Lipschitz.

## Companion paper: `Catalog/Bridges/CategoricalTropicalRipsQuotient.md`
States the correction explicitly — the finite-interleaving quotient does not yield a separating metric in general (with the triangle-inequality obstruction and the concrete counterexample), and the zero-distance quotient is the correct replacement — and summarizes the formal results.

## Build fix
The project's `lakefile.toml` was missing `srcDir`, so the library globs (`Bridges.+`, etc.) pointed at non-existent top-level directories while the sources live under `Catalog/`; no module could be built. Added `srcDir = "Catalog"`, after which per-module builds succeed. (An unrelated, pre-existing missing file referenced elsewhere in the `Algebra` library still prevents a whole-defaultTargets build, but it is outside the scope of this task and unaffected by these changes.)