Finish the original bridge in the narrowest possible way. Create one new Lean file in `Catalog/Bridges/` whose entire purpose is to connect the verified valuation-depth invariant from the p-adic computation files to a minimal tropical cost language on `WithBot ℕ`. Do not introduce any search-certificate, theory-morphism, category, or new object hierarchy infrastructure. Work locally and concretely.

Use the existing valuation-depth material as the foundation, preferably from the verified `Catalog/FINAL/` path if available, otherwise the corresponding computation file already used by the catalog. In the bridge file, define:

- `tropAdd : WithBot ℕ → WithBot ℕ → WithBot ℕ := max`
- `tropShift : WithBot ℕ → ℕ → WithBot ℕ`, where finite values are shifted by addition and `⊥` is fixed
- `costUnit : ℕ := 1`

Then prove a small, complete suite of lemmas with full proofs:

1. Pure tropical algebra lemmas on `WithBot ℕ`:
   - `tropAdd_comm`
   - `tropAdd_assoc`
   - `tropAdd_idem`
   - left/right identity behavior with `⊥` under `tropAdd`
   - `tropShift_bot`
   - `tropShift_zero`
   - `tropShift_add`
   - monotonicity of `tropAdd` in each argument
   - monotonicity of `tropShift`

2. Bridge lemmas from valuation depth to tropical cost, using the exact theorem names already available in the referenced valuation-depth file:
   - the depth of a sum is bounded by `tropAdd` of the two depths
   - multiplying by the distinguished uniformizer/prime increases depth by one, expressed as `tropShift depth costUnit`

3. If and only if the existing API already contains list/tree depth combination lemmas, add corollaries showing that a fold using `tropAdd` gives an upper bound for the depth of the corresponding list/tree combination. Do not invent new recursive structures unless they are already present and verified.

Implementation requirements:
- No placeholders, no `sorry`, no incomplete declarations.
- Keep the file self-contained and short.
- Reuse existing theorems rather than reproving valuation facts from scratch.
- If theorem names differ from expectation, adapt to the real API instead of adding speculative declarations.
- Prefer theorem statements that are immediately checkable and finishable from the imported files.

The final artifact should be a polished formalization of a local tropicalization bridge for valuation depth, not a framework for future bridges.