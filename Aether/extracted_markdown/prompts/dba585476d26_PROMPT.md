Build a complete Lean 4 formalization of the higher-dimensional completion threshold for Vietoris–Rips complexes, but keep the scope tightly reduced to statements that can be discharged from existing catalog infrastructure.

Target file: `Catalog/Geometry/RipsCliqueCompletion.lean`

Primary references to build on:
- `Catalog/FINAL/Bridges/RipsTropicalCompletion.lean`
- `Catalog/FINAL/Applications/PoincareData/MetricFiltration.lean`
- any existing file defining `cliqueComplex` / flag complexes and the metric Rips graph API

Precise task:
1. Define or reuse a notion `fullComplex` for the simplicial complex on vertex type `α` whose faces are all finite subsets allowed by the ambient complex API.
2. Prove a graph-theoretic lemma of the form
   `cliqueComplex G = fullComplex ↔ G = ⊤`
   or an equivalent extensional reformulation that matches the existing graph representation. If equality to `⊤` is awkward, prove the pair of implications through the statement that every pair of distinct vertices is adjacent.
3. Specialize this to the Vietoris–Rips graph attached to a metric/pseudometric finite space, using the verified dictionary in `MetricFiltration` to identify the graph underlying the Vietoris–Rips complex with the usual Rips graph/clique complex construction.
4. Invoke the existing theorem from `RipsTropicalCompletion` giving graph completeness at scale `ε` iff `tropBirthSum α ≤ ε`.
5. Derive the main theorem:
   `vietorisRips ε = fullComplex ↔ tropBirthSum α ≤ ε`
   with hypotheses exactly matching the strongest already verified theorem.

Important constraints:
- Do not introduce a large new abstraction layer for simplicial complexes.
- Prefer theorem statements that are definitionally close to existing APIs, even if less elegant.
- Avoid speculative lemmas about “top simplex birth time” unless they are immediate corollaries of the full-complex theorem.
- Only include a facewise membership theorem if it can be proved directly from an existing membership characterization for clique complexes or Vietoris–Rips complexes; otherwise omit it.
- The deliverable must be fully proved, with no `sorry`.

Suggested proof strategy:
- First prove the purely combinatorial `cliqueComplex_eq_full_iff` by extensionality on faces. For the forward direction, use that every 2-element set is a face in the full complex, hence an edge in the graph. For the reverse direction, use completeness of the graph to show every finite set is a clique.
- Then transport along the existing equivalence between Vietoris–Rips complexes and clique complexes of the Rips graph from `MetricFiltration`.
- Finish by rewriting with the verified threshold characterization from `RipsTropicalCompletion`.

If you discover that exact equality `cliqueComplex G = fullComplex` is cumbersome in the existing API, downgrade to a pair of theorems that together imply it:
- every finite set is a face of `cliqueComplex G` iff every pair of distinct vertices in that set is adjacent;
- `cliqueComplex G` contains every finite set iff `G` is complete.
Then package the final Vietoris–Rips threshold theorem using those formulations.

The output should be a finished Lean file with concise module documentation and theorem names aligned with existing catalog conventions.