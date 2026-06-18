# Summary of changes for run 33d19a42-2f7a-4a3f-a402-c6d7b80ea69a
Extended the proof-theoretic ordinal framework with a new, fully proved Lean file and a research roadmap, building on the existing `Catalog/Pythagorean/ProofTheoreticOrdinals.lean`.

## New file: `Catalog/Pythagorean/OrdinalQuasiMetric.lean`
Imports and builds on the existing `OrdinalTheory`, `OrdinalTheory.pto`, `OrdinalTheory.ofOrdinal`, and `depthDist`, settling the open geometric question left there: is the ordinal-valued separation `depthDist` a metric? Answer: it is a directed quasi-metric, not a metric. Eight theorems, all with complete proofs (no `sorry`; only standard axioms `propext`/`Classical.choice`/`Quot.sound`):

- `pto_ofOrdinal_succ` — the PTO of `ofOrdinal (α+1)` is exactly `α` (successor companion to the catalog's `pto_ofOrdinal_limit`).
- `ordinal_gap_additive` — for `x ≤ y ≤ z`, `(y−x)+(z−y) = z−x`.
- `depthDist_directed_additive` — when PTOs are linearly arranged, `depthDist T₁ T₃ = depthDist T₁ T₂ + depthDist T₂ T₃` (quasi-metric additivity).
- `depthDist_triangle_fails` — explicit triple (PTOs `ω+1, ω, 0`) strictly violating the symmetric triangle inequality, because `1 + ω = ω` absorbs the finite leg; turns the folklore non-commutativity obstruction into a theorem.
- `ofOrdinal_le_iff`, `ofOrdinal_lt_iff` — the principal theories order-embed the ordinals.
- `wellFounded_lt_ofOrdinal`, `ofOrdinal_totally_ordered` — principal theories are totally ordered and well-founded under strict inclusion (well-quasi-order, no infinite antichain).

Each theorem carries a short `-- !-- ... -- !--` proof sketch, and the docstring cites the catalog results it extends.

## `Catalog/Pythagorean/FUTURE_DIRECTIONS.md`
Five falsifiable conjectures, each with a "key insight" and "Why now?": (1) the exact additive-principal boundary of the triangle inequality, (2) a Hessenberg natural-sum metric repairing the obstruction, (3) the principal embedding as an initial order-isomorphism characterized by `T.pto ∉ T.provablyWO`, (4) antichain-freeness of all bounded theories, (5) fast-growing-hierarchy calibration of the directed distance.

## Build fix
The top-level `lakefile.toml` was missing `srcDir = "Catalog"`, so the source tree (under `Catalog/`) did not resolve from the project root; I added that line. The per-library `Catalog/lakefile.toml` is unchanged. The new module builds successfully and is sorry-free.