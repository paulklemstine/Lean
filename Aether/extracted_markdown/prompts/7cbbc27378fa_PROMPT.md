Formalize a small, complete, and typechecked Lean 4 development around edge counts of Rips graphs, staying tightly aligned with the existing metric filtration API.

Target file: `Catalog/Applications/PoincareData/RipsEdgeValuation.lean`

Primary goal:
Build a minimal but finished formalization of the edge-count invariant of the Rips graph of a finite metric space, with proofs that are directly justified by existing lemmas in the catalog.

Required scope:
1. Import the precise existing files for the Rips graph / metric filtration framework and any finite graph/cardinality utilities actually needed.
2. Define
   `edgeCount (X) (t : ℝ) : ℕ := ...`
   as the number of edges of `ripsGraph X t`.
3. Prove monotonicity:
   if `s ≤ t`, then `edgeCount X s ≤ edgeCount X t`.
   This should be proved by combining the existing `ripsGraph_mono`-style theorem with whatever graph-edge-set inclusion/cardinality lemma is already available. If necessary, introduce a small helper lemma about finite set cardinalities under inclusion.
4. Prove vanishing at trivial thresholds only in the forms already supported by the API:
   - if there is a theorem like `ripsGraph_bot_of_metric`, use it to prove the corresponding `edgeCount = 0` result exactly at that threshold;
   - if there is a theorem for negative thresholds giving an empty/bottom graph, use it to prove `edgeCount X t = 0` for `t < 0`.
   Do not guess theorem names; inspect the imported files and use the exact available lemmas.
5. Package the invariant as a simple structure, e.g.
   `structure ValuationObject where toFun : ℝ → ℕ; monotone' : Monotone toFun`
   and define `edgeValuation X`.
6. Define discrete increments along an indexed family or finite list of thresholds in the simplest robust form. Prefer a definition that avoids unnecessary integer arithmetic if possible. For example, for an increasing finite sequence `ts : Fin (n+1) → ℝ`, define increments by adjacent differences in `ℤ` only if subtraction in `ℕ` is inconvenient. Then prove:
   - nonnegativity of increments under monotonicity;
   - a telescoping sum identity in a form that Lean can handle cleanly.
   Keep this modest: one clean theorem is better than a complicated unusable API.

Important constraints:
- Produce a complete file with no `sorry`, no placeholder theorem headers, and no unfinished proofs.
- Prefer fewer theorems with solid proofs over a broad but brittle interface.
- Do not include isometry/congruence invariance unless the exact supporting equivalence lemmas for `ripsGraph` already exist and are easy to apply.
- Do not oversell the result as tropical geometry; if desired, mention only that the invariant behaves like a monotone valuation/counting profile.
- Before proving anything, inspect the actual definitions and theorem names in the imported files so that the file compiles against the real API.

Suggested theorem set:
- `edgeCount_def` or just the definition
- `edgeCount_mono`
- `edgeCount_bot` and/or `edgeCount_neg` if supported by existing lemmas
- `ValuationObject`
- `edgeValuation`
- one increment definition
- one increment nonnegativity theorem
- one telescoping theorem

If the edge-count cardinality is awkward because the graph library represents edges in a quotient/sym2 form, adapt the statement to the most natural available finite cardinality notion in the API. The objective is a reusable, compilable invariant extracted from the Rips filtration.