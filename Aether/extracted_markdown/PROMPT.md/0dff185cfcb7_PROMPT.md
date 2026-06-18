Formalize a complete and self-contained Lean file proving a sound tropical lower-bound certificate theorem for a minimal language of combinatorial-species expressions, with no `sorry`, placeholders, or theorem stubs.

Target file: `Catalog/Bridges/SpeciesTropicalProfileCertificate.lean`

Mathematical goal:
Build a small syntax `SpExpr` of species expressions whose denotation is an integer coefficient sequence, and prove that a structurally computed tropical lower bound is always below the actual valuation profile of the denoted sequence.

Required scope restrictions:
1. Use only atoms whose coefficient semantics are already explicitly available in the catalog and whose valuation-profile lower bounds can be proved from existing lemmas. If necessary, reduce to the smallest viable atom set rather than introducing ambitious new species.
2. Use only the two recursive constructors:
   - `add`, interpreted as coefficientwise addition
   - `mul`, interpreted as the existing binomial-convolution / species product semantics
3. The theorem must be fully proved by structural induction from existing valuation lemmas; do not include prose in place of code, unfinished declarations, or placeholders.

Suggested formal structure:
1. Define `SpExpr`.
2. Define `SpExpr.coeff : SpExpr -> ℕ -> ℤ` (or the coefficient codomain already used by the valuation interface).
3. Prove definitional lemmas for coefficients at `add` and `mul` nodes.
4. Define `tropLB p : SpExpr -> ℕ -> WithTop ℕ` (or whatever codomain matches the existing valuation profile API), recursively by:
   - atom: use the strongest base lower bound available from prior files
   - add: pointwise `min`
   - mul: min-plus convolution over all `k ≤ n`
5. Prove the key step lemmas in full:
   - `valProfile_add_node`
   - `valProfile_mul_node`
6. Prove the main theorem in full:
   - `tropLB_le_valProfile : tropLB p e n ≤ valProfile p (SpExpr.coeff e) n`

Important methodological instructions:
- Be conservative about definitions so that all base cases are actually provable from existing files.
- If an intended atom such as linear orders requires new unsupported valuation facts, drop it and state the theorem for a smaller atom language instead of leaving gaps.
- Reuse the exact existing notions of valuation profile, coefficient convolution, and tropical lower bounds from the relevant bridge file whenever possible.
- Prefer a short, complete theorem over a broad, partial development.
- Include any helper lemmas needed to make the induction clean and fully checkable.

Deliverable standard:
The file should compile completely. The assessment will specifically check that `valProfile_add_node`, `valProfile_mul_node`, and `tropLB_le_valProfile` are actual Lean proofs, not declarations without bodies.

If the existing species API is awkward, it is acceptable to present `SpExpr` as a syntax for coefficient sequences inspired by species operations, provided the semantics of `add` and `mul` exactly match the catalog’s species counting operations and the final theorem still realizes the species-to-tropical certificate pipeline.