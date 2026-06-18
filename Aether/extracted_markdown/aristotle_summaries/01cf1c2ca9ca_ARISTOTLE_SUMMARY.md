# Summary of changes for run a1435103-acfc-4e32-8428-dfe05649926f
## ML Universal Approximation: ReLU Width vs Depth Separation

I added a new, fully verified Lean development under `Catalog/MachineLearning/ReLUDepthWidth/`, plus a research roadmap.

### New file: `Catalog/MachineLearning/ReLUDepthWidth/Basic.lean`
A self-contained, axiom-clean formalization of ReLU depth separation via the tent map `tent x = 1 - |2x - 1|` (a width-2 one-hidden-layer ReLU block) and its `k`-fold composition `tent^[k]` (a depth-`k`, constant-width network). All theorems compile with **zero `sorry`** and depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Proven results:
- `tent_relu_repr` — the tent map is exactly a width-2 ReLU layer, `1 - relu(2x-1) - relu(1-2x)`.
- `tent_lipschitz` — the tent map is `2`-Lipschitz.
- `tent_mapsTo` — the tent map sends `[0,1]` into `[0,1]`.
- `tent_eq_two_mul` — on the ascending branch `x ≤ 1/2`, `tent x = 2x`.
- `tent_iterate_lipschitz` — the depth-`k` network `tent^[k]` is `2^k`-Lipschitz (Lipschitz constant grows exponentially with depth at constant width).
- `tent_iterate_zero` / `tent_iterate_peak` — `tent^[k]` climbs from `0` to `1` over an interval of width `2^{-k}`, the exponentially steep ramp.
- `relu_depth_separation` (the headline theorem) — any `K`-Lipschitz function with `K·2^{-k} + 2ε < 1` provably cannot approximate `tent^[k]` to accuracy `ε` on `[0,1]`. Since a bounded-weight shallow network is exactly such a Lipschitz function, matching a depth-`k` network forces its Lipschitz/width budget to grow like `2^k`.
- `relu_depth_separation_sharp` — shows the threshold `K·2^{-k} + 2ε < 1` is sharp (cannot be relaxed to `≤`).
- A worked `example` instantiating the separation at depth 3.

Each theorem carries a one–two sentence proof sketch in the requested `-- !-- … -- !--` format.

**Why non-trivial / novel:** This is the ReLU-native (piecewise-linear) form of depth separation — the output range stays bounded in `[0,1]` while the *local slope* (oscillation) blows up exponentially. This complements the catalog's existing exponential-tower result (`MachineLearning.DepthSeparation.Separation`, `not_uniformApprox_of_small_lipschitz`), where instead the *range* explodes. The docstrings cite that catalog result explicitly, and Future Direction #5 proposes unifying both under one abstract obstruction lemma.

### New file: `Catalog/MachineLearning/ReLUDepthWidth/FUTURE_DIRECTIONS.md`
Five testable, falsifiable research conjectures (each with a "The key insight is…" and a "Why now?" justification): (1) upgrading the Lipschitz obstruction to an exact oscillation/crossing-number width lower bound `w ≥ 2^k - 1`; (2) the matching constructive shallow `Θ(K/ε)` universal-approximation upper bound; (3) the higher-dimensional `[-1,1]^n` curse-of-dimensionality separation; (4) a robustness/adversarial reading of the same Lipschitz budget; and (5) a cross-domain bridge unifying the tent (slope-blowup) and exponential-tower (range-blowup) separations under a single inequality.

The module builds cleanly (verified with the project's Catalog lakefile).