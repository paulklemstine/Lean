# Summary of changes for run 502025b3-89d2-4fcc-99be-7292eaadcd55
Added a new Lean development that extends the existing chain-model file `Catalog/Speculative/AutoResearch/ProteinFolding.lean` into structural laws of the topological-energy theory of protein folding.

## New file: `Catalog/Speculative/AutoResearch/ProteinFoldingGeneralized.lean`
Builds cleanly (verified against the `Catalog` project) with **zero `sorry`** and no warnings. It reuses the catalog foundations (`PersistenceBar`, `totalPersistence`, `Rips`, `H0LineBarcode`) rather than reproving them, and contributes seven fully-proved theorems (plus short proof sketches in `-- !-- … -- !--` blocks):

1. `Rips_scale` — exact scaling symmetry of the Vietoris–Rips contact filtration: `Rips (c·d) (c·t) = Rips d t` for `c > 0` (upgrades the catalog's `Rips_mono` from monotonicity to a symmetry).
2. `totalPersistence_scale` — the topological energy is homogeneous of degree one: scaling the molecule by `c ≥ 0` scales total persistence by `c`.
3. `ForestBarcode_totalPersistence` — elder rule for a *branched* fold: the H₀ total persistence of an arbitrary merge forest equals its total edge weight (generalizing the chain telescoping law from a path to any tree/forest).
4. `H0LineBarcode_eq_extent_via_forest` — recovers the original chain extent law as the path special case, confirming the generalization is faithful.
5. `totalPersistence_W1_stable` — Wasserstein-1 (matching) stability: the energy difference of any two barcodes under an arbitrary matching is bounded by the total matching cost (generalizing the chain `2ε` stability via `abs_add_le` and list induction).
6. `min_spanning_tree_lower_bound` — a minimum-weight spanning tree lower-bounds the energy of every spanning tree (the well-posedness half of the native-fold optimization).
7. `totalPersistence_not_scale_invariant` — boundary witness showing the homogeneity is genuinely degree-one (a `(0,1)` bar rescales from energy 1 to 2), establishing necessity of the scaling factor.

## New file: `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md`
Five testable, falsifiable conjectures extending the work (MST optimality of the H₀ barcode; sharpness of the W1-stability bound; isolation of the native minimizer via homogeneity; an H₁ hydrophobic-core signature; and diameter/entrywise compaction monotonicity). Each includes a "The key insight is…" sentence, a "Why now?" justification, and a concrete refutation test.

Only the two new files were added; no other project files were modified.