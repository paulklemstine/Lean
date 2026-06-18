Formalize a compact, fully proved Lean 4 development that extracts a tropical-style valuation/profile from combinatorial-species exponential generating functions on finite truncations. Stay entirely within the species/EGF algebra already present in the catalog, and avoid unrelated excursions into ultrametrics, Gaussian integers, or Pythagorean trees.

Problem focus:
Build a file proving precise order-of-vanishing and finite-degree laws for coefficient sequences arising from species EGFs. Work with finitely supported coefficient functions or explicit truncations, so every definition is computable and all proofs can be completed cleanly.

Required mathematical content:
1. Define a notion `ord` for a coefficient sequence `f : ℕ → ℚ` with finite support (or for a truncated polynomial/series representation): the least `n` such that `f n ≠ 0`, with a conventional value for the zero sequence.
2. Define a notion `deg` for finite support: the greatest `n` such that `f n ≠ 0`, again with a conventional value for the zero sequence.
3. Define the Cauchy product/convolution profile needed for EGF multiplication, reusing existing catalog lemmas whenever possible.
4. Prove the tropical-style inequalities:
   - `ord (f + g) ≥ min (ord f) (ord g)`
   - `deg (f + g) ≤ max (deg f) (deg g)`
5. Prove multiplicative laws under explicit non-cancellation hypotheses:
   - if the leading nonzero coefficients at `ord f` and `ord g` are nonzero in the needed sense, then `ord (f * g) = ord f + ord g`
   - if the top-degree coefficients are nonzero in the needed sense, then `deg (f * g) = deg f + deg g`
6. Connect these laws to the existing EGF/species API by proving analogous statements for the coefficient sequences attached to species constructions already in the catalog, using `egf_add`, `egf_mul`, and convolution lemmas.
7. Include at least one explicit worked species example on truncations, showing the profile computation concretely.

Implementation guidance:
- Keep the file small and self-contained.
- Prefer finite-support data structures already convenient in mathlib or simple predicates over elaborate new abstractions.
- If equality statements need hypotheses to avoid cancellation, state those hypotheses explicitly and prove the strongest clean theorem that is easy to reuse.
- If a fully general species statement is awkward, first prove sequence-level lemmas and then derive species corollaries as wrappers.
- Do not leave placeholders, omitted theorem bodies, or speculative declarations.

Deliverable shape:
Produce one coherent Lean file with complete proofs. The result should read as a finished bridge from combinatorial species EGF algebra to a min-plus/max-plus coefficient profile, not as an inventory of possible future theorems.