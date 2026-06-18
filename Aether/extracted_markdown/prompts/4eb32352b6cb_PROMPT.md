Produce one small, standalone Lean 4 file in `Catalog/Algebra/BerggrenLorentz/WordCertificates.lean` that builds faithfully on `Algebra/BerggrenLorentz/Core.lean` and proves a coherent package of whole-word certification theorems for Berggren matrices.

Scope restrictions:
- Stay entirely within the Berggren/Lorentz/Pythagorean infrastructure already defined in the core file.
- Do NOT introduce cryptographic notions, lattice reduction algorithms, inverse generators, parent maps, descent on hypotenuse, or any unrelated imported material.
- Do NOT include theorem stubs, speculative statements, or declarations without complete proofs.
- Prefer simple list-based recursion over any elaborate free-monoid abstraction unless the core file already provides it.

Mathematical target:
1. Define an inductive or enum type of Berggren generators if one is not already present, with a function sending each generator to its matrix from the core file.
2. Define `wordMatrix : List Gen -> Matrix (Fin 3) (Fin 3) ℤ` by recursion (`[]` maps to `1`, `g :: w` maps to `genMatrix g * wordMatrix w`, or the reverse convention if more convenient).
3. Prove the whole-word Lorentz preservation theorem:
   `wordMatrix wᵀ ⬝ lorentzForm ⬝ wordMatrix w = lorentzForm`
   using the corresponding single-generator preservation lemmas from the core file and closure under multiplication.
4. Prove a determinant theorem for words. The cleanest acceptable form is multiplicative recursion plus a corollary `IsUnit (Matrix.det (wordMatrix w))`; if feasible, strengthen to an explicit sign formula depending on the parity of orientation-reversing generators.
5. Derive the quadratic-form invariance theorem:
   `lorentzQ (wordMatrix w ⬝ v) = lorentzQ v`
   for integer vectors `v`, using the matrix preservation result.
6. If and only if the core file already contains the needed equivalence/implication between `lorentzQ v = 0` and `IsPythag ...`, prove the corresponding corollary that Berggren words send Pythagorean triples to Pythagorean triples. If that bridge is not already available in the API, stop at `lorentzQ` preservation rather than inventing new encodings.

Proof strategy:
- First prove a reusable lemma that if `A` and `B` each preserve the Lorentz form, then so does `A ⬝ B`.
- Then induct on the word to obtain the preservation theorem.
- For determinants, use `Matrix.det_mul`, the determinant of the identity, and the determinant lemmas for generators from the core file.
- Keep all statements concrete over `ℤ` and `Fin 3` matrices/vectors to minimize coercion overhead.

Deliverable quality bar:
- The file must typecheck completely with no `sorry`.
- Every theorem should be directly used or naturally support the main result package.
- The module should read as a finished formalization of the monoid-certification layer, not as a partial draft toward a larger cryptographic project.

If any intended theorem becomes awkward because the exact names in `Core.lean` differ from expectation, adapt to the existing API rather than forcing the original wording. The goal is a correct, modest, reusable theorem cluster, not maximal ambition.