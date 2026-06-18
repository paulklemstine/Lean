# Summary of changes for run 8e3054ad-df47-49f5-9e5f-047f16f80340
Added a new, fully-compiling Lean 4 development on the deterministic backbone of derivability phase transitions, plus its research roadmap.

**New files**
- `Catalog/Computation/ProofPhaseTransitions.lean` — self-contained theory built on `Relation.ReflTransGen`.
- `Catalog/Computation/FUTURE_DIRECTIONS.md` — five falsifiable conjectures (each with a "key insight" and "Why now?"), driving the next cycle.

**What is proved (no `sorry` on any result; verified by a full module build)**
- `derivable_mono` / `ederiv_mono` / `ederiv_upward_closed`: derivability is monotone in the axiom set — i.e. on finite edge sets `E ↦ EDeriv E src tgt` is a genuine monotone Boolean function (the exact hypothesis of Friedgut's sharp-threshold theorem).
- `closed_preserved` and `barrier_not_derivable`: the barrier method — a set closed under the theory, containing the source and excluding the target, certifies non-derivability (stated for arbitrary relations, so it lifts to richer settings).
- `chain_derivable` and `chain_card`: the length-`n` chain theory derives `0 ⟶ n` using exactly `n` axioms (minimal density).
- `chain_edge_critical` and `chain_minimal_certificate` (the headline result): the chain is a minimal certificate — it derives `0 ⟶ n` yet deleting any single axiom breaks the derivation, placing it exactly on the boundary of the monotone derivability property.
- Boundary cases: `redundant_edge_not_critical` shows that a redundant shortcut axiom destroys criticality (so minimality is essential), and `empty_not_derivable` shows the empty theory derives nothing between distinct atoms.
- A stated research target (Friedgut's probabilistic sharp threshold) is recorded with its already-discharged monotonicity hypothesis; it is a placeholder, not a `sorry`.

Each theorem carries a one–two sentence proof sketch in `-- !-- ... -- !--` comments, and the file ends with worked `example` blocks.

**Build configuration fix**: the package `lakefile.toml` was missing `srcDir = "Catalog"`, so modules under `Catalog/` (which already use imports like `Computation.TropicalLife.Basic`) did not resolve. I added `srcDir = "Catalog"` so the project's modules resolve correctly; the new module compiles successfully.