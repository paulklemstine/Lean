Work in the exact representation already provided by `Catalog/Applications/PoincareData/MetricFiltration.lean`; do not introduce a new graph model unless absolutely necessary. Your task is to produce a small, type-checking Lean file that proves additive interleaving stability for the existing threshold/Rips graph construction on a finite vertex type.

Target a finite type `α` with `[Fintype α] [DecidableEq α]`, dissimilarity functions `d d' : α → α → ℝ`, and a constant `c : ℝ`. Assume the pointwise additive comparison
`hclose : ∀ x y, d x y ≤ d' x y + c`.

Follow this theorem plan, adapting names to the exact API in `MetricFiltration.lean`:

1. Prove a threshold-shift inclusion lemma for the underlying edge predicate / graph object. The intended mathematical statement is:
`∀ ε, RipsGraph d' ε ≤ RipsGraph d (ε + c)`
or, if graphs are represented as sets/subtypes/Finsets of edges,
`∀ ε, RipsGraph d' ε ⊆ RipsGraph d (ε + c)`.
The proof should be a direct inequality chase from `hclose`. Use the existing graph definition exactly; if adjacency requires both `d x y ≤ ε` and `d y x ≤ ε`, apply `hclose` twice.

2. Derive edge-count monotonicity from that inclusion:
`∀ ε, edgeCount (RipsGraph d' ε) ≤ edgeCount (RipsGraph d (ε + c))`.
Do this via the existing finite-set/cardinality lemmas already available for the representation in the catalog. Avoid creating bespoke combinatorial infrastructure if a cardinality monotonicity lemma already exists.

3. Only if supported cleanly by existing lemmas in the catalog, define the shifted profile
`shiftedProfile (ε : ℝ) := edgeCount (RipsGraph d (ε + c))`
and prove its `max`-preservation property in the concrete form
`shiftedProfile (max ε₁ ε₂) = max (shiftedProfile ε₁) (shiftedProfile ε₂)`.
This should rely on an already-established fact that the unshifted edge-count profile is `max`-preserving. If such a lemma is not present or would require substantial new abstraction, omit this step and instead finish with a clean file containing only steps (1) and (2).

4. Keep the file self-contained and robust:
- import only the relevant catalog files;
- use existing names and structures from `MetricFiltration.lean`;
- do not leave any `sorry`;
- remove any unrelated theorem fragments or custom tropical machinery.

If the exact name `RipsGraph` is different in the catalog, search the existing API and restate the theorem using the canonical object already defined there. The final result should be a precise, compilable stability theorem for metric/dissimilarity filtrations, not a speculative bridge theorem.

Deliver a standalone Lean file with concise module documentation stating the assumptions and the proved theorems.