Complete and verify a Lean 4 formalization of a concrete certificate for Berggren–Lorentz reduction, keeping the scope elementary and proof-oriented rather than categorical.

Primary goal:
Create a finished file `Catalog/Bridges/TropicalBerggrenCertificate.lean` with no `sorry`s, no placeholder declarations, and no unfinished theorem headers. The file should build a usable certificate for Berggren words via an explicit matrix norm and then derive quantitative depth bounds for primitive Pythagorean triples generated from the Berggren tree.

Follow this exact mathematical plan.

1. Work over the existing Berggren–Lorentz setup from the catalog.
   - Reuse the catalog’s definitions of Berggren generators, Berggren words, the root triple `(3,4,5)`, matrix action on triples, and any existing depth/hypotenuse lemmas.
   - Prefer proving statements specifically for the 3×3 integer matrices already used in the Berggren development.

2. Define a concrete matrix certificate that is easy to formalize.
   - Define `rowNorm : Matrix (Fin 3) (Fin 3) ℤ → ℕ` as the maximum over rows of the row sum of entrywise absolute values.
   - Keep all downstream statements in terms of `ℕ` inequalities wherever possible.
   - If a more specialized equivalent norm is easier because Berggren matrices have controlled signs, that is acceptable, but the definition must be explicit and globally well-defined on the relevant matrices.

3. Prove the core algebraic facts completely.
   Required theorems should include, or be equivalent to:
   - `rowNorm_one`
   - `rowNorm_mul_le : rowNorm (M ⬝ N) ≤ rowNorm M * rowNorm N`
   - exact computations `rowNorm_genA = 7`, `rowNorm_genB = 7`, `rowNorm_genC = 7`
   These should be fully implemented, not left as computational stubs. For the generator calculations, using `native_decide`, `decide`, or explicit `norm_num`/`fin_cases` is fine.

4. Define the Berggren word evaluation map and prove functoriality.
   - Define `wordMatrix : List BerggrenGen → Matrix (Fin 3) (Fin 3) ℤ` by multiplication of generator matrices.
   - Prove `wordMatrix [] = 1` and `wordMatrix (u ++ v) = wordMatrix u ⬝ wordMatrix v`.
   - Then prove the certificate bound
     `rowNorm_wordMatrix_le : rowNorm (wordMatrix w) ≤ 7 ^ w.length`.
   The proof should be by induction using submultiplicativity and the exact generator norm computation.

5. Connect the matrix certificate to triples and hypotenuse growth.
   - Using the root triple `(3,4,5)` and the existing action of Berggren matrices on triples, prove a clean bound of the form
     `hyp_of_word_le : hyp (act (wordMatrix w) rootTriple) ≤ 5 * 7 ^ w.length`
     or the closest existing notational variant in the catalog.
   - If the catalog already contains a comparable theorem, show how the new certificate recovers it uniformly from `rowNorm_wordMatrix_le`.
   - The bridge should be explicit: the hypotenuse coordinate is bounded by a row-norm estimate on matrix-vector multiplication.

6. Derive a converse depth lower bound in an elementary form.
   - State and prove a theorem saying that if a triple appears at depth `d`, then its hypotenuse is at most `5 * 7^d`; equivalently, any triple with hypotenuse `c` must satisfy `c ≤ 5 * 7^d` for any realizing depth `d`.
   - If a logarithmic reformulation is easy from existing library lemmas, include it as a corollary; otherwise stop at the exponential inequality. Do not let real logarithm manipulations become the bottleneck.

7. Keep the tropical language only as lightweight commentary.
   - You may mention in docstrings that submultiplicativity becomes subadditivity after taking logs, but do not make category-theoretic tropicalization the main formal target unless it is essentially free once the elementary results are done.
   - The priority is a complete, robust Lean artifact.

8. Deliverable standards.
   - The file must compile against the current catalog environment.
   - No `sorry`, `admit`, or placeholder bodies.
   - Include concise module documentation explaining the certificate and its consequences.
   - Prefer small helper lemmas over brittle long proofs.

What to avoid:
- Do not overextend into abstract tropical categories or valuation reconstruction unless everything above is already complete.
- Do not introduce unnecessary generality beyond what helps the Berggren application.
- Do not leave theorem statements without proofs.

Success criterion:
A complete formalization of a Berggren word certificate based on row norms, proving generator norm `7`, functoriality of word evaluation, the bound `rowNorm (wordMatrix w) ≤ 7^|w|`, and a derived hypotenuse/depth inequality for the Berggren tree.