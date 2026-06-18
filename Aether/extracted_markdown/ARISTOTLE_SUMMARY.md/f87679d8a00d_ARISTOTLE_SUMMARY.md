# Summary of changes for run 488d3013-bfd7-476f-a0af-370b30347b7b
Added a new file `Catalog/Algebra/BerggrenLorentz/WordCertificates.lean`, a minimal self-contained certification layer built directly on `Catalog/Algebra/BerggrenLorentz/Core.lean` (the actual Core path; the prompt's `Catalog/FINAL/...` path does not exist in the project).

The file lives in namespace `BerggrenLorentz.Word` (nested to avoid colliding with the `wordMatrix`/`BerggrenWord` already present in Core) and imports the Core via `Algebra.BerggrenLorentz.Core`, matching the repository's dominant `Catalog`-rooted import convention.

Contents (exactly the requested definitions/theorems plus two tiny helper lemmas needed for the rewriting):
- `inductive Gen | A | B | C deriving DecidableEq, Repr`.
- `genMatrix : Gen → Matrix (Fin 3) (Fin 3) ℤ` mapping `A,B,C` to the existing `matA, matB, matC`.
- `wordMatrix : List Gen → Matrix (Fin 3) (Fin 3) ℤ` with `[] ↦ 1` and `g :: w ↦ genMatrix g * wordMatrix w`.
- `@[simp]` lemmas `wordMatrix_nil` and `wordMatrix_cons`.
- (A) `genMatrix_preserves_metricQ (g) : (genMatrix g)ᵀ * metricQ * genMatrix g = metricQ`, by case split on `g` reusing the core lemmas `matA/matB/matC_preserves_lorentz`.
- (B) `wordMatrix_preserves_metricQ (w) : (wordMatrix w)ᵀ * metricQ * wordMatrix w = metricQ`, by induction on `w` using the recursive definition, `Matrix.transpose_mul`, associativity, and the generator theorem.
- (C) `wordMatrix_preserves_lorentzForm (w) (v) : lorentzForm (wordMatrix w *ᵥ v) = lorentzForm v`, derived from (B) via a helper `lorentzForm_mulVec_of_preserves` (any `M` with `Mᵀ Q M = Q` preserves the form) and `lorentzForm_eq_dotProduct` (expressing the core `lorentzForm` through `metricQ`).
- (D) `wordMatrix_preserves_pythag (w) (v) (h : IsPythag (v 0) (v 1) (v 2))`, packaging the core bridges `lorentzQ_zero_iff_pythag` and `lorentzForm_eq_lorentzQ` with (C) into a whole-word statement that Berggren words send Pythagorean triples to Pythagorean triples.

Everything stays over `ℤ` and `Fin 3`, reuses the exact Core names, and avoids any determinant/parity/IsUnit/classification material. A module docstring summarizes the result.

Verification: the file was compiled directly with the Core module on the search path (the project's `lakefile.toml` lacks the `srcDir = "Catalog"` it would need for `lake build` to locate any catalog file — a pre-existing configuration gap unrelated to this file, which I left untouched). It elaborates with zero errors, zero warnings, and zero `sorry`s, and the three main theorems depend only on the permitted axioms (`propext`, `Classical.choice`, `Lean.ofReduceBool`, `Lean.trustCompiler`, `Quot.sound`).