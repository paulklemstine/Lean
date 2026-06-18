Formalize a compact, self-contained bridge theorem package connecting combinatorial counting sequences to tropical/order valuation data through exponential generating functions. Do not pursue a broad categorical or species-functor framework unless every required ingredient is already in Catalog/FINAL/. Instead, work at the level of sequences a : ℕ → ℚ (or the coefficient ring already supported by the existing EGF file).

Target file: Catalog/Bridges/SpeciesTropicalValuation.lean

Primary goal: prove that the valuation of the EGF defines a tropical-style invariant of counting sequences under the binomial convolution product.

Required mathematical content:
1. Import the strongest existing FINAL files for combinatorial species / EGF algebra and for power-series order or valuation facts.
2. Define, with minimal new infrastructure:
   - `ordEGF (a : ℕ → ℚ) : WithTop ℕ := PowerSeries.order (egf a)`
   If a tropical wrapper type is already well-supported in FINAL, you may additionally define a tropicalized version, but this is optional and should not become the main technical burden.
3. Prove the bridge theorems with complete Lean proofs and no placeholders:
   - `egf_binConv` or the exact existing-name theorem: EGF of binomial convolution equals product of EGFs.
   - `ordEGF_binConv : ordEGF (binConv a b) = ordEGF a + ordEGF b`.
   - `ordEGF_add_ge : min (ordEGF a) (ordEGF b) ≤ ordEGF (a + b)`.
   These should be obtained by transporting already formalized power-series order lemmas through the EGF transform.
4. If the species file already provides a counting sequence `countSeq` or equivalent for a species F, add a lightweight corollary layer:
   - define `speciesOrdEGF F := ordEGF (countSeq F)`
   - prove the corresponding product/addition inequalities only when they follow immediately from existing species-to-sequence lemmas.
   Do not invent new species abstractions, equivalences, or functorial constructions.

Important restrictions:
- Remove all extraneous material. The previous attempt failed partly because unrelated identity-system/homotopy code was mixed into the file.
- Do not state unsupported claims such as an EGF bijection unless the exact theorem already exists and is easy to cite.
- Prefer short, robust theorem statements over ambitious but brittle generalizations.
- Verify there are no `sorry`s and no declarations without bodies.
- Use theorem names and imports that actually exist in Catalog/FINAL/; adapt statement names to the library rather than forcing speculative API.

Deliverables:
- A clean Lean file with complete proofs.
- A short RESEARCH_PAPER.md explaining the invariant `ordEGF`, the bridge theorem, and any species corollaries actually formalized.
- FUTURE_DIRECTIONS.md with 3-5 paragraphs, each containing a "The key insight is..." sentence and a "Why now?" justification. At least one future direction should discuss strengthening from order-only profiles to coefficientwise valuation profiles once adequate valuation infrastructure exists.

Success criterion: the resulting file should be a genuinely complete first bridge from combinatorial EGF algebra to tropical/order semantics, small enough to compile reliably and strong enough to support later generalization to richer valuation profiles.