Repair `Catalog/Probability/SpeciesBoltzmannBridge.lean` only. Do not create new files, do not edit other domains, and do not pivot to a new topic. This is a tightly scoped `sorry_fill` task.

Objective: remove the remaining `sorry`s required to complete the linear-order Boltzmann expectation theorem already intended in this file.

Required proof plan:
1. Identify the existing definitions and target theorem for the linear-order species partition function / Boltzmann normalization / expectation.
2. Prove the reusable closed form for the partition function of linear orders:
   - a theorem of the form `∑' n : ℕ, x^n = (1 - x)⁻¹` or the exact equivalent already present in the file,
   - using only the hypotheses already assumed there (typically `|x| < 1`, `x ≠ 1`, or a real/ENNReal variant).
3. Prove the first-moment series identity needed for expectation:
   - a theorem of the form `∑' n : ℕ, (n : ℝ) * x^n = x / (1 - x)^2` or the exact typed variant used in the file,
   - preferably by invoking existing Mathlib geometric-series / power-series derivative lemmas if available, otherwise by a short internal derivation compatible with the file’s current imports.
4. Combine these to discharge the expectation theorem for the Boltzmann size random variable of the linear-order species:
   - expectation = normalized first moment,
   - simplify algebraically to `x / (1 - x)` (or the exact codomain/type already used in the file).

Constraints:
- Modify only `Catalog/Probability/SpeciesBoltzmannBridge.lean`.
- Preserve existing theorem names and API wherever possible.
- Do not add unrelated lemmas or general infrastructure unless directly necessary for this dependency chain.
- Remove every `sorry` that blocks the linear-order expectation result in that file.
- If there are multiple `sorry`s in the file unrelated to this chain, do not expand scope unnecessarily; focus on those needed to complete the target theorem.

Implementation guidance:
- Prefer existing Mathlib lemmas for `tsum_geometric_of_norm_lt_1`, geometric-series manipulations, and scalar/algebraic simplification.
- Be careful about coercions `ℕ → ℝ` (or other codomain) in the first-moment sum.
- If the file uses probability-mass-function normalization, prove the raw series identities first and then rewrite into the PMF expectation statement.
- At the end, ensure the target theorem is fully proved and no placeholder remains on the dependency chain.

Deliverable: an updated `Catalog/Probability/SpeciesBoltzmannBridge.lean` with the relevant `sorry`s eliminated and the linear-order Boltzmann expectation theorem completed.