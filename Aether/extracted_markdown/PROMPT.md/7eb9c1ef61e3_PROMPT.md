Formalize a finite, fully checked bridge theorem between metric filtrations and tropical ultrametrics, staying close to the original direction but narrowing to the part most likely to compile cleanly.

Target file: `Catalog/Bridges/MetricFiltrationTropicalProfile.lean`.

Work in the following setting:
- `α` is a finite type with `[Fintype α] [DecidableEq α]`.
- `d : α -> α -> ℝ` is a pseudometric-like distance already compatible with the Rips graph API in `Applications/PoincareData/MetricFiltration.lean`.
- Use the existing `ripsGraph` construction and its monotonicity theorem `ripsGraph_mono`.

Primary goal:
Define the connectivity threshold / merge scale
`connThreshold d x y : ℝ`
as the least scale at which `x` and `y` become path-connected in the Rips graph filtration, using finiteness to ensure the threshold is attained by a finite set of candidate edge lengths if needed. Prefer a concrete finite minimum construction over abstract `sInf` if that is easier to formalize.

Required deliverables only:
1. Define `ConnAt d ε x y` to mean that `x` and `y` are connected by a path in `ripsGraph d ε`.
2. Prove monotonicity: if `ε ≤ ε'` and `ConnAt d ε x y`, then `ConnAt d ε' x y`.
3. Prove the tropical/max composition law:
   if `ConnAt d a x y` and `ConnAt d b y z`, then `ConnAt d (max a b) x z`.
4. Define `connThreshold d x y` from `ConnAt` in a way that actually compiles in Lean for finite `α`.
5. Prove basic properties:
   - `connThreshold d x x = 0` if this follows cleanly from the chosen setup, otherwise prove `ConnAt d 0 x x` and derive the weakest usable reflexive bound.
   - symmetry: `connThreshold d x y = connThreshold d y x`.
   - subdominance: `connThreshold d x y ≤ d x y`.
   - strong triangle inequality: `connThreshold d x z ≤ max (connThreshold d x y) (connThreshold d y z)`.
6. Package the previous theorem as the statement that `connThreshold` is an ultrametric (or satisfies the strong triangle inequality in the exact sense available in the catalog).

Important scope restrictions:
- Do NOT spend effort on connected-component counts, rank profiles, Betti-style summaries, maximality among ultrametrics below `d`, idempotence, dendrogram equivalence, or categorical universal properties unless all core threshold results are already complete and easy.
- Do NOT leave theorem statements without complete proof terms.
- Prefer smaller helper lemmas about paths in monotone graph filtrations over sweeping abstractions.
- If an exact theorem from the original concept becomes awkward because of API mismatch, weaken it to the strongest fully provable finite statement and document that in comments.

Suggested proof strategy:
- Express `ConnAt` using the graph connectivity/path API already available for `SimpleGraph`.
- Use `ripsGraph_mono` to transport paths/connectivity upward in scale.
- For the tropical law, concatenate paths after lifting both to `max a b`.
- For `connThreshold ≤ d x y`, use the direct edge `(x,y)` present at scale `d x y`.
- For the strong triangle inequality, show connectivity at `max (connThreshold d x y) (connThreshold d y z)` by monotonicity from the witnessing thresholds and then pass to the minimality property of `connThreshold`.
- If infimum-based definitions are cumbersome, define the threshold as the minimum of a finite set of scales that witness connectivity, and prove the needed specification lemma `ConnAt d (connThreshold d x y) x y` plus minimality.

Output expectations:
- Produce a standalone Lean file with complete code and no `sorry`.
- Include concise module documentation explaining that the file formalizes the single-linkage/minimax ultrametric extracted from the Rips graph filtration.
- State clearly in comments which stronger claims from the earlier attempt were intentionally deferred.

This is a formalization task, not an exploratory essay: prioritize a smaller theorem package that fully verifies.