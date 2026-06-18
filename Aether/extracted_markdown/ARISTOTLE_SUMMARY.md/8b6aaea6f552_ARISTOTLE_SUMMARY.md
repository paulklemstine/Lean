# Summary of changes for run 7edbdfc4-278b-411f-980b-3d97066096e1
Added a new self-contained Lean development formalizing the black hole information paradox, plus a research-directions file.

**New file:** `Catalog/Physics/HawkingInformationParadox.lean` — builds cleanly with **0 sorries** (only standard axioms `propext`, `Classical.choice`, `Quot.sound`).

It formalizes the paradox as a precise dichotomy about quantum (unitary) evolution and backs it with a concrete 2-qubit toy model:

Abstract theory (finite-dimensional complex Hilbert space `H`):
- `norm_preserving_injective` — a norm-preserving (unitary) evolution is injective: no two distinct in-states collapse.
- `injective_recoverable` — an injective evolution admits a linear left-inverse recovery map.
- `unitary_preserves_information` — unitary evaporation `E` admits a recovery map `R` with `R (E ψ) = ψ` for every state: information is preserved.
- `information_loss_violates_unitarity` — if two distinct in-states map to the same out-state, `E` cannot be norm-preserving (quantum mechanics is violated).
- `recoverable_iff_information_preserved` — the paradox as an iff: in-state recoverability ⇔ injectivity (information preservation).

2-qubit SWAP toy model on `EuclideanSpace ℂ (Fin 4)`:
- `evapU` — the evaporation unitary (SWAP of the black-hole and radiation qubits) as a genuine `LinearIsometryEquiv`.
- `recover_evaporate` — applying the inverse channel recovers the initial state exactly.
- `evapU_preserves_overlap` — all overlaps/fidelities are preserved.
- `evapU_no_information_loss` and `evapU_recoverable` — distinctness is preserved and an explicit recovery map exists (instantiating the abstract theorem).

Each theorem carries a one–two sentence proof sketch as a comment, and the docstring connects the work to existing catalog results (Landauer entropy defect, Holevo capacity, mutual information): the non-unitary horn is exactly an entropy-defect/erasure phenomenon.

**New file:** `Catalog/Physics/FUTURE_DIRECTIONS.md` — five falsifiable conjectures (Page curve from unitarity, quantitative no-cloning vs. complementarity, channel entropy-defect bridge to Landauer, Knill–Laflamme mixed-state recovery, strict monogamy/firewall inequality), each with a "key insight" and "Why now?" justification.

**Build configuration fix:** `lakefile.toml` was missing `srcDir = "Catalog"`, so module names like `Physics.X` did not resolve to the files under `Catalog/Physics/`. I added that line, which is the intended configuration and required for the catalog to build; the new module compiles via `Physics.HawkingInformationParadox`.