Develop a single coherent Lean 4 file formalizing Eulerian trails in finite multigraphs and proving the Euler parity theorem. Do not mix in cryptography, torsors, Cayley graphs, or undeveloped placeholders. The target should be a complete, type-checking mathematical development.

Working context: build on the existing multigraph infrastructure already available in the catalog. Treat this as a formalization project, not a security proof. The previous attempt was partial because it introduced many declarations without complete statements or proofs. Your task is to finish a sharply scoped theorem pipeline.

Required scope:
1. Define `EulerianTrail` for a finite multigraph `G : Multigraph nV nE` as:
   - `vertices : Fin (nE + 1) → Fin nV`
   - `edgePerm : Equiv.Perm (Fin nE)`
   - `connects : ∀ i : Fin nE, let e := edgePerm i; (G.endpt₁ e = vertices i.castSucc ∧ G.endpt₂ e = vertices i.succ) ∨ (G.endpt₁ e = vertices i.succ ∧ G.endpt₂ e = vertices i.castSucc)`
   This encodes a walk that uses each edge exactly once.

2. Define the basic derived data:
   - `startVertex`, `endVertex`
   - a suitable notion of degree of a vertex in the multigraph, computed by counting incident edges via endpoints
   - a notion of how many times the trail visits a vertex. If the direct `visitCount` over all positions is awkward for the key identity, refine it into something easier to prove with, e.g. `internalVisitCount` counting indices `i : Fin nE` where the vertex is the shared endpoint between consecutive used edges, or count arrivals/departures separately. Choose the formulation that gives the cleanest parity proof.

3. Prove a local counting identity for every vertex `v`. A recommended form is:
   - for non-endpoints in an open Eulerian trail, every occurrence contributes degree in pairs;
   - for the start/end vertices, there is one unmatched incidence each unless the trail is closed.
   Concretely, aim for a theorem equivalent to one of the following:
   - `degree v = 2 * internalVisitCount v + endpointContribution v`
   - or `degree v + startIndicator v + endIndicator v = 2 * visitCount v`
   where indicators are `0/1` naturals. Use whichever statement is easiest to formalize cleanly.

4. Deduce the parity theorem:
   - `odd_degree_vertices_le_two` for any Eulerian trail
   - and a closed-trail corollary: if `startVertex = endVertex`, then every vertex has even degree.
   If convenient, formulate oddness using `Nat % 2 = 1` or `¬ Even (degree v)` depending on available lemmas.

5. Keep the development minimal and robust:
   - no `axiom`, `admit`, `sorry`, or theorem stubs
   - no speculative cryptographic statements
   - no unrelated side results unless they directly support the parity theorem
   - prefer helper lemmas about `Fin`, filtered `Finset.card`, and endpoint counting over over-engineered abstractions.

Suggested proof strategy:
- First define degree as the number of edges whose endpoint list contains `v` (with loops counted carefully according to the multigraph definition already in the catalog; if loops are present, make sure the degree convention is explicit and compatible with the parity theorem).
- Introduce a per-step incidence count showing each used edge contributes exactly two endpoint incidences across the trail.
- Partition incidences at a fixed vertex into paired internal occurrences plus possible unpaired start/end contributions.
- Convert the counting identity into a parity statement using `Nat` modular arithmetic.

Deliverable expectations:
- one complete Lean file in a coherent namespace, likely `Catalog/Bridges/EulerianTrail.lean`
- all theorem statements present and proved
- concise module docstring explaining definitions and main theorem
- if the existing `Multigraph` API forces a slightly different formulation, adapt the theorem statements to that API, but preserve the mathematical content above.

This is a formalize task. The goal is a polished, standalone graph-theoretic result that can later serve as infrastructure for more ambitious work on graph actions or isogeny walks.