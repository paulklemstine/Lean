# Summary of changes for run bce3508c-8c37-4da7-aaaa-d1e7860f2fa2
## What was delivered

This research cycle extended the Kripke-semantic core of Gödel–Löb provability logic (`Catalog/Logic/GLKripke.lean`, `Catalog/Logic/PolymodalGL.lean`) in two of the previously-flagged open directions, producing 6 fully proved theorems (sorry = 0, only standard axioms `propext`/`Classical.choice`/`Quot.sound`).

### New Lean files (under `Catalog/Logic/`)
1. **`GLProductBox.lean`** — "Box does not factor" (Direction 2: the categorical obstruction).
   - `GLFrame.prod_box_rectangle_subset`: `(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)` always holds.
   - `GLFrame.prod_box_rectangle_of_edgeless`: equality is recovered exactly when both factor frames are edgeless.
   - `GLFrame.prod_box_not_factor`: an explicit `Bool`/`Unit` witness making the inclusion **strict** — box genuinely fails to factor, unlike `prod_diamond_rectangle`.
   - **Correction to the prior cycle:** Direction 2 had conjectured the criterion was *seriality*, but a serial GL frame is empty (converse well-foundedness always yields a dead end), so the correct criterion is *edge-freeness*. This is documented in the file and lab notebook.

2. **`GLRankStratification.lean`** — quantitative Löb / rank stratification (Direction 4).
   - `GLFrame.boxSet_empty_eq_maximal`: `□∅` = the dead-end worlds.
   - `GLFrame.rank_eq_zero_iff_maximal`: `rank w = 0 ↔ IsMaximal w`.
   - `GLFrame.boxSet_iterate_eq_rank_lt`: `□^k ∅ = { w | rank w < k }` for **every** GL frame, generalizing the single-frame computation `natBox^[k] ∅ = Iio k` from `LobNatModel.lean` and identifying consistency strength with ordinal rank.

3. **`ProvabilityLogic.lean`** (infrastructure repair) — the project shipped with a dangling `import Logic.ProvabilityLogic` and an undefined `ProvabilityLattice` in `GLKripke.lean`, which prevented the entire GL chain from building. I restored the missing file with a faithful bundled `ProvabilityLattice` (a Heyting algebra carrier with a `GLOperator` box), so the catalog compiles again.

Each `.lean` file contains the required `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) and per-theorem `-- !-- ... -- !--` proof sketches.

### FUTURE_DIRECTIONS.md
A narrative file with a Synthesis, Results Summary, and 5 falsifiable research directions (exact factorization iff; rank = longest-chain length; functoriality of rank under products and p-morphisms; an ε₀-valued rank for infinite ordinal-indexed frames; a tropical cost semantics), each containing a "The key insight is…" sentence and a "Why now?" justification.

### Build/infrastructure note
The project had a nested layout mismatch (sources under `Catalog/` but the top-level lakefile expecting them at the root). I added `srcDir = "Catalog"` to the root `lakefile.toml` so the project builds and the proof tooling resolves the `Logic.*` modules. All new modules build successfully with no remaining sorries.