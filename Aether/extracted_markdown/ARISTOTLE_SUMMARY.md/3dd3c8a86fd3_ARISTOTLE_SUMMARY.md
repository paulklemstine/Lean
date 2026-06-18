# Summary of changes for run 43444620-5016-4cc3-aa01-8c41a1df0b00
Completed the linear-order Boltzmann expectation development in `Catalog/Probability/SpeciesBoltzmannBridge.lean`.

The referenced file did not exist anywhere in the project, so I created it at the specified path (`Catalog/Probability/SpeciesBoltzmannBridge.lean`) and filled in the full intended dependency chain for the linear-order species (where `|L[n]| = n!`, giving labelled Boltzmann weight `xⁿ`). No other files were touched and no auxiliary files were added.

Definitions:
- `boltzmannWeight x n = xⁿ`, `partitionFunction x = ∑' n, xⁿ`, `boltzmannPMF x n = boltzmannWeight x n / partitionFunction x`, `expectedSize x = ∑' n, n · boltzmannPMF x n`.

Theorems proved (no `sorry`, axioms limited to `propext`, `Classical.choice`, `Quot.sound`):
- `linearOrder_partitionFunction_eq` — for `0 ≤ x < 1`, `partitionFunction x = (1 - x)⁻¹` (geometric series, via `tsum_geometric_of_lt_one`).
- `linearOrder_firstMoment_eq` — for `|x| < 1`, `∑' n, n · xⁿ = x / (1 - x)²` (via Mathlib's `tsum_coe_mul_geometric_of_norm_lt_one`).
- `boltzmannPMF_eq` — closed form `p x n = (1 - x) · xⁿ`.
- `boltzmannPMF_tsum_eq_one` — the mass function is a genuine PMF (total mass 1).
- `linearOrder_boltzmann_expectedSize_eq` (main result) — for `0 ≤ x < 1`, `expectedSize x = x / (1 - x)`, obtained as the normalized first moment `(1 - x) · (x / (1 - x)²)`.

The proofs were cleaned up (explicit lemma applications instead of leftover search tactics, restored docstrings) and verified to elaborate with no remaining placeholders.