Build a single coherent Lean 4 file that completes the partial Rips-profile program in the most conservative way compatible with the existing partial development. Follow the actual cycle theme: finite metric spaces, Vietoris–Rips graphs, and functorial domination. Do not introduce information geometry, tropical abstractions, or any unrelated scaffold.

Primary goal: formalize a small theorem package around edge counts of finite Vietoris–Rips graphs.

Work from the existing partial files `Core.lean` and `Functoriality.lean` if present, and from the strongest verified catalog foundations in `Catalog/FINAL/` that define finite metric/Vietoris–Rips graph objects. Prefer reusing an existing `ripsGraph` and its edge set rather than rebuilding graph theory from scratch.

Target definitions:
1. Define `edgeCount` for a finite metric space at threshold `r` as the number of unordered pairs `{x,y}` with `x ≠ y` and `dist x y ≤ r`. Implement it in the simplest way supported by the existing API, ideally as the cardinality of the edge set of `ripsGraph`.
2. Define `ripsProfile` as the threshold-indexed function `r ↦ edgeCount r`. Keep the codomain as `ℕ` unless there is a compelling pre-existing reason to use `ℝ`.

Target theorems (all fully proved, no placeholders):
1. Monotonicity: if `r ≤ s`, then `edgeCount r ≤ edgeCount s`, hence `ripsProfile` is monotone.
2. Functorial edge preservation: an injective nonexpanding map sends every Rips edge at threshold `r` to a Rips edge at threshold `r` in the codomain.
3. Functorial domination: under an injective nonexpanding map, `edgeCount` of the domain is bounded above by `edgeCount` of the codomain at every threshold.

Packaging guidance:
- If there is already a notion of morphism/nonexpanding map in the catalog, use it. Otherwise state the theorem directly for a function `f : α → β` satisfying injectivity and `dist (f x) (f y) ≤ dist x y`.
- Prove domination by constructing an injection on edge witnesses or on the edge set, whichever is better supported by the existing library.
- Keep the entire file finite/combinatorial. Avoid ambitious statements about step discontinuities, realized distance spectra, or interval constancy unless they are directly supported by the current API and can be completed cleanly.

Deliverable requirements:
- Produce one standalone Lean file with complete theorem statements and proofs.
- Remove or omit any theorem headers that cannot be completed.
- Prefer a small finished result over a broad partial development.
- Include short module-level documentation explaining the definitions and the three main results.

Mathematical intent:
The key insight is that the Vietoris–Rips edge-count profile is not just monotone but functorially controlled by injective nonexpanding maps, giving a concrete invariant of finite metric spaces that can be compared algorithmically across embeddings. Why now? The current cycle already has partial `Core.lean` and `Functoriality.lean` files and likely existing Rips graph infrastructure, so the tractable next step is to finish this narrow theorem package completely rather than attempt a larger but unfinished step-structure theory.