Repair `Catalog/Probability/SpeciesBoltzmannBridge.lean` and nothing else. The previous attempt failed because it ignored the target file and created an unrelated algebra file. Your task is a strict `sorry_fill` pass focused on the existing Boltzmann/species development for linear orders.

Primary goal:
- Eliminate the remaining `sorry` placeholders required to make `Catalog/Probability/SpeciesBoltzmannBridge.lean` compile cleanly.
- The main endpoint is the existing theorem `linOrderSpecies_boltzmann_mean` (use the exact statement already present in the file).

Required proof strategy:
1. Identify the exact linear-order partition-function lemma missing in the file and prove it first. This should express the linear-order species partition function in closed form, mathematically corresponding to the EGF/normalizing series `∑ n, x^n = 1 / (1 - x)` under the file’s existing assumptions.
2. Use that closed form to prove the intended explicit formula for the Boltzmann pmf of the linear-order species. Do not redefine the distribution unless absolutely necessary; instead, rewrite the existing definition.
3. Prove `linOrderSpecies_boltzmann_mean` by reducing the expectation sum to the standard series identity for `∑ n, n * x^n`, i.e. the geometric-derivative formula giving `x / (1 - x)^2`, and then dividing by the partition function if that is how the file defines the expectation.

Constraints:
- Stay inside `Catalog/Probability/SpeciesBoltzmannBridge.lean`.
- Do not create a new research direction, new domain, or unrelated theorems.
- Preserve existing names, statements, and types whenever possible.
- Prefer using already available Mathlib summation/power-series lemmas over ad hoc reproving, but if a tiny helper lemma is missing, add a local lemma with a short proof.
- If coercions between `ℕ`, `ℝ`, `NNReal`, and `ENNReal` are the source of difficulty, solve them minimally and explicitly; do not refactor the whole file.
- Avoid broad API changes. The deliverable is a compiling repaired file, not a redesign.

Concrete checklist before finishing:
- Search for every `sorry` in `Catalog/Probability/SpeciesBoltzmannBridge.lean` and remove it.
- Ensure the proof chain `boltzmannPartition_linearOrderSpecies` -> `boltzmannPMF_linearOrderSpecies` -> `linOrderSpecies_boltzmann_mean` (or the file’s exact analogous theorem names) is complete.
- Run through any needed `simp`, `ring`, `field_simp`, `norm_num`, `summable_geometric_of_abs_lt_1`, `tsum_geometric_of_abs_lt_1`, or derivative-of-geometric-series lemmas already in Mathlib.
- If the final expectation theorem depends on an auxiliary identity not yet named, add that auxiliary lemma in the same file and use it immediately.

Output expectation:
- Return the repaired Lean code for `Catalog/Probability/SpeciesBoltzmannBridge.lean` only.
- The file must compile with no `sorry`s.