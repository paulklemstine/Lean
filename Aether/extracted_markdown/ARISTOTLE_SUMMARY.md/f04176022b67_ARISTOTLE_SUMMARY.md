# Summary of changes for run 00fa9667-38f6-4e26-9730-60f58b0046b9
Created `Catalog/Bridges/MetricFiltrationTropicalProfile.lean`, a standalone, fully verified file (no `sorry`, only standard axioms `propext`/`Classical.choice`/`Quot.sound`) formalizing the single-linkage / minimax ultrametric extracted from the Rips graph filtration.

It imports and reuses the existing `ripsGraph` / `ripsGraph_mono` API from `Catalog/Applications/PoincareData/MetricFiltration.lean`, and works over `{α : Type*} [PseudoMetricSpace α]` with `[Fintype α]` added exactly where finiteness is needed.

Deliverables, all proved:
1. `ConnAt ε x y` := `(ripsGraph α ε).Reachable x y` (path-connectivity at a scale), with `refl`/`symm`/`trans` helpers.
2. `ConnAt.mono` — monotonicity in the scale (via `ripsGraph_mono` and `Reachable.mono`).
3. `ConnAt.max_comp` — the tropical/max composition law (lift both paths to `max a b`, then concatenate).
4. `connThreshold x y` — defined concretely as `Finset.min'` over the finite `candidateScales = {0} ∪ {dist x y}`, with attainment (`connThreshold_spec`) and minimality (`connThreshold_le_of_connAt`) lemmas, exactly the finite-minimum construction preferred over abstract `sInf`.
5. Basic properties: `connThreshold_self` (`= 0`), `connThreshold_comm` (symmetry), `connThreshold_le_dist` (subdominance), and `connThreshold_strong_triangle` (the strong/ultrametric triangle inequality).
6. `connThreshold_isUltrametric` — packages non-negativity, self-distance zero, symmetry, and the strong triangle inequality as the ultrametric statement.

Faithfulness/adaptation notes (documented in the file's module comment): the informal distance `d` is the ambient `dist` of the `PseudoMetricSpace`, since the existing Rips API is phrased via `dist`; `DecidableEq α` is replaced by `open Classical`. Per the scope restrictions, component counts, rank/Betti profiles, maximal sub-dominant ultrametric, idempotence, dendrogram equivalence, and categorical universal properties are intentionally deferred and noted as such in comments.

Verification: the file compiles with `lean` (exit 0, no warnings) and axiom checks on the main theorems report only the allowed standard axioms. (Note: the project's `lakefile.toml` default targets are pre-existing-misconfigured — their library globs point at root directories that do not exist — so files under `Catalog/` are compiled directly rather than via the default `lake build` targets.)