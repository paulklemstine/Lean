# Summary of changes for run 3f405a6b-68a0-49fc-9b0b-319c9d53737c
Created a self-contained Lean 4 formalization of the black hole information paradox as a theorem about unitary evolution.

**New file:** `Physics/HawkingInformation.lean` — builds cleanly (`lake build Physics.HawkingInformation`), zero `sorry`, all results depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

The development reduces the paradox to a single primitive: an evolution operator `U` on a finite-dimensional Hilbert space is unitary iff `Uᴴ * U = 1`. From this it proves 8 theorems:
- `unitary_recovery` — the adjoint decodes the Hawking radiation back to the infalling state.
- `unitary_preserves_information` — unitary evaporation is injective (no information loss).
- `information_loss_implies_nonunitary` — any information-destroying evolution cannot be unitary (the paradox: thermal/non-injective evaporation violates quantum mechanics).
- `unitary_iff_recoverable` — the dichotomy: unitarity ⇔ universal recoverability.
- `unitary_conj_recovery`, `unitary_conj_preserves_trace` — the mixed-state (density-matrix) evaporation channel `ρ ↦ U ρ Uᴴ` is reversible and conserves total probability.
- `swap_isUnitary`, `swap_recovery`, `swap_selfInverse` — an explicit 2-qubit toy black hole (the SWAP gate) evaporating unitarily with exact recovery of the infalling state from the radiation.

Each theorem carries a brief `-- !-- ... -- !--` proof sketch, and the file includes a `-- !-- Lab Notebook -- !--` block (Hypothesis/Result/Insight/Failure analysis) plus a catalog-synthesis note relating the work to `Physics/HolevoCapacity.lean` and `Physics/StabilizerBounds.lean`.

**FUTURE_DIRECTIONS.md** (`Physics/FUTURE_DIRECTIONS.md`) gives a Synthesis, Results Summary, and 5 falsifiable research directions (inner-product/no-cloning bridge, entropy invariance & the Page curve, partial trace & subsystem information flow, uniqueness of the decoder, and the evaporation semigroup), each with a "key insight" and "Why now?" justification.

Note: the project's pre-existing default build target fails due to an unrelated missing file (`Algebra/Jacobian/Defs.lean`) referenced in the manifest; the new module was therefore built and verified directly by its module name.