Formalize a complete, type-checking Lean 4 file proving the classical parity theorem for Eulerian trails in finite undirected multigraphs with loops, and do so in a minimal self-contained way.

Target file: `Catalog/Bridges/EulerianTrail.lean`

Scope:
1. Define a finite undirected multigraph with loops on vertices `Fin nV` and edges `Fin nE` by two endpoint maps `endpt₁ endpt₂ : Fin nE → Fin nV`.
2. Define `degree : Fin nV → Nat` as the number of endpoint incidences at the vertex, i.e. count edges with `endpt₁ e = v` plus count edges with `endpt₂ e = v`, so loops contribute 2.
3. Define `EulerianTrail G` consisting of:
   - `verts : Fin (nE + 1) → Fin nV`
   - `edgePerm : Equiv.Perm (Fin nE)`
   - `connects : ∀ i : Fin nE, let e := edgePerm i; ((G.endpt₁ e = verts (Fin.castSucc i) ∧ G.endpt₂ e = verts i.succ) ∨ (G.endpt₂ e = verts (Fin.castSucc i) ∧ G.endpt₁ e = verts i.succ))`
   Use any equivalent precise formulation that type-checks cleanly.
4. Define:
   - `startVertex`, `endVertex`
   - `visitCount v := |{i : Fin (nE+1) // verts i = v}|`
   - `startIndicator v`, `endIndicator v` as 0/1 naturals.
5. Prove the main local counting theorem:
   - `degree_add_indicators : G.degree v + startIndicator v + endIndicator v = 2 * visitCount v`
   This should be the central theorem. Structure the proof with helper lemmas if needed, e.g. counting how many times `v` appears among consecutive positions, or splitting incidences into entries/exits plus endpoints.
6. Deduce the parity consequences:
   - if `G.degree v` is odd, then `v = startVertex ∨ v = endVertex`
   - the finset/set of odd-degree vertices has cardinality at most 2
   - if `startVertex = endVertex`, then every vertex has even degree
7. Ensure there are no placeholders, no truncated definitions, and the file compiles.

Important constraints:
- Stay strictly on this theorem package. Do not generalize to existence of Eulerian trails, connectivity, graph library integration, or cryptography.
- Prefer a direct finite-counting development over importing heavy graph abstractions.
- Use `Finset.univ`, `Fintype.card`, `Nat` parity lemmas, and explicit helper lemmas about `Fin` indices as needed.
- If the exact `connects` shape above is awkward, refactor the trail representation slightly, but preserve the intended theorem and keep the model self-contained.

Suggested proof strategy:
- First prove a decomposition of `visitCount v` into interior occurrences plus possible start/end occurrences.
- Show each interior occurrence contributes exactly two incidences along the traversed edge sequence, while start/end contribute one each unless they coincide in the closed case, which is already handled by the two indicators.
- Convert this to the formula `degree v + startIndicator v + endIndicator v = 2 * visitCount v`.
- Use parity of the right-hand side to conclude that odd degree can only arise when the indicator sum is odd, hence only at the start or end.
- For the “at most two odd vertices” theorem, show every odd-degree vertex belongs to `{startVertex, endVertex}`.

Deliverable:
- One standalone Lean file with module docs and main theorem statements clearly named.
- The development should be robust and readable enough to serve as a reusable bridge result for future graph formalizations.