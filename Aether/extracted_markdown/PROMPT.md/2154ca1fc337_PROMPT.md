Complete the partial Lean development in `Catalog/Bridges/EulerianTrail.lean` by fully formalizing the Eulerian parity theorem for finite multigraphs, with no placeholders, no `sorry`, and no unproved theorem declarations.

Target problem:
Given a finite multigraph `G : Multigraph nV nE`, and an `EulerianTrail G` consisting of
1. `vertices : Fin (nE + 1) → Fin nV`,
2. `edgePerm : Equiv.Perm (Fin nE)`, and
3. a proof `connects` that each permuted edge joins consecutive vertices,
prove that the set of odd-degree vertices has cardinality at most two.

Required scope:
- Keep the project centered on the combinatorics of Eulerian trails in finite multigraphs.
- Do not revive the ReLU/pi approximation direction.
- Work with the existing `Bridges.Multigraph` definitions if available; adapt statements to that API rather than inventing a large new graph library.
- Prefer a short, robust theorem chain over excessive generalization.

Suggested theorem pipeline:
1. Finish basic definitions cleanly:
   - `visitCount`
   - `startVertex`
   - `endVertex`
   - any needed 0/1 indicator helper, ideally implemented in a way that is easy to rewrite in `ℕ`.
2. Prove a counting identity for each vertex `v` expressing degree in terms of visits/endpoints. A good precise target is one of the following equivalent forms:
   - `G.degree v = 2 * internalVisitCount v + endpointContribution v`, or
   - `G.degree v + endpointAdjustment v = 2 * visitCount v`, or
   - `G.degree v = 2 * visitCount v - startIndicator v - endIndicator v`.
   Choose the formulation that is easiest to prove with the existing API.
3. Deduce parity consequences:
   - if `v ≠ startVertex` and `v ≠ endVertex`, then `Even (G.degree v)`;
   - if `startVertex = endVertex`, then every vertex has even degree;
   - if `startVertex ≠ endVertex`, then any odd-degree vertex must be one of the two endpoints.
4. Conclude the main theorem:
   - the finite set `{v | Odd (G.degree v)}` has cardinality at most `2`.

Proof strategy guidance:
- Follow the future direction encoded by the partial file itself: finite counting on trail indices.
- Count incidences edge-by-edge via the permutation `edgePerm`; because every edge is used exactly once, degree can be computed from appearances in consecutive pairs `(vertices i.castSucc, vertices i.succ)`.
- Use endpoint separation: every interior occurrence contributes two incidences, while the first and last occurrences contribute one each when they are endpoints.
- Prefer `Finset.card`, `Finset.filter`, and explicit bijections/injections on `Fin` over abstract parity machinery if that keeps proofs shorter.
- If a direct `visitCount` statement is cumbersome, introduce an auxiliary count of step-incidences and prove equality to degree first.

Deliverables:
- A complete compilable Lean file with the final theorem proving the odd-degree-vertices bound.
- Remove or prove all existing theorem headers such as `sum_indicator_succ`, `degree_visit_identity`, `odd_degree_vertices_le_two`, etc.
- Include concise docstrings for the main definitions and theorem.

Important constraints:
- No speculative claims, no asymptotic neural-network results, no new unrelated abstractions.
- If some originally stated identity is awkward as written, restate it in an equivalent provable form and use that to derive the final theorem.
- The final result should be mathematically meaningful and fully verified, even if intermediate theorem names or formulations are adjusted for proof tractability.