Finish the incomplete formalization in `Catalog/Probability/SpeciesBoltzmannBridge.lean` by removing the remaining `sorry` placeholders and verifying the entire file compiles. Treat this as a proof-repair and completion task, not a new theory-building task.

Primary goal:
- Prove the missing final theorem `linOrderSpecies_boltzmann_mean` (and any immediately necessary helper lemmas) in the exact framework already used by the file.

Mathematical scope:
- Work with the existing species/EGF/Boltzmann definitions already present in the catalog.
- Specialize to the species of linear orders, whose size counts are `n!`, so the Boltzmann weight should simplify to a geometric-type law with mass `(1 - x) * x^n` for `0 ≤ x < 1`.
- Use explicit hypotheses such as `0 ≤ x` and `x < 1` whenever needed for summability, normalization, and mean computations.

Recommended proof strategy:
1. Inspect the existing proof of the general mean theorem `boltzmannMean_eq` and the completed set-species/Poisson lemmas.
2. Add a clean closed-form lemma for the linear-order partition function if missing: the real-valued EGF evaluation is `∑' n, x^n = (1 - x)⁻¹` under `|x| < 1`, or an equivalent formulation already available in Mathlib.
3. Derive the normalized Boltzmann PMF for linear orders explicitly:
   `P(N = n) = (1 - x) * x^n` for `0 ≤ x < 1`.
4. Prove the expectation formula for this PMF, ideally by reusing:
   - the file’s general mean identity `boltzmannMean_eq`, together with the pointed-species/EGF calculation for linear orders, or
   - a standard geometric-series derivative identity from Mathlib if that is simpler.
5. Keep the development minimal: do not generalize beyond linear orders, do not refactor unrelated proofs, and do not introduce new probability interfaces unless strictly necessary.

Deliverables:
- A fully compiling `Catalog/Probability/SpeciesBoltzmannBridge.lean` with no `sorry`.
- If helper lemmas are needed, keep them local and tightly tied to the linear-order argument.
- Preserve the existing theorem names whenever possible, especially `linOrderSpecies_boltzmann_mean`.

Success criterion:
- The file builds cleanly and the final theorem gives the expected geometric-law mean in the exact normalization used by the existing Boltzmann framework.