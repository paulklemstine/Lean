Formalize a minimal, complete certification layer in a new file `Catalog/Algebra/BerggrenLorentz/WordCertificates.lean` built directly on `Catalog/FINAL/Algebra/BerggrenLorentz/Core.lean`.

Scope:
- Keep the project narrowly focused on Berggren words and Lorentz-form preservation.
- Do not attempt determinant parity/counting formulas, `IsUnit` corollaries, or any classification/enumeration results unless they are trivial after the main theorem.
- The file must compile cleanly with zero `sorry`s, zero truncated declarations, and no pasted unrelated material.

Required definitions:
1. Define an inductive enum
   `inductive Gen | A | B | C deriving DecidableEq, Repr`.
2. Define
   `genMatrix : Gen → Matrix (Fin 3) (Fin 3) ℤ`
   by mapping `A,B,C` to the existing `matA, matB, matC` from the core file.
3. Define
   `wordMatrix : List Gen → Matrix (Fin 3) (Fin 3) ℤ`
   recursively by
   `[] ↦ 1` and `g :: w ↦ genMatrix g * wordMatrix w`.
4. Add only the obvious simp lemmas for `wordMatrix_nil` and `wordMatrix_cons`.

Required theorems:
A. Generator-level preservation:
- Prove a theorem for each generator, or a single case-split theorem,
  `genMatrix_preserves_metricQ (g : Gen) : (genMatrix g)ᵀ * metricQ * genMatrix g = metricQ`
  using the corresponding preservation lemmas already available in the core API for `matA`, `matB`, `matC`.

B. Word-level preservation by induction:
- Prove
  `wordMatrix_preserves_metricQ (w : List Gen) : (wordMatrix w)ᵀ * metricQ * wordMatrix w = metricQ`.
- Follow the intended proof strategy exactly: induction on `w`, use the recursive definition, transpose-of-product, associativity, and the generator theorem from part A.

C. Quadratic-form invariance on vectors:
- Using the core definitions of the Lorentz quadratic form on `Fin 3 → ℤ`, prove that if `M = wordMatrix w`, then applying `M` to a vector preserves the Lorentz form. State this in whatever form matches the core API most directly, for example
  `lorentzQ (wordMatrix w *ᵥ v) = lorentzQ v`
  or the corresponding named form in the core file.
- The proof should derive from part B and the existing core lemma that `Mᵀ Q M = Q` implies quadratic-form invariance.

D. Pythagorean preservation:
- Using the existing bridge in the core file between the Lorentz equation and the predicate `IsPythag`, prove a whole-word theorem saying Berggren words send Pythagorean triples to Pythagorean triples.
- Again, choose the statement shape that matches the core API exactly; the point is to package the already-available single-step bridge into a word-level corollary.

Implementation guidance:
- Prefer reusing the exact names and helper lemmas from `Core.lean` instead of reproving matrix identities from scratch.
- Keep everything over `ℤ` and `Fin 3`.
- If there is any mismatch in notation (`metricQ` vs `Q`, `lorentzForm` vs `lorentzQ`, matrix-vector action notation, etc.), inspect `Core.lean` and adapt to its actual exported names.
- Avoid introducing extra abstractions, typeclasses, or generic monoid machinery; a direct concrete development is preferred.
- The finished file should be short and self-contained, with a module docstring summarizing the result.

Deliverable:
- One complete Lean file `Catalog/Algebra/BerggrenLorentz/WordCertificates.lean` that compiles.
- The file should contain only the definitions and theorems above, plus whatever tiny helper lemmas are strictly necessary for the induction and rewriting.